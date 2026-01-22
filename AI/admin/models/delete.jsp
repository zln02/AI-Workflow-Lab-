<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.AIModelDAO" %>
<%
  // 관리자 인증 확인
  if (session.getAttribute("admin") == null) {
    response.sendRedirect("/AI/admin/auth/login.jsp");
    return;
  }

  String idParam = request.getParameter("id");
  
  if (idParam == null || idParam.trim().isEmpty()) {
    out.println("<script>alert('잘못된 요청입니다.'); location.href='index.jsp';</script>");
    return;
  }
  
  try {
    int id = Integer.parseInt(idParam);
    AIModelDAO modelDAO = new AIModelDAO();
    
    if (modelDAO.delete(id)) {
      response.sendRedirect("/AI/admin/models/index.jsp");
    } else {
      out.println("<script>alert('모델 삭제에 실패했습니다.'); location.href='index.jsp';</script>");
    }
  } catch (Exception e) {
    e.printStackTrace();
    out.println("<script>alert('오류가 발생했습니다: " + e.getMessage() + "'); location.href='index.jsp';</script>");
  }
%>

