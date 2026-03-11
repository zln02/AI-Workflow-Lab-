<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="db.DBConnect" %>
<%
  if (session.getAttribute("admin") == null) { response.sendRedirect("/AI/admin/auth/login.jsp"); return; }
  List<String> labels = new ArrayList<>();
  List<Integer> visits = new ArrayList<>();
  try (Connection c = DBConnect.getConnection();
       PreparedStatement ps = c.prepareStatement("SELECT tool_name, COALESCE(monthly_visits,0) monthly_visits FROM ai_tools ORDER BY COALESCE(monthly_visits,0) DESC LIMIT 10");
       ResultSet rs = ps.executeQuery()) {
    while (rs.next()) { labels.add(rs.getString("tool_name")); visits.add(rs.getInt("monthly_visits")); }
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
      <header class="admin-dashboard-header"><h1>도구 인기도 분석</h1><p>월 방문량 기준 상위 10개 도구입니다.</p></header>
      <section class="dashboard-card"><div class="chart-wrap"><canvas id="toolsAnalyticsChart"></canvas></div></section>
      <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.3/dist/chart.umd.min.js"></script>
      <script src="/AI/assets/js/charts.js"></script>
      <script>
        renderHorizontalBarChart('toolsAnalyticsChart',
          [<% for (int i=0;i<labels.size();i++) { %><%= i>0 ? "," : "" %>"<%= escapeJs(labels.get(i)) %>"<% } %>],
          [<% for (int i=0;i<visits.size();i++) { %><%= i>0 ? "," : "" %><%= visits.get(i) %><% } %>], { label:'Visits' });
      </script>
      <style>.dashboard-card{background:var(--glass-bg);border:1px solid var(--glass-border);border-radius:var(--radius-xl);padding:var(--spacing-xl)}.chart-wrap{height:360px}</style>
<%@ include file="/AI/admin/layout/footer.jspf" %>
