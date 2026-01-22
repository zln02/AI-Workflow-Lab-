<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.ProviderDAO" %>
<%@ page import="model.Provider" %>
<%
  if (session.getAttribute("admin") == null) {
    response.sendRedirect("/AI/admin/auth/login.jsp");
    return;
  }
  ProviderDAO providerDAO = new ProviderDAO();
  Provider provider = null;
  String idParam = request.getParameter("id");
  if (idParam != null && !idParam.trim().isEmpty()) {
    try {
      int id = Integer.parseInt(idParam);
      provider = providerDAO.findById(id);
    } catch (NumberFormatException e) {}
  }
%>
<%@ include file="/AI/admin/layout/header.jspf" %>
<div class="admin-layout">
  <%@ include file="/AI/admin/layout/sidebar.jspf" %>
  <div class="admin-main-wrapper">
    <%@ include file="/AI/admin/layout/topbar.jspf" %>
    <main class="admin-content">
      <header class="admin-dashboard-header">
        <h1><%= provider != null ? "제공사 수정" : "새 제공사 생성" %></h1>
        <a class="btn ghost" href="/AI/admin/providers/index.jsp">목록으로</a>
      </header>
      <section class="admin-form-section">
        <form method="POST" action="/AI/admin/providers/save.jsp" id="providerForm">
          <% if (provider != null) { %><input type="hidden" name="id" value="<%= provider.getId() %>"><% } %>
          <div class="form-group">
            <label for="provider_name">제공사명 *</label>
            <input type="text" id="provider_name" name="provider_name" required value="<%= provider != null && provider.getProviderName() != null ? provider.getProviderName() : "" %>">
          </div>
          <div class="form-group">
            <label for="website">웹사이트</label>
            <input type="url" id="website" name="website" value="<%= provider != null && provider.getWebsite() != null ? provider.getWebsite() : "" %>" placeholder="https://example.com">
          </div>
          <div class="form-group">
            <label for="country">국가</label>
            <input type="text" id="country" name="country" value="<%= provider != null && provider.getCountry() != null ? provider.getCountry() : "" %>" placeholder="예: USA, South Korea">
          </div>
          <div class="form-actions">
            <button type="submit" class="btn primary">저장</button>
            <a href="/AI/admin/providers/index.jsp" class="btn ghost">취소</a>
          </div>
        </form>
      </section>
<%@ include file="/AI/admin/layout/footer.jspf" %>
