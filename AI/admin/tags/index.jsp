<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.TagDAO" %>
<%@ page import="model.Tag" %>
<%@ page import="java.util.List" %>
<%
  if (session.getAttribute("admin") == null) {
    response.sendRedirect("/AI/admin/auth/login.jsp");
    return;
  }
  TagDAO tagDAO = new TagDAO();
  List<Tag> tags = tagDAO.findAll();
%>
<%@ include file="/AI/admin/layout/header.jspf" %>
<div class="admin-layout">
  <%@ include file="/AI/admin/layout/sidebar.jspf" %>
  <div class="admin-main-wrapper">
    <%@ include file="/AI/admin/layout/topbar.jspf" %>
    <main class="admin-content">
      <header class="admin-dashboard-header">
        <h1>태그 관리</h1>
        <p>AI 모델 태그를 생성하고 관리합니다.</p>
        <a class="btn primary" href="/AI/admin/tags/form.jsp">새 태그 생성</a>
      </header>
      <section class="admin-table-section">
        <table class="admin-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>태그명</th>
              <th>액션</th>
            </tr>
          </thead>
          <tbody>
            <% if (tags.isEmpty()) { %>
              <tr><td colspan="3" style="text-align: center; padding: 40px;">등록된 태그가 없습니다.</td></tr>
            <% } else { %>
              <% for (Tag tag : tags) { %>
                <tr>
                  <td><%= tag.getId() %></td>
                  <td><strong><%= tag.getTagName() %></strong></td>
                  <td>
                    <a href="/AI/admin/tags/form.jsp?id=<%= tag.getId() %>" class="btn btn-sm">수정</a>
                    <a href="/AI/admin/tags/delete.jsp?id=<%= tag.getId() %>" class="btn btn-sm btn-danger" onclick="return confirm('정말 삭제하시겠습니까?');">삭제</a>
                  </td>
                </tr>
              <% } %>
            <% } %>
          </tbody>
        </table>
      </section>
<%@ include file="/AI/admin/layout/footer.jspf" %>
