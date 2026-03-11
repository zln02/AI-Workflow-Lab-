<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="db.DBConnect" %>
<%
  if (session.getAttribute("admin") == null) {
    response.sendRedirect("/AI/admin/auth/login.jsp");
    return;
  }

  int toolCount = 0;
  int newsCount = 0;
  int featuredNewsCount = 0;
  int enterpriseTools = 0;
  int openSourceTools = 0;
  int apiTools = 0;
  double avgTrend = 0.0;
  double avgGrowth = 0.0;
  String topCountry = "-";
  String topCategory = "-";
  long totalVisits = 0L;
  long totalMau = 0L;

  List<Map<String, String>> topTools = new ArrayList<>();
  List<Map<String, String>> countryStats = new ArrayList<>();
  List<Map<String, String>> newsStats = new ArrayList<>();

  try (Connection c = DBConnect.getConnection()) {
    try (PreparedStatement ps = c.prepareStatement(
        "SELECT COUNT(*), " +
        "COALESCE(SUM(CASE WHEN enterprise_ready = 1 THEN 1 ELSE 0 END),0), " +
        "COALESCE(SUM(CASE WHEN open_source = 1 THEN 1 ELSE 0 END),0), " +
        "COALESCE(SUM(CASE WHEN api_available = 1 THEN 1 ELSE 0 END),0), " +
        "COALESCE(AVG(trend_score),0), COALESCE(AVG(growth_rate),0), " +
        "COALESCE(SUM(monthly_visits),0), COALESCE(SUM(monthly_active_users),0) " +
        "FROM ai_tools");
         ResultSet rs = ps.executeQuery()) {
      if (rs.next()) {
        toolCount = rs.getInt(1);
        enterpriseTools = rs.getInt(2);
        openSourceTools = rs.getInt(3);
        apiTools = rs.getInt(4);
        avgTrend = rs.getDouble(5);
        avgGrowth = rs.getDouble(6);
        totalVisits = rs.getLong(7);
        totalMau = rs.getLong(8);
      }
    }

    try (PreparedStatement ps = c.prepareStatement(
        "SELECT COUNT(*), COALESCE(SUM(CASE WHEN is_featured = 1 THEN 1 ELSE 0 END),0) FROM ai_tool_news WHERE is_active = 1");
         ResultSet rs = ps.executeQuery()) {
      if (rs.next()) {
        newsCount = rs.getInt(1);
        featuredNewsCount = rs.getInt(2);
      }
    }

    try (PreparedStatement ps = c.prepareStatement(
        "SELECT provider_country, COUNT(*) AS cnt FROM ai_tools " +
        "WHERE provider_country IS NOT NULL AND provider_country <> '' " +
        "GROUP BY provider_country ORDER BY cnt DESC LIMIT 1");
         ResultSet rs = ps.executeQuery()) {
      if (rs.next()) topCountry = rs.getString("provider_country");
    }

    try (PreparedStatement ps = c.prepareStatement(
        "SELECT category, COUNT(*) AS cnt FROM ai_tools GROUP BY category ORDER BY cnt DESC LIMIT 1");
         ResultSet rs = ps.executeQuery()) {
      if (rs.next()) topCategory = rs.getString("category");
    }

    try (PreparedStatement ps = c.prepareStatement(
        "SELECT tool_name, provider_name, category, global_rank, trend_score, growth_rate, monthly_visits " +
        "FROM ai_tools ORDER BY COALESCE(trend_score,0) DESC, COALESCE(growth_rate,0) DESC LIMIT 8");
         ResultSet rs = ps.executeQuery()) {
      while (rs.next()) {
        Map<String, String> row = new HashMap<>();
        row.put("tool_name", rs.getString("tool_name"));
        row.put("provider_name", rs.getString("provider_name"));
        row.put("category", rs.getString("category"));
        row.put("global_rank", rs.getObject("global_rank") != null ? "#" + rs.getInt("global_rank") : "-");
        row.put("trend_score", String.format(Locale.US, "%.1f", rs.getDouble("trend_score")));
        row.put("growth_rate", String.format(Locale.US, "%+.1f%%", rs.getDouble("growth_rate")));
        row.put("monthly_visits", String.format(Locale.US, "%,d", rs.getLong("monthly_visits")));
        topTools.add(row);
      }
    }

    try (PreparedStatement ps = c.prepareStatement(
        "SELECT provider_country, COUNT(*) AS cnt, COALESCE(AVG(trend_score),0) AS avg_trend " +
        "FROM ai_tools WHERE provider_country IS NOT NULL AND provider_country <> '' " +
        "GROUP BY provider_country ORDER BY cnt DESC, avg_trend DESC LIMIT 8");
         ResultSet rs = ps.executeQuery()) {
      while (rs.next()) {
        Map<String, String> row = new HashMap<>();
        row.put("country", rs.getString("provider_country"));
        row.put("cnt", String.valueOf(rs.getInt("cnt")));
        row.put("avg_trend", String.format(Locale.US, "%.1f", rs.getDouble("avg_trend")));
        countryStats.add(row);
      }
    }

    try (PreparedStatement ps = c.prepareStatement(
        "SELECT news_type, COUNT(*) AS cnt, COALESCE(SUM(view_count),0) AS views " +
        "FROM ai_tool_news WHERE is_active = 1 GROUP BY news_type ORDER BY cnt DESC, views DESC");
         ResultSet rs = ps.executeQuery()) {
      while (rs.next()) {
        Map<String, String> row = new HashMap<>();
        row.put("news_type", rs.getString("news_type"));
        row.put("cnt", String.valueOf(rs.getInt("cnt")));
        row.put("views", String.format(Locale.US, "%,d", rs.getLong("views")));
        newsStats.add(row);
      }
    }
  } catch (Exception ignored) {
    /* keep defaults */
  }
%>
<%!
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
      case "IL": return "이스라엘";
      case "IN": return "인도";
      case "GB": return "영국";
      default: return code;
    }
  }

  private String newsTypeLabel(String type) {
    if (type == null || type.isEmpty()) return "-";
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

  private String compactNumber(long value) {
    if (value >= 1000000000L) return String.format(Locale.US, "%.1fB", value / 1000000000.0);
    if (value >= 1000000L) return String.format(Locale.US, "%.1fM", value / 1000000.0);
    if (value >= 1000L) return String.format(Locale.US, "%.1fK", value / 1000.0);
    return String.format(Locale.US, "%d", value);
  }
%>
<%@ include file="/AI/admin/layout/header.jspf" %>
<div class="admin-layout">
  <%@ include file="/AI/admin/layout/sidebar.jspf" %>
  <div class="admin-main-wrapper">
    <%@ include file="/AI/admin/layout/topbar.jspf" %>
    <main class="admin-content">

      <header class="admin-dashboard-header" style="margin-bottom:2rem;">
        <h1>통계 및 인사이트</h1>
        <p>Phase 1 카탈로그 확장 기준으로 도구, 뉴스, 국가별 분포와 성장 지표를 확인합니다.</p>
      </header>

      <section class="kpi-grid" style="margin-bottom:2rem;">
        <article class="kpi-card kpi-tools">
          <div class="kpi-icon"><i class="bi bi-cpu-fill"></i></div>
          <div class="kpi-body">
            <span class="kpi-label">전체 도구</span>
            <span class="kpi-value"><%= toolCount %></span>
            <span class="kpi-desc">등록된 AI 도구 수</span>
          </div>
        </article>
        <article class="kpi-card kpi-category">
          <div class="kpi-icon"><i class="bi bi-graph-up-arrow"></i></div>
          <div class="kpi-body">
            <span class="kpi-label">평균 트렌드</span>
            <span class="kpi-value"><%= String.format(Locale.US, "%.1f", avgTrend) %></span>
            <span class="kpi-desc">평균 trend score</span>
          </div>
        </article>
        <article class="kpi-card kpi-lab">
          <div class="kpi-icon"><i class="bi bi-arrow-up-right-circle-fill"></i></div>
          <div class="kpi-body">
            <span class="kpi-label">평균 성장률</span>
            <span class="kpi-value"><%= String.format(Locale.US, "%+.1f%%", avgGrowth) %></span>
            <span class="kpi-desc">평균 growth rate</span>
          </div>
        </article>
        <article class="kpi-card kpi-orders">
          <div class="kpi-icon"><i class="bi bi-newspaper"></i></div>
          <div class="kpi-body">
            <span class="kpi-label">활성 뉴스</span>
            <span class="kpi-value"><%= newsCount %></span>
            <span class="kpi-desc">피처드 <%= featuredNewsCount %>건</span>
          </div>
        </article>
        <article class="kpi-card kpi-revenue">
          <div class="kpi-icon"><i class="bi bi-globe2"></i></div>
          <div class="kpi-body">
            <span class="kpi-label">월간 방문 합계</span>
            <span class="kpi-value kpi-value-sm"><%= compactNumber(totalVisits) %></span>
            <span class="kpi-desc">누적 추정 방문량</span>
          </div>
        </article>
      </section>

      <section style="display:grid;grid-template-columns:1.2fr .8fr;gap:1.25rem;margin-bottom:2rem;">
        <article style="background:var(--glass-bg);backdrop-filter:blur(20px);border:1px solid var(--glass-border);border-radius:var(--radius-xl);padding:var(--spacing-xl);">
          <header style="display:flex;justify-content:space-between;align-items:flex-start;gap:1rem;margin-bottom:1rem;">
            <div>
              <h2 style="margin:0 0 .25rem;">카탈로그 개요</h2>
              <p style="margin:0;font-size:.85rem;color:var(--text-secondary);">확장된 필드 기준 핵심 비율</p>
            </div>
          </header>
          <div style="display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:1rem;">
            <div class="stat-box">
              <span class="stat-box__label">Enterprise Ready</span>
              <strong class="stat-box__value"><%= enterpriseTools %></strong>
            </div>
            <div class="stat-box">
              <span class="stat-box__label">Open Source</span>
              <strong class="stat-box__value"><%= openSourceTools %></strong>
            </div>
            <div class="stat-box">
              <span class="stat-box__label">API Available</span>
              <strong class="stat-box__value"><%= apiTools %></strong>
            </div>
            <div class="stat-box">
              <span class="stat-box__label">활성 사용자 합계</span>
              <strong class="stat-box__value"><%= compactNumber(totalMau) %></strong>
            </div>
            <div class="stat-box">
              <span class="stat-box__label">최다 국가</span>
              <strong class="stat-box__value"><%= countryLabel(topCountry) %></strong>
            </div>
            <div class="stat-box">
              <span class="stat-box__label">최다 카테고리</span>
              <strong class="stat-box__value"><%= topCategory %></strong>
            </div>
          </div>
        </article>

        <article style="background:var(--glass-bg);backdrop-filter:blur(20px);border:1px solid var(--glass-border);border-radius:var(--radius-xl);padding:var(--spacing-xl);">
          <header style="margin-bottom:1rem;">
            <h2 style="margin:0 0 .25rem;">빠른 이동</h2>
            <p style="margin:0;font-size:.85rem;color:var(--text-secondary);">운영자가 자주 보는 화면</p>
          </header>
          <div style="display:grid;gap:.75rem;">
            <a class="quick-link-card quick-primary" href="/AI/admin/tools/index.jsp"><i class="bi bi-cpu"></i><span>도구 관리</span></a>
            <a class="quick-link-card" href="/AI/admin/dashboard.jsp"><i class="bi bi-speedometer2"></i><span>대시보드</span></a>
            <a class="quick-link-card" href="/AI/admin/orders/index.jsp"><i class="bi bi-receipt"></i><span>주문 관리</span></a>
            <a class="quick-link-card" href="/AI/admin/users/index.jsp"><i class="bi bi-people"></i><span>사용자 관리</span></a>
          </div>
        </article>
      </section>

      <section style="display:grid;grid-template-columns:1.2fr .8fr;gap:1.25rem;margin-bottom:2rem;">
        <article style="background:var(--glass-bg);backdrop-filter:blur(20px);border:1px solid var(--glass-border);border-radius:var(--radius-xl);padding:var(--spacing-xl);">
          <header style="display:flex;justify-content:space-between;align-items:center;margin-bottom:1rem;">
            <div>
              <h2 style="margin:0;">상위 트렌드 도구</h2>
              <p style="margin:.25rem 0 0;font-size:.85rem;color:var(--text-secondary);">trend score + growth rate 기준 상위 8개</p>
            </div>
          </header>
          <div class="admin-table-section">
            <table class="admin-table">
              <thead>
                <tr><th>도구</th><th>카테고리</th><th>글로벌 랭크</th><th>트렌드</th><th>성장률</th><th>월 방문</th></tr>
              </thead>
              <tbody>
                <% for (Map<String, String> row : topTools) { %>
                <tr>
                  <td><strong><%= row.get("tool_name") %></strong><div style="font-size:.78rem;color:var(--text-secondary);margin-top:.25rem;"><%= row.get("provider_name") %></div></td>
                  <td><%= row.get("category") %></td>
                  <td><%= row.get("global_rank") %></td>
                  <td><%= row.get("trend_score") %></td>
                  <td><%= row.get("growth_rate") %></td>
                  <td><%= row.get("monthly_visits") %></td>
                </tr>
                <% } if (topTools.isEmpty()) { %>
                <tr><td colspan="6" style="text-align:center;color:var(--text-secondary);padding:2rem;">표시할 데이터가 없습니다.</td></tr>
                <% } %>
              </tbody>
            </table>
          </div>
        </article>

        <article style="display:grid;gap:1.25rem;">
          <div style="background:var(--glass-bg);backdrop-filter:blur(20px);border:1px solid var(--glass-border);border-radius:var(--radius-xl);padding:var(--spacing-xl);">
            <header style="margin-bottom:1rem;">
              <h2 style="margin:0;">국가별 분포</h2>
              <p style="margin:.25rem 0 0;font-size:.85rem;color:var(--text-secondary);">국가별 도구 수와 평균 트렌드</p>
            </header>
            <div style="display:grid;gap:.75rem;">
              <% for (Map<String, String> row : countryStats) { %>
              <div class="mini-stat-row">
                <div>
                  <strong><%= countryLabel(row.get("country")) %></strong>
                  <div style="font-size:.78rem;color:var(--text-secondary);"><%= row.get("country") %></div>
                </div>
                <div style="text-align:right;">
                  <strong><%= row.get("cnt") %>개</strong>
                  <div style="font-size:.78rem;color:var(--text-secondary);">Trend <%= row.get("avg_trend") %></div>
                </div>
              </div>
              <% } if (countryStats.isEmpty()) { %>
              <div style="color:var(--text-secondary);">표시할 데이터가 없습니다.</div>
              <% } %>
            </div>
          </div>

          <div style="background:var(--glass-bg);backdrop-filter:blur(20px);border:1px solid var(--glass-border);border-radius:var(--radius-xl);padding:var(--spacing-xl);">
            <header style="margin-bottom:1rem;">
              <h2 style="margin:0;">뉴스 타입 분포</h2>
              <p style="margin:.25rem 0 0;font-size:.85rem;color:var(--text-secondary);">타입별 기사 수와 조회 합계</p>
            </header>
            <div style="display:grid;gap:.75rem;">
              <% for (Map<String, String> row : newsStats) { %>
              <div class="mini-stat-row">
                <div>
                  <strong><%= newsTypeLabel(row.get("news_type")) %></strong>
                  <div style="font-size:.78rem;color:var(--text-secondary);"><%= row.get("news_type") %></div>
                </div>
                <div style="text-align:right;">
                  <strong><%= row.get("cnt") %>건</strong>
                  <div style="font-size:.78rem;color:var(--text-secondary);">Views <%= row.get("views") %></div>
                </div>
              </div>
              <% } if (newsStats.isEmpty()) { %>
              <div style="color:var(--text-secondary);">표시할 데이터가 없습니다.</div>
              <% } %>
            </div>
          </div>
        </article>
      </section>

      <style>
        .stat-box {
          padding: 1rem 1.1rem;
          border-radius: 16px;
          background: rgba(255,255,255,.04);
          border: 1px solid rgba(255,255,255,.08);
        }
        .stat-box__label {
          display:block;
          font-size:.76rem;
          color:var(--text-secondary);
          margin-bottom:.45rem;
          text-transform:uppercase;
          letter-spacing:.06em;
        }
        .stat-box__value {
          font-size:1.15rem;
          color:var(--text-primary);
        }
        .mini-stat-row {
          display:flex;
          align-items:center;
          justify-content:space-between;
          gap:1rem;
          padding:.9rem 1rem;
          border-radius:14px;
          background: rgba(255,255,255,.04);
          border: 1px solid rgba(255,255,255,.08);
        }
        @media (max-width: 1100px) {
          .admin-content section[style*="grid-template-columns:1.2fr .8fr"] { grid-template-columns: 1fr !important; }
        }
        @media (max-width: 720px) {
          .admin-content section[style*="grid-template-columns:repeat(2,minmax(0,1fr))"] { grid-template-columns: 1fr !important; }
          .mini-stat-row { flex-direction: column; align-items: flex-start; }
        }
      </style>

    </main>
  </div>
</div>
<%@ include file="/AI/admin/layout/scripts.jspf" %>
</body>
</html>
