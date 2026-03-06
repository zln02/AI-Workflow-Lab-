<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.PackageDAO" %>
<%@ page import="dao.PlanDAO" %>
<%@ page import="model.Package" %>
<%@ page import="model.Plan" %>
<%@ page import="java.util.List" %>
<%
  PackageDAO packageDAO = new PackageDAO();
  PlanDAO planDAO = new PlanDAO();
  List<Package> packages = packageDAO.findAll();
  List<Plan> plans = planDAO.findAll();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>요금제- AI Workflow Lab</title>
  <link rel="stylesheet" href="/AI/assets/css/user.css">
</head>
<body>
  <!-- Navbar -->
  <nav class="navbar" id="navbar">
    <div class="navbar-container">
      <a href="/AI/user/home.jsp" class="navbar-logo">AI Workflow Lab/a>
      <ul class="navbar-menu" id="navbarMenu">
        <li><a href="/AI/user/models.jsp">모델</a></li>
        <li><a href="/AI/user/package.jsp">패키지</a></li>
        <li><a href="/AI/user/pricing.jsp" class="active">요금제</a></li>
        <li><a href="/AI/user/home.jsp#contact">문의</a></li>
        <%
          model.User currentUser = (model.User) session.getAttribute("user");
          if (currentUser != null && currentUser.isActive()) {
        %>
          <li><a href="/AI/user/mypage.jsp">마이페이지</a></li>
          <li><a href="/AI/user/logout.jsp">로그아웃</a></li>
        <% } else { %>
          <li><a href="/AI/user/login.jsp">로그인</a></li>
          <li><a href="/AI/user/signup.jsp">회원가입</a></li>
        <% } %>
      </ul>
      <button class="navbar-toggle" id="navbarToggle">☰</button>
    </div>
  </nav>

  <!-- Currency Toggle -->
  <div class="currency-toggle">
    <button type="button" data-currency="USD" aria-label="USD로 전환">USD</button>
    <button type="button" data-currency="KRW" aria-label="KRW로 전환">KRW</button>
  </div>

  <main style="width: min(980px, 100%); margin: 0 auto; padding: 80px 22px;">
    <!-- Hero Section -->
    <section class="user-hero">
      <h1>요금제 선택</h1>
      <p>개인, 팀, 기업을 위한 유연한 요금 옵션. 모든 플랜에는 AI 모델 마켓플레이스 및 API 통합이 포함됩니다.</p>
    </section>

    <!-- Pricing Section -->
    <section style="text-align: center; margin-bottom: 80px;">
      <div class="user-cards pricing-grid">
        <% for (Plan plan : plans) { %>
          <%
            boolean isFeatured = "GROWTH".equals(plan.getCode());
            double priceUsd = plan.getPriceUsd() != null ? plan.getPriceUsd().doubleValue() : 0;
            long priceKrw = Math.round(priceUsd * 1350);
            String durationText = plan.getDurationMonths() == 1 ? "1개월 무제한" : 
                                  plan.getDurationMonths() == 6 ? "6개월 무제한" : 
                                  plan.getDurationMonths() == 12 ? "1년 무제한" : 
                                  plan.getDurationMonths() + "개월 무제한";
          %>
          <div class="user-card glass-card price-card <%= isFeatured ? "featured" : "" %>" 
               style="<%= isFeatured ? "border: 2px solid var(--accent); box-shadow: 0 8px 16px var(--shadow-hover);" : "" %> display: flex; flex-direction: column; height: 100%;">
            <div style="flex: 1;">
              <h3 style="margin-bottom: 12px; font-size: 24px; line-height: 1.16667; font-weight: 600;"><%= plan.getName() %></h3>
              <p style="color: var(--text-secondary); font-size: 17px; line-height: 1.47059; margin-bottom: 20px;"><%= durationText %></p>
              <div class="price-display" style="font-size: 32px; line-height: 1.125; font-weight: 600; margin: 20px 0 8px;" data-price-usd="<%= priceUsd %>">
                <%= String.format("%,d", priceKrw) %>원
              </div>
              <div style="font-size: 14px; color: var(--text-secondary); margin-bottom: 24px;">
                ($<%= String.format("%.2f", priceUsd) %>/<%= plan.getDurationMonths() == 1 ? "mo" : plan.getDurationMonths() == 6 ? "6mo" : "yr" %>)
              </div>
              <ul style="list-style: none; padding: 0; margin: 0 0 24px; text-align: left;">
                <li style="padding: 8px 0; font-size: 17px; line-height: 1.47059; color: var(--text);">모든 모델 무제한</li>
                <li style="padding: 8px 0; font-size: 17px; line-height: 1.47059; color: var(--text);">모든 패키지 무제한</li>
                <li style="padding: 8px 0; font-size: 17px; line-height: 1.47059; color: var(--text);">우선 지원</li>
                <% if (plan.getDurationMonths() >= 6) { %>
                  <li style="padding: 8px 0; font-size: 17px; line-height: 1.47059; color: var(--text);">API 우선 접근</li>
                <% } %>
                <% if (plan.getDurationMonths() == 12) { %>
                  <li style="padding: 8px 0; font-size: 17px; line-height: 1.47059; color: var(--text);">전담 지원</li>
                  <li style="padding: 8px 0; font-size: 17px; line-height: 1.47059; color: var(--text);">맞춤 통합</li>
                <% } %>
              </ul>
            </div>
            <div style="margin-top: auto; padding-top: 24px; text-align: center;">
              <button class="btn primary" style="width: 100%;" data-plan="<%= plan.getCode() %>">구독하기</button>
            </div>
          </div>
        <% } %>
      </div>
    </section>

    <!-- Package Pricing Section -->
    <% if (!packages.isEmpty()) { %>
      <section style="text-align: center; margin-bottom: 80px;">
        <h2 style="margin-bottom: 8px;">패키지 요금제</h2>
        <p style="color: var(--text-secondary); font-size: 21px; line-height: 1.381; margin-bottom: 40px;">특별 가격의 사전 구성된 번들</p>
        <div class="user-cards">
          <% for (Package pkg : packages) { %>
            <div class="user-card glass-card" style="display: flex; flex-direction: column; height: 100%;">
              <div style="flex: 1;">
                <h3 style="margin-bottom: 12px; font-size: 24px; line-height: 1.16667; font-weight: 600;"><%= pkg.getTitle() != null ? pkg.getTitle() : "Package" %></h3>
                <p style="color: var(--text-secondary); margin: 16px 0; line-height: 1.47059; font-size: 17px;">
                  <%= pkg.getDescription() != null && pkg.getDescription().length() > 150 
                      ? pkg.getDescription().substring(0, 150) + "..." 
                      : (pkg.getDescription() != null ? pkg.getDescription() : "설명 없음") %>
                </p>
              </div>
              <div style="margin-top: auto; text-align: center;">
                <div style="margin: 20px 0;">
                  <% 
                    double priceUsd = pkg.getPrice() != null ? pkg.getPrice().doubleValue() : 0;
                    long priceKrw = Math.round(priceUsd * 1350);
                    double discountUsd = pkg.getDiscountPrice() != null && pkg.getDiscountPrice().compareTo(java.math.BigDecimal.ZERO) > 0 
                        ? pkg.getDiscountPrice().doubleValue() : 0;
                    long discountKrw = Math.round(discountUsd * 1350);
                  %>
                  <% if (discountUsd > 0) { %>
                    <div style="text-decoration: line-through; color: var(--text-secondary); font-size: 14px; margin-bottom: 8px;">
                      <%= String.format("%,d", priceKrw) %>원 ($<%= String.format("%.0f", priceUsd) %>/월)
                    </div>
                    <div class="price-display" style="color: #ff3b30; font-size: 32px; line-height: 1.125; font-weight: 600; margin-bottom: 8px;">
                      <%= String.format("%,d", discountKrw) %>원
                    </div>
                    <div style="font-size: 14px; color: var(--text-secondary); margin-bottom: 16px;">
                      ($<%= String.format("%.0f", discountUsd) %>/월)
                    </div>
                  <% } else { %>
                    <div class="price-display" style="font-size: 32px; line-height: 1.125; font-weight: 600; margin-bottom: 8px;">
                      <%= String.format("%,d", priceKrw) %>원
                    </div>
                    <div style="font-size: 14px; color: var(--text-secondary); margin-bottom: 16px;">
                      ($<%= String.format("%.0f", priceUsd) %>/월)
                    </div>
                  <% } %>
                </div>
                <a href="/AI/user/package.jsp?id=<%= pkg.getId() %>" class="btn primary btn-sm">상세보기</a>
              </div>
            </div>
          <% } %>
        </div>
      </section>
    <% } %>
  </main>
  
  <script src="/AI/assets/js/user.js"></script>
  <script type="module">
    import { toast } from '/AI/assets/js/toast.js';

    document.querySelectorAll('[data-plan]').forEach(btn => {
      btn.addEventListener('click', async () => {
        const planCode = btn.dataset.plan;
        
        if (!planCode) {
          toast('요금제를 선택할 수 없습니다', 'error');
          return;
        }

        try {
          btn.disabled = true;
          btn.textContent = '처리 중...';
          
          const response = await fetch('/AI/api/subscribe.jsp', {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json'
            },
            body: JSON.stringify({ planCode: planCode })
          });

          const data = await response.json();

          if (data.error) {
            toast(data.error, 'error');
            btn.disabled = false;
            btn.textContent = '구독하기';
            return;
          }

          if (data.success) {
            toast('구독이 완료되었습니다!', 'success');
            setTimeout(() => {
              window.location.href = '/AI/user/complete.jsp?type=subscribe&plan=' + planCode;
            }, 1000);
          } else {
            toast('구독 처리 중 오류가 발생했습니다', 'error');
            btn.disabled = false;
            btn.textContent = '구독하기';
          }
        } catch (error) {
          console.error('Subscribe error:', error);
          toast('구독 처리 중 오류가 발생했습니다', 'error');
          btn.disabled = false;
          btn.textContent = '구독하기';
        }
      });
    });
  </script>
  <jsp:include page="/AI/partials/footer.jsp"/>
</body>
</html>
