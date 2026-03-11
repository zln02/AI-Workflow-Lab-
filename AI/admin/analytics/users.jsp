<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.time.YearMonth" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.LinkedHashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="db.DBConnect" %>
<%
  if (session.getAttribute("admin") == null) {
    response.sendRedirect("/AI/admin/auth/login.jsp");
    return;
  }

  List<String> labels = new ArrayList<>();
  List<Integer> signups = new ArrayList<>();
  List<Integer> actives = new ArrayList<>();
  LinkedHashMap<String, Integer> signupMap = new LinkedHashMap<>();
  LinkedHashMap<String, Integer> activeMap = new LinkedHashMap<>();
  YearMonth now = YearMonth.now();
  DateTimeFormatter fmt = DateTimeFormatter.ofPattern("yyyy-MM");
  for (int i = 5; i >= 0; i--) {
    YearMonth m = now.minusMonths(i);
    labels.add(m.getMonthValue() + "월");
    signupMap.put(m.format(fmt), 0);
    activeMap.put(m.format(fmt), 0);
  }

  try (Connection c = DBConnect.getConnection()) {
    try (PreparedStatement ps = c.prepareStatement(
        "SELECT DATE_FORMAT(created_at,'%Y-%m') ym, COUNT(*) cnt FROM users WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH) GROUP BY DATE_FORMAT(created_at,'%Y-%m') ORDER BY ym");
         ResultSet rs = ps.executeQuery()) {
      while (rs.next()) signupMap.put(rs.getString("ym"), rs.getInt("cnt"));
    }
    try (PreparedStatement ps = c.prepareStatement(
        "SELECT DATE_FORMAT(COALESCE(last_login, created_at),'%Y-%m') ym, COUNT(*) cnt FROM users WHERE is_active=1 AND COALESCE(last_login, created_at) >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH) GROUP BY DATE_FORMAT(COALESCE(last_login, created_at),'%Y-%m') ORDER BY ym");
         ResultSet rs = ps.executeQuery()) {
      while (rs.next()) activeMap.put(rs.getString("ym"), rs.getInt("cnt"));
    }
  } catch (Exception ignored) {}

  signups.addAll(signupMap.values());
  actives.addAll(activeMap.values());
%>
<%!
  private String escapeJs(String value) {
    if (value == null) return "";
    return value.replace("\\", "\\\\").replace("\"", "\\\"");
  }
%>
<%@ include file="/AI/admin/layout/header.jspf" %>
<div class="admin-layout">
  <%@ include file="/AI/admin/layout/sidebar.jspf" %>
  <div class="admin-main-wrapper">
    <%@ include file="/AI/admin/layout/topbar.jspf" %>
    <main class="admin-content">
      <header class="admin-dashboard-header"><h1>사용자 분석</h1><p>가입 추이와 활성 흐름을 월 단위로 확인합니다.</p></header>
      <section class="dashboard-card">
        <div class="chart-wrap"><canvas id="usersAnalyticsChart"></canvas></div>
      </section>
      <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.3/dist/chart.umd.min.js"></script>
      <script src="/AI/assets/js/charts.js"></script>
      <script>
        renderLineChart('usersAnalyticsChart',
          [<% for (int i=0;i<labels.size();i++) { %><%= i>0 ? "," : "" %>"<%= escapeJs(labels.get(i)) %>"<% } %>],
          [
            { label:'가입', data:[<% for (int i=0;i<signups.size();i++) { %><%= i>0 ? "," : "" %><%= signups.get(i) %><% } %>], borderColor:'#3b82f6', backgroundColor:'rgba(59,130,246,.16)', fill:true, tension:.35 },
            { label:'활성', data:[<% for (int i=0;i<actives.size();i++) { %><%= i>0 ? "," : "" %><%= actives.get(i) %><% } %>], borderColor:'#22c55e', backgroundColor:'rgba(34,197,94,.12)', fill:true, tension:.35 }
          ], {});
      </script>
      <style>.dashboard-card{background:var(--glass-bg);border:1px solid var(--glass-border);border-radius:var(--radius-xl);padding:var(--spacing-xl)}.chart-wrap{height:340px}</style>
<%@ include file="/AI/admin/layout/footer.jspf" %>
