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
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
  <link rel="stylesheet" href="/AI/assets/css/tools.css">
  <script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
</head>
<body>
  <%@ include file="/AI/partials/header.jsp" %>
  
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
              <img src="/AI/assets/img/providers/<%= getProviderLogoFileName(tool.getProviderName()) %>.png" 
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
        <div class="card shadow-sm mb-4 bg-light">
          <div class="card-body">
            <h5 class="card-title"><i class="bi bi-magic"></i> AI 도구 추천받기</h5>
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
                        <img src="/AI/assets/img/providers/<%= getProviderLogoFileName(tool.getProviderName()) %>.png" 
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
                            <img src="/AI/assets/img/providers/<%= getProviderLogoFileName(tool.getProviderName()) %>.png" 
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
        const response = await axios.get('/AI/api/ai-tools/recommend', {
          params: { q: query, difficulty: difficulty }
        });
        
        if (response.data.success && response.data.data.length > 0) {
          let html = '<h6>추천 도구:</h6><div class="row">';
          
          response.data.data.forEach(tool => {
            html += `
              <div class="col-md-6 mb-2">
                <div class="card card-body">
                  <div class="d-flex align-items-center">
                    <img src="/AI/assets/img/providers/${tool.providerName.toLowerCase()}.png" 
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
