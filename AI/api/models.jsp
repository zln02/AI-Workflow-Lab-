<%@ page contentType="application/json; charset=UTF-8" buffer="32kb" autoFlush="true" %>
<%@ page import="dao.AIModelDAO" %>
<%@ page import="dao.CategoryDAO" %>
<%@ page import="java.util.*" %>
<%
  response.setHeader("Access-Control-Allow-Origin", "*");
  response.setHeader("Access-Control-Allow-Methods", "GET");
  response.setHeader("Content-Type", "application/json; charset=UTF-8");
  
  String catParam = request.getParameter("cat");
  List<Integer> categoryIds = new ArrayList<>();
  
  if (catParam != null && !catParam.trim().isEmpty()) {
    String[] catNames = catParam.split(",");
    CategoryDAO categoryDAO = new CategoryDAO();
    var allCategories = categoryDAO.findAll();
    
    for (String catName : catNames) {
      catName = catName.trim();
      for (var cat : allCategories) {
        if (cat.getCategoryName().equals(catName)) {
          categoryIds.add(cat.getId());
          break;
        }
      }
    }
  }
  
  try {
    AIModelDAO modelDAO = new AIModelDAO();
    CategoryDAO categoryDAO = new CategoryDAO();
    List<model.AIModel> models;
    
    if (categoryIds.isEmpty()) {
      models = modelDAO.findAll();
    } else {
      // 카테고리별 모델 필터링 - 선택된 카테고리에 해당하는 모든 모델 반환
      models = new ArrayList<>();
      java.util.Set<Integer> addedModelIds = new java.util.HashSet<>();
      
      for (Integer catId : categoryIds) {
        var catModels = modelDAO.findByCategory(catId);
        for (var model : catModels) {
          // 중복 제거 및 전체 정보 가져오기
          if (!addedModelIds.contains(model.getId())) {
            // findById로 전체 정보 가져오기 (provider_name, category_name 포함)
            var fullModel = modelDAO.findById(model.getId());
            if (fullModel != null) {
              models.add(fullModel);
              addedModelIds.add(fullModel.getId());
            }
          }
        }
      }
    }
    
    // 카테고리 이름 매핑
    var allCategories = categoryDAO.findAll();
    java.util.Map<Integer, String> categoryNameMap = new java.util.HashMap<>();
    for (var cat : allCategories) {
      categoryNameMap.put(cat.getId(), cat.getCategoryName());
    }
    
    StringBuilder json = new StringBuilder("[");
    boolean first = true;
    for (var model : models) {
      if (!first) json.append(",");
      json.append("{");
      json.append("\"id\":").append(model.getId()).append(",");
      json.append("\"name\":\"").append(escapeJson(model.getModelName() != null ? model.getModelName() : "")).append("\",");
      json.append("\"description\":\"").append(escapeJson(model.getDescription() != null ? model.getDescription() : "")).append("\",");
      json.append("\"purposeSummary\":\"").append(escapeJson(model.getPurposeSummary() != null ? model.getPurposeSummary() : "")).append("\",");
      
      // 가격 처리
      if (model.getPriceUsd() != null) {
        json.append("\"priceUsd\":").append(model.getPriceUsd().doubleValue()).append(",");
      } else {
        json.append("\"priceUsd\":0,");
      }
      
      if (model.getPrice() != null) {
        json.append("\"price\":\"").append(escapeJson(model.getPrice())).append("\",");
      } else {
        json.append("\"price\":\"무료 / 문의\",");
      }
      
      // 카테고리 이름 가져오기
      String categoryName = model.getCategoryName();
      if (categoryName == null && model.getCategoryId() != null) {
        categoryName = categoryNameMap.get(model.getCategoryId());
      }
      json.append("\"categoryName\":\"").append(escapeJson(categoryName != null ? categoryName : "")).append("\",");
      json.append("\"providerName\":\"").append(escapeJson(model.getProviderName() != null ? model.getProviderName() : "")).append("\"");
      
      json.append("}");
      first = false;
    }
    json.append("]");
    out.print(json.toString());
    
  } catch (Exception e) {
    response.setStatus(500);
    e.printStackTrace();
    String errorMsg = e.getMessage() != null ? e.getMessage() : e.getClass().getName();
    out.print("{\"error\":\"모델 조회 중 오류가 발생했습니다: " + escapeJson(errorMsg) + "\"}");
  }
%>
<%!
  private String escapeJson(String str) {
    if (str == null) return "";
    return str.replace("\\", "\\\\")
              .replace("\"", "\\\"")
              .replace("\n", "\\n")
              .replace("\r", "\\r")
              .replace("\t", "\\t");
  }
%>

