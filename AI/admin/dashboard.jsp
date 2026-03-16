<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.time.YearMonth" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.LinkedHashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.util.Map" %>
<%@ page import="db.DBConnect" %>
<%@ page import="util.EscapeUtil" %>
<%
  if (session.getAttribute("admin") == null) {
    response.sendRedirect("/AI/admin/auth/login.jsp");
    return;
  }

  String adminRole = (String) session.getAttribute("adminRole");
  boolean isSuperadmin = "superadmin".equals(adminRole) || "SUPER".equals(adminRole);

  int toolCount = 0;
  int userCount = 0;
  int orderCount = 0;
  int newToolsThisWeek = 0;
  int newUsersThisWeek = 0;
  long totalGrantedCredits = 0L;
  long totalUsedCredits = 0L;
  double creditUsageRate = 0.0;
  double monthRevenue = 0.0;
  double previousMonthRevenue = 0.0;
  double revenueGrowthRate = 0.0;

  List<String> monthLabels = new ArrayList<>();
  List<Integer> signupSeries = new ArrayList<>();
  List<Double> revenueSeries = new ArrayList<>();
  List<String> categoryLabels = new ArrayList<>();
  List<Integer> categorySeries = new ArrayList<>();
  List<String> planLabels = new ArrayList<>();
  List<Integer> planSeries = new ArrayList<>();
  List<Map<String, Object>> recentUsers = new ArrayList<>();
  List<Map<String, Object>> recentOrders = new ArrayList<>();
  List<Map<String, Object>> topTools = new ArrayList<>();
  List<String> dataWarnings = new ArrayList<>();

  DateTimeFormatter monthKeyFormatter = DateTimeFormatter.ofPattern("yyyy-MM");
  LinkedHashMap<String, Integer> signupMap = new LinkedHashMap<>();
  LinkedHashMap<String, Double> revenueMap = new LinkedHashMap<>();
  YearMonth currentMonth = YearMonth.now();
  for (int i = 5; i >= 0; i--) {
    YearMonth month = currentMonth.minusMonths(i);
    String key = month.format(monthKeyFormatter);
    monthLabels.add(month.getMonthValue() + "월");
    signupMap.put(key, 0);
    revenueMap.put(key, 0.0);
  }

  try (Connection c = DBConnect.getConnection()) {
    try (PreparedStatement ps = c.prepareStatement("SELECT COUNT(*) FROM ai_tools");
         ResultSet rs = ps.executeQuery()) {
      if (rs.next()) toolCount = rs.getInt(1);
    }

    try (PreparedStatement ps = c.prepareStatement("SELECT COUNT(*) FROM users WHERE is_active = 1");
         ResultSet rs = ps.executeQuery()) {
      if (rs.next()) userCount = rs.getInt(1);
    }

    try (PreparedStatement ps = c.prepareStatement("SELECT COUNT(*) FROM orders");
         ResultSet rs = ps.executeQuery()) {
      if (rs.next()) orderCount = rs.getInt(1);
    }

    try (PreparedStatement ps = c.prepareStatement("SELECT COUNT(*) FROM ai_tools WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)");
         ResultSet rs = ps.executeQuery()) {
      if (rs.next()) newToolsThisWeek = rs.getInt(1);
    } catch (Exception e) {
      dataWarnings.add("최근 7일 신규 도구 수를 불러오지 못했습니다.");
    }

    try (PreparedStatement ps = c.prepareStatement("SELECT COUNT(*) FROM users WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)");
         ResultSet rs = ps.executeQuery()) {
      if (rs.next()) newUsersThisWeek = rs.getInt(1);
    } catch (Exception e) {
      dataWarnings.add("최근 7일 신규 사용자 수를 불러오지 못했습니다.");
    }

    try (PreparedStatement ps = c.prepareStatement("SELECT COALESCE(SUM(total_granted),0), COALESCE(SUM(total_used),0) FROM user_credits");
         ResultSet rs = ps.executeQuery()) {
      if (rs.next()) {
        totalGrantedCredits = rs.getLong(1);
        totalUsedCredits = rs.getLong(2);
        if (totalGrantedCredits > 0) {
          creditUsageRate = (totalUsedCredits * 100.0) / totalGrantedCredits;
        }
      }
    } catch (Exception e) {
      dataWarnings.add("크레딧 집계 데이터를 불러오지 못했습니다.");
    }

    try (PreparedStatement ps = c.prepareStatement(
        "SELECT COALESCE(SUM(total_price),0) FROM orders WHERE order_status = 'COMPLETED' " +
        "AND created_at >= DATE_FORMAT(CURDATE(), '%Y-%m-01') AND created_at < DATE_ADD(DATE_FORMAT(CURDATE(), '%Y-%m-01'), INTERVAL 1 MONTH)");
         ResultSet rs = ps.executeQuery()) {
      if (rs.next()) monthRevenue = rs.getDouble(1);
    } catch (Exception e) {
      dataWarnings.add("이번 달 매출을 불러오지 못했습니다.");
    }

    try (PreparedStatement ps = c.prepareStatement(
        "SELECT COALESCE(SUM(total_price),0) FROM orders WHERE order_status = 'COMPLETED' " +
        "AND created_at >= DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 1 MONTH), '%Y-%m-01') " +
        "AND created_at < DATE_FORMAT(CURDATE(), '%Y-%m-01')");
         ResultSet rs = ps.executeQuery()) {
      if (rs.next()) previousMonthRevenue = rs.getDouble(1);
    } catch (Exception e) {
      dataWarnings.add("전월 매출을 불러오지 못했습니다.");
    }

    if (previousMonthRevenue > 0) {
      revenueGrowthRate = ((monthRevenue - previousMonthRevenue) / previousMonthRevenue) * 100.0;
    } else if (monthRevenue > 0) {
      revenueGrowthRate = 100.0;
    }

    try (PreparedStatement ps = c.prepareStatement(
        "SELECT DATE_FORMAT(created_at, '%Y-%m') AS ym, COUNT(*) AS cnt " +
        "FROM users WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH) " +
        "GROUP BY DATE_FORMAT(created_at, '%Y-%m') ORDER BY ym");
         ResultSet rs = ps.executeQuery()) {
      while (rs.next()) {
        signupMap.put(rs.getString("ym"), rs.getInt("cnt"));
      }
    } catch (Exception e) {
      dataWarnings.add("가입자 추이 데이터를 불러오지 못했습니다.");
    }

    try (PreparedStatement ps = c.prepareStatement(
        "SELECT DATE_FORMAT(created_at, '%Y-%m') AS ym, COALESCE(SUM(total_price),0) AS amount " +
        "FROM orders WHERE order_status = 'COMPLETED' AND created_at >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH) " +
        "GROUP BY DATE_FORMAT(created_at, '%Y-%m') ORDER BY ym");
         ResultSet rs = ps.executeQuery()) {
      while (rs.next()) {
        revenueMap.put(rs.getString("ym"), rs.getDouble("amount"));
      }
    } catch (Exception e) {
      dataWarnings.add("매출 추이 데이터를 불러오지 못했습니다.");
    }

    try (PreparedStatement ps = c.prepareStatement(
        "SELECT category, COUNT(*) AS cnt FROM ai_tools " +
        "WHERE category IS NOT NULL AND category <> '' GROUP BY category ORDER BY cnt DESC LIMIT 6");
         ResultSet rs = ps.executeQuery()) {
      while (rs.next()) {
        categoryLabels.add(rs.getString("category"));
        categorySeries.add(rs.getInt("cnt"));
      }
    } catch (Exception e) {
      dataWarnings.add("카테고리 분포를 불러오지 못했습니다.");
    }

    try (PreparedStatement ps = c.prepareStatement(
        "SELECT COALESCE(plan_code, 'free') AS plan_code, COUNT(*) AS cnt " +
        "FROM subscriptions WHERE status = 'ACTIVE' GROUP BY COALESCE(plan_code, 'free') ORDER BY cnt DESC");
         ResultSet rs = ps.executeQuery()) {
      while (rs.next()) {
        planLabels.add(rs.getString("plan_code"));
        planSeries.add(rs.getInt("cnt"));
      }
    } catch (Exception e) {
      dataWarnings.add("플랜 분포를 불러오지 못했습니다.");
    }

    try (PreparedStatement ps = c.prepareStatement(
        "SELECT id, name, email, created_at FROM users ORDER BY created_at DESC LIMIT 5");
         ResultSet rs = ps.executeQuery()) {
      while (rs.next()) {
        Map<String, Object> row = new HashMap<>();
        row.put("id", rs.getInt("id"));
        row.put("name", rs.getString("name"));
        row.put("email", rs.getString("email"));
        row.put("created_at", rs.getTimestamp("created_at"));
        recentUsers.add(row);
      }
    } catch (Exception e) {
      dataWarnings.add("최근 가입 유저 목록을 불러오지 못했습니다.");
    }

    try (PreparedStatement ps = c.prepareStatement(
        "SELECT id, customer_name, customer_email, total_price, order_status, created_at FROM orders ORDER BY created_at DESC LIMIT 5");
         ResultSet rs = ps.executeQuery()) {
      while (rs.next()) {
        Map<String, Object> row = new HashMap<>();
        row.put("id", rs.getInt("id"));
        row.put("customer_name", rs.getString("customer_name"));
        row.put("customer_email", rs.getString("customer_email"));
        row.put("total_price", rs.getDouble("total_price"));
        row.put("order_status", rs.getString("order_status"));
        row.put("created_at", rs.getTimestamp("created_at"));
        recentOrders.add(row);
      }
    } catch (Exception e) {
      dataWarnings.add("최근 주문 목록을 불러오지 못했습니다.");
    }

    try (PreparedStatement ps = c.prepareStatement(
        "SELECT id, tool_name, category, COALESCE(trend_score, 0) AS trend_score, COALESCE(growth_rate, 0) AS growth_rate, COALESCE(monthly_visits, 0) AS monthly_visits " +
        "FROM ai_tools ORDER BY COALESCE(trend_score, 0) DESC, COALESCE(monthly_visits, 0) DESC LIMIT 5");
         ResultSet rs = ps.executeQuery()) {
      while (rs.next()) {
        Map<String, Object> row = new HashMap<>();
        row.put("id", rs.getInt("id"));
        row.put("tool_name", rs.getString("tool_name"));
        row.put("category", rs.getString("category"));
        row.put("trend_score", rs.getDouble("trend_score"));
        row.put("growth_rate", rs.getDouble("growth_rate"));
        row.put("monthly_visits", rs.getLong("monthly_visits"));
        topTools.add(row);
      }
    } catch (Exception e) {
      dataWarnings.add("인기 도구 통계를 불러오지 못했습니다.");
    }
  } catch (Exception e) {
    dataWarnings.add("대시보드 DB 연결에 실패했습니다.");
  }

  signupSeries.addAll(signupMap.values());
  revenueSeries.addAll(revenueMap.values());
%>
<%!
  private String escapeJs(String value) {
    if (value == null) return "";
    return value.replace("\\", "\\\\").replace("\"", "\\\"").replace("'", "\\'").replace("\r", "\\r").replace("\n", "\\n");
  }

  private String escapeHtml(Object value) {
    if (value == null) return "-";
    return EscapeUtil.escapeHtml(String.valueOf(value));
  }

  private String formatTimestamp(Object value) {
    if (value == null) return "-";
    return new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(value);
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
      <% if (!dataWarnings.isEmpty()) { %>
      <section class="dashboard-alert" aria-live="polite">
        <strong>일부 지표를 불러오지 못했습니다.</strong>
        <ul class="dashboard-alert__list">
          <% for (String warning : dataWarnings) { %>
          <li><%= escapeHtml(warning) %></li>
          <% } %>
        </ul>
      </section>
      <% } %>
      <header class="admin-dashboard-header" style="margin-bottom:2rem;">
        <div style="display:flex;justify-content:space-between;align-items:flex-start;gap:1rem;flex-wrap:wrap;">
          <div>
            <h1>AI Workflow Lab 대시보드</h1>
            <p>운영 KPI, 성장 추이, 결제/크레딧 사용률을 한 화면에서 확인합니다.</p>
          </div>
          <div class="dashboard-pill-group">
            <a class="dashboard-pill" href="/AI/admin/statistics/index.jsp"><i class="bi bi-bar-chart"></i>인사이트</a>
            <a class="dashboard-pill" href="/AI/admin/orders/index.jsp"><i class="bi bi-receipt"></i>주문</a>
            <a class="dashboard-pill" href="/AI/admin/users/index.jsp"><i class="bi bi-people"></i>사용자</a>
          </div>
        </div>
      </header>

      <section class="kpi-grid" style="margin-bottom:1.5rem;">
        <article class="kpi-card kpi-tools">
          <div class="kpi-icon"><i class="bi bi-cpu-fill"></i></div>
          <div class="kpi-body">
            <span class="kpi-label">총 도구</span>
            <span class="kpi-value"><%= toolCount %></span>
            <span class="kpi-desc">이번 주 +<%= newToolsThisWeek %>개</span>
          </div>
        </article>
        <article class="kpi-card kpi-users">
          <div class="kpi-icon"><i class="bi bi-people-fill"></i></div>
          <div class="kpi-body">
            <span class="kpi-label">활성 유저</span>
            <span class="kpi-value"><%= userCount %></span>
            <span class="kpi-desc">금주 +<%= newUsersThisWeek %>명</span>
          </div>
        </article>
        <article class="kpi-card kpi-orders">
          <div class="kpi-icon"><i class="bi bi-cash-stack"></i></div>
          <div class="kpi-body">
            <span class="kpi-label">월 매출</span>
            <span class="kpi-value kpi-value-sm">₩<%= String.format(Locale.US, "%,.0f", monthRevenue) %></span>
            <span class="kpi-desc"><%= String.format(Locale.US, "%+.1f%% MoM", revenueGrowthRate) %></span>
          </div>
        </article>
        <article class="kpi-card kpi-revenue">
          <div class="kpi-icon"><i class="bi bi-coin"></i></div>
          <div class="kpi-body">
            <span class="kpi-label">총 크레딧</span>
            <span class="kpi-value"><%= compactNumber(totalGrantedCredits) %></span>
            <span class="kpi-desc">사용률 <%= String.format(Locale.US, "%.1f%%", creditUsageRate) %></span>
          </div>
        </article>
      </section>

      <section class="dashboard-grid" style="margin-bottom:1.5rem;">
        <article class="dashboard-card dashboard-chart-card">
          <header class="dashboard-card__header">
            <div>
              <h2>월간 가입자 추이</h2>
              <p>최근 6개월 활성 가입 흐름</p>
            </div>
          </header>
          <div class="chart-wrap"><canvas id="signupChart"></canvas></div>
        </article>
        <article class="dashboard-card dashboard-chart-card">
          <header class="dashboard-card__header">
            <div>
              <h2>카테고리 분포</h2>
              <p>상위 카테고리 6개</p>
            </div>
          </header>
          <div class="chart-wrap"><canvas id="categoryChart"></canvas></div>
        </article>
        <article class="dashboard-card dashboard-chart-card">
          <header class="dashboard-card__header">
            <div>
              <h2>매출 추이</h2>
              <p>완료 주문 기준 최근 6개월</p>
            </div>
          </header>
          <div class="chart-wrap"><canvas id="revenueChart"></canvas></div>
        </article>
        <article class="dashboard-card dashboard-chart-card">
          <header class="dashboard-card__header">
            <div>
              <h2>플랜 분포</h2>
              <p>활성 구독 플랜 구성</p>
            </div>
          </header>
          <div class="chart-wrap"><canvas id="planChart"></canvas></div>
        </article>
      </section>

      <section class="dashboard-secondary-grid" style="margin-bottom:1.5rem;">
        <article class="dashboard-card">
          <header class="dashboard-card__header">
            <div>
              <h2>최근 가입 유저</h2>
              <p>신규 회원 5명</p>
            </div>
            <a class="btn" href="/AI/admin/users/index.jsp" style="padding:8px 14px;">전체 보기</a>
          </header>
          <div class="dashboard-list">
            <% if (recentUsers.isEmpty()) { %>
              <p class="dashboard-empty">표시할 가입 이력이 없습니다.</p>
            <% } else { for (Map<String, Object> row : recentUsers) { %>
              <div class="dashboard-list__item">
                <div>
                  <strong><%= row.get("name") != null ? escapeHtml(row.get("name")) : "이름 없음" %></strong>
                  <p><%= row.get("email") != null ? escapeHtml(row.get("email")) : "-" %></p>
                </div>
                <span><%= formatTimestamp(row.get("created_at")) %></span>
              </div>
            <% }} %>
          </div>
        </article>
        <article class="dashboard-card">
          <header class="dashboard-card__header">
            <div>
              <h2>최근 주문</h2>
              <p>결제 상태 포함 최근 5건</p>
            </div>
            <a class="btn" href="/AI/admin/orders/index.jsp" style="padding:8px 14px;">전체 보기</a>
          </header>
          <div class="dashboard-list">
            <% if (recentOrders.isEmpty()) { %>
              <p class="dashboard-empty">주문 데이터가 없습니다.</p>
            <% } else { for (Map<String, Object> row : recentOrders) { %>
              <div class="dashboard-list__item">
                <div>
                  <strong>#<%= row.get("id") %> <%= row.get("customer_name") != null ? escapeHtml(row.get("customer_name")) : "고객" %></strong>
                  <p><%= row.get("customer_email") != null ? escapeHtml(row.get("customer_email")) : "-" %></p>
                </div>
                <div style="text-align:right;">
                  <strong>₩<%= String.format(Locale.US, "%,.0f", row.get("total_price")) %></strong>
                  <p><%= row.get("order_status") != null ? escapeHtml(row.get("order_status")) : "-" %> · <%= formatTimestamp(row.get("created_at")) %></p>
                </div>
              </div>
            <% }} %>
          </div>
        </article>
      </section>

      <section class="dashboard-card" style="margin-bottom:2rem;">
        <header class="dashboard-card__header">
          <div>
            <h2>인기 도구 TOP 5</h2>
            <p>트렌드 점수와 방문량 기준</p>
          </div>
          <a class="btn" href="/AI/admin/tools/index.jsp" style="padding:8px 14px;">도구 관리</a>
        </header>
        <div class="admin-table-section">
          <table class="admin-table">
            <thead>
              <tr>
                <th>도구명</th>
                <th>카테고리</th>
                <th>트렌드 점수</th>
                <th>성장률</th>
                <th>월 방문량</th>
              </tr>
            </thead>
            <tbody>
              <% if (topTools.isEmpty()) { %>
                <tr><td colspan="5" style="text-align:center;padding:2rem;">도구 통계가 없습니다.</td></tr>
              <% } else { for (Map<String, Object> row : topTools) { %>
                <tr>
                  <td><strong><%= escapeHtml(row.get("tool_name")) %></strong></td>
                  <td><%= row.get("category") != null ? escapeHtml(row.get("category")) : "-" %></td>
                  <td><%= String.format(Locale.US, "%.1f", row.get("trend_score")) %></td>
                  <td><%= String.format(Locale.US, "%+.1f%%", row.get("growth_rate")) %></td>
                  <td><%= compactNumber(((Number) row.get("monthly_visits")).longValue()) %></td>
                </tr>
              <% }} %>
            </tbody>
          </table>
        </div>
      </section>
      <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.3/dist/chart.umd.min.js"></script>
      <script src="/AI/assets/js/charts.js"></script>
      <script>
  const monthLabels = [<% for (int i = 0; i < monthLabels.size(); i++) { %><%= i > 0 ? "," : "" %>"<%= escapeJs(monthLabels.get(i)) %>"<% } %>];
  const signupSeries = [<% for (int i = 0; i < signupSeries.size(); i++) { %><%= i > 0 ? "," : "" %><%= signupSeries.get(i) %><% } %>];
  const revenueSeries = [<% for (int i = 0; i < revenueSeries.size(); i++) { %><%= i > 0 ? "," : "" %><%= String.format(Locale.US, "%.2f", revenueSeries.get(i)) %><% } %>];
  const categoryLabels = [<% for (int i = 0; i < categoryLabels.size(); i++) { %><%= i > 0 ? "," : "" %>"<%= escapeJs(categoryLabels.get(i)) %>"<% } %>];
  const categorySeries = [<% for (int i = 0; i < categorySeries.size(); i++) { %><%= i > 0 ? "," : "" %><%= categorySeries.get(i) %><% } %>];
  const planLabels = [<% for (int i = 0; i < planLabels.size(); i++) { %><%= i > 0 ? "," : "" %>"<%= escapeJs(planLabels.get(i)) %>"<% } %>];
  const planSeries = [<% for (int i = 0; i < planSeries.size(); i++) { %><%= i > 0 ? "," : "" %><%= planSeries.get(i) %><% } %>];
  const palette = window.getChartPalette ? window.getChartPalette() : ['#3b82f6', '#06b6d4', '#22c55e', '#f59e0b'];

  renderLineChart('signupChart', monthLabels, [{
    label: '신규 가입자',
    data: signupSeries,
    borderColor: palette[0],
    backgroundColor: 'rgba(59,130,246,.18)',
    tension: 0.35,
    fill: true,
    pointRadius: 3
  }], {});

  renderDoughnutChart('categoryChart', categoryLabels, categorySeries, {});

  renderBarChart('revenueChart', monthLabels, revenueSeries, {
    label: '월 매출',
    backgroundColor: palette[2],
    plugins: {
      tooltip: {
        callbacks: {
          label: function(context) {
            const value = Number(context.raw || 0);
            return '월 매출: ₩' + value.toLocaleString('ko-KR');
          }
        }
      }
    },
    scales: {
      x: { ticks: { color: '#94a3b8' }, grid: { color: 'rgba(148,163,184,.08)' } },
      y: {
        ticks: {
          color: '#94a3b8',
          callback: function(value) {
            return '₩' + Number(value).toLocaleString('ko-KR');
          }
        },
        grid: { color: 'rgba(148,163,184,.08)' }
      }
    }
  });

  renderDoughnutChart('planChart', planLabels, planSeries, {});
      </script>
<%@ include file="/AI/admin/layout/footer.jspf" %>
