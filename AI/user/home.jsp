<%-- 
  AI Navigator 홈페이지
  추천 AI 모델 및 패키지를 표시하는 메인 랜딩 페이지
--%>
<%@ page contentType="text/html; charset=UTF-8" buffer="128kb" autoFlush="true" %>
<%@ page isELIgnored="true" %>
<%@ page import="dao.AIModelDAO" %>
<%@ page import="dao.PackageDAO" %>
<%@ page import="dao.CategoryDAO" %>
<%@ page import="model.AIModel" %>
<%@ page import="model.Package" %>
<%@ page import="model.Category" %>
<%@ page import="model.User" %>
<%@ page import="java.util.List" %>
<%@ include file="/AI/user/_common.jsp" %>

<%!
  /**
   * AI 모델의 모달리티 코드 결정
   * input/output modalities, 카테고리명, 모델명을 종합적으로 분석
   * @param model AI 모델 객체
   * @return 모달리티 코드 (TEXT, IMAGE, VIDEO, AUDIO, EMBEDDING 중 하나)
   */
  public String determineModalityCode(AIModel model) {
    if (model == null) {
      return "";
    }
    
    String modalityCode = "";
    
    // 1순위: input/output modalities 확인 (가장 정확)
    String inputMods = (model.getInputModalities() != null) 
        ? model.getInputModalities().toUpperCase() : "";
    String outputMods = (model.getOutputModalities() != null) 
        ? model.getOutputModalities().toUpperCase() : "";
    
    if (inputMods.contains("AUDIO") || outputMods.contains("AUDIO")) {
      return "AUDIO";
    } else if (inputMods.contains("VIDEO") || outputMods.contains("VIDEO")) {
      return "VIDEO";
    } else if (inputMods.contains("IMAGE") || outputMods.contains("IMAGE")) {
      return "IMAGE";
    } else if (inputMods.contains("TEXT") || outputMods.contains("TEXT") 
        || inputMods.contains("CODE")) {
      return "TEXT";
    }
    
    // 2순위: 카테고리명으로 확인
    if (model.getCategoryName() != null) {
      String categoryName = model.getCategoryName().toUpperCase();
      
      // 텍스트 관련
      if (categoryName.contains("LLM") || categoryName.contains("TEXT") 
          || categoryName.contains("CODE") || categoryName.contains("TRANSLATION") 
          || categoryName.contains("SUMMARIZATION") || categoryName.contains("텍스트") 
          || categoryName.contains("코드") || categoryName.contains("번역") 
          || categoryName.contains("요약")) {
        return "TEXT";
      }
      // 이미지 관련
      else if (categoryName.contains("IMAGE") || categoryName.contains("이미지")) {
        return "IMAGE";
      }
      // 비디오 관련
      else if (categoryName.contains("VIDEO") || categoryName.contains("비디오") 
          || categoryName.contains("영상")) {
        return "VIDEO";
      }
      // 오디오 관련
      else if (categoryName.contains("SPEECH") || categoryName.contains("AUDIO") 
          || categoryName.contains("음성") || categoryName.contains("오디오") 
          || categoryName.contains("TTS") || categoryName.contains("STT")) {
        return "AUDIO";
      }
      // 임베딩 관련
      else if (categoryName.contains("EMBEDDING") || categoryName.contains("SEARCH") 
          || categoryName.contains("임베딩") || categoryName.contains("검색")) {
        return "EMBEDDING";
      }
    }
    
    // 3순위: 모델명으로 확인 (Whisper 등)
    if (model.getModelName() != null) {
      String modelName = model.getModelName().toUpperCase();
      if (modelName.contains("WHISPER") || modelName.contains("SPEECH") 
          || modelName.contains("TTS") || modelName.contains("STT") 
          || modelName.contains("AUDIO")) {
        return "AUDIO";
      }
    }
    
    return modalityCode;
  }
  
  /**
   * Provider별 로고 URL 및 링크 반환
   * @param providerName 제공자 이름
   * @param modelName 모델 이름 (Gemini 등 특수 케이스용)
   * @return [로고URL, 링크URL] 배열
   */
  public String[] getProviderLogo(String providerName, String modelName) {
    String[] result = {"/AI/assets/img/placeholder.png", "#"};
    
    if (providerName == null) {
      return result;
    }
    
    String providerLower = providerName.toLowerCase();
    
    // Provider별 로고 매핑
    if (providerLower.contains("openai")) {
      result[0] = "https://cdn.simpleicons.org/openai/412991";
      result[1] = "https://openai.com";
    } else if (providerLower.contains("google")) {
      result[0] = "https://cdn.simpleicons.org/google/4285F4";
      result[1] = "https://google.com";
    } else if (providerLower.contains("anthropic") || providerLower.contains("claude")) {
      result[0] = "https://cdn.simpleicons.org/anthropic/D97706";
      result[1] = "https://anthropic.com";
    } else if (providerLower.contains("meta")) {
      result[0] = "https://cdn.simpleicons.org/meta/0081FB";
      result[1] = "https://meta.com";
    } else if (providerLower.contains("microsoft")) {
      result[0] = "https://cdn.simpleicons.org/microsoft/0078D4";
      result[1] = "https://microsoft.com";
    } else if (providerLower.contains("adobe")) {
      result[0] = "https://cdn.simpleicons.org/adobe/FF0000";
      result[1] = "https://adobe.com";
    } else if (providerLower.contains("midjourney")) {
      result[0] = "https://cdn.simpleicons.org/midjourney/000000";
      result[1] = "https://midjourney.com";
    } else if (providerLower.contains("stability")) {
      result[0] = "https://cdn.simpleicons.org/stabilityai/7575FF";
      result[1] = "https://stability.ai";
    } else if (providerLower.contains("cohere")) {
      result[0] = "https://cdn.simpleicons.org/cohere/FA5C5C";
      result[1] = "https://cohere.com";
    } else if (providerLower.contains("github")) {
      result[0] = "https://cdn.simpleicons.org/github/181717";
      result[1] = "https://github.com";
    } else if (providerLower.contains("deepl")) {
      result[0] = "https://cdn.simpleicons.org/deepl/0F2C46";
      result[1] = "https://deepl.com";
    } else if (providerLower.contains("elevenlabs")) {
      result[0] = "https://cdn.simpleicons.org/elevenlabs/000000";
      result[1] = "https://elevenlabs.io";
    } else if (providerLower.contains("runway")) {
      result[0] = "https://cdn.simpleicons.org/runwayml/000000";
      result[1] = "https://runwayml.com";
    } else if (providerLower.contains("perplexity")) {
      result[0] = "https://cdn.simpleicons.org/perplexity/AA00FF";
      result[1] = "https://perplexity.ai";
    } else if (modelName != null && modelName.toLowerCase().contains("gemini")) {
      result[0] = "/AI/assets/img/Gemini.png";
      result[1] = "https://deepmind.google/technologies/gemini/";
    }
    
    return result;
  }
%>

<%
  request.setCharacterEncoding("UTF-8");
  response.setCharacterEncoding("UTF-8");
  
  // DB 연결 실패 시 빈 리스트로 초기화
  List<AIModel> featuredModels = new java.util.ArrayList<>();
  List<Package> featuredPackages = new java.util.ArrayList<>();
  java.util.Map<Integer, List<Category>> packageCategoriesMap = new java.util.HashMap<>();
  
  try {
    AIModelDAO modelDAO = new AIModelDAO();
    PackageDAO packageDAO = new PackageDAO();
    
    // 홈페이지용 제한된 데이터만 로드 (성능 최적화)
    featuredModels = modelDAO.findFeatured(20); // 최신 20개 모델만
    
    // 최신 6개 패키지만 로드
    featuredPackages = packageDAO.findFeatured(6);
    
    // 패키지 카테고리 일괄 조회 (N+1 쿼리 문제 해결)
    if (!featuredPackages.isEmpty()) {
      java.util.List<Integer> packageIds = new java.util.ArrayList<>();
      for (Package pkg : featuredPackages) {
        packageIds.add(pkg.getId());
      }
      packageCategoriesMap = packageDAO.getCategoriesByPackageIds(packageIds);
    }
  } catch (Exception e) {
    // DB 연결 실패 또는 기타 오류 시 로그만 기록하고 빈 리스트 유지
    System.err.println("홈페이지 데이터 로드 중 오류: " + e.getMessage());
    e.printStackTrace();
    // 사용자에게는 빈 페이지가 아닌 기본 화면을 보여줌
  }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>AI Navigator - AI 모델 마켓플레이스</title>
  <link rel="preload" href="/AI/assets/css/landing.css?v=2.0" as="style">
  <link rel="stylesheet" href="/AI/assets/css/landing.css?v=2.0">
  <link rel="stylesheet" href="/AI/assets/css/animations.css" media="print" onload="this.media='all'">
  <noscript><link rel="stylesheet" href="/AI/assets/css/animations.css"></noscript>
</head>
<body>
  <!-- Navbar with Login/Signup -->
  <jsp:include page="/AI/partials/header.jsp"/>

  <!-- Key Visual Section (includes search) -->
  <jsp:include page="/AI/partials/key-visual.jsp"/>

  <!-- Intent Recommendations Section -->
  <section id="intent-recos" class="intent-grid section"></section>

  <!-- Models Section -->
  <section class="section" id="models">
    <h2 class="section-title">추천 AI 모델</h2>
    <p class="section-subtitle">최고 성능의 AI 모델 큐레이션을 둘러보세요</p>
    
    <div class="modality-selector">
      <a href="#models" class="modality-btn active">전체 모델</a>
      <a href="#models?modality=TEXT" class="modality-btn">텍스트 모델</a>
      <a href="#models?modality=IMAGE" class="modality-btn">이미지 모델</a>
      <a href="#models?modality=VIDEO" class="modality-btn">비디오 모델</a>
      <a href="#models?modality=AUDIO" class="modality-btn">오디오 모델</a>
      <a href="#models?modality=EMBEDDING" class="modality-btn">임베딩 모델</a>
    </div>

    <div class="models-section-wrapper">
      <button class="scroll-nav-btn scroll-nav-left-positioned scroll-nav-left" id="mainScrollLeft" aria-label="왼쪽으로 이동" disabled>‹</button>
      <button class="scroll-nav-btn scroll-nav-right-positioned scroll-nav-right" id="mainScrollRight" aria-label="오른쪽으로 이동" disabled>›</button>
      
      <div class="model-items-scroll-container" id="modelItemsContainer">
        <div class="model-items-scroll" id="modelItemsScroll">
        <% for (AIModel model : featuredModels) { %>
          <%
            // 모달리티 코드 결정
            String modalityCode = determineModalityCode(model);
            
            // Provider 로고 정보 가져오기
            String[] logoInfo = getProviderLogo(model.getProviderName(), model.getModelName());
            String logoUrl = logoInfo[0];
            String logoLink = logoInfo[1];
            
            // 안전한 데이터 속성 값 준비 (XSS 방지)
            String modelName = safeString(model.getModelName(), "모델명 없음");
            String providerName = safeString(model.getProviderName(), "제공업체");
            String categoryName = safeString(model.getCategoryName(), "");
            String description = (model.getDescription() != null && !model.getDescription().isEmpty()) 
                ? model.getDescription() 
                : safeString(model.getPurposeSummary(), "설명 없음");
            String price = safeString(model.getPrice(), "무료 / 문의");
            String inputModalities = safeString(model.getInputModalities(), "");
            String outputModalities = safeString(model.getOutputModalities(), "");
          %>
          <div class="model-item fade-in" 
               data-modality="<%= modalityCode %>" 
               data-category="<%= escapeHtmlAttribute(categoryName) %>"
               data-model-id="<%= model.getId() %>"
               data-model-name="<%= escapeHtmlAttribute(modelName) %>"
               data-model-provider="<%= escapeHtmlAttribute(providerName) %>"
               data-model-category="<%= escapeHtmlAttribute(categoryName) %>"
               data-model-description="<%= escapeHtmlAttribute(description) %>"
               data-model-price="<%= escapeHtmlAttribute(price) %>"
               data-model-price-usd="<%= model.getPriceUsd() != null ? model.getPriceUsd().doubleValue() : 0 %>"
               data-model-api="<%= model.isApiAvailable() %>"
               data-model-finetune="<%= model.isFinetuneAvailable() %>"
               data-model-onprem="<%= model.isOnpremAvailable() %>"
               data-model-input="<%= escapeHtmlAttribute(inputModalities) %>"
               data-model-output="<%= escapeHtmlAttribute(outputModalities) %>"
               data-model-params="<%= model.getParamsBillion() != null ? model.getParamsBillion() : "" %>"
               data-model-latency="<%= model.getLatencyMs() != null ? model.getLatencyMs() : "" %>"
               data-model-homepage="<%= escapeHtmlAttribute(safeString(model.getHomepageUrl(), "")) %>"
               data-model-docs="<%= escapeHtmlAttribute(safeString(model.getDocsUrl(), "")) %>"
               data-model-playground="<%= escapeHtmlAttribute(safeString(model.getPlaygroundUrl(), "")) %>"
               class="model-item-content-visibility">
            <div class="model-item-image">
              <a href="<%= logoLink %>" target="_blank" rel="noopener noreferrer" class="model-item-image-link">
                <img src="<%= logoUrl %>" 
                     alt="<%= escapeHtml(providerName) %> 로고" 
                     loading="lazy" 
                     decoding="async" 
                     onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                <div class="model-item-image-fallback">🤖</div>
              </a>
            </div>
            <h3 class="model-item-name"><%= escapeHtml(modelName) %></h3>
            <p class="model-item-provider">
              <%= escapeHtml(providerName) %> 
              <% if (!categoryName.isEmpty()) { %>
                · <%= escapeHtml(categoryName) %>
              <% } %>
            </p>
            <p class="model-item-description">
              <%= escapeHtml(description.length() > 120 ? description.substring(0, 120) + "..." : description) %>
            </p>
            <div class="model-item-price">
              <%= escapeHtml(price) %>
            </div>
          </div>
        <% } %>
        </div>
      </div>
    </div>
  </section>

  <!-- Packages Section -->
  <% if (!featuredPackages.isEmpty()) { %>
    <section class="section">
      <h2 class="section-title">추천 패키지</h2>
      <p class="section-subtitle">일반적인 사용 사례를 위한 사전 구성된 번들</p>
      <div class="package-grid">
        <% for (Package pkg : featuredPackages) { %>
          <div class="package-card" style="display: flex; flex-direction: column;">
            <h3 class="package-card-title"><%= pkg.getTitle() != null ? pkg.getTitle() : "패키지" %></h3>
            <% 
              List<Category> pkgCategories = packageCategoriesMap.get(pkg.getId());
              if (pkgCategories == null) {
                pkgCategories = new java.util.ArrayList<>();
              }
            %>
            <% if (pkgCategories != null && !pkgCategories.isEmpty()) { %>
              <div class="package-card-categories">
                <% for (Category cat : pkgCategories) { %>
                  <span class="package-category-badge"><%= cat.getCategoryName() %></span>
                <% } %>
              </div>
            <% } %>
            <p class="package-card-description">
              <%= pkg.getDescription() != null && pkg.getDescription().length() > 100 
                  ? pkg.getDescription().substring(0, 100) + "..." 
                  : (pkg.getDescription() != null ? pkg.getDescription() : "설명 없음") %>
            </p>
            <div class="package-card-price">
              <% 
                double priceUsd = pkg.getPrice() != null ? pkg.getPrice().doubleValue() : 0;
                long priceKrw = Math.round(priceUsd * 1350);
              %>
              <span class="price-display" data-price-usd="<%= priceUsd %>">
                <%= String.format("%,d", priceKrw) %>원
              </span><br>
              <span class="price-display-usd" data-price-usd="<%= priceUsd %>">
                ($<%= String.format("%.0f", priceUsd) %>/월)
              </span>
            </div>
            <div class="model-item-actions package-card-actions-wrapper">
              <a href="/AI/user/packageDetail.jsp?id=<%= pkg.getId() %>" class="btn btn-primary btn-sm">패키지 보기</a>
            </div>
          </div>
        <% } %>
      </div>
    </section>
  <% } %>

  <!-- Contact Section -->
  <section class="contact-section" id="contact">
    <h2>문의하기</h2>
    <p>적합한 모델을 선택하는 데 도움이 필요하신가요? 지원팀에 문의하거나 API 문서를 확인하세요.</p>
    <div class="contact-links">
      <a href="mailto:support@ainavigator.com" class="btn btn-primary">지원 문의</a>
      <a href="/AI/user/pricing.jsp" class="btn btn-secondary">API 문의</a>
      <a href="/AI/landing/index.jsp" class="btn btn-secondary">회사 소개</a>
    </div>
  </section>

  <script src="/AI/assets/js/landing.js" defer async></script>

  <!-- Model Detail Modal -->
  <div id="modelDetailModal" class="model-detail-modal" style="display: none;">
    <div class="model-detail-modal-overlay"></div>
    <div class="model-detail-modal-content">
      <button class="model-detail-modal-close" id="modelDetailModalClose" aria-label="닫기">×</button>
      <div id="modelDetailContent"></div>
    </div>
  </div>
  <jsp:include page="/AI/partials/footer.jsp"/>
</body>
</html>
