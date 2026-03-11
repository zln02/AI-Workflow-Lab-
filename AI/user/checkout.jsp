<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="model.User" %>
<%@ page import="model.CreditPackage" %>
<%@ page import="model.Plan" %>
<%@ page import="dao.CreditDAO" %>
<%@ page import="dao.CreditPackageDAO" %>
<%@ page import="dao.PlanDAO" %>
<%@ page import="dao.OrderDAO" %>
<%@ page import="dao.SubscriptionDAO" %>
<%@ page import="model.Order" %>
<%@ page import="model.Subscription" %>
<%@ page import="util.CSRFUtil" %>
<%@ page import="util.EscapeUtil" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.math.BigDecimal" %>
<%
  request.setCharacterEncoding("UTF-8");

  // 로그인 확인
  User user = (User) session.getAttribute("user");
  if (user == null || !user.isActive()) {
    response.sendRedirect("/AI/user/login.jsp?redirect=/AI/user/checkout.jsp" +
        (request.getQueryString() != null ? "?" + request.getQueryString() : ""));
    return;
  }

  int packageId = 0;
  try { packageId = Integer.parseInt(request.getParameter("packageId")); } catch (Exception e) {}

  // 플랜 코드 파라미터
  String planCode = request.getParameter("plan");
  if (packageId <= 0 && (planCode == null || !planCode.matches("^(STARTER|GROWTH|ENTERPRISE|PRO|FREE)$"))) {
    planCode = "GROWTH";
  }

  PlanDAO planDAO = new PlanDAO();
  Plan plan = null;
  CreditPackage creditPackage = null;
  try {
    if (packageId > 0) {
      creditPackage = new CreditPackageDAO().findById(packageId);
    } else {
      plan = planDAO.findByCode(planCode);
    }
  } catch (Exception e) { e.printStackTrace(); }

  String errorMessage = null;
  String successOrderId = null;

  // POST: 결제 처리
  if ("POST".equals(request.getMethod())) {
    if (!CSRFUtil.validateToken(request)) {
      errorMessage = "보안 검증에 실패했습니다. 다시 시도해주세요.";
    } else {
      String cardNumber = request.getParameter("cardNumber");
      String cardExpiry = request.getParameter("cardExpiry");
      String cardCvc = request.getParameter("cardCvc");
      String cardName = request.getParameter("cardName");
      String payMethod = request.getParameter("paymentMethod");
      if (payMethod == null) payMethod = "card";

      // 간단 검증
      boolean valid = true;
      if ("card".equals(payMethod)) {
        if (cardNumber == null || cardNumber.replaceAll("\\s","").length() < 15) {
          errorMessage = "카드 번호를 올바르게 입력해주세요."; valid = false;
        } else if (cardExpiry == null || !cardExpiry.matches("\\d{2}/\\d{2}")) {
          errorMessage = "유효기간을 올바르게 입력해주세요. (MM/YY)"; valid = false;
        } else if (cardCvc == null || cardCvc.length() < 3) {
          errorMessage = "CVC를 올바르게 입력해주세요."; valid = false;
        }
      }

      if (valid && (plan != null || creditPackage != null)) {
        try {
          // 주문 생성
          OrderDAO orderDAO = new OrderDAO();
          Order order = new Order();
          order.setCustomerName(user.getFullName() != null ? user.getFullName() : user.getUsername());
          order.setCustomerEmail(user.getEmail());
          order.setPaymentMethod(payMethod);
          double priceKRW = creditPackage != null
              ? creditPackage.getPrice().doubleValue()
              : plan.getPriceUsd().doubleValue();
          order.setTotalPrice(new BigDecimal(String.format("%.2f", priceKRW)));
          order.setOrderStatus("COMPLETED");

          int orderId = orderDAO.insertOrder(order);

          if (orderId > 0) {
            if (creditPackage != null) {
              orderDAO.insertOrderItem(orderId, "PACKAGE", creditPackage.getId(), 1, creditPackage.getPrice());
              new CreditDAO().grant(user.getId(), creditPackage.getCredits() + creditPackage.getBonusCredits(), "credit_package_" + creditPackage.getId());
              response.sendRedirect("/AI/user/complete.jsp?orderId=" + orderId + "&plan=CREDITS");
              return;
            }

            SubscriptionDAO subscriptionDAO = new SubscriptionDAO();
            Subscription sub = new Subscription();
            sub.setUserId(user.getId());
            sub.setPlanId(plan.getId());
            sub.setPlanCode(plan.getPlanCode());
            sub.setStartDate(LocalDate.now());
            sub.setEndDate(LocalDate.now().plusMonths(plan.getDurationMonths() > 0 ? plan.getDurationMonths() : 1));
            sub.setStatus("ACTIVE");
            sub.setPaymentMethod(payMethod);
            sub.setBillingCycle(plan.getBillingCycle());
            sub.setTransactionId("TXN-" + orderId + "-" + System.currentTimeMillis());
            subscriptionDAO.insert(sub);

            response.sendRedirect("/AI/user/complete.jsp?orderId=" + orderId + "&plan=" + planCode);
            return;
          } else {
            errorMessage = "주문 처리 중 오류가 발생했습니다. 다시 시도해주세요.";
          }
        } catch (Exception e) {
          e.printStackTrace();
          errorMessage = "결제 처리 중 오류가 발생했습니다: " + e.getMessage();
        }
      } else if (plan == null && creditPackage == null) {
        errorMessage = "선택한 상품을 찾을 수 없습니다.";
      }
    }
  }

  // 플랜 정보 (하드코딩 fallback)
  String planName = "그로스";
  double planPriceUSD = 29.99;
  int planMonths = 1;
  boolean isCreditPurchase = creditPackage != null;
  if (creditPackage != null) {
    planName = creditPackage.getPackageName() + " 크레딧 팩";
    planPriceUSD = creditPackage.getPrice().doubleValue();
    planMonths = 0;
  } else if (plan != null) {
    planName = plan.getName();
    planPriceUSD = plan.getPriceUsd().doubleValue();
    planMonths = plan.getDurationMonths() > 0 ? plan.getDurationMonths() : 1;
  }
  long planPriceKRW = Math.round(planPriceUSD);
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
  <link rel="stylesheet" href="/AI/assets/css/page.css">
  <style>
    main { max-width: 900px; margin: 0 auto; padding: 60px 20px 80px; }
    h1 { font-size: 2rem; font-weight: 800; letter-spacing: -.03em; margin-bottom: 8px; }
    .sub-title { color: var(--text-muted, #64748b); font-size: .9375rem; margin-bottom: 40px; }

    .checkout-grid {
      display: grid;
      grid-template-columns: 1fr 380px;
      gap: 28px;
      align-items: start;
    }
    @media (max-width: 768px) { .checkout-grid { grid-template-columns: 1fr; } }

    .card-heading {
      font-size: 1.0625rem; font-weight: 700; margin-bottom: 24px;
      padding-bottom: 16px; border-bottom: 1px solid rgba(255,255,255,.08);
    }

    /* Payment method tabs */
    .pay-tabs { display: flex; gap: 10px; margin-bottom: 24px; }
    .pay-tab {
      flex: 1; padding: 12px; border-radius: 12px; font-size: .875rem; font-weight: 600;
      border: 1px solid rgba(255,255,255,.1); cursor: pointer;
      background: rgba(255,255,255,.04); color: var(--text-muted, #64748b);
      text-align: center; transition: all .2s;
    }
    .pay-tab.active { border-color: rgba(59,130,246,.5); color: #93c5fd; background: rgba(59,130,246,.1); }

    /* Form */
    .form-group { margin-bottom: 20px; }
    .form-input {
      width: 100%; padding: 12px 14px; border-radius: 10px; font-size: .9375rem;
      background: rgba(255,255,255,.05); border: 1px solid rgba(255,255,255,.1);
      color: var(--text-primary, #f1f5f9); outline: none; font-family: inherit;
      transition: border-color .2s, box-shadow .2s;
    }
    .form-input::placeholder { color: rgba(148,163,184,.45); }
    .form-input:focus { border-color: rgba(59,130,246,.5); box-shadow: 0 0 0 3px rgba(59,130,246,.12); }
    .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }

    /* Order summary card */
    .plan-badge {
      display: inline-flex; align-items: center; gap: 6px;
      padding: 4px 12px; border-radius: 20px; font-size: .75rem; font-weight: 700;
      background: rgba(59,130,246,.2); color: #93c5fd; margin-bottom: 16px;
    }
    .plan-name { font-size: 1.375rem; font-weight: 800; margin-bottom: 6px; }
    .plan-desc { font-size: .875rem; color: var(--text-muted, #64748b); margin-bottom: 24px; line-height: 1.6; }
    .price-row { display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px; font-size: .9rem; color: var(--text-secondary, #94a3b8); }
    .price-total { font-size: 1.25rem; font-weight: 800; color: var(--text-primary); }
    .divider { border: none; border-top: 1px solid rgba(255,255,255,.08); margin: 16px 0; }

    /* Submit button */
    .btn-pay {
      width: 100%; padding: 15px; border-radius: 12px; font-size: 1rem; font-weight: 700;
      border: none; cursor: pointer; margin-top: 20px;
      background: linear-gradient(135deg, #3b82f6, #8b5cf6); color: #fff;
      box-shadow: 0 4px 20px rgba(59,130,246,.35); transition: opacity .2s, transform .15s;
    }
    .btn-pay:hover { opacity: .9; transform: translateY(-1px); }
    .btn-pay:disabled { opacity: .6; cursor: not-allowed; transform: none; }

    /* Security note */
    .security-note { font-size: .75rem; color: var(--text-muted, #64748b); text-align: center; margin-top: 16px; }
    .security-note i { margin-right: 4px; }
  </style>
</head>
<body>
<%@ include file="/AI/partials/header.jsp" %>

<main>
  <h1>결제</h1>
  <p class="sub-title">안전하게 구독을 시작하세요</p>

  <% if (errorMessage != null) { %>
  <div class="alert-error"><i class="bi bi-exclamation-triangle me-2"></i><%= EscapeUtil.escapeHtml(errorMessage) %></div>
  <% } %>

  <div class="checkout-grid">
    <!-- 결제 정보 입력 -->
    <div class="glass-card">
      <div class="card-heading"><i class="bi bi-credit-card me-2"></i>결제 수단</div>

      <div class="pay-tabs">
        <div class="pay-tab active" data-method="card" onclick="selectMethod('card', this)">
          <i class="bi bi-credit-card me-1"></i>신용/체크카드
        </div>
        <div class="pay-tab" data-method="kakao" onclick="selectMethod('kakao', this)">
          <i class="bi bi-chat-fill me-1"></i>카카오페이
        </div>
        <div class="pay-tab" data-method="naver" onclick="selectMethod('naver', this)">
          <i class="bi bi-n-square me-1"></i>네이버페이
        </div>
      </div>

      <form method="POST" id="checkoutForm"
            action="/AI/user/checkout.jsp?<%= isCreditPurchase ? "packageId=" + packageId : "plan=" + EscapeUtil.escapeHtml(planCode) %>">
        <%= CSRFUtil.getHiddenFieldHtml(request) %>
        <input type="hidden" name="paymentMethod" id="paymentMethodInput" value="card">

        <!-- 카드 입력 섹션 -->
        <div id="cardSection">
          <div class="form-group">
            <label>카드 번호</label>
            <input type="text" name="cardNumber" class="form-input" placeholder="0000 0000 0000 0000"
                   maxlength="19" oninput="formatCard(this)" autocomplete="cc-number">
          </div>
          <div class="form-row">
            <div class="form-group">
              <label>유효기간</label>
              <input type="text" name="cardExpiry" class="form-input" placeholder="MM/YY"
                     maxlength="5" oninput="formatExpiry(this)" autocomplete="cc-exp">
            </div>
            <div class="form-group">
              <label>CVC</label>
              <input type="text" name="cardCvc" class="form-input" placeholder="123"
                     maxlength="4" oninput="this.value=this.value.replace(/\D/g,'')" autocomplete="cc-csc">
            </div>
          </div>
          <div class="form-group">
            <label>카드 소유자 이름</label>
            <input type="text" name="cardName" class="form-input" placeholder="홍길동"
                   value="<%= EscapeUtil.escapeHtml(user.getFullName() != null ? user.getFullName() : "") %>"
                   autocomplete="cc-name">
          </div>
        </div>

        <!-- 간편결제 섹션 (카카오/네이버) -->
        <div id="simplePaySection" style="display:none; text-align:center; padding: 32px 0;">
          <p id="simplePayText" style="color: var(--text-muted); font-size:.9375rem; line-height:1.6;"></p>
        </div>

        <button type="submit" class="btn-pay" id="payBtn">
          <i class="bi bi-lock-fill me-2"></i>
          <span id="payBtnText">₩<%= String.format("%,d", planPriceKRW) %> 결제하기</span>
        </button>
      </form>

      <p class="security-note">
        <i class="bi bi-shield-check"></i>
        256비트 SSL 암호화로 안전하게 보호됩니다
      </p>
    </div>

    <!-- 주문 요약 -->
    <div>
      <div class="glass-card">
        <div class="card-heading"><i class="bi bi-receipt me-2"></i>주문 요약</div>

        <div class="plan-badge"><i class="bi bi-star-fill"></i><%= EscapeUtil.escapeHtml(isCreditPurchase ? "CREDITS" : planCode) %></div>
        <div class="plan-name"><%= EscapeUtil.escapeHtml(planName) %><%= isCreditPurchase ? "" : " 플랜" %></div>
        <div class="plan-desc">
          <%= isCreditPurchase
              ? "즉시 사용 가능한 크레딧을 구매합니다."
              : (planCode.equals("STARTER") ? "AI 입문자를 위한 기본 플랜" :
              planCode.equals("GROWTH") ? "전문가를 위한 성장 플랜" : "팀과 기업을 위한 프리미엄 플랜") %>
        </div>

        <% if (!isCreditPurchase) { %>
        <div class="price-row">
          <span>구독 기간</span>
          <span><%= planMonths %>개월</span>
        </div>
        <div class="price-row">
          <span>₩<%= String.format("%,d", planPriceKRW) %></span>
        </div>
        <% } else { %>
        <div class="price-row">
          <span>제공 크레딧</span>
          <span><%= creditPackage.getCredits() + creditPackage.getBonusCredits() %> credits</span>
        </div>
        <div class="price-row">
          <span>구성</span>
          <span>기본 <%= creditPackage.getCredits() %> + 보너스 <%= creditPackage.getBonusCredits() %></span>
        </div>
        <% } %>
        <hr class="divider">
        <div class="price-row">
          <span style="font-weight:700; color: var(--text-primary);">총 결제 금액</span>
          <span class="price-total">₩<%= String.format("%,d", planPriceKRW) %></span>
        </div>

        <hr class="divider">
        <div style="font-size:.8125rem; color: var(--text-muted, #64748b); line-height:1.7;">
          <% if (isCreditPurchase) { %>
          <div><i class="bi bi-check-circle-fill" style="color:#34d399; margin-right:6px;"></i>결제 직후 크레딧 즉시 지급</div>
          <div><i class="bi bi-check-circle-fill" style="color:#34d399; margin-right:6px;"></i>구독 없이 단건 구매 가능</div>
          <div><i class="bi bi-check-circle-fill" style="color:#34d399; margin-right:6px;"></i>Playground/실습 랩에서 즉시 사용</div>
          <% } else { %>
          <div><i class="bi bi-check-circle-fill" style="color:#34d399; margin-right:6px;"></i>즉시 구독 활성화</div>
          <div><i class="bi bi-check-circle-fill" style="color:#34d399; margin-right:6px;"></i>다음 달 자동 갱신</div>
          <div><i class="bi bi-check-circle-fill" style="color:#34d399; margin-right:6px;"></i>언제든 취소 가능</div>
          <% } %>
        </div>
      </div>

      <div style="margin-top:16px;">
        <a href="/AI/user/pricing.jsp" style="color: var(--text-muted, #64748b); font-size:.8125rem; text-decoration:none;">
          <i class="bi bi-arrow-left me-1"></i>요금제 변경
        </a>
      </div>
    </div>
  </div>
</main>

<script>
  function selectMethod(method, el) {
    document.querySelectorAll('.pay-tab').forEach(t => t.classList.remove('active'));
    el.classList.add('active');
    document.getElementById('paymentMethodInput').value = method;

    const cardSec = document.getElementById('cardSection');
    const simpleSec = document.getElementById('simplePaySection');

    if (method === 'card') {
      cardSec.style.display = 'block';
      simpleSec.style.display = 'none';
      document.getElementById('payBtnText').textContent = '₩<%= String.format("%,d", planPriceKRW) %> 결제하기';
    } else {
      cardSec.style.display = 'none';
      simpleSec.style.display = 'block';
      const name = method === 'kakao' ? '카카오페이' : '네이버페이';
      document.getElementById('simplePayText').textContent = name + '로 안전하게 결제합니다. 버튼을 클릭하면 ' + name + ' 인증 화면으로 이동합니다.';
      document.getElementById('payBtnText').textContent = name + '로 ₩<%= String.format("%,d", planPriceKRW) %> 결제';
    }
  }

  function formatCard(input) {
    let v = input.value.replace(/\D/g, '').substring(0, 16);
    input.value = v.replace(/(.{4})/g, '$1 ').trim();
  }

  function formatExpiry(input) {
    let v = input.value.replace(/\D/g, '').substring(0, 4);
    if (v.length >= 2) v = v.substring(0,2) + '/' + v.substring(2);
    input.value = v;
  }

  // 결제 버튼 클릭 시 로딩 상태
  document.getElementById('checkoutForm').addEventListener('submit', function(e) {
    const btn = document.getElementById('payBtn');
    btn.disabled = true;
    btn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>처리 중...';
  });
</script>

<jsp:include page="/AI/partials/footer.jsp"/>
<script src="/AI/assets/js/user.js"></script>
</body>
</html>
