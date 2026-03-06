<%@ page contentType="application/json; charset=UTF-8" %>
<%@ page import="dao.OrderDAO" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="java.util.*" %>
<%
  response.setHeader("Access-Control-Allow-Origin", "http://localhost:8080");
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
    
    // 디버깅 로그 (민감 정보 제외)
    
    Object idObj = payload.get("id");
    String idParam = null;
    
    if (idObj != null) {
      // 숫자, 문자열 등 여러 형태로 올 수 있으므로 모두 처리
      if (idObj instanceof Number) {
        idParam = String.valueOf(((Number) idObj).intValue());
      } else {
        idParam = idObj.toString();
      }
    }
    
    
    if (idParam == null || idParam.trim().isEmpty()) {
      response.setStatus(400);
      out.print("{\"error\":\"주문 ID가 필요합니다.\"}");
      return;
    }
    
    int orderId;
    try {
      // 숫자만 추출 (공백, 특수문자 제거)
      String cleanId = idParam.trim().replaceAll("[^0-9-]", "");
      orderId = Integer.parseInt(cleanId);
      } catch (NumberFormatException e) {
      response.setStatus(400);
      out.print("{\"error\":\"유효하지 않은 주문 ID입니다.\"}");
      return;
    }
    
    OrderDAO orderDAO = new OrderDAO();
    boolean success = orderDAO.delete(orderId);
    
    if (success) {
      Map<String, Object> result = new HashMap<>();
      result.put("success", true);
      result.put("message", "주문이 성공적으로 삭제되었습니다.");
      
      out.print(gson.toJson(result));
    } else {
      response.setStatus(500);
      out.print("{\"error\":\"주문 삭제에 실패했습니다.\"}");
    }
    
  } catch (NumberFormatException e) {
    response.setStatus(400);
    out.print("{\"error\":\"유효하지 않은 주문 ID입니다.\"}");
  } catch (NoSuchMethodError e) {
    e.printStackTrace();
    System.err.println("Order delete method not found error: " + e.getMessage());
    response.setStatus(500);
    Map<String, Object> error = new HashMap<>();
    error.put("error", "주문 삭제 메서드를 찾을 수 없습니다. 서버를 재시작해주세요.");
    Gson gson = new Gson();
    out.print(gson.toJson(error));
  } catch (Exception e) {
    e.printStackTrace();
    response.setStatus(500);
    Map<String, Object> error = new HashMap<>();
    String errorMessage = e.getMessage();
    if (errorMessage != null && (errorMessage.contains("foreign key") || errorMessage.contains("Foreign key"))) {
      error.put("error", "이 주문은 다른 데이터와 연결되어 있어 삭제할 수 없습니다.");
    } else {
      error.put("error", "서버 오류가 발생했습니다.");
    }
    Gson gson = new Gson();
    out.print(gson.toJson(error));
  }
%>

