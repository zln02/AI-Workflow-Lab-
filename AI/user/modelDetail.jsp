<%@ page contentType="text/html; charset=UTF-8" buffer="64kb" autoFlush="true" %>
<%@ page import="dao.AIModelDAO" %>
<%@ page import="dao.PackageDAO" %>
<%@ page import="model.AIModel" %>
<%@ page import="model.Package" %>
<%@ page import="model.User" %>
<%@ page import="util.CSRFUtil" %>
<%@ page import="java.util.List" %>
<%
  request.setCharacterEncoding("UTF-8");
  response.setCharacterEncoding("UTF-8");
  
  String idParam = request.getParameter("id");
  AIModel model = null;
  if (idParam != null && !idParam.trim().isEmpty()) {
    try {
      int id = Integer.parseInt(idParam);
      AIModelDAO modelDAO = new AIModelDAO();
      model = modelDAO.findById(id);
    } catch (NumberFormatException e) {}
  }
  
  // 모델을 찾을 수 없으면 홈으로 리다이렉트
  if (model == null) {
    response.sendRedirect("/AI/user/home.jsp");
    return;
  }
  
  // 장바구니 추가 처리
  String action = request.getParameter("action");
  if ("addToCart".equals(action)) {
    @SuppressWarnings("unchecked")
    List<java.util.Map<String, Object>> cart = (List<java.util.Map<String, Object>>) session.getAttribute("cart");
    if (cart == null) {
      cart = new java.util.ArrayList<>();
      session.setAttribute("cart", cart);
    }
    
    // 중복 체크
    boolean exists = false;
    for (java.util.Map<String, Object> item : cart) {
      if ("MODEL".equals(item.get("type")) && item.get("id").equals(model.getId())) {
        int qty = (Integer) item.get("quantity");
        item.put("quantity", qty + 1);
        exists = true;
        break;
      }
    }
    
    if (!exists) {
      java.util.Map<String, Object> item = new java.util.HashMap<>();
      item.put("type", "MODEL");
      item.put("id", model.getId());
      item.put("quantity", 1);
      cart.add(item);
    }
    
    session.setAttribute("cart", cart);
    response.sendRedirect("/AI/user/cart.jsp");
    return;
  }
  
  // 바로 결제 처리
  if ("checkout".equals(action)) {
    @SuppressWarnings("unchecked")
    List<java.util.Map<String, Object>> cart = (List<java.util.Map<String, Object>>) session.getAttribute("cart");
    if (cart == null) {
      cart = new java.util.ArrayList<>();
    }
    
    // 중복 체크
    boolean exists = false;
    for (java.util.Map<String, Object> item : cart) {
      if ("MODEL".equals(item.get("type")) && item.get("id").equals(model.getId())) {
        exists = true;
        break;
      }
    }
    
    if (!exists) {
      java.util.Map<String, Object> item = new java.util.HashMap<>();
      item.put("type", "MODEL");
      item.put("id", model.getId());
      item.put("quantity", 1);
      cart.add(item);
      session.setAttribute("cart", cart);
    }
    
    response.sendRedirect("/AI/user/checkout.jsp");
    return;
  }
  
  PackageDAO packageDAO = new PackageDAO();
  List<Package> relatedPackages = packageDAO.findAll();
  if (relatedPackages.size() > 3) {
    relatedPackages = relatedPackages.subList(0, 3);
  }
  
  String csrfToken = CSRFUtil.getToken(session);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><%= model.getModelName() != null ? model.getModelName() : "Model" %> - AI Navigator</title>
  <link rel="stylesheet" href="/AI/assets/css/landing.css">
  <link rel="stylesheet" href="/AI/assets/css/user.css">
</head>
<body>
  <jsp:include page="/AI/partials/header.jsp"/>

  <!-- Model Detail Hero -->
  <section class="model-detail-hero">
    <div class="model-detail-image">
      <%
        String modelImage = "/AI/assets/img/placeholder.png";
        if (model.getModelName() != null && model.getModelName().toLowerCase().contains("gemini")) {
          modelImage = "/AI/assets/img/Gemini.png";
        }
      %>
      <img src="<%= modelImage %>" alt="<%= model.getModelName() != null ? model.getModelName() : "모델" %>" onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
      <div style="display: none; width: 100%; height: 100%; background: var(--surface); align-items: center; justify-content: center; font-size: 4rem;">🤖</div>
    </div>
    <h1 class="section-title" style="margin-bottom: 1rem;">
      <%= model.getModelName() != null ? model.getModelName() : "AI 모델" %>
    </h1>
    <p class="section-subtitle" style="margin-bottom: 2rem;">
      <%= model.getProviderName() != null ? model.getProviderName() : "제공업체" %>
      <% if (model.getCategoryName() != null) { %>
        · <%= model.getCategoryName() %>
      <% } %>
    </p>
    <div class="hero-actions">
      <form method="GET" action="/AI/user/modelDetail.jsp" style="display: inline;">
        <input type="hidden" name="id" value="<%= model.getId() %>">
        <input type="hidden" name="action" value="addToCart">
        <button type="submit" class="btn btn-primary">장바구니에 추가</button>
      </form>
      <form method="GET" action="/AI/user/modelDetail.jsp" style="display: inline;">
        <input type="hidden" name="id" value="<%= model.getId() %>">
        <input type="hidden" name="action" value="checkout">
        <button type="submit" class="btn btn-secondary">바로 결제하기</button>
      </form>
    </div>
  </section>

  <!-- Model Description -->
  <section class="section">
    <div style="max-width: 800px; margin: 0 auto;">
      <h2 style="font-size: 2rem; margin-bottom: 1.5rem; color: var(--text);">설명</h2>
      <p style="font-size: 1.125rem; color: var(--text-secondary); line-height: 1.8; margin-bottom: 2rem;">
        <%= model.getDescription() != null && !model.getDescription().isEmpty() 
            ? model.getDescription() 
            : (model.getPurposeSummary() != null ? model.getPurposeSummary() : "이 모델에 대한 설명이 없습니다.") %>
      </p>
    </div>
  </section>

  <!-- Model Specifications -->
  <section class="section">
    <h2 class="section-title">사양</h2>
    <div class="model-detail-specs">
      <div class="model-spec-card fade-in">
        <h3 class="model-spec-title">가격 및 이용 가능 여부</h3>
        <ul class="model-spec-list">
          <li>
            <strong>가격:</strong> 
            <%= model.getPrice() != null && !model.getPrice().isEmpty() ? model.getPrice() : "문의 필요" %>
          </li>
          <li>
            <strong>API 이용 가능:</strong> 
            <%= model.isApiAvailable() ? "가능" : "불가능" %>
          </li>
          <li>
            <strong>파인튜닝:</strong> 
            <%= model.isFinetuneAvailable() ? "가능" : "불가능" %>
          </li>
          <li>
            <strong>온프레미스:</strong> 
            <%= model.isOnpremAvailable() ? "가능" : "불가능" %>
          </li>
        </ul>
      </div>

      <div class="model-spec-card fade-in">
        <h3 class="model-spec-title">기능 및 사양</h3>
        <ul class="model-spec-list">
          <% if (model.getInputModalities() != null && !model.getInputModalities().isEmpty()) { %>
            <li><strong>입력 형식:</strong> <%= model.getInputModalities().replace(",", ", ") %></li>
          <% } %>
          <% if (model.getOutputModalities() != null && !model.getOutputModalities().isEmpty()) { %>
            <li><strong>출력 형식:</strong> <%= model.getOutputModalities().replace(",", ", ") %></li>
          <% } %>
          <% if (model.getParamsBillion() != null) { %>
            <li><strong>파라미터 수:</strong> <%= model.getParamsBillion() %>B (약 <%= String.format("%.0f", model.getParamsBillion().doubleValue() * 10) %>억 개)</li>
          <% } %>
          <% if (model.getLatencyMs() != null) { %>
            <li><strong>평균 응답 시간:</strong> <%= model.getLatencyMs() %>ms</li>
          <% } %>
          <% if (model.getRateLimitPerMin() != null && model.getRateLimitPerMin() > 0) { %>
            <li><strong>요청 속도 제한:</strong> 분당 <%= model.getRateLimitPerMin() %>회</li>
          <% } %>
          <% if (model.getLanguages() != null && !model.getLanguages().isEmpty()) { %>
            <li><strong>지원 언어:</strong> <%= model.getLanguages() %></li>
          <% } %>
          <% if (model.getMaxInputSizeMb() != null) { %>
            <li><strong>최대 입력 크기:</strong> <%= model.getMaxInputSizeMb() %>MB</li>
          <% } %>
          <% if (model.getSupportedFileTypes() != null && !model.getSupportedFileTypes().isEmpty()) { %>
            <li><strong>지원 파일 형식:</strong> <%= model.getSupportedFileTypes() %></li>
          <% } %>
          <% if (model.getHostingOptions() != null && !model.getHostingOptions().isEmpty()) { %>
            <li><strong>호스팅 옵션:</strong> <%= model.getHostingOptions().replace(",", ", ") %></li>
          <% } %>
          <% if (model.getLicenseType() != null && !model.getLicenseType().isEmpty()) { %>
            <li><strong>라이선스:</strong> 
              <% if ("FREE".equals(model.getLicenseType())) { %>무료
              <% } else if ("COMMERCIAL".equals(model.getLicenseType())) { %>상업용
              <% } else if ("OPEN_SOURCE".equals(model.getLicenseType())) { %>오픈소스
              <% } else if ("MIXED".equals(model.getLicenseType())) { %>혼합
              <% } else { %><%= model.getLicenseType() %><% } %>
            </li>
          <% } %>
          <% if (model.isCommercialUseAllowed()) { %>
            <li><strong>상업적 이용:</strong> 가능</li>
          <% } %>
          <% if (model.getBenchmarks() != null && !model.getBenchmarks().isEmpty()) { %>
            <li><strong>벤치마크 성능:</strong> <%= model.getBenchmarks() %></li>
          <% } %>
        </ul>
      </div>

      <div class="model-spec-card fade-in">
        <h3 class="model-spec-title">링크 및 리소스</h3>
        <ul class="model-spec-list">
          <% if (model.getHomepageUrl() != null && !model.getHomepageUrl().isEmpty()) { %>
            <li><a href="<%= model.getHomepageUrl() %>" target="_blank" style="color: var(--accent);">홈페이지</a></li>
          <% } %>
          <% if (model.getDocsUrl() != null && !model.getDocsUrl().isEmpty()) { %>
            <li><a href="<%= model.getDocsUrl() %>" target="_blank" style="color: var(--accent);">문서</a></li>
          <% } %>
          <% if (model.getPlaygroundUrl() != null && !model.getPlaygroundUrl().isEmpty()) { %>
            <li><a href="<%= model.getPlaygroundUrl() %>" target="_blank" style="color: var(--accent);">플레이그라운드</a></li>
          <% } %>
        </ul>
      </div>
    </div>
  </section>

  <!-- Related Packages -->
  <% if (!relatedPackages.isEmpty()) { %>
    <section class="section">
      <h2 class="section-title">포함된 패키지</h2>
      <p class="section-subtitle">이 모델이 포함된 패키지 목록</p>
      <div class="package-grid">
        <% for (Package pkg : relatedPackages) { %>
          <div class="package-card fade-in">
            <h3 class="package-card-title"><%= pkg.getTitle() != null ? pkg.getTitle() : "Package" %></h3>
            <p style="color: var(--text-secondary); margin: 1rem 0;">
              <%= pkg.getDescription() != null && pkg.getDescription().length() > 100 
                  ? pkg.getDescription().substring(0, 100) + "..." 
                  : (pkg.getDescription() != null ? pkg.getDescription() : "설명 없음") %>
            </p>
            <div class="package-card-price">
              <% 
                double priceUsd = pkg.getPrice() != null ? pkg.getPrice().doubleValue() : 0;
                long priceKrw = Math.round(priceUsd * 1350);
              %>
              <span style="font-size: 2rem; font-weight: 700; color: var(--accent);">
                <%= String.format("%,d", priceKrw) %>원
              </span><br>
              <span style="font-size: 1rem; color: var(--text-secondary);">
                ($<%= String.format("%.0f", priceUsd) %>/월)
              </span>
            </div>
            <div class="model-item-actions" style="margin-top: 1.5rem;">
              <a href="/AI/user/package.jsp?model_id=<%= model.getId() %>" class="btn btn-primary btn-sm">패키지 보기</a>
            </div>
          </div>
        <% } %>
      </div>
    </section>
  <% } %>

  <script src="/AI/assets/js/landing.js"></script>
  <jsp:include page="/AI/partials/footer.jsp"/>
</body>
</html>
