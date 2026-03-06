<%@ page contentType="application/json; charset=UTF-8" %>
<%@ page import="dao.SearchDAO" %>
<%@ page import="service.IntentService" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="java.util.*" %>
<%
  response.setHeader("Access-Control-Allow-Origin", "http://localhost:8080");
  response.setHeader("Access-Control-Allow-Methods", "GET");
  response.setHeader("Content-Type", "application/json; charset=UTF-8");
  
  String intent = request.getParameter("intent");
  if (intent == null || intent.trim().isEmpty()) {
    intent = "general";
  }
  
  try {
    SearchDAO searchDAO = new SearchDAO();
    
    // 의도별 모델 검색
    var modelList = searchDAO.searchModels("", intent);
    List<Map<String, Object>> models = new ArrayList<>();
    for (var model : modelList) {
      Map<String, Object> m = new HashMap<>();
      m.put("id", model.getId());
      m.put("name", model.getModelName());
      m.put("description", model.getDescription());
      m.put("price", model.getPrice());
      m.put("priceUsd", model.getPrice());
      m.put("categoryName", model.getCategoryName());
      m.put("providerName", model.getProviderName());
      models.add(m);
    }
    
    // 의도별 패키지 검색
    var packageList = searchDAO.searchPackages("", intent);
    List<Map<String, Object>> packages = new ArrayList<>();
    for (var pkg : packageList) {
      Map<String, Object> p = new HashMap<>();
      p.put("id", pkg.getId());
      p.put("title", pkg.getTitle());
      p.put("description", pkg.getDescription());
      p.put("price", pkg.getPrice());
      p.put("discountPrice", pkg.getDiscountPrice());
      packages.add(p);
    }
    
    // JSON 응답
    Map<String, Object> result = new HashMap<>();
    result.put("intent", intent);
    result.put("intentTitle", IntentService.getIntentTitle(intent));
    result.put("recommendedCategories", IntentService.getRecommendedCategories(intent));
    result.put("models", models);
    result.put("packages", packages);
    
    Gson gson = new Gson();
    out.print(gson.toJson(result));
    
  } catch (Exception e) {
    response.setStatus(500);
    Map<String, Object> error = new HashMap<>();
    e.printStackTrace();
    error.put("error", "추천 조회 중 오류가 발생했습니다.");
    Gson gson = new Gson();
    out.print(gson.toJson(error));
  }
%>



