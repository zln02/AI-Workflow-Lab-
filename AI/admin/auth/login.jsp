<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>AI Navigator Admin Login</title>
  <link rel="stylesheet" href="/AI/assets/css/admin-login.css">
</head>
<body>
  <div class="login-container">
    <div class="login-box">
      <div class="login-header">
        <div class="login-icon">⚡</div>
        <h1 class="title">Admin Login</h1>
        <p class="subtitle">AI Navigator 관리자 페이지</p>
      </div>

      <form method="post" action="/AI/admin/auth/login" id="loginForm">
        <div class="input-group">
          <input type="text" name="username" id="username" placeholder="아이디" required autocomplete="username">
        </div>

        <div class="input-group">
          <input type="password" name="password" id="password" placeholder="비밀번호" required autocomplete="current-password">
        </div>

        <button type="submit" class="login-btn">
          <span>로그인</span>
        </button>
      </form>
    </div>
  </div>

  <div id="toast-container"></div>

  <script src="/AI/assets/js/admin-login.js"></script>
  <%
    String error = request.getParameter("error");
    if (error != null) {
      String errorMessage = null;
      if ("credentials".equals(error)) {
        errorMessage = "아이디 또는 비밀번호가 올바르지 않습니다.";
      } else if ("validation".equals(error)) {
        errorMessage = "아이디와 비밀번호를 모두 입력해 주세요.";
      } else if ("status".equals(error)) {
        errorMessage = "계정이 활성화되지 않았거나 접근이 차단된 상태입니다.";
      }
      if (errorMessage != null) {
        out.println("<script>");
        out.println("document.addEventListener('DOMContentLoaded', function() {");
        out.println("  showToast('" + errorMessage + "', 'error');");
        out.println("});");
        out.println("</script>");
      }
    }
  %>
</body>
</html>
