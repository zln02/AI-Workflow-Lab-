<%@ page contentType="application/json; charset=UTF-8" %>
<%@ page import="dao.UserDAO" %>
<%@ page import="model.User" %>
<%@ page import="service.UserService" %>
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
    String name = request.getParameter("name");
    String email = request.getParameter("email");
    String password = request.getParameter("password");
    String status = request.getParameter("status");
    
    if (name == null || name.trim().isEmpty() ||
        email == null || email.trim().isEmpty() ||
        password == null || password.trim().isEmpty()) {
      response.setStatus(400);
      out.print("{\"error\":\"이름, 이메일, 비밀번호는 필수 항목입니다.\"}");
      return;
    }
    
    // 이메일 중복 확인
    UserDAO userDAO = new UserDAO();
    User existingUser = userDAO.findByEmail(email.trim());
    if (existingUser != null) {
      response.setStatus(400);
      out.print("{\"error\":\"이미 사용 중인 이메일입니다.\"}");
      return;
    }
    
    // 비밀번호 해싱
    UserService userService = new UserService();
    String passwordHash = userService.hashPassword(password);
    
    // 사용자 생성
    User user = new User();
    user.setEmail(email.trim());
    user.setPasswordHash(passwordHash);
    user.setName(name.trim());
    user.setStatus(status != null && !status.trim().isEmpty() ? status.trim() : "ACTIVE");
    
    long userId = userDAO.createUser(user);
    
    if (userId > 0) {
      Map<String, Object> result = new HashMap<>();
      result.put("success", true);
      result.put("userId", userId);
      result.put("message", "고객이 성공적으로 생성되었습니다.");
      
      Gson gson = new Gson();
      out.print(gson.toJson(result));
    } else {
      response.setStatus(500);
      out.print("{\"error\":\"고객 생성에 실패했습니다.\"}");
    }
    
  } catch (Exception e) {
    e.printStackTrace();
    response.setStatus(500);
    Map<String, Object> error = new HashMap<>();
    error.put("error", "서버 오류가 발생했습니다: " + e.getMessage());
    Gson gson = new Gson();
    out.print(gson.toJson(error));
  }
%>


