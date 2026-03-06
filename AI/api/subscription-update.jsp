<%@ page contentType="application/json; charset=UTF-8" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="java.io.BufferedReader" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>

<%
  response.setHeader("Access-Control-Allow-Origin", "http://localhost:8080");
  response.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
  response.setHeader("Access-Control-Allow-Headers", "Content-Type");

  if ("OPTIONS".equals(request.getMethod())) {
    response.setStatus(HttpServletResponse.SC_OK);
    return;
  }

  Gson gson = new Gson();

  if (session.getAttribute("admin") == null) {
    response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
    Map<String, Object> authErr = new HashMap<>();
    authErr.put("success", false);
    authErr.put("error", "관리자 권한이 필요합니다.");
    out.print(gson.toJson(authErr));
    return;
  }

  try {
    StringBuilder jsonData = new StringBuilder();
    BufferedReader reader = request.getReader();
    String line;
    while ((line = reader.readLine()) != null) {
      jsonData.append(line);
    }

    @SuppressWarnings("unchecked")
    Map<String, Object> json = gson.fromJson(jsonData.toString(), Map.class);
    if (json == null) { throw new IllegalArgumentException("Empty body"); }

    int id = ((Number) json.get("id")).intValue();
    String planCode = json.containsKey("planCode") ? (String) json.get("planCode") : "";
    String status = json.containsKey("status") ? (String) json.get("status") : "active";
    String startDate = json.containsKey("startDate") ? (String) json.get("startDate") : "";
    String endDate = json.containsKey("endDate") ? (String) json.get("endDate") : "";

    // 구독 업데이트 로직 (현재는 성공 응답만 반환)
    Map<String, Object> result = new HashMap<>();
    result.put("success", true);
    result.put("message", "구독이 성공적으로 수정되었습니다.");
    out.print(gson.toJson(result));

  } catch (Exception e) {
    e.printStackTrace();
    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
    Map<String, Object> error = new HashMap<>();
    error.put("success", false);
    error.put("error", "서버 오류가 발생했습니다.");
    out.print(gson.toJson(error));
  }
%>
