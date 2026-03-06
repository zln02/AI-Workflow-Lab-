<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="service.UserService" %>
<%@ page import="model.User" %>
<%@ page import="util.CSRFUtil" %>
<%@ page import="java.util.List" %>
<%
  request.setCharacterEncoding("UTF-8");
  
  String errorMessage = null;
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
      errorMessage = String.join("<br>", errors);
    } else {
      // 사용자 생성
      User user = userService.createUser(email, password, name);
      
      if (user != null) {
        // 자동 로그인 (세션에 사용자 저장)
        session.setAttribute("user", user);
        response.sendRedirect("/AI/user/home.jsp");
        return;
      } else {
          errorMessage = "회원가입 중 오류가 발생했습니다. 다시 시도해주세요.";
        }
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
  <title>회원가입- AI Workflow Lab</title>
  <link rel="stylesheet" href="/AI/assets/css/user.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" />
</head>
<body>
  <%@ include file="/AI/partials/header.jsp" %>

  <main style="width: min(980px, 100%); margin: 0 auto; padding: 80px 22px;">
    <section class="user-hero" style="text-align: center; margin-bottom: 60px;">
      <h1>회원가입</h1>
      <p style="color: var(--text-secondary); margin-top: 12px;">AI Workflow Lab에 가입하고 모든 기능을 이용하세요.</p>
    </section>

    <section style="max-width: 500px; margin: 0 auto;">
      <div class="glass-card" style="padding: 48px;">
        <% if (errorMessage != null) { %>
          <div id="error-message" class="error-message" style="background: #ff3b30; color: #ffffff; padding: 16px; border-radius: 12px; margin-bottom: 24px; font-size: 14px; line-height: 1.42859;">
            <%= escapeHtml(errorMessage) %>
          </div>
        <% } %>
        
        <% if (successMessage != null) { %>
          <div class="success-message" style="background: #34c759; color: #ffffff; padding: 16px; border-radius: 12px; margin-bottom: 24px; font-size: 14px; line-height: 1.42859;">
            <%= escapeHtml(successMessage) %>
          </div>
        <% } %>

        <form method="POST" action="/AI/user/signup.jsp" id="signupForm">
          <%= CSRFUtil.getHiddenFieldHtml(request) %>
          <div class="form-group">
            <label for="email">이메일 *</label>
            <input type="email" id="email" name="email" placeholder="example@email.com" required 
                   maxlength="255" pattern="[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}"
                   value="<%= request.getParameter("email") != null ? escapeHtml(request.getParameter("email")) : "" %>">
          </div>

          <div class="form-group">
            <label for="name">이름 *</label>
            <input type="text" id="name" name="name" placeholder="홍길동" required 
                   maxlength="100" minlength="2"
                   value="<%= request.getParameter("name") != null ? escapeHtml(request.getParameter("name")) : "" %>">
          </div>

          <div class="form-group">
            <label for="password">비밀번호 *</label>
            <input type="password" id="password" name="password" placeholder="최소 8자 이상" required 
                   minlength="8" autocomplete="new-password">
            <small style="color: var(--text-secondary); font-size: 12px; margin-top: 4px; display: block;">
              비밀번호는 최소 8자 이상이어야 합니다.
            </small>
          </div>

          <div class="form-group">
            <label for="passwordConfirm">비밀번호 확인 *</label>
            <input type="password" id="passwordConfirm" name="passwordConfirm" placeholder="비밀번호를 다시 입력하세요" required 
                   minlength="8" autocomplete="new-password">
          </div>

          <button type="submit" class="btn primary" style="width: 100%; margin-top: 8px;">회원가입</button>
        </form>

        <div style="text-align: center; margin-top: 24px; padding-top: 24px; border-top: 0.5px solid var(--border);">
          <p style="color: var(--text-secondary); font-size: 14px; line-height: 1.42859;">
            이미 계정이 있으신가요? 
            <a href="/AI/user/login.jsp" style="color: var(--accent); text-decoration: none;">로그인</a>
          </p>
        </div>
      </div>
    </section>
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



