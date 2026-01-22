<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="model.User" %>
<%
  // 세션 무효화
  session.invalidate();
  
  // 홈으로 리다이렉트
  response.sendRedirect("/AI/user/home.jsp");
%>



