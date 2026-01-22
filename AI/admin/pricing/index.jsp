<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="dao.PlanDAO" %>
<%@ page import="model.Plan" %>
<%@ page import="java.math.BigDecimal" %>
<%
  // 관리자 인증 확인
  if (session.getAttribute("admin") == null) {
    response.sendRedirect("/AI/admin/auth/login.jsp");
    return;
  }
  
  // 요금제 목록 조회
  PlanDAO planDAO = new PlanDAO();
  List<Plan> plans = planDAO.findAll();
%>
<%@ include file="/AI/admin/layout/header.jspf" %>
<div class="admin-layout">
  <%@ include file="/AI/admin/layout/sidebar.jspf" %>
  <div class="admin-main-wrapper">
    <%@ include file="/AI/admin/layout/topbar.jspf" %>
    <main class="admin-content">
      <header class="admin-dashboard-header">
        <h1>요금제 관리</h1>
        <p>AI 모델 요금제를 생성하고 관리합니다.</p>
        <a class="btn primary" href="/AI/admin/pricing/form.jsp">새 요금제 생성</a>
      </header>

      <section class="admin-table-section">
        <table class="admin-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>코드</th>
              <th>요금제명</th>
              <th>기간</th>
              <th>가격 (USD)</th>
              <th>설명</th>
              <th>액션</th>
            </tr>
          </thead>
          <tbody>
            <% if (plans == null || plans.isEmpty()) { %>
              <tr>
                <td colspan="7" style="text-align: center; padding: 40px;">
                  등록된 요금제가 없습니다.
                </td>
              </tr>
            <% } else { %>
              <% for (Plan plan : plans) { %>
                <tr>
                  <td><%= plan.getId() %></td>
                  <td><strong><%= plan.getCode() != null ? plan.getCode() : "-" %></strong></td>
                  <td><strong><%= plan.getName() != null ? plan.getName() : "-" %></strong></td>
                  <td><%= plan.getDurationMonths() %>개월</td>
                  <td>
                    <% 
                      if (plan.getPriceUsd() != null) {
                        BigDecimal price = plan.getPriceUsd();
                    %>
                      $<%= String.format("%.2f", price.doubleValue()) %>
                    <% } else { %>
                      -
                    <% } %>
                  </td>
                  <td style="max-width: 300px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
                    <%= plan.getDescription() != null ? plan.getDescription() : "-" %>
                  </td>
                  <td>
                    <a href="/AI/admin/pricing/form.jsp?id=<%= plan.getId() %>" class="btn btn-sm">수정</a>
                  </td>
                </tr>
              <% } %>
            <% } %>
          </tbody>
        </table>
      </section>
<%@ include file="/AI/admin/layout/footer.jspf" %>
