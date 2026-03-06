<%-- 로그인 페이지 --%>
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="service.UserService" %>
<%@ page import="dao.UserDAO" %>
<%@ page import="model.User" %>
<%@ page import="util.CSRFUtil" %>
<%@ include file="/AI/user/_common.jsp" %>
<%
  request.setCharacterEncoding("UTF-8");
  
  String errorMessage = null;
  String redirectUrl = request.getParameter("redirect");
  
  // POST 요청 처리 (로그인)
  if ("POST".equals(request.getMethod())) {
    // CSRF 토큰 검증
    if (!CSRFUtil.validateToken(request)) {
      errorMessage = "보안 검증에 실패했습니다. 다시 시도해주세요.";
    } else {
      String email = request.getParameter("email");
      String password = request.getParameter("password");
    
    if (email != null && password != null && !email.trim().isEmpty() && !password.isEmpty()) {
      UserService userService = new UserService();
      UserDAO userDAO = new UserDAO();
      
      // 먼저 이메일 존재 여부 확인
      User userByEmail = userDAO.findByEmail(email.trim().toLowerCase());
      
      if (userByEmail == null) {
        // 등록된 이메일이 없는 경우
        errorMessage = "등록된 정보가 없습니다. 회원가입 해주세요.";
      } else {
        // 이메일이 존재하는 경우 로그인 검증
        User user = userService.authenticate(email, password);
        
        if (user != null) {
          // 세션 재생성 (session fixation 방지)
          session.invalidate();
          HttpSession newSession = request.getSession(true);
          newSession.setAttribute("user", user);
          
          // 리다이렉트 URL이 있으면 해당 페이지로, 없으면 홈으로
          if (redirectUrl != null && !redirectUrl.isEmpty()) {
            response.sendRedirect(redirectUrl);
          } else {
            response.sendRedirect("/AI/user/home.jsp");
          }
          return;
        } else {
          // 이메일은 존재하지만 비밀번호가 틀린 경우
          errorMessage = "비밀번호가 올바르지 않습니다.";
        }
      }
    } else {
        errorMessage = "이메일과 비밀번호를 입력해주세요.";
      }
    }
    }
  }
  
  // 이미 로그인한 경우 홈으로 리다이렉트
  User currentUser = (User) session.getAttribute("user");
  if (currentUser != null && currentUser.isActive()) {
    if (redirectUrl != null && !redirectUrl.isEmpty()) {
      response.sendRedirect(redirectUrl);
    } else {
      response.sendRedirect("/AI/user/home.jsp");
    }
    return;
  }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>로그인- AI Workflow Lab</title>
  <link rel="stylesheet" href="/AI/assets/css/user.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" />
</head>
<body>
  <%@ include file="/AI/partials/header.jsp" %>

  <main style="width: min(980px, 100%); margin: 0 auto; padding: 80px 22px;">
    <section class="user-hero" style="text-align: center; margin-bottom: 60px;">
      <h1>로그인</h1>
      <p style="color: var(--text-secondary); margin-top: 12px;">AI Workflow Lab에 로그인하세요.</p>
    </section>

    <section style="max-width: 500px; margin: 0 auto;">
      <div class="glass-card" style="padding: 48px;">
        <% if (errorMessage != null) { %>
          <div id="error-message" class="error-message" style="background: #ff3b30; color: #ffffff; padding: 16px; border-radius: 12px; margin-bottom: 24px; font-size: 14px; line-height: 1.42859;">
            <%= escapeHtml(errorMessage) %>
            <% if (errorMessage.contains("등록된 정보가 없습니다")) { %>
              <div style="margin-top: 12px;">
                <a href="/AI/user/signup.jsp" style="color: #ffffff; text-decoration: underline; font-weight: 500;">회원가입하러 가기</a>
              </div>
            <% } %>
          </div>
        <% } %>

        <form method="POST" action="/AI/user/login.jsp<%= redirectUrl != null ? "?redirect=" + java.net.URLEncoder.encode(redirectUrl, "UTF-8") : "" %>" id="loginForm">
          <%= CSRFUtil.getHiddenFieldHtml(request) %>
          <div class="form-group">
            <label for="email">이메일</label>
            <input type="email" id="email" name="email" placeholder="example@email.com" required 
                   maxlength="255" autocomplete="email"
                   value="<%= request.getParameter("email") != null ? escapeHtml(request.getParameter("email")) : "" %>">
          </div>

          <div class="form-group">
            <label for="password">비밀번호</label>
            <input type="password" id="password" name="password" placeholder="비밀번호를 입력하세요" required 
                   autocomplete="current-password">
          </div>

          <button type="submit" class="btn primary" style="width: 100%; margin-top: 8px;">로그인</button>
        </form>

        <div style="text-align: center; margin-top: 24px; padding-top: 24px; border-top: 0.5px solid var(--border);">
          <p style="color: var(--text-secondary); font-size: 14px; line-height: 1.42859;">
            계정이 없으신가요? 
            <a href="/AI/user/signup.jsp" style="color: var(--accent); text-decoration: none;">회원가입</a>
          </p>
        </div>
      </div>
    </section>
  </main>

  <script src="/AI/assets/js/user.js"></script>
  <jsp:include page="/AI/partials/footer.jsp"/>
</body>
</html>



