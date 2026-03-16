<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.CategoryDAO" %>
<%@ page import="model.Category" %>
<%@ page import="util.CSRFUtil" %>
<%
  // 관리자 인증 확인
  if (session.getAttribute("admin") == null) {
    response.sendRedirect("/AI/admin/auth/login.jsp");
    return;
  }

  if (!"POST".equalsIgnoreCase(request.getMethod()) || !CSRFUtil.validateToken(request)) {
    response.setStatus(403);
    out.println("<script>alert('보안 검증에 실패했습니다.'); history.back();</script>");
    return;
  }

  request.setCharacterEncoding("UTF-8");
  
  CategoryDAO categoryDAO = new CategoryDAO();
  
  String idParam = request.getParameter("id");
  String categoryName = request.getParameter("category_name");
  
  // 입력 검증
  if (categoryName == null || categoryName.trim().isEmpty()) {
    out.println("<script>alert('카테고리명을 입력해주세요.'); history.back();</script>");
    return;
  }
  
  try {
    Category category = new Category();
    
    if (idParam != null && !idParam.trim().isEmpty()) {
      category.setId(Integer.parseInt(idParam));
    }
    
    category.setCategoryName(categoryName.trim());
    
    if (category.getId() > 0) {
      // 수정
      if (categoryDAO.update(category)) {
        response.sendRedirect("/AI/admin/categories/index.jsp");
      } else {
        out.println("<script>alert('카테고리 수정에 실패했습니다.'); history.back();</script>");
      }
    } else {
      // 신규 등록
      int newId = categoryDAO.insert(category);
      if (newId > 0) {
        response.sendRedirect("/AI/admin/categories/index.jsp");
      } else {
        out.println("<script>alert('카테고리 등록에 실패했습니다.'); history.back();</script>");
      }
    }
    
  } catch (Exception e) {
    e.printStackTrace();
    out.println("<script>alert('오류가 발생했습니다. 잠시 후 다시 시도해주세요.'); history.back();</script>");
  }
%>
