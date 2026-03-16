<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.AdminDAO" %>
<%@ page import="model.Admin" %>
<%@ page import="java.util.List" %>
<%@ page import="util.CSRFUtil" %>
<%
  if (session.getAttribute("admin") == null) {
    response.sendRedirect("/AI/admin/auth/login.jsp");
    return;
  }
  String adminRole = (String) session.getAttribute("adminRole");
  boolean isSuperadmin = "SUPER".equals(adminRole) || "superadmin".equals(adminRole);
  if (!isSuperadmin) {
    response.sendRedirect("/AI/admin/statistics/index.jsp");
    return;
  }
  AdminDAO adminDAO = new AdminDAO();
  List<Admin> admins = adminDAO.findAll();
%>
<%@ include file="/AI/admin/layout/header.jspf" %>
<div class="admin-layout">
  <%@ include file="/AI/admin/layout/sidebar.jspf" %>
  <div class="admin-main-wrapper">
    <%@ include file="/AI/admin/layout/topbar.jspf" %>
    <main class="admin-content">
      <header class="admin-dashboard-header">
        <h1>관리자 관리</h1>
        <p>관리자 계정을 생성하고 권한을 설정합니다. (Superadmin 전용)</p>
        <a class="btn primary" href="/AI/admin/admins/form.jsp">새 관리자 생성</a>
      </header>
      <section class="admin-table-section">
        <table class="admin-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>아이디</th>
              <th>이름</th>
              <th>이메일</th>
              <th>권한</th>
              <th>상태</th>
              <th>생성일</th>
              <th>마지막 로그인</th>
              <th>액션</th>
            </tr>
          </thead>
          <tbody>
            <% if (admins.isEmpty()) { %>
              <tr><td colspan="9" style="text-align: center; padding: 40px;">등록된 관리자가 없습니다.</td></tr>
            <% } else { %>
              <% for (Admin admin : admins) { %>
                <tr>
                  <td><%= admin.getId() %></td>
                  <td><strong><%= admin.getUsername() %></strong></td>
                  <td><%= admin.getName() != null ? admin.getName() : "-" %></td>
                  <td><%= admin.getEmail() != null ? admin.getEmail() : "-" %></td>
                  <td><span class="badge badge-info"><%= admin.getRole() != null ? admin.getRole() : "VIEWER" %></span></td>
                  <td><span class="badge <%= "ACTIVE".equals(admin.getStatus()) ? "badge-success" : "badge-secondary" %>"><%= admin.getStatus() != null ? admin.getStatus() : "PENDING" %></span></td>
                  <td><%= admin.getCreatedAt() != null ? admin.getCreatedAt().substring(0, 10) : "-" %></td>
                  <td><%= admin.getLastLogin() != null ? admin.getLastLogin().substring(0, 16) : "로그인 없음" %></td>
                  <td>
                    <a href="/AI/admin/admins/form.jsp?id=<%= admin.getId() %>" class="btn btn-sm">수정</a>
                    <% if (admin.getId() != ((model.Admin) session.getAttribute("admin")).getId()) { %>
                      <form method="POST" action="/AI/admin/admins/delete.jsp" style="display:inline;" onsubmit="return confirm('정말 삭제하시겠습니까?');">
                        <input type="hidden" name="id" value="<%= admin.getId() %>">
                        <%= CSRFUtil.getHiddenFieldHtml(request) %>
                        <button type="submit" class="btn btn-sm btn-danger">삭제</button>
                      </form>
                    <% } %>
                  </td>
                </tr>
              <% } %>
            <% } %>
          </tbody>
        </table>
      </section>
<%@ include file="/AI/admin/layout/footer.jspf" %>
