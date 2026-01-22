<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.AIModelDAO" %>
<%@ page import="dao.PackageDAO" %>
<%@ page import="dao.SearchLogDAO" %>
<%@ page import="model.AIModel" %>
<%@ page import="model.Package" %>
<%@ page import="java.util.*" %>
<%
  request.setCharacterEncoding("UTF-8");
  
  String keyword = request.getParameter("keyword");
  String pageParam = request.getParameter("page");
  int currentPage = 1;
  int pageSize = 12;
  
  try {
    if (pageParam != null && !pageParam.trim().isEmpty()) {
      currentPage = Integer.parseInt(pageParam);
      if (currentPage < 1) currentPage = 1;
    }
  } catch (NumberFormatException e) {
    currentPage = 1;
  }
  
  AIModelDAO modelDAO = new AIModelDAO();
  PackageDAO packageDAO = new PackageDAO();
  SearchLogDAO searchLogDAO = new SearchLogDAO();
  
  List<AIModel> models = new ArrayList<>();
  List<Package> packages = new ArrayList<>();
  int totalResults = 0;
  
  if (keyword != null && !keyword.trim().isEmpty()) {
    keyword = keyword.trim();
    // Sanitize keyword for XSS prevention
    keyword = keyword.replace("<", "&lt;").replace(">", "&gt;");
    
    // Search models (simple LIKE search - can be enhanced)
    List<AIModel> allModels = modelDAO.findAll();
    for (AIModel model : allModels) {
      if (model.getModelName() != null && model.getModelName().toLowerCase().contains(keyword.toLowerCase())) {
        models.add(model);
      } else if (model.getDescription() != null && model.getDescription().toLowerCase().contains(keyword.toLowerCase())) {
        models.add(model);
      }
    }
    
    // Search packages
    List<Package> allPackages = packageDAO.findAll();
    for (Package pkg : allPackages) {
      if (pkg.getTitle() != null && pkg.getTitle().toLowerCase().contains(keyword.toLowerCase())) {
        packages.add(pkg);
      } else if (pkg.getDescription() != null && pkg.getDescription().toLowerCase().contains(keyword.toLowerCase())) {
        packages.add(pkg);
      }
    }
    
    totalResults = models.size() + packages.size();
    searchLogDAO.logSearch(keyword, totalResults);
    
    // Pagination for models
    int startIndex = (currentPage - 1) * pageSize;
    int endIndex = Math.min(startIndex + pageSize, models.size());
    if (startIndex < models.size()) {
      models = models.subList(startIndex, endIndex);
    } else {
      models = new ArrayList<>();
    }
  }
  
  int totalPages = (int) Math.ceil((double) totalResults / pageSize);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>검색 결과 - AI Navigator</title>
  <link rel="stylesheet" href="/AI/assets/css/user.css">
</head>
<body>
  <!-- Navbar -->
  <nav class="navbar" id="navbar">
    <div class="navbar-container">
      <a href="/AI/user/home.jsp" class="navbar-logo">AI Navigator</a>
      <ul class="navbar-menu" id="navbarMenu">
        <li><a href="/AI/user/home.jsp">모델</a></li>
        <li><a href="/AI/user/package.jsp">패키지</a></li>
        <li><a href="/AI/user/pricing.jsp">요금제</a></li>
        <li><a href="/AI/user/home.jsp#contact">문의</a></li>
      </ul>
      <button class="navbar-toggle" id="navbarToggle">☰</button>
    </div>
  </nav>

  <!-- Currency Toggle -->
  <div class="currency-toggle">
    <button type="button" data-currency="USD" aria-label="USD로 전환">USD</button>
    <button type="button" data-currency="KRW" aria-label="KRW로 전환">KRW</button>
  </div>

  <!-- Loading Overlay -->
  <div id="loading-overlay" class="loading-overlay">
    <div class="loading-spinner"></div>
  </div>

  <main>
    <section class="user-hero">
      <h1>검색 결과</h1>
      <% if (keyword != null && !keyword.isEmpty()) { %>
        <p>"<%= keyword %>"에 대한 검색 결과: <%= totalResults %>개</p>
      <% } else { %>
        <p>검색어를 입력해주세요.</p>
      <% } %>
    </section>

    <% if (keyword == null || keyword.isEmpty()) { %>
      <div class="glass-card" style="text-align: center; padding: 80px 40px; max-width: 600px; margin: 0 auto;">
        <p style="font-size: 21px; line-height: 1.381; color: var(--text-secondary); margin-bottom: 24px;">검색어를 입력해주세요.</p>
        <a href="/AI/user/home.jsp" class="btn primary">홈으로</a>
      </div>
    <% } else if (totalResults == 0) { %>
      <div class="glass-card" style="text-align: center; padding: 80px 40px; max-width: 600px; margin: 0 auto;">
        <p style="font-size: 21px; line-height: 1.381; color: var(--text-secondary); margin-bottom: 24px;">검색 결과가 없습니다.</p>
        <a href="/AI/user/home.jsp" class="btn primary">홈으로</a>
      </div>
    <% } else { %>
      <!-- Models Results -->
      <% if (!models.isEmpty()) { %>
        <section style="margin-bottom: 48px; text-align: center;">
          <h2 style="margin-bottom: 8px;">AI 모델 (<%= models.size() %>개)</h2>
          <div class="user-cards">
            <% for (AIModel model : models) { %>
              <div class="user-card glass-card">
                <%
                  String providerName = model.getProviderName() != null ? model.getProviderName().toLowerCase() : "";
                  String logoUrl = "/AI/assets/img/placeholder.png";
                  String logoLink = "#";
                  
                  // Provider별 로고 URL 매핑
                  if (providerName.contains("openai")) {
                    logoUrl = "https://cdn.simpleicons.org/openai/412991";
                    logoLink = "https://openai.com";
                  } else if (providerName.contains("google")) {
                    logoUrl = "https://cdn.simpleicons.org/google/4285F4";
                    logoLink = "https://google.com";
                  } else if (providerName.contains("anthropic") || providerName.contains("claude")) {
                    logoUrl = "https://cdn.simpleicons.org/anthropic/D97706";
                    logoLink = "https://anthropic.com";
                  } else if (providerName.contains("meta")) {
                    logoUrl = "https://cdn.simpleicons.org/meta/0081FB";
                    logoLink = "https://meta.com";
                  } else if (providerName.contains("microsoft")) {
                    logoUrl = "https://cdn.simpleicons.org/microsoft/0078D4";
                    logoLink = "https://microsoft.com";
                  } else if (providerName.contains("adobe")) {
                    logoUrl = "https://cdn.simpleicons.org/adobe/FF0000";
                    logoLink = "https://adobe.com";
                  } else if (providerName.contains("midjourney")) {
                    logoUrl = "https://cdn.simpleicons.org/midjourney/000000";
                    logoLink = "https://midjourney.com";
                  } else if (providerName.contains("stability")) {
                    logoUrl = "https://cdn.simpleicons.org/stabilityai/7575FF";
                    logoLink = "https://stability.ai";
                  } else if (providerName.contains("cohere")) {
                    logoUrl = "https://cdn.simpleicons.org/cohere/FA5C5C";
                    logoLink = "https://cohere.com";
                  } else if (providerName.contains("github")) {
                    logoUrl = "https://cdn.simpleicons.org/github/181717";
                    logoLink = "https://github.com";
                  } else if (providerName.contains("deepl")) {
                    logoUrl = "https://cdn.simpleicons.org/deepl/0F2C46";
                    logoLink = "https://deepl.com";
                  } else if (providerName.contains("elevenlabs")) {
                    logoUrl = "https://cdn.simpleicons.org/elevenlabs/000000";
                    logoLink = "https://elevenlabs.io";
                  } else if (providerName.contains("runway")) {
                    logoUrl = "https://cdn.simpleicons.org/runwayml/000000";
                    logoLink = "https://runwayml.com";
                  } else if (providerName.contains("perplexity")) {
                    logoUrl = "https://cdn.simpleicons.org/perplexity/AA00FF";
                    logoLink = "https://perplexity.ai";
                  } else if (model.getModelName() != null && model.getModelName().toLowerCase().contains("gemini")) {
                    logoUrl = "/AI/assets/img/Gemini.png";
                    logoLink = "https://deepmind.google/technologies/gemini/";
                  }
                %>
                <div style="width: 100%; height: 200px; background: var(--surface); border-radius: 12px; margin-bottom: 16px; display: flex; align-items: center; justify-content: center; overflow: hidden;">
                  <a href="<%= logoLink %>" target="_blank" rel="noopener noreferrer" style="display: block; width: 100%; height: 100%;">
                    <img src="<%= logoUrl %>" alt="<%= model.getProviderName() != null ? model.getProviderName() : "제공업체" %> 로고" style="width: 100%; height: 100%; object-fit: contain; padding: 20px;" onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                    <div style="display: none; width: 100%; height: 100%; align-items: center; justify-content: center; font-size: 3rem; color: var(--text-secondary);">🤖</div>
                  </a>
                </div>
                <h3><%= model.getModelName() != null ? model.getModelName().replace("<", "&lt;").replace(">", "&gt;") : "모델" %></h3>
                <p><%= model.getDescription() != null && model.getDescription().length() > 100 
                    ? model.getDescription().substring(0, 100).replace("<", "&lt;").replace(">", "&gt;") + "..." 
                    : (model.getDescription() != null ? model.getDescription().replace("<", "&lt;").replace(">", "&gt;") : "") %></p>
                <% if (model.getPriceUsd() != null) { %>
                  <p class="price-display" data-price-usd="<%= model.getPriceUsd().doubleValue() %>">
                    $<%= String.format("%.2f", model.getPriceUsd().doubleValue()) %>
                  </p>
                <% } %>
                <a href="/AI/user/modelDetail.jsp?id=<%= model.getId() %>" class="btn primary btn-sm">상세보기</a>
              </div>
            <% } %>
          </div>
        </section>
      <% } %>

      <!-- Packages Results -->
      <% if (!packages.isEmpty()) { %>
        <section style="margin-bottom: 3rem;">
          <h2>패키지 (<%= packages.size() %>개)</h2>
          <div class="user-cards">
            <% for (Package pkg : packages) { %>
              <div class="user-card glass-card">
                <h3><%= pkg.getTitle() != null ? pkg.getTitle().replace("<", "&lt;").replace(">", "&gt;") : "패키지" %></h3>
                <p><%= pkg.getDescription() != null && pkg.getDescription().length() > 100 
                    ? pkg.getDescription().substring(0, 100).replace("<", "&lt;").replace(">", "&gt;") + "..." 
                    : (pkg.getDescription() != null ? pkg.getDescription().replace("<", "&lt;").replace(">", "&gt;") : "") %></p>
                <% if (pkg.getFinalPrice() != null) { %>
                  <p class="price-display" data-price-usd="<%= pkg.getFinalPrice().doubleValue() %>">
                    $<%= String.format("%.2f", pkg.getFinalPrice().doubleValue()) %>
                  </p>
                <% } %>
                <a href="/AI/user/packageDetail.jsp?id=<%= pkg.getId() %>" class="btn primary btn-sm">상세보기</a>
              </div>
            <% } %>
          </div>
        </section>
      <% } %>

      <!-- Pagination -->
      <% if (totalPages > 1) { %>
        <div style="display: flex; justify-content: center; gap: 1rem; margin-top: 2rem;">
          <% if (currentPage > 1) { %>
            <a href="/AI/user/search.jsp?keyword=<%= java.net.URLEncoder.encode(keyword, "UTF-8") %>&page=<%= currentPage - 1 %>" 
               class="btn ghost">이전</a>
          <% } %>
          <span style="display: flex; align-items: center; padding: 0 1rem;">
            페이지 <%= currentPage %> / <%= totalPages %>
          </span>
          <% if (currentPage < totalPages) { %>
            <a href="/AI/user/search.jsp?keyword=<%= java.net.URLEncoder.encode(keyword, "UTF-8") %>&page=<%= currentPage + 1 %>" 
               class="btn ghost">다음</a>
          <% } %>
        </div>
      <% } %>
    <% } %>
  </main>

  <script src="/AI/assets/js/user.js"></script>
  <jsp:include page="/AI/partials/footer.jsp"/>
</body>
</html>

