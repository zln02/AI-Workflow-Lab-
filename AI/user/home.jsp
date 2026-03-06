<%-- 
  AI Workflow Lab 홈페이지
  AI 도구 추천, 워크플로우 가이드, 실습 랩을 통한 AI 실무 경험 플랫폼
--%>
<%@ page contentType="text/html; charset=UTF-8" buffer="128kb" autoFlush="true" %>
<%@ page isELIgnored="true" %>
<%@ page import="dao.AIToolDAO" %>
<%@ page import="dao.LabProjectDAO" %>
<%@ page import="model.AITool" %>
<%@ page import="model.LabProject" %>
<%@ page import="model.User" %>
<%@ page import="java.util.List" %>
<%@ include file="/AI/user/_common.jsp" %>

<%
  // 사용자 정보 확인
  User user = (User) session.getAttribute("user");
  
  // DAO 초기화
  AIToolDAO toolDao = new AIToolDAO();
  LabProjectDAO projectDao = new LabProjectDAO();

  // 데이터 조회
  List<AITool> featuredTools = toolDao.findPopular(8);
  List<LabProject> tutorialList = projectDao.findByType("Tutorial");
  List<LabProject> featuredProjects = tutorialList.subList(0, Math.min(4, tutorialList.size()));
  
  // 검색 키워드
  String searchKeyword = request.getParameter("search");
  if (searchKeyword == null) searchKeyword = "";
%>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>AI Workflow Lab - AI 도구 추천과 실무 경험 플랫폼</title>
  <meta name="description" content="AI 도구 추천, 워크플로우 가이드, 실습 랩을 통해 AI 실무 경험을 쌓아보세요. 쉽고 빠른 AI 학습과 실전 프로젝트를 지원합니다.">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
  <link rel="stylesheet" href="/AI/assets/css/animations.css">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <script src="https://cdn.jsdelivr.net/npm/gsap@3.12.2/dist/gsap.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/gsap@3.12.2/dist/ScrollTrigger.min.js"></script>
  <style>
    body { padding-top: 44px; font-family: -apple-system, BlinkMacSystemFont, 'Noto Sans KR', sans-serif; }

    /* Navbar */
    .navbar { position: fixed; top: 0; left: 0; right: 0; z-index: 1000; background: rgba(255,255,255,0.85); backdrop-filter: blur(20px); border-bottom: 0.5px solid rgba(0,0,0,0.1); height: 44px; display: flex; align-items: center; padding: 0; }
    .navbar-container { max-width: 1200px; margin: 0 auto; display: flex; justify-content: space-between; align-items: center; width: 100%; padding: 0 20px; }
    .navbar-logo { font-size: 17px; font-weight: 500; color: #1d1d1f; text-decoration: none; }
    .navbar-menu-wrapper { display: flex; align-items: center; gap: 2rem; }
    .navbar-menu { display: flex; gap: 1.5rem; list-style: none; align-items: center; margin: 0; padding: 0; }
    .navbar-menu a { color: #1d1d1f; text-decoration: none; font-size: 13px; transition: color 0.2s; }
    .navbar-menu a:hover, .navbar-menu a.active { color: #0071e3; }
    .navbar-toggle { display: none; background: none; border: none; color: #1d1d1f; font-size: 1.5rem; cursor: pointer; }
    @media (max-width: 768px) {
      .navbar-menu-wrapper { display: none; }
      .navbar-menu-wrapper.active { display: flex; flex-direction: column; position: fixed; top: 44px; left: 0; right: 0; background: #fff; padding: 1rem; border-bottom: 1px solid #e0e0e0; z-index: 999; }
      .navbar-toggle { display: block; }
    }

    /* AI Provider logos section */
    .ai-logos-section { background: #f5f5f7; padding: 40px 0; overflow: hidden; }
    .ai-logos-track { display: flex; gap: 40px; align-items: center; animation: scrollLogos 30s linear infinite; width: max-content; }
    .ai-logos-track:hover { animation-play-state: paused; }
    .ai-logo-item { display: flex; flex-direction: column; align-items: center; gap: 8px; opacity: 0.7; transition: opacity 0.2s; flex-shrink: 0; }
    .ai-logo-item:hover { opacity: 1; }
    .ai-logo-item img { width: 48px; height: 48px; border-radius: 10px; }
    .ai-logo-item span { font-size: 11px; color: #86868b; font-weight: 500; }
    @keyframes scrollLogos { 0% { transform: translateX(0); } 100% { transform: translateX(-50%); } }

    /* Section titles */
    .home-section-title { font-size: 32px; font-weight: 600; color: #1d1d1f; letter-spacing: -0.003em; margin-bottom: 6px; }
    .home-section-sub { font-size: 17px; color: #86868b; margin-bottom: 0; }

    /* Dark Theme Overrides */
    .ai-tool-card { background: var(--bg-card); border: 1px solid var(--border-primary); }
    .ai-tool-card:hover { border-color: var(--border-hover); box-shadow: var(--shadow-glow); }
    .ai-tool-card-header { border-bottom: 1px solid var(--border-primary); background: var(--bg-tertiary); }
    .provider-logo-fallback { background: var(--bg-tertiary); }
    .ai-tool-card-title { color: var(--text-primary); }
    .ai-tool-card-desc { color: var(--text-secondary); }
    .ai-tool-card-footer { border-top: 1px solid var(--border-primary); }

    .platform-card { background: var(--bg-card); border: 1px solid var(--border-primary); }
    .platform-card:hover { border-color: var(--border-hover); box-shadow: var(--shadow-glow); }

    .lab-card { background: var(--bg-card); border: 1px solid var(--border-primary); }
    .lab-card:hover { border-color: var(--border-hover); box-shadow: var(--shadow-glow); }

    .cta-section { background: var(--primary-gradient); }

    .badge-beginner { background: rgba(16, 185, 129, 0.2); color: var(--difficulty-beginner); border: 1px solid rgba(16, 185, 129, 0.3); }
    .badge-intermediate { background: rgba(245, 158, 11, 0.2); color: var(--difficulty-intermediate); border: 1px solid rgba(245, 158, 11, 0.3); }
    .badge-advanced { background: rgba(239, 68, 68, 0.2); color: var(--difficulty-advanced); border: 1px solid rgba(239, 68, 68, 0.3); }
  </style>
</head>
<body>
  <%@ include file="/AI/partials/header.jsp" %>

  <main>
    <%@ include file="/AI/partials/key-visual.jsp" %>

    <!-- AI 로고 스크롤 배너 -->
    <section class="ai-logos-section">
      <div class="container-fluid px-0">
        <div class="ai-logos-track" id="logosTrack">
          <!-- 1세트 -->
          <div class="ai-logo-item"><img src="/AI/assets/img/providers/openai.svg" alt="OpenAI"><span>ChatGPT</span></div>
          <div class="ai-logo-item"><img src="/AI/assets/img/providers/google.svg" alt="Google"><span>Gemini</span></div>
          <div class="ai-logo-item"><img src="/AI/assets/img/providers/anthropic.svg" alt="Anthropic"><span>Claude</span></div>
          <div class="ai-logo-item"><img src="/AI/assets/img/providers/meta.svg" alt="Meta"><span>Llama</span></div>
          <div class="ai-logo-item"><img src="/AI/assets/img/providers/microsoft.svg" alt="Microsoft"><span>Copilot</span></div>
          <div class="ai-logo-item"><img src="/AI/assets/img/providers/mistral.svg" alt="Mistral"><span>Mistral</span></div>
          <div class="ai-logo-item"><img src="/AI/assets/img/providers/stability.svg" alt="Stability"><span>Stable Diffusion</span></div>
          <div class="ai-logo-item"><img src="/AI/assets/img/providers/cohere.svg" alt="Cohere"><span>Cohere</span></div>
          <div class="ai-logo-item"><img src="/AI/assets/img/providers/huggingface.svg" alt="HuggingFace"><span>HuggingFace</span></div>
          <div class="ai-logo-item"><img src="/AI/assets/img/providers/gemini.svg" alt="Gemini"><span>Gemini Pro</span></div>
          <!-- 2세트 (무한 스크롤) -->
          <div class="ai-logo-item"><img src="/AI/assets/img/providers/openai.svg" alt="OpenAI"><span>ChatGPT</span></div>
          <div class="ai-logo-item"><img src="/AI/assets/img/providers/google.svg" alt="Google"><span>Gemini</span></div>
          <div class="ai-logo-item"><img src="/AI/assets/img/providers/anthropic.svg" alt="Anthropic"><span>Claude</span></div>
          <div class="ai-logo-item"><img src="/AI/assets/img/providers/meta.svg" alt="Meta"><span>Llama</span></div>
          <div class="ai-logo-item"><img src="/AI/assets/img/providers/microsoft.svg" alt="Microsoft"><span>Copilot</span></div>
          <div class="ai-logo-item"><img src="/AI/assets/img/providers/mistral.svg" alt="Mistral"><span>Mistral</span></div>
          <div class="ai-logo-item"><img src="/AI/assets/img/providers/stability.svg" alt="Stability"><span>Stable Diffusion</span></div>
          <div class="ai-logo-item"><img src="/AI/assets/img/providers/cohere.svg" alt="Cohere"><span>Cohere</span></div>
          <div class="ai-logo-item"><img src="/AI/assets/img/providers/huggingface.svg" alt="HuggingFace"><span>HuggingFace</span></div>
          <div class="ai-logo-item"><img src="/AI/assets/img/providers/gemini.svg" alt="Gemini"><span>Gemini Pro</span></div>
        </div>
      </div>
    </section>

    <!-- 플랫폼 소개 섹션 -->
    <section class="py-5">
      <div class="container">
        <div class="text-center mb-5">
          <h2 class="home-section-title">AI 실무 역량을 키우는 가장 빠른 방법</h2>
          <p class="home-section-sub">도구 탐색부터 실전 프로젝트까지 한 곳에서</p>
        </div>
        <div class="row g-4 justify-content-center">
          <div class="col-md-5">
            <div class="platform-card bg-primary text-white h-100">
              <div class="mb-3"><i class="bi bi-compass-fill" style="font-size: 2.5rem;"></i></div>
              <h4 class="fw-bold mb-3">AI 도구 탐색</h4>
              <p class="mb-4 opacity-75">업무 목적에 맞는 AI 도구를 추천받고, 최신 도구를 쉽게 비교·탐색할 수 있습니다. ChatGPT, Claude, Gemini 등 50+ 도구 수록.</p>
              <a href="/AI/user/tools/navigator.jsp" class="btn btn-light">도구 탐색하기 <i class="bi bi-arrow-right ms-1"></i></a>
            </div>
          </div>
          <div class="col-md-5">
            <div class="platform-card h-100" style="background: linear-gradient(135deg, #059669, #10b981); color: white;">
              <div class="mb-3"><i class="bi bi-flask-fill" style="font-size: 2.5rem;"></i></div>
              <h4 class="fw-bold mb-3">AI 실습 랩</h4>
              <p class="mb-4 opacity-75">실제 비즈니스 시나리오 기반 프로젝트를 직접 수행하며 AI 실무 역량을 쌓으세요. 초급부터 고급까지 단계별 커리큘럼.</p>
              <a href="/AI/user/lab/index.jsp" class="btn btn-light">실습 시작하기 <i class="bi bi-arrow-right ms-1"></i></a>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- 인기 AI 도구 섹션 -->
    <section class="py-5" style="background: #f5f5f7;">
      <div class="container">
        <div class="d-flex justify-content-between align-items-end mb-5">
          <div>
            <h2 class="home-section-title">인기 AI 도구</h2>
            <p class="home-section-sub">가장 많이 활용되는 AI 도구들을 만나보세요</p>
          </div>
          <a href="/AI/user/tools/navigator.jsp" class="btn btn-outline-primary btn-sm">전체 도구 보기 <i class="bi bi-arrow-right ms-1"></i></a>
        </div>

        <div class="row g-3">
          <% if (featuredTools.isEmpty()) { %>
          <div class="col-12 text-center py-5 text-muted">
            <i class="bi bi-robot" style="font-size: 3rem;"></i>
            <p class="mt-3">등록된 AI 도구가 없습니다.</p>
          </div>
          <% } %>
          <% for (AITool tool : featuredTools) {
             String[] logoInfo = getProviderLogo(tool.getProviderName(), tool.getToolName());
          %>
          <div class="col-lg-3 col-md-4 col-sm-6">
            <div class="ai-tool-card">
              <div class="ai-tool-card-header">
                <div class="d-flex align-items-center gap-2">
                  <img src="<%= logoInfo[0] %>" alt="<%= escapeHtml(tool.getProviderName()) %>"
                       class="provider-logo"
                       onerror="this.style.display='none';this.nextElementSibling.style.display='flex'">
                  <div class="provider-logo-fallback" style="display:none;">🤖</div>
                  <span class="text-muted" style="font-size:12px;"><%= escapeHtml(safeString(tool.getProviderName(), "")) %></span>
                </div>
                <% if (tool.isFreeTierAvailable()) { %>
                <span class="badge bg-success-subtle text-success" style="font-size:10px;">무료</span>
                <% } %>
              </div>
              <div class="ai-tool-card-body">
                <h5 class="ai-tool-card-title"><%= escapeHtml(tool.getToolName()) %></h5>
                <p class="ai-tool-card-desc"><%= escapeHtml(safeString(tool.getPurposeSummary(), "")) %></p>
                <div class="d-flex align-items-center gap-2 flex-wrap">
                  <span class="badge bg-light text-dark" style="font-size:11px; border: 1px solid #e0e0e0;"><%= escapeHtml(safeString(tool.getCategory(), "기타")) %></span>
                  <span class="badge badge-<%= tool.getDifficultyLevel() != null ? tool.getDifficultyLevel().toLowerCase() : "beginner" %>" style="font-size:11px;">
                    <%= escapeHtml(safeString(tool.getDifficultyLevel(), "")) %>
                  </span>
                </div>
              </div>
              <div class="ai-tool-card-footer">
                <a href="/AI/user/tools/detail.jsp?id=<%= tool.getId() %>" class="btn btn-primary btn-sm w-100">
                  자세히 보기
                </a>
              </div>
            </div>
          </div>
          <% } %>
        </div>
      </div>
    </section>

    <!-- 실습 랩 프로젝트 섹션 -->
    <section class="py-5">
      <div class="container">
        <div class="d-flex justify-content-between align-items-end mb-5">
          <div>
            <h2 class="home-section-title">AI 실습 랩</h2>
            <p class="home-section-sub">실제 비즈니스 시나리오로 AI 역량을 키우세요</p>
          </div>
          <a href="/AI/user/lab/index.jsp" class="btn btn-outline-success btn-sm">전체 프로젝트 <i class="bi bi-arrow-right ms-1"></i></a>
        </div>

        <div class="row g-3">
          <% for (LabProject project : featuredProjects) { %>
          <div class="col-lg-3 col-md-6">
            <div class="lab-card d-flex flex-column">
              <div class="p-4 flex-grow-1">
                <div class="d-flex justify-content-between mb-3">
                  <span class="badge bg-primary-subtle text-primary"><%= escapeHtml(safeString(project.getProjectType(), "")) %></span>
                  <span class="badge bg-secondary-subtle text-secondary"><%= escapeHtml(safeString(project.getDifficultyLevel(), "")) %></span>
                </div>
                <h5 class="fw-semibold mb-2" style="font-size:16px;"><%= escapeHtml(project.getTitle()) %></h5>
                <p class="text-muted small mb-3" style="display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden;">
                  <%= escapeHtml(safeString(project.getDescription(), "")) %>
                </p>
                <div class="small text-muted">
                  <span><i class="bi bi-clock me-1"></i><%= project.getFormattedDuration() %></span>
                  <% Integer participants = project.getCurrentParticipants(); 
                     if (participants != null && participants > 0) { %>
                  <span class="ms-3"><i class="bi bi-people me-1"></i><%= participants %>명</span>
                  <% } else { %>
                  <span class="ms-3"><i class="bi bi-people me-1"></i>Coming Soon</span>
                  <% } %>
                </div>
              </div>
              <div class="p-3 border-top">
                <a href="/AI/user/lab/detail.jsp?id=<%= project.getId() %>" class="btn btn-outline-success btn-sm w-100">
                  실습 시작하기
                </a>
              </div>
            </div>
          </div>
          <% } %>
          <% if (featuredProjects.isEmpty()) { %>
          <div class="col-12 text-center py-5 text-muted">
            <i class="bi bi-flask" style="font-size: 3rem;"></i>
            <p class="mt-3">등록된 실습 프로젝트가 없습니다.</p>
          </div>
          <% } %>
        </div>
      </div>
    </section>

    <!-- CTA 섹션 -->
    <section class="cta-section py-5 text-white">
      <div class="container text-center py-3">
        <h2 class="fw-bold mb-3" style="font-size:36px;">AI 실무 역량, 지금 바로 시작하세요</h2>
        <p class="lead mb-4 opacity-75">나의 수준과 목표에 맞는 AI 학습 경로를 추천받고,<br>체계적으로 AI 도구를 익히세요.</p>
        <div class="d-flex justify-content-center gap-3 flex-wrap">
          <a href="/AI/user/tools/navigator.jsp?difficulty=Beginner" class="btn btn-light btn-lg px-4">
            <i class="bi bi-stars me-2"></i>초급으로 시작하기
          </a>
          <a href="/AI/user/lab/index.jsp" class="btn btn-outline-light btn-lg px-4">
            <i class="bi bi-flask me-2"></i>실습 랩 바로가기
          </a>
        </div>
      </div>
    </section>
  </main>

  <%@ include file="/AI/partials/footer.jsp" %>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
  <script src="/AI/assets/js/landing.js"></script>
  <script src="/AI/assets/js/gsap-init.js"></script>
</body>
</html>
