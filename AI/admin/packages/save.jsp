<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.PackageDAO" %>
<%@ page import="dao.PackageItemDAO" %>
<%@ page import="model.Package" %>
<%@ page import="model.PackageItem" %>
<%@ page import="java.math.BigDecimal" %>
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
  
  PackageDAO packageDAO = new PackageDAO();
  PackageItemDAO itemDAO = new PackageItemDAO();
  
  String idParam = request.getParameter("id");
  String title = request.getParameter("title");
  String description = request.getParameter("description");
  // price_usd 필드에서 가격 가져오기 (숫자만)
  String priceStr = request.getParameter("price_usd");
  if (priceStr == null || priceStr.trim().isEmpty()) {
    priceStr = request.getParameter("price"); // 하위 호환성
  }
  String discountPriceStr = request.getParameter("discount_price");
  String categoryIdStr = null;
  // category_ids[] 배열에서 첫 번째 값을 대표 카테고리로 사용 (하위 호환성)
  String[] categoryIds = request.getParameterValues("category_ids[]");
  if (categoryIds != null && categoryIds.length > 0 && !categoryIds[0].trim().isEmpty()) {
    categoryIdStr = categoryIds[0]; // 첫 번째 선택된 카테고리를 대표 카테고리로 사용
  } else {
    // 기존 category_id 파라미터도 확인 (하위 호환성)
    categoryIdStr = request.getParameter("category_id");
  }
  String activeStr = request.getParameter("active");
  
  // 입력 검증
  if (title == null || title.trim().isEmpty() || priceStr == null || priceStr.trim().isEmpty()) {
    out.println("<script>alert('패키지명과 가격을 입력해주세요.'); history.back();</script>");
    return;
  }
  
  try {
    Package pkg = new Package();
    
    if (idParam != null && !idParam.trim().isEmpty()) {
      pkg.setId(Integer.parseInt(idParam));
    }
    
    pkg.setTitle(title.trim());
    pkg.setDescription(description != null ? description.trim() : null);
    
    // USD 가격 (숫자만 추출)
    String priceValue = priceStr.replaceAll("[^0-9.]", "");
    if (priceValue.isEmpty()) {
      out.println("<script>alert('USD 가격을 올바르게 입력해주세요.'); history.back();</script>");
      return;
    }
    pkg.setPrice(new BigDecimal(priceValue));
    
    if (discountPriceStr != null && !discountPriceStr.trim().isEmpty()) {
      // USD 할인가 (숫자만 추출)
      String discountValue = discountPriceStr.replaceAll("[^0-9.]", "");
      if (!discountValue.isEmpty()) {
        pkg.setDiscountPrice(new BigDecimal(discountValue));
      }
    }
    
    if (categoryIdStr != null && !categoryIdStr.trim().isEmpty()) {
      pkg.setCategoryId(Integer.parseInt(categoryIdStr));
    }
    
    pkg.setActive("true".equals(activeStr));
    
    int packageId;
    if (pkg.getId() > 0) {
      // 수정
      if (packageDAO.update(pkg)) {
        packageId = pkg.getId();
        // 기존 아이템 삭제 후 재등록
        itemDAO.deleteByPackageId(packageId);
      } else {
        out.println("<script>alert('패키지 수정에 실패했습니다.'); history.back();</script>");
        return;
      }
    } else {
      // 신규 등록
      packageId = packageDAO.insert(pkg);
      if (packageId <= 0) {
        out.println("<script>alert('패키지 등록에 실패했습니다.'); history.back();</script>");
        return;
      }
    }
    
    // 패키지 아이템 저장
    String[] modelIds = request.getParameterValues("item_model_id[]");
    String[] quantities = request.getParameterValues("item_quantity[]");
    
    if (modelIds != null && quantities != null && modelIds.length == quantities.length) {
      for (int i = 0; i < modelIds.length; i++) {
        if (modelIds[i] != null && !modelIds[i].trim().isEmpty()) {
          PackageItem item = new PackageItem();
          item.setPackageId(packageId);
          item.setModelId(Integer.parseInt(modelIds[i]));
          item.setQuantity(Integer.parseInt(quantities[i]));
          itemDAO.insert(item);
        }
      }
    }
    
    // 패키지 카테고리 저장 (package_categories 테이블에 DELETE 후 INSERT)
    if (categoryIds != null && categoryIds.length > 0) {
      java.util.List<Integer> categoryIdList = new java.util.ArrayList<>();
      for (String catIdStr : categoryIds) {
        if (catIdStr != null && !catIdStr.trim().isEmpty()) {
          try {
            categoryIdList.add(Integer.parseInt(catIdStr.trim()));
          } catch (NumberFormatException e) {
            // 무시
          }
        }
      }
      if (!categoryIdList.isEmpty()) {
        packageDAO.saveCategories(packageId, categoryIdList);
      }
    } else {
      // 카테고리가 선택되지 않은 경우 기존 카테고리 삭제
      packageDAO.saveCategories(packageId, new java.util.ArrayList<>());
    }
    
    response.sendRedirect("/AI/admin/packages/index.jsp");
    
  } catch (Exception e) {
    e.printStackTrace();
    out.println("<script>alert('오류가 발생했습니다. 잠시 후 다시 시도해주세요.'); history.back();</script>");
  }
%>
