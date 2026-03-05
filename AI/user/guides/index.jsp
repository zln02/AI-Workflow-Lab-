<%@ page contentType="text/html; charset=UTF-8" buffer="128kb" autoFlush="true" %>
<%@ page isELIgnored="true" %>
<%@ page import="dao.WorkflowGuideDAO" %>
<%@ page import="model.WorkflowGuide" %>
<%@ page import="java.util.List" %>
<%@ include file="/AI/user/_common.jsp" %>

<%
  WorkflowGuideDAO guideDao = new WorkflowGuideDAO();

  String keyword  = request.getParameter("keyword");
  String category = request.getParameter("category");
  String diff     = request.getParameter("difficulty");

  List<WorkflowGuide> guides;
  String pageTitle = "워크플로우 가이드";

  if (keyword != null && !keyword.trim().isEmpty()) {
      guides = guideDao.searchByKeyword(keyword);
      pageTitle = "검색: " + escapeHtml(keyword);
  } else if (category != null && !category.trim().isEmpty()) {
      guides = guideDao.findByCategory(category);
      pageTitle = escapeHtml(category);
  } else if (diff != null && !diff.trim().isEmpty()) {
      guides = guideDao.findByDifficulty(diff);
      pageTitle = escapeHtml(diff) + " 가이드";
  } else {
      guides = guideDao.findAll();
  }

  List<WorkflowGuide> popular = guideDao.findPopular(5);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><%= pageTitle %> - AI Workflow Lab</title>
  <link rel="stylesheet" href="/AI/assets/css/landing.css">
</head>
<body>
<%@ include file="/AI/partials/header.jsp" %>

<div class="container-fluid mt-4">
  <div class="row">
    <!-- 사이드바 -->
    <aside class="col-lg-3 col-md-4 mb-4">
      <div class="card shadow-sm mb-4">
        <div class="card-header bg-primary text-white">
          <h5 class="mb-0"><i class="bi bi-funnel"></i> 필터</h5>
        </div>
        <div class="card-body">
          <form method="get">
            <div class="mb-3">
              <label class="form-label fw-semibold">키워드 검색</label>
              <div class="input-group">
                <input type="text" class="form-control" name="keyword"
                       value="<%= escapeHtml(keyword != null ? keyword : "") %>" placeholder="가이드 검색...">
                <button class="btn btn-outline-primary" type="submit"><i class="bi bi-search"></i></button>
              </div>
            </div>
            <div class="mb-3">
              <label class="form-label fw-semibold">카테고리</label>
              <select class="form-select" name="category" onchange="this.form.submit()">
                <option value="">전체</option>
                <option value="Content Creation"  <%= "Content Creation".equals(category)  ? "selected":"" %>>콘텐츠 제작</option>
                <option value="Marketing"         <%= "Marketing".equals(category)         ? "selected":"" %>>마케팅</option>
                <option value="Development"       <%= "Development".equals(category)       ? "selected":"" %>>개발</option>
                <option value="Data Analysis"     <%= "Data Analysis".equals(category)     ? "selected":"" %>>데이터 분석</option>
                <option value="Business"          <%= "Business".equals(category)          ? "selected":"" %>>비즈니스</option>
              </select>
            </div>
            <div class="mb-3">
              <label class="form-label fw-semibold">난이도</label>
              <select class="form-select" name="difficulty" onchange="this.form.submit()">
                <option value="">전체</option>
                <option value="Beginner"     <%= "Beginner".equals(diff)     ? "selected":"" %>>초급</option>
                <option value="Intermediate" <%= "Intermediate".equals(diff) ? "selected":"" %>>중급</option>
                <option value="Advanced"     <%= "Advanced".equals(diff)     ? "selected":"" %>>고급</option>
              </select>
            </div>
          </form>
        </div>
      </div>

      <!-- 인기 가이드 -->
      <div class="card shadow-sm">
        <div class="card-header bg-warning text-dark">
          <h5 class="mb-0"><i class="bi bi-fire"></i> 인기 가이드</h5>
        </div>
        <div class="card-body p-0">
          <ul class="list-group list-group-flush">
            <% for (WorkflowGuide g : popular) { %>
            <li class="list-group-item">
              <a href="/AI/user/guides/detail.jsp?id=<%= g.getId() %>" class="text-decoration-none">
                <span class="badge <%= g.getDifficultyBadgeClass() %> me-1"><%= g.getDifficultyLevel() %></span>
                <%= escapeHtml(g.getTitle()) %>
              </a>
              <div class="small text-muted mt-1">
                <i class="bi bi-eye"></i> <%= g.getViewCount() != null ? g.getViewCount() : 0 %>
                &nbsp;<i class="bi bi-clock"></i> <%= g.getFormattedDuration() %>
              </div>
            </li>
            <% } %>
          </ul>
        </div>
      </div>
    </aside>

    <!-- 메인 -->
    <main class="col-lg-9 col-md-8">
      <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
          <h1 class="h3 mb-1"><%= pageTitle %></h1>
          <p class="text-muted mb-0">총 <strong><%= guides.size() %></strong>개의 가이드</p>
        </div>
      </div>

      <div class="row g-4">
        <% if (guides.isEmpty()) { %>
        <div class="col-12 text-center py-5 text-muted">
          <i class="bi bi-journal-x display-1"></i>
          <h4 class="mt-3">가이드가 없습니다</h4>
          <p>다른 키워드나 필터로 시도해보세요.</p>
        </div>
        <% } else { for (WorkflowGuide g : guides) { %>
        <div class="col-lg-4 col-md-6">
          <div class="card h-100 shadow-sm">
            <div class="card-body">
              <div class="d-flex justify-content-between mb-2">
                <span class="badge bg-info text-dark"><%= escapeHtml(g.getCategory()) %></span>
                <span class="badge <%= g.getDifficultyBadgeClass() %>"><%= g.getDifficultyLevel() %></span>
              </div>
              <h5 class="card-title"><%= escapeHtml(g.getTitle()) %></h5>
              <p class="card-text text-muted small"><%= escapeHtml(safeString(g.getDescription(), "")) %></p>
              <% if (g.hasRequiredTools()) { %>
              <div class="small text-muted mb-2">
                <i class="bi bi-tools me-1"></i>
                <%= g.getToolsRequired().size() %>개 도구 필요
              </div>
              <% } %>
              <div class="d-flex gap-3 text-muted small">
                <span><i class="bi bi-clock me-1"></i><%= g.getFormattedDuration() %></span>
                <span><i class="bi bi-list-ol me-1"></i><%= g.getStepCount() %>단계</span>
                <span><i class="bi bi-eye me-1"></i><%= g.getViewCount() != null ? g.getViewCount() : 0 %></span>
              </div>
            </div>
            <div class="card-footer bg-transparent">
              <a href="/AI/user/guides/detail.jsp?id=<%= g.getId() %>" class="btn btn-primary btn-sm w-100">
                <i class="bi bi-play-circle me-1"></i>가이드 보기
              </a>
            </div>
          </div>
        </div>
        <% } } %>
      </div>
    </main>
  </div>
</div>

<%@ include file="/AI/partials/footer.jsp" %>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
