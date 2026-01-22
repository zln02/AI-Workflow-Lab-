<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.OrderDAO" %>
<%@ page import="dao.OrderDAO.SalesStatistics" %>
<%@ page import="dao.OrderDAO.TopSellingItem" %>
<%@ page import="java.util.List" %>
<%@ page import="java.math.BigDecimal" %>
<%
  if (session.getAttribute("admin") == null) {
    response.sendRedirect("/AI/admin/auth/login.jsp");
    return;
  }
  OrderDAO orderDAO = new OrderDAO();
  SalesStatistics stats = orderDAO.getSalesStatistics();
  List<TopSellingItem> topPackages = orderDAO.getTopSellingPackages();
  List<TopSellingItem> topModels = orderDAO.getTopSellingModels();
%>
<%@ include file="/AI/admin/layout/header.jspf" %>
<div class="admin-layout">
  <%@ include file="/AI/admin/layout/sidebar.jspf" %>
  <div class="admin-main-wrapper">
    <%@ include file="/AI/admin/layout/topbar.jspf" %>
    <main class="admin-content">
      <header class="admin-dashboard-header">
        <h1>판매 통계</h1>
        <p>판매량과 인기 상품을 분석합니다.</p>
      </header>

      <section class="admin-grid">
        <article>
          <h2>총 주문 수</h2>
          <p>최근 30일간</p>
          <span class="counter"><%= stats.getTotalOrders() %></span>
        </article>
        <article>
          <h2>총 매출</h2>
          <p>최근 30일간</p>
          <span class="counter"><%= String.format("%,.0f", stats.getTotalRevenue()) %></span>
        </article>
        <article>
          <h2>평균 주문 금액</h2>
          <p>최근 30일간</p>
          <span class="counter"><%= String.format("%,.0f", stats.getAvgOrderValue()) %></span>
        </article>
      </section>

      <section class="admin-table-section" style="margin-top: 2rem;">
        <h2 style="margin-bottom: 1rem;">인기 패키지 TOP 10</h2>
        <table class="admin-table">
          <thead>
            <tr>
              <th>순위</th>
              <th>패키지명</th>
              <th>판매 수량</th>
              <th>주문 건수</th>
              <th>총 매출</th>
            </tr>
          </thead>
          <tbody>
            <% if (topPackages.isEmpty()) { %>
              <tr><td colspan="5" style="text-align: center; padding: 40px;">판매 데이터가 없습니다.</td></tr>
            <% } else { %>
              <% for (int i = 0; i < topPackages.size(); i++) { %>
                <% TopSellingItem item = topPackages.get(i); %>
                <tr>
                  <td><strong><%= i + 1 %></strong></td>
                  <td><%= item.getItemName() %></td>
                  <td><%= item.getTotalQuantity() %>개</td>
                  <td><%= item.getOrderCount() %>건</td>
                  <td><%= String.format("%,.0f", item.getTotalRevenue()) %>원</td>
                </tr>
              <% } %>
            <% } %>
          </tbody>
        </table>
      </section>

      <section class="admin-table-section" style="margin-top: 2rem;">
        <h2 style="margin-bottom: 1rem;">인기 모델 TOP 10</h2>
        <table class="admin-table">
          <thead>
            <tr>
              <th>순위</th>
              <th>모델명</th>
              <th>판매 수량</th>
              <th>주문 건수</th>
            </tr>
          </thead>
          <tbody>
            <% if (topModels.isEmpty()) { %>
              <tr><td colspan="4" style="text-align: center; padding: 40px;">판매 데이터가 없습니다.</td></tr>
            <% } else { %>
              <% for (int i = 0; i < topModels.size(); i++) { %>
                <% TopSellingItem item = topModels.get(i); %>
                <tr>
                  <td><strong><%= i + 1 %></strong></td>
                  <td><%= item.getItemName() %></td>
                  <td><%= item.getTotalQuantity() %>개</td>
                  <td><%= item.getOrderCount() %>건</td>
                </tr>
              <% } %>
            <% } %>
          </tbody>
        </table>
      </section>
<%@ include file="/AI/admin/layout/footer.jspf" %>
