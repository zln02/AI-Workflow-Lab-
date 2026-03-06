<%@ page contentType="application/json; charset=UTF-8" %>
<%@ page import="service.BillingService" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="java.util.*" %>
<%@ page import="java.math.BigDecimal" %>
<%
  response.setHeader("Access-Control-Allow-Origin", "http://localhost:8080");
  response.setHeader("Access-Control-Allow-Methods", "GET");
  response.setHeader("Content-Type", "application/json; charset=UTF-8");

  // 세션에서 실제 user_id 가져오기
  long userId = 0;
  try {
    model.User sessionUser = (model.User) session.getAttribute("user");
    if (sessionUser != null) {
      userId = sessionUser.getId();
    }
  } catch (Exception e) {
    // 비로그인 사용자는 userId=0 유지
  }
  
  // 세션에서 장바구니 가져오기
  List<Map<String, Object>> cartItems = new ArrayList<>();
  try {
    @SuppressWarnings("unchecked")
    List<Map<String, Object>> sessionCart = (List<Map<String, Object>>) session.getAttribute("cart");
    if (sessionCart != null) {
      cartItems = sessionCart;
    }
  } catch (Exception e) {
    // 무시
  }
  
  try {
    BillingService billingService = new BillingService();
    var summary = billingService.summarize(cartItems, userId);
    
    Map<String, Object> result = new HashMap<>();
    result.put("coverLabel", summary.getCoverLabel());
    result.put("hasActiveSubscription", summary.hasActiveSubscription());
    result.put("total", summary.getTotal().doubleValue());
    
    List<Map<String, Object>> items = new ArrayList<>();
    for (var item : summary.getItems()) {
      Map<String, Object> i = new HashMap<>();
      i.put("type", item.getType());
      i.put("name", item.getName());
      i.put("price", item.getPrice().doubleValue());
      i.put("covered", item.isCovered());
      items.add(i);
    }
    result.put("items", items);
    
    Gson gson = new Gson();
    out.print(gson.toJson(result));
    
  } catch (Exception e) {
    response.setStatus(500);
    Map<String, Object> error = new HashMap<>();
    e.printStackTrace();
    error.put("error", "장바구니 요약 조회 중 오류가 발생했습니다.");
    Gson gson = new Gson();
    out.print(gson.toJson(error));
  }
%>



