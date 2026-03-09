<%@ page contentType="text/html; charset=UTF-8" buffer="128kb" autoFlush="true" %>
<%@ page isELIgnored="true" %>
<%@ page import="dao.AIToolDAO" %>
<%@ page import="model.AITool" %>
<%@ page import="java.util.List" %>
<%@ include file="/AI/user/_common.jsp" %>

<%
  AIToolDAO toolDao = new AIToolDAO();
  List<AITool> tools = toolDao.findAll();

  // URL 파라미터 → JS 초기 필터 상태로만 사용 (클라이언트 필터링)
  String initKeyword    = safeString(request.getParameter("keyword"),    "");
  String initCategory   = safeString(request.getParameter("category"),   "");
  String initDifficulty = safeString(request.getParameter("difficulty"),  "");

  // 카테고리 → 컬러 + 이모지 헬퍼 (카드 렌더링용)
%>
<%!
  // 카테고리별 그라데이션 컬러바
  private String catGradient(String cat) {
    if (cat == null) return "linear-gradient(135deg,#64748b,#94a3b8)";
    switch (cat) {
      case "Text Generation":  return "linear-gradient(135deg,#3b82f6,#60a5fa)";
      case "Code Generation":  return "linear-gradient(135deg,#22c55e,#4ade80)";
      case "Image Generation": return "linear-gradient(135deg,#a855f7,#c084fc)";
      case "Voice Processing": return "linear-gradient(135deg,#f97316,#fb923c)";
      case "Video Processing": return "linear-gradient(135deg,#8b5cf6,#a78bfa)";
      case "Translation":      return "linear-gradient(135deg,#ec4899,#f472b6)";
      case "Data Analysis":    return "linear-gradient(135deg,#06b6d4,#22d3ee)";
      default:                 return "linear-gradient(135deg,#64748b,#94a3b8)";
    }
  }

  // 카테고리별 이모지
  private String catEmoji(String cat) {
    if (cat == null) return "🤖";
    switch (cat) {
      case "Text Generation":  return "💬";
      case "Code Generation":  return "💻";
      case "Image Generation": return "🎨";
      case "Voice Processing": return "🎵";
      case "Video Processing": return "🎬";
      case "Translation":      return "🌍";
      case "Data Analysis":    return "📊";
      default:                 return "🤖";
    }
  }

  // 난이도 한글
  private String diffKo(String diff) {
    if ("Beginner".equals(diff))     return "입문";
    if ("Intermediate".equals(diff)) return "중급";
    if ("Advanced".equals(diff))     return "고급";
    return diff != null ? diff : "";
  }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>AI 도구 탐색기 — AI Workflow Lab</title>
  <meta name="description" content="카테고리·난이도·키워드로 AI 도구를 검색하고 비교하세요.">
  <link rel="icon" href="data:,">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
  <link rel="stylesheet" href="/AI/assets/css/dark-theme.css">
  <link rel="stylesheet" href="/AI/assets/css/animations.css">

  <style>
    /* ===== Base ===== */
    body {
      padding-top: 60px;
      background: var(--bg-primary, #0a0f1e);
      color: var(--text-primary, #f1f5f9);
      font-family: 'Noto Sans KR', -apple-system, BlinkMacSystemFont, sans-serif;
    }

    /* ===== Page Header ===== */
    .nav-header {
      padding: 48px 0 0;
      background: var(--bg-primary, #0a0f1e);
    }

    .nav-header__inner {
      max-width: 1200px;
      margin: 0 auto;
      padding: 0 24px;
    }

    .nav-header__title {
      font-size: clamp(1.75rem, 4vw, 2.5rem);
      font-weight: 700;
      letter-spacing: -0.025em;
      margin: 0 0 8px;
      color: var(--text-primary, #f1f5f9);
    }

    .nav-header__sub {
      font-size: 1rem;
      color: var(--text-secondary, #94a3b8);
      margin: 0 0 28px;
    }

    /* ===== Search Bar ===== */
    .nav-search {
      position: relative;
      margin-bottom: 20px;
    }

    .nav-search__icon {
      position: absolute;
      left: 16px;
      top: 50%;
      transform: translateY(-50%);
      color: var(--text-muted, #64748b);
      font-size: 1.1rem;
      pointer-events: none;
    }

    .nav-search__input {
      width: 100%;
      padding: 14px 48px;
      background: rgba(255,255,255,0.05);
      border: 1px solid rgba(255,255,255,0.10);
      border-radius: 12px;
      color: var(--text-primary, #f1f5f9);
      font-size: 0.9375rem;
      font-family: inherit;
      transition: all 0.2s ease;
    }

    .nav-search__input::placeholder { color: var(--text-muted, #64748b); }

    .nav-search__input:focus {
      outline: none;
      border-color: rgba(59,130,246,0.5);
      background: rgba(255,255,255,0.07);
      box-shadow: 0 0 0 3px rgba(59,130,246,0.12);
    }

    .nav-search__clear {
      position: absolute;
      right: 14px;
      top: 50%;
      transform: translateY(-50%);
      background: none;
      border: none;
      color: var(--text-muted, #64748b);
      cursor: pointer;
      padding: 4px;
      display: none;
      font-size: 1rem;
      line-height: 1;
      transition: color 0.2s;
    }

    .nav-search__clear:hover { color: var(--text-primary, #f1f5f9); }
    .nav-search__input:not(:placeholder-shown) ~ .nav-search__clear { display: block; }

    /* ===== Filter Pills — Row 1: Category ===== */
    .filter-row1 {
      overflow-x: auto;
      display: flex;
      gap: 8px;
      padding-bottom: 4px;
      margin-bottom: 12px;
      scrollbar-width: none;
    }
    .filter-row1::-webkit-scrollbar { display: none; }

    .cat-btn {
      display: inline-flex;
      align-items: center;
      gap: 5px;
      padding: 7px 16px;
      border-radius: 999px;
      font-size: 0.8125rem;
      font-weight: 500;
      white-space: nowrap;
      border: 1px solid rgba(255,255,255,0.12);
      background: rgba(255,255,255,0.05);
      color: var(--text-secondary, #94a3b8);
      cursor: pointer;
      transition: all 0.18s ease;
      flex-shrink: 0;
    }

    .cat-btn:hover {
      background: rgba(255,255,255,0.09);
      color: var(--text-primary, #f1f5f9);
      border-color: rgba(255,255,255,0.20);
    }

    /* Active states per category */
    .cat-btn.active[data-cat=""]                { background: rgba(255,255,255,0.12); color: #f1f5f9; border-color: rgba(255,255,255,0.25); }
    .cat-btn.active[data-cat="Text Generation"] { background: rgba(59,130,246,0.18);  color: #60a5fa; border-color: rgba(59,130,246,0.40); }
    .cat-btn.active[data-cat="Code Generation"] { background: rgba(34,197,94,0.18);   color: #4ade80; border-color: rgba(34,197,94,0.40); }
    .cat-btn.active[data-cat="Image Generation"]{ background: rgba(168,85,247,0.18);  color: #c084fc; border-color: rgba(168,85,247,0.40); }
    .cat-btn.active[data-cat="Voice Processing"]{ background: rgba(249,115,22,0.18);  color: #fb923c; border-color: rgba(249,115,22,0.40); }
    .cat-btn.active[data-cat="Video Processing"]{ background: rgba(139,92,246,0.18);  color: #a78bfa; border-color: rgba(139,92,246,0.40); }
    .cat-btn.active[data-cat="Translation"]     { background: rgba(236,72,153,0.18);  color: #f472b6; border-color: rgba(236,72,153,0.40); }
    .cat-btn.active[data-cat="Data Analysis"]   { background: rgba(6,182,212,0.18);   color: #22d3ee; border-color: rgba(6,182,212,0.40); }

    /* ===== Filter Row 2: Difficulty + Sort ===== */
    .filter-row2 {
      display: flex;
      align-items: center;
      gap: 10px;
      margin-bottom: 0;
      flex-wrap: wrap;
    }

    .diff-group {
      display: flex;
      gap: 6px;
    }

    .diff-btn {
      padding: 6px 14px;
      border-radius: 8px;
      font-size: 0.8125rem;
      font-weight: 500;
      border: 1px solid rgba(255,255,255,0.10);
      background: rgba(255,255,255,0.04);
      color: var(--text-secondary, #94a3b8);
      cursor: pointer;
      transition: all 0.18s ease;
      white-space: nowrap;
    }

    .diff-btn:hover {
      background: rgba(255,255,255,0.08);
      color: var(--text-primary, #f1f5f9);
    }

    .diff-btn.active {
      background: rgba(255,255,255,0.10);
      color: var(--text-primary, #f1f5f9);
      border-color: rgba(255,255,255,0.22);
    }

    .diff-btn.active[data-diff="Beginner"]     { background: rgba(34,197,94,0.15);  color: #4ade80; border-color: rgba(34,197,94,0.35); }
    .diff-btn.active[data-diff="Intermediate"] { background: rgba(245,158,11,0.15); color: #fbbf24; border-color: rgba(245,158,11,0.35); }
    .diff-btn.active[data-diff="Advanced"]     { background: rgba(239,68,68,0.15);  color: #f87171; border-color: rgba(239,68,68,0.35); }

    .sort-select {
      margin-left: auto;
      padding: 6px 12px;
      border-radius: 8px;
      border: 1px solid rgba(255,255,255,0.10);
      background: rgba(255,255,255,0.05);
      color: var(--text-secondary, #94a3b8);
      font-size: 0.8125rem;
      font-family: inherit;
      cursor: pointer;
      transition: all 0.18s ease;
    }

    .sort-select:focus {
      outline: none;
      border-color: rgba(59,130,246,0.4);
      color: var(--text-primary, #f1f5f9);
    }

    .sort-select option { background: #1e293b; color: #f1f5f9; }

    /* ===== Results area ===== */
    .nav-results {
      max-width: 1200px;
      margin: 0 auto;
      padding: 24px 24px 80px;
    }

    .results-meta {
      display: flex;
      align-items: center;
      justify-content: space-between;
      margin-bottom: 20px;
      font-size: 0.875rem;
      color: var(--text-muted, #64748b);
    }

    .results-meta strong { color: var(--text-secondary, #94a3b8); }

    /* ===== Tool Grid ===== */
    .tool-grid {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 18px;
    }

    /* ===== Tool Card ===== */
    .tc {
      background: rgba(255,255,255,0.045);
      border: 1px solid rgba(255,255,255,0.09);
      border-radius: 14px;
      overflow: hidden;
      display: flex;
      flex-direction: column;
      transition: border-color 0.22s ease, transform 0.22s ease, box-shadow 0.22s ease;
      cursor: pointer;
    }

    .tc:hover {
      border-color: rgba(59,130,246,0.32);
      transform: translateY(-4px);
      box-shadow: 0 0 28px rgba(59,130,246,0.14), 0 12px 32px rgba(0,0,0,0.28);
    }

    /* Colored top bar */
    .tc__bar {
      height: 4px;
      transition: height 0.22s ease;
    }

    .tc:hover .tc__bar { height: 8px; }

    /* Card body */
    .tc__body {
      padding: 18px 20px 20px;
      display: flex;
      flex-direction: column;
      flex: 1;
    }

    /* Top row: emoji + provider */
    .tc__top {
      display: flex;
      align-items: flex-start;
      justify-content: space-between;
      margin-bottom: 14px;
    }

    .tc__emoji {
      font-size: 2.25rem;
      line-height: 1;
    }

    .tc__provider {
      display: flex;
      align-items: center;
      gap: 6px;
      max-width: 50%;
    }

    .tc__plogo {
      width: 18px;
      height: 18px;
      border-radius: 4px;
      object-fit: contain;
      flex-shrink: 0;
    }

    .tc__pname {
      font-size: 0.75rem;
      color: var(--text-muted, #64748b);
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }

    /* Tool name */
    .tc__name {
      font-size: 1.0625rem;
      font-weight: 700;
      color: var(--text-primary, #f1f5f9);
      margin: 0 0 8px;
      letter-spacing: -0.01em;
    }

    /* Description */
    .tc__desc {
      font-size: 0.84375rem;
      color: var(--text-secondary, #94a3b8);
      line-height: 1.65;
      margin: 0 0 14px;
      display: -webkit-box;
      -webkit-line-clamp: 2;
      -webkit-box-orient: vertical;
      overflow: hidden;
      flex: 1;
    }

    /* Tags */
    .tc__tags {
      display: flex;
      gap: 5px;
      flex-wrap: wrap;
      margin-bottom: 14px;
    }

    .tc__tag {
      font-size: 0.6875rem;
      font-weight: 500;
      padding: 2px 9px;
      border-radius: 999px;
      background: rgba(255,255,255,0.06);
      color: var(--text-muted, #64748b);
      border: 1px solid rgba(255,255,255,0.09);
    }

    /* Footer row */
    .tc__footer {
      border-top: 1px solid rgba(255,255,255,0.07);
      padding-top: 12px;
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 8px;
    }

    .tc__badges {
      display: flex;
      align-items: center;
      gap: 6px;
      flex-wrap: wrap;
    }

    .tc__badge {
      font-size: 0.6875rem;
      font-weight: 600;
      padding: 2px 8px;
      border-radius: 5px;
    }

    .tc__badge--beginner     { background: rgba(34,197,94,0.12);  color: #4ade80; border: 1px solid rgba(34,197,94,0.22); }
    .tc__badge--intermediate { background: rgba(245,158,11,0.12); color: #fbbf24; border: 1px solid rgba(245,158,11,0.22); }
    .tc__badge--advanced     { background: rgba(239,68,68,0.12);  color: #f87171; border: 1px solid rgba(239,68,68,0.22); }
    .tc__badge--free         { background: rgba(34,197,94,0.10);  color: #4ade80; border: 1px solid rgba(34,197,94,0.18); }
    .tc__badge--paid         { background: rgba(255,255,255,0.05); color: var(--text-muted,#64748b); border: 1px solid rgba(255,255,255,0.09); }

    .tc__stars {
      font-size: 0.75rem;
      color: #f59e0b;
      letter-spacing: 1px;
    }

    .tc__link {
      font-size: 0.8125rem;
      font-weight: 600;
      color: #60a5fa;
      -webkit-text-fill-color: #60a5fa;
      text-decoration: none;
      white-space: nowrap;
      display: inline-flex;
      align-items: center;
      gap: 3px;
      transition: gap 0.15s ease, color 0.15s ease;
      flex-shrink: 0;
    }

    .tc__link:hover {
      gap: 6px;
      color: #93c5fd;
      -webkit-text-fill-color: #93c5fd;
    }

    /* ===== Empty State ===== */
    .empty-state {
      grid-column: 1 / -1;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      padding: 80px 24px;
      text-align: center;
    }

    .empty-state__emoji { font-size: 3.5rem; margin-bottom: 16px; }
    .empty-state__title { font-size: 1.125rem; font-weight: 600; color: var(--text-primary,#f1f5f9); margin: 0 0 8px; }
    .empty-state__sub   { font-size: 0.9rem; color: var(--text-muted,#64748b); margin: 0 0 24px; }

    .reset-btn {
      padding: 9px 20px;
      border-radius: 9px;
      background: rgba(59,130,246,0.12);
      color: #60a5fa;
      -webkit-text-fill-color: #60a5fa;
      border: 1px solid rgba(59,130,246,0.25);
      font-size: 0.875rem;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.18s ease;
      text-decoration: none;
    }

    .reset-btn:hover {
      background: rgba(59,130,246,0.20);
      color: #93c5fd;
      -webkit-text-fill-color: #93c5fd;
    }

    /* ===== Divider between header and results ===== */
    .nav-divider {
      max-width: 1200px;
      margin: 24px auto 0;
      padding: 0 24px;
      border-top: 1px solid rgba(255,255,255,0.07);
    }

    /* ===== Responsive ===== */
    @media (max-width: 1024px) {
      .tool-grid { grid-template-columns: repeat(2, 1fr); }
    }

    @media (max-width: 640px) {
      .tool-grid { grid-template-columns: 1fr; }
      .filter-row2 { flex-direction: column; align-items: flex-start; gap: 8px; }
      .sort-select { margin-left: 0; width: 100%; }
    }
  </style>
</head>
<body>
  <%@ include file="/AI/partials/header.jsp" %>

  <!-- ================================================================
       Page Header + Filters (sticky on desktop)
       ================================================================ -->
  <div class="nav-header" id="navHeaderBlock">
    <div class="nav-header__inner">
      <h1 class="nav-header__title">🔍 AI 도구 탐색기</h1>
      <p class="nav-header__sub">원하는 AI 도구를 탐색하고 비교해보세요</p>

      <!-- Search -->
      <div class="nav-search">
        <i class="bi bi-search nav-search__icon"></i>
        <input
          id="searchInput"
          class="nav-search__input"
          type="text"
          placeholder="도구명, 기능, 키워드로 검색..."
          autocomplete="off"
          spellcheck="false"
        >
        <button class="nav-search__clear" id="searchClear" title="지우기">
          <i class="bi bi-x-lg"></i>
        </button>
      </div>

      <!-- Category filter pills -->
      <div class="filter-row1" role="group" aria-label="카테고리 필터">
        <button class="cat-btn" data-cat="">전체</button>
        <button class="cat-btn" data-cat="Text Generation">💬 대화</button>
        <button class="cat-btn" data-cat="Code Generation">💻 코딩</button>
        <button class="cat-btn" data-cat="Image Generation">🎨 이미지생성</button>
        <button class="cat-btn" data-cat="Voice Processing">🎵 오디오</button>
        <button class="cat-btn" data-cat="Video Processing">🎬 비디오</button>
        <button class="cat-btn" data-cat="Translation">📝 문서작성</button>
        <button class="cat-btn" data-cat="Data Analysis">📊 데이터분석</button>
      </div>

      <!-- Row 2: Difficulty + Sort -->
      <div class="filter-row2">
        <div class="diff-group" role="group" aria-label="난이도 필터">
          <button class="diff-btn" data-diff="">전체</button>
          <button class="diff-btn" data-diff="Beginner">입문</button>
          <button class="diff-btn" data-diff="Intermediate">중급</button>
          <button class="diff-btn" data-diff="Advanced">고급</button>
        </div>
        <select class="sort-select" id="sortSelect" aria-label="정렬">
          <option value="default">추천순</option>
          <option value="rating">별점순</option>
          <option value="reviews">인기순</option>
          <option value="newest">최신순</option>
        </select>
      </div>
    </div>
  </div>

  <!-- ================================================================
       Results
       ================================================================ -->
  <div class="nav-divider"></div>

  <div class="nav-results">
    <!-- Meta: count -->
    <div class="results-meta">
      <span>총 <strong id="resultsCount"><%= tools.size() %></strong>개 도구</span>
    </div>

    <!-- Tool Grid -->
    <div class="tool-grid" id="toolGrid">

      <% for (AITool tool : tools) {
           String cat   = safeString(tool.getCategory(), "");
           String diff  = safeString(tool.getDifficultyLevel(), "");
           String desc  = safeString(tool.getPurposeSummary(), safeString(tool.getDescription(), ""));
           String[] logo = getProviderLogo(tool.getProviderName(), tool.getToolName());

           // Stringify tags for data-attr (comma separated)
           StringBuilder tagsStr = new StringBuilder();
           if (tool.getTags() != null) {
             for (String t : tool.getTags()) { if (tagsStr.length() > 0) tagsStr.append(","); tagsStr.append(t); }
           }

           Double rating = tool.getRating();
           int    reviews = tool.getReviewCount() != null ? tool.getReviewCount() : 0;
           String diffClass = "tc__badge--" + diff.toLowerCase();
      %>
      <div class="tc"
           data-name="<%= escapeHtmlAttribute(tool.getToolName()) %>"
           data-desc="<%= escapeHtmlAttribute(desc) %>"
           data-category="<%= escapeHtmlAttribute(cat) %>"
           data-difficulty="<%= escapeHtmlAttribute(diff) %>"
           data-tags="<%= escapeHtmlAttribute(tagsStr.toString()) %>"
           data-rating="<%= rating != null ? rating : 0 %>"
           data-reviews="<%= reviews %>"
           data-id="<%= tool.getId() %>"
           onclick="location.href='/AI/user/tools/detail.jsp?id=<%= tool.getId() %>'">

        <!-- Color bar -->
        <div class="tc__bar" style="background: <%= catGradient(cat) %>;"></div>

        <div class="tc__body">
          <!-- Top: emoji + provider -->
          <div class="tc__top">
            <span class="tc__emoji" aria-hidden="true"><%= catEmoji(cat) %></span>
            <div class="tc__provider">
              <img src="<%= logo[0] %>"
                   alt="<%= escapeHtml(tool.getProviderName()) %>"
                   class="tc__plogo"
                   onerror="this.style.display='none'">
              <span class="tc__pname"><%= escapeHtml(safeString(tool.getProviderName(), "")) %></span>
            </div>
          </div>

          <!-- Name -->
          <h3 class="tc__name"><%= escapeHtml(tool.getToolName()) %></h3>

          <!-- Description -->
          <p class="tc__desc"><%= escapeHtml(desc) %></p>

          <!-- Tags -->
          <% if (tool.getTags() != null && !tool.getTags().isEmpty()) { %>
          <div class="tc__tags">
            <% int tagCount = 0;
               for (String tag : tool.getTags()) {
                 if (tagCount >= 3) break; %>
            <span class="tc__tag"><%= escapeHtml(tag) %></span>
            <%   tagCount++;
               } %>
          </div>
          <% } %>

          <!-- Footer: badges + link -->
          <div class="tc__footer">
            <div class="tc__badges">
              <% if (!diff.isEmpty()) { %>
              <span class="tc__badge <%= diffClass %>"><%= diffKo(diff) %></span>
              <% } %>
              <% if (tool.isFreeTierAvailable()) { %>
              <span class="tc__badge tc__badge--free">무료</span>
              <% } else { %>
              <span class="tc__badge tc__badge--paid">유료</span>
              <% } %>
              <% if (rating != null) { %>
              <span class="tc__stars"><%= tool.getStarRating() %></span>
              <% } %>
            </div>
            <a href="/AI/user/tools/detail.jsp?id=<%= tool.getId() %>"
               class="tc__link"
               onclick="event.stopPropagation()">
              자세히 보기 <i class="bi bi-arrow-right"></i>
            </a>
          </div>
        </div><!-- /.tc__body -->
      </div><!-- /.tc -->
      <% } %>

      <!-- Empty State (hidden by default, shown via JS) -->
      <div class="empty-state" id="emptyState" style="display:none;">
        <div class="empty-state__emoji">🔍</div>
        <h3 class="empty-state__title">검색 결과가 없습니다</h3>
        <p class="empty-state__sub">다른 키워드나 필터를 시도해보세요.</p>
        <button class="reset-btn" id="resetBtn">필터 초기화</button>
      </div>
    </div><!-- /#toolGrid -->
  </div>

  <%@ include file="/AI/partials/footer.jsp" %>

  <!-- ================================================================
       Client-side Filter + Sort
       ================================================================ -->
  <script>
  (function () {
    'use strict';

    /* ── State ── */
    var state = {
      keyword:    '<%= escapeHtmlAttribute(initKeyword) %>',
      category:   '<%= escapeHtmlAttribute(initCategory) %>',
      difficulty: '<%= escapeHtmlAttribute(initDifficulty) %>',
      sort:       'default'
    };

    /* ── DOM refs ── */
    var searchInput  = document.getElementById('searchInput');
    var searchClear  = document.getElementById('searchClear');
    var sortSelect   = document.getElementById('sortSelect');
    var toolGrid     = document.getElementById('toolGrid');
    var resultsCount = document.getElementById('resultsCount');
    var emptyState   = document.getElementById('emptyState');
    var catBtns      = document.querySelectorAll('.cat-btn');
    var diffBtns     = document.querySelectorAll('.diff-btn');
    var resetBtn     = document.getElementById('resetBtn');

    /* ── All card elements (exclude empty-state) ── */
    var allCards = Array.from(document.querySelectorAll('.tc'));

    /* ── Set initial UI state from URL params ── */
    if (state.keyword) searchInput.value = state.keyword;

    catBtns.forEach(function (btn) {
      btn.classList.toggle('active', btn.dataset.cat === state.category);
    });
    diffBtns.forEach(function (btn) {
      btn.classList.toggle('active', btn.dataset.diff === state.difficulty);
    });

    /* ── Filter ── */
    function filterCards() {
      var kw   = state.keyword.trim().toLowerCase();
      var cat  = state.category;
      var diff = state.difficulty;
      var visible = 0;

      allCards.forEach(function (card) {
        var name  = (card.dataset.name  || '').toLowerCase();
        var desc  = (card.dataset.desc  || '').toLowerCase();
        var tags  = (card.dataset.tags  || '').toLowerCase();
        var cCat  = card.dataset.category  || '';
        var cDiff = card.dataset.difficulty || '';

        var matchKw   = !kw   || name.includes(kw)   || desc.includes(kw)   || tags.includes(kw);
        var matchCat  = !cat  || cCat  === cat;
        var matchDiff = !diff || cDiff === diff;

        var show = matchKw && matchCat && matchDiff;
        card.style.display = show ? '' : 'none';
        if (show) visible++;
      });

      resultsCount.textContent = visible;
      emptyState.style.display = visible === 0 ? 'flex' : 'none';
    }

    /* ── Sort ── */
    function sortCards() {
      var s = state.sort;
      var sorted = allCards.slice().sort(function (a, b) {
        if (s === 'rating')  return parseFloat(b.dataset.rating  || 0) - parseFloat(a.dataset.rating  || 0);
        if (s === 'reviews') return parseInt(b.dataset.reviews   || 0) - parseInt(a.dataset.reviews   || 0);
        if (s === 'newest')  return parseInt(b.dataset.id        || 0) - parseInt(a.dataset.id        || 0);
        /* default (추천순): rating desc, then reviews desc */
        var rDiff = parseFloat(b.dataset.rating || 0) - parseFloat(a.dataset.rating || 0);
        return rDiff !== 0 ? rDiff : parseInt(b.dataset.reviews || 0) - parseInt(a.dataset.reviews || 0);
      });
      sorted.forEach(function (card) { toolGrid.insertBefore(card, emptyState); });
    }

    function apply() {
      sortCards();
      filterCards();
    }

    /* ── Search input (debounced) ── */
    var debounceTimer;
    searchInput.addEventListener('input', function () {
      state.keyword = this.value;
      clearTimeout(debounceTimer);
      debounceTimer = setTimeout(apply, 160);
    });

    searchClear.addEventListener('click', function () {
      searchInput.value = '';
      state.keyword = '';
      apply();
      searchInput.focus();
    });

    /* ── Category buttons ── */
    catBtns.forEach(function (btn) {
      btn.addEventListener('click', function () {
        catBtns.forEach(function (b) { b.classList.remove('active'); });
        btn.classList.add('active');
        state.category = btn.dataset.cat;
        apply();
      });
    });

    /* ── Difficulty buttons ── */
    diffBtns.forEach(function (btn) {
      btn.addEventListener('click', function () {
        diffBtns.forEach(function (b) { b.classList.remove('active'); });
        btn.classList.add('active');
        state.difficulty = btn.dataset.diff;
        apply();
      });
    });

    /* ── Sort select ── */
    sortSelect.addEventListener('change', function () {
      state.sort = this.value;
      apply();
    });

    /* ── Reset button ── */
    resetBtn.addEventListener('click', function () {
      state.keyword = '';
      state.category = '';
      state.difficulty = '';
      state.sort = 'default';

      searchInput.value = '';
      sortSelect.value = 'default';
      catBtns.forEach(function (b) { b.classList.remove('active'); });
      diffBtns.forEach(function (b) { b.classList.remove('active'); });

      // activate "전체" buttons
      document.querySelector('.cat-btn[data-cat=""]').classList.add('active');
      document.querySelector('.diff-btn[data-diff=""]').classList.add('active');

      apply();
    });

    /* ── Initial run ── */
    apply();

  })();
  </script>
</body>
</html>
