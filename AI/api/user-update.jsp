<%@ page contentType="application/json; charset=UTF-8" %>
<%@ page import="dao.UserDAO" %>
<%@ page import="model.User" %>
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
    String name = request.getParameter("name");
    String email = request.getParameter("email");
    String status = request.getParameter("status");
    
    if (userIdParam == null || userIdParam.trim().isEmpty()) {
      response.setStatus(400);
      out.print("{\"error\":\"사용자 ID가 필요합니다.\"}");
      return;
    }
    
    if (name == null || name.trim().isEmpty() ||
        email == null || email.trim().isEmpty()) {
      response.setStatus(400);
      out.print("{\"error\":\"이름과 이메일은 필수 항목입니다.\"}");
      return;
    }
    
    long userId = Long.parseLong(userIdParam);
    
    UserDAO userDAO = new UserDAO();
    User existingUser = userDAO.findById(userId);
    
    if (existingUser == null) {
      response.setStatus(404);
      out.print("{\"error\":\"사용자를 찾을 수 없습니다.\"}");
      return;
    }
    
    // 이메일 중복 확인 (다른 사용자가 사용 중인지)
    User emailUser = userDAO.findByEmail(email.trim());
    if (emailUser != null && emailUser.getId() != userId) {
      response.setStatus(400);
      out.print("{\"error\":\"이미 사용 중인 이메일입니다.\"}");
      return;
    }
    
    // 사용자 정보 업데이트 (이메일 포함)
    boolean success = userDAO.updateUser(userId, name.trim(), email.trim(), status != null && !status.trim().isEmpty() ? status.trim() : "ACTIVE");
    
    if (success) {
      Map<String, Object> result = new HashMap<>();
      result.put("success", true);
      result.put("message", "고객 정보가 성공적으로 수정되었습니다.");
      
      Gson gson = new Gson();
      out.print(gson.toJson(result));
    } else {
      response.setStatus(500);
      out.print("{\"error\":\"고객 정보 수정에 실패했습니다.\"}");
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

