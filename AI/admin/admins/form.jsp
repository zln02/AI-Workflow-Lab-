<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.AdminDAO" %>
<%@ page import="model.Admin" %>
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
  Admin admin = null;
  String idParam = request.getParameter("id");
  if (idParam != null && !idParam.trim().isEmpty()) {
    try {
      int id = Integer.parseInt(idParam);
      admin = adminDAO.findById(id);
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
        <h1><%= admin != null ? "관리자 수정" : "새 관리자 생성" %></h1>
        <a class="btn ghost" href="/AI/admin/admins/index.jsp">목록으로</a>
      </header>
      <section class="admin-form-section">
        <form method="POST" action="/AI/admin/admins/save.jsp" id="adminForm">
          <% if (admin != null) { %><input type="hidden" name="id" value="<%= admin.getId() %>"><% } %>
          <div class="form-group">
            <label for="username">아이디 *</label>
            <input type="text" id="username" name="username" required value="<%= admin != null && admin.getUsername() != null ? admin.getUsername() : "" %>" <%= admin != null ? "readonly" : "" %>>
            <% if (admin != null) { %><small style="color: var(--text-secondary); font-size: 0.875rem;">아이디는 변경할 수 없습니다.</small><% } %>
          </div>
          <% if (admin == null) { %>
            <div class="form-group">
              <label for="password">비밀번호 *</label>
              <input type="password" id="password" name="password" required>
            </div>
          <% } else { %>
            <div class="form-group">
              <label for="password">비밀번호 변경</label>
              <input type="password" id="password" name="password" placeholder="변경하지 않으려면 비워두세요">
            </div>
          <% } %>
          <div class="form-group">
            <label for="name">이름</label>
            <input type="text" id="name" name="name" value="<%= admin != null && admin.getName() != null ? admin.getName() : "" %>">
          </div>
          <div class="form-group">
            <label for="email">이메일</label>
            <input type="email" id="email" name="email" value="<%= admin != null && admin.getEmail() != null ? admin.getEmail() : "" %>">
          </div>
          <div class="form-group">
            <label for="role">권한 *</label>
            <select id="role" name="role" required>
              <option value="VIEWER" <%= admin != null && "VIEWER".equals(admin.getRole()) ? "selected" : "" %>>VIEWER</option>
              <option value="EDITOR" <%= admin != null && "EDITOR".equals(admin.getRole()) ? "selected" : "" %>>EDITOR</option>
              <option value="MANAGER" <%= admin != null && "MANAGER".equals(admin.getRole()) ? "selected" : "" %>>MANAGER</option>
              <option value="SUPER" <%= admin != null && "SUPER".equals(admin.getRole()) ? "selected" : "" %>>SUPER</option>
            </select>
          </div>
          <div class="form-group">
            <label for="status">상태 *</label>
            <select id="status" name="status" required>
              <option value="PENDING" <%= admin != null && "PENDING".equals(admin.getStatus()) ? "selected" : "" %>>PENDING</option>
              <option value="ACTIVE" <%= admin == null || "ACTIVE".equals(admin.getStatus()) ? "selected" : "" %>>ACTIVE</option>
              <option value="SUSPENDED" <%= admin != null && "SUSPENDED".equals(admin.getStatus()) ? "selected" : "" %>>SUSPENDED</option>
            </select>
          </div>
          <div class="form-actions">
            <button type="submit" class="btn primary">저장</button>
            <a href="/AI/admin/admins/index.jsp" class="btn ghost">취소</a>
          </div>
        </form>
      </section>
<%@ include file="/AI/admin/layout/footer.jspf" %>
