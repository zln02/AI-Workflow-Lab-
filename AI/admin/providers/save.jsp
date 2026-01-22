<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.ProviderDAO" %>
<%@ page import="model.Provider" %>
<%
  // 관리자 인증 확인
  if (session.getAttribute("admin") == null) {
    response.sendRedirect("/AI/admin/auth/login.jsp");
    return;
  }

  request.setCharacterEncoding("UTF-8");
  
  ProviderDAO providerDAO = new ProviderDAO();
  
  String idParam = request.getParameter("id");
  String providerName = request.getParameter("provider_name");
  String website = request.getParameter("website");
  String country = request.getParameter("country");
  
  // 입력 검증
  if (providerName == null || providerName.trim().isEmpty()) {
    out.println("<script>alert('제공사명을 입력해주세요.'); history.back();</script>");
    return;
  }
  
  try {
    Provider provider = new Provider();
    
    if (idParam != null && !idParam.trim().isEmpty()) {
      provider.setId(Integer.parseInt(idParam));
    }
    
    provider.setProviderName(providerName.trim());
    provider.setWebsite(website != null ? website.trim() : null);
    provider.setCountry(country != null ? country.trim() : null);
    
    if (provider.getId() > 0) {
      // 수정
      if (providerDAO.update(provider)) {
        response.sendRedirect("/AI/admin/providers/index.jsp");
      } else {
        out.println("<script>alert('제공사 수정에 실패했습니다.'); history.back();</script>");
      }
    } else {
      // 신규 등록
      int newId = providerDAO.insert(provider);
      if (newId > 0) {
        response.sendRedirect("/AI/admin/providers/index.jsp");
      } else {
        out.println("<script>alert('제공사 등록에 실패했습니다.'); history.back();</script>");
      }
    }
    
  } catch (Exception e) {
    e.printStackTrace();
    out.println("<script>alert('오류가 발생했습니다: " + e.getMessage() + "'); history.back();</script>");
  }
%>

