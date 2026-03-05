<%@ page contentType="text/html; charset=UTF-8" %>
<%-- Common Header with User Authentication Status --%>
<%@ page import="model.User" %>
<%
  request.setCharacterEncoding("UTF-8");
  User currentUser = (User) session.getAttribute("user");
  boolean isLoggedIn = currentUser != null && currentUser.isActive();
%>
<!-- Bootstrap 5.3.3 -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
<nav class="navbar" id="navbar">
  <div class="navbar-container">
    <a href="/AI/user/home.jsp" class="navbar-logo">
      <i class="bi bi-cpu-fill me-1"></i>AI Workflow Lab
    </a>
    <div class="navbar-menu-wrapper">
      <ul class="navbar-menu" id="navbarMenu">
        <li><a href="/AI/user/tools/navigator.jsp" <%= request.getRequestURI().contains("/tools/") ? "class=\"active\"" : "" %>>
          <i class="bi bi-compass me-1"></i>AI 도구 탐색
        </a></li>
        <li><a href="/AI/user/lab/index.jsp" <%= request.getRequestURI().contains("/lab/") ? "class=\"active\"" : "" %>>
          <i class="bi bi-flask me-1"></i>실습 랩
        </a></li>
        <li><a href="/AI/user/portfolio/index.jsp" <%= request.getRequestURI().contains("/portfolio/") ? "class=\"active\"" : "" %>>
          <i class="bi bi-collection me-1"></i>포트폴리오
        </a></li>
      </ul>
      <ul class="navbar-menu navbar-menu-auth">
        <% if (isLoggedIn) { %>
          <li><a href="/AI/user/mypage.jsp" title="마이페이지">
            <i class="bi bi-person-circle me-1"></i><%= currentUser.getDisplayName() %>
          </a></li>
          <li><a href="/AI/user/logout.jsp">로그아웃</a></li>
        <% } else { %>
          <li><a href="/AI/user/login.jsp">로그인</a></li>
          <li><a href="/AI/user/signup.jsp" class="btn btn-primary btn-sm">시작하기</a></li>
        <% } %>
      </ul>
    </div>
    <button class="navbar-toggle" id="navbarToggle">☰</button>
  </div>
</nav>

