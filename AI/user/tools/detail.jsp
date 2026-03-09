<%@ page contentType="text/html; charset=UTF-8" buffer="128kb" autoFlush="true" %>
<%@ page isELIgnored="true" %>
<%@ page import="dao.AIToolDAO" %>
<%@ page import="model.AITool" %>
<%@ page import="java.util.List" %>
<%@ include file="/AI/user/_common.jsp" %>

<%
  int toolId = 0;
  try { toolId = Integer.parseInt(request.getParameter("id")); } catch (Exception e) {}
  AIToolDAO toolDao = new AIToolDAO();
  AITool tool = toolId > 0 ? toolDao.findById(toolId) : null;

  if (tool == null) {
    response.sendRedirect("/AI/user/tools/navigator.jsp");
    return;
  }

  List<AITool> related = toolDao.findByCategory(tool.getCategory());
  related.removeIf(t -> t.getId() == tool.getId());
  if (related.size() > 4) related = related.subList(0, 4);

  String[] logoInfo = getProviderLogo(tool.getProviderName(), tool.getToolName());
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><%= escapeHtml(tool.getToolName()) %> - AI Workflow Lab</title>
  <link rel="icon" href="data:,">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
  <link rel="stylesheet" href="/AI/assets/css/dark-theme.css">
  <style>
    body { padding-top: 44px; }

    .tool-hero {
      background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%);
      border-bottom: 1px solid #334155;
      padding: 48px 0 40px;
    }
    .tool-hero-logo {
      width: 72px; height: 72px; border-radius: 16px;
      object-fit: contain; background: #334155; padding: 8px;
    }
    .tool-hero-logo-fallback {
      width: 72px; height: 72px; border-radius: 16px;
      background: #334155; display: flex; align-items: center;
      justify-content: center; font-size: 2rem;
    }
    .spec-card {
      background: #1e293b; border: 1px solid #334155;
      border-radius: 12px; padding: 20px; margin-bottom: 16px;
    }
    .spec-card h6 {
      color: #6366f1; font-size: 12px; font-weight: 600;
      text-transform: uppercase; letter-spacing: 0.08em; margin-bottom: 12px;
    }
    .spec-row {
      display: flex; justify-content: space-between; align-items: flex-start;
      padding: 8px 0; border-bottom: 1px solid #334155; font-size: 14px;
    }
    .spec-row:last-child { border-bottom: none; }
    .spec-label { color: #64748b; flex-shrink: 0; margin-right: 16px; }
    .spec-value { color: #e2e8f0; text-align: right; }
    .tag-pill {
      display: inline-block; padding: 4px 12px;
      background: rgba(99,102,241,0.15); border: 1px solid rgba(99,102,241,0.3);
      border-radius: 20px; font-size: 12px; color: #a5b4fc; margin: 3px;
    }
    .use-case-item {
      display: flex; gap: 10px; align-items: flex-start;
      padding: 10px 0; border-bottom: 1px solid #334155; font-size: 14px; color: #94a3b8;
    }
    .use-case-item:last-child { border-bottom: none; }
    .use-case-item i { color: #6366f1; margin-top: 2px; flex-shrink: 0; }
    .action-btn {
      display: inline-flex; align-items: center; gap: 8px;
      padding: 12px 24px; border-radius: 10px; font-size: 15px;
      font-weight: 500; text-decoration: none; transition: all 0.2s;
    }
    .action-btn-primary {
      background: linear-gradient(135deg, #6366f1, #8b5cf6); color: white; border: none;
    }
    .action-btn-primary:hover { color: white; transform: translateY(-2px); box-shadow: 0 8px 20px rgba(99,102,241,0.4); }
    .action-btn-secondary {
      background: transparent; color: #94a3b8; border: 1px solid #334155;
    }
    .action-btn-secondary:hover { color: #e2e8f0; border-color: #6366f1; }
    .difficulty-badge {
      display: inline-block; padding: 4px 12px; border-radius: 20px; font-size: 12px; font-weight: 600;
    }
    .related-card {
      background: #1e293b; border: 1px solid #334155; border-radius: 12px;
      padding: 16px; transition: all 0.2s; text-decoration: none; display: block;
    }
    .related-card:hover { border-color: #6366f1; transform: translateY(-2px); }
  </style>
</head>
<body>
<%@ include file="/AI/partials/header.jsp" %>

<!-- 히어로 영역 -->
<div class="tool-hero">
  <div class="container">
    <!-- 브레드크럼 -->
    <nav aria-label="breadcrumb" class="mb-4">
      <ol class="breadcrumb" style="font-size:13px;">
        <li class="breadcrumb-item"><a href="/AI/user/home.jsp" style="color:#64748b; text-decoration:none;">홈</a></li>
        <li class="breadcrumb-item"><a href="/AI/user/tools/navigator.jsp" style="color:#64748b; text-decoration:none;">AI 도구 탐색</a></li>
        <li class="breadcrumb-item active" style="color:#94a3b8;"><%= escapeHtml(tool.getToolName()) %></li>
      </ol>
    </nav>

    <div class="d-flex align-items-start gap-4 flex-wrap">
      <!-- 로고 -->
      <img src="<%= logoInfo[0] %>" alt="<%= escapeHtml(tool.getProviderName()) %>"
           class="tool-hero-logo"
           onerror="this.style.display='none';this.nextElementSibling.style.display='flex'">
      <div class="tool-hero-logo-fallback" style="display:none;">🤖</div>

      <!-- 기본 정보 -->
      <div class="flex-grow-1">
        <div class="d-flex align-items-center gap-2 mb-1 flex-wrap">
          <span style="font-size:13px; color:#64748b;"><%= escapeHtml(safeString(tool.getProviderName(), "")) %></span>
          <% if (tool.isFreeTierAvailable()) { %>
          <span class="badge" style="background:rgba(16,185,129,0.2); color:#10b981; border:1px solid rgba(16,185,129,0.3); font-size:11px;">무료 플랜</span>
          <% } %>
          <% String diff = safeString(tool.getDifficultyLevel(), ""); if (!diff.isEmpty()) { %>
          <span class="difficulty-badge badge-<%= diff.toLowerCase() %>"><%= escapeHtml(diff) %></span>
          <% } %>
        </div>
        <h1 style="font-size:32px; font-weight:700; color:#e2e8f0; margin-bottom:8px;"><%= escapeHtml(tool.getToolName()) %></h1>
        <p style="color:#94a3b8; font-size:16px; margin-bottom:16px;"><%= escapeHtml(safeString(tool.getPurposeSummary(), "")) %></p>

        <!-- 평점 -->
        <% if (tool.getRating() != null) { %>
        <div style="color:#f59e0b; font-size:15px; margin-bottom:20px;">
          <%= tool.getStarRating() %>
          <span style="color:#64748b; font-size:13px; margin-left:6px;"><%= String.format("%.1f", tool.getRating()) %> (<%= tool.getReviewCount() != null ? tool.getReviewCount() : 0 %>개 리뷰)</span>
        </div>
        <% } %>

        <!-- 액션 버튼 -->
        <div class="d-flex gap-2 flex-wrap">
          <% if (tool.getWebsiteUrl() != null && !tool.getWebsiteUrl().isEmpty()) { %>
          <a href="<%= escapeHtml(tool.getWebsiteUrl()) %>" target="_blank" rel="noopener" class="action-btn action-btn-primary">
            <i class="bi bi-box-arrow-up-right"></i>공식 사이트
          </a>
          <% } %>
          <% if (tool.getPlaygroundUrl() != null && !tool.getPlaygroundUrl().isEmpty()) { %>
          <a href="<%= escapeHtml(tool.getPlaygroundUrl()) %>" target="_blank" rel="noopener" class="action-btn action-btn-secondary">
            <i class="bi bi-play-circle"></i>체험하기
          </a>
          <% } %>
          <% if (tool.getDocsUrl() != null && !tool.getDocsUrl().isEmpty()) { %>
          <a href="<%= escapeHtml(tool.getDocsUrl()) %>" target="_blank" rel="noopener" class="action-btn action-btn-secondary">
            <i class="bi bi-book"></i>문서
          </a>
          <% } %>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- 메인 콘텐츠 -->
<div class="container py-5">
  <div class="row g-4">
    <!-- 왼쪽: 상세 정보 -->
    <div class="col-lg-8">

      <!-- 설명 -->
      <% String desc = safeString(tool.getDescription(), safeString(tool.getPurposeSummary(), "")); if (!desc.isEmpty()) { %>
      <div class="spec-card">
        <h6><i class="bi bi-info-circle me-2"></i>도구 소개</h6>
        <p style="color:#94a3b8; font-size:15px; line-height:1.7; margin:0;"><%= escapeHtml(desc) %></p>
      </div>
      <% } %>

      <!-- 활용 사례 -->
      <% if (tool.getUseCases() != null && !tool.getUseCases().isEmpty()) { %>
      <div class="spec-card">
        <h6><i class="bi bi-lightbulb me-2"></i>활용 사례</h6>
        <% for (String uc : tool.getUseCases()) { %>
        <div class="use-case-item">
          <i class="bi bi-check2-circle"></i>
          <span><%= escapeHtml(uc) %></span>
        </div>
        <% } %>
      </div>
      <% } %>

      <!-- 주요 기능 -->
      <% if (tool.getFeatures() != null && !tool.getFeatures().isEmpty()) { %>
      <div class="spec-card">
        <h6><i class="bi bi-stars me-2"></i>주요 기능</h6>
        <div class="row g-2">
          <% for (String feat : tool.getFeatures()) { %>
          <div class="col-md-6">
            <div style="display:flex; gap:8px; align-items:flex-start; font-size:14px; color:#94a3b8;">
              <i class="bi bi-check-circle-fill" style="color:#6366f1; margin-top:2px; flex-shrink:0;"></i>
              <span><%= escapeHtml(feat) %></span>
            </div>
          </div>
          <% } %>
        </div>
      </div>
      <% } %>

      <!-- 태그 -->
      <% if (tool.getTags() != null && !tool.getTags().isEmpty()) { %>
      <div class="spec-card">
        <h6><i class="bi bi-tags me-2"></i>태그</h6>
        <% for (String tag : tool.getTags()) { %>
        <a href="/AI/user/tools/navigator.jsp?keyword=<%= java.net.URLEncoder.encode(tag, "UTF-8") %>" class="tag-pill" style="text-decoration:none;"><%= escapeHtml(tag) %></a>
        <% } %>
      </div>
      <% } %>
    </div>

    <!-- 오른쪽: 스펙 -->
    <div class="col-lg-4">
      <div class="spec-card">
        <h6><i class="bi bi-clipboard-data me-2"></i>기본 스펙</h6>

        <div class="spec-row">
          <span class="spec-label">카테고리</span>
          <span class="spec-value"><%= escapeHtml(safeString(tool.getCategory(), "-")) %></span>
        </div>
        <% if (tool.getSubcategory() != null && !tool.getSubcategory().isEmpty()) { %>
        <div class="spec-row">
          <span class="spec-label">서브카테고리</span>
          <span class="spec-value"><%= escapeHtml(tool.getSubcategory()) %></span>
        </div>
        <% } %>
        <div class="spec-row">
          <span class="spec-label">난이도</span>
          <span class="spec-value"><%= escapeHtml(safeString(tool.getDifficultyLevel(), "-")) %></span>
        </div>
        <div class="spec-row">
          <span class="spec-label">무료 플랜</span>
          <span class="spec-value"><%= tool.isFreeTierAvailable() ? "✅ 있음" : "❌ 없음" %></span>
        </div>
        <div class="spec-row">
          <span class="spec-label">API 제공</span>
          <span class="spec-value"><%= tool.isApiAvailable() ? "✅ 있음" : "❌ 없음" %></span>
        </div>
        <% if (tool.getPricingModel() != null && !tool.getPricingModel().isEmpty()) { %>
        <div class="spec-row">
          <span class="spec-label">요금 모델</span>
          <span class="spec-value"><%= escapeHtml(tool.getPricingModel()) %></span>
        </div>
        <% } %>
        <div class="spec-row">
          <span class="spec-label">상업적 이용</span>
          <span class="spec-value"><%= tool.isCommercialUseAllowed() ? "✅ 허용" : "❌ 제한" %></span>
        </div>
        <% if (tool.getLicenseType() != null && !tool.getLicenseType().isEmpty()) { %>
        <div class="spec-row">
          <span class="spec-label">라이선스</span>
          <span class="spec-value"><%= escapeHtml(tool.getLicenseType()) %></span>
        </div>
        <% } %>
        <% if (tool.getInputModalities() != null && !tool.getInputModalities().isEmpty()) { %>
        <div class="spec-row">
          <span class="spec-label">입력 형식</span>
          <span class="spec-value"><%= escapeHtml(tool.getInputModalities()) %></span>
        </div>
        <% } %>
        <% if (tool.getOutputModalities() != null && !tool.getOutputModalities().isEmpty()) { %>
        <div class="spec-row">
          <span class="spec-label">출력 형식</span>
          <span class="spec-value"><%= escapeHtml(tool.getOutputModalities()) %></span>
        </div>
        <% } %>
        <% if (tool.getRateLimitPerMin() != null) { %>
        <div class="spec-row">
          <span class="spec-label">분당 요청 제한</span>
          <span class="spec-value"><%= tool.getRateLimitPerMin() %></span>
        </div>
        <% } %>
      </div>

      <!-- 요금 상세 -->
      <% if (tool.getPricingDetails() != null && !tool.getPricingDetails().isEmpty()) { %>
      <div class="spec-card">
        <h6><i class="bi bi-cash-coin me-2"></i>요금 안내</h6>
        <p style="color:#94a3b8; font-size:14px; line-height:1.6; margin:0;"><%= escapeHtml(tool.getPricingDetails()) %></p>
      </div>
      <% } %>

      <!-- 지원 언어 -->
      <% if (tool.getSupportedLanguages() != null && !tool.getSupportedLanguages().isEmpty()) { %>
      <div class="spec-card">
        <h6><i class="bi bi-translate me-2"></i>지원 언어</h6>
        <% for (String lang : tool.getSupportedLanguages()) { %>
        <span class="tag-pill"><%= escapeHtml(lang) %></span>
        <% } %>
      </div>
      <% } %>
    </div>
  </div>

  <!-- 관련 도구 -->
  <% if (!related.isEmpty()) { %>
  <div class="mt-5">
    <h5 style="color:#e2e8f0; font-weight:600; margin-bottom:20px;">
      <i class="bi bi-grid-3x3-gap me-2" style="color:#6366f1;"></i>같은 카테고리 도구
    </h5>
    <div class="row g-3">
      <% for (AITool rel : related) {
         String[] relLogo = getProviderLogo(rel.getProviderName(), rel.getToolName()); %>
      <div class="col-lg-3 col-md-6">
        <a href="/AI/user/tools/detail.jsp?id=<%= rel.getId() %>" class="related-card">
          <div class="d-flex align-items-center gap-2 mb-2">
            <img src="<%= relLogo[0] %>" alt="" style="width:24px;height:24px;border-radius:6px;object-fit:contain;"
                 onerror="this.style.display='none'">
            <span style="font-size:12px;color:#64748b;"><%= escapeHtml(safeString(rel.getProviderName(), "")) %></span>
          </div>
          <div style="font-size:15px;font-weight:600;color:#e2e8f0;margin-bottom:6px;"><%= escapeHtml(rel.getToolName()) %></div>
          <div style="font-size:13px;color:#64748b;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden;">
            <%= escapeHtml(safeString(rel.getPurposeSummary(), "")) %>
          </div>
        </a>
      </div>
      <% } %>
    </div>
  </div>
  <% } %>
</div>

<%@ include file="/AI/partials/footer.jsp" %>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
