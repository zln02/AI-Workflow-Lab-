<%@ page contentType="text/html; charset=UTF-8" buffer="128kb" autoFlush="true" %>
<%@ page isELIgnored="true" %>
<%@ page import="dao.AIToolNewsDAO" %>
<%@ page import="dao.AIToolDAO" %>
<%@ page import="model.AIToolNews" %>
<%@ page import="model.AITool" %>
<%@ page import="java.util.List" %>
<%@ include file="/AI/user/_common.jsp" %>
<%
  AIToolNewsDAO newsDao = new AIToolNewsDAO();
  AIToolDAO toolDao = new AIToolDAO();

  String type = safeString(request.getParameter("type"), "");
  List<AIToolNews> featured = newsDao.findFeatured(4);
  List<AIToolNews> items = type.isEmpty() ? newsDao.findLatest(24) : newsDao.findByType(type, 24);
  List<AITool> trendingTools = toolDao.findFiltered(null, null, null, null, false, false, "trend", 6, 0);
%>
<%!
  private String newsTypeLabel(String type) {
    if (type == null || type.isEmpty()) return "전체";
    switch (type) {
      case "update": return "업데이트";
      case "launch": return "출시";
      case "funding": return "투자";
      case "comparison": return "비교";
      case "tutorial": return "튜토리얼";
      case "industry": return "산업";
      default: return type;
    }
  }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>AI 뉴스 - AI Workflow Lab</title>
  <link rel="icon" href="data:,">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
  <link rel="stylesheet" href="/AI/assets/css/dark-theme.css">
  <style>
    body { padding-top: 60px; background: #07111f; color: #f8fafc; font-family: 'Noto Sans KR', sans-serif; }
    .page { max-width: 1240px; margin: 0 auto; padding: 36px 24px 80px; }
    .hero {
      padding: 30px; border-radius: 24px; margin-bottom: 22px;
      background:
        radial-gradient(circle at top right, rgba(251,191,36,0.16), transparent 24%),
        radial-gradient(circle at bottom left, rgba(59,130,246,0.16), transparent 28%),
        linear-gradient(160deg, rgba(15,23,42,0.95), rgba(8,15,29,0.98));
      border: 1px solid rgba(255,255,255,0.08);
    }
    .hero h1 { font-size: clamp(1.8rem, 4vw, 2.8rem); font-weight: 800; margin: 10px 0 8px; }
    .hero p { color: #94a3b8; max-width: 760px; margin: 0; }
    .section-title { display:flex; align-items:center; gap:8px; margin: 0 0 14px; font-size:1rem; font-weight:700; color:#f8fafc; }
    .filters, .mini-grid, .news-grid { display:grid; gap:14px; }
    .filters { grid-template-columns: repeat(7, minmax(0, 1fr)); margin-top: 22px; }
    .filter-pill {
      display:flex; align-items:center; justify-content:center; padding:10px 12px; border-radius:999px;
      text-decoration:none; color:#94a3b8; background:rgba(255,255,255,0.05); border:1px solid rgba(255,255,255,0.08);
      font-size:.84rem; font-weight:600;
    }
    .filter-pill.active { background: rgba(59,130,246,0.18); color:#f8fafc; border-color: rgba(96,165,250,0.30); }
    .layout { display:grid; grid-template-columns: 1.5fr .9fr; gap:18px; }
    .featured-grid { display:grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap:14px; }
    .feature-card, .news-card, .mini-card {
      display:block; text-decoration:none; color:inherit; border-radius:20px;
      background:rgba(255,255,255,0.04); border:1px solid rgba(255,255,255,0.08);
      transition: transform .18s ease, border-color .18s ease, box-shadow .18s ease;
    }
    .feature-card:hover, .news-card:hover, .mini-card:hover { transform: translateY(-2px); border-color: rgba(96,165,250,0.32); box-shadow: 0 12px 28px rgba(0,0,0,0.22); }
    .feature-card { padding:18px; min-height: 210px; position:relative; overflow:hidden; }
    .feature-card__badge, .news-type {
      display:inline-flex; align-items:center; padding:5px 10px; border-radius:999px;
      background: rgba(251,191,36,0.14); color:#fcd34d; border:1px solid rgba(251,191,36,0.24); font-size:.72rem; font-weight:700;
    }
    .feature-card__title { margin:14px 0 8px; font-size:1.12rem; font-weight:800; line-height:1.35; }
    .feature-card__summary, .news-card__summary { color:#94a3b8; line-height:1.65; font-size:.9rem; }
    .feature-card__meta, .news-card__meta { display:flex; gap:10px; flex-wrap:wrap; color:#64748b; font-size:.78rem; margin-top:14px; }
    .panel { padding:18px; border-radius:20px; background:rgba(255,255,255,0.04); border:1px solid rgba(255,255,255,0.08); }
    .mini-grid { grid-template-columns: 1fr; }
    .mini-card { padding:14px 16px; }
    .mini-card__title { font-size:.95rem; font-weight:700; margin-bottom:6px; color:#f8fafc; }
    .mini-card__sub { color:#94a3b8; font-size:.82rem; }
    .news-grid { grid-template-columns: repeat(2, minmax(0, 1fr)); margin-top: 18px; }
    .news-card { padding:18px; }
    .news-card__title { font-size:1rem; font-weight:800; margin:12px 0 8px; color:#f8fafc; line-height:1.4; }
    .tag-row { display:flex; gap:8px; flex-wrap:wrap; margin-top:12px; }
    .tag { padding:4px 9px; border-radius:999px; background:rgba(255,255,255,0.05); border:1px solid rgba(255,255,255,0.08); color:#94a3b8; font-size:.72rem; }
    .empty { padding:40px 20px; text-align:center; color:#94a3b8; border:1px dashed rgba(255,255,255,0.10); border-radius:18px; }
    @media (max-width: 1024px) {
      .layout { grid-template-columns: 1fr; }
      .filters { grid-template-columns: repeat(3, minmax(0, 1fr)); }
    }
    @media (max-width: 640px) {
      .page { padding-left:16px; padding-right:16px; }
      .featured-grid, .news-grid, .filters { grid-template-columns: 1fr; }
    }
  </style>
</head>
<body>
<%@ include file="/AI/partials/header.jsp" %>
<div class="page">
  <section class="hero">
    <div style="color:#60a5fa;font-size:.76rem;font-weight:700;letter-spacing:.12em;text-transform:uppercase;">Newsroom</div>
    <h1>AI 뉴스 브리핑</h1>
    <p>도구 업데이트, 제품 출시, 비교 포인트를 한 화면에서 확인할 수 있도록 Phase 1 카탈로그 뉴스 레이어를 추가했습니다.</p>
    <div class="filters">
      <a class="filter-pill<%= type.isEmpty() ? " active" : "" %>" href="/AI/user/news/index.jsp">전체</a>
      <a class="filter-pill<%= "update".equals(type) ? " active" : "" %>" href="/AI/user/news/index.jsp?type=update">업데이트</a>
      <a class="filter-pill<%= "launch".equals(type) ? " active" : "" %>" href="/AI/user/news/index.jsp?type=launch">출시</a>
      <a class="filter-pill<%= "comparison".equals(type) ? " active" : "" %>" href="/AI/user/news/index.jsp?type=comparison">비교</a>
      <a class="filter-pill<%= "tutorial".equals(type) ? " active" : "" %>" href="/AI/user/news/index.jsp?type=tutorial">튜토리얼</a>
      <a class="filter-pill<%= "industry".equals(type) ? " active" : "" %>" href="/AI/user/news/index.jsp?type=industry">산업</a>
      <a class="filter-pill" href="/AI/user/tools/rankings.jsp">랭킹</a>
    </div>
  </section>

  <div class="layout">
    <section>
      <h2 class="section-title"><i class="bi bi-lightning-charge"></i>주요 뉴스</h2>
      <div class="featured-grid">
        <% for (AIToolNews item : featured) { %>
          <a href="/AI/user/news/detail.jsp?id=<%= item.getId() %>" class="feature-card">
            <span class="feature-card__badge"><%= escapeHtml(newsTypeLabel(item.getNewsType())) %></span>
            <div class="feature-card__title"><%= escapeHtml(item.getTitle()) %></div>
            <div class="feature-card__summary"><%= escapeHtml(item.getSummary()) %></div>
            <div class="feature-card__meta">
              <span><i class="bi bi-building"></i> <%= escapeHtml(safeString(item.getSourceName(), "AI Workflow Lab")) %></span>
              <span><i class="bi bi-calendar3"></i> <%= item.getPublishedAt() != null ? item.getPublishedAt().toLocalDateTime().toLocalDate().toString() : "-" %></span>
            </div>
          </a>
        <% } %>
      </div>

      <h2 class="section-title" style="margin-top:24px;"><i class="bi bi-newspaper"></i>최신 기사</h2>
      <% if (items.isEmpty()) { %>
        <div class="empty">표시할 뉴스가 없습니다.</div>
      <% } else { %>
        <div class="news-grid">
          <% for (AIToolNews item : items) { %>
            <a href="/AI/user/news/detail.jsp?id=<%= item.getId() %>" class="news-card">
              <span class="news-type"><%= escapeHtml(newsTypeLabel(item.getNewsType())) %></span>
              <div class="news-card__title"><%= escapeHtml(item.getTitle()) %></div>
              <div class="news-card__summary"><%= escapeHtml(item.getSummary()) %></div>
              <% if (item.getTags() != null && !item.getTags().isEmpty()) { %>
                <div class="tag-row">
                  <% for (String tag : item.getTags()) { %>
                    <span class="tag"><%= escapeHtml(tag) %></span>
                  <% } %>
                </div>
              <% } %>
              <div class="news-card__meta">
                <span><i class="bi bi-building"></i> <%= escapeHtml(safeString(item.getSourceName(), "AI Workflow Lab")) %></span>
                <span><i class="bi bi-eye"></i> <%= item.getViewCount() %></span>
              </div>
            </a>
          <% } %>
        </div>
      <% } %>
    </section>

    <aside>
      <div class="panel">
        <h2 class="section-title"><i class="bi bi-graph-up"></i>트렌드 도구</h2>
        <div class="mini-grid">
          <% for (AITool tool : trendingTools) { %>
            <a href="/AI/user/tools/detail.jsp?id=<%= tool.getId() %>" class="mini-card">
              <div class="mini-card__title"><%= escapeHtml(tool.getToolName()) %></div>
              <div class="mini-card__sub"><%= escapeHtml(safeString(tool.getProviderName(), "")) %> · Trend <%= escapeHtml(tool.getTrendDisplay()) %> · Growth <%= escapeHtml(tool.getGrowthDisplay()) %></div>
            </a>
          <% } %>
        </div>
      </div>

      <div class="panel" style="margin-top:18px;">
        <h2 class="section-title"><i class="bi bi-box-arrow-up-right"></i>바로 가기</h2>
        <div class="mini-grid">
          <a href="/AI/user/tools/navigator.jsp" class="mini-card">
            <div class="mini-card__title">AI 도구 탐색기</div>
            <div class="mini-card__sub">카테고리, 국가, 트렌드 기준으로 탐색</div>
          </a>
          <a href="/AI/user/tools/rankings.jsp" class="mini-card">
            <div class="mini-card__title">랭킹 보드</div>
            <div class="mini-card__sub">시장 지표 기반 상위 도구 비교</div>
          </a>
        </div>
      </div>
    </aside>
  </div>
</div>
<%@ include file="/AI/partials/footer.jsp" %>
</body>
</html>
