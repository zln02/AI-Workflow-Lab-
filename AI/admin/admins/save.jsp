<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.AdminDAO" %>
<%@ page import="model.Admin" %>
<%@ page import="security.PasswordUtils" %>
<%@ page import="org.mindrot.jbcrypt.BCrypt" %>
<%
  // 관리자 인증 확인
  if (session.getAttribute("admin") == null) {
    response.sendRedirect("/AI/admin/auth/login.jsp");
    return;
  }

  // Superadmin 권한 확인
  String adminRole = (String) session.getAttribute("adminRole");
  boolean isSuperadmin = "SUPER".equals(adminRole) || "superadmin".equals(adminRole);
  
  if (!isSuperadmin) {
    response.sendRedirect("/AI/admin/statistics/index.jsp");
    return;
  }

  request.setCharacterEncoding("UTF-8");
  
  AdminDAO adminDAO = new AdminDAO();
  
  String idParam = request.getParameter("id");
  String username = request.getParameter("username");
  String password = request.getParameter("password");
  String name = request.getParameter("name");
  String email = request.getParameter("email");
  String role = request.getParameter("role");
  String status = request.getParameter("status");
  
  // 입력 검증
  if (username == null || username.trim().isEmpty() || role == null || status == null) {
    out.println("<script>alert('필수 항목을 입력해주세요.'); history.back();</script>");
    return;
  }
  
  try {
    Admin admin = new Admin();
    
    if (idParam != null && !idParam.trim().isEmpty()) {
      // 수정
      admin.setId(Integer.parseInt(idParam));
      Admin existing = adminDAO.findById(admin.getId());
      if (existing == null) {
        out.println("<script>alert('관리자를 찾을 수 없습니다.'); history.back();</script>");
        return;
      }
      admin.setUsername(existing.getUsername()); // 아이디는 변경 불가
    } else {
      // 신규 등록
      if (password == null || password.trim().isEmpty()) {
        out.println("<script>alert('비밀번호를 입력해주세요.'); history.back();</script>");
        return;
      }
      admin.setUsername(username.trim());
      // 비밀번호 해시화
      String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
      admin.setPassword(hashedPassword);
    }
    
    admin.setName(name != null ? name.trim() : null);
    admin.setEmail(email != null ? email.trim() : null);
    admin.setRole(role);
    admin.setStatus(status);
    
    if (admin.getId() > 0) {
      // 수정
      if (password != null && !password.trim().isEmpty()) {
        // 비밀번호 변경
        String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
        adminDAO.updatePassword(admin.getId(), hashedPassword);
      }
      if (adminDAO.update(admin)) {
        response.sendRedirect("/AI/admin/admins/index.jsp");
      } else {
        out.println("<script>alert('관리자 수정에 실패했습니다.'); history.back();</script>");
      }
    } else {
      // 신규 등록
      int newId = adminDAO.insert(admin);
      if (newId > 0) {
        response.sendRedirect("/AI/admin/admins/index.jsp");
      } else {
        out.println("<script>alert('관리자 등록에 실패했습니다.'); history.back();</script>");
      }
    }
    
  } catch (Exception e) {
    e.printStackTrace();
    out.println("<script>alert('오류가 발생했습니다: " + e.getMessage() + "'); history.back();</script>");
  }
%>

