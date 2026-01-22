<%@ page contentType="application/json; charset=UTF-8" buffer="32kb" autoFlush="true" %>
<%@ page import="dao.PackageDAO" %>
<%@ page import="java.util.*" %>
<%
  response.setHeader("Access-Control-Allow-Origin", "*");
  response.setHeader("Access-Control-Allow-Methods", "GET");
  response.setHeader("Content-Type", "application/json; charset=UTF-8");
  
  String catsParam = request.getParameter("cats");
  List<Integer> categoryIds = new ArrayList<>();
  
  if (catsParam != null && !catsParam.trim().isEmpty()) {
    String[] catNames = catsParam.split(",");
    dao.CategoryDAO categoryDAO = new dao.CategoryDAO();
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
    PackageDAO packageDAO = new PackageDAO();
    List<model.Package> packages;
    
    if (categoryIds.isEmpty()) {
      packages = packageDAO.findAll();
    } else {
      // 다중 카테고리 필터링: 선택된 모든 카테고리를 포함하는 패키지만 반환
      packages = new ArrayList<>();
      var allPackages = packageDAO.findAll();
      
      for (var pkg : allPackages) {
        var pkgCategories = packageDAO.getCategoriesByPackageId(pkg.getId());
        
        // 패키지의 카테고리 ID 목록 생성
        List<Integer> pkgCategoryIds = new ArrayList<>();
        for (var pkgCat : pkgCategories) {
          pkgCategoryIds.add(pkgCat.getId());
        }
        
        // 선택된 모든 카테고리가 패키지에 포함되어 있는지 확인
        boolean allCategoriesMatched = true;
        for (Integer selectedCatId : categoryIds) {
          if (!pkgCategoryIds.contains(selectedCatId)) {
            allCategoriesMatched = false;
            break;
          }
        }
        
        // 선택된 모든 카테고리를 포함하는 패키지만 추가 (AND 조건)
        if (allCategoriesMatched && categoryIds.size() >= 1) {
          packages.add(pkg);
        }
      }
    }
    
    StringBuilder json = new StringBuilder("[");
    boolean first = true;
    for (var pkg : packages) {
      if (!first) json.append(",");
      json.append("{");
      json.append("\"id\":").append(pkg.getId()).append(",");
      json.append("\"title\":\"").append(escapeJson(pkg.getTitle() != null ? pkg.getTitle() : "")).append("\",");
      json.append("\"description\":\"").append(escapeJson(pkg.getDescription() != null ? pkg.getDescription() : "")).append("\",");
      
      // 가격 처리
      if (pkg.getPrice() != null) {
        json.append("\"price\":").append(pkg.getPrice().doubleValue()).append(",");
      } else {
        json.append("\"price\":0,");
      }
      
      if (pkg.getDiscountPrice() != null && pkg.getDiscountPrice().compareTo(java.math.BigDecimal.ZERO) > 0) {
        json.append("\"discountPrice\":").append(pkg.getDiscountPrice().doubleValue()).append(",");
      } else {
        json.append("\"discountPrice\":null,");
      }
      
      // 카테고리 목록
      var pkgCategories = packageDAO.getCategoriesByPackageId(pkg.getId());
      json.append("\"categories\":[");
      boolean catFirst = true;
      for (var cat : pkgCategories) {
        if (!catFirst) json.append(",");
        json.append("\"").append(escapeJson(cat.getCategoryName())).append("\"");
        catFirst = false;
      }
      json.append("]");
      
      json.append("}");
      first = false;
    }
    json.append("]");
    out.print(json.toString());
    
  } catch (Exception e) {
    response.setStatus(500);
    e.printStackTrace();
    out.print("{\"error\":\"패키지 조회 중 오류가 발생했습니다: " + escapeJson(e.getMessage()) + "\",\"stack\":\"" + escapeJson(e.getClass().getName()) + "\"}");
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

