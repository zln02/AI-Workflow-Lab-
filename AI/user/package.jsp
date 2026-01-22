<%@ page contentType="text/html; charset=UTF-8" buffer="64kb" autoFlush="true" %>
<%@ page isELIgnored="true" %>
<%@ page import="dao.PackageDAO" %>
<%@ page import="dao.CategoryDAO" %>
<%@ page import="dao.AIModelDAO" %>
<%@ page import="dao.SearchLogDAO" %>
<%@ page import="model.Package" %>
<%@ page import="model.Category" %>
<%@ page import="model.AIModel" %>
<%@ page import="java.util.List" %>
<%
  PackageDAO packageDAO = new PackageDAO();
  CategoryDAO categoryDAO = new CategoryDAO();
  AIModelDAO modelDAO = new AIModelDAO();
  SearchLogDAO searchLogDAO = new SearchLogDAO();
  
  String categoryIdParam = request.getParameter("category_id");
  String searchKeyword = request.getParameter("keyword");
  String idParam = request.getParameter("id");
  String modelIdParam = request.getParameter("model_id");
  List<Package> packages = new java.util.ArrayList<>(); // 초기 로드 시 빈 리스트
  List<Package> modelPackages = new java.util.ArrayList<>(); // 특정 모델이 포함된 패키지
  List<Category> categories = categoryDAO.findAll();
  
  // model_id 파라미터로 특정 모델이 포함된 패키지 찾기
  AIModel relatedModel = null;
  if (modelIdParam != null && !modelIdParam.trim().isEmpty()) {
    try {
      int modelId = Integer.parseInt(modelIdParam);
      relatedModel = modelDAO.findById(modelId);
      if (relatedModel != null) {
        modelPackages = packageDAO.findByModelId(modelId);
      }
    } catch (NumberFormatException e) {}
  }
  
  Package selectedPackage = null;
  if (idParam != null && !idParam.trim().isEmpty()) {
    try {
      int id = Integer.parseInt(idParam);
      selectedPackage = packageDAO.findById(id);
    } catch (NumberFormatException e) {}
  }
  
  // model_id가 있으면 모든 패키지 로드
  if (modelIdParam != null && !modelIdParam.trim().isEmpty()) {
    packages = packageDAO.findAll();
  } else if (categoryIdParam != null && !categoryIdParam.trim().isEmpty()) {
    // 카테고리 선택 시 해당 카테고리의 패키지만 로드
    try {
      int categoryId = Integer.parseInt(categoryIdParam);
      packages = packageDAO.findByCategory(categoryId);
      if (packages == null) {
        packages = new java.util.ArrayList<>();
      }
      Category cat = categoryDAO.findById(categoryId);
      if (cat != null) {
        searchLogDAO.logSearch(cat.getCategoryName(), packages.size());
      }
    } catch (NumberFormatException e) {
      packages = new java.util.ArrayList<>();
    } catch (Exception e) {
      e.printStackTrace();
      packages = new java.util.ArrayList<>();
    }
  } else if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
    packages = packageDAO.findAll();
    searchLogDAO.logSearch(searchKeyword, packages.size());
  } else {
    // 초기 로드 시 모든 활성 패키지 로드
    packages = packageDAO.findAll();
  }
  
  // 디버깅: 패키지 리스트가 null이면 빈 리스트로 초기화
  if (packages == null) {
    packages = new java.util.ArrayList<>();
  }
  
  // 패키지 카테고리 일괄 조회 (N+1 쿼리 문제 해결)
  java.util.Map<Integer, List<Category>> packageCategoriesMap = new java.util.HashMap<>();
  if (!packages.isEmpty()) {
    java.util.List<Integer> packageIds = new java.util.ArrayList<>();
    for (Package pkg : packages) {
      packageIds.add(pkg.getId());
    }
    packageCategoriesMap = packageDAO.getCategoriesByPackageIds(packageIds);
  }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>패키지 - AI Navigator</title>
  <link rel="stylesheet" href="/AI/assets/css/user.css">
  <link rel="stylesheet" href="/AI/assets/css/animations.css">
</head>
<body>
  <!-- Navbar -->
  <nav class="navbar" id="navbar">
    <div class="navbar-container">
      <a href="/AI/user/home.jsp" class="navbar-logo">AI Navigator</a>
      <ul class="navbar-menu" id="navbarMenu">
        <li><a href="/AI/user/models.jsp">모델</a></li>
        <li><a href="/AI/user/package.jsp" class="active">패키지</a></li>
        <li><a href="/AI/user/pricing.jsp">요금제</a></li>
        <li><a href="/AI/user/home.jsp#contact">문의</a></li>
        <%
          model.User currentUser = (model.User) session.getAttribute("user");
          if (currentUser != null && currentUser.isActive()) {
        %>
          <li><a href="/AI/user/mypage.jsp">마이페이지</a></li>
          <li><a href="/AI/user/logout.jsp">로그아웃</a></li>
        <% } else { %>
          <li><a href="/AI/user/login.jsp">로그인</a></li>
          <li><a href="/AI/user/signup.jsp">회원가입</a></li>
        <% } %>
      </ul>
      <button class="navbar-toggle" id="navbarToggle">☰</button>
    </div>
  </nav>

  <!-- Currency Toggle -->
  <div class="currency-toggle">
    <button type="button" data-currency="USD" aria-label="USD로 전환">USD</button>
    <button type="button" data-currency="KRW" aria-label="KRW로 전환">KRW</button>
  </div>

  <main style="width: min(980px, 100%); margin: 0 auto; padding: 80px 22px;">
    <!-- Hero Section -->
    <section class="user-hero">
      <h1>패키지 선택</h1>
      <p>특정 비즈니스 요구사항에 맞춘 사전 구성된 AI 모델 번들입니다. 패키지를 선택하거나 직접 맞춤 솔루션을 구성하세요.</p>
    </section>

    <!-- Category Filter -->
    <section style="text-align: center; margin-bottom: 60px;">
      <h2 style="margin-bottom: 20px;">카테고리별 탐색</h2>
      <p style="color: var(--text-secondary); font-size: 14px; margin-bottom: 16px;">카테고리를 선택하세요 (최대 2개까지 선택 가능)</p>
      <div id="catChips" style="display: flex; gap: 8px; justify-content: center; flex-wrap: wrap; min-height: 40px;">
        <% for (Category cat : categories) { %>
          <button class="btn secondary cat-chip" data-cat-name="<%= cat.getCategoryName() %>" data-cat-id="<%= cat.getId() %>" style="margin: 4px;">
            <%= cat.getCategoryName() %>
          </button>
        <% } %>
      </div>
    </section>

    <!-- Model-specific Packages Section (if model_id parameter exists) -->
    <% if (relatedModel != null && !modelPackages.isEmpty()) { %>
      <section style="margin-bottom: 60px;">
        <h2 style="margin-bottom: 8px; font-size: 32px; line-height: 1.125; font-weight: 600; text-align: center;">
          <%= relatedModel.getModelName() != null ? relatedModel.getModelName() : "모델" %>이 포함된 패키지
        </h2>
        <p style="text-align: center; color: var(--text-secondary); margin-bottom: 24px;">
          다음 패키지에서 이 모델을 이용할 수 있습니다
        </p>
        <div class="user-cards" style="display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 24px;">
          <% for (Package pkg : modelPackages) { %>
            <div class="user-card glass-card" style="display: flex; flex-direction: column;">
              <h3 style="margin-bottom: 12px; font-size: 24px; line-height: 1.16667; font-weight: 600;"><%= pkg.getTitle() != null ? pkg.getTitle() : "패키지" %></h3>
              <% 
                List<Category> pkgCategories = packageDAO.getCategoriesByPackageId(pkg.getId());
              %>
              <% if (pkgCategories != null && !pkgCategories.isEmpty()) { %>
                <div style="display: flex; gap: 6px; flex-wrap: wrap; margin-bottom: 16px;">
                  <% for (Category cat : pkgCategories) { %>
                    <span style="background: var(--surface); color: var(--text); padding: 4px 12px; border-radius: 12px; font-size: 12px; line-height: 1.33337;"><%= cat.getCategoryName() %></span>
                  <% } %>
                </div>
              <% } %>
              <p style="color: var(--text-secondary); margin: 16px 0; line-height: 1.47059; font-size: 17px;">
                <%= pkg.getDescription() != null && pkg.getDescription().length() > 150 
                    ? pkg.getDescription().substring(0, 150) + "..." 
                    : (pkg.getDescription() != null ? pkg.getDescription() : "설명 없음") %>
              </p>
              <div style="margin: 20px 0;">
                <% 
                  double priceUsd = pkg.getPrice() != null ? pkg.getPrice().doubleValue() : 0;
                  long priceKrw = Math.round(priceUsd * 1350);
                  double discountUsd = pkg.getDiscountPrice() != null && pkg.getDiscountPrice().compareTo(java.math.BigDecimal.ZERO) > 0 
                      ? pkg.getDiscountPrice().doubleValue() : 0;
                  long discountKrw = Math.round(discountUsd * 1350);
                %>
                <% if (discountUsd > 0) { %>
                  <div class="original-price-display" style="text-decoration: line-through; color: var(--text-secondary); font-size: 14px; margin-bottom: 8px;" data-price-usd="<%= priceUsd %>">
                    <%= String.format("%,d", priceKrw) %>원 ($<%= String.format("%.0f", priceUsd) %>/월)
                  </div>
                  <div class="price-display" style="color: #ff3b30; font-size: 32px; line-height: 1.125; font-weight: 600; margin-bottom: 8px;" data-price-usd="<%= discountUsd %>">
                    <%= String.format("%,d", discountKrw) %>원
                  </div>
                  <div class="price-display-usd" style="font-size: 14px; color: var(--text-secondary);" data-price-usd="<%= discountUsd %>">
                    ($<%= String.format("%.0f", discountUsd) %>/월)
                  </div>
                <% } else { %>
                  <div class="price-display" style="font-size: 32px; line-height: 1.125; font-weight: 600; margin-bottom: 8px;" data-price-usd="<%= priceUsd %>">
                    <%= String.format("%,d", priceKrw) %>원
                  </div>
                  <div class="price-display-usd" style="font-size: 14px; color: var(--text-secondary);" data-price-usd="<%= priceUsd %>">
                    ($<%= String.format("%.0f", priceUsd) %>/월)
                  </div>
                <% } %>
              </div>
              <div style="display: flex; gap: 8px; justify-content: center; margin-top: auto; padding-top: 24px;">
                <a href="/AI/user/packageDetail.jsp?id=<%= pkg.getId() %>" class="btn primary btn-sm">상세보기</a>
                <a href="/AI/user/packageDetail.jsp?id=<%= pkg.getId() %>&action=addToCart" class="btn secondary btn-sm">장바구니</a>
              </div>
            </div>
          <% } %>
        </div>
      </section>
    <% } %>

    <!-- All Packages Section -->
    <section class="results-section" style="margin-bottom: 80px;">
      <% if (relatedModel != null && !modelPackages.isEmpty()) { %>
        <h2 style="margin-bottom: 24px; font-size: 32px; line-height: 1.125; font-weight: 600; text-align: center;">전체 패키지</h2>
      <% } %>
      <!-- Packages Section -->
      <div>
        <% if (relatedModel == null || modelPackages.isEmpty()) { %>
          <h2 style="margin-bottom: 24px; font-size: 32px; line-height: 1.125; font-weight: 600; text-align: center;">패키지</h2>
        <% } %>
        <div id="pkgGrid" class="user-cards pack-grid" style="display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 24px;">
          <% if (packages.isEmpty() && (modelIdParam == null || modelIdParam.trim().isEmpty())) { %>
            <div class="glass-card" style="text-align: center; padding: 80px 40px; max-width: 600px; margin: 0 auto; grid-column: 1 / -1;">
              <h2 style="margin-bottom: 12px;">패키지가 없습니다</h2>
              <p style="color: var(--text-secondary); font-size: 17px; line-height: 1.47059;">
                새로운 패키지를 기다려주세요.
              </p>
            </div>
          <% } else { %>
            <% for (Package pkg : packages) { %>
              <div class="user-card glass-card" style="display: flex; flex-direction: column;">
                <h3 style="margin-bottom: 12px; font-size: 24px; line-height: 1.16667; font-weight: 600;"><%= pkg.getTitle() != null ? pkg.getTitle() : "패키지" %></h3>
                <% 
                  List<Category> pkgCategories = packageCategoriesMap.get(pkg.getId());
                  if (pkgCategories == null) {
                    pkgCategories = new java.util.ArrayList<>();
                  }
                %>
                <% if (pkgCategories != null && !pkgCategories.isEmpty()) { %>
                  <div style="display: flex; gap: 6px; flex-wrap: wrap; margin-bottom: 16px;">
                    <% for (Category cat : pkgCategories) { %>
                      <span style="background: var(--surface); color: var(--text); padding: 4px 12px; border-radius: 12px; font-size: 12px; line-height: 1.33337;"><%= cat.getCategoryName() %></span>
                    <% } %>
                  </div>
                <% } %>
                <p style="color: var(--text-secondary); margin: 16px 0; line-height: 1.47059; font-size: 17px;">
                  <%= pkg.getDescription() != null && pkg.getDescription().length() > 150 
                      ? pkg.getDescription().substring(0, 150) + "..." 
                      : (pkg.getDescription() != null ? pkg.getDescription() : "설명 없음") %>
                </p>
                <div style="margin: 20px 0;">
                  <% 
                    double priceUsd = pkg.getPrice() != null ? pkg.getPrice().doubleValue() : 0;
                    long priceKrw = Math.round(priceUsd * 1350);
                    double discountUsd = pkg.getDiscountPrice() != null && pkg.getDiscountPrice().compareTo(java.math.BigDecimal.ZERO) > 0 
                        ? pkg.getDiscountPrice().doubleValue() : 0;
                    long discountKrw = Math.round(discountUsd * 1350);
                  %>
                  <% if (discountUsd > 0) { %>
                    <div class="original-price-display" style="text-decoration: line-through; color: var(--text-secondary); font-size: 14px; margin-bottom: 8px;" data-price-usd="<%= priceUsd %>">
                      <%= String.format("%,d", priceKrw) %>원 ($<%= String.format("%.0f", priceUsd) %>/월)
                    </div>
                    <div class="price-display" style="color: #ff3b30; font-size: 32px; line-height: 1.125; font-weight: 600; margin-bottom: 8px;" data-price-usd="<%= discountUsd %>">
                      <%= String.format("%,d", discountKrw) %>원
                    </div>
                    <div class="price-display-usd" style="font-size: 14px; color: var(--text-secondary);" data-price-usd="<%= discountUsd %>">
                      ($<%= String.format("%.0f", discountUsd) %>/월)
                    </div>
                  <% } else { %>
                    <div class="price-display" style="font-size: 32px; line-height: 1.125; font-weight: 600; margin-bottom: 8px;" data-price-usd="<%= priceUsd %>">
                      <%= String.format("%,d", priceKrw) %>원
                    </div>
                    <div class="price-display-usd" style="font-size: 14px; color: var(--text-secondary);" data-price-usd="<%= priceUsd %>">
                      ($<%= String.format("%.0f", priceUsd) %>/월)
                    </div>
                  <% } %>
                </div>
                <div style="display: flex; gap: 8px; justify-content: center; margin-top: auto; padding-top: 24px;">
                  <a href="/AI/user/packageDetail.jsp?id=<%= pkg.getId() %>" class="btn primary btn-sm">상세보기</a>
                  <a href="/AI/user/packageDetail.jsp?id=<%= pkg.getId() %>&action=addToCart" class="btn secondary btn-sm">장바구니</a>
                </div>
              </div>
            <% } %>
          <% } %>
        </div>
      </div>
    </section>

    <!-- Original Package List (Hidden, for fallback) - 카테고리 선택 시에만 동적으로 표시됨 -->
    <section style="display: none !important; visibility: hidden; position: absolute; top: -9999px; left: -9999px;">
      <% if (packages == null || packages.isEmpty()) { %>
        <div class="glass-card" style="text-align: center; padding: 80px 40px; max-width: 600px; margin: 0 auto;">
          <h2 style="margin-bottom: 12px;">패키지가 없습니다</h2>
          <p style="color: var(--text-secondary); font-size: 17px; line-height: 1.47059;">
            새로운 패키지를 기다려주세요.
          </p>
        </div>
      <% } else { %>
        <div class="user-cards" id="originalPkgGrid">
          <% for (Package pkg : packages) { %>
            <div class="user-card glass-card" style="display: flex; flex-direction: column;">
              <h3 style="margin-bottom: 12px; font-size: 24px; line-height: 1.16667; font-weight: 600;"><%= pkg.getTitle() != null ? pkg.getTitle() : "패키지" %></h3>
              <% 
                List<Category> pkgCategories = packageDAO.getCategoriesByPackageId(pkg.getId());
              %>
              <% if (pkgCategories != null && !pkgCategories.isEmpty()) { %>
                <div style="display: flex; gap: 6px; flex-wrap: wrap; margin-bottom: 16px;">
                  <% for (Category cat : pkgCategories) { %>
                    <span style="background: var(--surface); color: var(--text); padding: 4px 12px; border-radius: 12px; font-size: 12px; line-height: 1.33337;"><%= cat.getCategoryName() %></span>
                  <% } %>
                </div>
              <% } %>
              <p style="color: var(--text-secondary); margin: 16px 0; line-height: 1.47059; font-size: 17px;">
                <%= pkg.getDescription() != null && pkg.getDescription().length() > 150 
                    ? pkg.getDescription().substring(0, 150) + "..." 
                    : (pkg.getDescription() != null ? pkg.getDescription() : "설명 없음") %>
              </p>
              <div style="margin: 20px 0;">
                <% 
                  double priceUsd = pkg.getPrice() != null ? pkg.getPrice().doubleValue() : 0;
                  long priceKrw = Math.round(priceUsd * 1350);
                  double discountUsd = pkg.getDiscountPrice() != null && pkg.getDiscountPrice().compareTo(java.math.BigDecimal.ZERO) > 0 
                      ? pkg.getDiscountPrice().doubleValue() : 0;
                  long discountKrw = Math.round(discountUsd * 1350);
                %>
                <% if (discountUsd > 0) { %>
                  <div class="original-price-display" style="text-decoration: line-through; color: var(--text-secondary); font-size: 14px; margin-bottom: 8px;" data-price-usd="<%= priceUsd %>">
                    <%= String.format("%,d", priceKrw) %>원 ($<%= String.format("%.0f", priceUsd) %>/월)
                  </div>
                  <div class="price-display" style="color: #ff3b30; font-size: 32px; line-height: 1.125; font-weight: 600; margin-bottom: 8px;" data-price-usd="<%= discountUsd %>">
                    <%= String.format("%,d", discountKrw) %>원
                  </div>
                  <div class="price-display-usd" style="font-size: 14px; color: var(--text-secondary);" data-price-usd="<%= discountUsd %>">
                    ($<%= String.format("%.0f", discountUsd) %>/월)
                  </div>
                <% } else { %>
                  <div class="price-display" style="font-size: 32px; line-height: 1.125; font-weight: 600; margin-bottom: 8px;" data-price-usd="<%= priceUsd %>">
                    <%= String.format("%,d", priceKrw) %>원
                  </div>
                  <div class="price-display-usd" style="font-size: 14px; color: var(--text-secondary);" data-price-usd="<%= priceUsd %>">
                    ($<%= String.format("%.0f", priceUsd) %>/월)
                  </div>
                <% } %>
              </div>
              <div style="display: flex; gap: 8px; justify-content: center; margin-top: auto; padding-top: 24px;">
                <a href="/AI/user/packageDetail.jsp?id=<%= pkg.getId() %>" class="btn primary btn-sm">상세보기</a>
                <a href="/AI/user/packageDetail.jsp?id=<%= pkg.getId() %>&action=addToCart" class="btn secondary btn-sm">장바구니</a>
              </div>
            </div>
          <% } %>
        </div>
      <% } %>
    </section>

    <!-- Package Detail (if selected) -->
    <% if (selectedPackage != null) { %>
      <section style="text-align: center; margin-top: 80px;">
        <div class="glass-card" style="max-width: 900px; margin: 0 auto; padding: 60px 40px;">
          <h2 style="margin-bottom: 20px;">
            <%= selectedPackage.getTitle() != null ? selectedPackage.getTitle() : "패키지 상세" %>
          </h2>
          <p style="font-size: 21px; line-height: 1.381; color: var(--text-secondary); margin-bottom: 40px;">
            <%= selectedPackage.getDescription() != null ? selectedPackage.getDescription() : "설명 없음" %>
          </p>
          <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 40px; margin-top: 40px; margin-bottom: 40px;">
            <div>
              <h3 style="color: var(--accent); margin-bottom: 12px; font-size: 17px; line-height: 1.47059;">가격</h3>
              <% 
                double priceUsd = selectedPackage.getPrice() != null ? selectedPackage.getPrice().doubleValue() : 0;
                long priceKrw = Math.round(priceUsd * 1350);
                double discountUsd = selectedPackage.getDiscountPrice() != null && selectedPackage.getDiscountPrice().compareTo(java.math.BigDecimal.ZERO) > 0 
                    ? selectedPackage.getDiscountPrice().doubleValue() : 0;
                long discountKrw = Math.round(discountUsd * 1350);
              %>
              <% if (discountUsd > 0) { %>
                <p style="text-decoration: line-through; color: var(--text-secondary); font-size: 14px; margin-bottom: 8px;">
                  <%= String.format("%,d", priceKrw) %>원 ($<%= String.format("%.0f", priceUsd) %>/월)
                </p>
                <p class="price-display" style="font-size: 32px; line-height: 1.125; font-weight: 600; color: #ff3b30; margin-bottom: 8px;">
                  <%= String.format("%,d", discountKrw) %>원
                </p>
                <p style="color: var(--text-secondary); font-size: 14px;">
                  ($<%= String.format("%.0f", discountUsd) %>/월)
                </p>
              <% } else { %>
                <p class="price-display" style="font-size: 32px; line-height: 1.125; font-weight: 600; margin-bottom: 8px;">
                  <%= String.format("%,d", priceKrw) %>원
                </p>
                <p style="color: var(--text-secondary); font-size: 14px;">
                  ($<%= String.format("%.0f", priceUsd) %>/월)
                </p>
              <% } %>
            </div>
            <% 
              List<Category> pkgCategories = packageDAO.getCategoriesByPackageId(selectedPackage.getId());
            %>
            <% if (pkgCategories != null && !pkgCategories.isEmpty()) { %>
              <div>
                <h3 style="color: var(--accent); margin-bottom: 12px; font-size: 17px; line-height: 1.47059;">카테고리</h3>
                <div style="display: flex; gap: 6px; flex-wrap: wrap;">
                  <% for (Category cat : pkgCategories) { %>
                    <span style="background: var(--surface); color: var(--text); padding: 4px 12px; border-radius: 12px; font-size: 12px; line-height: 1.33337;"><%= cat.getCategoryName() %></span>
                  <% } %>
                </div>
              </div>
            <% } %>
          </div>
          <div style="margin-top: 40px;">
            <a href="/AI/user/packageDetail.jsp?id=<%= selectedPackage.getId() %>&action=addToCart" class="btn primary">장바구니에 추가</a>
          </div>
        </div>
      </section>
    <% } %>
  </main>
  
  <script src="/AI/assets/js/user.js"></script>
  <script type="module">
    import { toast } from '/AI/assets/js/toast.js';

    const catChipsContainer = document.getElementById('catChips');
    const pkgGrid = document.getElementById('pkgGrid');
    const selectedCats = new Set();

    // 카테고리 목록 가져오기 및 렌더링
    async function loadCategories() {
      try {
        const response = await fetch('/AI/api/categories.jsp');
        const categories = await response.json();
        
        categories.forEach(cat => {
          const chip = document.createElement('button');
          chip.className = 'btn secondary cat-chip';
          chip.textContent = cat.name;
          chip.dataset.catName = cat.name;
          chip.dataset.catId = cat.id;
          
          chip.addEventListener('click', () => {
            toggleCategory(cat.name, chip);
          });
          
          catChipsContainer.appendChild(chip);
        });
      } catch (error) {
        console.error('카테고리 로드 실패:', error);
        toast('카테고리를 불러올 수 없습니다', 'error');
      }
    }

    function toggleCategory(catName, chip) {
      if (selectedCats.has(catName)) {
        // 이미 선택된 카테고리면 해제
        selectedCats.delete(catName);
        chip.classList.remove('primary');
        chip.classList.add('secondary');
      } else {
        // 최대 2개까지만 선택 가능
        if (selectedCats.size >= 2) {
          toast('카테고리는 최대 2개까지 선택할 수 있습니다', 'error');
          return;
        }
        selectedCats.add(catName);
        chip.classList.remove('secondary');
        chip.classList.add('primary');
      }
      updateModelsAndPackages();
    }

    async function updateModelsAndPackages() {
      const modelGrid = document.getElementById('modelGrid');
      const pkgGrid = document.getElementById('pkgGrid');
      
      if (selectedCats.size < 1) {
        modelGrid.innerHTML = '';
        pkgGrid.classList.add('locked');
        pkgGrid.innerHTML = '<div class="lock-overlay">카테고리를 선택하세요.</div>';
        return;
      }

      // 카테고리 1개 이상 선택 시 결과 표시
      pkgGrid.classList.remove('locked');
      modelGrid.innerHTML = '<div class="loading-shimmer" style="height: 300px; border-radius: 12px; grid-column: 1 / -1;"></div>';
      pkgGrid.innerHTML = '<div class="loading-shimmer" style="height: 300px; border-radius: 12px;"></div>';

      try {
        const catsParam = Array.from(selectedCats).map(encodeURIComponent).join(',');
        console.log('선택된 카테고리:', Array.from(selectedCats));
        console.log('API 요청 파라미터:', catsParam);
        
        // 모델과 패키지를 동시에 로드
        const [modelsResponse, packagesResponse] = await Promise.all([
          fetch(`/AI/api/models.jsp?cat=${catsParam}`),
          fetch(`/AI/api/packages.jsp?cats=${catsParam}`)
        ]);
        
        let models, packages;
        
        // JSON 파싱 시 에러 처리
        try {
          const modelsText = await modelsResponse.text();
          console.log('모델 API 응답:', modelsText.substring(0, 200));
          if (modelsResponse.ok) {
            models = JSON.parse(modelsText);
          } else {
            console.error('모델 API 오류:', modelsResponse.status, modelsText);
            models = [];
          }
        } catch (e) {
          console.error('모델 JSON 파싱 오류:', e);
          models = [];
        }
        
        try {
          const packagesText = await packagesResponse.text();
          console.log('패키지 API 응답:', packagesText.substring(0, 200));
          if (packagesResponse.ok) {
            packages = JSON.parse(packagesText);
          } else {
            console.error('패키지 API 오류:', packagesResponse.status, packagesText);
            packages = [];
          }
        } catch (e) {
          console.error('패키지 JSON 파싱 오류:', e);
          packages = [];
        }
        
        // 에러 응답 체크
        if (models && typeof models === 'object' && models.error) {
          console.error('모델 API 오류:', models.error);
          models = [];
        }
        if (packages && typeof packages === 'object' && packages.error) {
          console.error('패키지 API 오류:', packages.error);
          packages = [];
        }
        
        // 배열이 아닌 경우 빈 배열로 변환
        if (!Array.isArray(models)) {
          console.warn('모델 데이터가 배열이 아닙니다:', typeof models, models);
          models = [];
        }
        if (!Array.isArray(packages)) {
          console.warn('패키지 데이터가 배열이 아닙니다:', typeof packages, packages);
          packages = [];
        }
        
        console.log('로드된 모델 수:', models ? models.length : 0);
        console.log('로드된 패키지 수:', packages ? packages.length : 0);
        console.log('모델 데이터 샘플:', models && models.length > 0 ? models[0] : '없음');
        console.log('패키지 데이터 샘플:', packages && packages.length > 0 ? packages[0] : '없음');
        
        // 모델 렌더링
        if (!models || !Array.isArray(models) || models.length === 0) {
          modelGrid.innerHTML = '<div class="glass-card" style="text-align: center; padding: 40px; grid-column: 1 / -1;"><p style="color: var(--text-secondary);">해당 카테고리의 모델이 없습니다.</p></div>';
        } else {
          modelGrid.innerHTML = models.map(model => {
            const price = model.priceUsd ? '$' + model.priceUsd.toFixed(2) : (model.price || '무료 / 문의');
            const modelName = escapeHtml(model.name || '모델명 없음');
            const providerName = escapeHtml(model.providerName || '제공업체');
            const categoryName = escapeHtml(model.categoryName || '');
            const description = escapeHtml((model.description || model.purposeSummary || '설명 없음').substring(0, 150));
            const descSuffix = (model.description || model.purposeSummary || '').length > 150 ? '...' : '';
            const escapedPrice = escapeHtml(price);
            
            // Provider별 로고 URL 매핑
            function getProviderLogo(providerName, modelName) {
              if (!providerName) return { logo: '/AI/assets/img/placeholder.png', link: '#' };
              
              const provider = providerName.toLowerCase();
              const model = (modelName || '').toLowerCase();
              
              if (provider.includes('openai')) {
                return { logo: 'https://cdn.simpleicons.org/openai/412991', link: 'https://openai.com' };
              } else if (provider.includes('google') || model.includes('gemini')) {
                return { logo: 'https://cdn.simpleicons.org/google/4285F4', link: 'https://google.com' };
              } else if (provider.includes('anthropic') || provider.includes('claude')) {
                return { logo: 'https://cdn.simpleicons.org/anthropic/D97706', link: 'https://anthropic.com' };
              } else if (provider.includes('meta')) {
                return { logo: 'https://cdn.simpleicons.org/meta/0081FB', link: 'https://meta.com' };
              } else if (provider.includes('microsoft')) {
                return { logo: 'https://cdn.simpleicons.org/microsoft/0078D4', link: 'https://microsoft.com' };
              } else if (provider.includes('adobe')) {
                return { logo: 'https://cdn.simpleicons.org/adobe/FF0000', link: 'https://adobe.com' };
              } else if (provider.includes('midjourney')) {
                return { logo: 'https://cdn.simpleicons.org/midjourney/000000', link: 'https://midjourney.com' };
              } else if (provider.includes('stability')) {
                return { logo: 'https://cdn.simpleicons.org/stabilityai/7575FF', link: 'https://stability.ai' };
              } else if (provider.includes('cohere')) {
                return { logo: 'https://cdn.simpleicons.org/cohere/FA5C5C', link: 'https://cohere.com' };
              } else if (provider.includes('github')) {
                return { logo: 'https://cdn.simpleicons.org/github/181717', link: 'https://github.com' };
              } else if (provider.includes('deepl')) {
                return { logo: 'https://cdn.simpleicons.org/deepl/0F2C46', link: 'https://deepl.com' };
              } else if (provider.includes('elevenlabs')) {
                return { logo: 'https://cdn.simpleicons.org/elevenlabs/000000', link: 'https://elevenlabs.io' };
              } else if (provider.includes('runway')) {
                return { logo: 'https://cdn.simpleicons.org/runwayml/000000', link: 'https://runwayml.com' };
              } else if (provider.includes('perplexity')) {
                return { logo: 'https://cdn.simpleicons.org/perplexity/AA00FF', link: 'https://perplexity.ai' };
              }
              
              return { logo: '/AI/assets/img/placeholder.png', link: '#' };
            }
            
            const providerLogo = getProviderLogo(model.providerName, model.name);
            
            return 
              '<div class="user-card glass-card" style="display: flex; flex-direction: column;">' +
                '<div style="width: 100%; height: 200px; background: var(--surface); border-radius: 12px; margin-bottom: 16px; display: flex; align-items: center; justify-content: center; overflow: hidden; position: relative;">' +
                  '<a href="' + providerLogo.link + '" target="_blank" rel="noopener noreferrer" style="display: block; width: 100%; height: 100%;">' +
                    '<img src="' + providerLogo.logo + '" alt="' + providerName + ' 로고" style="width: 100%; height: 100%; object-fit: contain; padding: 20px;" onerror="this.style.display=\'none\'; this.nextElementSibling.style.display=\'flex\';" />' +
                    '<div class="model-fallback-icon" style="display: none; width: 100%; height: 100%; align-items: center; justify-content: center; font-size: 3rem; color: var(--text-secondary);">🤖</div>' +
                  '</a>' +
                '</div>' +
                '<h3 style="margin-bottom: 8px; font-size: 24px; line-height: 1.16667; font-weight: 600;">' + modelName + '</h3>' +
                '<p style="color: var(--text-secondary); font-size: 14px; margin-bottom: 12px;">' + providerName + (categoryName ? ' · ' + categoryName : '') + '</p>' +
                '<p style="color: var(--text-secondary); margin: 16px 0; line-height: 1.47059; font-size: 17px; flex-grow: 1;">' +
                  description + descSuffix +
                '</p>' +
                '<div style="margin: 20px 0;">' +
                  '<div class="price-display" style="font-size: 21px; line-height: 1.381; font-weight: 600; color: var(--accent);" data-price-usd="' + (model.priceUsd || 0) + '">' +
                    escapedPrice +
                  '</div>' +
                '</div>' +
                '<div style="display: flex; gap: 8px; justify-content: center; margin-top: auto; padding-top: 24px;">' +
                  '<a href="/AI/user/cart.jsp?action=add&type=MODEL&id=' + model.id + '" class="btn secondary btn-sm">장바구니 추가</a>' +
                  '<a href="/AI/user/checkout.jsp?model_id=' + model.id + '" class="btn primary btn-sm">결제하기</a>' +
                '</div>' +
              '</div>';
          }).join('');
        }
        
        // 패키지 렌더링
        if (!packages || !Array.isArray(packages) || packages.length === 0) {
          pkgGrid.innerHTML = `
            <div class="glass-card" style="text-align: center; padding: 80px 40px; max-width: 600px; margin: 0 auto; grid-column: 1 / -1;">
              <h2 style="margin-bottom: 12px;">패키지가 없습니다</h2>
              <p style="color: var(--text-secondary); font-size: 17px; line-height: 1.47059;">
                선택한 카테고리 조합에 해당하는 패키지가 없습니다.
              </p>
            </div>
          `;
        } else {
          // 패키지 카드 렌더링 (JSP EL 충돌 방지를 위해 문자열 연결 사용)
          pkgGrid.innerHTML = packages.map(pkg => {
          const price = pkg.price ? '$' + pkg.price.toFixed(2) : '가격 문의';
          const discountPrice = pkg.discountPrice ? '$' + pkg.discountPrice.toFixed(2) : null;
          const categories = (pkg.categories || []).map(c => {
            const escapedC = escapeHtml(c);
            return '<span style="background: var(--surface); padding: 4px 12px; border-radius: 12px; font-size: 12px; margin-right: 4px;">' + escapedC + '</span>';
          }).join('');
          
          const pkgTitle = escapeHtml(pkg.title || '패키지');
          const pkgDesc = escapeHtml((pkg.description || '설명 없음').substring(0, 150));
          const pkgDescSuffix = (pkg.description || '').length > 150 ? '...' : '';
          
          let categoriesHtml = '';
          if (categories) {
            categoriesHtml = '<div style="margin-bottom: 16px;">' + categories + '</div>';
          }
          
          let priceHtml = '';
          if (discountPrice) {
            const escapedPrice = escapeHtml(price);
            const escapedDiscount = escapeHtml(discountPrice);
            priceHtml = 
              '<div style="text-decoration: line-through; color: var(--text-secondary); font-size: 14px; margin-bottom: 8px;">' +
                escapedPrice +
              '</div>' +
              '<div class="price-display" style="color: #ff3b30; font-size: 32px; line-height: 1.125; font-weight: 600; margin-bottom: 8px;" data-price-usd="' + pkg.discountPrice + '">' +
                escapedDiscount +
              '</div>';
          } else {
            const escapedPrice = escapeHtml(price);
            priceHtml = 
              '<div class="price-display" style="font-size: 32px; line-height: 1.125; font-weight: 600; margin-bottom: 8px;" data-price-usd="' + (pkg.price || 0) + '">' +
                escapedPrice +
              '</div>';
          }
          
          return 
            '<div class="user-card glass-card" style="display: flex; flex-direction: column;">' +
              '<h3 style="margin-bottom: 12px; font-size: 24px; line-height: 1.16667; font-weight: 600;">' + pkgTitle + '</h3>' +
              categoriesHtml +
              '<p style="color: var(--text-secondary); margin: 16px 0; line-height: 1.47059; font-size: 17px;">' +
                pkgDesc + pkgDescSuffix +
              '</p>' +
              '<div style="margin: 20px 0;">' +
                priceHtml +
              '</div>' +
              '<div style="display: flex; gap: 8px; justify-content: center; margin-top: auto; padding-top: 24px;">' +
                '<a href="/AI/user/cart.jsp?action=add&type=PACKAGE&id=' + pkg.id + '" class="btn secondary btn-sm">장바구니 추가</a>' +
                '<a href="/AI/user/packageDetail.jsp?id=' + pkg.id + '&action=checkout" class="btn primary btn-sm">결제하기</a>' +
              '</div>' +
            '</div>';
          }).join('');

          // GSAP reveal 초기화
          if (window.initReveal) {
            window.initReveal();
          }

          // 통화 전환 업데이트
          if (window.AINavigator && window.AINavigator.setCurrency) {
            window.AINavigator.setCurrency(window.AINavigator.getCurrency());
          }
        }
      } catch (error) {
        console.error('모델/패키지 로드 실패:', error);
        console.error('에러 상세:', error.message, error.stack);
        toast('모델과 패키지를 불러올 수 없습니다: ' + (error.message || '알 수 없는 오류'), 'error');
        const modelGrid = document.getElementById('modelGrid');
        if (modelGrid) {
          modelGrid.innerHTML = '<div class="glass-card" style="text-align: center; padding: 40px; grid-column: 1 / -1;"><p style="color: #ff3b30;">모델을 불러오는 중 오류가 발생했습니다.</p><p style="color: var(--text-secondary); font-size: 14px; margin-top: 8px;">콘솔을 확인해주세요.</p></div>';
        }
        if (pkgGrid) {
          pkgGrid.innerHTML = '<div class="glass-card" style="text-align: center; padding: 40px;"><p style="color: #ff3b30;">패키지를 불러오는 중 오류가 발생했습니다.</p><p style="color: var(--text-secondary); font-size: 14px; margin-top: 8px;">콘솔을 확인해주세요.</p></div>';
        }
      }
    }

    function escapeHtml(text) {
      if (!text) return '';
      const div = document.createElement('div');
      div.textContent = text;
      return div.innerHTML;
    }

    // model_id 파라미터가 있으면 전체 패키지 로드
    <% if (modelIdParam != null && !modelIdParam.trim().isEmpty()) { %>
      (async function() {
        try {
          // 전체 패키지 로드
          const packagesResponse = await fetch('/AI/api/packages.jsp');
          const allPackages = await packagesResponse.json();
          
          // 현재 모델이 포함된 패키지 ID 목록
          const modelPackageIds = new Set([<% for (Package pkg : modelPackages) { %><%= pkg.getId() %>,<% } %>]);
          
          // 모델이 포함된 패키지 제외한 나머지 패키지
          const otherPackages = allPackages.filter(pkg => !modelPackageIds.has(pkg.id));
          
          const pkgGrid = document.getElementById('pkgGrid');
          pkgGrid.classList.remove('locked');
          
          if (!otherPackages || otherPackages.length === 0) {
            pkgGrid.innerHTML = '<div class="glass-card" style="text-align: center; padding: 40px; grid-column: 1 / -1;"><p style="color: var(--text-secondary);">추가 패키지가 없습니다.</p></div>';
          } else {
            pkgGrid.innerHTML = otherPackages.map(pkg => {
              const price = pkg.price ? '$' + pkg.price.toFixed(2) : '가격 문의';
              const discountPrice = pkg.discountPrice ? '$' + pkg.discountPrice.toFixed(2) : null;
              const categories = (pkg.categories || []).map(c => {
                const escapedC = escapeHtml(c);
                return '<span style="background: var(--surface); padding: 4px 12px; border-radius: 12px; font-size: 12px; margin-right: 4px;">' + escapedC + '</span>';
              }).join('');
              
              const pkgTitle = escapeHtml(pkg.title || '패키지');
              const pkgDesc = escapeHtml((pkg.description || '설명 없음').substring(0, 150));
              const pkgDescSuffix = (pkg.description || '').length > 150 ? '...' : '';
              
              let categoriesHtml = '';
              if (categories) {
                categoriesHtml = '<div style="margin-bottom: 16px;">' + categories + '</div>';
              }
              
              let priceHtml = '';
              if (discountPrice) {
                const escapedPrice = escapeHtml(price);
                const escapedDiscount = escapeHtml(discountPrice);
                priceHtml = 
                  '<div style="text-decoration: line-through; color: var(--text-secondary); font-size: 14px; margin-bottom: 8px;">' +
                    escapedPrice +
                  '</div>' +
                  '<div class="price-display" style="color: #ff3b30; font-size: 32px; line-height: 1.125; font-weight: 600; margin-bottom: 8px;" data-price-usd="' + pkg.discountPrice + '">' +
                    escapedDiscount +
                  '</div>';
              } else {
                const escapedPrice = escapeHtml(price);
                priceHtml = 
                  '<div class="price-display" style="font-size: 32px; line-height: 1.125; font-weight: 600; margin-bottom: 8px;" data-price-usd="' + (pkg.price || 0) + '">' +
                    escapedPrice +
                  '</div>';
              }
              
              return 
                '<div class="user-card glass-card" style="display: flex; flex-direction: column;">' +
                  '<h3 style="margin-bottom: 12px; font-size: 24px; line-height: 1.16667; font-weight: 600;">' + pkgTitle + '</h3>' +
                  categoriesHtml +
                  '<p style="color: var(--text-secondary); margin: 16px 0; line-height: 1.47059; font-size: 17px;">' +
                    pkgDesc + pkgDescSuffix +
                  '</p>' +
                  '<div style="margin: 20px 0;">' +
                    priceHtml +
                  '</div>' +
                  '<div style="display: flex; gap: 8px; justify-content: center; margin-top: auto; padding-top: 24px;">' +
                    '<a href="/AI/user/cart.jsp?action=add&type=PACKAGE&id=' + pkg.id + '" class="btn secondary btn-sm">장바구니 추가</a>' +
                    '<a href="/AI/user/packageDetail.jsp?id=' + pkg.id + '&action=checkout" class="btn primary btn-sm">결제하기</a>' +
                  '</div>' +
                '</div>';
            }).join('');
            
            // 통화 전환 업데이트
            if (window.AINavigator && window.AINavigator.setCurrency) {
              window.AINavigator.setCurrency(window.AINavigator.getCurrency());
            }
          }
        } catch (error) {
          console.error('전체 패키지 로드 실패:', error);
        }
      })();
    <% } %>

    // 초기화
    loadCategories();
  </script>
  <jsp:include page="/AI/partials/footer.jsp"/>
</body>
</html>
