<%@ page contentType="text/html; charset=UTF-8" buffer="128kb" autoFlush="true" %>
<%@ page isELIgnored="true" %>
<%@ page import="dao.AIToolDAO" %>
<%@ page import="model.AITool" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.LinkedHashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ include file="/AI/user/_common.jsp" %>
<%
  AIToolDAO toolDao = new AIToolDAO();

  String sort = safeString(request.getParameter("sort"), "rank");
  String category = safeString(request.getParameter("category"), "");
  String country = safeString(request.getParameter("country"), "");
  List<AITool> tools = toolDao.findFiltered(null, category, null, country, false, false, sort, 30, 0);

  String rankingTitle = "AI 도구 랭킹";
  if ("trend".equals(sort)) rankingTitle = "트렌드 랭킹";
  else if ("reviews".equals(sort)) rankingTitle = "사용자 규모 랭킹";
  else if ("visits".equals(sort)) rankingTitle = "월간 방문 랭킹";
  else if ("github".equals(sort)) rankingTitle = "오픈소스 랭킹";
  else if ("rating".equals(sort)) rankingTitle = "평점 랭킹";
  else if ("newest".equals(sort)) rankingTitle = "최신 업데이트 랭킹";

  List<AITool> chartTools = tools.size() > 10 ? tools.subList(0, 10) : tools;
  Map<String, Integer> countryCounts = new LinkedHashMap<>();
  for (AITool tool : tools) {
    String code = safeString(tool.getProviderCountry(), "ETC");
    countryCounts.put(code, countryCounts.getOrDefault(code, 0) + 1);
  }
  List<String> countryLabels = new ArrayList<>(countryCounts.keySet());
  List<Integer> countryValues = new ArrayList<>(countryCounts.values());
%>
<%!
  private String countryLabel(String code) {
    if (code == null || code.isEmpty()) return "전체 국가";
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

  private String metricLabel(String sort) {
    if ("trend".equals(sort)) return "Trend";
    if ("reviews".equals(sort)) return "MAU";
    if ("visits".equals(sort)) return "Visits";
    if ("github".equals(sort)) return "GitHub";
    if ("rating".equals(sort)) return "Rating";
    if ("newest".equals(sort)) return "Updated";
    return "Rank";
  }

  private String metricValue(AITool tool, String sort) {
    if ("trend".equals(sort)) return tool.getTrendDisplay();
    if ("reviews".equals(sort)) return tool.getFormattedMonthlyActiveUsers();
    if ("visits".equals(sort)) return tool.getFormattedMonthlyVisits();
    if ("github".equals(sort)) return tool.getFormattedGithubStars();
    if ("rating".equals(sort)) return tool.getRating() != null ? String.format(java.util.Locale.US, "%.1f", tool.getRating()) : "-";
    if ("newest".equals(sort)) return tool.getLastMajorUpdate() != null ? tool.getLastMajorUpdate().toString() : "-";
    return tool.getRankDisplay();
  }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><%= escapeHtml(rankingTitle) %> - AI Workflow Lab</title>
  <link rel="icon" href="data:,">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
  <link rel="stylesheet" href="/AI/assets/css/dark-theme.css">
  <style>
    body { padding-top: 60px; background: #07111f; color: #f8fafc; font-family: 'Noto Sans KR', sans-serif; }
    .page-wrap { max-width: 1240px; margin: 0 auto; padding: 36px 24px 80px; }
    .hero {
      border: 1px solid rgba(255,255,255,0.08);
      border-radius: 24px;
      padding: 28px;
      background:
        radial-gradient(circle at top right, rgba(96,165,250,0.18), transparent 30%),
        radial-gradient(circle at bottom left, rgba(16,185,129,0.14), transparent 28%),
        linear-gradient(160deg, rgba(15,23,42,0.95), rgba(8,15,29,0.98));
      margin-bottom: 22px;
    }
    .eyebrow { color: #60a5fa; font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.12em; font-weight: 700; }
    .hero h1 { margin: 10px 0 8px; font-size: clamp(1.8rem, 4vw, 2.8rem); font-weight: 800; }
    .hero p { margin: 0; color: #94a3b8; max-width: 760px; }
    .hero-actions { display: flex; flex-wrap: wrap; gap: 10px; margin-top: 22px; }
    .pill-row, .filter-row { display: flex; flex-wrap: wrap; gap: 10px; }
    .pill, .filter-link {
      display: inline-flex; align-items: center; gap: 6px;
      padding: 9px 14px; border-radius: 999px; text-decoration: none;
      border: 1px solid rgba(255,255,255,0.10); color: #94a3b8; background: rgba(255,255,255,0.05);
      font-size: 0.875rem; font-weight: 600; transition: all .18s ease;
    }
    .pill:hover, .filter-link:hover { color: #f8fafc; background: rgba(255,255,255,0.09); }
    .pill.active, .filter-link.active { color: #f8fafc; border-color: rgba(96,165,250,0.38); background: rgba(59,130,246,0.18); }
    .stats-grid { display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 14px; margin: 22px 0 0; }
    .stat-card {
      padding: 16px; border-radius: 18px; background: rgba(255,255,255,0.05);
      border: 1px solid rgba(255,255,255,0.08);
    }
    .stat-label { color: #64748b; font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.08em; }
    .stat-value { display: block; margin-top: 6px; font-size: 1.3rem; font-weight: 800; }
    .filters-panel {
      display: flex; justify-content: space-between; gap: 18px; flex-wrap: wrap;
      padding: 18px 20px; margin-bottom: 18px; border-radius: 18px;
      background: rgba(255,255,255,0.04); border: 1px solid rgba(255,255,255,0.08);
    }
    .board { display: grid; gap: 14px; }
    .rank-card {
      display: grid; grid-template-columns: 72px 1.4fr 1fr 180px; gap: 14px; align-items: center;
      padding: 18px; border-radius: 20px; text-decoration: none; color: inherit;
      background: rgba(255,255,255,0.04); border: 1px solid rgba(255,255,255,0.08);
      transition: transform .18s ease, border-color .18s ease, box-shadow .18s ease;
    }
    .rank-card:hover { transform: translateY(-2px); border-color: rgba(96,165,250,0.35); box-shadow: 0 12px 28px rgba(0,0,0,0.22); }
    .rank-badge {
      width: 54px; height: 54px; border-radius: 16px; display: flex; align-items: center; justify-content: center;
      background: linear-gradient(135deg, rgba(59,130,246,0.25), rgba(139,92,246,0.25));
      color: #f8fafc; font-weight: 800; font-size: 1.05rem; border: 1px solid rgba(96,165,250,0.28);
    }
    .rank-card:nth-child(1) .rank-badge { background: linear-gradient(135deg, rgba(251,191,36,0.30), rgba(245,158,11,0.22)); }
    .rank-card:nth-child(2) .rank-badge { background: linear-gradient(135deg, rgba(226,232,240,0.24), rgba(148,163,184,0.24)); }
    .rank-card:nth-child(3) .rank-badge { background: linear-gradient(135deg, rgba(251,146,60,0.24), rgba(217,119,6,0.22)); }
    .tool-title { font-size: 1.05rem; font-weight: 700; color: #f8fafc; margin-bottom: 4px; }
    .tool-sub { color: #94a3b8; font-size: 0.86rem; margin-bottom: 8px; }
    .tool-tags { display: flex; gap: 8px; flex-wrap: wrap; }
    .tag {
      display: inline-flex; align-items: center; padding: 4px 10px; border-radius: 999px;
      background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.08); color: #94a3b8; font-size: 0.74rem;
    }
    .kpis { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 10px; }
    .kpi {
      padding: 10px 12px; border-radius: 14px; background: rgba(255,255,255,0.04); border: 1px solid rgba(255,255,255,0.06);
    }
    .kpi-label { display: block; color: #64748b; font-size: 0.68rem; text-transform: uppercase; letter-spacing: 0.08em; }
    .kpi-value { display: block; margin-top: 4px; font-size: 0.9rem; font-weight: 700; color: #f8fafc; }
    .metric-box {
      text-align: right; padding: 12px 14px; border-radius: 16px;
      background: rgba(59,130,246,0.10); border: 1px solid rgba(96,165,250,0.20);
    }
    .metric-label { display: block; color: #93c5fd; font-size: 0.72rem; text-transform: uppercase; letter-spacing: 0.1em; }
    .metric-value { display: block; margin-top: 6px; font-size: 1.2rem; font-weight: 800; color: #f8fafc; }
    .metric-sub { display: block; margin-top: 4px; color: #94a3b8; font-size: 0.78rem; }
    .empty { padding: 40px 24px; border-radius: 18px; text-align: center; color: #94a3b8; background: rgba(255,255,255,0.04); border: 1px dashed rgba(255,255,255,0.10); }
    .viz-grid { display:grid; grid-template-columns: 1.3fr .9fr; gap:18px; margin-bottom:18px; }
    .viz-card {
      padding: 20px; border-radius: 20px;
      background: rgba(255,255,255,0.04); border: 1px solid rgba(255,255,255,0.08);
    }
    .viz-card canvas { width:100% !important; height:320px !important; }
    .viz-title { display:flex; align-items:center; justify-content:space-between; gap:12px; margin-bottom:14px; }
    .viz-title h2 { margin:0; font-size:1rem; font-weight:700; color:#f8fafc; }
    .viz-title p { margin:0; color:#94a3b8; font-size:.82rem; }
    @media (max-width: 1024px) {
      .stats-grid { grid-template-columns: repeat(2, minmax(0, 1fr)); }
      .viz-grid { grid-template-columns: 1fr; }
      .rank-card { grid-template-columns: 64px 1fr; }
      .metric-box { text-align: left; }
    }
    @media (max-width: 640px) {
      .page-wrap { padding-left: 16px; padding-right: 16px; }
      .stats-grid { grid-template-columns: 1fr; }
      .kpis { grid-template-columns: 1fr; }
    }
  </style>
</head>
<body>
<%@ include file="/AI/partials/header.jsp" %>
<div class="page-wrap">
  <section class="hero">
    <span class="eyebrow">Rankings</span>
    <h1><%= escapeHtml(rankingTitle) %></h1>
    <p>전략 문서 Phase 1에서 추가한 지표를 기준으로 AI 도구를 한눈에 비교합니다. 국가와 카테고리를 좁혀서 시장 지형을 바로 볼 수 있습니다.</p>

    <div class="hero-actions pill-row">
      <a class="pill<%= "rank".equals(sort) ? " active" : "" %>" href="/AI/user/tools/rankings.jsp?sort=rank&category=<%= java.net.URLEncoder.encode(category, "UTF-8") %>&country=<%= java.net.URLEncoder.encode(country, "UTF-8") %>"><i class="bi bi-trophy"></i> 랭킹</a>
      <a class="pill<%= "trend".equals(sort) ? " active" : "" %>" href="/AI/user/tools/rankings.jsp?sort=trend&category=<%= java.net.URLEncoder.encode(category, "UTF-8") %>&country=<%= java.net.URLEncoder.encode(country, "UTF-8") %>"><i class="bi bi-graph-up-arrow"></i> 트렌드</a>
      <a class="pill<%= "reviews".equals(sort) ? " active" : "" %>" href="/AI/user/tools/rankings.jsp?sort=reviews&category=<%= java.net.URLEncoder.encode(category, "UTF-8") %>&country=<%= java.net.URLEncoder.encode(country, "UTF-8") %>"><i class="bi bi-people"></i> 사용자 규모</a>
      <a class="pill<%= "visits".equals(sort) ? " active" : "" %>" href="/AI/user/tools/rankings.jsp?sort=visits&category=<%= java.net.URLEncoder.encode(category, "UTF-8") %>&country=<%= java.net.URLEncoder.encode(country, "UTF-8") %>"><i class="bi bi-globe2"></i> 방문량</a>
      <a class="pill<%= "github".equals(sort) ? " active" : "" %>" href="/AI/user/tools/rankings.jsp?sort=github&category=<%= java.net.URLEncoder.encode(category, "UTF-8") %>&country=<%= java.net.URLEncoder.encode(country, "UTF-8") %>"><i class="bi bi-github"></i> 오픈소스</a>
      <a class="pill<%= "rating".equals(sort) ? " active" : "" %>" href="/AI/user/tools/rankings.jsp?sort=rating&category=<%= java.net.URLEncoder.encode(category, "UTF-8") %>&country=<%= java.net.URLEncoder.encode(country, "UTF-8") %>"><i class="bi bi-star"></i> 평점</a>
      <a class="pill" href="/AI/user/news/index.jsp"><i class="bi bi-newspaper"></i> 뉴스</a>
    </div>

    <div class="stats-grid">
      <div class="stat-card">
        <span class="stat-label">필터 결과</span>
        <span class="stat-value"><%= tools.size() %></span>
      </div>
      <div class="stat-card">
        <span class="stat-label">카테고리</span>
        <span class="stat-value" style="font-size:1rem;"><%= escapeHtml(category.isEmpty() ? "전체" : category) %></span>
      </div>
      <div class="stat-card">
        <span class="stat-label">국가</span>
        <span class="stat-value" style="font-size:1rem;"><%= escapeHtml(countryLabel(country)) %></span>
      </div>
      <div class="stat-card">
        <span class="stat-label">기준</span>
        <span class="stat-value" style="font-size:1rem;"><%= escapeHtml(metricLabel(sort)) %></span>
      </div>
    </div>
  </section>

  <section class="filters-panel">
    <div class="filter-row">
      <a class="filter-link<%= category.isEmpty() ? " active" : "" %>" href="/AI/user/tools/rankings.jsp?sort=<%= java.net.URLEncoder.encode(sort, "UTF-8") %>&country=<%= java.net.URLEncoder.encode(country, "UTF-8") %>">전체 카테고리</a>
      <a class="filter-link<%= "종합 AI 어시스턴트".equals(category) ? " active" : "" %>" href="/AI/user/tools/rankings.jsp?sort=<%= java.net.URLEncoder.encode(sort, "UTF-8") %>&category=<%= java.net.URLEncoder.encode("종합 AI 어시스턴트", "UTF-8") %>&country=<%= java.net.URLEncoder.encode(country, "UTF-8") %>">종합 AI</a>
      <a class="filter-link<%= "코드 생성".equals(category) ? " active" : "" %>" href="/AI/user/tools/rankings.jsp?sort=<%= java.net.URLEncoder.encode(sort, "UTF-8") %>&category=<%= java.net.URLEncoder.encode("코드 생성", "UTF-8") %>&country=<%= java.net.URLEncoder.encode(country, "UTF-8") %>">코드</a>
      <a class="filter-link<%= "이미지 생성".equals(category) ? " active" : "" %>" href="/AI/user/tools/rankings.jsp?sort=<%= java.net.URLEncoder.encode(sort, "UTF-8") %>&category=<%= java.net.URLEncoder.encode("이미지 생성", "UTF-8") %>&country=<%= java.net.URLEncoder.encode(country, "UTF-8") %>">이미지</a>
      <a class="filter-link<%= "영상 생성".equals(category) ? " active" : "" %>" href="/AI/user/tools/rankings.jsp?sort=<%= java.net.URLEncoder.encode(sort, "UTF-8") %>&category=<%= java.net.URLEncoder.encode("영상 생성", "UTF-8") %>&country=<%= java.net.URLEncoder.encode(country, "UTF-8") %>">영상</a>
      <a class="filter-link<%= "문서/글쓰기".equals(category) ? " active" : "" %>" href="/AI/user/tools/rankings.jsp?sort=<%= java.net.URLEncoder.encode(sort, "UTF-8") %>&category=<%= java.net.URLEncoder.encode("문서/글쓰기", "UTF-8") %>&country=<%= java.net.URLEncoder.encode(country, "UTF-8") %>">문서</a>
    </div>
    <div class="filter-row">
      <a class="filter-link<%= country.isEmpty() ? " active" : "" %>" href="/AI/user/tools/rankings.jsp?sort=<%= java.net.URLEncoder.encode(sort, "UTF-8") %>&category=<%= java.net.URLEncoder.encode(category, "UTF-8") %>">전체 국가</a>
      <a class="filter-link<%= "US".equals(country) ? " active" : "" %>" href="/AI/user/tools/rankings.jsp?sort=<%= java.net.URLEncoder.encode(sort, "UTF-8") %>&category=<%= java.net.URLEncoder.encode(category, "UTF-8") %>&country=US">미국</a>
      <a class="filter-link<%= "KR".equals(country) ? " active" : "" %>" href="/AI/user/tools/rankings.jsp?sort=<%= java.net.URLEncoder.encode(sort, "UTF-8") %>&category=<%= java.net.URLEncoder.encode(category, "UTF-8") %>&country=KR">한국</a>
      <a class="filter-link<%= "CN".equals(country) ? " active" : "" %>" href="/AI/user/tools/rankings.jsp?sort=<%= java.net.URLEncoder.encode(sort, "UTF-8") %>&category=<%= java.net.URLEncoder.encode(category, "UTF-8") %>&country=CN">중국</a>
      <a class="filter-link" href="/AI/user/tools/navigator.jsp">탐색기로 이동</a>
    </div>
  </section>

  <% if (!chartTools.isEmpty()) { %>
    <section class="viz-grid">
      <div class="viz-card">
        <div class="viz-title">
          <div>
            <h2><i class="bi bi-bar-chart-line"></i> 상위 10개 성과 분포</h2>
            <p>현재 필터 조건에서 선택한 기준값을 바로 비교합니다.</p>
          </div>
        </div>
        <canvas id="rankingMetricChart" aria-label="랭킹 지표 차트"></canvas>
      </div>
      <div class="viz-card">
        <div class="viz-title">
          <div>
            <h2><i class="bi bi-pie-chart"></i> 국가 분포</h2>
            <p>현재 보드에 노출된 도구의 국가별 비중입니다.</p>
          </div>
        </div>
        <canvas id="countryMixChart" aria-label="국가 분포 차트"></canvas>
      </div>
    </section>
  <% } %>

  <section class="board">
    <% if (tools.isEmpty()) { %>
      <div class="empty">조건에 맞는 랭킹 데이터가 없습니다.</div>
    <% } %>

    <% for (int i = 0; i < tools.size(); i++) {
         AITool tool = tools.get(i); %>
      <a href="/AI/user/tools/detail.jsp?id=<%= tool.getId() %>" class="rank-card">
        <div class="rank-badge">#<%= i + 1 %></div>
        <div>
          <div class="tool-title"><%= escapeHtml(tool.getToolName()) %></div>
          <div class="tool-sub"><%= escapeHtml(safeString(tool.getProviderName(), "")) %> · <%= escapeHtml(countryLabel(safeString(tool.getProviderCountry(), ""))) %> · <%= escapeHtml(safeString(tool.getCategory(), "-")) %></div>
          <div class="tool-tags">
            <span class="tag"><%= escapeHtml(tool.getPricingDisplay()) %></span>
            <% if (tool.isEnterpriseReady()) { %><span class="tag">Enterprise</span><% } %>
            <% if (tool.isOpenSource()) { %><span class="tag">Open Source</span><% } %>
            <% if (tool.isApiAvailable()) { %><span class="tag">API</span><% } %>
            <span class="tag"> <a href="/AI/user/tools/compare.jsp?ids=<%= tool.getId() %>" style="color:inherit;text-decoration:none;">비교</a></span>
          </div>
        </div>
        <div class="kpis">
          <div class="kpi">
            <span class="kpi-label">Global Rank</span>
            <span class="kpi-value"><%= escapeHtml(tool.getRankDisplay()) %></span>
          </div>
          <div class="kpi">
            <span class="kpi-label">Trend</span>
            <span class="kpi-value"><%= escapeHtml(tool.getTrendDisplay()) %></span>
          </div>
          <div class="kpi">
            <span class="kpi-label">Growth</span>
            <span class="kpi-value"><%= escapeHtml(tool.getGrowthDisplay()) %></span>
          </div>
          <div class="kpi">
            <span class="kpi-label">Monthly Visits</span>
            <span class="kpi-value"><%= escapeHtml(tool.getFormattedMonthlyVisits()) %></span>
          </div>
        </div>
        <div class="metric-box">
          <span class="metric-label"><%= escapeHtml(metricLabel(sort)) %></span>
          <span class="metric-value"><%= escapeHtml(metricValue(tool, sort)) %></span>
          <span class="metric-sub">MAU <%= escapeHtml(tool.getFormattedMonthlyActiveUsers()) %> · GitHub <%= escapeHtml(tool.getFormattedGithubStars()) %></span>
        </div>
      </a>
    <% } %>
  </section>
</div>
<%@ include file="/AI/partials/footer.jsp" %>
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.3/dist/chart.umd.min.js"></script>
<script>
  (function () {
    const labels = [
      <% for (int i = 0; i < chartTools.size(); i++) { %>
        "<%= escapeJs(chartTools.get(i).getToolName()) %>"<%= i + 1 < chartTools.size() ? "," : "" %>
      <% } %>
    ];
    const metricValues = [
      <% for (int i = 0; i < chartTools.size(); i++) {
           AITool tool = chartTools.get(i);
           String value = "0";
           if ("trend".equals(sort)) value = tool.getTrendScore() != null ? String.format(java.util.Locale.US, "%.2f", tool.getTrendScore()) : "0";
           else if ("reviews".equals(sort)) value = tool.getMonthlyActiveUsers() != null ? String.valueOf(tool.getMonthlyActiveUsers()) : "0";
           else if ("visits".equals(sort)) value = tool.getMonthlyVisits() != null ? String.valueOf(tool.getMonthlyVisits()) : "0";
           else if ("github".equals(sort)) value = tool.getGithubStars() != null ? String.valueOf(tool.getGithubStars()) : "0";
           else if ("rating".equals(sort)) value = tool.getRating() != null ? String.format(java.util.Locale.US, "%.2f", tool.getRating()) : "0";
           else if ("newest".equals(sort)) value = tool.getLastMajorUpdate() != null ? String.valueOf(tool.getLastMajorUpdate().getTime()) : "0";
           else value = tool.getGlobalRank() != null ? String.valueOf(tool.getGlobalRank()) : "0";
      %>
        <%= value %><%= i + 1 < chartTools.size() ? "," : "" %>
      <% } %>
    ];
    const countryLabels = [
      <% for (int i = 0; i < countryLabels.size(); i++) { %>
        "<%= escapeJs(countryLabel(countryLabels.get(i))) %>"<%= i + 1 < countryLabels.size() ? "," : "" %>
      <% } %>
    ];
    const countryValues = [
      <% for (int i = 0; i < countryValues.size(); i++) { %>
        <%= countryValues.get(i) %><%= i + 1 < countryValues.size() ? "," : "" %>
      <% } %>
    ];

    if (window.Chart && labels.length) {
      const metricCtx = document.getElementById('rankingMetricChart');
      const countryCtx = document.getElementById('countryMixChart');
      const metricDescending = "<%= escapeJs(sort) %>" !== "rank";

      if (metricCtx) {
        new Chart(metricCtx, {
          type: 'bar',
          data: {
            labels,
            datasets: [{
              label: "<%= escapeJs(metricLabel(sort)) %>",
              data: metricValues,
              backgroundColor: 'rgba(96, 165, 250, 0.72)',
              borderColor: 'rgba(147, 197, 253, 1)',
              borderWidth: 1,
              borderRadius: 10
            }]
          },
          options: {
            maintainAspectRatio: false,
            plugins: {
              legend: { display: false }
            },
            scales: {
              x: {
                ticks: { color: '#cbd5e1' },
                grid: { display: false }
              },
              y: {
                reverse: !metricDescending,
                ticks: { color: '#94a3b8' },
                grid: { color: 'rgba(148, 163, 184, 0.12)' }
              }
            }
          }
        });
      }

      if (countryCtx && countryLabels.length) {
        new Chart(countryCtx, {
          type: 'doughnut',
          data: {
            labels: countryLabels,
            datasets: [{
              data: countryValues,
              backgroundColor: [
                'rgba(59, 130, 246, 0.85)',
                'rgba(16, 185, 129, 0.85)',
                'rgba(251, 191, 36, 0.85)',
                'rgba(244, 114, 182, 0.85)',
                'rgba(248, 113, 113, 0.85)',
                'rgba(167, 139, 250, 0.85)'
              ],
              borderColor: '#07111f',
              borderWidth: 3
            }]
          },
          options: {
            maintainAspectRatio: false,
            plugins: {
              legend: {
                position: 'bottom',
                labels: { color: '#cbd5e1', boxWidth: 12 }
              }
            }
          }
        });
      }
    }
  }());
</script>
</body>
</html>
