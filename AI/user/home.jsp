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
  <link rel="icon" href="data:,">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
  <link rel="stylesheet" href="/AI/assets/css/dark-theme.css">
  <link rel="stylesheet" href="/AI/assets/css/animations.css">
  <script src="https://cdn.jsdelivr.net/npm/gsap@3.12.2/dist/gsap.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/gsap@3.12.2/dist/ScrollTrigger.min.js"></script>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, 'Noto Sans KR', sans-serif; }

    /* AI Provider logos section */
    .ai-logos-section { background: #0a0f1e; padding: 40px 0; overflow: hidden; border-top: 1px solid #1e293b; border-bottom: 1px solid #1e293b; }
    .ai-logos-track { display: flex; gap: 40px; align-items: center; animation: scrollLogos 30s linear infinite; width: max-content; }
    .ai-logos-track:hover { animation-play-state: paused; }
    .ai-logo-item { display: flex; flex-direction: column; align-items: center; gap: 8px; opacity: 0.5; transition: opacity 0.2s; flex-shrink: 0; }
    .ai-logo-item:hover { opacity: 1; }
    .ai-logo-item img { width: 48px; height: 48px; border-radius: 10px; }
    .ai-logo-item span { font-size: 11px; color: #64748b; font-weight: 500; }
    @keyframes scrollLogos { 0% { transform: translateX(0); } 100% { transform: translateX(-50%); } }

    /* Section titles */
    .home-section-title { font-size: 32px; font-weight: 600; color: var(--text-primary, #e2e8f0); letter-spacing: -0.003em; margin-bottom: 6px; }
    .home-section-sub { font-size: 17px; color: var(--text-secondary, #94a3b8); margin-bottom: 0; }

    /* AI Tool Cards */
    .ai-tool-card { background: var(--bg-card, #1e293b); border: 1px solid var(--border-primary, #334155); border-radius: 12px; overflow: hidden; display: flex; flex-direction: column; height: 100%; transition: all 0.2s ease; }
    .ai-tool-card:hover { border-color: var(--border-hover, #6366f1); box-shadow: var(--shadow-glow, 0 0 20px rgba(99,102,241,0.3)); transform: translateY(-4px); }
    .ai-tool-card-header { padding: 12px 16px; border-bottom: 1px solid var(--border-primary, #334155); background: var(--bg-tertiary, #334155); display: flex; justify-content: space-between; align-items: center; }
    .ai-tool-card-body { padding: 16px; flex: 1; }
    .ai-tool-card-title { font-size: 15px; font-weight: 600; color: var(--text-primary, #e2e8f0); margin-bottom: 8px; }
    .ai-tool-card-desc { font-size: 13px; color: var(--text-secondary, #94a3b8); display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; margin-bottom: 12px; }
    .ai-tool-card-footer { padding: 12px 16px; border-top: 1px solid var(--border-primary, #334155); }

    /* Provider logos */
    .provider-logo { width: 24px; height: 24px; border-radius: 6px; object-fit: contain; }
    .provider-logo-fallback { width: 24px; height: 24px; display: flex; align-items: center; justify-content: center; background: var(--bg-tertiary, #334155); border-radius: 6px; font-size: 14px; }

    /* Platform cards */
    .platform-card { padding: 2rem; border-radius: 16px; height: 100%; transition: all 0.2s ease; }
    .platform-card:hover { transform: translateY(-4px); box-shadow: 0 20px 40px rgba(0,0,0,0.3); }

    /* CTA section */
    .cta-section { background: linear-gradient(135deg, #4338ca 0%, #6366f1 40%, #8b5cf6 100%); }

    /* Sections */
    .tools-section { background: var(--bg-secondary, #1e293b); padding: 64px 0; }

    .badge-beginner { background: rgba(16, 185, 129, 0.2); color: var(--difficulty-beginner, #10b981); border: 1px solid rgba(16, 185, 129, 0.3); }
    .badge-intermediate { background: rgba(245, 158, 11, 0.2); color: var(--difficulty-intermediate, #f59e0b); border: 1px solid rgba(245, 158, 11, 0.3); }
    .badge-advanced { background: rgba(239, 68, 68, 0.2); color: var(--difficulty-advanced, #ef4444); border: 1px solid rgba(239, 68, 68, 0.3); }
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
    <section class="py-5 tools-section">
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
