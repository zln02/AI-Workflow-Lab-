<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.AdminDAO" %>
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

  String idParam = request.getParameter("id");
  
  if (idParam == null || idParam.trim().isEmpty()) {
    out.println("<script>alert('잘못된 요청입니다.'); location.href='index.jsp';</script>");
    return;
  }
  
  try {
    int id = Integer.parseInt(idParam);
    AdminDAO adminDAO = new AdminDAO();
    
    // 자기 자신은 삭제 불가
    model.Admin currentAdmin = (model.Admin) session.getAttribute("admin");
    if (currentAdmin != null && currentAdmin.getId() == id) {
      out.println("<script>alert('자기 자신은 삭제할 수 없습니다.'); location.href='index.jsp';</script>");
      return;
    }
    
    if (adminDAO.delete(id)) {
      response.sendRedirect("/AI/admin/admins/index.jsp");
    } else {
      out.println("<script>alert('관리자 삭제에 실패했습니다.'); location.href='index.jsp';</script>");
    }
  } catch (Exception e) {
    e.printStackTrace();
    out.println("<script>alert('오류가 발생했습니다: " + e.getMessage() + "'); location.href='index.jsp';</script>");
  }
%>

