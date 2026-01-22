<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.OrderDAO" %>
<%@ page import="dao.PackageDAO" %>
<%@ page import="dao.AIModelDAO" %>
<%@ page import="model.Order" %>
<%@ page import="model.User" %>
<%@ page import="model.Package" %>
<%@ page import="model.AIModel" %>
<%@ page import="util.CSRFUtil" %>
<%@ page import="java.util.*" %>
<%@ page import="java.math.BigDecimal" %>
<%
  request.setCharacterEncoding("UTF-8");
  
  // CSRF validation for POST
  if ("POST".equals(request.getMethod())) {
    String submittedToken = request.getParameter("csrf");
    if (!CSRFUtil.validateToken(session, submittedToken)) {
      response.setStatus(403);
      response.setContentType("text/html; charset=UTF-8");
      out.println("<!DOCTYPE html><html><head><meta charset='UTF-8'><title>오류</title></head><body>");
      out.println("<h1>403 Forbidden</h1><p>CSRF 토큰이 유효하지 않습니다.</p>");
      out.println("<a href='/AI/user/checkout.jsp'>결제 페이지로 돌아가기</a></body></html>");
      return;
    }
  }
  
  // 로그인한 사용자 정보 가져오기
  User user = (User) session.getAttribute("user");
  
  String customer = request.getParameter("customer");
  String email = request.getParameter("email");
  String phone = request.getParameter("phone");
  String payment = request.getParameter("payment");
  
  // 로그인한 사용자의 정보로 자동 채우기
  if (user != null && user.isActive()) {
    if (customer == null || customer.trim().isEmpty()) {
      customer = user.getName();
    }
    if (email == null || email.trim().isEmpty()) {
      email = user.getEmail();
    }
  }
  
  // Server-side validation
  if (customer != null) customer = customer.trim();
  if (email != null) {
    email = email.trim();
    // Basic email validation
    if (!email.matches("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$")) {
      email = null;
    }
  }
  if (phone != null) phone = phone.trim();
  
  // 세션에서 장바구니 가져오기
  @SuppressWarnings("unchecked")
  List<Map<String, Object>> cart = (List<Map<String, Object>>) session.getAttribute("cart");
  
  BigDecimal totalPrice = BigDecimal.ZERO;
  int orderId = -1;
  String actualOrderDate = null;
  
  // 구독 상태 확인
  boolean hasActiveSubscription = false;
  if (user != null && user.isActive()) {
    try {
      dao.SubscriptionDAO subscriptionDAO = new dao.SubscriptionDAO();
      model.Subscription subscription = subscriptionDAO.findActiveByUserId(user.getId());
      if (subscription != null && subscription.isActiveNow()) {
        hasActiveSubscription = true;
      }
    } catch (Exception e) {
      // 구독 확인 오류 시 무시
    }
  }
  
  // 구독 완료인지 확인
  String type = request.getParameter("type");
  boolean isSubscription = "subscribe".equals(type);
  String planCode = request.getParameter("planCode");
  
  // 구독 완료인 경우 구독 정보 조회
  if (isSubscription && user != null && planCode != null) {
    try {
      dao.SubscriptionDAO subscriptionDAO = new dao.SubscriptionDAO();
      java.util.List<model.Subscription> subscriptions = subscriptionDAO.findAllByUserId(user.getId());
      if (!subscriptions.isEmpty()) {
        // 최신 구독 정보 찾기 (planCode 일치)
        for (model.Subscription sub : subscriptions) {
          if (planCode.equals(sub.getPlanCode())) {
            actualOrderDate = sub.getCreatedAt() != null ? sub.getCreatedAt() : null;
            break;
          }
        }
        // planCode 일치하는 게 없으면 최신 구독 사용
        if (actualOrderDate == null && !subscriptions.isEmpty()) {
          actualOrderDate = subscriptions.get(0).getCreatedAt() != null ? subscriptions.get(0).getCreatedAt() : null;
        }
      }
    } catch (Exception e) {
      e.printStackTrace();
    }
  }
  
  // 결제 완료 후 주문 정보 DB에 저장
  if (cart != null && customer != null && email != null && payment != null) {
    try {
      OrderDAO orderDAO = new OrderDAO();
      PackageDAO packageDAO = new PackageDAO();
      AIModelDAO modelDAO = new AIModelDAO();
      
      // 총 금액 계산 (구독 상태에 따라 가격 조정)
      for (Map<String, Object> item : cart) {
        String itemType = (String) item.get("type");
        int itemId = (Integer) item.get("id");
        int quantity = (Integer) item.get("quantity");
        
        BigDecimal itemPrice = BigDecimal.ZERO;
        if ("PACKAGE".equals(itemType)) {
          model.Package pkg = packageDAO.findById(itemId);
          if (pkg != null) {
            BigDecimal originalPrice = pkg.getFinalPrice() != null ? pkg.getFinalPrice() : BigDecimal.ZERO;
            // 활성 구독이 있으면 가격을 0으로 설정
            itemPrice = hasActiveSubscription ? BigDecimal.ZERO : originalPrice;
          }
        } else if ("MODEL".equals(itemType)) {
          AIModel model = modelDAO.findById(itemId);
          if (model != null) {
            // 모델 가격 계산 (checkout.jsp와 동일한 로직)
            BigDecimal originalPrice = BigDecimal.ZERO;
            if (model.getPriceUsd() != null && model.getPriceUsd().compareTo(BigDecimal.ZERO) > 0) {
              originalPrice = model.getPriceUsd();
            } else if (model.getPriceKrw() != null && model.getPriceKrw() > 0) {
              // KRW를 USD로 변환 (1 USD = 1350 KRW)
              originalPrice = new BigDecimal(model.getPriceKrw()).divide(new BigDecimal("1350"), 2, java.math.RoundingMode.HALF_UP);
            } else if (model.getPrice() != null && !model.getPrice().trim().isEmpty()) {
              // price 문자열에서 파싱
              String rawPrice = model.getPrice().trim();
              if (!rawPrice.equalsIgnoreCase("무료") && !rawPrice.equalsIgnoreCase("free")) {
                String priceStr = rawPrice.replaceAll("[^0-9.]", "");
                if (!priceStr.isEmpty()) {
                  try {
                    BigDecimal parsedPrice = new BigDecimal(priceStr);
                    // 만약 1000 이상이면 KRW로 간주하고 USD로 변환
                    if (parsedPrice.compareTo(new BigDecimal("1000")) >= 0 && !rawPrice.contains("$")) {
                      originalPrice = parsedPrice.divide(new BigDecimal("1350"), 2, java.math.RoundingMode.HALF_UP);
                    } else {
                      originalPrice = parsedPrice;
                    }
                  } catch (NumberFormatException e) {
                    // 파싱 실패 시 0 유지
                  }
                }
              }
            }
            // 활성 구독이 있으면 가격을 0으로 설정, 없으면 원래 가격 저장
            itemPrice = hasActiveSubscription ? BigDecimal.ZERO : originalPrice;
          }
        }
        totalPrice = totalPrice.add(itemPrice.multiply(new BigDecimal(quantity)));
      }
      
      // 주문 생성
      Order order = new Order();
      order.setCustomerName(customer);
      order.setCustomerEmail(email);
      order.setCustomerPhone(phone != null ? phone : "");
      order.setPaymentMethod(payment);
      order.setTotalPrice(totalPrice); // 구독이 적용된 실제 결제 금액
      order.setOrderStatus("COMPLETED");
      
      orderId = orderDAO.insertOrder(order);
      
      // 주문 정보 조회하여 실제 주문일시 가져오기
      if (orderId > 0) {
        try {
          Order savedOrder = orderDAO.findById(orderId);
          if (savedOrder != null && savedOrder.getCreatedAt() != null) {
            actualOrderDate = savedOrder.getCreatedAt();
          }
        } catch (Exception e) {
          e.printStackTrace();
        }
      }
      
      // 주문 아이템 저장
      if (orderId > 0) {
        for (Map<String, Object> item : cart) {
          String itemType = (String) item.get("type");
          int itemId = (Integer) item.get("id");
          int quantity = (Integer) item.get("quantity");
          
          BigDecimal itemPrice = BigDecimal.ZERO;
          if ("PACKAGE".equals(itemType)) {
            model.Package pkg = packageDAO.findById(itemId);
            if (pkg != null) {
              BigDecimal originalPrice = pkg.getFinalPrice() != null ? pkg.getFinalPrice() : BigDecimal.ZERO;
              // 활성 구독이 있으면 가격을 0으로 설정 (실제 결제된 가격 저장)
              itemPrice = hasActiveSubscription ? BigDecimal.ZERO : originalPrice;
            }
          } else if ("MODEL".equals(itemType)) {
            AIModel model = modelDAO.findById(itemId);
            if (model != null) {
              // 모델 가격 계산 (총 금액 계산과 동일한 로직)
              BigDecimal originalPrice = BigDecimal.ZERO;
              if (model.getPriceUsd() != null && model.getPriceUsd().compareTo(BigDecimal.ZERO) > 0) {
                originalPrice = model.getPriceUsd();
              } else if (model.getPriceKrw() != null && model.getPriceKrw() > 0) {
                // KRW를 USD로 변환 (1 USD = 1350 KRW)
                originalPrice = new BigDecimal(model.getPriceKrw()).divide(new BigDecimal("1350"), 2, java.math.RoundingMode.HALF_UP);
              } else if (model.getPrice() != null && !model.getPrice().trim().isEmpty()) {
                // price 문자열에서 파싱
                String rawPrice = model.getPrice().trim();
                if (!rawPrice.equalsIgnoreCase("무료") && !rawPrice.equalsIgnoreCase("free")) {
                  String priceStr = rawPrice.replaceAll("[^0-9.]", "");
                  if (!priceStr.isEmpty()) {
                    try {
                      BigDecimal parsedPrice = new BigDecimal(priceStr);
                      // 만약 1000 이상이면 KRW로 간주하고 USD로 변환
                      if (parsedPrice.compareTo(new BigDecimal("1000")) >= 0 && !rawPrice.contains("$")) {
                        originalPrice = parsedPrice.divide(new BigDecimal("1350"), 2, java.math.RoundingMode.HALF_UP);
                      } else {
                        originalPrice = parsedPrice;
                      }
                    } catch (NumberFormatException e) {
                      // 파싱 실패 시 0 유지
                    }
                  }
                }
              }
              // 활성 구독이 있으면 가격을 0으로 설정, 없으면 원래 가격 저장 (실제 결제된 가격)
              itemPrice = hasActiveSubscription ? BigDecimal.ZERO : originalPrice;
            } else {
              itemPrice = BigDecimal.ZERO;
            }
          }
          
          orderDAO.insertOrderItem(orderId, itemType, itemId, quantity, itemPrice);
        }
      }
      
      // 장바구니 비우기
      session.removeAttribute("cart");
    } catch (Exception e) {
      e.printStackTrace();
      // 오류가 발생해도 완료 페이지는 표시
    }
  }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>결제 완료 - AI Navigator</title>
  <link rel="stylesheet" href="/AI/assets/css/user.css">
</head>
<body>
  <!-- Navbar -->
  <nav class="navbar" id="navbar">
    <div class="navbar-container">
      <a href="/AI/user/home.jsp" class="navbar-logo">AI Navigator</a>
      <ul class="navbar-menu" id="navbarMenu">
        <li><a href="/AI/user/home.jsp">모델</a></li>
        <li><a href="/AI/user/package.jsp">패키지</a></li>
        <li><a href="/AI/user/pricing.jsp">요금제</a></li>
        <li><a href="/AI/user/home.jsp#contact">문의</a></li>
      </ul>
      <button class="navbar-toggle" id="navbarToggle">☰</button>
    </div>
  </nav>

  <!-- Currency Toggle -->
  <div class="currency-toggle">
    <button type="button" data-currency="USD" aria-label="USD로 전환">USD</button>
    <button type="button" data-currency="KRW" aria-label="KRW로 전환">KRW</button>
  </div>

  <main class="user-complete">
    <section class="complete-content" style="text-align: center;">
      <div class="complete-icon">✓</div>
      <h1 style="margin-top: 20px; margin-bottom: 8px;">결제가 완료되었습니다!</h1>
      <% if (customer != null) { %>
        <p class="complete-message">
          <strong><%= customer %></strong>님, 주문이 성공적으로 처리되었습니다.
        </p>
        <% if (email != null) { %>
          <p class="complete-detail">
            주문 확인 이메일이 <strong><%= email %></strong>로 발송되었습니다.
          </p>
        <% } %>
      <% } else { %>
        <p class="complete-message">
          결제가 성공적으로 기록되었습니다.
        </p>
      <% } %>
      
      <div class="complete-info" style="margin-top: 40px; padding: 40px; background: var(--surface); border-radius: 18px; max-width: 500px; margin-left: auto; margin-right: auto;">
        <h2 style="margin-bottom: 20px;">주문 정보</h2>
        <% if (orderId > 0) { %>
          <p style="margin-bottom: 12px; font-size: 17px; line-height: 1.47059;"><strong>주문번호:</strong> #<%= orderId %></p>
        <% } %>
        <% if (customer != null) { %>
          <p style="margin-bottom: 12px; font-size: 17px; line-height: 1.47059;"><strong>주문자:</strong> <%= customer %></p>
        <% } %>
        <% if (email != null) { %>
          <p style="margin-bottom: 12px; font-size: 17px; line-height: 1.47059;"><strong>이메일:</strong> <%= email %></p>
        <% } %>
        <% if (phone != null && !phone.trim().isEmpty()) { %>
          <p style="margin-bottom: 12px; font-size: 17px; line-height: 1.47059;"><strong>전화번호:</strong> <%= phone %></p>
        <% } %>
        <% if (payment != null) { %>
          <p style="margin-bottom: 12px; font-size: 17px; line-height: 1.47059;"><strong>결제 방법:</strong> 
            <%= "card".equals(payment) ? "카드" : 
                "bank".equals(payment) ? "은행 이체" : 
                "virtual".equals(payment) ? "가상계좌" : payment %>
          </p>
        <% } %>
        <% if (isSubscription) { %>
          <p style="margin-bottom: 12px; font-size: 21px; line-height: 1.381; font-weight: 600; color: #34c759;">
            <strong>구독 완료</strong> 
            <span class="tag" style="padding: 2px 8px; border-radius: 999px; background: var(--bg-contrast); font-size: 12px; color: #34c759; margin-left: 8px;">구독 적용</span>
          </p>
        <% } else if (totalPrice.compareTo(BigDecimal.ZERO) > 0) { %>
          <p style="margin-bottom: 12px; font-size: 21px; line-height: 1.381; font-weight: 600; color: var(--accent);">
            <strong>결제금액:</strong> 
            <span class="price-display" data-price-usd="<%= totalPrice.doubleValue() %>">
              $<%= String.format("%.2f", totalPrice.doubleValue()) %>
            </span>
          </p>
        <% } else { %>
          <p style="margin-bottom: 12px; font-size: 21px; line-height: 1.381; font-weight: 600; color: #34c759;">
            <strong>결제금액:</strong> $0.00 
            <span class="tag" style="padding: 2px 8px; border-radius: 999px; background: var(--bg-contrast); font-size: 12px; color: #34c759; margin-left: 8px;">구독 적용</span>
          </p>
        <% } %>
        <p style="margin-bottom: 0; font-size: 17px; line-height: 1.47059;"><strong>주문일시:</strong> 
          <% 
            if (actualOrderDate != null && !actualOrderDate.trim().isEmpty()) {
              // DB에서 가져온 실제 주문일시 표시
              try {
                // String을 Date로 파싱하여 포맷팅
                java.text.SimpleDateFormat dbFormat = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                java.util.Date date = dbFormat.parse(actualOrderDate);
                java.text.SimpleDateFormat displayFormat = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                out.print(displayFormat.format(date));
              } catch (Exception e) {
                // 파싱 실패 시 원본 문자열 표시 (처음 19자만 - 날짜 시간 부분만)
                out.print(actualOrderDate.length() > 19 ? actualOrderDate.substring(0, 19) : actualOrderDate);
              }
            } else {
              // DB에 저장되지 않았거나 조회 실패한 경우 현재 시간 표시
              out.print(new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new java.util.Date()));
            }
          %>
        </p>
      </div>
      
      <div class="complete-actions" style="margin-top: 40px;">
        <a class="btn primary" href="/AI/user/home.jsp">홈으로</a>
        <a class="btn" href="/AI/user/package.jsp">패키지 더 보기</a>
        <a class="btn ghost" href="/AI/admin/auth/login.jsp">관리자 데모</a>
      </div>
    </section>
  </main>
  <script src="/AI/assets/js/user.js"></script>
  <style>
    .user-complete {
      max-width: 800px;
      margin: 0 auto;
      padding: 60px 20px;
      text-align: center;
    }
    .complete-icon {
      width: 80px;
      height: 80px;
      background: #28a745;
      color: white;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 3em;
      margin: 0 auto 30px;
    }
    .complete-message {
      font-size: 1.2em;
      margin: 20px 0;
    }
    .complete-detail {
      color: #666;
      margin-bottom: 30px;
    }
    .complete-info {
      background: #f8f9fa;
      padding: 30px;
      border-radius: 8px;
      margin: 40px 0;
      text-align: left;
    }
    .complete-info h2 {
      margin-bottom: 20px;
      text-align: center;
    }
    .complete-info p {
      margin: 10px 0;
    }
    .complete-actions {
      display: flex;
      gap: 15px;
      justify-content: center;
      margin-top: 40px;
    }
  </style>
  <jsp:include page="/AI/partials/footer.jsp"/>
</body>
</html>
