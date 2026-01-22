<%@ page contentType="application/json; charset=UTF-8" %>
<%@ page import="dao.SubscriptionDAO" %>
<%@ page import="model.Subscription" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="java.util.*" %>
<%
  response.setHeader("Access-Control-Allow-Origin", "*");
  response.setHeader("Content-Type", "application/json; charset=UTF-8");
  
  if (session.getAttribute("admin") == null) {
    response.setStatus(403);
    out.print("{\"error\":\"관리자 권한이 필요합니다.\"}");
    return;
  }
  
  if (!"POST".equals(request.getMethod())) {
    response.setStatus(405);
    out.print("{\"error\":\"POST 메서드만 지원합니다.\"}");
    return;
  }
  
  try {
    // JSON body에서 읽기
    String body = "";
    try (java.io.BufferedReader reader = request.getReader()) {
      String line;
      while ((line = reader.readLine()) != null) {
        body += line;
      }
    }
    
    Gson gson = new Gson();
    Map<String, Object> payload = new HashMap<>();
    
    if (body != null && !body.trim().isEmpty()) {
      payload = gson.fromJson(body, HashMap.class);
    }
    
    // 디버깅: 받은 데이터 로그 출력
    System.err.println("Subscription delete request body: " + body);
    System.err.println("Parsed payload: " + payload);
    
    Object idObj = payload.get("id");
    String idParam = null;
    
    if (idObj != null) {
      // 숫자, 문자열 등 여러 형태로 올 수 있으므로 모두 처리
      if (idObj instanceof Number) {
        idParam = String.valueOf(((Number) idObj).longValue());
      } else {
        idParam = idObj.toString();
      }
    }
    
    System.err.println("Extracted subscription ID: " + idParam);
    
    if (idParam == null || idParam.trim().isEmpty()) {
      response.setStatus(400);
      out.print("{\"error\":\"구독 ID가 필요합니다.\"}");
      return;
    }
    
    long subscriptionId;
    try {
      // 숫자만 추출 (공백, 특수문자 제거)
      String cleanId = idParam.trim().replaceAll("[^0-9-]", "");
      subscriptionId = Long.parseLong(cleanId);
      System.err.println("Parsed subscription ID: " + subscriptionId);
    } catch (NumberFormatException e) {
      System.err.println("NumberFormatException: idParam=" + idParam + ", cleanId=" + (idParam != null ? idParam.trim().replaceAll("[^0-9-]", "") : "null"));
      System.err.println("Full exception: " + e.getClass().getName() + ": " + e.getMessage());
      e.printStackTrace();
      response.setStatus(400);
      String errorMsg = "유효하지 않은 구독 ID입니다";
      if (idParam != null && !idParam.trim().isEmpty()) {
        errorMsg += ": " + idParam;
      }
      out.print("{\"error\":\"" + errorMsg + "\"}");
      return;
    }
    
    SubscriptionDAO subscriptionDAO = new SubscriptionDAO();
    boolean success = subscriptionDAO.delete(subscriptionId);
    
    if (success) {
      Map<String, Object> result = new HashMap<>();
      result.put("success", true);
      result.put("message", "구독이 성공적으로 삭제되었습니다.");
      
      out.print(gson.toJson(result));
    } else {
      response.setStatus(500);
      out.print("{\"error\":\"구독 삭제에 실패했습니다. 해당 구독이 존재하지 않을 수 있습니다.\"}");
    }
    
  } catch (NumberFormatException e) {
    response.setStatus(400);
    out.print("{\"error\":\"유효하지 않은 구독 ID입니다.\"}");
  } catch (Exception e) {
    e.printStackTrace();
    System.err.println("Subscription delete error: " + e.getClass().getName() + ": " + e.getMessage());
    if (e.getCause() != null) {
      System.err.println("Cause: " + e.getCause().getMessage());
    }
    response.setStatus(500);
    Map<String, Object> error = new HashMap<>();
    String errorMessage = e.getMessage();
    if (errorMessage != null && errorMessage.contains("foreign key")) {
      errorMessage = "이 구독은 다른 데이터와 연결되어 있어 삭제할 수 없습니다. 상태를 'CANCELLED'로 변경하세요.";
    }
    error.put("error", "서버 오류가 발생했습니다: " + errorMessage);
    Gson gson = new Gson();
    out.print(gson.toJson(error));
  }
%>

