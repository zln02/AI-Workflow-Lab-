<%@ page contentType="text/html; charset=UTF-8" %>
<%-- 워터마크 (관리자 페이지 제외) --%>
<%
  // 관리자 페이지가 아닌 경우에만 워터마크 표시
  String requestURI = request.getRequestURI();
  boolean isAdminPage = requestURI != null && requestURI.contains("/admin/");
  
  if (!isAdminPage) {
%>
<div class="watermark">
  <div class="watermark-content">
    <p class="watermark-text">해당 웹사이트는 과제용 웹사이트입니다.</p>
    <p class="watermark-text">동신대학교 컴퓨터공학과 박진영</p>
  </div>
</div>
<% } %>


