<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="db.DBConnect" %>
<%
  if (session.getAttribute("admin") == null) { response.sendRedirect("/AI/admin/auth/login.jsp"); return; }
  List<String> labels = new ArrayList<>();
  List<Double> data = new ArrayList<>();
  try (Connection c = DBConnect.getConnection();
       PreparedStatement ps = c.prepareStatement("SELECT COALESCE(plan_code,'unknown') plan_code, COALESCE(SUM(total_price),0) total FROM orders GROUP BY COALESCE(plan_code,'unknown') ORDER BY total DESC");
       ResultSet rs = ps.executeQuery()) {
    while (rs.next()) { labels.add(rs.getString("plan_code")); data.add(rs.getDouble("total")); }
  } catch (Exception ignored) {}
%>
<%!
  private String escapeJs(String value) { return value == null ? "" : value.replace("\\", "\\\\").replace("\"", "\\\""); }
%>
<%@ include file="/AI/admin/layout/header.jspf" %>
<div class="admin-layout">
  <%@ include file="/AI/admin/layout/sidebar.jspf" %>
  <div class="admin-main-wrapper">
    <%@ include file="/AI/admin/layout/topbar.jspf" %>
    <main class="admin-content">
      <header class="admin-dashboard-header"><h1>매출 분석</h1><p>플랜 코드 기준 누적 매출 분포입니다.</p></header>
      <section class="dashboard-card"><div class="chart-wrap"><canvas id="revenueAnalyticsChart"></canvas></div></section>
      <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.3/dist/chart.umd.min.js"></script>
      <script src="/AI/assets/js/charts.js"></script>
      <script>
        renderDoughnutChart('revenueAnalyticsChart',
          [<% for (int i=0;i<labels.size();i++) { %><%= i>0 ? "," : "" %>"<%= escapeJs(labels.get(i)) %>"<% } %>],
          [<% for (int i=0;i<data.size();i++) { %><%= i>0 ? "," : "" %><%= String.format(java.util.Locale.US, "%.2f", data.get(i)) %><% } %>], {});
      </script>
      <style>.dashboard-card{background:var(--glass-bg);border:1px solid var(--glass-border);border-radius:var(--radius-xl);padding:var(--spacing-xl)}.chart-wrap{height:340px}</style>
<%@ include file="/AI/admin/layout/footer.jspf" %>
