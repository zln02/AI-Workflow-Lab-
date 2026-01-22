<%@ page contentType="application/json; charset=UTF-8" %>
<%@ page import="dao.UserDAO" %>
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
    String userIdParam = request.getParameter("userId");
    
    if (userIdParam == null || userIdParam.trim().isEmpty()) {
      response.setStatus(400);
      out.print("{\"error\":\"사용자 ID가 필요합니다.\"}");
      return;
    }
    
    long userId = Long.parseLong(userIdParam);
    
    UserDAO userDAO = new UserDAO();
    boolean success = userDAO.deleteUser(userId);
    
    if (success) {
      Map<String, Object> result = new HashMap<>();
      result.put("success", true);
      result.put("message", "고객이 성공적으로 삭제되었습니다.");
      
      Gson gson = new Gson();
      out.print(gson.toJson(result));
    } else {
      response.setStatus(500);
      out.print("{\"error\":\"고객 삭제에 실패했습니다.\"}");
    }
    
  } catch (NumberFormatException e) {
    response.setStatus(400);
    out.print("{\"error\":\"유효하지 않은 사용자 ID입니다.\"}");
  } catch (Exception e) {
    e.printStackTrace();
    response.setStatus(500);
    Map<String, Object> error = new HashMap<>();
    error.put("error", "서버 오류가 발생했습니다: " + e.getMessage());
    Gson gson = new Gson();
    out.print(gson.toJson(error));
  }
%>


