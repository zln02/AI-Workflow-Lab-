# Task 03: P1 실제 결제(PG) 연동 구현

## 프로젝트 경로
`/var/lib/tomcat9/webapps/ROOT/`

## 현재 문제
- `AI/api/subscribe.jsp`에서 구독 버튼 클릭만으로 결제 없이 DB에 ACTIVE 구독 생성
- `checkout.jsp`는 "결제 기능 준비 중" 빈 페이지
- `transactionId = "TXN-" + System.currentTimeMillis()` 가짜 트랜잭션 ID

---

## 작업 3-1: PortOne(아임포트) 결제 연동 Servlet 구현

> PortOne을 선택한 이유: 한국 PG 통합 지원, 무료 테스트 환경, JavaScript SDK 제공

### 새 파일: `WEB-INF/src/servlet/PaymentServlet.java`

```java
package servlet;

import dao.PlanDAO;
import dao.SubscriptionDAO;
import model.Plan;
import model.Subscription;
import model.User;
import dto.ApiResponse;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.time.LocalDate;
import java.util.Map;
import java.util.HashMap;

/**
 * 결제 처리 서블릿
 * POST /api/payment/prepare  - 결제 준비 (merchant_uid 생성)
 * POST /api/payment/complete - 결제 완료 검증
 */
@WebServlet("/api/payment/*")
public class PaymentServlet extends HttpServlet {
    private Gson gson;
    private String impKey;
    private String impSecret;

    @Override
    public void init() throws ServletException {
        gson = new GsonBuilder().setDateFormat("yyyy-MM-dd HH:mm:ss").create();
        impKey = System.getenv("PORTONE_API_KEY");
        impSecret = System.getenv("PORTONE_API_SECRET");
        if (impKey == null || impSecret == null) {
            System.err.println("[WARNING] PORTONE_API_KEY/PORTONE_API_SECRET 환경변수 미설정. 결제 검증 불가.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json; charset=UTF-8");
        PrintWriter out = response.getWriter();

        // 로그인 확인
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null || !user.isActive()) {
            response.setStatus(401);
            out.print(gson.toJson(ApiResponse.error("로그인이 필요합니다.")));
            return;
        }

        String pathInfo = request.getPathInfo();
        if (pathInfo == null) {
            response.setStatus(400);
            out.print(gson.toJson(ApiResponse.badRequest("잘못된 요청입니다.")));
            return;
        }

        try {
            switch (pathInfo) {
                case "/prepare":
                    handlePrepare(request, response, user, out);
                    break;
                case "/complete":
                    handleComplete(request, response, user, out);
                    break;
                default:
                    response.setStatus(404);
                    out.print(gson.toJson(ApiResponse.notFound("엔드포인트를 찾을 수 없습니다.")));
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(500);
            out.print(gson.toJson(ApiResponse.error("결제 처리 중 오류가 발생했습니다.")));
        }
    }

    /**
     * 결제 준비: merchant_uid 생성 및 결제 금액 사전 등록
     */
    private void handlePrepare(HttpServletRequest request, HttpServletResponse response,
                                User user, PrintWriter out) throws Exception {
        // JSON body 읽기
        String body = readBody(request);
        Map<String, Object> json = gson.fromJson(body, Map.class);
        String planCode = (String) json.get("planCode");

        if (planCode == null || !planCode.matches("^(STARTER|GROWTH|ENTERPRISE)$")) {
            response.setStatus(400);
            out.print(gson.toJson(ApiResponse.badRequest("유효하지 않은 요금제입니다.")));
            return;
        }

        PlanDAO planDAO = new PlanDAO();
        Plan plan = planDAO.findByCode(planCode);
        if (plan == null) {
            response.setStatus(404);
            out.print(gson.toJson(ApiResponse.notFound("요금제를 찾을 수 없습니다.")));
            return;
        }

        // 고유 주문번호 생성 (중복 방지)
        String merchantUid = "ORDER-" + user.getId() + "-" + System.currentTimeMillis();

        // 결제 금액 (KRW 기준, 소수점 없음)
        long amountKrw = Math.round(plan.getPrice().doubleValue() * 1350);

        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("merchantUid", merchantUid);
        result.put("amount", amountKrw);
        result.put("planCode", planCode);
        result.put("planName", plan.getName());
        result.put("buyerEmail", user.getEmail());
        result.put("buyerName", user.getFullName());

        out.print(gson.toJson(result));
    }

    /**
     * 결제 완료 검증: PortOne API로 결제 금액 재검증 후 구독 생성
     */
    private void handleComplete(HttpServletRequest request, HttpServletResponse response,
                                 User user, PrintWriter out) throws Exception {
        String body = readBody(request);
        Map<String, Object> json = gson.fromJson(body, Map.class);
        String impUid = (String) json.get("imp_uid");
        String merchantUid = (String) json.get("merchant_uid");
        String planCode = (String) json.get("planCode");

        if (impUid == null || merchantUid == null || planCode == null) {
            response.setStatus(400);
            out.print(gson.toJson(ApiResponse.badRequest("필수 파라미터가 누락되었습니다.")));
            return;
        }

        // 1. PortOne API로 결제 정보 조회
        Map<String, Object> paymentData = verifyPaymentWithPortOne(impUid);
        if (paymentData == null) {
            response.setStatus(400);
            out.print(gson.toJson(ApiResponse.error("결제 검증에 실패했습니다.")));
            return;
        }

        String status = (String) paymentData.get("status");
        double paidAmount = ((Number) paymentData.get("amount")).doubleValue();
        String pgMerchantUid = (String) paymentData.get("merchant_uid");

        // 2. merchant_uid 일치 확인
        if (!merchantUid.equals(pgMerchantUid)) {
            response.setStatus(400);
            out.print(gson.toJson(ApiResponse.error("주문번호가 일치하지 않습니다.")));
            return;
        }

        // 3. 결제 상태 확인
        if (!"paid".equals(status)) {
            response.setStatus(400);
            out.print(gson.toJson(ApiResponse.error("결제가 완료되지 않았습니다. 상태: " + status)));
            return;
        }

        // 4. 결제 금액 검증
        PlanDAO planDAO = new PlanDAO();
        Plan plan = planDAO.findByCode(planCode);
        if (plan == null) {
            response.setStatus(404);
            out.print(gson.toJson(ApiResponse.error("요금제를 찾을 수 없습니다.")));
            return;
        }

        long expectedAmount = Math.round(plan.getPrice().doubleValue() * 1350);
        if (Math.abs(paidAmount - expectedAmount) > 1) { // 1원 이내 오차 허용
            response.setStatus(400);
            out.print(gson.toJson(ApiResponse.error(
                "결제 금액이 일치하지 않습니다. 예상: " + expectedAmount + ", 실제: " + (long) paidAmount)));
            // TODO: 관리자 알림, 환불 처리
            return;
        }

        // 5. 구독 생성
        Subscription subscription = new Subscription();
        subscription.setUserId(user.getId());
        subscription.setPlanCode(planCode);
        subscription.setStartDate(LocalDate.now());
        subscription.setEndDate(LocalDate.now().plusMonths(plan.getDurationMonths()));
        subscription.setStatus("ACTIVE");
        subscription.setPaymentMethod("card");
        subscription.setTransactionId(impUid);

        SubscriptionDAO subscriptionDAO = new SubscriptionDAO();
        long subscriptionId = subscriptionDAO.insert(subscription);

        if (subscriptionId > 0) {
            Map<String, Object> result = new HashMap<>();
            result.put("success", true);
            result.put("subscriptionId", subscriptionId);
            result.put("planCode", planCode);
            result.put("startDate", subscription.getStartDate().toString());
            result.put("endDate", subscription.getEndDate().toString());
            out.print(gson.toJson(result));
        } else {
            response.setStatus(500);
            out.print(gson.toJson(ApiResponse.error("구독 생성에 실패했습니다.")));
        }
    }

    /**
     * PortOne API로 결제 검증
     */
    private Map<String, Object> verifyPaymentWithPortOne(String impUid) {
        try {
            // 1. 액세스 토큰 발급
            String accessToken = getPortOneAccessToken();
            if (accessToken == null) return null;

            // 2. 결제 정보 조회
            URL url = new URL("https://api.iamport.kr/payments/" + impUid);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setRequestProperty("Authorization", accessToken);
            conn.setRequestProperty("Content-Type", "application/json");

            int responseCode = conn.getResponseCode();
            if (responseCode == 200) {
                String responseBody = readResponse(conn);
                Map<String, Object> result = gson.fromJson(responseBody, Map.class);
                return (Map<String, Object>) result.get("response");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    private String getPortOneAccessToken() {
        try {
            URL url = new URL("https://api.iamport.kr/users/getToken");
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setDoOutput(true);

            Map<String, String> tokenRequest = new HashMap<>();
            tokenRequest.put("imp_key", impKey);
            tokenRequest.put("imp_secret", impSecret);

            conn.getOutputStream().write(gson.toJson(tokenRequest).getBytes("UTF-8"));

            if (conn.getResponseCode() == 200) {
                String responseBody = readResponse(conn);
                Map<String, Object> result = gson.fromJson(responseBody, Map.class);
                Map<String, Object> resp = (Map<String, Object>) result.get("response");
                return (String) resp.get("access_token");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    private String readBody(HttpServletRequest request) throws IOException {
        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        }
        return sb.toString();
    }

    private String readResponse(HttpURLConnection conn) throws IOException {
        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(conn.getInputStream(), "UTF-8"))) {
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        }
        return sb.toString();
    }
}
```

### web.xml에 서블릿 매핑 추가:
```xml
<servlet>
    <servlet-name>PaymentServlet</servlet-name>
    <servlet-class>servlet.PaymentServlet</servlet-class>
</servlet>
<servlet-mapping>
    <servlet-name>PaymentServlet</servlet-name>
    <url-pattern>/api/payment/*</url-pattern>
</servlet-mapping>
```

---

## 작업 3-2: checkout.jsp 실제 결제 UI 구현

### 파일: `AI/user/checkout.jsp` (전체 교체)

```jsp
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="model.User" %>
<%@ page import="util.EscapeUtil" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !user.isActive()) {
        response.sendRedirect("/AI/user/login.jsp?redirect=" +
            java.net.URLEncoder.encode(request.getRequestURI() + "?" + (request.getQueryString() != null ? request.getQueryString() : ""), "UTF-8"));
        return;
    }

    String planCode = request.getParameter("plan");
    if (planCode == null || planCode.isEmpty()) {
        response.sendRedirect("/AI/user/pricing.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>결제 - AI Workflow Lab</title>
    <link rel="icon" href="data:,">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link rel="stylesheet" href="/AI/assets/css/dark-theme.css">
    <link rel="stylesheet" href="/AI/assets/css/user.css">
    <!-- PortOne JavaScript SDK -->
    <script src="https://cdn.iamport.kr/v1/iamport.js"></script>
</head>
<body>
    <%@ include file="/AI/partials/header.jsp" %>

    <main style="width: min(600px, 100%); margin: 0 auto; padding: 80px 22px;">
        <section class="user-hero" style="text-align: center; margin-bottom: 40px;">
            <h1>결제</h1>
            <p style="color: var(--text-secondary); margin-top: 12px;">구독 플랜 결제를 진행합니다.</p>
        </section>

        <section>
            <div class="glass-card" style="padding: 48px;">
                <!-- 주문 요약 -->
                <h3 style="margin-bottom: 24px; font-size: 20px;">주문 요약</h3>
                <div id="orderSummary" style="margin-bottom: 32px;">
                    <div style="display: flex; justify-content: space-between; padding: 12px 0; border-bottom: 1px solid var(--border);">
                        <span id="planName" style="font-weight: 500;">로딩 중...</span>
                        <span id="planPrice" style="font-weight: 600; color: var(--accent);">-</span>
                    </div>
                    <div style="display: flex; justify-content: space-between; padding: 16px 0; font-size: 18px; font-weight: 600;">
                        <span>총 결제금액</span>
                        <span id="totalPrice" style="color: var(--accent);">-</span>
                    </div>
                </div>

                <!-- 결제 버튼 -->
                <button id="payBtn" class="btn primary" style="width: 100%; padding: 16px; font-size: 16px;" disabled>
                    <i class="bi bi-credit-card me-2"></i>결제하기
                </button>

                <!-- 안내 문구 -->
                <div style="margin-top: 24px; padding: 16px; background: var(--surface); border-radius: 12px;">
                    <p style="font-size: 12px; color: var(--text-secondary); margin: 0; line-height: 1.6;">
                        <i class="bi bi-shield-check me-1"></i>
                        결제는 PortOne(아임포트)을 통해 안전하게 처리됩니다.<br>
                        결제 완료 후 즉시 구독이 활성화됩니다.
                    </p>
                </div>
            </div>
        </section>
    </main>

    <script src="/AI/assets/js/user.js"></script>
    <script type="module">
        import { toast } from '/AI/assets/js/toast.js';

        const planCode = '<%= EscapeUtil.escapeJavaScript(planCode) %>';
        let paymentData = null;

        // 1. 결제 준비 - 서버에서 주문 정보 가져오기
        async function preparePayment() {
            try {
                const res = await fetch('/api/payment/prepare', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ planCode })
                });
                const data = await res.json();

                if (!data.success) {
                    toast(data.message || '결제 준비에 실패했습니다.', 'error');
                    return;
                }

                paymentData = data;
                document.getElementById('planName').textContent = data.planName + ' 플랜';
                document.getElementById('planPrice').textContent = Number(data.amount).toLocaleString() + '원';
                document.getElementById('totalPrice').textContent = Number(data.amount).toLocaleString() + '원';
                document.getElementById('payBtn').disabled = false;

            } catch (err) {
                console.error(err);
                toast('결제 준비 중 오류가 발생했습니다.', 'error');
            }
        }

        // 2. PortOne 결제 요청
        document.getElementById('payBtn').addEventListener('click', async () => {
            if (!paymentData) {
                toast('결제 정보를 불러오는 중입니다.', 'warning');
                return;
            }

            const btn = document.getElementById('payBtn');
            btn.disabled = true;
            btn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>결제 진행 중...';

            // PortOne 초기화 (가맹점 식별코드를 환경에 맞게 설정)
            const IMP = window.IMP;
            IMP.init('imp00000000'); // TODO: 실제 가맹점 코드로 변경

            IMP.request_pay({
                pg: 'html5_inicis',  // PG사 (이니시스, 카카오페이 등)
                pay_method: 'card',
                merchant_uid: paymentData.merchantUid,
                name: 'AI Workflow Lab - ' + paymentData.planName + ' 플랜',
                amount: paymentData.amount,
                buyer_email: paymentData.buyerEmail,
                buyer_name: paymentData.buyerName
            }, async (rsp) => {
                if (rsp.success) {
                    // 3. 결제 성공 -> 서버에서 검증
                    try {
                        const verifyRes = await fetch('/api/payment/complete', {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/json' },
                            body: JSON.stringify({
                                imp_uid: rsp.imp_uid,
                                merchant_uid: rsp.merchant_uid,
                                planCode: planCode
                            })
                        });
                        const verifyData = await verifyRes.json();

                        if (verifyData.success) {
                            toast('결제가 완료되었습니다!', 'success');
                            setTimeout(() => {
                                window.location.href = '/AI/user/complete.jsp?type=subscribe&plan=' + planCode;
                            }, 1500);
                        } else {
                            toast(verifyData.message || '결제 검증에 실패했습니다.', 'error');
                            btn.disabled = false;
                            btn.innerHTML = '<i class="bi bi-credit-card me-2"></i>결제하기';
                        }
                    } catch (err) {
                        console.error(err);
                        toast('결제 검증 중 오류가 발생했습니다.', 'error');
                        btn.disabled = false;
                        btn.innerHTML = '<i class="bi bi-credit-card me-2"></i>결제하기';
                    }
                } else {
                    // 결제 실패 또는 취소
                    toast(rsp.error_msg || '결제가 취소되었습니다.', 'error');
                    btn.disabled = false;
                    btn.innerHTML = '<i class="bi bi-credit-card me-2"></i>결제하기';
                }
            });
        });

        // 페이지 로드 시 결제 준비
        preparePayment();
    </script>
    <jsp:include page="/AI/partials/footer.jsp"/>
</body>
</html>
```

---

## 작업 3-3: pricing.jsp 구독 버튼 수정

### 파일: `AI/user/pricing.jsp`

pricing.jsp에서 구독 버튼 클릭 시 직접 subscribe.jsp API를 호출하는 대신 checkout.jsp로 이동하도록 변경:

**기존 JavaScript 부분 (170~217행) 전체 교체**:
```javascript
document.querySelectorAll('[data-plan]').forEach(btn => {
    btn.addEventListener('click', () => {
        const planCode = btn.dataset.plan;
        if (!planCode) {
            toast('요금제를 선택할 수 없습니다', 'error');
            return;
        }
        // checkout 페이지로 이동
        window.location.href = '/AI/user/checkout.jsp?plan=' + encodeURIComponent(planCode);
    });
});
```

---

## 환경 변수 설정 필요
`/etc/default/tomcat9`에 추가:
```bash
PORTONE_API_KEY=your_api_key_here
PORTONE_API_SECRET=your_api_secret_here
PORTONE_MERCHANT_CODE=imp00000000
```

## 테스트
1. PortOne 테스트 가맹점 가입: https://admin.portone.io
2. 테스트 모드로 결제 진행
3. 결제 완료 후 mypage.jsp에서 구독 상태 확인

## 컴파일
```bash
cd /var/lib/tomcat9/webapps/ROOT
javac -cp "WEB-INF/lib/*:/usr/share/tomcat9/lib/*" \
  -d WEB-INF/classes \
  WEB-INF/src/servlet/PaymentServlet.java
sudo systemctl restart tomcat9
```
