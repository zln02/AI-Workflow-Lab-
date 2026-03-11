<%--
  AI Workflow Lab — 홈페이지 리디자인 (Hancom Docs AI Style)
--%>
<%@ page contentType="text/html; charset=UTF-8" buffer="128kb" autoFlush="true" %>
<%@ page isELIgnored="true" %>
<%@ page import="dao.AIToolDAO" %>
<%@ page import="dao.AIToolNewsDAO" %>
<%@ page import="dao.LabProjectDAO" %>
<%@ page import="dao.PlanDAO" %>
<%@ page import="model.AITool" %>
<%@ page import="model.AIToolNews" %>
<%@ page import="model.LabProject" %>
<%@ page import="model.Plan" %>
<%@ page import="model.User" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="db.DBConnect" %>
<%@ include file="/AI/user/_common.jsp" %>
<%
  User user = (User) session.getAttribute("user");
  boolean loggedIn = user != null && user.isActive();
  AIToolDAO homeToolDao = new AIToolDAO();
  AIToolNewsDAO homeNewsDao = new AIToolNewsDAO();
  LabProjectDAO homeLabDao = new LabProjectDAO();
  PlanDAO homePlanDao = new PlanDAO();
  List<AITool> trendingTools = java.util.Collections.emptyList();
  List<AITool> rankedTools = java.util.Collections.emptyList();
  List<AIToolNews> latestNews = java.util.Collections.emptyList();
  List<LabProject> popularLabs = java.util.Collections.emptyList();
  List<Plan> featuredPlans = java.util.Collections.emptyList();
  List<String[]> countrySnapshots = new ArrayList<>();

  int toolCount = 0, userCount = 0, labCount = 0;
  try (Connection _c = DBConnect.getConnection()) {
    try (PreparedStatement ps = _c.prepareStatement("SELECT COUNT(*) FROM ai_tools");
         ResultSet rs = ps.executeQuery()) { if (rs.next()) toolCount = rs.getInt(1); }
    try (PreparedStatement ps = _c.prepareStatement("SELECT COUNT(*) FROM users WHERE is_active=1");
         ResultSet rs = ps.executeQuery()) { if (rs.next()) userCount = rs.getInt(1); }
    try (PreparedStatement ps = _c.prepareStatement("SELECT COUNT(*) FROM lab_projects WHERE is_active=1");
         ResultSet rs = ps.executeQuery()) { if (rs.next()) labCount = rs.getInt(1); }
    try (PreparedStatement ps = _c.prepareStatement(
        "SELECT provider_country, COUNT(*) AS cnt, COALESCE(AVG(trend_score), 0) AS avg_trend " +
        "FROM ai_tools WHERE provider_country IS NOT NULL AND provider_country <> '' " +
        "GROUP BY provider_country ORDER BY cnt DESC, avg_trend DESC LIMIT 6");
         ResultSet rs = ps.executeQuery()) {
      while (rs.next()) {
        countrySnapshots.add(new String[]{
          rs.getString("provider_country"),
          String.valueOf(rs.getInt("cnt")),
          String.format(java.util.Locale.US, "%.1f", rs.getDouble("avg_trend"))
        });
      }
    }
  } catch (Exception _e) { /* 기본값 유지 */ }
  try {
    trendingTools = homeToolDao.findFiltered(null, null, null, null, false, false, "trend", 6, 0);
    rankedTools = homeToolDao.findFiltered(null, null, null, null, false, false, "rank", 5, 0);
    latestNews = homeNewsDao.findLatest(4);
    popularLabs = homeLabDao.findPopular(6);
    featuredPlans = homePlanDao.findAllActive();
    if (featuredPlans.size() > 3) featuredPlans = featuredPlans.subList(0, 3);
  } catch (Exception _e) { /* 기본값 유지 */ }
%>
<%!
  private String countryName(String code) {
    if (code == null || code.isEmpty()) return "-";
    switch (code) {
      case "US": return "미국";
      case "KR": return "대한민국";
      case "CN": return "중국";
      case "JP": return "일본";
      case "FR": return "프랑스";
      case "DE": return "독일";
      case "CA": return "캐나다";
      case "IN": return "인도";
      case "GB": return "영국";
      default: return code;
    }
  }

  private String countryFlag(String code) {
    if (code == null || code.length() != 2) return "🌐";
    int first = Character.codePointAt(code.toUpperCase(), 0) - 'A' + 0x1F1E6;
    int second = Character.codePointAt(code.toUpperCase(), 1) - 'A' + 0x1F1E6;
    return new String(Character.toChars(first)) + new String(Character.toChars(second));
  }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>AI Workflow Lab — AI의 모든 것, 한곳에서</title>
  <meta name="description" content="수백 개의 AI 모델을 한눈에 비교하고, 실습 프로젝트로 실력을 키우세요.">
  <meta name="robots" content="index,follow,max-image-preview:large">
  <meta property="og:type" content="website">
  <meta property="og:title" content="AI Workflow Lab — AI의 모든 것, 한곳에서">
  <meta property="og:description" content="AI 도구 탐색, 순위 비교, 실습 랩, 구독 결제까지 한 번에 제공하는 통합 플랫폼입니다.">
  <meta property="og:url" content="<%= request.getRequestURL().toString() %>">
  <meta property="og:site_name" content="AI Workflow Lab">
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="AI Workflow Lab — AI의 모든 것, 한곳에서">
  <meta name="twitter:description" content="수백 개의 AI 도구를 탐색하고 실습 랩으로 바로 검증하세요.">
  <link rel="canonical" href="<%= request.getRequestURL().toString() %>">
  <link rel="icon" href="data:,">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link rel="dns-prefetch" href="//cdn.jsdelivr.net">
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
  <link rel="stylesheet" href="/AI/assets/css/dark-theme.css">
  <link rel="stylesheet" href="/AI/assets/css/home.css">
  <style>
    .home-addon-grid { display:grid; gap:28px; margin-top:34px; }
    .lab-showcase-grid, .ecosystem-grid, .pricing-mini-grid { display:grid; grid-template-columns:repeat(3,minmax(0,1fr)); gap:18px; }
    .lab-card, .ecosystem-card, .pricing-mini-card {
      background:rgba(255,255,255,.05);
      border:1px solid rgba(255,255,255,.09);
      border-radius:22px;
      padding:22px;
      color:#e2e8f0;
      text-decoration:none;
      transition:transform .2s ease, border-color .2s ease, box-shadow .2s ease;
    }
    .lab-card:hover, .ecosystem-card:hover, .pricing-mini-card:hover {
      transform:translateY(-4px);
      border-color:rgba(59,130,246,.35);
      box-shadow:0 18px 40px rgba(2,6,23,.28);
    }
    .lab-card__meta, .ecosystem-card__meta, .pricing-mini-card__meta {
      color:#94a3b8;
      font-size:.8rem;
      margin-bottom:10px;
      display:flex;
      gap:10px;
      flex-wrap:wrap;
    }
    .lab-card__title, .ecosystem-card__title, .pricing-mini-card__title {
      font-size:1.12rem;
      font-weight:700;
      color:#f8fafc;
      margin-bottom:8px;
    }
    .lab-card__desc, .pricing-mini-card__desc {
      color:#cbd5e1;
      font-size:.92rem;
      line-height:1.6;
      margin:0;
    }
    .ecosystem-card__metric {
      margin-top:14px;
      display:flex;
      justify-content:space-between;
      align-items:center;
      padding-top:14px;
      border-top:1px solid rgba(255,255,255,.08);
      color:#e2e8f0;
      font-size:.9rem;
    }
    .pricing-mini-card__price {
      font-size:1.65rem;
      font-weight:800;
      color:#f8fafc;
      margin:10px 0 14px;
    }
    .pricing-mini-card__list {
      list-style:none;
      margin:0 0 18px;
      padding:0;
      display:grid;
      gap:8px;
      color:#cbd5e1;
      font-size:.9rem;
    }
    .pricing-mini-card__list li::before { content:"• "; color:#60a5fa; }
    .pricing-mini-card--popular {
      background:linear-gradient(180deg, rgba(59,130,246,.18), rgba(255,255,255,.05));
      border-color:rgba(96,165,250,.42);
    }
    @media (max-width: 1080px) {
      .lab-showcase-grid, .ecosystem-grid, .pricing-mini-grid { grid-template-columns:1fr; }
    }
  </style>
</head>
<body>

<%@ include file="/AI/partials/header.jsp" %>

<!-- ============================================================
     SECTION 1 — HERO
     ============================================================ -->
<section class="hero-section">

  <!-- Video background -->
  <div class="hero-video-wrap">
    <video autoplay muted loop playsinline preload="auto">
      <source src="/AI/assets/video/main.mp4" type="video/mp4">
    </video>
  </div>

  <!-- Orbs -->
  <div class="hero-orbs">
    <div class="hero-orb hero-orb-1"></div>
    <div class="hero-orb hero-orb-2"></div>
    <div class="hero-orb hero-orb-3"></div>
  </div>

  <!-- Grid overlay -->
  <div class="hero-grid"></div>

  <!-- Content -->
  <div class="hero-content">
    <div class="hero-badge">
      <span class="dot"></span>
      AI 모델 마켓플레이스 플랫폼
    </div>

    <h1 class="hero-title">
      <span class="line">AI의 모든 것,</span>
      <span class="line highlight">한곳에서 탐색하세요</span>
    </h1>

    <p class="hero-sub">
      수백 개의 AI 도구를 한눈에 비교하고,<br>
      실습 프로젝트로 실무 역량을 키우는 통합 플랫폼입니다.
    </p>

    <div class="hero-cta">
      <a href="/AI/user/tools/navigator.jsp" class="btn-hero-primary">
        <i class="bi bi-compass-fill"></i>
        AI 도구 탐색하기
      </a>
      <a href="/AI/user/tools/compare.jsp" class="btn-hero-outline">
        <i class="bi bi-layout-split"></i>
        도구 비교하기
      </a>
      <% if (!loggedIn) { %>
      <a href="/AI/user/signup.jsp" class="btn-hero-outline">
        <i class="bi bi-person-plus"></i>
        무료로 시작하기
      </a>
      <% } else { %>
      <a href="/AI/user/lab/index.jsp" class="btn-hero-outline">
        <i class="bi bi-flask"></i>
        실습 랩 입장
      </a>
      <% } %>
    </div>

    <!-- Stats -->
    <div class="hero-stats">
      <div class="hero-stat">
        <span class="num" data-target="<%= toolCount %>" data-suffix="+"><%= toolCount %>+</span>
        <span class="lbl">AI 도구</span>
      </div>
      <div class="hero-stat">
        <span class="num" data-target="<%= userCount %>" data-suffix="+"><%= userCount %>+</span>
        <span class="lbl">활성 사용자</span>
      </div>
      <div class="hero-stat">
        <span class="num" data-target="<%= labCount %>" data-suffix="+"><%= labCount %>+</span>
        <span class="lbl">실습 프로젝트</span>
      </div>
      <div class="hero-stat">
        <span class="num" data-target="5" data-suffix="개">5개</span>
        <span class="lbl">AI 모달리티</span>
      </div>
    </div>
  </div>

  <!-- Scroll indicator -->
  <div class="scroll-indicator">
    <div class="scroll-arrow">
      <i class="bi bi-chevron-down" style="font-size:.875rem;"></i>
    </div>
    <span>SCROLL</span>
  </div>

</section>


<!-- ============================================================
     SECTION 2 — PROBLEM
     ============================================================ -->
<section class="hl-section problem-section">
  <div class="section-inner">
    <div class="problem-lines">
      <p class="problem-line">수천 개의 AI 도구 중</p>
      <p class="problem-line"><span class="accent">어떤 것을 선택</span>해야 할지 모르겠다면,</p>
      <p class="problem-line">비교가 <span class="accent2">너무 복잡하고</span> 시간이 걸린다면,</p>
      <p class="problem-line">실습할 곳이 <span class="accent2">마땅히 없다면—</span></p>
      <p class="problem-line"><span class="accent3">AI Workflow Lab이 해결합니다.</span></p>
    </div>
  </div>
</section>


<!-- ============================================================
     SECTION 3 — FEATURES
     ============================================================ -->
<section class="hl-section features-section">
  <div class="section-inner">
    <div class="fade-up" style="text-align:center;">
      <span class="section-label"><i class="bi bi-stars"></i>핵심 기능</span>
      <h2 class="section-heading">
        AI 탐색부터 결제까지,<br>
        <span class="grad-text">하나의 플랫폼</span>에서
      </h2>
      <p class="section-sub" style="margin: 0 auto;">
        AI 도구 발견, 비교, 구독, 실습까지 — 필요한 모든 것이 여기 있습니다.
      </p>
    </div>

    <div class="features-grid">

      <div class="feature-card">
        <div class="feature-icon feature-icon-1">
          <i class="bi bi-compass-fill"></i>
        </div>
        <div class="feature-title">AI 도구 탐색기</div>
        <div class="feature-desc">
          Text, Image, Code, Voice 등 다양한 카테고리의 AI 도구를 탐색하고 상세 정보를 한눈에 비교하세요.
        </div>
        <a href="/AI/user/tools/navigator.jsp" class="feature-link">
          탐색하러 가기 <i class="bi bi-arrow-right"></i>
        </a>
      </div>

      <div class="feature-card">
        <div class="feature-icon feature-icon-2">
          <i class="bi bi-flask-fill"></i>
        </div>
        <div class="feature-title">실습 랩</div>
        <div class="feature-desc">
          Beginner부터 Advanced까지 단계별 실습 프로젝트로 AI 실무 역량을 키우고 포트폴리오를 완성하세요.
        </div>
        <a href="/AI/user/lab/index.jsp" class="feature-link">
          실습 시작하기 <i class="bi bi-arrow-right"></i>
        </a>
      </div>

      <div class="feature-card">
        <div class="feature-icon feature-icon-3">
          <i class="bi bi-credit-card-fill"></i>
        </div>
        <div class="feature-title">구독 플랜</div>
        <div class="feature-desc">
          Starter, Growth, Enterprise 플랜으로 필요한 만큼만 구독하세요. 신용카드, 카카오페이, 네이버페이 지원.
        </div>
        <a href="/AI/user/pricing.jsp" class="feature-link">
          요금제 보기 <i class="bi bi-arrow-right"></i>
        </a>
      </div>

      <div class="feature-card">
        <div class="feature-icon feature-icon-4">
          <i class="bi bi-person-circle"></i>
        </div>
        <div class="feature-title">마이페이지</div>
        <div class="feature-desc">
          구독 현황, 주문 내역, 프로필 설정을 한곳에서 관리하세요. 북마크한 AI 도구도 쉽게 확인할 수 있습니다.
        </div>
        <a href="<%= loggedIn ? "/AI/user/mypage.jsp" : "/AI/user/login.jsp" %>" class="feature-link">
          <%= loggedIn ? "마이페이지 열기" : "로그인하기" %> <i class="bi bi-arrow-right"></i>
        </a>
      </div>

    </div>
  </div>
</section>


<!-- ============================================================
     SECTION 4A — POPULAR LABS
     ============================================================ -->
<section class="hl-section">
  <div class="section-inner">
    <div class="fade-up" style="text-align:center;">
      <span class="section-label"><i class="bi bi-bezier2"></i>실전 실습</span>
      <h2 class="section-heading">
        바로 실행해보는<br>
        <span class="grad-text">인기 실습 랩</span>
      </h2>
      <p class="section-sub" style="margin:0 auto;">
        참여자 수가 높은 프로젝트 중심으로 초급부터 고급까지 바로 시작할 수 있습니다.
      </p>
    </div>

    <div class="home-addon-grid">
      <div class="lab-showcase-grid">
        <% if (popularLabs.isEmpty()) { %>
        <div class="lab-card">
          <div class="lab-card__title">인기 실습 준비 중</div>
          <p class="lab-card__desc">실습 프로젝트 데이터가 준비되면 이 영역에 추천 랩이 표시됩니다.</p>
        </div>
        <% } else { for (LabProject lab : popularLabs) { %>
        <a href="/AI/user/lab/detail.jsp?id=<%= lab.getId() %>" class="lab-card">
          <div class="lab-card__meta">
            <span><%= escapeHtml(safeString(lab.getCategory(), "Lab")) %></span>
            <span><%= escapeHtml(safeString(lab.getDifficultyLevel(), "Beginner")) %></span>
            <span><%= lab.getCurrentParticipants() != null ? lab.getCurrentParticipants() : 0 %>명 참여</span>
          </div>
          <div class="lab-card__title"><%= escapeHtml(lab.getTitle()) %></div>
          <p class="lab-card__desc"><%= escapeHtml(safeString(lab.getDescription(), "실전형 AI 워크플로우 실습")) %></p>
        </a>
        <% }} %>
      </div>
    </div>
  </div>
</section>

<!-- ============================================================
     SECTION 4 — LIVE DATA
     ============================================================ -->
<section class="hl-section live-section">
  <div class="section-inner">
    <div class="fade-up" style="text-align:center;">
      <span class="section-label"><i class="bi bi-broadcast"></i>실시간 카탈로그</span>
      <h2 class="section-heading">
        홈에서 바로 보는<br>
        <span class="grad-text">트렌드와 뉴스</span>
      </h2>
      <p class="section-sub" style="margin: 0 auto;">
        새로 추가한 랭킹, 비교, 뉴스 레이어를 홈페이지에서 바로 이어지게 구성했습니다.
      </p>
    </div>

    <div class="live-grid">
      <div class="live-panel">
        <div class="live-panel__head">
          <div>
            <span class="live-panel__eyebrow">Trend</span>
            <h3 class="live-panel__title">트렌드 도구</h3>
          </div>
          <a href="/AI/user/tools/rankings.jsp?sort=trend" class="live-link">전체 보기</a>
        </div>
        <div class="live-list">
          <% for (AITool tool : trendingTools) { %>
          <a href="/AI/user/tools/detail.jsp?id=<%= tool.getId() %>" class="live-item">
            <div class="live-item__main">
              <div class="live-item__title"><%= escapeHtml(tool.getToolName()) %></div>
              <div class="live-item__sub"><%= escapeHtml(safeString(tool.getProviderName(), "")) %> · Growth <%= escapeHtml(tool.getGrowthDisplay()) %></div>
            </div>
            <div class="live-item__metric">
              <span>Trend</span>
              <strong><%= escapeHtml(tool.getTrendDisplay()) %></strong>
            </div>
          </a>
          <% } %>
        </div>
      </div>

      <div class="live-panel">
        <div class="live-panel__head">
          <div>
            <span class="live-panel__eyebrow">Rank</span>
            <h3 class="live-panel__title">랭킹 스냅샷</h3>
          </div>
          <a href="/AI/user/tools/rankings.jsp" class="live-link">전체 보기</a>
        </div>
        <div class="rank-snapshot">
          <% for (AITool tool : rankedTools) { %>
          <a href="/AI/user/tools/detail.jsp?id=<%= tool.getId() %>" class="rank-snapshot__card">
            <div class="rank-snapshot__badge"><%= escapeHtml(tool.getRankDisplay()) %></div>
            <div class="rank-snapshot__body">
              <div class="rank-snapshot__title"><%= escapeHtml(tool.getToolName()) %></div>
              <div class="rank-snapshot__sub"><%= escapeHtml(safeString(tool.getCategory(), "-")) %> · <%= escapeHtml(tool.getFormattedMonthlyVisits()) %>/월</div>
            </div>
          </a>
          <% } %>
        </div>
      </div>
    </div>

    <div class="news-strip">
      <div class="live-panel__head" style="margin-bottom:16px;">
        <div>
          <span class="live-panel__eyebrow">News</span>
          <h3 class="live-panel__title">최신 뉴스</h3>
        </div>
        <a href="/AI/user/news/index.jsp" class="live-link">뉴스룸</a>
      </div>
      <div class="news-strip__grid">
        <% for (AIToolNews item : latestNews) { %>
        <a href="/AI/user/news/detail.jsp?id=<%= item.getId() %>" class="news-strip__card">
          <span class="news-strip__badge"><%= escapeHtml(safeString(item.getNewsType(), "update")) %></span>
          <div class="news-strip__title"><%= escapeHtml(item.getTitle()) %></div>
          <div class="news-strip__summary"><%= escapeHtml(item.getSummary()) %></div>
        </a>
        <% } %>
      </div>
    </div>
  </div>
</section>


<!-- ============================================================
     SECTION 4B — ECOSYSTEM
     ============================================================ -->
<section class="hl-section">
  <div class="section-inner">
    <div class="fade-up" style="text-align:center;">
      <span class="section-label"><i class="bi bi-globe-central-south-asia"></i>국가별 AI 생태계</span>
      <h2 class="section-heading">
        지금 뜨는 국가와<br>
        <span class="grad-text">도구 밀집도</span>
      </h2>
      <p class="section-sub" style="margin:0 auto;">
        도구 수와 평균 트렌드 점수 기준으로 국가별 AI 생태계를 빠르게 스캔할 수 있습니다.
      </p>
    </div>

    <div class="home-addon-grid">
      <div class="ecosystem-grid">
        <% if (countrySnapshots.isEmpty()) { %>
        <div class="ecosystem-card">
          <div class="ecosystem-card__title">국가 통계 준비 중</div>
          <div class="ecosystem-card__metric"><span>데이터 적재 후 표시됩니다.</span><span>🌐</span></div>
        </div>
        <% } else { for (String[] country : countrySnapshots) { %>
        <a href="/AI/user/tools/rankings.jsp?country=<%= escapeHtmlAttribute(country[0]) %>" class="ecosystem-card">
          <div class="ecosystem-card__meta"><span><%= countryFlag(country[0]) %></span><span><%= escapeHtml(country[0]) %></span></div>
          <div class="ecosystem-card__title"><%= escapeHtml(countryName(country[0])) %></div>
          <div class="ecosystem-card__metric">
            <span>등록 도구 <strong><%= escapeHtml(country[1]) %></strong></span>
            <span>Trend <strong><%= escapeHtml(country[2]) %></strong></span>
          </div>
        </a>
        <% }} %>
      </div>
    </div>
  </div>
</section>

<!-- ============================================================
     SECTION 4C — PRICING
     ============================================================ -->
<section class="hl-section">
  <div class="section-inner">
    <div class="fade-up" style="text-align:center;">
      <span class="section-label"><i class="bi bi-wallet2"></i>플랜 미리보기</span>
      <h2 class="section-heading">
        탐색부터 실습까지 맞는<br>
        <span class="grad-text">요금제를 선택하세요</span>
      </h2>
      <p class="section-sub" style="margin:0 auto;">
        인기 플랜만 추려서 한 번에 비교하고, 결제로 바로 이어질 수 있게 연결했습니다.
      </p>
    </div>

    <div class="home-addon-grid">
      <div class="pricing-mini-grid">
        <% if (featuredPlans.isEmpty()) { %>
        <div class="pricing-mini-card">
          <div class="pricing-mini-card__title">플랜 정보 준비 중</div>
          <p class="pricing-mini-card__desc">요금제 데이터가 없으면 기본 가격 페이지로 바로 이동해 확인할 수 있습니다.</p>
        </div>
        <% } else { for (Plan plan : featuredPlans) { %>
        <a href="/AI/user/pricing.jsp" class="pricing-mini-card <%= plan.isPopular() ? "pricing-mini-card--popular" : "" %>">
          <div class="pricing-mini-card__meta">
            <span><%= escapeHtml(safeString(plan.getNameKo(), plan.getName())) %></span>
            <span><%= escapeHtml(safeString(plan.getBillingCycle(), "monthly")) %></span>
          </div>
          <div class="pricing-mini-card__title"><%= escapeHtml(safeString(plan.getName(), "Plan")) %></div>
          <div class="pricing-mini-card__price">₩<%= plan.getPriceUsd() != null ? String.format(java.util.Locale.US, "%,.0f", plan.getPriceUsd()) : "0" %></div>
          <ul class="pricing-mini-card__list">
            <li>월 크레딧 <%= plan.getCreditsMonthly() %></li>
            <li>일 API 호출 <%= plan.getMaxApiCallsDaily() != null ? plan.getMaxApiCallsDaily() : "-" %></li>
            <li>프로젝트 수 <%= plan.getMaxProjects() != null ? plan.getMaxProjects() : "-" %></li>
          </ul>
          <p class="pricing-mini-card__desc">도구 탐색, Playground, 실습 랩, 결제 흐름까지 한 번에 연결됩니다.</p>
        </a>
        <% }} %>
      </div>
    </div>
  </div>
</section>

<!-- ============================================================
     SECTION 5 — MODALITIES
     ============================================================ -->
<section class="hl-section modality-section">
  <div class="section-inner">
    <div class="fade-up" style="text-align:center;">
      <span class="section-label"><i class="bi bi-grid-3x3-gap"></i>지원 모달리티</span>
      <h2 class="section-heading">
        모든 형태의 AI,<br>
        <span class="grad-text">한곳에서 찾으세요</span>
      </h2>
      <p class="section-sub" style="margin: 0 auto;">
        텍스트, 이미지, 음성, 코드, 영상까지 — 5가지 AI 모달리티를 모두 지원합니다.
      </p>
    </div>

    <div class="modality-grid">

      <div class="modality-card">
        <i class="bi bi-chat-dots-fill modality-icon"></i>
        <div class="modality-name">텍스트 생성</div>
        <div class="modality-desc">GPT-4, Claude, Gemini 등 언어 모델</div>
      </div>

      <div class="modality-card">
        <i class="bi bi-image-fill modality-icon"></i>
        <div class="modality-name">이미지 생성</div>
        <div class="modality-desc">DALL-E, Midjourney, Stable Diffusion</div>
      </div>

      <div class="modality-card">
        <i class="bi bi-code-slash modality-icon"></i>
        <div class="modality-name">코드 생성</div>
        <div class="modality-desc">GitHub Copilot, CodeLlama, Codex</div>
      </div>

      <div class="modality-card">
        <i class="bi bi-soundwave modality-icon"></i>
        <div class="modality-name">음성 처리</div>
        <div class="modality-desc">Whisper, ElevenLabs, Bark</div>
      </div>

      <div class="modality-card">
        <i class="bi bi-camera-video-fill modality-icon"></i>
        <div class="modality-name">영상 생성</div>
        <div class="modality-desc">Sora, Runway, Pika Labs</div>
      </div>

    </div>
  </div>
</section>


<!-- ============================================================
     SECTION 5 — CTA
     ============================================================ -->
<section class="hl-section cta-section">
  <div class="section-inner">
    <div class="cta-inner">
      <h2 class="cta-title">
        지금 바로<br>
        <span class="grad-text">AI의 세계로 입장하세요</span>
      </h2>
      <p class="cta-sub">
        무료로 시작하고, 언제든 업그레이드하세요.<br>
        신용카드 없이 바로 탐색을 시작할 수 있습니다.
      </p>
      <div class="cta-buttons">
        <% if (!loggedIn) { %>
        <a href="/AI/user/signup.jsp" class="btn-hero-primary" style="font-size:.9375rem;padding:13px 28px;">
          <i class="bi bi-person-plus-fill"></i>
          무료로 시작하기
        </a>
        <a href="/AI/user/pricing.jsp" class="btn-hero-outline" style="font-size:.9375rem;padding:13px 28px;">
          <i class="bi bi-tag"></i>
          요금제 보기
        </a>
        <% } else { %>
        <a href="/AI/user/tools/navigator.jsp" class="btn-hero-primary" style="font-size:.9375rem;padding:13px 28px;">
          <i class="bi bi-compass-fill"></i>
          AI 도구 탐색하기
        </a>
        <a href="/AI/user/lab/index.jsp" class="btn-hero-outline" style="font-size:.9375rem;padding:13px 28px;">
          <i class="bi bi-flask"></i>
          실습 랩 입장
        </a>
        <% } %>
      </div>
    </div>
  </div>
</section>


<!-- ============================================================
     FOOTER
     ============================================================ -->
<footer class="home-footer">
  <div class="home-footer__inner">
    <a href="/AI/user/home.jsp" class="home-footer__brand">
      <i class="bi bi-hexagon-fill" style="background:linear-gradient(135deg,#3b82f6,#8b5cf6);-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;"></i> AI Workflow Lab
    </a>
    <div class="home-footer__links">
      <a href="/AI/user/tools/navigator.jsp">AI 도구</a>
      <a href="/AI/user/lab/index.jsp">실습 랩</a>
      <a href="/AI/user/pricing.jsp">요금제</a>
      <a href="/AI/user/mypage.jsp">마이페이지</a>
    </div>
    <p class="home-footer__copy">&copy; 2026 AI Workflow Lab. All rights reserved.</p>
  </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="/AI/assets/js/home.js"></script>
</body>
</html>
