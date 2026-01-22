<%@ page contentType="application/json; charset=UTF-8" %>
<%@ page import="dao.OrderDAO" %>
<%@ page import="dao.AIModelDAO" %>
<%@ page import="dao.PackageDAO" %>
<%@ page import="model.Order" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="java.util.*" %>
<%@ page import="java.math.BigDecimal" %>
<%
  // 관리자 인증 확인
  if (session.getAttribute("admin") == null) {
    response.setStatus(401);
    out.print("{\"error\":\"인증이 필요합니다.\"}");
    return;
  }

  response.setHeader("Access-Control-Allow-Origin", "*");
  response.setHeader("Access-Control-Allow-Methods", "GET");
  response.setHeader("Content-Type", "application/json; charset=UTF-8");

  try {
    OrderDAO orderDAO = new OrderDAO();
    AIModelDAO modelDAO = new AIModelDAO();
    PackageDAO packageDAO = new PackageDAO();
    
    // 최근 주문 개수 (기본값: 10개)
    String limitParam = request.getParameter("limit");
    int limit = 10;
    if (limitParam != null && !limitParam.trim().isEmpty()) {
      try {
        limit = Integer.parseInt(limitParam);
        if (limit > 50) limit = 50; // 최대 50개로 제한
        if (limit < 1) limit = 10;
      } catch (NumberFormatException e) {
        limit = 10;
      }
    }
    
    // 최근 주문 조회
    List<Order> orders = orderDAO.findRecentOrders(limit);
    
    // 주문 정보를 JSON 형태로 변환
    List<Map<String, Object>> orderList = new ArrayList<>();
    for (Order order : orders) {
      Map<String, Object> orderMap = new HashMap<>();
      orderMap.put("id", order.getId());
      orderMap.put("customerName", order.getCustomerName());
      orderMap.put("customerEmail", order.getCustomerEmail());
      orderMap.put("customerPhone", order.getCustomerPhone());
      orderMap.put("paymentMethod", order.getPaymentMethod());
      orderMap.put("totalPrice", order.getTotalPrice() != null ? order.getTotalPrice().doubleValue() : 0.0);
      orderMap.put("orderStatus", order.getOrderStatus());
      orderMap.put("createdAt", order.getCreatedAt());
      
      // 주문 아이템 정보 가져오기
      List<Map<String, Object>> orderItems = orderDAO.findOrderItems(order.getId());
      List<Map<String, Object>> itemsWithNames = new ArrayList<>();
      
      for (Map<String, Object> item : orderItems) {
        Map<String, Object> itemWithName = new HashMap<>();
        itemWithName.put("itemType", item.get("itemType"));
        itemWithName.put("itemId", item.get("itemId"));
        itemWithName.put("quantity", item.get("quantity"));
        itemWithName.put("price", ((BigDecimal) item.get("price")).doubleValue());
        
        // 아이템 이름 가져오기
        String itemType = (String) item.get("itemType");
        int itemId = (Integer) item.get("itemId");
        String itemName = "알 수 없음";
        
        try {
          if ("MODEL".equals(itemType)) {
            var model = modelDAO.findById(itemId);
            if (model != null) {
              itemName = model.getModelName() != null ? model.getModelName() : "모델 #" + itemId;
            }
          } else if ("PACKAGE".equals(itemType)) {
            var pkg = packageDAO.findById(itemId);
            if (pkg != null) {
              itemName = pkg.getTitle() != null ? pkg.getTitle() : "패키지 #" + itemId;
            }
          }
        } catch (Exception e) {
          // 아이템 조회 실패 시 기본값 사용
        }
        
        itemWithName.put("itemName", itemName);
        itemsWithNames.add(itemWithName);
      }
      
      orderMap.put("items", itemsWithNames);
      orderList.add(orderMap);
    }
    
    // JSON 응답
    Map<String, Object> result = new HashMap<>();
    result.put("success", true);
    result.put("orders", orderList);
    result.put("count", orderList.size());
    
    Gson gson = new Gson();
    out.print(gson.toJson(result));
    
  } catch (Exception e) {
    response.setStatus(500);
    e.printStackTrace();
    Map<String, Object> error = new HashMap<>();
    error.put("success", false);
    error.put("error", "최근 주문 조회 중 오류가 발생했습니다: " + (e.getMessage() != null ? e.getMessage() : e.getClass().getName()));
    
    Gson gson = new Gson();
    out.print(gson.toJson(error));
  }
%>



