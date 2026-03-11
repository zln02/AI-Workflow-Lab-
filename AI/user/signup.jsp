<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="service.UserService" %>
<%@ page import="model.User" %>
<%@ page import="util.CSRFUtil" %>
<%@ page import="util.EscapeUtil" %>
<%@ page import="java.util.List" %>
<%
  request.setCharacterEncoding("UTF-8");

  String errorMessage = null;
  List<String> errorMessages = null;
  String successMessage = null;

  // POST 요청 처리 (회원가입)
  if ("POST".equals(request.getMethod())) {
    // CSRF 토큰 검증
    if (!CSRFUtil.validateToken(request)) {
      errorMessage = "보안 검증에 실패했습니다. 다시 시도해주세요.";
    } else {
      String email = request.getParameter("email");
      String password = request.getParameter("password");
      String passwordConfirm = request.getParameter("passwordConfirm");
      String name = request.getParameter("name");

      UserService userService = new UserService();

      // 검증
      List<String> errors = userService.validateSignup(email, password, passwordConfirm, name);

      if (!errors.isEmpty()) {
        errorMessages = errors;
      } else {
        // 사용자 생성
        User user = userService.createUser(email, password, name);

        if (user != null) {
          // 세션 재생성 (session fixation 방지) 후 자동 로그인
          session.invalidate();
          javax.servlet.http.HttpSession newSession = request.getSession(true);
          newSession.setAttribute("user", user);
          response.sendRedirect("/AI/user/home.jsp");
          return;
        } else {
          errorMessage = "회원가입 중 오류가 발생했습니다. 다시 시도해주세요.";
        }
      }
    }
  }

  // 이미 로그인한 경우 홈으로 리다이렉트
  User currentUser = (User) session.getAttribute("user");
  if (currentUser != null && currentUser.isActive()) {
    response.sendRedirect("/AI/user/home.jsp");
    return;
  }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>회원가입 - AI Workflow Lab</title>
  <link rel="icon" href="data:,">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
  <link rel="stylesheet" href="/AI/assets/css/dark-theme.css">
  <link rel="stylesheet" href="/AI/assets/css/page.css">
  <style>
    /* ── Auth card ── */
    .auth-wrap { width: 100%; max-width: 440px; }
    .auth-logo__text {
      font-size: 1.125rem; font-weight: 800; letter-spacing: -.02em;
      background: linear-gradient(135deg, #3b82f6, #8b5cf6);
      -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text;
    }

    /* ── Error / success ── */
    .auth-error {
      background: rgba(248,113,113,.1); border: 1px solid rgba(248,113,113,.3);
      border-radius: 10px; padding: 13px 16px; margin-bottom: 20px;
      font-size: .875rem; color: #fca5a5; line-height: 1.55;
    }
    .auth-error ul { margin: 0; padding-left: 18px; }
    .auth-success {
      background: rgba(52,211,153,.1); border: 1px solid rgba(52,211,153,.3);
      border-radius: 10px; padding: 13px 16px; margin-bottom: 20px;
      font-size: .875rem; color: #6ee7b7;
    }
  </style>
</head>
<body class="auth-body">
<%@ include file="/AI/partials/header.jsp" %>

<main>
  <div class="auth-wrap">
    <!-- Logo -->
    <a href="/AI/user/home.jsp" class="auth-logo">
      <i class="bi bi-hexagon-fill" style="font-size:1.4rem;background:linear-gradient(135deg,#3b82f6,#8b5cf6);-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;"></i>
      <span class="auth-logo__text">AI Workflow Lab</span>
    </a>

    <!-- Heading -->
    <div class="auth-heading">
      <h1>계정 만들기</h1>
      <p>AI Workflow Lab에 가입하고 모든 기능을 이용하세요</p>
    </div>

    <!-- Card -->
    <div class="auth-card">
      <!-- Error messages -->
      <% if (errorMessage != null) { %>
      <div id="error-message" class="auth-error">
        <%= EscapeUtil.escapeHtml(errorMessage) %>
      </div>
      <% } %>
      <% if (errorMessages != null && !errorMessages.isEmpty()) { %>
      <div id="error-message" class="auth-error">
        <ul>
          <% for (String err : errorMessages) { %>
          <li><%= EscapeUtil.escapeHtml(err) %></li>
          <% } %>
        </ul>
      </div>
      <% } %>
      <% if (successMessage != null) { %>
      <div class="auth-success">
        <%= EscapeUtil.escapeHtml(successMessage) %>
      </div>
      <% } %>

      <form method="POST" action="/AI/user/signup.jsp" id="signupForm">
        <%= CSRFUtil.getHiddenFieldHtml(request) %>

        <div class="form-field">
          <label for="email">이메일 *</label>
          <input type="email" id="email" name="email" placeholder="example@email.com" required
                 maxlength="255" pattern="[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}"
                 value="<%= request.getParameter("email") != null ? EscapeUtil.escapeHtml(request.getParameter("email")) : "" %>">
        </div>

        <div class="form-field">
          <label for="name">이름 *</label>
          <input type="text" id="name" name="name" placeholder="홍길동" required
                 maxlength="100" minlength="2"
                 value="<%= request.getParameter("name") != null ? EscapeUtil.escapeHtml(request.getParameter("name")) : "" %>">
        </div>

        <div class="form-field">
          <label for="password">비밀번호 *</label>
          <input type="password" id="password" name="password" placeholder="최소 8자 이상" required
                 minlength="8" autocomplete="new-password">
          <small>비밀번호는 최소 8자 이상이어야 합니다.</small>
        </div>

        <div class="form-field">
          <label for="passwordConfirm">비밀번호 확인 *</label>
          <input type="password" id="passwordConfirm" name="passwordConfirm" placeholder="비밀번호를 다시 입력하세요" required
                 minlength="8" autocomplete="new-password">
        </div>

        <button type="submit" class="btn-auth">회원가입</button>
      </form>

      <div class="auth-divider">
        이미 계정이 있으신가요? <a href="/AI/user/login.jsp">로그인</a>
      </div>
    </div><!-- /auth-card -->
  </div><!-- /auth-wrap -->
</main>

<script src="/AI/assets/js/user.js"></script>
<script>
  // 비밀번호 일치 확인
  document.getElementById('signupForm').addEventListener('submit', function(e) {
    const password = document.getElementById('password').value;
    const passwordConfirm = document.getElementById('passwordConfirm').value;

    if (password !== passwordConfirm) {
      e.preventDefault();
      const errorDiv = document.getElementById('error-message');
      if (errorDiv) {
        errorDiv.textContent = '비밀번호가 일치하지 않습니다.';
        errorDiv.style.display = 'block';
      } else {
        alert('비밀번호가 일치하지 않습니다.');
      }
      return false;
    }
  });

  // 실시간 비밀번호 일치 확인
  const passwordInput = document.getElementById('password');
  const passwordConfirmInput = document.getElementById('passwordConfirm');

  function checkPasswordMatch() {
    if (passwordConfirmInput.value && passwordInput.value !== passwordConfirmInput.value) {
      passwordConfirmInput.setCustomValidity('비밀번호가 일치하지 않습니다.');
    } else {
      passwordConfirmInput.setCustomValidity('');
    }
  }

  passwordInput.addEventListener('input', checkPasswordMatch);
  passwordConfirmInput.addEventListener('input', checkPasswordMatch);
</script>
<jsp:include page="/AI/partials/footer.jsp"/>
</body>
</html>
