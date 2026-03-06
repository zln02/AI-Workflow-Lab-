<%@ page contentType="text/html; charset=UTF-8" %>
<%
  // Simple static page for checkout
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>결제- AI Workflow Lab</title>
  <link rel="stylesheet" href="/AI/assets/css/user.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" />
</head>
<body>
  <%@ include file="/AI/partials/header.jsp" %>

  <main style="width: min(980px, 100%); margin: 0 auto; padding: 80px 22px;">
    <section class="user-hero">
      <h1>결제</h1>
      <p>결제 기능은 현재 준비 중입니다.</p>
    </section>

    <section style="text-align: center; margin-bottom: 80px;">
      <div class="glass-card" style="padding: 48px; max-width: 600px; margin: 0 auto;">
        <i class="bi bi-credit-card" style="font-size: 48px; color: var(--accent); margin-bottom: 16px;"></i>
        <h3 style="margin-bottom: 12px;">결제 기능 준비 중</h3>
        <p style="color: var(--text-secondary); line-height: 1.6;">
          AI Workflow Lab의 결제 기능은 현재 준비 중입니다.<br>
          구독 플랜을 먼저 확인해 보세요.
        </p>
        <a href="/AI/user/pricing.jsp" class="btn primary" style="margin-top: 24px;">
          <i class="bi bi-credit-card me-1"></i>구독 플랜 보기
        </a>
      </div>
    </section>
  </main>

  <jsp:include page="/AI/partials/footer.jsp"/>
  <script src="/AI/assets/js/user.js"></script>
</body>
</html>
