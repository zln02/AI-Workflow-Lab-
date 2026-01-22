<%@ page contentType="application/json; charset=UTF-8" %>
<%@ page import="dao.SubscriptionDAO" %>
<%@ page import="model.Subscription" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="java.util.*" %>
<%
  response.setHeader("Access-Control-Allow-Origin", "*");
  response.setHeader("Access-Control-Allow-Methods", "GET");
  response.setHeader("Content-Type", "application/json; charset=UTF-8");
  
  // 세션에서 user_id 가져오기
  long userId = 0;
  try {
    String sessionId = session.getId();
    userId = Math.abs(sessionId.hashCode());
  } catch (Exception e) {
    userId = System.currentTimeMillis() % 1000000;
  }
  
  try {
    SubscriptionDAO subscriptionDAO = new SubscriptionDAO();
    Subscription subscription = subscriptionDAO.findActiveByUserId(userId);
    
    Map<String, Object> result = new HashMap<>();
    if (subscription != null && subscription.isActiveNow()) {
      result.put("active", true);
      result.put("planCode", subscription.getPlanCode());
      result.put("startDate", subscription.getStartDate().toString());
      result.put("endDate", subscription.getEndDate().toString());
      result.put("daysRemaining", subscription.getDaysRemaining());
    } else {
      result.put("active", false);
    }
    
    Gson gson = new Gson();
    out.print(gson.toJson(result));
    
  } catch (Exception e) {
    response.setStatus(500);
    Map<String, Object> error = new HashMap<>();
    error.put("error", "구독 조회 중 오류가 발생했습니다: " + e.getMessage());
    Gson gson = new Gson();
    out.print(gson.toJson(error));
  }
%>



