<%@ page contentType="text/html; charset=UTF-8" %>
<%
  // 세션 무효화
  if (session != null) {
    session.invalidate();
  }
  // 로그인 페이지로 리다이렉트
  response.sendRedirect("/AI/admin/auth/login.jsp");
%>
