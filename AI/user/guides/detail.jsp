<%@ page contentType="text/html; charset=UTF-8" buffer="128kb" autoFlush="true" %>
<%@ page isELIgnored="true" %>
<%@ page import="dao.WorkflowGuideDAO" %>
<%@ page import="model.WorkflowGuide" %>
<%@ page import="java.util.List" %>
<%@ include file="/AI/user/_common.jsp" %>

<%
  int guideId = 0;
  try { guideId = Integer.parseInt(request.getParameter("id")); } catch (Exception e) {}
  WorkflowGuideDAO guideDao = new WorkflowGuideDAO();
  WorkflowGuide guide = guideId > 0 ? guideDao.findById(guideId) : null;

  if (guide == null) {
    response.sendRedirect("/AI/user/guides/index.jsp");
    return;
  }
  // 조회수 증가
  guideDao.incrementViewCount(guideId);

  List<WorkflowGuide> related = guideDao.findByCategory(guide.getCategory());
  related.removeIf(g -> g.getId() == guide.getId());
  if (related.size() > 4) related = related.subList(0, 4);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><%= escapeHtml(guide.getTitle()) %> - AI Workflow Lab</title>
  <link rel="stylesheet" href="/AI/assets/css/landing.css">
</head>
<body>
<%@ include file="/AI/partials/header.jsp" %>

<div class="container mt-4">
  <!-- 브레드크럼 -->
  <nav aria-label="breadcrumb" class="mb-3">
    <ol class="breadcrumb">
      <li class="breadcrumb-item"><a href="/AI/user/home.jsp">홈</a></li>
      <li class="breadcrumb-item"><a href="/AI/user/guides/index.jsp">워크플로우 가이드</a></li>
      <li class="breadcrumb-item active"><%= escapeHtml(guide.getTitle()) %></li>
    </ol>
  </nav>

  <div class="row">
    <!-- 본문 -->
    <div class="col-lg-8">
      <div class="card shadow-sm mb-4">
        <div class="card-body p-4">
          <!-- 헤더 -->
          <div class="d-flex gap-2 mb-3">
            <span class="badge bg-info text-dark fs-6"><%= escapeHtml(guide.getCategory()) %></span>
            <span class="badge <%= guide.getDifficultyBadgeClass() %> fs-6"><%= guide.getDifficultyLevel() %></span>
          </div>
          <h1 class="h2 mb-2"><%= escapeHtml(guide.getTitle()) %></h1>
          <p class="lead text-muted"><%= escapeHtml(safeString(guide.getDescription(), "")) %></p>

          <!-- 메타 정보 -->
          <div class="d-flex gap-4 text-muted small py-3 border-top border-bottom mb-4">
            <span><i class="bi bi-clock me-1"></i><%= guide.getFormattedDuration() %></span>
            <span><i class="bi bi-list-ol me-1"></i><%= guide.getStepCount() %>단계</span>
            <span><i class="bi bi-eye me-1"></i><%= (guide.getViewCount() != null ? guide.getViewCount() : 0) + 1 %>회 조회</span>
            <span><i class="bi bi-hand-thumbs-up me-1"></i><%= guide.getLikeCount() != null ? guide.getLikeCount() : 0 %>개 좋아요</span>
          </div>

          <!-- 학습 목표 -->
          <% if (guide.getLearningObjectives() != null && !guide.getLearningObjectives().isEmpty()) { %>
          <div class="mb-4">
            <h4><i class="bi bi-bullseye me-2 text-primary"></i>학습 목표</h4>
            <ul class="list-group list-group-flush">
              <% for (String obj : guide.getLearningObjectives()) { %>
              <li class="list-group-item">
                <i class="bi bi-check-circle-fill text-success me-2"></i><%= escapeHtml(obj) %>
              </li>
              <% } %>
            </ul>
          </div>
          <% } %>

          <!-- 선행 조건 -->
          <% if (guide.hasPrerequisites()) { %>
          <div class="alert alert-info mb-4">
            <h5><i class="bi bi-info-circle me-2"></i>선행 조건</h5>
            <ul class="mb-0">
              <% for (String pre : guide.getPrerequisites()) { %>
              <li><%= escapeHtml(pre) %></li>
              <% } %>
            </ul>
          </div>
          <% } %>

          <!-- 단계별 가이드 -->
          <% if (guide.getSteps() != null && !guide.getSteps().isEmpty()) { %>
          <div class="mb-4">
            <h4><i class="bi bi-list-check me-2 text-primary"></i>단계별 진행 방법</h4>
            <div class="steps-list">
              <% int stepNum = 1; for (String step : guide.getSteps()) { %>
              <div class="d-flex mb-3">
                <div class="step-number bg-primary text-white rounded-circle d-flex align-items-center justify-content-center me-3 flex-shrink-0"
                     style="width:32px;height:32px;font-weight:600;font-size:.9rem;">
                  <%= stepNum++ %>
                </div>
                <div class="step-content p-3 bg-light rounded flex-grow-1">
                  <%= escapeHtml(step) %>
                </div>
              </div>
              <% } %>
            </div>
          </div>
          <% } %>

          <!-- 샘플 프롬프트 -->
          <% if (guide.getSamplePrompts() != null && !guide.getSamplePrompts().isEmpty()) { %>
          <div class="mb-4">
            <h4><i class="bi bi-chat-quote me-2 text-primary"></i>샘플 프롬프트</h4>
            <% for (String prompt : guide.getSamplePrompts()) { %>
            <div class="card mb-2 border-primary">
              <div class="card-body py-2 px-3 d-flex justify-content-between align-items-start">
                <code class="text-primary"><%= escapeHtml(prompt) %></code>
                <button class="btn btn-outline-secondary btn-sm ms-2 copy-btn" data-text="<%= escapeHtmlAttribute(prompt) %>">
                  <i class="bi bi-clipboard"></i>
                </button>
              </div>
            </div>
            <% } %>
          </div>
          <% } %>

          <!-- 팁 & 트릭 -->
          <% if (guide.getTipsTricks() != null && !guide.getTipsTricks().trim().isEmpty()) { %>
          <div class="alert alert-success mb-4">
            <h5><i class="bi bi-lightbulb me-2"></i>팁 &amp; 트릭</h5>
            <p class="mb-0"><%= escapeHtml(guide.getTipsTricks()) %></p>
          </div>
          <% } %>

          <!-- 흔한 실수 -->
          <% if (guide.getCommonMistakes() != null && !guide.getCommonMistakes().isEmpty()) { %>
          <div class="alert alert-warning mb-4">
            <h5><i class="bi bi-exclamation-triangle me-2"></i>주의사항 &amp; 흔한 실수</h5>
            <ul class="mb-0">
              <% for (String mistake : guide.getCommonMistakes()) { %>
              <li><%= escapeHtml(mistake) %></li>
              <% } %>
            </ul>
          </div>
          <% } %>

          <!-- 좋아요 버튼 -->
          <div class="text-center border-top pt-3 mt-4">
            <button class="btn btn-outline-danger btn-lg" id="likeBtn" onclick="likeGuide(<%= guide.getId() %>)">
              <i class="bi bi-heart me-2"></i>도움이 됐어요 
              <span id="likeCount">(<%= guide.getLikeCount() != null ? guide.getLikeCount() : 0 %>)</span>
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- 사이드바 -->
    <aside class="col-lg-4">
      <!-- 필요 도구 -->
      <% if (guide.hasRequiredTools()) { %>
      <div class="card shadow-sm mb-4">
        <div class="card-header bg-dark text-white">
          <h5 class="mb-0"><i class="bi bi-tools me-2"></i>필요한 도구</h5>
        </div>
        <div class="card-body p-0">
          <ul class="list-group list-group-flush">
            <% for (String tool : guide.getToolsRequired()) { %>
            <li class="list-group-item d-flex justify-content-between align-items-center">
              <%= escapeHtml(tool) %>
              <a href="/AI/user/tools/navigator.jsp?keyword=<%= escapeHtmlAttribute(tool) %>"
                 class="btn btn-outline-primary btn-sm">찾기</a>
            </li>
            <% } %>
          </ul>
        </div>
      </div>
      <% } %>

      <!-- 관련 가이드 -->
      <% if (!related.isEmpty()) { %>
      <div class="card shadow-sm">
        <div class="card-header">
          <h5 class="mb-0"><i class="bi bi-bookmark me-2"></i>관련 가이드</h5>
        </div>
        <div class="card-body p-0">
          <ul class="list-group list-group-flush">
            <% for (WorkflowGuide r : related) { %>
            <li class="list-group-item">
              <a href="/AI/user/guides/detail.jsp?id=<%= r.getId() %>" class="text-decoration-none">
                <span class="badge <%= r.getDifficultyBadgeClass() %> me-1"><%= r.getDifficultyLevel() %></span>
                <%= escapeHtml(r.getTitle()) %>
              </a>
              <div class="small text-muted mt-1"><i class="bi bi-clock me-1"></i><%= r.getFormattedDuration() %></div>
            </li>
            <% } %>
          </ul>
        </div>
      </div>
      <% } %>

      <!-- 실습 랩 CTA -->
      <div class="card shadow-sm mt-4 bg-success text-white">
        <div class="card-body text-center p-4">
          <i class="bi bi-flask display-4 mb-2"></i>
          <h5>배운 내용을 실습해보세요!</h5>
          <p class="small mb-3">실제 프로젝트를 통해 AI 활용 능력을 키워보세요.</p>
          <a href="/AI/user/lab/index.jsp" class="btn btn-outline-light w-100">실습 랩 바로가기</a>
        </div>
      </div>
    </aside>
  </div>

  <!-- 연관 가이드 목록 -->
  <% if (!related.isEmpty()) { %>
  <hr class="my-5">
  <h3 class="mb-4">같은 카테고리 가이드</h3>
  <div class="row g-4">
    <% for (WorkflowGuide r : related) { %>
    <div class="col-lg-3 col-md-6">
      <div class="card h-100 shadow-sm">
        <div class="card-body">
          <div class="d-flex justify-content-between mb-2">
            <span class="badge bg-info text-dark"><%= escapeHtml(r.getCategory()) %></span>
            <span class="badge <%= r.getDifficultyBadgeClass() %>"><%= r.getDifficultyLevel() %></span>
          </div>
          <h6 class="card-title"><%= escapeHtml(r.getTitle()) %></h6>
          <p class="card-text text-muted small"><%= escapeHtml(safeString(r.getDescription(), "")) %></p>
        </div>
        <div class="card-footer bg-transparent">
          <a href="/AI/user/guides/detail.jsp?id=<%= r.getId() %>" class="btn btn-outline-primary btn-sm w-100">보기</a>
        </div>
      </div>
    </div>
    <% } %>
  </div>
  <% } %>
</div>

<%@ include file="/AI/partials/footer.jsp" %>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
  // 프롬프트 복사
  document.querySelectorAll('.copy-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      navigator.clipboard.writeText(btn.dataset.text).then(() => {
        btn.innerHTML = '<i class="bi bi-check2"></i>';
        setTimeout(() => btn.innerHTML = '<i class="bi bi-clipboard"></i>', 2000);
      });
    });
  });

  // 좋아요 기능
  let liked = false;
  function likeGuide(id) {
    if (liked) return;
    liked = true;
    fetch('/AI/api/guides/' + id + '/like', { method: 'POST' });
    const count = document.getElementById('likeCount');
    const cur = parseInt(count.textContent.replace(/[()]/g, ''));
    count.textContent = '(' + (cur + 1) + ')';
    document.getElementById('likeBtn').classList.replace('btn-outline-danger', 'btn-danger');
  }
</script>
</body>
</html>
