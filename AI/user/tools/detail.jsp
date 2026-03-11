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
  if (related.size() > 3) related = related.subList(0, 3);

  String[] logoInfo = getProviderLogo(tool.getProviderName(), tool.getToolName());
%>
<%!
  private String joinList(List<String> values, String fallback) {
    if (values == null || values.isEmpty()) return fallback;
    return String.join(", ", values);
  }

  private String countryLabel(String code) {
    if (code == null || code.isEmpty()) return "-";
    switch (code) {
      case "US": return "미국";
      case "KR": return "한국";
      case "CN": return "중국";
      case "FR": return "프랑스";
      case "DE": return "독일";
      case "JP": return "일본";
      case "CA": return "캐나다";
      default: return code;
    }
  }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><%= escapeHtml(tool.getToolName()) %> - AI Workflow Lab</title>
  <meta name="description" content="<%= escapeHtmlAttribute(safeString(tool.getPurposeSummary(), tool.getToolName() + " 상세 정보, 가격, 기능, 장단점")) %>">
  <meta name="robots" content="index,follow,max-image-preview:large">
  <meta property="og:type" content="website">
  <meta property="og:title" content="<%= escapeHtmlAttribute(tool.getToolName()) %> - AI Workflow Lab">
  <meta property="og:description" content="<%= escapeHtmlAttribute(safeString(tool.getPurposeSummary(), tool.getToolName() + "의 기능과 활용 사례를 확인하세요.")) %>">
  <meta property="og:url" content="<%= request.getRequestURL().toString() %>?id=<%= tool.getId() %>">
  <meta property="og:site_name" content="AI Workflow Lab">
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="<%= escapeHtmlAttribute(tool.getToolName()) %> - AI Workflow Lab">
  <meta name="twitter:description" content="<%= escapeHtmlAttribute(safeString(tool.getPurposeSummary(), tool.getToolName() + " 상세 정보")) %>">
  <link rel="canonical" href="<%= request.getRequestURL().toString() %>?id=<%= tool.getId() %>">
  <link rel="icon" href="data:,">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
  <link rel="stylesheet" href="/AI/assets/css/dark-theme.css">
  <style>
    body { padding-top: 60px; background: var(--bg-primary, #0a0f1e); color: var(--text-primary, #f1f5f9); font-family: 'Noto Sans KR', sans-serif; }
    .pi { max-width: 1100px; margin: 0 auto; padding: 0 24px; }
    .hero-section { background: linear-gradient(135deg, rgba(17,24,39,0.9), rgba(10,15,30,1)); border-bottom: 1px solid rgba(255,255,255,0.07); padding: 40px 0 48px; }
    .gc { background: rgba(255,255,255,0.045); border: 1px solid rgba(255,255,255,0.09); border-radius: 14px; padding: 24px; margin-bottom: 20px; }
    .gc-title { font-size: 0.75rem; font-weight: 600; color: #60a5fa; text-transform: uppercase; letter-spacing: 0.08em; margin: 0 0 16px; }
    .spec-row { display: flex; justify-content: space-between; padding: 9px 0; border-bottom: 1px solid rgba(255,255,255,0.06); font-size: 0.875rem; }
    .spec-row:last-child { border-bottom: none; }
    .spec-label { color: var(--text-muted, #64748b); }
    .spec-value { color: var(--text-primary, #f1f5f9); text-align: right; }
    .cat-badge { display: inline-flex; align-items: center; padding: 3px 12px; border-radius: 999px; font-size: 0.75rem; font-weight: 600; margin-right: 6px; }
    .feat-item { display: flex; gap: 8px; align-items: flex-start; font-size: 0.875rem; color: var(--text-secondary, #94a3b8); margin-bottom: 10px; }
    .feat-item i { color: #4ade80; flex-shrink: 0; margin-top: 2px; }
    .tag-pill { display: inline-flex; align-items: center; padding: 4px 12px; border-radius: 999px; font-size: 0.75rem; font-weight: 500; background: rgba(59,130,246,0.10); color: #60a5fa; border: 1px solid rgba(59,130,246,0.18); text-decoration: none; margin: 3px; transition: background 0.2s; }
    .tag-pill:hover { background: rgba(59,130,246,0.18); color: #93c5fd; }
    .btn-hero-primary { display: inline-flex; align-items: center; gap: 7px; padding: 10px 20px; border-radius: 9px; background: linear-gradient(135deg, #3b82f6, #8b5cf6); color: #fff; -webkit-text-fill-color: #fff; font-size: 0.875rem; font-weight: 600; text-decoration: none; border: none; transition: all 0.2s; }
    .btn-hero-primary:hover { transform: translateY(-1px); box-shadow: 0 6px 20px rgba(59,130,246,0.4); color: #fff; -webkit-text-fill-color: #fff; }
    .btn-hero-outline { display: inline-flex; align-items: center; gap: 7px; padding: 10px 20px; border-radius: 9px; background: rgba(255,255,255,0.06); color: var(--text-secondary, #94a3b8); -webkit-text-fill-color: var(--text-secondary, #94a3b8); font-size: 0.875rem; font-weight: 600; text-decoration: none; border: 1px solid rgba(255,255,255,0.12); transition: all 0.2s; }
    .btn-hero-outline:hover { background: rgba(255,255,255,0.10); color: #f1f5f9; -webkit-text-fill-color: #f1f5f9; }
    .rel-card { display: block; background: rgba(255,255,255,0.04); border: 1px solid rgba(255,255,255,0.08); border-radius: 12px; padding: 18px; text-decoration: none; transition: all 0.22s; }
    .rel-card:hover { border-color: rgba(59,130,246,0.3); transform: translateY(-3px); box-shadow: 0 8px 24px rgba(0,0,0,0.25); }
    .breadcrumb-bar { padding: 12px 0; border-bottom: 1px solid rgba(255,255,255,0.06); font-size: 0.8125rem; }
    .breadcrumb-bar a { color: var(--text-muted, #64748b); text-decoration: none; }
    .breadcrumb-bar a:hover { color: var(--text-secondary, #94a3b8); }
    .breadcrumb-bar span { color: var(--text-secondary, #94a3b8); }
    .stars { color: #f59e0b; letter-spacing: 1px; }
    .gc-green { background: rgba(34,197,94,0.06); border-left: 3px solid rgba(34,197,94,0.4); }
    .gc-red { background: rgba(239,68,68,0.05); border-left: 3px solid rgba(239,68,68,0.3); }
    .kpi-grid { display:grid; grid-template-columns:repeat(4,minmax(0,1fr)); gap:12px; margin-top:22px; }
    .kpi-card { padding:14px 16px; border-radius:14px; background:rgba(255,255,255,0.05); border:1px solid rgba(255,255,255,0.08); }
    .kpi-card span { display:block; }
    .kpi-card__label { color:#64748b; font-size:.7rem; text-transform:uppercase; letter-spacing:.08em; }
    .kpi-card__value { color:#f1f5f9; font-size:1rem; font-weight:700; margin-top:6px; }
    @media (max-width: 992px) { .kpi-grid { grid-template-columns:repeat(2,minmax(0,1fr)); } }
    @media (max-width: 576px) { .kpi-grid { grid-template-columns:1fr; } }
  </style>
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "SoftwareApplication",
    "name": "<%= escapeJs(tool.getToolName()) %>",
    "applicationCategory": "<%= escapeJs(safeString(tool.getCategory(), "AI Tool")) %>",
    "operatingSystem": "<%= escapeJs(joinList(tool.getSupportedPlatforms(), "Web")) %>",
    "description": "<%= escapeJs(safeString(tool.getPurposeSummary(), tool.getToolName() + " 상세 정보")) %>",
    "offers": {
      "@type": "Offer",
      "price": "<%= escapeJs(safeString(tool.getPricingModel(), tool.isFreeTierAvailable() ? "0" : "Contact")) %>",
      "priceCurrency": "KRW"
    },
    "aggregateRating": {
      "@type": "AggregateRating",
      "ratingValue": "<%= tool.getRating() != null ? String.format(java.util.Locale.US, "%.1f", tool.getRating()) : "0.0" %>",
      "reviewCount": "<%= tool.getReviewCount() != null ? tool.getReviewCount() : 0 %>"
    },
    "publisher": {
      "@type": "Organization",
      "name": "<%= escapeJs(safeString(tool.getProviderName(), "AI Workflow Lab")) %>"
    }
  }
  </script>
</head>
<body>
<%@ include file="/AI/partials/header.jsp" %>

<!-- 브레드크럼 -->
<div class="hero-section">
  <div class="pi">
    <div class="breadcrumb-bar mb-4">
      <a href="/AI/user/home.jsp">홈</a>
      <span class="mx-2">›</span>
      <a href="/AI/user/tools/navigator.jsp">AI 도구 탐색</a>
      <span class="mx-2">›</span>
      <span><%= escapeHtml(tool.getToolName()) %></span>
    </div>

    <!-- 히어로 콘텐츠 -->
    <div class="d-flex align-items-start gap-4 flex-wrap">
      <!-- 로고 -->
      <div style="flex-shrink:0;">
        <img src="<%= logoInfo[0] %>" alt="<%= escapeHtml(safeString(tool.getProviderName(), "")) %>"
             style="width:64px;height:64px;border-radius:12px;object-fit:contain;background:rgba(255,255,255,0.06);padding:8px;"
             onerror="this.style.display='none';document.getElementById('logo-fallback-<%= tool.getId() %>').style.display='flex';">
        <div id="logo-fallback-<%= tool.getId() %>"
             style="display:none;width:64px;height:64px;border-radius:12px;background:rgba(255,255,255,0.06);align-items:center;justify-content:center;font-size:1.75rem;">
          <i class="bi bi-hexagon-fill"></i>
        </div>
      </div>

      <!-- 정보 -->
      <div class="flex-grow-1">
        <!-- 배지 행 -->
        <div class="d-flex align-items-center gap-2 mb-2 flex-wrap">
          <%
            String cat = safeString(tool.getCategory(), "");
            String catBg, catColor;
            if ("Text Generation".equals(cat)) { catBg = "rgba(59,130,246,0.15)"; catColor = "#60a5fa"; }
            else if ("Code Generation".equals(cat)) { catBg = "rgba(34,197,94,0.15)"; catColor = "#4ade80"; }
            else if ("Image Generation".equals(cat)) { catBg = "rgba(168,85,247,0.15)"; catColor = "#c084fc"; }
            else if ("Voice Processing".equals(cat)) { catBg = "rgba(249,115,22,0.15)"; catColor = "#fb923c"; }
            else { catBg = "rgba(100,116,139,0.15)"; catColor = "#94a3b8"; }
          %>
          <% if (!cat.isEmpty()) { %>
          <span class="cat-badge" style="background:<%= catBg %>;color:<%= catColor %>;border:1px solid <%= catColor %>33;">
            <%= escapeHtml(cat) %>
          </span>
          <% } %>
          <% String diff = safeString(tool.getDifficultyLevel(), ""); if (!diff.isEmpty()) { %>
          <span class="cat-badge" style="background:rgba(100,116,139,0.15);color:#94a3b8;border:1px solid rgba(100,116,139,0.25);">
            <%= escapeHtml(diff) %>
          </span>
          <% } %>
          <% if (tool.isFreeTierAvailable()) { %>
          <span class="cat-badge" style="background:rgba(16,185,129,0.15);color:#34d399;border:1px solid rgba(16,185,129,0.3);">
            무료
          </span>
          <% } %>
        </div>

        <h1 style="font-size:2rem;font-weight:700;color:#f1f5f9;margin-bottom:8px;"><%= escapeHtml(tool.getToolName()) %></h1>
        <p style="color:#94a3b8;font-size:1rem;margin-bottom:14px;"><%= escapeHtml(safeString(tool.getPurposeSummary(), "")) %></p>

        <!-- 별점 -->
        <% if (tool.getRating() != null) { %>
        <div class="d-flex align-items-center gap-2 mb-18" style="margin-bottom:18px;">
          <span class="stars"><%= tool.getStarRating() %></span>
          <span style="color:#f59e0b;font-size:0.875rem;font-weight:600;"><%= String.format("%.1f", tool.getRating()) %></span>
          <span style="color:#64748b;font-size:0.8125rem;">(<%= tool.getReviewCount() != null ? tool.getReviewCount() : 0 %>개 리뷰)</span>
        </div>
        <% } %>

        <!-- CTA 버튼 -->
        <div class="d-flex gap-2 flex-wrap">
          <% if (tool.getWebsiteUrl() != null && !tool.getWebsiteUrl().isEmpty()) { %>
          <a href="<%= escapeHtml(tool.getWebsiteUrl()) %>" target="_blank" rel="noopener" class="btn-hero-primary">
            <i class="bi bi-box-arrow-up-right"></i>공식 사이트
          </a>
          <% } %>
          <% if (tool.getPlaygroundUrl() != null && !tool.getPlaygroundUrl().isEmpty()) { %>
          <a href="<%= escapeHtml(tool.getPlaygroundUrl()) %>" target="_blank" rel="noopener" class="btn-hero-outline">
            <i class="bi bi-play-circle"></i>체험하기
          </a>
          <% } %>
          <% if (tool.getDocsUrl() != null && !tool.getDocsUrl().isEmpty()) { %>
          <a href="<%= escapeHtml(tool.getDocsUrl()) %>" target="_blank" rel="noopener" class="btn-hero-outline">
            <i class="bi bi-book"></i>문서
          </a>
          <% } %>
          <a href="/AI/user/tools/navigator.jsp" class="btn-hero-outline">
            <i class="bi bi-arrow-left"></i>뒤로가기
          </a>
          <a href="/AI/user/tools/rankings.jsp?category=<%= java.net.URLEncoder.encode(safeString(tool.getCategory(), ""), "UTF-8") %>" class="btn-hero-outline">
            <i class="bi bi-trophy"></i>카테고리 랭킹
          </a>
          <a href="/AI/user/tools/compare.jsp?ids=<%= tool.getId() %>" class="btn-hero-outline">
            <i class="bi bi-layout-split"></i>비교
          </a>
          <a href="/AI/user/news/index.jsp" class="btn-hero-outline">
            <i class="bi bi-newspaper"></i>뉴스
          </a>
        </div>

        <div class="kpi-grid">
          <div class="kpi-card">
            <span class="kpi-card__label">Global Rank</span>
            <span class="kpi-card__value"><%= escapeHtml(tool.getRankDisplay()) %></span>
          </div>
          <div class="kpi-card">
            <span class="kpi-card__label">Trend Score</span>
            <span class="kpi-card__value"><%= escapeHtml(tool.getTrendDisplay()) %></span>
          </div>
          <div class="kpi-card">
            <span class="kpi-card__label">Monthly Visits</span>
            <span class="kpi-card__value"><%= escapeHtml(tool.getFormattedMonthlyVisits()) %></span>
          </div>
          <div class="kpi-card">
            <span class="kpi-card__label">Monthly Active Users</span>
            <span class="kpi-card__value"><%= escapeHtml(tool.getFormattedMonthlyActiveUsers()) %></span>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- 메인 콘텐츠 -->
<div class="pi py-5">
  <div class="row g-4">

    <!-- 왼쪽 컬럼 -->
    <div class="col-lg-8">

      <!-- 도구 소개 -->
      <%
        String desc = safeString(tool.getDescription(), safeString(tool.getPurposeSummary(), ""));
        if (!desc.isEmpty()) {
      %>
      <div class="gc">
        <p class="gc-title"><i class="bi bi-info-circle me-2"></i>도구 소개</p>
        <p style="color:#94a3b8;font-size:0.9375rem;line-height:1.75;margin:0;"><%= escapeHtml(desc) %></p>
      </div>
      <% } %>

      <!-- 주요 기능 -->
      <% if (tool.getFeatures() != null && !tool.getFeatures().isEmpty()) { %>
      <div class="gc">
        <p class="gc-title"><i class="bi bi-stars me-2"></i>주요 기능</p>
        <div class="row g-2">
          <% for (String feat : tool.getFeatures()) { %>
          <div class="col-md-6">
            <div class="feat-item">
              <i class="bi bi-check-circle-fill"></i>
              <span><%= escapeHtml(feat) %></span>
            </div>
          </div>
          <% } %>
        </div>
      </div>
      <% } %>

      <!-- 활용 사례 / 장점 -->
      <% if (tool.getUseCases() != null && !tool.getUseCases().isEmpty()) { %>
      <div class="gc gc-green">
        <p class="gc-title" style="color:#4ade80;"><i class="bi bi-lightbulb-fill me-2"></i>활용 사례 / 장점</p>
        <% for (String uc : tool.getUseCases()) { %>
        <div class="d-flex gap-2 align-items-start mb-2" style="font-size:0.875rem;color:#94a3b8;">
          <i class="bi bi-check-circle-fill" style="color:#4ade80;flex-shrink:0;margin-top:2px;"></i>
          <span><%= escapeHtml(uc) %></span>
        </div>
        <% } %>
      </div>
      <% } %>

      <!-- 가격 정보 -->
      <% if (tool.getPricingDetails() != null && !tool.getPricingDetails().isEmpty()) { %>
      <div class="gc gc-red">
        <p class="gc-title" style="color:#f87171;"><i class="bi bi-cash-coin me-2"></i>가격 정보</p>
        <p style="color:#94a3b8;font-size:0.875rem;line-height:1.65;margin-bottom:12px;"><%= escapeHtml(tool.getPricingDetails()) %></p>
        <% if (tool.isFreeTierAvailable()) { %>
        <span class="cat-badge" style="background:rgba(16,185,129,0.15);color:#34d399;border:1px solid rgba(16,185,129,0.3);">무료 플랜 있음</span>
        <% } else { %>
        <span class="cat-badge" style="background:rgba(239,68,68,0.12);color:#f87171;border:1px solid rgba(239,68,68,0.25);">유료</span>
        <% } %>
      </div>
      <% } %>

      <!-- 태그 -->
      <% if (tool.getTags() != null && !tool.getTags().isEmpty()) { %>
      <div class="gc">
        <p class="gc-title"><i class="bi bi-tags me-2"></i>태그</p>
        <% for (String tag : tool.getTags()) { %>
        <a href="/AI/user/tools/navigator.jsp?keyword=<%= java.net.URLEncoder.encode(tag, "UTF-8") %>" class="tag-pill"><%= escapeHtml(tag) %></a>
        <% } %>
      </div>
      <% } %>
    </div>

    <!-- 오른쪽 컬럼 -->
    <div class="col-lg-4">

      <!-- 기본 스펙 -->
      <div class="gc">
        <p class="gc-title"><i class="bi bi-clipboard-data me-2"></i>기본 스펙</p>

        <div class="spec-row">
          <span class="spec-label">제공 국가</span>
          <span class="spec-value"><%= escapeHtml(countryLabel(tool.getProviderCountry())) %></span>
        </div>
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
          <span class="spec-label">글로벌 랭크</span>
          <span class="spec-value"><%= escapeHtml(tool.getRankDisplay()) %></span>
        </div>
        <div class="spec-row">
          <span class="spec-label">트렌드 점수</span>
          <span class="spec-value"><%= escapeHtml(tool.getTrendDisplay()) %></span>
        </div>
        <div class="spec-row">
          <span class="spec-label">성장률</span>
          <span class="spec-value"><%= escapeHtml(tool.getGrowthDisplay()) %></span>
        </div>
        <div class="spec-row">
          <span class="spec-label">월간 방문</span>
          <span class="spec-value"><%= escapeHtml(tool.getFormattedMonthlyVisits()) %></span>
        </div>
        <div class="spec-row">
          <span class="spec-label">활성 사용자</span>
          <span class="spec-value"><%= escapeHtml(tool.getFormattedMonthlyActiveUsers()) %></span>
        </div>
        <div class="spec-row">
          <span class="spec-label">GitHub Stars</span>
          <span class="spec-value"><%= escapeHtml(tool.getFormattedGithubStars()) %></span>
        </div>
        <div class="spec-row">
          <span class="spec-label">무료 플랜</span>
          <span class="spec-value"><%= tool.isFreeTierAvailable() ? "<i class='bi bi-check-circle-fill' style='color:#34d399;margin-right:4px;'></i>있음" : "<i class='bi bi-x-circle-fill' style='color:#f87171;margin-right:4px;'></i>없음" %></span>
        </div>
        <div class="spec-row">
          <span class="spec-label">API 제공</span>
          <span class="spec-value"><%= tool.isApiAvailable() ? "<i class='bi bi-check-circle-fill' style='color:#34d399;margin-right:4px;'></i>있음" : "<i class='bi bi-x-circle-fill' style='color:#f87171;margin-right:4px;'></i>없음" %></span>
        </div>
        <% if (tool.getPricingModel() != null && !tool.getPricingModel().isEmpty()) { %>
        <div class="spec-row">
          <span class="spec-label">요금 모델</span>
          <span class="spec-value"><%= escapeHtml(tool.getPricingModel()) %></span>
        </div>
        <% } %>
        <div class="spec-row">
          <span class="spec-label">상업적 이용</span>
          <span class="spec-value"><%= tool.isCommercialUseAllowed() ? "<i class='bi bi-check-circle-fill' style='color:#34d399;margin-right:4px;'></i>허용" : "<i class='bi bi-x-circle-fill' style='color:#f87171;margin-right:4px;'></i>제한" %></span>
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

      <!-- 요금 상세 (사이드) -->
      <% if (tool.getPricingDetails() != null && !tool.getPricingDetails().isEmpty()) { %>
      <div class="gc">
        <p class="gc-title"><i class="bi bi-cash-coin me-2"></i>요금 상세</p>
        <p style="color:#94a3b8;font-size:0.8125rem;line-height:1.65;margin:0;"><%= escapeHtml(tool.getPricingDetails()) %></p>
      </div>
      <% } %>

      <!-- 지원 언어 -->
      <% if (tool.getSupportedLanguages() != null && !tool.getSupportedLanguages().isEmpty()) { %>
      <div class="gc">
        <p class="gc-title"><i class="bi bi-translate me-2"></i>지원 언어</p>
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
    <h5 style="color:#f1f5f9;font-weight:600;margin-bottom:20px;">
      <i class="bi bi-grid-3x3-gap me-2" style="color:#60a5fa;"></i>같은 카테고리 도구
    </h5>
    <div class="row g-3">
      <% for (AITool rel : related) {
           String[] relLogo = getProviderLogo(rel.getProviderName(), rel.getToolName()); %>
      <div class="col-lg-4 col-md-6 col-12">
        <a href="/AI/user/tools/detail.jsp?id=<%= rel.getId() %>" class="rel-card">
          <div class="d-flex align-items-center gap-2 mb-2">
            <img src="<%= relLogo[0] %>" alt=""
                 style="width:24px;height:24px;border-radius:6px;object-fit:contain;background:rgba(255,255,255,0.06);padding:2px;"
                 onerror="this.style.display='none';">
            <span style="font-size:0.75rem;color:#64748b;"><%= escapeHtml(safeString(rel.getProviderName(), "")) %></span>
          </div>
          <div style="font-size:0.9375rem;font-weight:600;color:#f1f5f9;margin-bottom:6px;"><%= escapeHtml(rel.getToolName()) %></div>
          <div style="font-size:0.8125rem;color:#64748b;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden;margin-bottom:12px;">
            <%= escapeHtml(safeString(rel.getPurposeSummary(), "")) %>
          </div>
          <span style="font-size:0.8125rem;color:#60a5fa;font-weight:500;">자세히 보기 →</span>
        </a>
      </div>
      <% } %>
    </div>
  </div>
  <% } %>
</div>

<%@ include file="/AI/partials/footer.jsp" %>
</body>
</html>
