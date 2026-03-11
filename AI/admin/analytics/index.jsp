<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.time.YearMonth" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.LinkedHashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%@ page import="db.DBConnect" %>
<%
  if (session.getAttribute("admin") == null) {
    response.sendRedirect("/AI/admin/auth/login.jsp");
    return;
  }

  List<String> monthLabels = new ArrayList<>();
  List<Integer> userSeries = new ArrayList<>();
  List<Integer> creditSeries = new ArrayList<>();
  List<Double> revenueSeries = new ArrayList<>();
  List<String> toolLabels = new ArrayList<>();
  List<Integer> toolVisitSeries = new ArrayList<>();

  LinkedHashMap<String, Integer> usersByMonth = new LinkedHashMap<>();
  LinkedHashMap<String, Integer> creditsByMonth = new LinkedHashMap<>();
  LinkedHashMap<String, Double> revenueByMonth = new LinkedHashMap<>();
  YearMonth now = YearMonth.now();
  DateTimeFormatter fmt = DateTimeFormatter.ofPattern("yyyy-MM");
  for (int i = 5; i >= 0; i--) {
    YearMonth month = now.minusMonths(i);
    String key = month.format(fmt);
    monthLabels.add(month.getMonthValue() + "월");
    usersByMonth.put(key, 0);
    creditsByMonth.put(key, 0);
    revenueByMonth.put(key, 0.0);
  }

  int activeUsers = 0;
  int activeSubs = 0;
  int totalCreditsUsed = 0;
  double totalRevenue = 0.0;

  try (Connection c = DBConnect.getConnection()) {
    try (PreparedStatement ps = c.prepareStatement("SELECT COUNT(*) FROM users WHERE is_active = 1");
         ResultSet rs = ps.executeQuery()) {
      if (rs.next()) activeUsers = rs.getInt(1);
    } catch (Exception ignored) {}

    try (PreparedStatement ps = c.prepareStatement("SELECT COUNT(*) FROM subscriptions WHERE status='ACTIVE'");
         ResultSet rs = ps.executeQuery()) {
      if (rs.next()) activeSubs = rs.getInt(1);
    } catch (Exception ignored) {}

    try (PreparedStatement ps = c.prepareStatement("SELECT COALESCE(SUM(credits_used),0) FROM credit_usage_logs");
         ResultSet rs = ps.executeQuery()) {
      if (rs.next()) totalCreditsUsed = rs.getInt(1);
    } catch (Exception ignored) {}

    try (PreparedStatement ps = c.prepareStatement("SELECT COALESCE(SUM(total_price),0) FROM orders WHERE order_status='COMPLETED'");
         ResultSet rs = ps.executeQuery()) {
      if (rs.next()) totalRevenue = rs.getDouble(1);
    } catch (Exception ignored) {}

    try (PreparedStatement ps = c.prepareStatement(
        "SELECT DATE_FORMAT(created_at, '%Y-%m') ym, COUNT(*) cnt FROM users " +
        "WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH) GROUP BY DATE_FORMAT(created_at, '%Y-%m') ORDER BY ym");
         ResultSet rs = ps.executeQuery()) {
      while (rs.next()) usersByMonth.put(rs.getString("ym"), rs.getInt("cnt"));
    } catch (Exception ignored) {}

    try (PreparedStatement ps = c.prepareStatement(
        "SELECT DATE_FORMAT(created_at, '%Y-%m') ym, COALESCE(SUM(credits_used),0) cnt FROM credit_usage_logs " +
        "WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH) GROUP BY DATE_FORMAT(created_at, '%Y-%m') ORDER BY ym");
         ResultSet rs = ps.executeQuery()) {
      while (rs.next()) creditsByMonth.put(rs.getString("ym"), rs.getInt("cnt"));
    } catch (Exception ignored) {}

    try (PreparedStatement ps = c.prepareStatement(
        "SELECT DATE_FORMAT(created_at, '%Y-%m') ym, COALESCE(SUM(total_price),0) total FROM orders " +
        "WHERE order_status='COMPLETED' AND created_at >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH) " +
        "GROUP BY DATE_FORMAT(created_at, '%Y-%m') ORDER BY ym");
         ResultSet rs = ps.executeQuery()) {
      while (rs.next()) revenueByMonth.put(rs.getString("ym"), rs.getDouble("total"));
    } catch (Exception ignored) {}

    try (PreparedStatement ps = c.prepareStatement(
        "SELECT tool_name, COALESCE(monthly_visits,0) AS monthly_visits FROM ai_tools " +
        "ORDER BY COALESCE(monthly_visits,0) DESC LIMIT 6");
         ResultSet rs = ps.executeQuery()) {
      while (rs.next()) {
        toolLabels.add(rs.getString("tool_name"));
        toolVisitSeries.add(rs.getInt("monthly_visits"));
      }
    } catch (Exception ignored) {}
  } catch (Exception ignored) {
  }

  userSeries.addAll(usersByMonth.values());
  creditSeries.addAll(creditsByMonth.values());
  revenueSeries.addAll(revenueByMonth.values());
%>
<%!
  private String escapeJs(String value) {
    if (value == null) return "";
    return value.replace("\\", "\\\\").replace("\"", "\\\"").replace("'", "\\'").replace("\r", "\\r").replace("\n", "\\n");
  }
%>
<%@ include file="/AI/admin/layout/header.jspf" %>
<div class="admin-layout">
  <%@ include file="/AI/admin/layout/sidebar.jspf" %>
  <div class="admin-main-wrapper">
    <%@ include file="/AI/admin/layout/topbar.jspf" %>
    <main class="admin-content">
      <header class="admin-dashboard-header" style="margin-bottom:2rem;">
        <h1>Analytics Hub</h1>
        <p>사용자, 크레딧, 매출, 도구 인기도를 별도 분석 화면으로 분리했습니다.</p>
      </header>

      <section class="kpi-grid" style="margin-bottom:1.5rem;">
        <article class="kpi-card kpi-users"><div class="kpi-icon"><i class="bi bi-people-fill"></i></div><div class="kpi-body"><span class="kpi-label">활성 유저</span><span class="kpi-value"><%= activeUsers %></span></div></article>
        <article class="kpi-card kpi-orders"><div class="kpi-icon"><i class="bi bi-wallet2"></i></div><div class="kpi-body"><span class="kpi-label">활성 구독</span><span class="kpi-value"><%= activeSubs %></span></div></article>
        <article class="kpi-card kpi-revenue"><div class="kpi-icon"><i class="bi bi-coin"></i></div><div class="kpi-body"><span class="kpi-label">총 사용 크레딧</span><span class="kpi-value"><%= String.format(Locale.US, "%,d", totalCreditsUsed) %></span></div></article>
        <article class="kpi-card kpi-tools"><div class="kpi-icon"><i class="bi bi-cash-stack"></i></div><div class="kpi-body"><span class="kpi-label">누적 매출</span><span class="kpi-value kpi-value-sm">₩<%= String.format(Locale.US, "%,.0f", totalRevenue) %></span></div></article>
      </section>

      <section style="display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:1.25rem;">
        <article class="dashboard-card"><header class="dashboard-card__header"><div><h2>신규 사용자</h2><p>최근 6개월</p></div></header><div class="chart-wrap"><canvas id="usersChart"></canvas></div></article>
        <article class="dashboard-card"><header class="dashboard-card__header"><div><h2>크레딧 사용량</h2><p>최근 6개월</p></div></header><div class="chart-wrap"><canvas id="creditsChart"></canvas></div></article>
        <article class="dashboard-card"><header class="dashboard-card__header"><div><h2>매출 추이</h2><p>완료 주문 기준</p></div></header><div class="chart-wrap"><canvas id="revenueChart"></canvas></div></article>
        <article class="dashboard-card"><header class="dashboard-card__header"><div><h2>상위 도구 방문량</h2><p>월 추정 방문수</p></div></header><div class="chart-wrap"><canvas id="toolsChart"></canvas></div></article>
      </section>

      <section class="dashboard-card" style="margin-top:1.5rem;">
        <header class="dashboard-card__header">
          <div>
            <h2>빠른 이동</h2>
            <p>세부 분석 페이지로 바로 이동할 수 있습니다.</p>
          </div>
        </header>
        <div style="display:flex;gap:.75rem;flex-wrap:wrap;">
          <a class="dashboard-pill" href="/AI/admin/analytics/users.jsp">사용자 분석</a>
          <a class="dashboard-pill" href="/AI/admin/analytics/credits.jsp">크레딧 분석</a>
          <a class="dashboard-pill" href="/AI/admin/analytics/revenue.jsp">매출 분석</a>
          <a class="dashboard-pill" href="/AI/admin/analytics/tools.jsp">도구 분석</a>
        </div>
      </section>

      <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.3/dist/chart.umd.min.js"></script>
      <script src="/AI/assets/js/charts.js"></script>
      <script>
        const monthLabels = [<% for (int i = 0; i < monthLabels.size(); i++) { %><%= i > 0 ? "," : "" %>"<%= escapeJs(monthLabels.get(i)) %>"<% } %>];
        const userSeries = [<% for (int i = 0; i < userSeries.size(); i++) { %><%= i > 0 ? "," : "" %><%= userSeries.get(i) %><% } %>];
        const creditSeries = [<% for (int i = 0; i < creditSeries.size(); i++) { %><%= i > 0 ? "," : "" %><%= creditSeries.get(i) %><% } %>];
        const revenueSeries = [<% for (int i = 0; i < revenueSeries.size(); i++) { %><%= i > 0 ? "," : "" %><%= String.format(Locale.US, "%.2f", revenueSeries.get(i)) %><% } %>];
        const toolLabels = [<% for (int i = 0; i < toolLabels.size(); i++) { %><%= i > 0 ? "," : "" %>"<%= escapeJs(toolLabels.get(i)) %>"<% } %>];
        const toolSeries = [<% for (int i = 0; i < toolVisitSeries.size(); i++) { %><%= i > 0 ? "," : "" %><%= toolVisitSeries.get(i) %><% } %>];
        const palette = window.getChartPalette();

        renderLineChart('usersChart', monthLabels, [{ label: 'Users', data: userSeries, borderColor: palette[0], backgroundColor: 'rgba(59,130,246,.16)', fill: true, tension: .35 }], {});
        renderBarChart('creditsChart', monthLabels, creditSeries, { label: 'Credits', backgroundColor: palette[3] });
        renderBarChart('revenueChart', monthLabels, revenueSeries, { label: 'Revenue', backgroundColor: palette[2] });
        renderHorizontalBarChart('toolsChart', toolLabels, toolSeries, { label: 'Visits', backgroundColor: palette.slice(0, toolSeries.length) });
      </script>
      <style>
        .dashboard-card {
          background: var(--glass-bg);
          border: 1px solid var(--glass-border);
          border-radius: var(--radius-xl);
          padding: var(--spacing-xl);
          backdrop-filter: blur(20px);
        }
        .dashboard-card__header { margin-bottom: 1rem; }
        .dashboard-card__header h2 { margin: 0 0 .25rem; font-size: 1.05rem; }
        .dashboard-card__header p { margin: 0; color: var(--text-secondary); font-size: .85rem; }
        .chart-wrap { height: 290px; }
        .dashboard-pill {
          display: inline-flex;
          align-items: center;
          padding: .72rem 1rem;
          border-radius: 999px;
          text-decoration: none;
          color: var(--text-primary);
          background: rgba(15, 23, 42, 0.45);
          border: 1px solid rgba(148, 163, 184, 0.16);
        }
        @media (max-width: 1100px) {
          section[style*="grid-template-columns:repeat(2"] { grid-template-columns: 1fr !important; }
        }
      </style>
<%@ include file="/AI/admin/layout/footer.jspf" %>
