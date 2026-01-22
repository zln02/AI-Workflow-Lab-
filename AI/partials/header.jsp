<%@ page contentType="text/html; charset=UTF-8" %>
<%-- Common Header with User Authentication Status --%>
<%@ page import="model.User" %>
<%
  request.setCharacterEncoding("UTF-8");
  User currentUser = (User) session.getAttribute("user");
  boolean isLoggedIn = currentUser != null && currentUser.isActive();
%>
<nav class="navbar" id="navbar">
  <div class="navbar-container">
    <a href="/AI/user/home.jsp" class="navbar-logo">AI Navigator</a>
    <div class="navbar-menu-wrapper">
      <ul class="navbar-menu" id="navbarMenu">
        <li><a href="/AI/user/models.jsp" <%= request.getRequestURI().contains("/models.jsp") ? "class=\"active\"" : "" %>>모델</a></li>
        <li><a href="/AI/user/package.jsp" <%= request.getRequestURI().contains("/package.jsp") ? "class=\"active\"" : "" %>>패키지</a></li>
        <li><a href="/AI/user/pricing.jsp" <%= request.getRequestURI().contains("/pricing.jsp") ? "class=\"active\"" : "" %>>요금제</a></li>
        <li><a href="/AI/user/home.jsp#contact">문의</a></li>
      </ul>
      <ul class="navbar-menu navbar-menu-auth">
        <% if (isLoggedIn) { %>
          <li><a href="/AI/user/cart.jsp" class="cart-icon" title="장바구니">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"></path>
              <line x1="3" y1="6" x2="21" y2="6"></line>
              <path d="M16 10a4 4 0 0 1-8 0"></path>
            </svg>
          </a></li>
          <li><a href="/AI/user/mypage.jsp">마이페이지</a></li>
          <li><a href="/AI/user/logout.jsp">로그아웃</a></li>
        <% } else { %>
          <li><a href="/AI/user/login.jsp">로그인</a></li>
          <li><a href="/AI/user/signup.jsp">회원가입</a></li>
        <% } %>
      </ul>
    </div>
    <button class="navbar-toggle" id="navbarToggle">☰</button>
  </div>
</nav>

