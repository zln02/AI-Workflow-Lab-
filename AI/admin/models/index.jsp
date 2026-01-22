<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.AIModelDAO" %>
<%@ page import="model.AIModel" %>
<%@ page import="java.util.List" %>
<%
  // 관리자 인증 확인
  if (session.getAttribute("admin") == null) {
    response.sendRedirect("/AI/admin/auth/login.jsp");
    return;
  }

  AIModelDAO modelDAO = new AIModelDAO();
  List<AIModel> models = modelDAO.findAll();
%>
<%@ include file="/AI/admin/layout/header.jspf" %>
<div class="admin-layout">
  <%@ include file="/AI/admin/layout/sidebar.jspf" %>
  <div class="admin-main-wrapper">
    <%@ include file="/AI/admin/layout/topbar.jspf" %>
    <main class="admin-content">
      <header class="admin-dashboard-header">
        <h1>AI 모델 관리</h1>
        <p>AI 모델을 생성하고 관리합니다.</p>
        <a class="btn primary" href="/AI/admin/models/form.jsp">새 모델 생성</a>
      </header>

      <section class="admin-table-section">
        <table class="admin-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>모델명</th>
              <th>제공사</th>
              <th>카테고리</th>
              <th>가격</th>
              <th>API 제공</th>
              <th>생성일</th>
              <th>액션</th>
            </tr>
          </thead>
          <tbody>
            <% if (models.isEmpty()) { %>
              <tr>
                <td colspan="8" style="text-align: center; padding: 40px;">
                  등록된 모델이 없습니다.
                </td>
              </tr>
            <% } else { %>
              <% for (AIModel model : models) { %>
                <tr>
                  <td><%= model.getId() %></td>
                  <td><strong><%= model.getModelName() != null ? model.getModelName() : "-" %></strong></td>
                  <td><%= model.getProviderName() != null && !model.getProviderName().isEmpty() ? model.getProviderName() : (model.getProviderId() != null ? "ID: " + model.getProviderId() : "-") %></td>
                  <td><%= model.getCategoryName() != null && !model.getCategoryName().isEmpty() ? model.getCategoryName() : (model.getCategoryId() != null ? "ID: " + model.getCategoryId() : "-") %></td>
                  <td><%= model.getPrice() != null ? model.getPrice() : "-" %></td>
                  <td>
                    <span class="badge <%= model.isApiAvailable() ? "badge-success" : "badge-secondary" %>">
                      <%= model.isApiAvailable() ? "예" : "아니오" %>
                    </span>
                  </td>
                  <td><%= model.getCreatedAt() != null ? model.getCreatedAt().substring(0, 10) : "-" %></td>
                  <td>
                    <a href="/AI/admin/models/form.jsp?id=<%= model.getId() %>" class="btn btn-sm">수정</a>
                    <a href="/AI/admin/models/delete.jsp?id=<%= model.getId() %>" 
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
