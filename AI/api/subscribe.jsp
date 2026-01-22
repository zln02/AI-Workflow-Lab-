<%@ page contentType="application/json; charset=UTF-8" %>
<%@ page import="dao.PlanDAO" %>
<%@ page import="dao.SubscriptionDAO" %>
<%@ page import="model.Plan" %>
<%@ page import="model.Subscription" %>
<%@ page import="model.User" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="java.util.*" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
  response.setHeader("Access-Control-Allow-Origin", "*");
  response.setHeader("Content-Type", "application/json; charset=UTF-8");
  
  if (!"POST".equals(request.getMethod())) {
    response.setStatus(405);
    out.print("{\"error\":\"POST 메서드만 지원합니다.\"}");
    return;
  }
  
  // 세션에서 로그인한 사용자 정보 가져오기
  User user = (User) session.getAttribute("user");
  if (user == null || !user.isActive()) {
    response.setStatus(401);
    out.print("{\"error\":\"로그인이 필요합니다.\"}");
    return;
  }
  
  long userId = user.getId();
  
  String planCode = request.getParameter("planCode");
  if (planCode == null || planCode.trim().isEmpty()) {
    // JSON body에서 읽기 시도
    try {
      String body = "";
      java.io.BufferedReader reader = request.getReader();
      String line;
      while ((line = reader.readLine()) != null) {
        body += line;
      }
      if (!body.isEmpty()) {
        Gson gson = new Gson();
        Map<String, Object> json = gson.fromJson(body, Map.class);
        planCode = (String) json.get("planCode");
      }
    } catch (Exception e) {
      // 무시
    }
  }
  
  if (planCode == null || planCode.trim().isEmpty()) {
    response.setStatus(400);
    out.print("{\"error\":\"요금제 코드가 필요합니다.\"}");
    return;
  }
  
  // 화이트리스트 검증
  if (!planCode.matches("^(STARTER|GROWTH|PRO)$")) {
    response.setStatus(400);
    out.print("{\"error\":\"유효하지 않은 요금제 코드입니다.\"}");
    return;
  }
  
  try {
    PlanDAO planDAO = new PlanDAO();
    Plan plan = planDAO.findByCode(planCode);
    
    if (plan == null) {
      response.setStatus(404);
      out.print("{\"error\":\"요금제를 찾을 수 없습니다.\"}");
      return;
    }
    
    // 구독 생성
    Subscription subscription = new Subscription();
    subscription.setUserId(userId);
    subscription.setPlanCode(planCode);
    subscription.setStartDate(LocalDate.now());
    subscription.setEndDate(LocalDate.now().plusMonths(plan.getDurationMonths()));
    subscription.setStatus("ACTIVE");
    subscription.setPaymentMethod("card"); // 기본값
    subscription.setTransactionId("TXN-" + System.currentTimeMillis());
    
    SubscriptionDAO subscriptionDAO = new SubscriptionDAO();
    long subscriptionId = subscriptionDAO.insert(subscription);
    
    if (subscriptionId > 0) {
      Map<String, Object> result = new HashMap<>();
      result.put("success", true);
      result.put("subscriptionId", subscriptionId);
      result.put("planCode", planCode);
      result.put("startDate", subscription.getStartDate().toString());
      result.put("endDate", subscription.getEndDate().toString());
      
      Gson gson = new Gson();
      out.print(gson.toJson(result));
    } else {
      response.setStatus(500);
      out.print("{\"error\":\"구독 생성에 실패했습니다.\"}");
    }
    
  } catch (Exception e) {
    response.setStatus(500);
    Map<String, Object> error = new HashMap<>();
    error.put("error", "구독 생성 중 오류가 발생했습니다: " + e.getMessage());
    Gson gson = new Gson();
    out.print(gson.toJson(error));
  }
%>



