<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.TagDAO" %>
<%@ page import="model.Tag" %>
<%
  // 관리자 인증 확인
  if (session.getAttribute("admin") == null) {
    response.sendRedirect("/AI/admin/auth/login.jsp");
    return;
  }

  request.setCharacterEncoding("UTF-8");
  
  TagDAO tagDAO = new TagDAO();
  
  String idParam = request.getParameter("id");
  String tagName = request.getParameter("tag_name");
  
  // 입력 검증
  if (tagName == null || tagName.trim().isEmpty()) {
    out.println("<script>alert('태그명을 입력해주세요.'); history.back();</script>");
    return;
  }
  
  try {
    Tag tag = new Tag();
    
    if (idParam != null && !idParam.trim().isEmpty()) {
      tag.setId(Integer.parseInt(idParam));
    }
    
    tag.setTagName(tagName.trim());
    
    if (tag.getId() > 0) {
      // 수정
      if (tagDAO.update(tag)) {
        response.sendRedirect("/AI/admin/tags/index.jsp");
      } else {
        out.println("<script>alert('태그 수정에 실패했습니다.'); history.back();</script>");
      }
    } else {
      // 신규 등록
      int newId = tagDAO.insert(tag);
      if (newId > 0) {
        response.sendRedirect("/AI/admin/tags/index.jsp");
      } else {
        out.println("<script>alert('태그 등록에 실패했습니다.'); history.back();</script>");
      }
    }
    
  } catch (Exception e) {
    e.printStackTrace();
    out.println("<script>alert('오류가 발생했습니다: " + e.getMessage() + "'); history.back();</script>");
  }
%>

