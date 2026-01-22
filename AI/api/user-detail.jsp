<%@ page contentType="application/json; charset=UTF-8" %>
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
<%@ page import="java.util.*" %>
<%@ page import="com.google.gson.Gson" %>
<%
  response.setHeader("Access-Control-Allow-Origin", "*");
  response.setHeader("Content-Type", "application/json; charset=UTF-8");
  
  String userIdParam = request.getParameter("userId");
  
  if (userIdParam == null || userIdParam.trim().isEmpty()) {
    response.setStatus(400);
    out.print("{\"error\":\"사용자 ID가 필요합니다.\"}");
    return;
  }
  
  try {
    long userId = Long.parseLong(userIdParam);
    
    UserDAO userDAO = new UserDAO();
    User user = userDAO.findById(userId);
    
    if (user == null) {
      response.setStatus(404);
      out.print("{\"error\":\"사용자를 찾을 수 없습니다.\"}");
      return;
    }
    
    // 주문 내역 조회
    OrderDAO orderDAO = new OrderDAO();
    List<Order> orders = new ArrayList<>();
    if (user.getEmail() != null && !user.getEmail().trim().isEmpty()) {
      try {
        orders = orderDAO.findByEmail(user.getEmail());
      } catch (Exception e) {
        System.err.println("Error loading orders: " + e.getMessage());
        // 오류가 발생해도 빈 리스트로 계속 진행
      }
    }
    
    // 구독 내역 조회
    SubscriptionDAO subscriptionDAO = new SubscriptionDAO();
    List<Subscription> subscriptions = new ArrayList<>();
    try {
      subscriptions = subscriptionDAO.findAllByUserId(user.getId());
    } catch (Exception e) {
      System.err.println("Error loading subscriptions: " + e.getMessage());
      // 오류가 발생해도 빈 리스트로 계속 진행
    }
    
    // 주문 아이템 정보 로드
    PackageDAO packageDAO = new PackageDAO();
    AIModelDAO modelDAO = new AIModelDAO();
    PlanDAO planDAO = new PlanDAO();
    
    // 주문 내역에 아이템 정보 추가
    List<Map<String, Object>> ordersWithItems = new ArrayList<>();
    for (Order order : orders) {
      if (order == null) continue;
      Map<String, Object> orderMap = new HashMap<>();
      orderMap.put("id", order.getId());
      orderMap.put("customerName", order.getCustomerName());
      orderMap.put("customerEmail", order.getCustomerEmail());
      orderMap.put("customerPhone", order.getCustomerPhone());
      orderMap.put("paymentMethod", order.getPaymentMethod());
      orderMap.put("totalPrice", order.getTotalPrice() != null ? order.getTotalPrice().doubleValue() : 0.0);
      orderMap.put("orderStatus", order.getOrderStatus());
      orderMap.put("createdAt", order.getCreatedAt());
      
      // 주문 아이템 조회
      List<Map<String, Object>> orderItems = new ArrayList<>();
      try {
        orderItems = orderDAO.findOrderItems(order.getId());
      } catch (Exception e) {
        System.err.println("Error loading order items for order " + order.getId() + ": " + e.getMessage());
        // 오류가 발생해도 빈 리스트로 계속 진행
      }
      List<Map<String, Object>> itemsWithDetails = new ArrayList<>();
      
      for (Map<String, Object> item : orderItems) {
        Map<String, Object> itemDetail = new HashMap<>();
        String itemType = (String) item.get("itemType");
        if (itemType == null) continue;
        
        try {
          int itemId = ((Number) item.get("itemId")).intValue();
          int quantity = item.get("quantity") != null ? ((Number) item.get("quantity")).intValue() : 1;
          java.math.BigDecimal priceObj = (java.math.BigDecimal) item.get("price");
          if (priceObj == null) {
            priceObj = java.math.BigDecimal.ZERO;
          }
          
          itemDetail.put("itemType", itemType);
          itemDetail.put("itemId", itemId);
          itemDetail.put("quantity", quantity);
          itemDetail.put("price", priceObj.doubleValue());
          
          String itemName = "";
          try {
            if ("PACKAGE".equals(itemType)) {
              Package pkg = packageDAO.findById(itemId);
              itemName = pkg != null && pkg.getTitle() != null ? pkg.getTitle() : "패키지 #" + itemId;
            } else if ("MODEL".equals(itemType)) {
              AIModel model = modelDAO.findById(itemId);
              itemName = model != null && model.getModelName() != null ? model.getModelName() : "모델 #" + itemId;
            } else {
              itemName = "아이템 #" + itemId;
            }
          } catch (Exception e) {
            System.err.println("Error loading item details: " + e.getMessage());
            itemName = "아이템 #" + itemId;
          }
          itemDetail.put("itemName", itemName);
          itemsWithDetails.add(itemDetail);
        } catch (Exception e) {
          System.err.println("Error processing order item: " + e.getMessage());
          // 오류가 발생한 아이템은 건너뛰기
        }
      }
      
      orderMap.put("items", itemsWithDetails);
      ordersWithItems.add(orderMap);
    }
    
    // 구독 내역에 플랜 정보 추가
    List<Map<String, Object>> subscriptionsWithPlans = new ArrayList<>();
    for (Subscription sub : subscriptions) {
      if (sub == null) continue;
      Map<String, Object> subMap = new HashMap<>();
      subMap.put("id", sub.getId());
      subMap.put("userId", sub.getUserId());
      subMap.put("planCode", sub.getPlanCode());
      subMap.put("startDate", sub.getStartDate() != null ? sub.getStartDate().toString() : null);
      subMap.put("endDate", sub.getEndDate() != null ? sub.getEndDate().toString() : null);
      subMap.put("status", sub.getStatus());
      subMap.put("paymentMethod", sub.getPaymentMethod());
      subMap.put("transactionId", sub.getTransactionId());
      subMap.put("createdAt", sub.getCreatedAt());
      
      if (sub.getPlanCode() != null && !sub.getPlanCode().trim().isEmpty()) {
        try {
          Plan plan = planDAO.findByCode(sub.getPlanCode());
          if (plan != null) {
            Map<String, Object> planMap = new HashMap<>();
            planMap.put("id", plan.getId());
            planMap.put("code", plan.getCode());
            planMap.put("name", plan.getName());
            planMap.put("durationMonths", plan.getDurationMonths());
            planMap.put("priceUsd", plan.getPriceUsd() != null ? plan.getPriceUsd().doubleValue() : 0.0);
            subMap.put("plan", planMap);
          }
        } catch (Exception e) {
          System.err.println("Error loading plan: " + e.getMessage());
          // 오류가 발생해도 계속 진행
        }
      }
      
      subscriptionsWithPlans.add(subMap);
    }
    
    // 사용자 정보 구성
    Map<String, Object> userMap = new HashMap<>();
    userMap.put("id", user.getId());
    userMap.put("email", user.getEmail());
    userMap.put("name", user.getName());
    userMap.put("status", user.getStatus());
    userMap.put("createdAt", user.getCreatedAt() != null ? new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(user.getCreatedAt()) : null);
    userMap.put("lastLogin", user.getLastLogin() != null ? new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(user.getLastLogin()) : null);
    
    // 최종 결과 구성
    Map<String, Object> result = new HashMap<>();
    result.put("user", userMap);
    result.put("orders", ordersWithItems);
    result.put("subscriptions", subscriptionsWithPlans);
    
    Gson gson = new Gson();
    out.print(gson.toJson(result));
    
  } catch (NumberFormatException e) {
    response.setStatus(400);
    out.print("{\"error\":\"유효하지 않은 사용자 ID입니다.\"}");
  } catch (Exception e) {
    e.printStackTrace();
    response.setStatus(500);
    out.print("{\"error\":\"서버 오류가 발생했습니다: " + e.getMessage() + "\"}");
  }
%>

