<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.PackageDAO" %>
<%@ page import="dao.AIModelDAO" %>
<%@ page import="model.Package" %>
<%@ page import="model.AIModel" %>
<%@ page import="util.CSRFUtil" %>
<%@ page import="java.util.*" %>
<%@ page import="java.math.BigDecimal" %>
<%
  request.setCharacterEncoding("UTF-8");
  
  // 세션에서 장바구니 가져오기
  @SuppressWarnings("unchecked")
  List<Map<String, Object>> cart = (List<Map<String, Object>>) session.getAttribute("cart");
  
  if (cart == null || cart.isEmpty()) {
    response.sendRedirect("/AI/user/cart.jsp");
    return;
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
  
  PackageDAO packageDAO = new PackageDAO();
  AIModelDAO modelDAO = new AIModelDAO();
  List<Map<String, Object>> checkoutItems = new ArrayList<>();
  BigDecimal totalPriceUSD = BigDecimal.ZERO;
  
  // Recalculate total from cart (server-side, don't trust client)
  for (Map<String, Object> item : cart) {
    Map<String, Object> checkoutItem = new HashMap<>();
    String itemType = (String) item.get("type");
    int itemId = (Integer) item.get("id");
    int quantity = Math.max(1, (Integer) item.get("quantity"));
    
    if ("PACKAGE".equals(itemType)) {
      Package pkg = packageDAO.findById(itemId);
      if (pkg != null) {
        checkoutItem.put("type", "PACKAGE");
        checkoutItem.put("id", pkg.getId());
        checkoutItem.put("title", pkg.getTitle() != null ? pkg.getTitle() : "패키지");
        BigDecimal originalPrice = pkg.getFinalPrice() != null ? pkg.getFinalPrice() : BigDecimal.ZERO;
        // 활성 구독이 있으면 가격을 0으로 설정
        BigDecimal price = hasActiveSubscription ? BigDecimal.ZERO : originalPrice;
        checkoutItem.put("originalPrice", originalPrice);
        checkoutItem.put("price", price);
        checkoutItem.put("quantity", quantity);
        checkoutItem.put("hasActiveSubscription", hasActiveSubscription);
        totalPriceUSD = totalPriceUSD.add(price.multiply(new BigDecimal(quantity)));
        checkoutItems.add(checkoutItem);
      }
    } else if ("MODEL".equals(itemType)) {
      AIModel model = modelDAO.findById(itemId);
      if (model != null) {
        checkoutItem.put("type", "MODEL");
        checkoutItem.put("id", model.getId());
        String modelTitle = model.getModelName() != null ? model.getModelName() : "모델";
        if (model.getProviderName() != null) {
          modelTitle += " (" + model.getProviderName() + ")";
        }
        checkoutItem.put("title", modelTitle);
        
        // 모델 가격은 price_usd 우선 사용, 없으면 price_krw를 USD로 변환, 그래도 없으면 price 문자열에서 파싱
        BigDecimal price = BigDecimal.ZERO;
        String priceDisplay = "무료 / 문의";
        
        if (model.getPriceUsd() != null && model.getPriceUsd().compareTo(BigDecimal.ZERO) > 0) {
          price = model.getPriceUsd();
          priceDisplay = "$" + String.format("%.2f", price.doubleValue());
        } else if (model.getPriceKrw() != null && model.getPriceKrw() > 0) {
          // KRW를 USD로 변환 (1 USD = 1350 KRW)
          price = new BigDecimal(model.getPriceKrw()).divide(new BigDecimal("1350"), 2, java.math.RoundingMode.HALF_UP);
          priceDisplay = String.format("%,d원", model.getPriceKrw()) + " ($" + String.format("%.2f", price.doubleValue()) + ")";
        } else if (model.getPrice() != null && !model.getPrice().trim().isEmpty()) {
          String rawPrice = model.getPrice().trim();
          if (rawPrice.equalsIgnoreCase("무료") || rawPrice.equalsIgnoreCase("free")) {
            price = BigDecimal.ZERO;
            priceDisplay = "무료";
          } else {
            String priceStr = rawPrice.replaceAll("[^0-9.]", "");
            if (!priceStr.isEmpty()) {
              try {
                BigDecimal parsedPrice = new BigDecimal(priceStr);
                // 만약 1000 이상이면 KRW로 간주하고 USD로 변환
                if (parsedPrice.compareTo(new BigDecimal("1000")) >= 0 && !rawPrice.contains("$")) {
                  price = parsedPrice.divide(new BigDecimal("1350"), 2, java.math.RoundingMode.HALF_UP);
                  priceDisplay = String.format("%,d원", parsedPrice.longValue()) + " ($" + String.format("%.2f", price.doubleValue()) + ")";
                } else {
                  price = parsedPrice;
                  priceDisplay = "$" + String.format("%.2f", price.doubleValue());
                }
              } catch (NumberFormatException e) {
                // 파싱 실패 시 0 유지
              }
            }
          }
        }
        
        BigDecimal originalPrice = price;
        String originalPriceDisplay = priceDisplay;
        // 활성 구독이 있으면 가격을 0으로 설정
        if (hasActiveSubscription) {
          price = BigDecimal.ZERO;
          if (originalPrice.compareTo(BigDecimal.ZERO) > 0) {
            priceDisplay = "무료 <span style='padding: 2px 8px; border-radius: 999px; background: #34c759; color: #ffffff; font-size: 11px; margin-left: 4px;'>구독 적용</span>";
          }
        }
        checkoutItem.put("originalPrice", originalPrice);
        checkoutItem.put("price", price);
        checkoutItem.put("priceDisplay", priceDisplay);
        checkoutItem.put("quantity", quantity);
        checkoutItem.put("hasActiveSubscription", hasActiveSubscription);
        totalPriceUSD = totalPriceUSD.add(price.multiply(new BigDecimal(quantity)));
        checkoutItems.add(checkoutItem);
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
  <title>결제- AI Workflow Lab</title>
  <link rel="stylesheet" href="/AI/assets/css/user.css">
</head>
<body>
  <!-- Navbar -->
  <nav class="navbar" id="navbar">
    <div class="navbar-container">
      <a href="/AI/user/home.jsp" class="navbar-logo">AI Workflow Lab/a>
      <ul class="navbar-menu" id="navbarMenu">
        <li><a href="/AI/user/home.jsp">모델</a></li>
        <li><a href="/AI/user/package.jsp">패키지</a></li>
        <li><a href="/AI/user/pricing.jsp">요금제</a></li>
        <li><a href="/AI/user/home.jsp#contact">문의</a></li>
        <%
          if (currentUser != null && currentUser.isActive()) {
        %>
          <li><a href="/AI/user/mypage.jsp">마이페이지</a></li>
          <li><a href="/AI/user/logout.jsp">로그아웃</a></li>
        <% } else { %>
          <li><a href="/AI/user/login.jsp">로그인</a></li>
          <li><a href="/AI/user/signup.jsp">회원가입</a></li>
        <% } %>
      </ul>
      <button class="navbar-toggle" id="navbarToggle">☰</button>
    </div>
  </nav>

  <!-- Currency Toggle -->
  <div class="currency-toggle">
    <button type="button" data-currency="USD" aria-label="USD로 전환">USD</button>
    <button type="button" data-currency="KRW" aria-label="KRW로 전환">KRW</button>
  </div>

  <!-- Loading Overlay -->
  <div id="loading-overlay" class="loading-overlay">
    <div class="loading-spinner"></div>
  </div>

  <main class="user-checkout">
    <section class="checkout-header">
      <h1>결제</h1>
      <p>주문 정보를 확인하고 결제를 진행하세요.</p>
    </section>

    <section class="checkout-content">
      <div class="checkout-items glass-card">
        <h2 style="margin-bottom: 24px; text-align: center;">주문 내역</h2>
        <table class="checkout-table">
          <thead>
            <tr>
              <th>아이템</th>
              <th>타입</th>
              <th>가격</th>
              <th>수량</th>
              <th>소계</th>
            </tr>
          </thead>
          <tbody>
            <% for (Map<String, Object> item : checkoutItems) { %>
              <% 
                String title = (String) item.get("title");
                BigDecimal price = (BigDecimal) item.get("price");
                int quantity = (Integer) item.get("quantity");
                BigDecimal subtotal = price.multiply(new BigDecimal(quantity));
              %>
              <tr>
                <td><strong><%= title != null ? title.replace("<", "&lt;").replace(">", "&gt;") : "아이템" %></strong></td>
                <td><%= "PACKAGE".equals(item.get("type")) ? "패키지" : "모델" %></td>
                <td>
                  <span class="price-display" data-price-usd="<%= price.doubleValue() %>">
                    <%= item.get("priceDisplay") != null ? item.get("priceDisplay") : ("$" + String.format("%.2f", price.doubleValue())) %>
                  </span>
                </td>
                <td><%= quantity %></td>
                <td>
                  <span class="subtotal-display" data-price-usd="<%= subtotal.doubleValue() %>">
                    $<%= String.format("%.2f", subtotal.doubleValue()) %>
                  </span>
                </td>
              </tr>
            <% } %>
          </tbody>
          <tfoot>
            <tr>
              <td colspan="4" style="text-align: right;"><strong>총계</strong></td>
              <td>
                <strong class="total-display" data-price-usd="<%= totalPriceUSD.doubleValue() %>">
                  $<%= String.format("%.2f", totalPriceUSD.doubleValue()) %>
                </strong>
              </td>
            </tr>
          </tfoot>
        </table>
      </div>

      <form class="checkout-form glass-card" action="/AI/user/complete.jsp" method="POST" id="checkoutForm">
        <input type="hidden" name="csrf" value="<%= csrfToken %>">
        <h2 style="margin-bottom: 24px; text-align: center;">결제 정보</h2>
        <div class="form-group">
          <label for="customer">이름 *</label>
          <input type="text" id="customer" name="customer" 
                 value="<%= currentUser != null && currentUser.getName() != null ? currentUser.getName().replace("\"", "&quot;") : "" %>"
                 placeholder="홍길동" required 
                 maxlength="100" pattern="[가-힣a-zA-Z\s]+" title="한글 또는 영문만 입력 가능합니다">
        </div>
        <div class="form-group">
          <label for="email">이메일 *</label>
          <input type="email" id="email" name="email" 
                 value="<%= currentUser != null && currentUser.getEmail() != null ? currentUser.getEmail().replace("\"", "&quot;") : "" %>"
                 placeholder="example@company.com" required 
                 maxlength="255" pattern="[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}">
        </div>
        <div class="form-group">
          <label for="payment">결제 방법 *</label>
          <select id="payment" name="payment" required>
            <option value="">선택하세요</option>
            <option value="card">카드</option>
            <option value="bank">은행 이체</option>
            <option value="virtual">가상계좌</option>
          </select>
        </div>
        <div class="checkout-summary">
          <div id="subscription-status" style="margin-bottom: 12px; padding: 12px; background: var(--surface); border-radius: 8px; font-size: 14px; line-height: 1.42859;">
            <strong>구독 상태:</strong> <span id="cover-label">확인 중...</span>
          </div>
          <div class="summary-row" style="font-size: 21px; line-height: 1.381; font-weight: 600;">
            <span>총 결제금액</span>
            <strong class="total-display" id="final-total" data-price-usd="<%= totalPriceUSD.doubleValue() %>" style="color: var(--accent);">
              $<%= String.format("%.2f", totalPriceUSD.doubleValue()) %>
            </strong>
          </div>
        </div>
        <div class="checkout-actions" style="display: flex; gap: 12px; justify-content: center; flex-wrap: wrap;">
          <button type="submit" class="btn primary large">결제 진행</button>
          <a href="/AI/user/cart.jsp" class="btn secondary">장바구니로</a>
        </div>
      </form>
    </section>
  </main>
  
  <script src="/AI/assets/js/user.js"></script>
  <script type="module">
    import { toast } from '/AI/assets/js/toast.js';

    async function refreshCheckoutSummary() {
      try {
        const response = await fetch('/AI/api/cart-summary.jsp');
        const data = await response.json();
        
        const coverLabel = document.getElementById('cover-label');
        const finalTotal = document.getElementById('final-total');
        
        if (coverLabel) {
          coverLabel.textContent = data.coverLabel;
        }
        
        if (finalTotal && data.hasActiveSubscription) {
          finalTotal.innerHTML = '$0.00 <span class="tag" style="padding: 2px 8px; border-radius: 999px; background: var(--bg-contrast); font-size: 12px; color: #34c759; margin-left: 8px;">구독 적용</span>';
          finalTotal.setAttribute('data-price-usd', '0');
        }
      } catch (error) {
        console.error('Checkout summary error:', error);
      }
    }

    refreshCheckoutSummary();
  </script>
  <script>
    // Client-side validation
    document.getElementById('checkoutForm').addEventListener('submit', function(e) {
      const email = document.getElementById('email').value;
      const emailPattern = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
      
      if (!emailPattern.test(email)) {
        e.preventDefault();
        alert('유효한 이메일 주소를 입력해주세요.');
        return false;
      }
      
      // Show loading
      if (window.AINavigator) {
        window.AINavigator.showLoading();
      }
    });
  </script>
  <jsp:include page="/AI/partials/footer.jsp"/>
</body>
</html>
