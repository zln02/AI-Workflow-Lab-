<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="db.DBConnect" %>
<%
  if (session.getAttribute("admin") == null) { response.sendRedirect("/AI/admin/auth/login.jsp"); return; }
  List<String> labels = new ArrayList<>();
  List<Integer> data = new ArrayList<>();
  try (Connection c = DBConnect.getConnection();
       PreparedStatement ps = c.prepareStatement("SELECT COALESCE(model_used,'unknown') model_used, COALESCE(SUM(credits_used),0) credits FROM credit_usage_logs GROUP BY COALESCE(model_used,'unknown') ORDER BY credits DESC LIMIT 8");
       ResultSet rs = ps.executeQuery()) {
    while (rs.next()) { labels.add(rs.getString("model_used")); data.add(rs.getInt("credits")); }
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
      <header class="admin-dashboard-header"><h1>크레딧 분석</h1><p>모델별 크레딧 사용량 상위 분포입니다.</p></header>
      <section class="dashboard-card"><div class="chart-wrap"><canvas id="creditsAnalyticsChart"></canvas></div></section>
      <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.3/dist/chart.umd.min.js"></script>
      <script src="/AI/assets/js/charts.js"></script>
      <script>
        renderHorizontalBarChart('creditsAnalyticsChart',
          [<% for (int i=0;i<labels.size();i++) { %><%= i>0 ? "," : "" %>"<%= escapeJs(labels.get(i)) %>"<% } %>],
          [<% for (int i=0;i<data.size();i++) { %><%= i>0 ? "," : "" %><%= data.get(i) %><% } %>],
          { label:'Credits' });
      </script>
      <style>.dashboard-card{background:var(--glass-bg);border:1px solid var(--glass-border);border-radius:var(--radius-xl);padding:var(--spacing-xl)}.chart-wrap{height:340px}</style>
<%@ include file="/AI/admin/layout/footer.jspf" %>
