<%@ page contentType="text/html; charset=UTF-8" %>
<%
  // 관리자 인증 확인
  if (session.getAttribute("admin") == null) {
    response.sendRedirect("/AI/admin/auth/login.jsp");
    return;
  }
%>
<%@ include file="/AI/admin/layout/header.jspf" %>
<div class="admin-layout">
  <%@ include file="/AI/admin/layout/sidebar.jspf" %>
  <div class="admin-main-wrapper">
    <%@ include file="/AI/admin/layout/topbar.jspf" %>
    <main class="admin-content">
      <header class="admin-dashboard-header">
        <h1>요금제 생성</h1>
        <a class="btn ghost" href="/AI/admin/pricing/index.jsp">목록으로</a>
      </header>
      <section class="admin-form-section">
        <div style="padding: 2rem; text-align: center; color: var(--text-secondary);">
          <p>요금제 기능은 준비 중입니다.</p>
          <a href="/AI/admin/pricing/index.jsp" class="btn ghost" style="margin-top: 1rem;">목록으로 돌아가기</a>
        </div>
      </section>
<%@ include file="/AI/admin/layout/footer.jspf" %>
