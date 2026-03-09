<%@ page contentType="text/html; charset=UTF-8" buffer="128kb" autoFlush="true" %>
<%@ page isELIgnored="true" %>
<%@ page import="dao.AIToolDAO" %>
<%@ page import="model.AITool" %>
<%@ page import="java.util.List" %>
<%@ include file="/AI/user/_common.jsp" %>

<%
  // DAO 초기화
  AIToolDAO toolDao = new AIToolDAO();
  
  // 파라미터 처리
  String keyword = request.getParameter("keyword");
  String category = request.getParameter("category");
  String difficulty = request.getParameter("difficulty");
  String view = request.getParameter("view");
  if (view == null) view = "grid";
  
  // 데이터 조회
  List<AITool> tools = null;
  String pageTitle = "AI 도구 탐색";
  
  if (keyword != null && !keyword.trim().isEmpty()) {
      tools = toolDao.searchByKeyword(keyword);
      pageTitle = "검색 결과: " + escapeHtml(keyword);
  } else if (category != null && !category.trim().isEmpty()) {
      tools = toolDao.findByCategory(category);
      pageTitle = escapeHtml(category) + " 카테고리";
  } else if (difficulty != null && !difficulty.trim().isEmpty()) {
      tools = toolDao.findByDifficulty(difficulty);
      pageTitle = escapeHtml(difficulty) + " 난이도";
  } else {
      tools = toolDao.findAll();
  }
  
  // 인기 도구 (사이드바용)
  List<AITool> popularTools = toolDao.findPopular(5);
%>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><%= pageTitle %> - AI Workflow Lab</title>
  <meta name="description" content="AI Workflow Lab에서 다양한 AI 도구를 탐색하고 추천을 받아보세요.">
  <link rel="icon" href="data:,">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
  <link rel="stylesheet" href="/AI/assets/css/dark-theme.css">
  <link rel="stylesheet" href="/AI/assets/css/tools.css">
  <script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
  <style>
    body { padding-top: 44px; background: var(--bg-primary, #0f172a); color: var(--text-primary, #e2e8f0); }
    .page-header { background: linear-gradient(135deg, #1e293b, #0f172a); border-bottom: 1px solid #334155; padding: 32px 0 24px; margin-bottom: 0; }
    .page-header h1 { color: #e2e8f0; font-size: 28px; font-weight: 700; margin-bottom: 6px; }
    .page-header p { color: #94a3b8; font-size: 15px; margin: 0; }
    .card { background: #1e293b; border: 1px solid #334155; color: #e2e8f0; }
    .card-header.bg-primary { background: linear-gradient(135deg, #6366f1, #8b5cf6) !important; border-bottom: none; }
    .card-header.bg-success { background: linear-gradient(135deg, #059669, #10b981) !important; border-bottom: none; }
    .card-body { color: #e2e8f0; }
    .card-body .text-muted, .small.text-muted { color: #94a3b8 !important; }
    .form-label { color: #94a3b8; font-size: 13px; font-weight: 500; }
    .form-control { background: #334155; border: 1px solid #475569; color: #e2e8f0; }
    .form-control:focus { background: #334155; border-color: #6366f1; color: #e2e8f0; box-shadow: 0 0 0 3px rgba(99,102,241,0.15); }
    .form-control::placeholder { color: #64748b; }
    .form-select { background: #334155; border: 1px solid #475569; color: #e2e8f0; }
    .form-select:focus { background: #334155; border-color: #6366f1; color: #e2e8f0; box-shadow: 0 0 0 3px rgba(99,102,241,0.15); }
    .form-select option { background: #1e293b; color: #e2e8f0; }
    .btn-outline-primary { color: #6366f1; border-color: #6366f1; }
    .btn-outline-primary:hover { background: #6366f1; color: white; }
    .btn-outline-secondary { color: #94a3b8; border-color: #475569; }
    .btn-outline-secondary:hover, .btn-outline-secondary.active { background: #334155; color: #e2e8f0; border-color: #6366f1; }
    .tool-card { transition: all 0.2s ease; }
    .tool-card:hover { border-color: #6366f1; transform: translateY(-4px); box-shadow: 0 0 20px rgba(99,102,241,0.3); }
    .card-footer.bg-transparent { border-top: 1px solid #334155; background: transparent; }
    a.text-decoration-none { color: #e2e8f0; }
    a.text-decoration-none:hover { color: #6366f1; }
    .badge.bg-light { background: #334155 !important; color: #94a3b8 !important; border: 1px solid #475569; }
    .bg-light.card { background: #1e293b !important; border: 1px solid #6366f1; }
    .bg-light.card .card-title { color: #e2e8f0; }
    .bg-light.card .card-text { color: #94a3b8; }
    .recommend-section { background: linear-gradient(135deg, rgba(99,102,241,0.15), rgba(139,92,246,0.15)); border: 1px solid rgba(99,102,241,0.3); border-radius: 12px; padding: 24px; margin-bottom: 24px; }
    .recommend-section .card-title { color: #e2e8f0; font-size: 17px; font-weight: 600; }
    .recommend-section .card-text { color: #94a3b8; font-size: 14px; }
    h1.h3 { color: #e2e8f0; }
    p.text-muted.mb-0 { color: #94a3b8 !important; }
  </style>
</head>
<body>
  <%@ include file="/AI/partials/header.jsp" %>

  <div class="page-header">
    <div class="container-fluid">
      <h1><i class="bi bi-compass me-2"></i>AI 도구 탐색</h1>
      <p>업무 목적에 맞는 AI 도구를 찾고 추천받으세요. 50+ 도구 수록.</p>
    </div>
  </div>

  <div class="container-fluid mt-4">
    <div class="row">
      <!-- 사이드바 -->
      <aside class="col-lg-3 col-md-4">
        <div class="card shadow-sm mb-4">
          <div class="card-header bg-primary text-white">
            <h5 class="mb-0"><i class="bi bi-funnel"></i> 필터</h5>
          </div>
          <div class="card-body">
            <form id="filterForm">
              <!-- 검색 -->
              <div class="mb-3">
                <label class="form-label">키워드 검색</label>
                <div class="input-group">
                  <input type="text" class="form-control" name="keyword" 
                         value="<%= escapeHtml(keyword != null ? keyword : "") %>" 
                         placeholder="AI 도구 검색...">
                  <button class="btn btn-outline-primary" type="submit">
                    <i class="bi bi-search"></i>
                  </button>
                </div>
              </div>
              
              <!-- 카테고리 -->
              <div class="mb-3">
                <label class="form-label">카테고리</label>
                <select class="form-select" name="category">
                  <option value="">전체 카테고리</option>
                  <option value="Text Generation" <%= "Text Generation".equals(category) ? "selected" : "" %>>텍스트 생성</option>
                  <option value="Image Generation" <%= "Image Generation".equals(category) ? "selected" : "" %>>이미지 생성</option>
                  <option value="Code Generation" <%= "Code Generation".equals(category) ? "selected" : "" %>>코드 생성</option>
                  <option value="Voice Processing" <%= "Voice Processing".equals(category) ? "selected" : "" %>>음성 처리</option>
                  <option value="Video Processing" <%= "Video Processing".equals(category) ? "selected" : "" %>>비디오 처리</option>
                  <option value="Translation" <%= "Translation".equals(category) ? "selected" : "" %>>번역</option>
                  <option value="Data Analysis" <%= "Data Analysis".equals(category) ? "selected" : "" %>>데이터 분석</option>
                </select>
              </div>
              
              <!-- 난이도 -->
              <div class="mb-3">
                <label class="form-label">난이도</label>
                <select class="form-select" name="difficulty">
                  <option value="">전체 난이도</option>
                  <option value="Beginner" <%= "Beginner".equals(difficulty) ? "selected" : "" %>>초급</option>
                  <option value="Intermediate" <%= "Intermediate".equals(difficulty) ? "selected" : "" %>>중급</option>
                  <option value="Advanced" <%= "Advanced".equals(difficulty) ? "selected" : "" %>>고급</option>
                </select>
              </div>
              
              <button type="submit" class="btn btn-primary w-100">필터 적용</button>
            </form>
          </div>
        </div>
        
        <!-- 인기 도구 -->
        <div class="card shadow-sm">
          <div class="card-header bg-success text-white">
            <h5 class="mb-0"><i class="bi bi-fire"></i> 인기 도구</h5>
          </div>
          <div class="card-body">
            <% for (AITool tool : popularTools) { %>
            <div class="d-flex align-items-center mb-3">
              <img src="/AI/assets/img/providers/<%= getProviderLogoFileName(tool.getProviderName()) %>.svg"
                   alt="<%= escapeHtml(tool.getProviderName()) %>"
                   class="me-2" style="width: 24px; height: 24px;">
              <div class="flex-grow-1">
                <a href="/AI/user/tools/detail.jsp?id=<%= tool.getId() %>" class="text-decoration-none">
                  <%= escapeHtml(tool.getToolName()) %>
                </a>
                <div class="small text-muted">
                  <%= tool.getStarRating() %> (<%= tool.getReviewCount() %>)
                </div>
              </div>
            </div>
            <% } %>
          </div>
        </div>
      </aside>
      
      <!-- 메인 콘텐츠 -->
      <main class="col-lg-9 col-md-8">
        <!-- 헤더 -->
        <div class="d-flex justify-content-between align-items-center mb-4">
          <div>
            <h1 class="h3 mb-1"><%= pageTitle %></h1>
            <p class="text-muted mb-0">총 <%= tools.size() %>개의 도구를 찾았습니다</p>
          </div>
          <div class="btn-group" role="group">
            <button type="button" class="btn btn-outline-secondary <%= "grid".equals(view) ? "active" : "" %>" 
                    onclick="changeView('grid')">
              <i class="bi bi-grid-3x3-gap"></i> 그리드
            </button>
            <button type="button" class="btn btn-outline-secondary <%= "list".equals(view) ? "active" : "" %>" 
                    onclick="changeView('list')">
              <i class="bi bi-list"></i> 리스트
            </button>
          </div>
        </div>
        
        <!-- AI 도구 추천 섹션 -->
        <div class="recommend-section mb-4">
          <div class="card-body p-0">
            <h5 class="card-title"><i class="bi bi-magic me-2"></i>AI 도구 추천받기</h5>
            <p class="card-text">어떤 작업을 하고 싶으신가요? AI가 적합한 도구를 추천해드립니다.</p>
            <form id="recommendForm" class="row g-3">
              <div class="col-md-6">
                <input type="text" class="form-control" id="recommendQuery" 
                       placeholder="예: 블로그 글 작성, 이미지 생성, 코드 리뷰..." required>
              </div>
              <div class="col-md-3">
                <select class="form-select" id="recommendDifficulty">
                  <option value="">난이도</option>
                  <option value="Beginner">초급</option>
                  <option value="Intermediate">중급</option>
                  <option value="Advanced">고급</option>
                </select>
              </div>
              <div class="col-md-3">
                <button type="submit" class="btn btn-primary w-100">
                  <i class="bi bi-stars"></i> 추천받기
                </button>
              </div>
            </form>
            <div id="recommendResults" class="mt-3"></div>
          </div>
        </div>

        
        <!-- 도구 목록 -->
        <div id="toolsContainer" class="<%= "grid".equals(view) ? "row g-4" : "" %>">
          <% if (tools.isEmpty()) { %>
          <div class="col-12">
            <div class="text-center py-5">
              <i class="bi bi-search display-1 text-muted"></i>
              <h3 class="mt-3">검색 결과가 없습니다</h3>
              <p class="text-muted">다른 키워드나 필터로 시도해보세요.</p>
            </div>
          </div>
          <% } else { %>
            <% for (AITool tool : tools) { %>
              <% if ("grid".equals(view)) { %>
                <!-- 그리드 뷰 -->
                <div class="col-lg-4 col-md-6">
                  <div class="card h-100 shadow-sm tool-card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                      <div class="d-flex align-items-center">
                        <img src="/AI/assets/img/providers/<%= getProviderLogoFileName(tool.getProviderName()) %>.svg"
                             alt="<%= escapeHtml(tool.getProviderName()) %>"
                             class="me-2" style="width: 24px; height: 24px;">
                        <span class="badge <%= tool.getDifficultyBadgeClass() %>">
                          <%= tool.getDifficultyLevel() %>
                        </span>
                      </div>
                      <% if (tool.isFreeTierAvailable()) { %>
                      <span class="badge bg-success">무료</span>
                      <% } %>
                    </div>
                    <div class="card-body">
                      <h5 class="card-title"><%= escapeHtml(tool.getToolName()) %></h5>
                      <p class="card-text text-muted small"><%= escapeHtml(tool.getPurposeSummary()) %></p>
                      <div class="mb-2">
                        <%= tool.getStarRating() %>
                        <span class="text-muted">(<%= tool.getReviewCount() %>)</span>
                      </div>
                      <div class="mb-3">
                        <% if (tool.getTags() != null && !tool.getTags().isEmpty()) { %>
                          <% for (String tag : tool.getTags().subList(0, Math.min(3, tool.getTags().size()))) { %>
                            <span class="badge bg-light text-dark me-1"><%= escapeHtml(tag) %></span>
                          <% } %>
                        <% } %>
                      </div>
                    </div>
                    <div class="card-footer bg-transparent">
                      <a href="/AI/user/tools/detail.jsp?id=<%= tool.getId() %>" 
                         class="btn btn-primary btn-sm w-100">
                        자세히 보기
                      </a>
                    </div>
                  </div>
                </div>
              <% } else { %>
                <!-- 리스트 뷰 -->
                <div class="col-12 mb-3">
                  <div class="card shadow-sm">
                    <div class="card-body">
                      <div class="row align-items-center">
                        <div class="col-md-8">
                          <div class="d-flex align-items-center mb-2">
                            <img src="/AI/assets/img/providers/<%= getProviderLogoFileName(tool.getProviderName()) %>.svg"
                                 alt="<%= escapeHtml(tool.getProviderName()) %>"
                                 class="me-2" style="width: 24px; height: 24px;">
                            <h5 class="mb-0 me-3"><%= escapeHtml(tool.getToolName()) %></h5>
                            <span class="badge <%= tool.getDifficultyBadgeClass() %> me-2">
                              <%= tool.getDifficultyLevel() %>
                            </span>
                            <% if (tool.isFreeTierAvailable()) { %>
                            <span class="badge bg-success">무료</span>
                            <% } %>
                          </div>
                          <p class="text-muted mb-2"><%= escapeHtml(tool.getPurposeSummary()) %></p>
                          <div>
                            <%= tool.getStarRating() %>
                            <span class="text-muted">(<%= tool.getReviewCount() %>)</span>
                            <% if (tool.getTags() != null && !tool.getTags().isEmpty()) { %>
                              <% for (String tag : tool.getTags().subList(0, Math.min(5, tool.getTags().size()))) { %>
                                <span class="badge bg-light text-dark me-1"><%= escapeHtml(tag) %></span>
                              <% } %>
                            <% } %>
                          </div>
                        </div>
                        <div class="col-md-4 text-end">
                          <a href="/AI/user/tools/detail.jsp?id=<%= tool.getId() %>" 
                             class="btn btn-primary">
                            자세히 보기
                          </a>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              <% } %>
            <% } %>
          <% } %>
        </div>
      </main>
    </div>
  </div>
  
  <%@ include file="/AI/partials/footer.jsp" %>
  
  <script>
    // 뷰 전환
    function changeView(viewType) {
      const url = new URL(window.location);
      url.searchParams.set('view', viewType);
      window.location = url.toString();
    }
    
    // 필터 폼 제출
    document.getElementById('filterForm').addEventListener('submit', function(e) {
      e.preventDefault();
      const formData = new FormData(this);
      const params = new URLSearchParams();
      
      for (let [key, value] of formData.entries()) {
        if (value) params.set(key, value);
      }
      
      window.location = '?' + params.toString();
    });
    
    // AI 추천
    document.getElementById('recommendForm').addEventListener('submit', async function(e) {
      e.preventDefault();
      
      const query = document.getElementById('recommendQuery').value;
      const difficulty = document.getElementById('recommendDifficulty').value;
      const resultsDiv = document.getElementById('recommendResults');
      
      resultsDiv.innerHTML = '<div class="text-center"><div class="spinner-border spinner-border-sm" role="status"></div> 추천 중...</div>';
      
      try {
        const response = await axios.get('/AI/api/recommend.jsp', {
          params: { q: query, difficulty: difficulty }
        });
        
        if (response.data.success && response.data.data.length > 0) {
          let html = '<h6>추천 도구:</h6><div class="row">';
          
          response.data.data.forEach(tool => {
            html += `
              <div class="col-md-6 mb-2">
                <div class="card card-body">
                  <div class="d-flex align-items-center">
                    <img src="/AI/assets/img/providers/${tool.providerName.toLowerCase()}.svg"
                         alt="${tool.providerName}"
                         class="me-2" style="width: 20px; height: 20px;">
                    <div class="flex-grow-1">
                      <a href="/AI/user/tools/detail.jsp?id=${tool.id}" class="text-decoration-none fw-bold">
                        ${tool.toolName}
                      </a>
                      <div class="small text-muted">${tool.purposeSummary}</div>
                    </div>
                  </div>
                </div>
              </div>
            `;
          });
          
          html += '</div>';
          resultsDiv.innerHTML = html;
        } else {
          resultsDiv.innerHTML = '<div class="alert alert-info">추천할 도구를 찾지 못했습니다. 다른 키워드로 시도해보세요.</div>';
        }
      } catch (error) {
        resultsDiv.innerHTML = '<div class="alert alert-danger">오류가 발생했습니다. 다시 시도해주세요.</div>';
      }
    });
  </script>
</body>
</html>
