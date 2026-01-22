<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.CategoryDAO" %>
<%@ page import="model.Category" %>
<%@ page import="java.util.List" %>
<%
  // 관리자 인증 확인
  if (session.getAttribute("admin") == null) {
    response.sendRedirect("/AI/admin/auth/login.jsp");
    return;
  }

  CategoryDAO categoryDAO = new CategoryDAO();
  List<Category> categories = categoryDAO.findAll();
%>
<%@ include file="/AI/admin/layout/header.jspf" %>
<div class="admin-layout">
  <%@ include file="/AI/admin/layout/sidebar.jspf" %>
  <div class="admin-main-wrapper">
    <%@ include file="/AI/admin/layout/topbar.jspf" %>
    <main class="admin-content">
      <header class="admin-dashboard-header">
        <h1>카테고리 관리</h1>
        <p>AI 모델 카테고리를 생성하고 관리합니다.</p>
        <a class="btn primary" href="/AI/admin/categories/form.jsp">새 카테고리 생성</a>
      </header>

      <section class="admin-table-section">
        <table class="admin-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>카테고리명</th>
              <th>액션</th>
            </tr>
          </thead>
          <tbody>
            <% if (categories.isEmpty()) { %>
              <tr>
                <td colspan="3" style="text-align: center; padding: 40px;">
                  등록된 카테고리가 없습니다.
                </td>
              </tr>
            <% } else { %>
              <% for (Category category : categories) { %>
                <tr>
                  <td><%= category.getId() %></td>
                  <td><strong><%= category.getCategoryName() %></strong></td>
                  <td>
                    <a href="/AI/admin/categories/form.jsp?id=<%= category.getId() %>" class="btn btn-sm">수정</a>
                    <a href="/AI/admin/categories/delete.jsp?id=<%= category.getId() %>" 
                       class="btn btn-sm btn-danger" 
                       onclick="return confirm('정말 삭제하시겠습니까?');">삭제</a>
                  </td>
                </tr>
              <% } %>
            <% } %>
          </tbody>
        </table>
      </section>
<%@ include file="/AI/admin/layout/footer.jspf" %>
