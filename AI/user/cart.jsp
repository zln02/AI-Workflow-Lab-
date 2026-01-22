<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page isELIgnored="true" %>
<%@ page import="dao.PackageDAO" %>
<%@ page import="dao.AIModelDAO" %>
<%@ page import="model.Package" %>
<%@ page import="model.AIModel" %>
<%@ page import="util.CSRFUtil" %>
<%@ page import="java.util.*" %>
<%@ page import="java.math.BigDecimal" %>
<%
  request.setCharacterEncoding("UTF-8");
  
  String action = request.getParameter("action");
  String type = request.getParameter("type");
  String idParam = request.getParameter("id");
  String indexParam = request.getParameter("index");
  String quantityParam = request.getParameter("quantity");
  
  // CSRF validation for POST actions
  if ("POST".equals(request.getMethod())) {
    String submittedToken = request.getParameter("csrf");
    if (!CSRFUtil.validateToken(session, submittedToken)) {
      response.setStatus(403);
      response.setContentType("text/html; charset=UTF-8");
      out.println("<!DOCTYPE html><html><head><meta charset='UTF-8'><title>오류</title></head><body>");
      out.println("<h1>403 Forbidden</h1><p>CSRF 토큰이 유효하지 않습니다.</p>");
      out.println("<a href='/AI/user/cart.jsp'>장바구니로 돌아가기</a></body></html>");
      return;
    }
  }
  
  // 세션에서 장바구니 가져오기
  @SuppressWarnings("unchecked")
  List<Map<String, Object>> cart = (List<Map<String, Object>>) session.getAttribute("cart");
  if (cart == null) {
    cart = new ArrayList<>();
    session.setAttribute("cart", cart);
  }
  
  // 장바구니 추가 (GET 요청도 허용하되 CSRF는 POST에서만 검증)
  if ("add".equals(action) && type != null && idParam != null) {
    try {
      int id = Integer.parseInt(idParam);
      if (!"PACKAGE".equals(type) && !"MODEL".equals(type)) {
        response.sendRedirect("/AI/user/cart.jsp");
        return;
      }
      
      Map<String, Object> item = new HashMap<>();
      item.put("type", type);
      item.put("id", id);
      item.put("quantity", 1);
      
      // 중복 체크 및 수량 증가
      boolean exists = false;
      for (Map<String, Object> existingItem : cart) {
        if (existingItem.get("type").equals(type) && existingItem.get("id").equals(id)) {
          int qty = (Integer) existingItem.get("quantity");
          existingItem.put("quantity", Math.max(1, qty + 1));
          exists = true;
          break;
        }
      }
      
      if (!exists) {
        cart.add(item);
      }
      
      session.setAttribute("cart", cart);
      response.sendRedirect("/AI/user/cart.jsp");
      return;
    } catch (NumberFormatException e) {
      // 잘못된 ID
    }
  }
  
  // 장바구니 수량 업데이트 (POST only)
  if ("update".equals(action) && indexParam != null && quantityParam != null && "POST".equals(request.getMethod())) {
    try {
      int index = Integer.parseInt(indexParam);
      int quantity = Integer.parseInt(quantityParam);
      if (index >= 0 && index < cart.size() && quantity >= 1) {
        Map<String, Object> item = cart.get(index);
        item.put("quantity", quantity);
        session.setAttribute("cart", cart);
      }
      response.sendRedirect("/AI/user/cart.jsp");
      return;
    } catch (NumberFormatException e) {
      // 잘못된 파라미터
    }
  }
  
  // 장바구니 삭제
  if ("remove".equals(action) && idParam != null) {
    try {
      int index = Integer.parseInt(idParam);
      if (index >= 0 && index < cart.size()) {
        cart.remove(index);
        session.setAttribute("cart", cart);
      }
      response.sendRedirect("/AI/user/cart.jsp");
      return;
    } catch (NumberFormatException e) {
      // 잘못된 인덱스
    }
  }
  
  // 세션에서 사용자 정보 가져오기
  model.User currentUser = (model.User) session.getAttribute("user");
  
  // 구독 상태 확인
  boolean hasActiveSubscription = false;
  if (currentUser != null && currentUser.isActive()) {
    try {
      dao.SubscriptionDAO subscriptionDAO = new dao.SubscriptionDAO();
      model.Subscription subscription = subscriptionDAO.findActiveByUserId(currentUser.getId());
      if (subscription != null && subscription.isActiveNow()) {
        hasActiveSubscription = true;
      }
    } catch (Exception e) {
      // 구독 확인 오류 시 무시
    }
  }
  
  // 장바구니 아이템 로드
  PackageDAO packageDAO = new PackageDAO();
  AIModelDAO modelDAO = new AIModelDAO();
  List<Map<String, Object>> cartItems = new ArrayList<>();
  BigDecimal totalPriceUSD = BigDecimal.ZERO;
  
  for (Map<String, Object> item : cart) {
    Map<String, Object> cartItem = new HashMap<>();
    String itemType = (String) item.get("type");
    int itemId = (Integer) item.get("id");
    int quantity = Math.max(1, (Integer) item.get("quantity"));
    
    if ("PACKAGE".equals(itemType)) {
      Package pkg = packageDAO.findById(itemId);
      if (pkg != null) {
        cartItem.put("type", "PACKAGE");
        cartItem.put("id", pkg.getId());
        cartItem.put("title", pkg.getTitle() != null ? pkg.getTitle() : "패키지");
        BigDecimal originalPrice = pkg.getFinalPrice() != null ? pkg.getFinalPrice() : BigDecimal.ZERO;
        // 활성 구독이 있으면 가격을 0으로 설정
        BigDecimal price = hasActiveSubscription ? BigDecimal.ZERO : originalPrice;
        cartItem.put("originalPrice", originalPrice);
        cartItem.put("price", price);
        cartItem.put("quantity", quantity);
        cartItem.put("itemType", "패키지");
        cartItem.put("hasActiveSubscription", hasActiveSubscription);
        totalPriceUSD = totalPriceUSD.add(price.multiply(new BigDecimal(quantity)));
        cartItems.add(cartItem);
      }
    } else if ("MODEL".equals(itemType)) {
      AIModel model = modelDAO.findById(itemId);
      if (model != null) {
        cartItem.put("type", "MODEL");
        cartItem.put("id", model.getId());
        // 모델명, 제공업체, 카테고리 정보 포함
        String modelTitle = model.getModelName() != null ? model.getModelName() : "모델";
        String providerName = model.getProviderName() != null ? model.getProviderName() : "";
        String categoryName = model.getCategoryName() != null ? model.getCategoryName() : "";
        
        if (!providerName.isEmpty()) {
          modelTitle += " (" + providerName + ")";
        }
        cartItem.put("title", modelTitle);
        cartItem.put("providerName", providerName);
        cartItem.put("categoryName", categoryName);
        cartItem.put("itemType", "모델");
        
        // 모델 가격은 price_usd 우선 사용, 없으면 price_krw를 USD로 변환, 그래도 없으면 price 문자열에서 파싱
        BigDecimal price = BigDecimal.ZERO;
        if (model.getPriceUsd() != null && model.getPriceUsd().compareTo(BigDecimal.ZERO) > 0) {
          price = model.getPriceUsd();
        } else if (model.getPriceKrw() != null && model.getPriceKrw() > 0) {
          // KRW를 USD로 변환 (1 USD = 1350 KRW)
          price = new BigDecimal(model.getPriceKrw()).divide(new BigDecimal(1350), 2, java.math.RoundingMode.HALF_UP);
        } else if (model.getPrice() != null && !model.getPrice().trim().isEmpty()) {
          // price 문자열에서 숫자 추출 시도 (예: "$10.00", "10", "무료" 등)
          String priceStr = model.getPrice().trim();
          // "무료", "Free" 등의 키워드 체크
          if (!priceStr.toLowerCase().contains("무료") && !priceStr.toLowerCase().contains("free")) {
            try {
              // 숫자만 추출 (달러 기호, 쉼표, 원화 기호 제거)
              priceStr = priceStr.replaceAll("[^0-9.]", "");
              if (!priceStr.isEmpty()) {
                BigDecimal parsedPrice = new BigDecimal(priceStr);
                // 만약 1000 이상이면 KRW로 간주하고 USD로 변환
                if (parsedPrice.compareTo(new BigDecimal(1000)) >= 0) {
                  price = parsedPrice.divide(new BigDecimal(1350), 2, java.math.RoundingMode.HALF_UP);
                } else {
                  price = parsedPrice;
                }
              }
            } catch (NumberFormatException e) {
              // 파싱 실패 시 0 유지
              price = BigDecimal.ZERO;
            }
          }
        }
        BigDecimal originalPrice = price;
        // 활성 구독이 있으면 가격을 0으로 설정
        if (hasActiveSubscription) {
          price = BigDecimal.ZERO;
        }
        cartItem.put("originalPrice", originalPrice);
        cartItem.put("price", price);
        String priceDisplayStr = model.getPrice() != null && !model.getPrice().trim().isEmpty() ? model.getPrice() : (originalPrice.compareTo(BigDecimal.ZERO) > 0 ? "$" + String.format("%.2f", originalPrice.doubleValue()) : "무료 / 문의");
        // 활성 구독이 있으면 가격 표시를 무료로 변경
        if (hasActiveSubscription && originalPrice.compareTo(BigDecimal.ZERO) > 0) {
          priceDisplayStr = "무료 <span style='padding: 2px 8px; border-radius: 999px; background: #34c759; color: #ffffff; font-size: 11px; margin-left: 4px;'>구독 적용</span>";
        }
        cartItem.put("priceDisplay", priceDisplayStr);
        cartItem.put("quantity", quantity);
        cartItem.put("hasActiveSubscription", hasActiveSubscription);
        totalPriceUSD = totalPriceUSD.add(price.multiply(new BigDecimal(quantity)));
        cartItems.add(cartItem);
      } else {
        // 모델을 찾을 수 없는 경우에도 기본 정보로 표시
        cartItem.put("type", "MODEL");
        cartItem.put("id", itemId);
        cartItem.put("title", "모델 (ID: " + itemId + ") - 정보 없음");
        cartItem.put("price", BigDecimal.ZERO);
        cartItem.put("priceDisplay", "정보 없음");
        cartItem.put("quantity", quantity);
        cartItem.put("itemType", "모델");
        cartItem.put("providerName", "");
        cartItem.put("categoryName", "");
        cartItems.add(cartItem);
      }
    }
  }
  
  String csrfToken = CSRFUtil.getToken(session);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>장바구니 - AI Navigator</title>
  <link rel="stylesheet" href="/AI/assets/css/user.css">
</head>
<body>
  <jsp:include page="/AI/partials/header.jsp"/>

  <!-- Currency Toggle -->
  <div class="currency-toggle">
    <button type="button" data-currency="USD" aria-label="USD로 전환">USD</button>
    <button type="button" data-currency="KRW" aria-label="KRW로 전환">KRW</button>
  </div>

  <!-- Loading Overlay -->
  <div id="loading-overlay" class="loading-overlay">
    <div class="loading-spinner"></div>
  </div>

  <main class="user-cart">
    <section class="cart-header">
      <h1>장바구니</h1>
      <p>장바구니에 담긴 항목을 확인하세요.</p>
      <a href="/AI/user/package.jsp" class="btn secondary">쇼핑 계속하기</a>
    </section>

    <section class="cart-content">
      <% if (cartItems.isEmpty()) { %>
        <div class="empty-cart glass-card">
          <p>장바구니가 비어있습니다.</p>
          <a href="/AI/user/package.jsp" class="btn primary">패키지 보기</a>
        </div>
      <% } else { %>
        <div class="cart-items">
          <table class="cart-table">
            <thead>
              <tr>
                <th>아이템</th>
                <th>타입</th>
                <th>가격</th>
                <th>수량</th>
                <th>소계</th>
                <th>액션</th>
              </tr>
            </thead>
            <tbody>
              <% for (int i = 0; i < cartItems.size(); i++) { %>
                <% Map<String, Object> cartItem = cartItems.get(i); %>
                <% 
                  String title = (String) cartItem.get("title");
                  BigDecimal price = (BigDecimal) cartItem.get("price");
                  int quantity = (Integer) cartItem.get("quantity");
                  BigDecimal subtotal = price.multiply(new BigDecimal(quantity));
                %>
                <tr>
                  <td>
                    <strong><%= title != null ? title.replace("<", "&lt;").replace(">", "&gt;") : "아이템" %></strong>
                    <% if ("MODEL".equals(cartItem.get("type"))) { %>
                      <% 
                        String providerName = (String) cartItem.get("providerName");
                        String categoryName = (String) cartItem.get("categoryName");
                        if (providerName != null && !providerName.isEmpty()) {
                      %>
                        <br><span class="cart-item-details">
                          제공업체: <%= providerName %>
                        </span>
                      <% } %>
                      <% if (categoryName != null && !categoryName.isEmpty()) { %>
                        <br><span class="cart-item-details">
                          카테고리: <%= categoryName %>
                        </span>
                      <% } %>
                      <br><a href="/AI/user/modelDetail.jsp?id=<%= cartItem.get("id") %>" class="cart-item-link">
                        상세보기 →
                      </a>
                    <% } %>
                  </td>
                  <td>
                    <span class="cart-item-type-badge <%= "PACKAGE".equals(cartItem.get("type")) ? "package" : "model" %>">
                      <%= cartItem.get("itemType") != null ? cartItem.get("itemType") : ("PACKAGE".equals(cartItem.get("type")) ? "패키지" : "모델") %>
                    </span>
                  </td>
                  <td>
                    <span class="price-display" data-price-usd="<%= price.doubleValue() %>">
                      <% 
                        String priceDisplay = (String) cartItem.get("priceDisplay");
                        if (priceDisplay != null && !priceDisplay.isEmpty()) {
                      %>
                        <%= priceDisplay %>
                      <% } else if (price.compareTo(BigDecimal.ZERO) > 0) { %>
                        $<%= String.format("%.2f", price.doubleValue()) %>
                      <% } else { %>
                        무료 / 문의
                      <% } %>
                    </span>
                  </td>
                  <td>
                    <div class="quantity-controls">
                      <button type="button" data-action="decrease" aria-label="수량 감소">-</button>
                      <input type="number" 
                             value="<%= quantity %>" 
                             min="1" 
                             data-index="<%= i %>"
                             readonly
                             class="quantity-input">
                      <button type="button" data-action="increase" aria-label="수량 증가">+</button>
                    </div>
                  </td>
                  <td>
                    <span class="subtotal-display" data-price-usd="<%= subtotal.doubleValue() %>">
                      $<%= String.format("%.2f", subtotal.doubleValue()) %>
                    </span>
                  </td>
                  <td>
                    <form method="POST" action="/AI/user/cart.jsp" style="display: inline;">
                      <input type="hidden" name="csrf" value="<%= csrfToken %>">
                      <input type="hidden" name="action" value="remove">
                      <input type="hidden" name="id" value="<%= i %>">
                      <button type="submit" class="btn btn-sm danger" aria-label="삭제">삭제</button>
                    </form>
                  </td>
                </tr>
              <% } %>
            </tbody>
            <tfoot>
              <tr>
                <td colspan="4" style="text-align: right;"><strong>총계</strong></td>
                <td colspan="2">
                  <strong class="total-display" data-price-usd="<%= totalPriceUSD.doubleValue() %>">
                    $<%= String.format("%.2f", totalPriceUSD.doubleValue()) %>
                  </strong>
                </td>
              </tr>
            </tfoot>
          </table>
        </div>

        <div class="cart-actions">
          <a href="/AI/user/checkout.jsp" class="btn primary large">결제하기</a>
        </div>
      <% } %>
    </section>
  </main>
  
  <script src="/AI/assets/js/user.js"></script>
  <script>
    // Cart quantity update functionality is handled by user.js
    // CSRF token for cart updates
    window.cartCSRFToken = '<%= csrfToken %>';
  </script>
  <jsp:include page="/AI/partials/footer.jsp"/>
</body>
</html>
