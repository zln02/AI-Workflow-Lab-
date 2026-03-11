<%@ page contentType="text/html; charset=UTF-8" buffer="128kb" autoFlush="true" %>
<%@ page isELIgnored="true" %>
<%@ page import="dao.AIToolNewsDAO" %>
<%@ page import="dao.AIToolDAO" %>
<%@ page import="model.AIToolNews" %>
<%@ page import="model.AITool" %>
<%@ page import="java.util.List" %>
<%@ include file="/AI/user/_common.jsp" %>
<%
  int newsId = 0;
  try { newsId = Integer.parseInt(request.getParameter("id")); } catch (Exception ignored) {}

  AIToolNewsDAO newsDao = new AIToolNewsDAO();
  AIToolDAO toolDao = new AIToolDAO();

  AIToolNews article = newsId > 0 ? newsDao.findById(newsId) : null;
  if (article == null) {
    response.sendRedirect("/AI/user/news/index.jsp");
    return;
  }

  AITool tool = article.getToolId() != null ? toolDao.findById(article.getToolId()) : null;
  List<AIToolNews> relatedNews = article.getToolId() != null ? newsDao.findByToolId(article.getToolId(), 6) : newsDao.findLatest(6);
  relatedNews.removeIf(n -> n.getId() == article.getId());
  if (relatedNews.size() > 4) relatedNews = relatedNews.subList(0, 4);
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
  <title><%= escapeHtml(article.getTitle()) %> - AI 뉴스</title>
  <link rel="icon" href="data:,">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
  <link rel="stylesheet" href="/AI/assets/css/dark-theme.css">
  <style>
    body { padding-top: 60px; background: #07111f; color: #f8fafc; font-family: 'Noto Sans KR', sans-serif; }
    .page { max-width: 1120px; margin: 0 auto; padding: 36px 24px 80px; }
    .hero, .panel, .article-body, .side-card {
      border-radius: 22px; background: rgba(255,255,255,0.04); border: 1px solid rgba(255,255,255,0.08);
    }
    .hero { padding: 30px; margin-bottom: 20px; background:
      radial-gradient(circle at top right, rgba(59,130,246,0.15), transparent 24%),
      linear-gradient(160deg, rgba(15,23,42,0.95), rgba(8,15,29,0.98)); }
    .badge-type {
      display:inline-flex; align-items:center; padding:6px 11px; border-radius:999px; font-size:.75rem; font-weight:700;
      background: rgba(59,130,246,0.16); color:#93c5fd; border:1px solid rgba(96,165,250,0.25);
    }
    .hero h1 { margin: 14px 0 10px; font-size: clamp(1.7rem, 4vw, 2.6rem); font-weight: 800; line-height: 1.3; }
    .hero p { color:#cbd5e1; line-height:1.75; margin:0; font-size:1rem; }
    .meta { display:flex; gap:14px; flex-wrap:wrap; color:#64748b; margin-top:18px; font-size:.82rem; }
    .layout { display:grid; grid-template-columns: 1.45fr .8fr; gap:18px; }
    .article-body { padding: 26px; }
    .article-body p { color:#cbd5e1; line-height:1.85; font-size:.97rem; margin:0 0 16px; }
    .article-body h2 { font-size:1.06rem; font-weight:800; margin:0 0 14px; color:#f8fafc; }
    .tag-row { display:flex; gap:8px; flex-wrap:wrap; margin-top:16px; }
    .tag { padding:4px 9px; border-radius:999px; background:rgba(255,255,255,0.05); border:1px solid rgba(255,255,255,0.08); color:#94a3b8; font-size:.72rem; }
    .panel, .side-card { padding:18px; }
    .section-title { display:flex; align-items:center; gap:8px; margin:0 0 14px; font-size:1rem; font-weight:800; }
    .cta {
      display:inline-flex; align-items:center; gap:8px; padding:10px 14px; border-radius:999px; text-decoration:none;
      background: rgba(59,130,246,0.16); color:#93c5fd; border:1px solid rgba(96,165,250,0.24); font-size:.84rem; font-weight:700;
    }
    .related { display:grid; gap:12px; }
    .related a { text-decoration:none; color:inherit; }
    .related-card {
      padding:14px 16px; border-radius:16px; background:rgba(255,255,255,0.04); border:1px solid rgba(255,255,255,0.08);
      transition: all .18s ease;
    }
    .related-card:hover { border-color: rgba(96,165,250,0.32); transform: translateY(-2px); }
    .related-card__title { color:#f8fafc; font-size:.94rem; font-weight:700; margin-bottom:6px; }
    .related-card__sub { color:#94a3b8; font-size:.82rem; line-height:1.6; }
    @media (max-width: 960px) { .layout { grid-template-columns: 1fr; } }
    @media (max-width: 640px) { .page { padding-left:16px; padding-right:16px; } }
  </style>
</head>
<body>
<%@ include file="/AI/partials/header.jsp" %>
<div class="page">
  <section class="hero">
    <div style="display:flex;gap:10px;flex-wrap:wrap;align-items:center;">
      <span class="badge-type"><%= escapeHtml(newsTypeLabel(article.getNewsType())) %></span>
      <% if (tool != null) { %>
        <a href="/AI/user/tools/detail.jsp?id=<%= tool.getId() %>" class="cta"><i class="bi bi-box-arrow-up-right"></i><%= escapeHtml(tool.getToolName()) %></a>
      <% } %>
    </div>
    <h1><%= escapeHtml(article.getTitle()) %></h1>
    <p><%= escapeHtml(article.getSummary()) %></p>
    <div class="meta">
      <span><i class="bi bi-building"></i> <%= escapeHtml(safeString(article.getSourceName(), "AI Workflow Lab")) %></span>
      <span><i class="bi bi-calendar3"></i> <%= article.getPublishedAt() != null ? article.getPublishedAt().toLocalDateTime().toLocalDate().toString() : "-" %></span>
      <span><i class="bi bi-eye"></i> <%= article.getViewCount() %></span>
    </div>
  </section>

  <div class="layout">
    <article class="article-body">
      <h2>브리핑</h2>
      <p><%= escapeHtml(article.getSummary()) %></p>
      <% if (article.getContent() != null && !article.getContent().trim().isEmpty()) { %>
        <p><%= escapeHtml(article.getContent()) %></p>
      <% } else { %>
        <p>현재는 요약형 뉴스 데이터를 사용하고 있습니다. 다음 단계에서는 원문 본문과 소스 링크, 도구별 changelog를 함께 연결할 수 있습니다.</p>
      <% } %>

      <% if (tool != null) { %>
        <h2>연결된 도구</h2>
        <p><strong><%= escapeHtml(tool.getToolName()) %></strong>는 <%= escapeHtml(safeString(tool.getProviderName(), "")) %>가 제공하며, 현재 글로벌 랭크 <%= escapeHtml(tool.getRankDisplay()) %>, 트렌드 <%= escapeHtml(tool.getTrendDisplay()) %>, 성장률 <%= escapeHtml(tool.getGrowthDisplay()) %>로 집계돼 있습니다.</p>
        <a href="/AI/user/tools/detail.jsp?id=<%= tool.getId() %>" class="cta"><i class="bi bi-arrow-right"></i>도구 상세 보기</a>
      <% } %>

      <% if (article.getTags() != null && !article.getTags().isEmpty()) { %>
        <div class="tag-row">
          <% for (String tag : article.getTags()) { %>
            <span class="tag"><%= escapeHtml(tag) %></span>
          <% } %>
        </div>
      <% } %>
    </article>

    <aside style="display:grid;gap:18px;">
      <div class="panel">
        <h2 class="section-title"><i class="bi bi-newspaper"></i>관련 뉴스</h2>
        <div class="related">
          <% for (AIToolNews item : relatedNews) { %>
            <a href="/AI/user/news/detail.jsp?id=<%= item.getId() %>">
              <div class="related-card">
                <div class="related-card__title"><%= escapeHtml(item.getTitle()) %></div>
                <div class="related-card__sub"><%= escapeHtml(item.getSummary()) %></div>
              </div>
            </a>
          <% } %>
        </div>
      </div>

      <div class="side-card">
        <h2 class="section-title"><i class="bi bi-compass"></i>이동</h2>
        <div class="related">
          <a href="/AI/user/news/index.jsp">
            <div class="related-card">
              <div class="related-card__title">뉴스 목록</div>
              <div class="related-card__sub">전체 AI 뉴스와 업데이트 브리핑 보기</div>
            </div>
          </a>
          <a href="/AI/user/tools/rankings.jsp">
            <div class="related-card">
              <div class="related-card__title">랭킹 보드</div>
              <div class="related-card__sub">트렌드와 시장 지표 기준 도구 비교</div>
            </div>
          </a>
        </div>
      </div>
    </aside>
  </div>
</div>
<%@ include file="/AI/partials/footer.jsp" %>
</body>
</html>
