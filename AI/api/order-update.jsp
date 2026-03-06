<%@ page contentType="application/json; charset=UTF-8" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="org.json.JSONException" %>
<%@ page import="java.io.BufferedReader" %>
<%@ page import="dao.UserDAO" %>

<%
  response.setHeader("Access-Control-Allow-Origin", "http://localhost:8080");
  response.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
  response.setHeader("Access-Control-Allow-Headers", "Content-Type");
  
  if ("OPTIONS".equals(request.getMethod())) {
    response.setStatus(HttpServletResponse.SC_OK);
    return;
  }

  if (session.getAttribute("admin") == null) {
    response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
    out.print(new JSONObject().put("success", false).put("error", "관리자 권한이 필요합니다.").toString());
    return;
  }

  try {
    StringBuilder jsonData = new StringBuilder();
    BufferedReader reader = request.getReader();
    String line;
    while ((line = reader.readLine()) != null) {
      jsonData.append(line);
    }

    JSONObject json = new JSONObject(jsonData.toString());
    
    int id = json.getInt("id");
    String status = json.optString("status", "pending");
    String notes = json.optString("notes", "");
    double amount = json.optDouble("amount", 0.0);

    UserDAO userDAO = new UserDAO();
    
    // TODO: 실제 주문 업데이트 쿼리 구현 필요
    // 현재는 성공 응답만 반환
    boolean success = true;

    JSONObject result = new JSONObject();
    result.put("success", success);
    if (success) {
      result.put("message", "주문이 성공적으로 수정되었습니다.");
    } else {
      result.put("error", "주문 수정에 실패했습니다.");
    }

    out.print(result.toString());
  } catch (JSONException e) {
    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
    JSONObject error = new JSONObject();
    error.put("success", false);
    error.put("error", "잘못된 요청 형식입니다: " + e.getMessage());
    out.print(error.toString());
  } catch (Exception e) {
    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
    JSONObject error = new JSONObject();
    error.put("success", false);
    error.put("error", "서버 오류가 발생했습니다: " + e.getMessage());
    out.print(error.toString());
  }
%>
