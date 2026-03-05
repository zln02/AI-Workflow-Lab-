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
  <link rel="stylesheet" href="/AI/assets/css/landing.css">
  <link rel="stylesheet" href="/AI/assets/css/animations.css">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <script src="https://cdn.jsdelivr.net/npm/gsap@3.12.2/dist/gsap.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/gsap@3.12.2/dist/ScrollTrigger.min.js"></script>
</head>
<body>
  <%@ include file="/AI/partials/header.jsp" %>
  
  <main>
    <%@ include file="/AI/partials/key-visual.jsp" %>

    <!-- 플랫폼 소개 섹션 -->
    <section class="platform-intro py-5 bg-light">
      <div class="container">
        <div class="row g-4 text-center justify-content-center">
          <div class="col-md-5">
            <div class="intro-card h-100 p-4 bg-primary text-white rounded shadow">
              <div class="intro-icon mb-3">
                <i class="bi bi-compass display-4"></i>
              </div>
              <h4>AI 도구 탐색</h4>
              <p>업무 목적에 맞는 AI 도구를 추천받고, 최신 도구를 쉽게 비교·탐색할 수 있습니다.</p>
              <a href="/AI/user/tools/navigator.jsp" class="btn btn-outline-light btn-sm mt-2">도구 탐색하기</a>
            </div>
          </div>
          <div class="col-md-5">
            <div class="intro-card h-100 p-4 bg-success text-white rounded shadow">
              <div class="intro-icon mb-3">
                <i class="bi bi-flask display-4"></i>
              </div>
              <h4>AI 실습 랩</h4>
              <p>실제 비즈니스 시나리오 기반 프로젝트를 직접 수행하며 AI 실무 역량을 쌓으세요.</p>
              <a href="/AI/user/lab/index.jsp" class="btn btn-outline-light btn-sm mt-2">실습 시작하기</a>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- 인기 AI 도구 섹션 -->
    <section class="featured-tools py-5">
      <div class="container">
        <div class="d-flex justify-content-between align-items-center mb-5">
          <div>
            <h2 class="section-title mb-1">인기 AI 도구</h2>
            <p class="section-subtitle text-muted mb-0">가장 많이 활용되는 AI 도구들을 만나보세요</p>
          </div>
          <a href="/AI/user/tools/navigator.jsp" class="btn btn-outline-primary">전체 도구 보기</a>
        </div>

        <div class="row g-4">
          <% for (AITool tool : featuredTools) { %>
          <div class="col-lg-3 col-md-4 col-sm-6">
            <div class="model-card h-100">
              <div class="model-header d-flex justify-content-between align-items-center">
                <% String[] logoInfo = getProviderLogo(tool.getProviderName(), tool.getToolName()); %>
                <img src="<%= logoInfo[0] %>" alt="<%= escapeHtml(tool.getProviderName()) %>" class="provider-logo">
                <span class="badge <%= tool.getDifficultyBadgeClass() %>"><%= tool.getDifficultyLevel() %></span>
              </div>
              <div class="model-body">
                <h5 class="model-title"><%= escapeHtml(tool.getToolName()) %></h5>
                <p class="model-description text-muted small"><%= escapeHtml(safeString(tool.getPurposeSummary(), "")) %></p>
                <div class="d-flex align-items-center gap-2 mb-2">
                  <span class="badge bg-light text-dark border"><%= escapeHtml(tool.getCategory()) %></span>
                  <% if (tool.isFreeTierAvailable()) { %>
                  <span class="badge bg-success">무료 플랜</span>
                  <% } %>
                </div>
                <div class="text-warning small">
                  <%= tool.getStarRating() %>
                  <span class="text-muted">(<%= tool.getReviewCount() != null ? tool.getReviewCount() : 0 %>)</span>
                </div>
              </div>
              <div class="model-footer">
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
    <section class="lab-projects py-5">
      <div class="container">
        <div class="d-flex justify-content-between align-items-center mb-5">
          <div>
            <h2 class="section-title mb-1">AI 실습 랩</h2>
            <p class="section-subtitle text-muted mb-0">실제 비즈니스 시나리오로 AI 역량을 키우세요</p>
          </div>
          <a href="/AI/user/lab/index.jsp" class="btn btn-outline-success">전체 프로젝트 보기</a>
        </div>

        <div class="row g-4">
          <% for (LabProject project : featuredProjects) { %>
          <div class="col-lg-3 col-md-6">
            <div class="card h-100 shadow-sm border-0">
              <div class="card-body">
                <div class="d-flex justify-content-between mb-2">
                  <span class="badge <%= project.getTypeBadgeClass() %>"><%= project.getProjectType() %></span>
                  <span class="badge <%= project.getDifficultyBadgeClass() %>"><%= project.getDifficultyLevel() %></span>
                </div>
                <h5 class="card-title"><%= escapeHtml(project.getTitle()) %></h5>
                <p class="card-text text-muted small"><%= escapeHtml(safeString(project.getDescription(), "")) %></p>
                <div class="mt-3 small text-muted">
                  <div><i class="bi bi-clock me-1"></i><%= project.getFormattedDuration() %></div>
                  <div class="mt-1">
                    <i class="bi bi-people me-1"></i>
                    <%= project.getCurrentParticipants() != null ? project.getCurrentParticipants() : 0 %>명 참여 중
                  </div>
                </div>
              </div>
              <div class="card-footer bg-transparent">
                <a href="/AI/user/lab/detail.jsp?id=<%= project.getId() %>" class="btn btn-success btn-sm w-100">
                  실습 시작하기
                </a>
              </div>
            </div>
          </div>
          <% } %>
          <% if (featuredProjects.isEmpty()) { %>
          <div class="col-12 text-center py-4 text-muted">
            <i class="bi bi-flask display-4"></i>
            <p class="mt-2">등록된 실습 프로젝트가 없습니다.</p>
          </div>
          <% } %>
        </div>
      </div>
    </section>

    <!-- 학습 경로 CTA 섹션 -->
    <section class="cta-section py-5 bg-primary text-white">
      <div class="container text-center">
        <h2 class="mb-3">AI 실무 역량, 지금 바로 시작하세요</h2>
        <p class="lead mb-4">나의 수준과 목표에 맞는 AI 학습 경로를 추천받고,<br>체계적으로 AI 도구를 익히세요.</p>
        <div class="d-flex justify-content-center gap-3 flex-wrap">
          <a href="/AI/user/tools/navigator.jsp?difficulty=Beginner" class="btn btn-light btn-lg">
            <i class="bi bi-stars me-2"></i>초급으로 시작하기
          </a>
          <a href="/AI/user/lab/index.jsp" class="btn btn-outline-light btn-lg">
            <i class="bi bi-flask me-2"></i>실습 랩 바로가기
          </a>
        </div>
      </div>
    </section>
  </main>

  <%@ include file="/AI/partials/footer.jsp" %>

  <script src="/AI/assets/js/landing.js"></script>
  <script src="/AI/assets/js/gsap-init.js"></script>
</body>
</html>
