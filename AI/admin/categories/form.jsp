<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.CategoryDAO" %>
<%@ page import="model.Category" %>
<%
  if (session.getAttribute("admin") == null) {
    response.sendRedirect("/AI/admin/auth/login.jsp");
    return;
  }
  CategoryDAO categoryDAO = new CategoryDAO();
  Category category = null;
  String idParam = request.getParameter("id");
  if (idParam != null && !idParam.trim().isEmpty()) {
    try {
      int id = Integer.parseInt(idParam);
      category = categoryDAO.findById(id);
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
        <h1><%= category != null ? "카테고리 수정" : "새 카테고리 생성" %></h1>
        <a class="btn ghost" href="/AI/admin/categories/index.jsp">목록으로</a>
      </header>
      <section class="admin-form-section">
        <form method="POST" action="/AI/admin/categories/save.jsp" id="categoryForm">
          <% if (category != null) { %><input type="hidden" name="id" value="<%= category.getId() %>"><% } %>
          <div class="form-group">
            <label for="category_name">카테고리명 *</label>
            <input type="text" id="category_name" name="category_name" required value="<%= category != null && category.getCategoryName() != null ? category.getCategoryName() : "" %>">
          </div>
          <div class="form-actions">
            <button type="submit" class="btn primary">저장</button>
            <a href="/AI/admin/categories/index.jsp" class="btn ghost">취소</a>
          </div>
        </form>
      </section>
<%@ include file="/AI/admin/layout/footer.jspf" %>
