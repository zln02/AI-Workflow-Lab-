<%@ page contentType="text/html; charset=UTF-8" buffer="128kb" autoFlush="true" %>
<%@ page isELIgnored="true" %>
<%@ page import="dao.AIToolDAO" %>
<%@ page import="model.AITool" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ include file="/AI/user/_common.jsp" %>
<%
  AIToolDAO toolDao = new AIToolDAO();

  List<Integer> compareIds = new ArrayList<>();
  String idsParam = safeString(request.getParameter("ids"), "");
  if (!idsParam.isEmpty()) {
    for (String raw : idsParam.split(",")) {
      try {
        int parsed = Integer.parseInt(raw.trim());
        if (parsed > 0 && !compareIds.contains(parsed)) compareIds.add(parsed);
      } catch (Exception ignored) {}
    }
  }

  String idAParam = safeString(request.getParameter("a"), "");
  String idBParam = safeString(request.getParameter("b"), "");
  try {
    if (!idAParam.isEmpty()) {
      int parsed = Integer.parseInt(idAParam);
      if (parsed > 0 && !compareIds.contains(parsed)) compareIds.add(parsed);
    }
    if (!idBParam.isEmpty()) {
      int parsed = Integer.parseInt(idBParam);
      if (parsed > 0 && !compareIds.contains(parsed)) compareIds.add(parsed);
    }
  } catch (Exception ignored) {}

  List<AITool> selected = new ArrayList<>();
  for (Integer id : compareIds) {
    AITool item = toolDao.findById(id);
    if (item != null) selected.add(item);
    if (selected.size() >= 3) break;
  }

  List<AITool> suggestions = toolDao.findFiltered(null, null, null, null, false, false, "trend", 12, 0);
%>
<%!
  private String yn(boolean value) { return value ? "예" : "아니오"; }

  private String safeMetric(String value) {
    return value == null || value.trim().isEmpty() ? "-" : value;
  }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>AI 도구 비교 - AI Workflow Lab</title>
  <link rel="icon" href="data:,">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
  <link rel="stylesheet" href="/AI/assets/css/dark-theme.css">
  <style>
    body { padding-top: 60px; background: #07111f; color: #f8fafc; font-family: 'Noto Sans KR', sans-serif; }
    .page { max-width: 1280px; margin: 0 auto; padding: 36px 24px 80px; }
    .hero, .panel, .compare-table, .pick-card {
      border-radius: 24px; background: rgba(255,255,255,0.04); border: 1px solid rgba(255,255,255,0.08);
    }
    .hero {
      padding: 30px; margin-bottom: 20px;
      background:
        radial-gradient(circle at top right, rgba(139,92,246,0.15), transparent 22%),
        radial-gradient(circle at bottom left, rgba(34,197,94,0.14), transparent 24%),
        linear-gradient(160deg, rgba(15,23,42,0.95), rgba(8,15,29,0.98));
    }
    .hero h1 { margin: 10px 0 8px; font-size: clamp(1.8rem, 4vw, 2.8rem); font-weight: 800; }
    .hero p { margin: 0; color: #94a3b8; max-width: 760px; }
    .hero-actions { display:flex; gap:10px; flex-wrap:wrap; margin-top:20px; }
    .link-pill {
      display:inline-flex; align-items:center; gap:8px; padding:10px 14px; border-radius:999px;
      text-decoration:none; color:#cbd5e1; background:rgba(255,255,255,0.05); border:1px solid rgba(255,255,255,0.08); font-size:.85rem; font-weight:700;
    }
    .layout { display:grid; grid-template-columns: 1.5fr .85fr; gap:18px; }
    .compare-table { overflow:hidden; }
    table { width:100%; border-collapse: collapse; }
    th, td { padding: 16px 18px; border-bottom: 1px solid rgba(255,255,255,0.07); vertical-align: top; }
    thead th { background: rgba(255,255,255,0.03); font-size: .8rem; text-transform: uppercase; letter-spacing: .08em; color: #93c5fd; }
    tbody td:first-child { width: 180px; color:#64748b; font-size:.82rem; font-weight:700; }
    tbody td { color:#e2e8f0; font-size:.92rem; }
    .tool-head { display:flex; flex-direction:column; gap:4px; }
    .tool-name { font-size:1.04rem; font-weight:800; color:#f8fafc; }
    .tool-sub { color:#94a3b8; font-size:.82rem; }
    .value-strong { color:#f8fafc; font-weight:800; }
    .tag-row { display:flex; gap:8px; flex-wrap:wrap; }
    .tag {
      display:inline-flex; align-items:center; padding:4px 9px; border-radius:999px;
      background: rgba(255,255,255,0.05); border:1px solid rgba(255,255,255,0.08); color:#94a3b8; font-size:.72rem;
    }
    .panel { padding: 18px; }
    .section-title { display:flex; align-items:center; gap:8px; margin:0 0 14px; font-size:1rem; font-weight:800; }
    .pick-grid { display:grid; gap:12px; }
    .pick-card { padding:16px; text-decoration:none; color:inherit; transition: all .18s ease; }
    .pick-card:hover { transform: translateY(-2px); border-color: rgba(96,165,250,0.32); }
    .pick-title { color:#f8fafc; font-size:.96rem; font-weight:800; margin-bottom:6px; }
    .pick-sub { color:#94a3b8; font-size:.82rem; margin-bottom:10px; line-height:1.6; }
    .cta {
      display:inline-flex; align-items:center; gap:8px; padding:8px 12px; border-radius:999px; text-decoration:none;
      background: rgba(59,130,246,0.16); color:#93c5fd; border:1px solid rgba(96,165,250,0.24); font-size:.8rem; font-weight:700;
    }
    .empty { padding: 50px 24px; text-align:center; color:#94a3b8; }
    @media (max-width: 1024px) { .layout { grid-template-columns: 1fr; } }
    @media (max-width: 640px) {
      .page { padding-left:16px; padding-right:16px; }
      thead { display:none; }
      table, tbody, tr, td { display:block; width:100%; }
      tbody td:first-child { width:auto; padding-bottom:6px; border-bottom:none; }
      tr { padding: 12px 0; border-bottom: 1px solid rgba(255,255,255,0.07); }
    }
  </style>
</head>
<body>
<%@ include file="/AI/partials/header.jsp" %>
<div class="page">
  <section class="hero">
    <div style="color:#60a5fa;font-size:.76rem;font-weight:700;letter-spacing:.12em;text-transform:uppercase;">Compare</div>
    <h1>AI 도구 비교</h1>
    <p>핵심 지표와 운영 특성을 같은 기준으로 나란히 비교할 수 있게 구성했습니다. 상세 페이지나 랭킹 보드에서 원하는 도구를 가져와 비교하면 됩니다.</p>
    <div class="hero-actions">
      <a href="/AI/user/tools/navigator.jsp" class="link-pill"><i class="bi bi-compass"></i> 탐색기</a>
      <a href="/AI/user/tools/rankings.jsp" class="link-pill"><i class="bi bi-trophy"></i> 랭킹</a>
      <a href="/AI/user/news/index.jsp" class="link-pill"><i class="bi bi-newspaper"></i> 뉴스</a>
    </div>
  </section>

  <div class="layout">
    <section class="compare-table">
      <% if (selected.size() < 2) { %>
        <div class="empty">
          비교할 도구 2개 이상을 선택해 주세요.<br>
          예시: <code>/AI/user/tools/compare.jsp?ids=1,2</code>
        </div>
      <% } else { %>
        <table>
          <thead>
            <tr>
              <th>항목</th>
              <% for (AITool tool : selected) { %>
                <th>
                  <div class="tool-head">
                    <span class="tool-name"><%= escapeHtml(tool.getToolName()) %></span>
                    <span class="tool-sub"><%= escapeHtml(safeString(tool.getProviderName(), "")) %></span>
                  </div>
                </th>
              <% } %>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>카테고리</td>
              <% for (AITool tool : selected) { %><td><%= escapeHtml(safeString(tool.getCategory(), "-")) %></td><% } %>
            </tr>
            <tr>
              <td>글로벌 랭크</td>
              <% for (AITool tool : selected) { %><td class="value-strong"><%= escapeHtml(tool.getRankDisplay()) %></td><% } %>
            </tr>
            <tr>
              <td>트렌드 점수</td>
              <% for (AITool tool : selected) { %><td><%= escapeHtml(tool.getTrendDisplay()) %></td><% } %>
            </tr>
            <tr>
              <td>성장률</td>
              <% for (AITool tool : selected) { %><td><%= escapeHtml(tool.getGrowthDisplay()) %></td><% } %>
            </tr>
            <tr>
              <td>월간 방문</td>
              <% for (AITool tool : selected) { %><td><%= escapeHtml(tool.getFormattedMonthlyVisits()) %></td><% } %>
            </tr>
            <tr>
              <td>활성 사용자</td>
              <% for (AITool tool : selected) { %><td><%= escapeHtml(tool.getFormattedMonthlyActiveUsers()) %></td><% } %>
            </tr>
            <tr>
              <td>GitHub Stars</td>
              <% for (AITool tool : selected) { %><td><%= escapeHtml(tool.getFormattedGithubStars()) %></td><% } %>
            </tr>
            <tr>
              <td>난이도</td>
              <% for (AITool tool : selected) { %><td><%= escapeHtml(safeString(tool.getDifficultyLevel(), "-")) %></td><% } %>
            </tr>
            <tr>
              <td>요금 모델</td>
              <% for (AITool tool : selected) { %><td><%= escapeHtml(safeMetric(tool.getPricingDisplay())) %></td><% } %>
            </tr>
            <tr>
              <td>API 제공</td>
              <% for (AITool tool : selected) { %><td><%= yn(tool.isApiAvailable()) %></td><% } %>
            </tr>
            <tr>
              <td>무료 플랜</td>
              <% for (AITool tool : selected) { %><td><%= yn(tool.isFreeTierAvailable()) %></td><% } %>
            </tr>
            <tr>
              <td>엔터프라이즈</td>
              <% for (AITool tool : selected) { %><td><%= yn(tool.isEnterpriseReady()) %></td><% } %>
            </tr>
            <tr>
              <td>오픈소스</td>
              <% for (AITool tool : selected) { %><td><%= yn(tool.isOpenSource()) %></td><% } %>
            </tr>
            <tr>
              <td>입출력 형식</td>
              <% for (AITool tool : selected) { %><td><%= escapeHtml(safeMetric(tool.getInputModalities())) %> → <%= escapeHtml(safeMetric(tool.getOutputModalities())) %></td><% } %>
            </tr>
            <tr>
              <td>플랫폼</td>
              <% for (AITool tool : selected) { %>
                <td>
                  <div class="tag-row">
                    <% if (tool.getSupportedPlatforms() != null && !tool.getSupportedPlatforms().isEmpty()) {
                         for (String platform : tool.getSupportedPlatforms()) { %>
                      <span class="tag"><%= escapeHtml(platform) %></span>
                    <%   }
                       } else { %>
                      <span class="tag">-</span>
                    <% } %>
                  </div>
                </td>
              <% } %>
            </tr>
            <tr>
              <td>핵심 태그</td>
              <% for (AITool tool : selected) { %>
                <td>
                  <div class="tag-row">
                    <% if (tool.getTags() != null && !tool.getTags().isEmpty()) {
                         int limit = 0;
                         for (String tag : tool.getTags()) {
                           if (limit >= 4) break; %>
                      <span class="tag"><%= escapeHtml(tag) %></span>
                    <%     limit++;
                         }
                       } else { %>
                      <span class="tag">-</span>
                    <% } %>
                  </div>
                </td>
              <% } %>
            </tr>
          </tbody>
        </table>
      <% } %>
    </section>

    <aside class="panel">
      <h2 class="section-title"><i class="bi bi-stars"></i>비교 후보</h2>
      <div class="pick-grid">
        <% for (AITool tool : suggestions) { %>
          <div class="pick-card">
            <div class="pick-title"><%= escapeHtml(tool.getToolName()) %></div>
            <div class="pick-sub"><%= escapeHtml(safeString(tool.getProviderName(), "")) %> · Rank <%= escapeHtml(tool.getRankDisplay()) %> · Trend <%= escapeHtml(tool.getTrendDisplay()) %></div>
            <div style="display:flex;gap:8px;flex-wrap:wrap;">
              <a class="cta" href="/AI/user/tools/detail.jsp?id=<%= tool.getId() %>"><i class="bi bi-box-arrow-up-right"></i>상세</a>
              <% if (!selected.isEmpty()) {
                   StringBuilder ids = new StringBuilder();
                   ids.append(selected.get(0).getId()).append(",").append(tool.getId()); %>
                <a class="cta" href="/AI/user/tools/compare.jsp?ids=<%= ids.toString() %>"><i class="bi bi-layout-split"></i>빠른 비교</a>
              <% } %>
            </div>
          </div>
        <% } %>
      </div>
    </aside>
  </div>
</div>
<%@ include file="/AI/partials/footer.jsp" %>
</body>
</html>
