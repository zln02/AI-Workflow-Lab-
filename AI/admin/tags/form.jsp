<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.TagDAO" %>
<%@ page import="model.Tag" %>
<%
  if (session.getAttribute("admin") == null) {
    response.sendRedirect("/AI/admin/auth/login.jsp");
    return;
  }
  TagDAO tagDAO = new TagDAO();
  Tag tag = null;
  String idParam = request.getParameter("id");
  if (idParam != null && !idParam.trim().isEmpty()) {
    try {
      int id = Integer.parseInt(idParam);
      tag = tagDAO.findById(id);
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
        <h1><%= tag != null ? "태그 수정" : "새 태그 생성" %></h1>
        <a class="btn ghost" href="/AI/admin/tags/index.jsp">목록으로</a>
      </header>
      <section class="admin-form-section">
        <form method="POST" action="/AI/admin/tags/save.jsp" id="tagForm">
          <% if (tag != null) { %><input type="hidden" name="id" value="<%= tag.getId() %>"><% } %>
          <div class="form-group">
            <label for="tag_name">태그명 *</label>
            <input type="text" id="tag_name" name="tag_name" required value="<%= tag != null && tag.getTagName() != null ? tag.getTagName() : "" %>">
          </div>
          <div class="form-actions">
            <button type="submit" class="btn primary">저장</button>
            <a href="/AI/admin/tags/index.jsp" class="btn ghost">취소</a>
          </div>
        </form>
      </section>
<%@ include file="/AI/admin/layout/footer.jspf" %>
