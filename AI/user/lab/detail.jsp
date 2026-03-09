<%@ page contentType="text/html; charset=UTF-8" buffer="128kb" autoFlush="true" %>
<%@ page isELIgnored="true" %>
<%@ page import="dao.LabProjectDAO" %>
<%@ page import="model.LabProject" %>
<%@ page import="java.util.List" %>
<%@ include file="/AI/user/_common.jsp" %>

<%
  int projectId = 0;
  try { projectId = Integer.parseInt(request.getParameter("id")); } catch (Exception e) {}
  LabProjectDAO projectDao = new LabProjectDAO();
  LabProject project = projectId > 0 ? projectDao.findById(projectId) : null;

  if (project == null) {
    response.sendRedirect("/AI/user/lab/index.jsp");
    return;
  }

  List<LabProject> related = projectDao.findByCategory(project.getCategory());
  related.removeIf(p -> p.getId() == project.getId());
  if (related.size() > 3) related = related.subList(0, 3);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><%= escapeHtml(project.getTitle()) %> - AI 실습 랩</title>
  <link rel="icon" href="data:,">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
  <link rel="stylesheet" href="/AI/assets/css/dark-theme.css">
  <style>
    body { padding-top: 44px; }
    .step-number { width:36px; height:36px; font-weight:700; font-size:.9rem; flex-shrink:0; }
    .step-content { background: var(--bg-secondary, #1e293b); border-radius:.5rem; padding:1rem; border: 1px solid var(--border-primary, #334155); }
    .goal-chip { display:inline-block; padding:.3rem .75rem; background: rgba(99,102,241,0.15); border-radius:1rem;
                 font-size:.85rem; margin:.2rem; border:1px solid rgba(99,102,241,0.3); color: var(--text-primary, #e2e8f0); }
    .progress-tracker { position:sticky; top:64px; }
  </style>
</head>
<body>
<%@ include file="/AI/partials/header.jsp" %>

<div class="container mt-4">
  <!-- 브레드크럼 -->
  <nav aria-label="breadcrumb" class="mb-3">
    <ol class="breadcrumb">
      <li class="breadcrumb-item"><a href="/AI/user/home.jsp">홈</a></li>
      <li class="breadcrumb-item"><a href="/AI/user/lab/index.jsp">AI 실습 랩</a></li>
      <li class="breadcrumb-item active"><%= escapeHtml(project.getTitle()) %></li>
    </ol>
  </nav>

  <div class="row">
    <!-- 본문 -->
    <div class="col-lg-8">
      <!-- 프로젝트 헤더 카드 -->
      <div class="card shadow-sm mb-4">
        <div class="card-body p-4">
          <div class="d-flex gap-2 mb-3">
            <span class="badge <%= project.getTypeBadgeClass() %> fs-6"><%= project.getProjectType() %></span>
            <span class="badge <%= project.getDifficultyBadgeClass() %> fs-6"><%= project.getDifficultyLevel() %></span>
            <span class="badge bg-secondary fs-6"><%= escapeHtml(project.getCategory()) %></span>
          </div>
          <h1 class="h2 mb-3"><%= escapeHtml(project.getTitle()) %></h1>

          <!-- 통계 -->
          <div class="row g-3 mb-4">
            <div class="col-4 text-center">
              <div class="h4 text-primary mb-0"><%= project.getFormattedDuration() %></div>
              <small class="text-muted">예상 소요 시간</small>
            </div>
            <div class="col-4 text-center border-start border-end">
              <div class="h4 text-success mb-0"><%= project.getStepCount() %></div>
              <small class="text-muted">진행 단계</small>
            </div>
            <div class="col-4 text-center">
              <div class="h4 text-danger mb-0">
                <%= project.getCurrentParticipants() != null ? project.getCurrentParticipants() : 0 %>
              </div>
              <small class="text-muted">참여자</small>
            </div>
          </div>

          <!-- 비즈니스 시나리오 -->
          <% if (project.getBusinessContext() != null && !project.getBusinessContext().trim().isEmpty()) { %>
          <div class="alert alert-primary border-0 mb-4">
            <h5 class="alert-heading"><i class="bi bi-briefcase me-2"></i>비즈니스 시나리오</h5>
            <p class="mb-0"><%= escapeHtml(project.getBusinessContext()) %></p>
          </div>
          <% } %>

          <!-- 프로젝트 목표 -->
          <% if (project.getProjectGoals() != null && !project.getProjectGoals().isEmpty()) { %>
          <div class="mb-4">
            <h4><i class="bi bi-bullseye me-2 text-primary"></i>프로젝트 목표</h4>
            <div>
              <% for (String goal : project.getProjectGoals()) { %>
              <span class="goal-chip"><i class="bi bi-check2 text-success me-1"></i><%= escapeHtml(goal) %></span>
              <% } %>
            </div>
          </div>
          <% } %>
        </div>
      </div>

      <!-- 요구사항 -->
      <% if (project.getRequirements() != null && !project.getRequirements().isEmpty()) { %>
      <div class="card shadow-sm mb-4">
        <div class="card-header">
          <h5 class="mb-0"><i class="bi bi-clipboard-check me-2 text-primary"></i>사전 요구사항</h5>
        </div>
        <div class="card-body">
          <ul class="list-unstyled mb-0">
            <% for (String req : project.getRequirements()) { %>
            <li class="mb-2"><i class="bi bi-check-circle text-success me-2"></i><%= escapeHtml(req) %></li>
            <% } %>
          </ul>
        </div>
      </div>
      <% } %>

      <!-- 단계별 진행 -->
      <% if (project.getStepByStepGuide() != null && !project.getStepByStepGuide().isEmpty()) { %>
      <div class="card shadow-sm mb-4">
        <div class="card-header">
          <h5 class="mb-0"><i class="bi bi-list-ol me-2 text-primary"></i>단계별 실습 가이드</h5>
        </div>
        <div class="card-body">
          <% int stepNum = 1; for (String step : project.getStepByStepGuide()) { %>
          <div class="d-flex mb-4" id="step-<%= stepNum %>">
            <div class="step-number bg-primary text-white rounded-circle d-flex align-items-center justify-content-center me-3">
              <%= stepNum++ %>
            </div>
            <div class="step-content flex-grow-1">
              <p class="mb-0"><%= escapeHtml(step) %></p>
            </div>
          </div>
          <% } %>
        </div>
      </div>
      <% } %>

      <!-- 예상 결과물 -->
      <% if (project.getExpectedOutcomes() != null && !project.getExpectedOutcomes().isEmpty()) { %>
      <div class="card shadow-sm mb-4">
        <div class="card-header bg-success text-white">
          <h5 class="mb-0"><i class="bi bi-trophy me-2"></i>예상 결과물</h5>
        </div>
        <div class="card-body">
          <ul class="list-unstyled mb-0">
            <% for (String outcome : project.getExpectedOutcomes()) { %>
            <li class="mb-2"><i class="bi bi-star-fill text-warning me-2"></i><%= escapeHtml(outcome) %></li>
            <% } %>
          </ul>
        </div>
      </div>
      <% } %>

      <!-- 평가 기준 -->
      <% if (project.getEvaluationCriteria() != null && !project.getEvaluationCriteria().isEmpty()) { %>
      <div class="card shadow-sm mb-4">
        <div class="card-header">
          <h5 class="mb-0"><i class="bi bi-clipboard2-data me-2"></i>평가 기준</h5>
        </div>
        <div class="card-body">
          <% int critNum = 1; for (String crit : project.getEvaluationCriteria()) { %>
          <div class="d-flex align-items-start mb-2">
            <span class="badge bg-primary me-2 mt-1"><%= critNum++ %></span>
            <span><%= escapeHtml(crit) %></span>
          </div>
          <% } %>
        </div>
      </div>
      <% } %>

      <!-- 힌트 -->
      <% if (project.hasHints()) { %>
      <div class="mb-4">
        <button class="btn btn-outline-warning w-100" type="button"
                data-bs-toggle="collapse" data-bs-target="#hintsSection">
          <i class="bi bi-lightbulb me-2"></i>힌트 보기 (막히면 참고하세요)
        </button>
        <div class="collapse mt-3" id="hintsSection">
          <div class="card border-warning">
            <div class="card-body">
              <ul class="mb-0">
                <% for (String hint : project.getHints()) { %>
                <li class="mb-2"><%= escapeHtml(hint) %></li>
                <% } %>
              </ul>
            </div>
          </div>
        </div>
      </div>
      <% } %>

      <!-- 결과물 제출 CTA -->
      <div class="card shadow-sm bg-dark text-white mb-4">
        <div class="card-body text-center p-4">
          <h4><i class="bi bi-send me-2"></i>결과물 제출하기</h4>
          <p class="text-light mb-4">프로젝트를 완료하셨나요? 결과물을 포트폴리오로 저장하세요.</p>
          <a href="/AI/user/portfolio/submit.jsp?projectId=<%= project.getId() %>"
             class="btn btn-light btn-lg">
            <i class="bi bi-collection me-2"></i>포트폴리오에 저장
          </a>
        </div>
      </div>
    </div>

    <!-- 사이드바 -->
    <aside class="col-lg-4">
      <!-- 진행 트래커 -->
      <div class="card shadow-sm mb-4 progress-tracker">
        <div class="card-header bg-primary text-white">
          <h5 class="mb-0"><i class="bi bi-check2-circle me-2"></i>진행 상황</h5>
        </div>
        <div class="card-body">
          <div class="mb-3">
            <div class="d-flex justify-content-between mb-1">
              <small>진행률</small>
              <small id="progressPct">0%</small>
            </div>
            <div class="progress">
              <div class="progress-bar bg-success" id="progressBar" style="width:0%"></div>
            </div>
          </div>
          <div id="stepChecklist">
            <% int sNum = 1; if (project.getStepByStepGuide() != null) {
               for (String s : project.getStepByStepGuide()) { %>
            <div class="form-check mb-2">
              <input class="form-check-input step-check" type="checkbox" id="chk<%= sNum %>"
                     onchange="updateProgress()">
              <label class="form-check-label small" for="chk<%= sNum %>">
                단계 <%= sNum++ %>: <%= escapeHtml(s.length() > 45 ? s.substring(0, 45) + "…" : s) %>
              </label>
            </div>
            <% } } %>
          </div>
          <button class="btn btn-success w-100 mt-3" onclick="markAllDone()">
            <i class="bi bi-check-all me-1"></i>모두 완료
          </button>
        </div>
      </div>

      <!-- 필요 도구 -->
      <% if (project.getToolsRequired() != null && !project.getToolsRequired().isEmpty()) { %>
      <div class="card shadow-sm mb-4">
        <div class="card-header">
          <h5 class="mb-0"><i class="bi bi-tools me-2"></i>필요한 AI 도구</h5>
        </div>
        <div class="card-body p-0">
          <ul class="list-group list-group-flush">
            <% for (String tool : project.getToolsRequired()) { %>
            <li class="list-group-item d-flex justify-content-between align-items-center">
              <span><i class="bi bi-cpu me-2 text-primary"></i><%= escapeHtml(tool) %></span>
              <a href="/AI/user/tools/navigator.jsp?keyword=<%= escapeHtmlAttribute(tool) %>"
                 class="btn btn-outline-primary btn-sm" target="_blank">찾기</a>
            </li>
            <% } %>
          </ul>
        </div>
      </div>
      <% } %>

      <!-- 관련 프로젝트 -->
      <% if (!related.isEmpty()) { %>
      <div class="card shadow-sm">
        <div class="card-header">
          <h5 class="mb-0"><i class="bi bi-grid me-2"></i>관련 프로젝트</h5>
        </div>
        <div class="card-body p-0">
          <ul class="list-group list-group-flush">
            <% for (LabProject r : related) { %>
            <li class="list-group-item">
              <a href="/AI/user/lab/detail.jsp?id=<%= r.getId() %>" class="text-decoration-none d-block">
                <div><span class="badge <%= r.getDifficultyBadgeClass() %> me-1"><%= r.getDifficultyLevel() %></span>
                  <%= escapeHtml(r.getTitle()) %></div>
                <div class="small text-muted mt-1">
                  <i class="bi bi-clock me-1"></i><%= r.getFormattedDuration() %>
                </div>
              </a>
            </li>
            <% } %>
          </ul>
        </div>
      </div>
      <% } %>
    </aside>
  </div>
</div>

<%@ include file="/AI/partials/footer.jsp" %>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
  const totalSteps = document.querySelectorAll('.step-check').length;

  function updateProgress() {
    const checked = document.querySelectorAll('.step-check:checked').length;
    const pct = totalSteps > 0 ? Math.round(checked / totalSteps * 100) : 0;
    document.getElementById('progressBar').style.width = pct + '%';
    document.getElementById('progressPct').textContent = pct + '%';
  }

  function markAllDone() {
    document.querySelectorAll('.step-check').forEach(c => c.checked = true);
    updateProgress();
  }
</script>
</body>
</html>
