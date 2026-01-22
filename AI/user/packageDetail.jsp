<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.PackageDAO" %>
<%@ page import="model.Package" %>
<%@ page import="model.PackageItem" %>
<%@ page import="java.util.List" %>
<%
  String idParam = request.getParameter("id");
  if (idParam == null || idParam.trim().isEmpty()) {
    response.sendRedirect("/AI/user/package.jsp");
    return;
  }

  try {
    int id = Integer.parseInt(idParam);
    PackageDAO packageDAO = new PackageDAO();
    Package pkg = packageDAO.findById(id);
    
    if (pkg == null) {
      response.sendRedirect("/AI/user/package.jsp");
      return;
    }
    
    // 장바구니 추가 처리 (모델과 동일한 방식)
    String action = request.getParameter("action");
    if ("addToCart".equals(action)) {
      @SuppressWarnings("unchecked")
      java.util.List<java.util.Map<String, Object>> cart = (java.util.List<java.util.Map<String, Object>>) session.getAttribute("cart");
      if (cart == null) {
        cart = new java.util.ArrayList<>();
        session.setAttribute("cart", cart);
      }
      
      // 중복 체크
      boolean exists = false;
      for (java.util.Map<String, Object> item : cart) {
        if ("PACKAGE".equals(item.get("type")) && item.get("id").equals(pkg.getId())) {
          int qty = (Integer) item.get("quantity");
          item.put("quantity", qty + 1);
          exists = true;
          break;
        }
      }
      
      if (!exists) {
        java.util.Map<String, Object> item = new java.util.HashMap<>();
        item.put("type", "PACKAGE");
        item.put("id", pkg.getId());
        item.put("quantity", 1);
        cart.add(item);
      }
      
      session.setAttribute("cart", cart);
      response.sendRedirect("/AI/user/cart.jsp");
      return;
    }
    
    // 바로 결제 처리 (모델과 동일한 방식)
    if ("checkout".equals(action)) {
      @SuppressWarnings("unchecked")
      java.util.List<java.util.Map<String, Object>> cart = (java.util.List<java.util.Map<String, Object>>) session.getAttribute("cart");
      if (cart == null) {
        cart = new java.util.ArrayList<>();
      }
      
      // 중복 체크
      boolean exists = false;
      for (java.util.Map<String, Object> item : cart) {
        if ("PACKAGE".equals(item.get("type")) && item.get("id").equals(pkg.getId())) {
          exists = true;
          break;
        }
      }
      
      if (!exists) {
        java.util.Map<String, Object> item = new java.util.HashMap<>();
        item.put("type", "PACKAGE");
        item.put("id", pkg.getId());
        item.put("quantity", 1);
        cart.add(item);
        session.setAttribute("cart", cart);
      }
      
      response.sendRedirect("/AI/user/checkout.jsp");
      return;
    }
    
    List<PackageItem> items = pkg.getItems();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><%= pkg.getTitle() %> - AI Navigator</title>
  <link rel="stylesheet" href="/AI/assets/css/user.css">
</head>
<body>
  <!-- Navbar -->
  <nav class="navbar" id="navbar">
    <div class="navbar-container">
      <a href="/AI/user/home.jsp" class="navbar-logo">AI Navigator</a>
      <ul class="navbar-menu" id="navbarMenu">
        <li><a href="/AI/user/home.jsp">모델</a></li>
        <li><a href="/AI/user/package.jsp" class="active">패키지</a></li>
        <li><a href="/AI/user/pricing.jsp">요금제</a></li>
        <li><a href="/AI/user/home.jsp#contact">문의</a></li>
      </ul>
      <button class="navbar-toggle" id="navbarToggle">☰</button>
    </div>
  </nav>

  <main class="user-package-detail" style="width: min(980px, 100%); margin: 0 auto; padding: 80px 22px;">
    <section class="package-detail-header" style="text-align: center; margin-bottom: 60px;">
      <a href="/AI/user/package.jsp" class="btn secondary" style="margin-bottom: 20px;">← 목록으로</a>
      <h1 style="margin-bottom: 12px;"><%= pkg.getTitle() %></h1>
      <% if (pkg.getDescription() != null) { %>
        <p class="package-description" style="color: var(--text-secondary); font-size: 21px; line-height: 1.381; max-width: 600px; margin: 0 auto;"><%= pkg.getDescription() %></p>
      <% } %>
    </section>

    <section class="package-content">
      <div class="package-info">
        <div class="package-price-section">
          <h2>가격</h2>
          <% if (pkg.getDiscountPrice() != null && pkg.getDiscountPrice().compareTo(java.math.BigDecimal.ZERO) > 0) { %>
            <div class="price-info">
              <span class="original-price"><%= String.format("%,.0f", pkg.getPrice()) %>원</span>
              <span class="discount-price"><%= String.format("%,.0f", pkg.getDiscountPrice()) %>원</span>
              <span class="discount-badge">할인</span>
            </div>
          <% } else { %>
            <div class="price-info">
              <span class="final-price"><%= String.format("%,.0f", pkg.getPrice()) %>원</span>
            </div>
          <% } %>
        </div>

        <div class="package-items">
          <h2>패키지 구성</h2>
          <% if (items == null || items.isEmpty()) { %>
            <p>구성 아이템이 없습니다.</p>
          <% } else { %>
            <ul class="item-list">
              <% for (PackageItem item : items) { %>
                <li class="item-card">
                  <div class="item-info">
                    <h4><%= item.getModel() != null ? item.getModel().getModelName() : "모델 ID: " + item.getModelId() %></h4>
                    <% if (item.getModel() != null && item.getModel().getDescription() != null) { %>
                      <p><%= item.getModel().getDescription() %></p>
                    <% } %>
                    <span class="item-quantity">수량: <%= item.getQuantity() %></span>
                  </div>
                  <% if (item.getModel() != null) { %>
                    <a href="/AI/user/modelDetail.jsp?id=<%= item.getModel().getId() %>" class="btn btn-sm">상세보기</a>
                  <% } %>
                </li>
              <% } %>
            </ul>
          <% } %>
        </div>

        <div class="package-actions">
          <form method="GET" action="/AI/user/packageDetail.jsp" style="display: inline; flex: 1;">
            <input type="hidden" name="id" value="<%= pkg.getId() %>">
            <input type="hidden" name="action" value="addToCart">
            <button type="submit" class="btn primary large" style="width: 100%;">장바구니에 추가</button>
          </form>
          <form method="GET" action="/AI/user/packageDetail.jsp" style="display: inline; flex: 1;">
            <input type="hidden" name="id" value="<%= pkg.getId() %>">
            <input type="hidden" name="action" value="checkout">
            <button type="submit" class="btn large" style="width: 100%;">바로 구매</button>
          </form>
        </div>
      </div>
    </section>
  </main>
  <script src="/AI/assets/js/user.js"></script>
  <style>
    .user-package-detail {
      max-width: 1200px;
      margin: 0 auto;
      padding: 40px 20px;
    }
    .package-detail-header {
      margin-bottom: 40px;
    }
    .package-content {
      display: grid;
      gap: 30px;
    }
    .package-price-section {
      padding: 30px;
      background: #f8f9fa;
      border-radius: 8px;
      margin-bottom: 30px;
    }
    .price-info {
      margin-top: 15px;
    }
    .original-price {
      text-decoration: line-through;
      color: #999;
      margin-right: 15px;
    }
    .discount-price {
      font-size: 2em;
      font-weight: bold;
      color: #e74c3c;
      margin-right: 10px;
    }
    .discount-badge {
      background: #e74c3c;
      color: white;
      padding: 5px 10px;
      border-radius: 4px;
      font-size: 0.9em;
    }
    .final-price {
      font-size: 2em;
      font-weight: bold;
    }
    .item-list {
      list-style: none;
      padding: 0;
    }
    .item-card {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 20px;
      background: white;
      border: 1px solid #dee2e6;
      border-radius: 8px;
      margin-bottom: 15px;
    }
    .item-quantity {
      color: #666;
      font-size: 0.9em;
    }
    .package-actions {
      display: flex;
      gap: 15px;
      margin-top: 30px;
    }
    .btn.large {
      flex: 1;
      padding: 15px;
      font-size: 1.1em;
    }
  </style>
</body>
</html>
<% 
  } catch (NumberFormatException e) {
    response.sendRedirect("/AI/user/package.jsp");
  }
%>

