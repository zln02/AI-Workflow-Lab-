<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.AIModelDAO" %>
<%@ page import="model.AIModel" %>
<%@ page import="java.math.BigDecimal" %>
<%
  // 관리자 인증 확인
  if (session.getAttribute("admin") == null) {
    response.sendRedirect("/AI/admin/auth/login.jsp");
    return;
  }

  request.setCharacterEncoding("UTF-8");
  
  AIModelDAO modelDAO = new AIModelDAO();
  
  String idParam = request.getParameter("id");
  String modelName = request.getParameter("model_name");
  String providerIdStr = request.getParameter("provider_id");
  String categoryIdStr = request.getParameter("category_id");
  String price = request.getParameter("price");
  String description = request.getParameter("description");
  String purposeSummary = request.getParameter("purpose_summary");
  String apiAvailableStr = request.getParameter("api_available");
  String finetuneAvailableStr = request.getParameter("finetune_available");
  String onpremAvailableStr = request.getParameter("onprem_available");
  String commercialUseAllowedStr = request.getParameter("commercial_use_allowed");
  
  // 입력 검증
  if (modelName == null || modelName.trim().isEmpty()) {
    out.println("<script>alert('모델명을 입력해주세요.'); history.back();</script>");
    return;
  }
  
  try {
    AIModel model = new AIModel();
    
    if (idParam != null && !idParam.trim().isEmpty()) {
      model.setId(Integer.parseInt(idParam));
    }
    
    model.setModelName(modelName.trim());
    
    if (providerIdStr != null && !providerIdStr.trim().isEmpty()) {
      model.setProviderId(Integer.parseInt(providerIdStr));
    }
    
    if (categoryIdStr != null && !categoryIdStr.trim().isEmpty()) {
      model.setCategoryId(Integer.parseInt(categoryIdStr));
    }
    
    model.setPrice(price != null ? price.trim() : null);
    model.setDescription(description != null ? description.trim() : null);
    model.setPurposeSummary(purposeSummary != null ? purposeSummary.trim() : null);
    model.setApiAvailable("true".equals(apiAvailableStr));
    model.setFinetuneAvailable("true".equals(finetuneAvailableStr));
    model.setOnpremAvailable("true".equals(onpremAvailableStr));
    model.setCommercialUseAllowed("true".equals(commercialUseAllowedStr));
    
    if (model.getId() > 0) {
      // 수정
      if (modelDAO.update(model)) {
        response.sendRedirect("/AI/admin/models/index.jsp");
      } else {
        out.println("<script>alert('모델 수정에 실패했습니다.'); history.back();</script>");
      }
    } else {
      // 신규 등록
      int newId = modelDAO.insert(model);
      if (newId > 0) {
        response.sendRedirect("/AI/admin/models/index.jsp");
      } else {
        out.println("<script>alert('모델 등록에 실패했습니다.'); history.back();</script>");
      }
    }
    
  } catch (Exception e) {
    e.printStackTrace();
    out.println("<script>alert('오류가 발생했습니다: " + e.getMessage() + "'); history.back();</script>");
  }
%>

