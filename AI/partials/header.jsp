<%@ page contentType="text/html; charset=UTF-8" %>
<%-- Common Header with User Authentication Status --%>
<%@ page import="model.User" %>
<%
  request.setCharacterEncoding("UTF-8");
  // 이미 선언된 경우 재선언하지 않도록 session에서 직접 참조
  Object _headerUserObj = session.getAttribute("user");
  User _headerUser = (_headerUserObj instanceof User) ? (User) _headerUserObj : null;
  boolean _headerIsLoggedIn = _headerUser != null && _headerUser.isActive();
%>
<!-- Favicon -->
<link rel="icon" href="data:,">
<!-- Google Fonts -->
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<!-- Bootstrap 5.3.3 -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
<!-- Dark Theme -->
<link href="/AI/assets/css/dark-theme.css" rel="stylesheet">
<nav class="navbar" id="navbar">
  <div class="navbar-container">
    <a href="/AI/user/home.jsp" class="navbar-logo">
      <i class="bi bi-lightning-charge-fill me-1"></i>AI Workflow Lab
    </a>
    <div class="navbar-menu-wrapper">
      <ul class="navbar-menu" id="navbarMenu">
        <li><a href="/AI/user/tools/navigator.jsp" <%= request.getRequestURI().contains("/tools/") ? "class=\"active\"" : "" %>>
          <i class="bi bi-compass me-1"></i>AI 도구 탐색
        </a></li>
        <li><a href="/AI/user/lab/index.jsp" <%= request.getRequestURI().contains("/lab/") ? "class=\"active\"" : "" %>>
          <i class="bi bi-flask me-1"></i>실습 랩
        </a></li>
        <li><a href="/AI/user/mypage.jsp" <%= request.getRequestURI().contains("/mypage") ? "class=\"active\"" : "" %>>
          <i class="bi bi-person-circle me-1"></i>마이페이지
        </a></li>
      </ul>
      <ul class="navbar-menu navbar-menu-auth">
        <% if (_headerIsLoggedIn) { %>
          <li><a href="/AI/user/mypage.jsp" title="마이페이지">
            <i class="bi bi-person-circle me-1"></i><%= _headerUser.getDisplayName() %>
          </a></li>
          <li><a href="/AI/user/logout.jsp">로그아웃</a></li>
        <% } else { %>
          <li><a href="/AI/user/login.jsp">로그인</a></li>
          <li><a href="/AI/user/signup.jsp" class="btn btn-primary btn-sm">시작하기</a></li>
        <% } %>
      </ul>
    </div>
    <button class="navbar-toggle" id="navbarToggle"><i class="bi bi-list"></i></button>
  </div>
</nav>

