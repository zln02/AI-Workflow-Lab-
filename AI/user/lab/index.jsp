<%@ page contentType="text/html; charset=UTF-8" buffer="128kb" autoFlush="true" %>
<%@ page isELIgnored="true" %>
<%@ page import="dao.LabProjectDAO" %>
<%@ page import="model.LabProject" %>
<%@ page import="java.util.List" %>
<%@ include file="/AI/user/_common.jsp" %>

<%
  LabProjectDAO projectDao = new LabProjectDAO();

  String keyword  = request.getParameter("keyword");
  String category = request.getParameter("category");
  String diff     = request.getParameter("difficulty");
  String ptype    = request.getParameter("type");

  List<LabProject> projects;
  String pageTitle = "AI 실습 랩";

  if (keyword != null && !keyword.trim().isEmpty()) {
      projects = projectDao.searchByKeyword(keyword);
      pageTitle = "검색: " + escapeHtml(keyword);
  } else if (category != null && !category.trim().isEmpty()) {
      projects = projectDao.findByCategory(category);
  } else if (diff != null && !diff.trim().isEmpty()) {
      projects = projectDao.findByDifficulty(diff);
  } else if (ptype != null && !ptype.trim().isEmpty()) {
      projects = projectDao.findByType(ptype);
  } else {
      projects = projectDao.findAll();
  }

  List<LabProject> popular = projectDao.findPopular(5);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><%= pageTitle %> - AI Workflow Lab</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <style>
    body { padding-top: 44px; font-family: -apple-system, BlinkMacSystemFont, 'Noto Sans KR', sans-serif; }
    .navbar { position: fixed; top: 0; left: 0; right: 0; z-index: 1000; background: rgba(255,255,255,0.9); backdrop-filter: blur(20px); border-bottom: 0.5px solid rgba(0,0,0,0.1); height: 44px; display: flex; align-items: center; padding: 0; }
    .navbar-container { max-width: 1200px; margin: 0 auto; display: flex; justify-content: space-between; align-items: center; width: 100%; padding: 0 20px; }
    .navbar-logo { font-size: 17px; font-weight: 500; color: #1d1d1f; text-decoration: none; }
    .navbar-menu-wrapper { display: flex; align-items: center; gap: 2rem; }
    .navbar-menu { display: flex; gap: 1.5rem; list-style: none; align-items: center; margin: 0; padding: 0; }
    .navbar-menu a { color: #1d1d1f; text-decoration: none; font-size: 13px; }
    .navbar-menu a:hover, .navbar-menu a.active { color: #0071e3; }
    .navbar-toggle { display: none; background: none; border: none; color: #1d1d1f; font-size: 1.5rem; cursor: pointer; }
    .lab-card { border-radius: 12px; transition: all 0.2s ease; border: 1px solid #e9ecef; }
    .lab-card:hover { transform: translateY(-4px); box-shadow: 0 8px 24px rgba(0,0,0,0.1); border-color: #198754; }
  </style>
</head>
<body>
<%@ include file="/AI/partials/header.jsp" %>

<!-- Hero Banner -->
<div class="bg-dark text-white py-4 mb-4">
  <div class="container">
    <div class="row align-items-center">
      <div class="col-md-8">
        <h1 class="h2 mb-1"><i class="bi bi-flask me-2"></i>AI 실습 랩</h1>
        <p class="mb-0 text-light">실제 비즈니스 문제를 AI로 해결하며 실무 역량을 키워보세요.</p>
      </div>
      <div class="col-md-4 text-md-end mt-3 mt-md-0">
        <div class="d-flex justify-content-md-end gap-3">
          <div class="text-center">
            <div class="h4 mb-0"><%= projects.size() %></div>
            <small class="text-muted">프로젝트</small>
          </div>
          <div class="text-center">
            <div class="h4 mb-0">3</div>
            <small class="text-muted">난이도</small>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<div class="container-fluid">
  <div class="row">
    <!-- 사이드바 -->
    <aside class="col-lg-3 col-md-4 mb-4">
      <div class="card shadow-sm mb-4">
        <div class="card-header bg-success text-white">
          <h5 class="mb-0"><i class="bi bi-funnel"></i> 필터</h5>
        </div>
        <div class="card-body">
          <form method="get">
            <div class="mb-3">
              <input type="text" class="form-control" name="keyword"
                     value="<%= escapeHtml(keyword != null ? keyword : "") %>" placeholder="프로젝트 검색...">
            </div>
            <div class="mb-3">
              <label class="form-label fw-semibold">카테고리</label>
              <select class="form-select" name="category" onchange="this.form.submit()">
                <option value="">전체</option>
                <option value="Customer Service" <%= "Customer Service".equals(category) ? "selected":"" %>>고객 서비스</option>
                <option value="Marketing"        <%= "Marketing".equals(category)        ? "selected":"" %>>마케팅</option>
                <option value="Development"      <%= "Development".equals(category)      ? "selected":"" %>>개발</option>
                <option value="Data Analysis"    <%= "Data Analysis".equals(category)    ? "selected":"" %>>데이터 분석</option>
                <option value="HR"               <%= "HR".equals(category)               ? "selected":"" %>>인사</option>
                <option value="Finance"          <%= "Finance".equals(category)          ? "selected":"" %>>재무</option>
              </select>
            </div>
            <div class="mb-3">
              <label class="form-label fw-semibold">난이도</label>
              <div class="btn-group-vertical w-100" role="group">
                <a href="?<%= category != null ? "category="+category+"&" : "" %>difficulty=Beginner"
                   class="btn btn-sm <%= "Beginner".equals(diff) ? "btn-success" : "btn-outline-success" %>">
                  초급 (Beginner)
                </a>
                <a href="?<%= category != null ? "category="+category+"&" : "" %>difficulty=Intermediate"
                   class="btn btn-sm <%= "Intermediate".equals(diff) ? "btn-warning text-dark" : "btn-outline-warning" %>">
                  중급 (Intermediate)
                </a>
                <a href="?<%= category != null ? "category="+category+"&" : "" %>difficulty=Advanced"
                   class="btn btn-sm <%= "Advanced".equals(diff) ? "btn-danger" : "btn-outline-danger" %>">
                  고급 (Advanced)
                </a>
              </div>
            </div>
            <div class="mb-3">
              <label class="form-label fw-semibold">프로젝트 유형</label>
              <select class="form-select" name="type" onchange="this.form.submit()">
                <option value="">전체</option>
                <option value="Tutorial"   <%= "Tutorial".equals(ptype)   ? "selected":"" %>>튜토리얼</option>
                <option value="Challenge"  <%= "Challenge".equals(ptype)  ? "selected":"" %>>챌린지</option>
                <option value="Real-world" <%= "Real-world".equals(ptype) ? "selected":"" %>>실전 프로젝트</option>
              </select>
            </div>
            <div class="d-flex gap-2">
              <button type="submit" class="btn btn-success flex-grow-1">적용</button>
              <a href="/AI/user/lab/index.jsp" class="btn btn-outline-secondary">초기화</a>
            </div>
          </form>
        </div>
      </div>

      <!-- 인기 프로젝트 -->
      <div class="card shadow-sm">
        <div class="card-header bg-danger text-white">
          <h5 class="mb-0"><i class="bi bi-trophy me-2"></i>인기 프로젝트</h5>
        </div>
        <div class="card-body p-0">
          <ul class="list-group list-group-flush">
            <% for (LabProject p : popular) { %>
            <li class="list-group-item">
              <a href="/AI/user/lab/detail.jsp?id=<%= p.getId() %>" class="text-decoration-none d-block">
                <span class="badge <%= p.getDifficultyBadgeClass() %> me-1"><%= p.getDifficultyLevel() %></span>
                <%= escapeHtml(p.getTitle()) %>
              </a>
              <div class="small text-muted mt-1">
                <i class="bi bi-people me-1"></i><%= p.getCurrentParticipants() != null ? p.getCurrentParticipants() : 0 %>명 참여
                &nbsp;<i class="bi bi-clock me-1"></i><%= p.getFormattedDuration() %>
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
        <p class="text-muted mb-0">총 <strong><%= projects.size() %></strong>개 프로젝트</p>
        <!-- 유형별 빠른 필터 -->
        <div class="btn-group" role="group">
          <a href="/AI/user/lab/index.jsp" class="btn btn-sm <%= (ptype == null || ptype.isEmpty()) ? "btn-dark" : "btn-outline-dark" %>">전체</a>
          <a href="?type=Tutorial" class="btn btn-sm <%= "Tutorial".equals(ptype) ? "btn-info" : "btn-outline-info" %>">튜토리얼</a>
          <a href="?type=Challenge" class="btn btn-sm <%= "Challenge".equals(ptype) ? "btn-warning" : "btn-outline-warning" %>">챌린지</a>
          <a href="?type=Real-world" class="btn btn-sm <%= "Real-world".equals(ptype) ? "btn-danger" : "btn-outline-danger" %>">실전</a>
        </div>
      </div>

      <div class="row g-4">
        <% if (projects.isEmpty()) { %>
        <div class="col-12 text-center py-5 text-muted">
          <i class="bi bi-flask display-1"></i>
          <h4 class="mt-3">프로젝트가 없습니다</h4>
          <p>다른 조건으로 검색해보세요.</p>
        </div>
        <% } else { for (LabProject p : projects) { %>
        <div class="col-lg-6">
          <div class="card h-100 shadow-sm">
            <div class="card-body">
              <div class="d-flex justify-content-between mb-2">
                <span class="badge <%= p.getTypeBadgeClass() %>"><%= p.getProjectType() %></span>
                <span class="badge <%= p.getDifficultyBadgeClass() %>"><%= p.getDifficultyLevel() %></span>
              </div>
              <h5 class="card-title"><%= escapeHtml(p.getTitle()) %></h5>

              <!-- 비즈니스 컨텍스트 -->
              <% if (p.getBusinessContext() != null && !p.getBusinessContext().trim().isEmpty()) { %>
              <div class="alert alert-light border-start border-primary border-3 py-2 px-3 mb-3 small">
                <i class="bi bi-briefcase me-1 text-primary"></i>
                <em><%= escapeHtml(p.getBusinessContext().length() > 100
                        ? p.getBusinessContext().substring(0, 100) + "..." : p.getBusinessContext()) %></em>
              </div>
              <% } else { %>
              <p class="card-text text-muted small"><%= escapeHtml(safeString(p.getDescription(), "")) %></p>
              <% } %>

              <!-- 목표 태그 -->
              <% if (p.getProjectGoals() != null && !p.getProjectGoals().isEmpty()) { %>
              <div class="mb-3">
                <% int goalCount = 0; for (String goal : p.getProjectGoals()) { if (goalCount++ >= 3) break; %>
                <span class="badge bg-light text-dark border me-1 mb-1">
                  <i class="bi bi-check2 text-success me-1"></i><%= escapeHtml(goal.length() > 30 ? goal.substring(0, 30) + "…" : goal) %>
                </span>
                <% } %>
                <% if (p.getProjectGoals().size() > 3) { %>
                <span class="badge bg-light text-muted border">+<%= p.getProjectGoals().size() - 3 %> 더</span>
                <% } %>
              </div>
              <% } %>

              <div class="d-flex gap-3 text-muted small mt-auto">
                <span><i class="bi bi-clock me-1"></i><%= p.getFormattedDuration() %></span>
                <span><i class="bi bi-people me-1"></i><%= p.getCurrentParticipants() != null ? p.getCurrentParticipants() : 0 %>명 참여</span>
                <span><i class="bi bi-list-ol me-1"></i><%= p.getStepCount() %>단계</span>
              </div>
            </div>
            <div class="card-footer bg-transparent">
              <a href="/AI/user/lab/detail.jsp?id=<%= p.getId() %>" class="btn btn-success btn-sm w-100">
                <i class="bi bi-play-circle me-1"></i>실습 시작하기
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
