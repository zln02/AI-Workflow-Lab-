<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.ProviderDAO" %>
<%@ page import="model.Provider" %>
<%@ page import="java.util.List" %>
<%
  if (session.getAttribute("admin") == null) {
    response.sendRedirect("/AI/admin/auth/login.jsp");
    return;
  }
  ProviderDAO providerDAO = new ProviderDAO();
  List<Provider> providers = providerDAO.findAll();
%>
<%@ include file="/AI/admin/layout/header.jspf" %>
<div class="admin-layout">
  <%@ include file="/AI/admin/layout/sidebar.jspf" %>
  <div class="admin-main-wrapper">
    <%@ include file="/AI/admin/layout/topbar.jspf" %>
    <main class="admin-content">
      <header class="admin-dashboard-header">
        <h1>제공사 관리</h1>
        <p>AI 모델 제공사를 생성하고 관리합니다.</p>
        <a class="btn primary" href="/AI/admin/providers/form.jsp">새 제공사 생성</a>
      </header>
      <section class="admin-table-section">
        <table class="admin-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>제공사명</th>
              <th>웹사이트</th>
              <th>국가</th>
              <th>생성일</th>
              <th>액션</th>
            </tr>
          </thead>
          <tbody>
            <% if (providers.isEmpty()) { %>
              <tr><td colspan="6" style="text-align: center; padding: 40px;">등록된 제공사가 없습니다.</td></tr>
            <% } else { %>
              <% for (Provider provider : providers) { %>
                <tr>
                  <td><%= provider.getId() %></td>
                  <td><strong><%= provider.getProviderName() %></strong></td>
                  <td>
                    <% if (provider.getWebsite() != null && !provider.getWebsite().trim().isEmpty()) { %>
                      <a href="<%= provider.getWebsite() %>" target="_blank"><%= provider.getWebsite() %></a>
                    <% } else { %>-<% } %>
                  </td>
                  <td><%= provider.getCountry() != null ? provider.getCountry() : "-" %></td>
                  <td><%= provider.getCreatedAt() != null ? provider.getCreatedAt().substring(0, 10) : "-" %></td>
                  <td>
                    <a href="/AI/admin/providers/form.jsp?id=<%= provider.getId() %>" class="btn btn-sm">수정</a>
                    <a href="/AI/admin/providers/delete.jsp?id=<%= provider.getId() %>" class="btn btn-sm btn-danger" onclick="return confirm('정말 삭제하시겠습니까?');">삭제</a>
                  </td>
                </tr>
              <% } %>
            <% } %>
          </tbody>
        </table>
      </section>
<%@ include file="/AI/admin/layout/footer.jspf" %>
