<%@ page contentType="text/html; charset=UTF-8" %>
<%
  // Simple static page for package detail
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>패키지 상세- AI Workflow Lab</title>
  <link rel="stylesheet" href="/AI/assets/css/user.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" />
</head>
<body>
  <%@ include file="/AI/partials/header.jsp" %>

  <main style="width: min(980px, 100%); margin: 0 auto; padding: 80px 22px;">
    <section class="user-hero">
      <h1>패키지 상세</h1>
      <p>패키지 상세 정보는 현재 준비 중입니다.</p>
    </section>

    <section style="text-align: center; margin-bottom: 80px;">
      <div class="glass-card" style="padding: 48px; max-width: 600px; margin: 0 auto;">
        <i class="bi bi-box-seam" style="font-size: 48px; color: var(--accent); margin-bottom: 16px;"></i>
        <h3 style="margin-bottom: 12px;">패키지 상세 기능 준비 중</h3>
        <p style="color: var(--text-secondary); line-height: 1.6;">
          AI Workflow Lab의 패키지 상세 기능은 현재 준비 중입니다.<br>
          AI 도구 탐색기에서 개별 도구를 먼저 확인해 보세요.
        </p>
        <a href="/AI/user/tools/navigator.jsp" class="btn primary" style="margin-top: 24px;">
          <i class="bi bi-compass me-1"></i>AI 도구 탐색기로 가기
        </a>
      </div>
    </section>
  </main>

  <jsp:include page="/AI/partials/footer.jsp"/>
  <script src="/AI/assets/js/user.js"></script>
</body>
</html>
