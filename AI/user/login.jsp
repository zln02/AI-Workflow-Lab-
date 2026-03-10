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

  // 소셜 로그인 에러 처리
  String kakaoError  = request.getParameter("kakao_error");
  String googleError = request.getParameter("google_error");
  String naverError  = request.getParameter("naver_error");
  String socialErrorParam = kakaoError != null ? kakaoError : googleError != null ? googleError : naverError;
  String socialProvider = kakaoError != null ? "카카오" : googleError != null ? "구글" : "네이버";
  if (socialErrorParam != null) {
    switch (socialErrorParam) {
      case "not_configured":  errorMessage = socialProvider + " 로그인이 아직 설정되지 않았습니다."; break;
      case "access_denied":   errorMessage = socialProvider + " 로그인을 취소하셨습니다."; break;
      case "token_failed":    errorMessage = socialProvider + " 인증에 실패했습니다. 다시 시도해주세요."; break;
      case "userinfo_failed": errorMessage = socialProvider + " 사용자 정보를 가져올 수 없습니다."; break;
      case "create_failed":   errorMessage = socialProvider + " 계정 연동에 실패했습니다."; break;
      case "account_inactive":errorMessage = "비활성화된 계정입니다. 고객센터로 문의해주세요."; break;
      default:                errorMessage = socialProvider + " 로그인 중 오류가 발생했습니다."; break;
    }
  }

  // Open Redirect 방지: 상대경로만 허용
  String redirectParam = request.getParameter("redirect");
  String redirectUrl = null;
  if (redirectParam != null && !redirectParam.isEmpty()
      && redirectParam.startsWith("/") && !redirectParam.startsWith("//")) {
    redirectUrl = redirectParam;
  }

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
          errorMessage = "등록된 정보가 없습니다. 회원가입 해주세요.";
        } else {
          User user = userService.authenticate(email, password);

          if (user != null) {
            // 세션 재생성 (session fixation 방지)
            session.invalidate();
            HttpSession newSession = request.getSession(true);
            newSession.setAttribute("user", user);

            if (redirectUrl != null && !redirectUrl.isEmpty()) {
              response.sendRedirect(redirectUrl);
            } else {
              response.sendRedirect("/AI/user/home.jsp");
            }
            return;
          } else {
            errorMessage = "비밀번호가 올바르지 않습니다.";
          }
        }
      } else {
        errorMessage = "이메일과 비밀번호를 입력해주세요.";
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
  <title>로그인 - AI Workflow Lab</title>
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
    .auth-error a { color: #fca5a5; font-weight: 600; }

    /* ── 소셜 구분선 ── */
    .social-divider {
      display: flex; align-items: center; gap: 12px;
      margin: 20px 0; color: #6b7280; font-size: .8rem;
    }
    .social-divider::before, .social-divider::after {
      content: ''; flex: 1; height: 1px; background: rgba(255,255,255,.1);
    }

    /* ── 카카오 로그인 버튼 ── */
    .btn-kakao {
      display: flex; align-items: center; justify-content: center; gap: 10px;
      width: 100%; padding: 13px 20px; border-radius: 12px;
      background: #FEE500; color: rgba(0,0,0,.85);
      font-size: .95rem; font-weight: 600; text-decoration: none;
      border: none; cursor: pointer; transition: background .15s;
    }
    .btn-kakao:hover { background: #F5DC00; color: rgba(0,0,0,.85); text-decoration: none; }
    .btn-kakao svg { flex-shrink: 0; }
    .btn-google {
      display: flex; align-items: center; justify-content: center; gap: 10px;
      width: 100%; padding: 12px 20px; border-radius: 12px; margin-top: 10px;
      background: #fff; color: #3c4043;
      font-size: .95rem; font-weight: 600; text-decoration: none;
      border: 1px solid #dadce0; cursor: pointer; transition: background .15s;
    }
    .btn-google:hover { background: #f8f9fa; color: #3c4043; text-decoration: none; }
    .btn-naver {
      display: flex; align-items: center; justify-content: center; gap: 10px;
      width: 100%; padding: 12px 20px; border-radius: 12px; margin-top: 10px;
      background: #03C75A; color: #fff;
      font-size: .95rem; font-weight: 600; text-decoration: none;
      border: none; cursor: pointer; transition: background .15s;
    }
    .btn-naver:hover { background: #02b350; color: #fff; text-decoration: none; }
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
      <h1>다시 오신 걸 환영합니다</h1>
      <p>계정에 로그인하세요</p>
    </div>

    <!-- Card -->
    <div class="auth-card">
      <!-- Error message -->
      <% if (errorMessage != null) { %>
      <div id="error-message" class="auth-error">
        <%= escapeHtml(errorMessage) %>
        <% if (errorMessage.contains("등록된 정보가 없습니다")) { %>
        <div style="margin-top: 10px;">
          <a href="/AI/user/signup.jsp">회원가입하러 가기 →</a>
        </div>
        <% } %>
      </div>
      <% } %>

      <form method="POST" action="/AI/user/login.jsp<%= redirectUrl != null ? "?redirect=" + java.net.URLEncoder.encode(redirectUrl, "UTF-8") : "" %>" id="loginForm">
        <%= CSRFUtil.getHiddenFieldHtml(request) %>

        <div class="form-field">
          <label for="email">이메일</label>
          <input type="email" id="email" name="email" placeholder="example@email.com" required
                 maxlength="255" autocomplete="email"
                 value="<%= request.getParameter("email") != null ? escapeHtml(request.getParameter("email")) : "" %>">
        </div>

        <div class="form-field">
          <label for="password">비밀번호</label>
          <input type="password" id="password" name="password" placeholder="비밀번호를 입력하세요" required
                 autocomplete="current-password">
        </div>

        <button type="submit" class="btn-auth">로그인</button>
      </form>

      <!-- 소셜 로그인 구분선 -->
      <div class="social-divider">또는</div>

      <!-- 카카오 로그인 -->
      <a href="/AI/oauth/kakao<%= redirectUrl != null ? "?redirect=" + java.net.URLEncoder.encode(redirectUrl, "UTF-8") : "" %>"
         class="btn-kakao">
        <svg width="20" height="20" viewBox="0 0 20 20" fill="none" aria-hidden="true">
          <path fill-rule="evenodd" clip-rule="evenodd"
            d="M10 2C5.582 2 2 4.836 2 8.333c0 2.21 1.392 4.155 3.49 5.29l-.888 3.317a.25.25 0 0 0 .372.273L9.06 14.95c.31.03.624.05.94.05 4.418 0 8-2.836 8-6.333S14.418 2 10 2Z"
            fill="rgba(0,0,0,0.85)"/>
        </svg>
        카카오로 로그인
      </a>

      <!-- 구글 로그인 -->
      <a href="/AI/oauth/google<%= redirectUrl != null ? "?redirect=" + java.net.URLEncoder.encode(redirectUrl, "UTF-8") : "" %>"
         class="btn-google">
        <svg width="18" height="18" viewBox="0 0 48 48" aria-hidden="true">
          <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/>
          <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>
          <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/>
          <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>
        </svg>
        구글로 로그인
      </a>

      <!-- 네이버 로그인 -->
      <a href="/AI/oauth/naver<%= redirectUrl != null ? "?redirect=" + java.net.URLEncoder.encode(redirectUrl, "UTF-8") : "" %>"
         class="btn-naver">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="white" aria-hidden="true">
          <path d="M16.273 12.845L7.376 0H0v24h7.727V11.155L16.624 24H24V0h-7.727z"/>
        </svg>
        네이버로 로그인
      </a>

      <div class="auth-divider" style="margin-top:20px;">
        계정이 없으신가요? <a href="/AI/user/signup.jsp">회원가입</a>
      </div>
    </div><!-- /auth-card -->
  </div><!-- /auth-wrap -->
</main>

<script src="/AI/assets/js/user.js"></script>
<jsp:include page="/AI/partials/footer.jsp"/>
</body>
</html>
