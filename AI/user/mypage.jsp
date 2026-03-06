<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="model.User" %>
<%@ page import="model.Subscription" %>
<%@ page import="model.Plan" %>
<%@ page import="model.Order" %>
<%@ page import="dao.SubscriptionDAO" %>
<%@ page import="dao.PlanDAO" %>
<%@ page import="dao.OrderDAO" %>
<%@ page import="dao.PackageDAO" %>
<%@ page import="dao.AIModelDAO" %>
<%@ page import="service.UserService" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.math.BigDecimal" %>
<%
  request.setCharacterEncoding("UTF-8");
  response.setCharacterEncoding("UTF-8");
  
  // 로그인 확인
  User user = (User) session.getAttribute("user");
  if (user == null || !user.isActive()) {
    response.sendRedirect("/AI/user/login.jsp?redirect=" + 
                         java.net.URLEncoder.encode(request.getRequestURI(), "UTF-8"));
    return;
  }
  
  // 구독 정보 조회
  SubscriptionDAO subscriptionDAO = new SubscriptionDAO();
  Subscription subscription = subscriptionDAO.findActiveByUserId(user.getId());
  Plan plan = null;
  if (subscription != null) {
    PlanDAO planDAO = new PlanDAO();
    plan = planDAO.findByCode(subscription.getPlanCode());
  }
  
  // 주문 내역 조회
  OrderDAO orderDAO = new OrderDAO();
  List<Order> orders = new java.util.ArrayList<>();
  List<Map<String, Object>> ordersWithItems = new java.util.ArrayList<>();
  if (user.getEmail() != null && !user.getEmail().trim().isEmpty()) {
    try {
      orders = orderDAO.findByEmail(user.getEmail());
      PackageDAO packageDAO = new PackageDAO();
      AIModelDAO modelDAO = new AIModelDAO();
      
      for (Order order : orders) {
        Map<String, Object> orderMap = new HashMap<>();
        orderMap.put("id", order.getId());
        orderMap.put("customerName", order.getCustomerName());
        orderMap.put("customerEmail", order.getCustomerEmail());
        orderMap.put("paymentMethod", order.getPaymentMethod());
        orderMap.put("totalPrice", order.getTotalPrice());
        orderMap.put("orderStatus", order.getOrderStatus());
        // createdAt이 String이므로 그대로 전달
        String createdAtStr = order.getCreatedAt();
        orderMap.put("createdAt", createdAtStr);
        
        // 주문 아이템 조회
        List<Map<String, Object>> orderItems = new java.util.ArrayList<>();
        try {
          orderItems = orderDAO.findOrderItems(order.getId());
        } catch (Exception e) {
          e.printStackTrace();
          // 오류가 발생해도 빈 리스트로 계속 진행
        }
        List<Map<String, Object>> itemsWithDetails = new java.util.ArrayList<>();
        
        for (Map<String, Object> item : orderItems) {
          Map<String, Object> itemDetail = new HashMap<>();
          String itemType = (String) item.get("itemType");
          if (itemType != null) {
            int itemId = ((Number) item.get("itemId")).intValue();
            int quantity = item.get("quantity") != null ? ((Number) item.get("quantity")).intValue() : 1;
            BigDecimal priceObj = (BigDecimal) item.get("price");
            if (priceObj == null) {
              priceObj = BigDecimal.ZERO;
            }
            
            itemDetail.put("itemType", itemType);
            itemDetail.put("itemId", itemId);
            itemDetail.put("quantity", quantity);
            itemDetail.put("price", priceObj);
            
            String itemName = "";
            try {
              if ("PACKAGE".equals(itemType)) {
                model.Package pkg = packageDAO.findById(itemId);
                itemName = pkg != null && pkg.getTitle() != null ? pkg.getTitle() : "패키지 #" + itemId;
              } else if ("MODEL".equals(itemType)) {
                model.AIModel modelObj = modelDAO.findById(itemId);
                if (modelObj != null) {
                  itemName = modelObj.getModelName() != null ? modelObj.getModelName() : "모델 #" + itemId;
                  // 모델 가격이 없으면 모델에서 가격 가져오기
                  if (priceObj == null || priceObj.compareTo(BigDecimal.ZERO) == 0) {
                    try {
                      if (modelObj.getPriceUsd() != null && modelObj.getPriceUsd().compareTo(BigDecimal.ZERO) > 0) {
                        priceObj = modelObj.getPriceUsd();
                        itemDetail.put("price", priceObj);
                      }
                    } catch (Exception e) {
                      // 가격 가져오기 실패 시 무시
                    }
                  }
                } else {
                  itemName = "모델 #" + itemId;
                }
              } else {
                itemName = "아이템 #" + itemId;
              }
            } catch (Exception e) {
              System.err.println("Error loading item name for itemId " + itemId + ": " + e.getMessage());
              itemName = "아이템 #" + itemId;
            }
            itemDetail.put("itemName", itemName);
            itemsWithDetails.add(itemDetail);
          }
        }
        
        orderMap.put("items", itemsWithDetails);
        ordersWithItems.add(orderMap);
      }
    } catch (Exception e) {
      e.printStackTrace();
    }
  }
  
  // 비밀번호 변경 처리
  String passwordError = null;
  String passwordSuccess = null;
  if ("POST".equals(request.getMethod()) && "changePassword".equals(request.getParameter("action"))) {
    String currentPassword = request.getParameter("currentPassword");
    String newPassword = request.getParameter("newPassword");
    String newPasswordConfirm = request.getParameter("newPasswordConfirm");
    
    UserService userService = new UserService();
    List<String> errors = userService.changePassword(user.getId(), currentPassword, newPassword, newPasswordConfirm);
    
    if (errors.isEmpty()) {
      passwordSuccess = "비밀번호가 성공적으로 변경되었습니다.";
    } else {
      passwordError = String.join("<br>", errors);
    }
  }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>마이페이지- AI Workflow Lab</title>
  <link rel="stylesheet" href="/AI/assets/css/user.css">
</head>
<body>
  <jsp:include page="/AI/partials/header.jsp"/>

  <!-- Currency Toggle -->
  <div class="currency-toggle">
    <button type="button" data-currency="USD" aria-label="USD로 전환">USD</button>
    <button type="button" data-currency="KRW" aria-label="KRW로 전환">KRW</button>
  </div>

  <main style="width: min(980px, 100%); margin: 0 auto; padding: 80px 22px;">
    <section class="user-hero" style="text-align: center; margin-bottom: 60px;">
      <h1>마이페이지</h1>
      <p style="color: var(--text-secondary); margin-top: 12px;">계정 정보를 확인하고 관리하세요.</p>
    </section>

    <!-- 구독 정보 섹션 -->
    <% if (subscription != null && plan != null) { %>
      <section style="max-width: 600px; margin: 0 auto 40px;">
        <div class="glass-card" style="padding: 48px;">
          <h2 style="margin-bottom: 32px; font-size: 32px; line-height: 1.125;">구독 정보</h2>
          
          <div class="form-group">
            <label>구독 플랜</label>
            <div style="padding: 12px 16px; background: var(--surface); border-radius: 12px; color: var(--text); font-weight: 600;">
              <%= plan.getName() != null ? plan.getName() : subscription.getPlanCode() %>
            </div>
          </div>

          <div class="form-group">
            <label>구독 기간</label>
            <div style="padding: 12px 16px; background: var(--surface); border-radius: 12px; color: var(--text);">
              <%= subscription.getStartDate() != null ? subscription.getStartDate().format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd")) : "" %> ~ 
              <%= subscription.getEndDate() != null ? subscription.getEndDate().format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd")) : "" %>
            </div>
          </div>

          <div class="form-group">
            <label>남은 기간</label>
            <div style="padding: 12px 16px; background: var(--surface); border-radius: 12px; color: var(--text);">
              <% 
                long daysRemaining = subscription.getDaysRemaining();
                if (daysRemaining > 0) {
              %>
                <span style="color: #34c759; font-weight: 600;"><%= daysRemaining %>일 남음</span>
              <% } else { %>
                <span style="color: #ff3b30;">만료됨</span>
              <% } %>
            </div>
          </div>

          <div class="form-group">
            <label>구독 상태</label>
            <div style="padding: 12px 16px; background: var(--surface); border-radius: 12px;">
              <% if (subscription.isActiveNow()) { %>
                <span style="padding: 4px 12px; background: #34c759; color: #ffffff; border-radius: 999px; font-size: 12px; font-weight: 600;">
                  활성
                </span>
              <% } else { %>
                <span style="padding: 4px 12px; background: #ff3b30; color: #ffffff; border-radius: 999px; font-size: 12px; font-weight: 600;">
                  만료
                </span>
              <% } %>
            </div>
          </div>
        </div>
      </section>
    <% } else { %>
      <section style="max-width: 600px; margin: 0 auto 40px;">
        <div class="glass-card" style="padding: 48px; text-align: center;">
          <h2 style="margin-bottom: 16px; font-size: 24px; line-height: 1.16667;">구독 정보 없음</h2>
          <p style="color: var(--text-secondary); margin-bottom: 24px;">현재 활성화된 구독이 없습니다.</p>
          <a href="/AI/user/pricing.jsp" class="btn primary">구독하기</a>
        </div>
      </section>
    <% } %>

    <!-- 결제 내역 섹션 -->
    <section style="max-width: 600px; margin: 0 auto 40px;">
      <div class="glass-card" style="padding: 48px;">
        <h2 style="margin-bottom: 32px; font-size: 32px; line-height: 1.125;">결제 내역</h2>
        
        <% if (ordersWithItems.isEmpty()) { %>
          <div style="text-align: center; padding: 40px; color: var(--text-secondary);">
            <p>결제 내역이 없습니다.</p>
          </div>
        <% } else { %>
          <% for (Map<String, Object> order : ordersWithItems) { %>
            <div style="border-bottom: 1px solid var(--glass-border); padding-bottom: 24px; margin-bottom: 24px;">
              <div style="display: flex; justify-content: space-between; align-items: start; margin-bottom: 16px;">
                <div>
                  <h3 style="margin: 0 0 8px 0; font-size: 18px; font-weight: 600; color: var(--text);">
                    주문 #<%= order.get("id") %>
                  </h3>
                  <% 
                    // 주문 아이템 목록 가져오기
                    @SuppressWarnings("unchecked")
                    List<Map<String, Object>> orderItems = (List<Map<String, Object>>) order.get("items");
                    if (orderItems != null && !orderItems.isEmpty()) {
                  %>
                    <p style="margin: 0 0 4px 0; color: var(--text-primary); font-size: 14px; font-weight: 500;">
                      <% 
                        java.util.List<String> itemNames = new java.util.ArrayList<>();
                        for (Map<String, Object> item : orderItems) {
                          String itemName = item.get("itemName") != null ? (String) item.get("itemName") : "";
                          if (!itemName.isEmpty()) {
                            itemNames.add(itemName);
                          }
                        }
                        if (!itemNames.isEmpty()) {
                          // HTML 이스케이프 처리
                          for (int i = 0; i < itemNames.size(); i++) {
                            if (i > 0) out.print(", ");
                            String name = itemNames.get(i);
                            out.print(name.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;"));
                          }
                        }
                      %>
                    </p>
                  <% } %>
                  <p style="margin: 0; color: var(--text-secondary); font-size: 14px;">
                    <% 
                      String createdAtStr = (String) order.get("createdAt");
                      if (createdAtStr != null && !createdAtStr.trim().isEmpty()) {
                        // String을 파싱하여 포맷팅
                        try {
                          java.text.SimpleDateFormat dbFormat = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                          java.util.Date date = dbFormat.parse(createdAtStr);
                          java.text.SimpleDateFormat displayFormat = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                          out.print(displayFormat.format(date));
                        } catch (Exception e) {
                          // 파싱 실패 시 원본 문자열 표시
                          out.print(createdAtStr.substring(0, Math.min(createdAtStr.length(), 19)));
                        }
                      } else {
                        out.print("-");
                      }
                    %>
                  </p>
                </div>
                <div style="text-align: right;">
                  <p style="margin: 0; font-size: 20px; font-weight: 600; color: var(--accent);">
                    <% 
                      BigDecimal totalPrice = (BigDecimal) order.get("totalPrice");
                      if (totalPrice != null) {
                        long priceKrw = Math.round(totalPrice.doubleValue() * 1350);
                    %>
                    <span class="price-display" data-price-usd="<%= totalPrice.doubleValue() %>">
                      <%= String.format("%,d", priceKrw) %>원
                    </span>
                    <% } else { %>
                      $0.00
                    <% } %>
                  </p>
                  <p style="margin: 4px 0 0 0; font-size: 12px; color: var(--text-secondary);">
                    <%= "card".equals(order.get("paymentMethod")) ? "카드" : 
                        "bank".equals(order.get("paymentMethod")) ? "은행 이체" : 
                        "virtual".equals(order.get("paymentMethod")) ? "가상계좌" : 
                        order.get("paymentMethod") != null ? order.get("paymentMethod") : "-" %>
                  </p>
                </div>
              </div>
              
              <div style="margin-top: 16px;">
                <% 
                  @SuppressWarnings("unchecked")
                  List<Map<String, Object>> items = (List<Map<String, Object>>) order.get("items");
                  if (items != null && !items.isEmpty()) {
                %>
                  <% for (Map<String, Object> item : items) { 
                    String itemType = (String) item.get("itemType");
                    String itemName = item.get("itemName") != null ? (String) item.get("itemName") : "";
                    if (itemName == null || itemName.isEmpty()) {
                      // itemName이 없으면 기본값 설정
                      int itemId = item.get("itemId") != null ? ((Number) item.get("itemId")).intValue() : 0;
                      if ("PACKAGE".equals(itemType)) {
                        itemName = "패키지 #" + itemId;
                      } else if ("MODEL".equals(itemType)) {
                        itemName = "모델 #" + itemId;
                      } else {
                        itemName = "아이템 #" + itemId;
                      }
                    }
                    BigDecimal itemPrice = (BigDecimal) item.get("price");
                    if (itemPrice == null) {
                      itemPrice = BigDecimal.ZERO;
                    }
                    int quantity = item.get("quantity") != null ? ((Number) item.get("quantity")).intValue() : 1;
                  %>
                    <div style="display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid var(--surface);">
                      <div>
                        <span style="padding: 2px 8px; background: var(--surface); border-radius: 4px; font-size: 11px; margin-right: 8px;">
                          <%= "PACKAGE".equals(itemType) ? "패키지" : "모델" %>
                        </span>
                        <span style="color: var(--text);"><%= itemName != null && !itemName.isEmpty() ? itemName : "-" %></span>
                        <span style="color: var(--text-secondary); font-size: 13px; margin-left: 8px;">
                          x<%= quantity %>
                        </span>
                      </div>
                      <div style="color: var(--text); font-weight: 500;">
                        <% 
                          if (itemPrice != null && itemPrice.compareTo(BigDecimal.ZERO) > 0) {
                            long itemPriceKrw = Math.round(itemPrice.doubleValue() * 1350);
                        %>
                        <span class="price-display" data-price-usd="<%= itemPrice.doubleValue() %>">
                          <%= String.format("%,d", itemPriceKrw) %>원
                        </span>
                        <% } else { %>
                          <span style="color: var(--text-secondary);">무료</span>
                        <% } %>
                      </div>
                    </div>
                  <% } %>
                <% } else { %>
                  <p style="color: var(--text-secondary); text-align: center; padding: 20px; font-size: 14px;">
                    주문 아이템 정보가 없습니다.
                  </p>
                <% } %>
              </div>
            </div>
          <% } %>
        <% } %>
      </div>
    </section>

    <!-- 계정 정보 섹션 -->
    <section style="max-width: 600px; margin: 0 auto 40px;">
      <div class="glass-card" style="padding: 48px;">
        <h2 style="margin-bottom: 32px; font-size: 32px; line-height: 1.125;">계정 정보</h2>
        
        <div class="form-group">
          <label>이메일</label>
          <div style="padding: 12px 16px; background: var(--surface); border-radius: 12px; color: var(--text);">
            <%= user.getEmail() != null ? user.getEmail() : "" %>
          </div>
        </div>

        <div class="form-group">
          <label>이름</label>
          <div style="padding: 12px 16px; background: var(--surface); border-radius: 12px; color: var(--text);">
            <%= user.getName() != null ? user.getName() : "" %>
          </div>
        </div>

        <div class="form-group">
          <label>계정 상태</label>
          <div style="padding: 12px 16px; background: var(--surface); border-radius: 12px; color: var(--text);">
            <span style="padding: 4px 12px; background: #34c759; color: #ffffff; border-radius: 999px; font-size: 12px;">
              <%= user.getStatus() != null && user.getStatus().equals("ACTIVE") ? "활성" : "비활성" %>
            </span>
          </div>
        </div>

        <% if (user.getCreatedAt() != null) { %>
          <div class="form-group">
            <label>가입일</label>
            <div style="padding: 12px 16px; background: var(--surface); border-radius: 12px; color: var(--text-secondary); font-size: 14px;">
              <%= new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(user.getCreatedAt()) %>
            </div>
          </div>
        <% } %>

        <% if (user.getLastLogin() != null) { %>
          <div class="form-group">
            <label>마지막 로그인</label>
            <div style="padding: 12px 16px; background: var(--surface); border-radius: 12px; color: var(--text-secondary); font-size: 14px;">
              <%= new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(user.getLastLogin()) %>
            </div>
          </div>
        <% } %>
      </div>
    </section>

    <!-- 비밀번호 변경 섹션 -->
    <section style="max-width: 600px; margin: 0 auto;">
      <div class="glass-card" style="padding: 48px;">
        <h2 style="margin-bottom: 32px; font-size: 32px; line-height: 1.125;">비밀번호 변경</h2>
        
        <% if (passwordError != null) { %>
          <div id="password-error" class="error-message" style="background: #ff3b30; color: #ffffff; padding: 16px; border-radius: 12px; margin-bottom: 24px; font-size: 14px; line-height: 1.42859;">
            <%= passwordError %>
          </div>
        <% } %>
        
        <% if (passwordSuccess != null) { %>
          <div class="success-message" style="background: #34c759; color: #ffffff; padding: 16px; border-radius: 12px; margin-bottom: 24px; font-size: 14px; line-height: 1.42859;">
            <%= passwordSuccess %>
          </div>
        <% } %>

        <form method="POST" action="/AI/user/mypage.jsp" id="changePasswordForm">
          <input type="hidden" name="action" value="changePassword">
          
          <div class="form-group">
            <label for="currentPassword">현재 비밀번호 *</label>
            <input type="password" id="currentPassword" name="currentPassword" placeholder="현재 비밀번호를 입력하세요" required 
                   autocomplete="current-password">
          </div>

          <div class="form-group">
            <label for="newPassword">새 비밀번호 *</label>
            <input type="password" id="newPassword" name="newPassword" placeholder="최소 8자 이상" required 
                   minlength="8" autocomplete="new-password">
            <small style="color: var(--text-secondary); font-size: 12px; margin-top: 4px; display: block;">
              비밀번호는 최소 8자 이상이어야 합니다.
            </small>
          </div>

          <div class="form-group">
            <label for="newPasswordConfirm">새 비밀번호 확인 *</label>
            <input type="password" id="newPasswordConfirm" name="newPasswordConfirm" placeholder="새 비밀번호를 다시 입력하세요" required 
                   minlength="8" autocomplete="new-password">
          </div>

          <button type="submit" class="btn primary" style="width: 100%; margin-top: 8px;">비밀번호 변경</button>
        </form>
      </div>
    </section>
  </main>

  <script src="/AI/assets/js/user.js"></script>
  <script>
    // 비밀번호 일치 확인
    document.getElementById('changePasswordForm').addEventListener('submit', function(e) {
      const newPassword = document.getElementById('newPassword').value;
      const newPasswordConfirm = document.getElementById('newPasswordConfirm').value;
      
      if (newPassword !== newPasswordConfirm) {
        e.preventDefault();
        const errorDiv = document.getElementById('password-error');
        if (errorDiv) {
          errorDiv.textContent = '새 비밀번호가 일치하지 않습니다.';
          errorDiv.style.display = 'block';
        } else {
          alert('새 비밀번호가 일치하지 않습니다.');
        }
        return false;
      }
    });

    // 실시간 비밀번호 일치 확인
    const newPasswordInput = document.getElementById('newPassword');
    const newPasswordConfirmInput = document.getElementById('newPasswordConfirm');
    
    function checkPasswordMatch() {
      if (newPasswordConfirmInput.value && newPasswordInput.value !== newPasswordConfirmInput.value) {
        newPasswordConfirmInput.setCustomValidity('비밀번호가 일치하지 않습니다.');
      } else {
        newPasswordConfirmInput.setCustomValidity('');
      }
    }
    
    newPasswordInput.addEventListener('input', checkPasswordMatch);
    newPasswordConfirmInput.addEventListener('input', checkPasswordMatch);
  </script>
  <jsp:include page="/AI/partials/footer.jsp"/>
</body>
</html>
