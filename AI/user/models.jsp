<%@ page contentType="text/html; charset=UTF-8" buffer="64kb" autoFlush="true" %>
<%@ page isELIgnored="true" %>
<%@ page import="dao.AIModelDAO" %>
<%@ page import="dao.CategoryDAO" %>
<%@ page import="model.AIModel" %>
<%@ page import="model.Category" %>
<%@ page import="java.util.List" %>
<%
  request.setCharacterEncoding("UTF-8");
  response.setCharacterEncoding("UTF-8");
  AIModelDAO modelDAO = new AIModelDAO();
  CategoryDAO categoryDAO = new CategoryDAO();
  
  // DB의 모든 AI 모델 로드
  List<AIModel> allModels = modelDAO.findAll();
  
  // 카테고리 목록
  List<Category> categories = categoryDAO.findAll();
  
  // 필터링 파라미터
  String modalityParam = request.getParameter("modality");
  String categoryParam = request.getParameter("category");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>AI 모델 목록 - AI Navigator</title>
  <link rel="stylesheet" href="/AI/assets/css/landing.css?v=2.0">
  <link rel="stylesheet" href="/AI/assets/css/user.css">
  <link rel="stylesheet" href="/AI/assets/css/animations.css">
</head>
<body>
  <jsp:include page="/AI/partials/header.jsp"/>

  <section class="section" style="padding-top: 80px;">
    <h2 class="section-title">AI 모델 전체 목록</h2>
    <p class="section-subtitle">모든 AI 모델을 둘러보세요</p>
    
    <div class="modality-selector" style="margin-bottom: 3rem;">
      <a href="/AI/user/models.jsp" class="modality-btn <%= (modalityParam == null || modalityParam.isEmpty()) ? "active" : "" %>" id="all-models-btn">전체 모델</a>
      <a href="/AI/user/models.jsp?modality=TEXT" class="modality-btn <%= "TEXT".equals(modalityParam) ? "active" : "" %>">텍스트 모델</a>
      <a href="/AI/user/models.jsp?modality=IMAGE" class="modality-btn <%= "IMAGE".equals(modalityParam) ? "active" : "" %>">이미지 모델</a>
      <a href="/AI/user/models.jsp?modality=VIDEO" class="modality-btn <%= "VIDEO".equals(modalityParam) ? "active" : "" %>">비디오 모델</a>
      <a href="/AI/user/models.jsp?modality=AUDIO" class="modality-btn <%= "AUDIO".equals(modalityParam) ? "active" : "" %>">오디오 모델</a>
      <a href="/AI/user/models.jsp?modality=EMBEDDING" class="modality-btn <%= "EMBEDDING".equals(modalityParam) ? "active" : "" %>">임베딩 모델</a>
    </div>

    <div class="model-items" style="display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 2rem; margin-top: 2rem;">
      <% for (AIModel model : allModels) { %>
        <%
          // 카테고리 이름, input_modalities, output_modalities를 모두 확인하여 모달리티 코드 결정
          String modalityCode = "";
          
          // input/output modalities 확인 (우선순위 높음)
          String inputMods = model.getInputModalities() != null ? model.getInputModalities().toUpperCase() : "";
          String outputMods = model.getOutputModalities() != null ? model.getOutputModalities().toUpperCase() : "";
          
          if (inputMods.contains("AUDIO") || outputMods.contains("AUDIO")) {
            modalityCode = "AUDIO";
          } else if (inputMods.contains("VIDEO") || outputMods.contains("VIDEO")) {
            modalityCode = "VIDEO";
          } else if (inputMods.contains("IMAGE") || outputMods.contains("IMAGE")) {
            modalityCode = "IMAGE";
          } else if (inputMods.contains("TEXT") || outputMods.contains("TEXT") || inputMods.contains("CODE")) {
            modalityCode = "TEXT";
          } else if (model.getCategoryName() != null) {
            // modalities가 없으면 카테고리 이름으로 확인
            String categoryName = model.getCategoryName().toUpperCase();
            if (categoryName.contains("LLM") || categoryName.contains("TEXT") || categoryName.contains("CODE") || 
                categoryName.contains("TRANSLATION") || categoryName.contains("SUMMARIZATION") ||
                categoryName.contains("텍스트") || categoryName.contains("코드") || categoryName.contains("번역") || categoryName.contains("요약")) {
              modalityCode = "TEXT";
            } else if (categoryName.contains("IMAGE") || categoryName.contains("이미지")) {
              modalityCode = "IMAGE";
            } else if (categoryName.contains("VIDEO") || categoryName.contains("비디오") || categoryName.contains("영상")) {
              modalityCode = "VIDEO";
            } else if (categoryName.contains("SPEECH") || categoryName.contains("AUDIO") || 
                     categoryName.contains("음성") || categoryName.contains("오디오") ||
                     categoryName.contains("TTS") || categoryName.contains("STT")) {
              modalityCode = "AUDIO";
            } else if (categoryName.contains("EMBEDDING") || categoryName.contains("SEARCH") ||
                     categoryName.contains("임베딩") || categoryName.contains("검색")) {
              modalityCode = "EMBEDDING";
            }
          }
          
          // 모델명에서도 확인 (Whisper 등)
          if (modalityCode.isEmpty() && model.getModelName() != null) {
            String modelName = model.getModelName().toUpperCase();
            if (modelName.contains("WHISPER") || modelName.contains("SPEECH") || modelName.contains("TTS") || modelName.contains("STT") || modelName.contains("AUDIO")) {
              modalityCode = "AUDIO";
            } else if (modelName.contains("DALL") || modelName.contains("MIDJOURNEY") || modelName.contains("STABLE") || modelName.contains("IMAGE")) {
              modalityCode = "IMAGE";
            } else if (modelName.contains("VIDEO") || modelName.contains("RUNWAY")) {
              modalityCode = "VIDEO";
            } else if (modelName.contains("GPT") || modelName.contains("BERT") || modelName.contains("CLAUDE") || modelName.contains("LLM") || modelName.contains("TEXT")) {
              modalityCode = "TEXT";
            }
          }
          
          // modalityCode가 여전히 비어있으면 "UNKNOWN"으로 설정 (필터링에서 제외)
          if (modalityCode.isEmpty()) {
            modalityCode = "UNKNOWN";
          }
          
          // 필터링 적용 - 서버 사이드 필터링
          // modalityParam이 있으면 해당 모달리티만 표시, 없으면 전체 표시
          if (modalityParam != null && !modalityParam.isEmpty()) {
            // 필터링 조건: modalityCode가 정확히 일치해야 함 (UNKNOWN 제외)
            if (!modalityCode.equals(modalityParam)) {
              continue; // 필터링 조건에 맞지 않으면 건너뛰기
            }
          }
          
          // Provider별 로고 URL 매핑
          String providerName = model.getProviderName() != null ? model.getProviderName().toLowerCase() : "";
          String logoUrl = "/AI/assets/img/placeholder.png";
          String logoLink = "#";
          
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
        <div class="model-item fade-in" data-modality="<%= modalityCode %>" data-model-id="<%= model.getId() %>" data-model-name="<%= model.getModelName() != null ? model.getModelName().replace("\"", "&quot;") : "" %>" style="display: flex; flex-direction: column;">
          <div class="model-item-image">
            <a href="<%= logoLink %>" target="_blank" rel="noopener noreferrer" style="display: block; width: 100%; height: 100%;">
              <img src="<%= logoUrl %>" alt="<%= model.getProviderName() != null ? model.getProviderName() : "제공업체" %> 로고" loading="lazy" decoding="async" style="width: 100%; height: 100%; object-fit: contain; padding: 20px;" onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
              <div style="display: none; width: 100%; height: 100%; background: var(--surface); align-items: center; justify-content: center; font-size: 2rem; border-radius: 12px;">🤖</div>
            </a>
          </div>
          <h3 class="model-item-name"><%= model.getModelName() != null ? model.getModelName() : "모델명 없음" %></h3>
          <p class="model-item-provider">
            <%= model.getProviderName() != null ? model.getProviderName() : "제공업체" %> 
            <% if (model.getCategoryName() != null) { %>
              · <%= model.getCategoryName() %>
            <% } %>
          </p>
          <p class="model-item-description">
            <%= model.getDescription() != null && !model.getDescription().isEmpty() 
                ? (model.getDescription().length() > 120 ? model.getDescription().substring(0, 120) + "..." : model.getDescription())
                : (model.getPurposeSummary() != null ? model.getPurposeSummary() : "설명 없음") %>
          </p>
          <div class="model-item-price">
            <% if (model.getPrice() != null && !model.getPrice().isEmpty()) { %>
              <%= model.getPrice() %>
            <% } else { %>
              무료 / 문의
            <% } %>
          </div>
          <div class="model-item-actions">
            <a href="/AI/user/modelDetail.jsp?id=<%= model.getId() %>" class="btn btn-primary btn-sm">상세보기</a>
            <a href="/AI/user/pricing.jsp" class="btn btn-secondary btn-sm">요금제</a>
          </div>
        </div>
      <% } %>
    </div>
  </section>

  <script src="/AI/assets/js/landing.js"></script>
  <script>
    // models.jsp 전용 필터링 (landing.js와 충돌 방지)
    // URL 파라미터에서 modality 가져오기
    const urlParams = new URLSearchParams(window.location.search);
    let currentModality = urlParams.get('modality');
    
    // models.jsp 전용 모달리티 필터링 함수 (landing.js의 함수와 구분)
    function filterModelsPageByModality(modality) {
      const modelItems = document.querySelectorAll('.model-item[data-modality]');
      let visibleCount = 0;
      
      modelItems.forEach(item => {
        const itemModality = item.getAttribute('data-modality');
        // modality가 null이거나 빈 문자열이면 모든 모델 표시 (전체 모델)
        if (!modality || modality === '' || modality === null) {
          item.style.display = '';
          visibleCount++;
        } else {
          // modalityCode가 정확히 일치하는 경우만 표시
          if (itemModality === modality) {
            item.style.display = '';
            visibleCount++;
          } else {
            item.style.display = 'none';
          }
        }
      });
      
      // 모달리티 버튼 active 상태 업데이트
      document.querySelectorAll('.modality-btn').forEach(btn => {
        btn.classList.remove('active');
        const href = btn.getAttribute('href');
        
        if (!modality || modality === '' || modality === null) {
          // 전체 모델 버튼 활성화
          if (href === '/AI/user/models.jsp' || href.startsWith('/AI/user/models.jsp?')) {
            // 질의 문자열이 없거나 modality 파라미터만 있는 경우
            if (!href.includes('modality=') || href === '/AI/user/models.jsp') {
              btn.classList.add('active');
            }
          }
        } else {
          // 특정 모달리티 버튼 활성화
          if (href && href.includes(`modality=${modality}`)) {
            btn.classList.add('active');
          }
        }
      });
      
      // 디버깅: 모달리티별 모델 개수 확인
      const modalityCounts = {};
      modelItems.forEach(item => {
        const mod = item.getAttribute('data-modality');
        modalityCounts[mod] = (modalityCounts[mod] || 0) + 1;
      });
      console.log('모달리티별 모델 개수:', modalityCounts);
      console.log(`필터링 완료: ${modality || '전체'} 모델 ${visibleCount}개 표시`);
    }
    
    // 페이지 로드 시 필터링 적용 (landing.js 실행 전에 실행)
    (function() {
      // 현재 URL 파라미터에 따라 필터링
      if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function() {
          filterModelsPageByModality(currentModality);
          setupModalityButtons();
        });
      } else {
        // 이미 DOM이 로드된 경우 즉시 실행
        filterModelsPageByModality(currentModality);
        setupModalityButtons();
      }
      
      // 모달리티 버튼 클릭 이벤트 설정
      function setupModalityButtons() {
        document.querySelectorAll('.modality-btn').forEach(btn => {
          // 기존 이벤트 리스너 제거 후 새로 추가
          const newBtn = btn.cloneNode(true);
          btn.parentNode.replaceChild(newBtn, btn);
          
          newBtn.addEventListener('click', function(e) {
            const href = this.getAttribute('href');
            if (href) {
              // URL에서 modality 파라미터 추출
              try {
                const url = new URL(href, window.location.origin);
                const modality = url.searchParams.get('modality');
                
                // 즉시 필터링 적용
                currentModality = modality;
                filterModelsPageByModality(modality);
                
                // 링크는 정상적으로 동작하도록 함
                // 페이지가 새로고침되므로 서버 사이드 필터링도 적용됨
              } catch (e) {
                // 상대 경로인 경우
                if (href === '/AI/user/models.jsp') {
                  currentModality = null;
                  filterModelsPageByModality(null);
                }
              }
            }
          });
        });
      }
    })();
  </script>
  <jsp:include page="/AI/partials/footer.jsp"/>
</body>
</html>

