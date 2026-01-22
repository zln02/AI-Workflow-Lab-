<%@ page contentType="application/json; charset=UTF-8" buffer="32kb" autoFlush="true" %>
<%@ page import="dao.SearchDAO" %>
<%@ page import="dao.SearchLogDAO" %>
<%@ page import="service.IntentService" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="model.AIModel" %>
<%@ page import="model.Package" %>
<%@ page import="java.util.*" %>
<%
  response.setHeader("Access-Control-Allow-Origin", "*");
  response.setHeader("Access-Control-Allow-Methods", "GET");
  response.setHeader("Content-Type", "application/json; charset=UTF-8");
  
  String q = request.getParameter("q");
  if (q == null || q.trim().isEmpty()) {
    response.setStatus(400);
    out.print("{\"error\":\"검색어가 필요합니다.\"}");
    return;
  }
  
  // 검색어 길이 제한
  if (q.length() > 500) {
    q = q.substring(0, 500);
  }
  
  // 의도 추론
  String intent = IntentService.infer(q);
  
  // 검색 실행
  SearchDAO searchDAO = new SearchDAO();
  List<Map<String, Object>> models = new ArrayList<>();
  List<Map<String, Object>> packages = new ArrayList<>();
  
  try {
    // 모델 검색
    List<AIModel> modelList = searchDAO.searchModels(q, intent);
    for (AIModel model : modelList) {
      Map<String, Object> m = new HashMap<>();
      m.put("id", model.getId());
      m.put("name", model.getModelName());
      m.put("description", model.getDescription());
      m.put("price", model.getPrice());
      m.put("priceUsd", model.getPriceUsd());
      m.put("categoryName", model.getCategoryName());
      m.put("providerName", model.getProviderName());
      models.add(m);
    }
    
    // 패키지 검색
    List<Package> packageList = searchDAO.searchPackages(q, intent);
    for (Package pkg : packageList) {
      Map<String, Object> p = new HashMap<>();
      p.put("id", pkg.getId());
      p.put("title", pkg.getTitle());
      p.put("description", pkg.getDescription());
      p.put("price", pkg.getPrice());
      p.put("discountPrice", pkg.getDiscountPrice());
      packages.add(p);
    }
    
    // 검색 로그 기록
    SearchLogDAO logDAO = new SearchLogDAO();
    try {
      // user_id는 세션에서 가져오거나 null
      Long userId = null;
      try {
        Object userIdObj = session.getAttribute("user_id");
        if (userIdObj != null) {
          userId = Long.parseLong(userIdObj.toString());
        }
      } catch (Exception e) {
        // 무시
      }
      
      // 검색 로그는 별도로 기록 (의도 포함)
      // SearchLogDAO는 keyword만 받으므로 확장 필요하지만 일단 기본 로그만
      logDAO.logSearch(q, models.size() + packages.size());
    } catch (Exception e) {
      // 로그 실패는 무시
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
    String errorMessage = "검색 중 오류가 발생했습니다";
    if (e.getMessage() != null) {
      errorMessage += ": " + e.getMessage();
    }
    error.put("error", errorMessage);
    error.put("details", e.getClass().getName());
    // 개발 환경에서만 스택 트레이스 포함
    if (e.getCause() != null) {
      error.put("cause", e.getCause().getMessage());
    }
    Gson gson = new Gson();
    out.print(gson.toJson(error));
    // 서버 로그에도 기록
    e.printStackTrace();
  }
%>

