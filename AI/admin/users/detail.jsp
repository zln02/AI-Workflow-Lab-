<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.UserDAO" %>
<%@ page import="dao.OrderDAO" %>
<%@ page import="dao.SubscriptionDAO" %>
<%@ page import="dao.PackageDAO" %>
<%@ page import="dao.AIModelDAO" %>
<%@ page import="dao.PlanDAO" %>
<%@ page import="model.User" %>
<%@ page import="model.Order" %>
<%@ page import="model.Subscription" %>
<%@ page import="model.Package" %>
<%@ page import="model.AIModel" %>
<%@ page import="model.Plan" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
  if (session.getAttribute("admin") == null) {
    response.sendRedirect("/AI/admin/auth/login.jsp");
    return;
  }
  
  String idParam = request.getParameter("id");
  User user = null;
  if (idParam != null && !idParam.trim().isEmpty()) {
    try {
      long userId = Long.parseLong(idParam);
      UserDAO userDAO = new UserDAO();
      user = userDAO.findById(userId);
    } catch (NumberFormatException e) {}
  }
  
  if (user == null) {
    response.sendRedirect("/AI/admin/users/index.jsp");
    return;
  }
  
  // 주문 내역 조회
  OrderDAO orderDAO = new OrderDAO();
  List<Order> orders = orderDAO.findByEmail(user.getEmail());
  
  // 구독 내역 조회
  SubscriptionDAO subscriptionDAO = new SubscriptionDAO();
  List<Subscription> subscriptions = subscriptionDAO.findAllByUserId(user.getId());
  
  // 주문 아이템 정보 로드
  PackageDAO packageDAO = new PackageDAO();
  AIModelDAO modelDAO = new AIModelDAO();
  PlanDAO planDAO = new PlanDAO();
%>
<%@ include file="/AI/admin/layout/header.jspf" %>
<div class="admin-layout">
  <%@ include file="/AI/admin/layout/sidebar.jspf" %>
  <div class="admin-main-wrapper">
    <%@ include file="/AI/admin/layout/topbar.jspf" %>
    <main class="admin-content">
      <header class="admin-dashboard-header">
        <h1>고객 상세 정보</h1>
        <p><%= user.getName() != null ? user.getName() : "고객" %>님의 정보 및 구매 내역</p>
        <a class="btn secondary" href="/AI/admin/users/index.jsp">← 목록으로</a>
      </header>
      
      <!-- 고객 정보 -->
      <section class="admin-table-section" style="margin-bottom: 40px;">
        <h2 style="margin-bottom: 24px; font-size: 24px; font-weight: 600;">고객 정보</h2>
        <div class="glass-card" style="padding: 32px;">
          <table style="width: 100%; border-collapse: collapse;">
            <tr>
              <td style="padding: 12px; width: 150px; font-weight: 600; color: var(--text-secondary);">ID</td>
              <td style="padding: 12px;"><%= user.getId() %></td>
            </tr>
            <tr>
              <td style="padding: 12px; font-weight: 600; color: var(--text-secondary);">이름</td>
              <td style="padding: 12px;"><%= user.getName() != null ? user.getName() : "-" %></td>
            </tr>
            <tr>
              <td style="padding: 12px; font-weight: 600; color: var(--text-secondary);">이메일</td>
              <td style="padding: 12px;"><%= user.getEmail() != null ? user.getEmail() : "-" %></td>
            </tr>
            <tr>
              <td style="padding: 12px; font-weight: 600; color: var(--text-secondary);">상태</td>
              <td style="padding: 12px;">
                <span class="badge <%= "ACTIVE".equals(user.getStatus()) ? "badge-success" : "badge-secondary" %>">
                  <%= user.getStatus() != null && user.getStatus().equals("ACTIVE") ? "활성" : "비활성" %>
                </span>
              </td>
            </tr>
            <tr>
              <td style="padding: 12px; font-weight: 600; color: var(--text-secondary);">가입일</td>
              <td style="padding: 12px;">
                <% if (user.getCreatedAt() != null) { %>
                  <%= new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(user.getCreatedAt()) %>
                <% } else { %>
                  -
                <% } %>
              </td>
            </tr>
            <tr>
              <td style="padding: 12px; font-weight: 600; color: var(--text-secondary);">마지막 로그인</td>
              <td style="padding: 12px;">
                <% if (user.getLastLogin() != null) { %>
                  <%= new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(user.getLastLogin()) %>
                <% } else { %>
                  로그인 없음
                <% } %>
              </td>
            </tr>
          </table>
        </div>
      </section>
      
      <!-- 구독 내역 -->
      <section class="admin-table-section" style="margin-bottom: 40px;">
        <h2 style="margin-bottom: 24px; font-size: 24px; font-weight: 600;">구독 내역</h2>
        <% if (subscriptions.isEmpty()) { %>
          <div class="glass-card" style="padding: 40px; text-align: center;">
            <p style="color: var(--text-secondary);">구독 내역이 없습니다.</p>
          </div>
        <% } else { %>
          <table class="admin-table">
            <thead>
              <tr>
                <th>구독 ID</th>
                <th>요금제</th>
                <th>시작일</th>
                <th>종료일</th>
                <th>상태</th>
                <th>결제 방법</th>
              </tr>
            </thead>
            <tbody>
              <% for (Subscription sub : subscriptions) { %>
                <%
                  Plan plan = planDAO.findByCode(sub.getPlanCode());
                %>
                <tr>
                  <td><%= sub.getId() %></td>
                  <td>
                    <% if (plan != null) { %>
                      <strong><%= plan.getName() != null ? plan.getName() : sub.getPlanCode() %></strong>
                      (<%= plan.getDurationMonths() %>개월)
                    <% } else { %>
                      <%= sub.getPlanCode() %>
                    <% } %>
                  </td>
                  <td>
                    <% if (sub.getStartDate() != null) { %>
                      <%= sub.getStartDate().toString() %>
                    <% } else { %>
                      -
                    <% } %>
                  </td>
                  <td>
                    <% if (sub.getEndDate() != null) { %>
                      <%= sub.getEndDate().toString() %>
                    <% } else { %>
                      -
                    <% } %>
                  </td>
                  <td>
                    <span class="badge <%= "ACTIVE".equals(sub.getStatus()) ? "badge-success" : "badge-secondary" %>">
                      <%= sub.getStatus() != null ? sub.getStatus() : "-" %>
                    </span>
                  </td>
                  <td><%= sub.getPaymentMethod() != null ? sub.getPaymentMethod() : "-" %></td>
                </tr>
              <% } %>
            </tbody>
          </table>
        <% } %>
      </section>
      
      <!-- 구매 내역 -->
      <section class="admin-table-section">
        <h2 style="margin-bottom: 24px; font-size: 24px; font-weight: 600;">구매 내역</h2>
        <% if (orders.isEmpty()) { %>
          <div class="glass-card" style="padding: 40px; text-align: center;">
            <p style="color: var(--text-secondary);">구매 내역이 없습니다.</p>
          </div>
        <% } else { %>
          <% for (Order order : orders) { %>
            <div class="glass-card" style="padding: 24px; margin-bottom: 24px;">
              <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
                <div>
                  <h3 style="margin: 0 0 8px 0; font-size: 20px; font-weight: 600;">주문 #<%= order.getId() %></h3>
                  <p style="margin: 0; color: var(--text-secondary); font-size: 14px;">
                    주문일: <%= order.getCreatedAt() != null ? order.getCreatedAt().substring(0, 19) : "-" %> | 
                    결제 방법: <%= order.getPaymentMethod() != null ? order.getPaymentMethod() : "-" %> |
                    상태: <span class="badge badge-success"><%= order.getOrderStatus() != null ? order.getOrderStatus() : "-" %></span>
                  </p>
                </div>
                <div style="text-align: right;">
                  <p style="margin: 0; font-size: 24px; font-weight: 600; color: var(--accent);">
                    $<%= String.format("%.2f", order.getTotalPrice() != null ? order.getTotalPrice().doubleValue() : 0.0) %>
                  </p>
                </div>
              </div>
              
              <table style="width: 100%; border-collapse: collapse; margin-top: 16px;">
                <thead>
                  <tr style="border-bottom: 1px solid var(--border);">
                    <th style="padding: 12px; text-align: left;">타입</th>
                    <th style="padding: 12px; text-align: left;">아이템</th>
                    <th style="padding: 12px; text-align: right;">수량</th>
                    <th style="padding: 12px; text-align: right;">단가</th>
                    <th style="padding: 12px; text-align: right;">소계</th>
                  </tr>
                </thead>
                <tbody>
                  <%
                    List<Map<String, Object>> orderItems = orderDAO.findOrderItems(order.getId());
                    for (Map<String, Object> item : orderItems) {
                      String itemType = (String) item.get("itemType");
                      if (itemType == null) {
                        continue; // itemType이 null이면 건너뛰기
                      }
                      int itemId = ((Number) item.get("itemId")).intValue();
                      int quantity = ((Number) item.get("quantity")).intValue();
                      java.math.BigDecimal priceObj = (java.math.BigDecimal) item.get("price");
                      if (priceObj == null) {
                        priceObj = java.math.BigDecimal.ZERO;
                      }
                      java.math.BigDecimal price = priceObj;
                      java.math.BigDecimal subtotal = price.multiply(new java.math.BigDecimal(quantity));
                      
                      String itemName = "";
                      if ("PACKAGE".equals(itemType)) {
                        Package pkg = packageDAO.findById(itemId);
                        itemName = pkg != null && pkg.getTitle() != null ? pkg.getTitle() : "패키지 #" + itemId;
                      } else if ("MODEL".equals(itemType)) {
                        AIModel model = modelDAO.findById(itemId);
                        itemName = model != null && model.getModelName() != null ? model.getModelName() : "모델 #" + itemId;
                      } else {
                        itemName = "아이템 #" + itemId;
                      }
                  %>
                    <tr style="border-bottom: 1px solid var(--border);">
                      <td style="padding: 12px;">
                        <span class="badge badge-info"><%= "PACKAGE".equals(itemType) ? "패키지" : "모델" %></span>
                      </td>
                      <td style="padding: 12px;"><%= itemName %></td>
                      <td style="padding: 12px; text-align: right;"><%= quantity %></td>
                      <td style="padding: 12px; text-align: right;">$<%= String.format("%.2f", price.doubleValue()) %></td>
                      <td style="padding: 12px; text-align: right; font-weight: 600;">
                        $<%= String.format("%.2f", subtotal.doubleValue()) %>
                      </td>
                    </tr>
                  <% } %>
                </tbody>
                <tfoot>
                  <tr>
                    <td colspan="4" style="padding: 12px; text-align: right; font-weight: 600;">총계</td>
                    <td style="padding: 12px; text-align: right; font-weight: 600; font-size: 18px; color: var(--accent);">
                      $<%= String.format("%.2f", order.getTotalPrice() != null ? order.getTotalPrice().doubleValue() : 0.0) %>
                    </td>
                  </tr>
                </tfoot>
              </table>
            </div>
          <% } %>
        <% } %>
      </section>
<%@ include file="/AI/admin/layout/footer.jspf" %>

