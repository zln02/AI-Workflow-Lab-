<%@ page contentType="text/html; charset=UTF-8" isELIgnored="true" %>
<%@ page import="java.sql.*" %>
<%@ page import="db.DBConnect" %>
<%@ page import="util.EscapeUtil" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="com.google.gson.JsonArray" %>
<%@ page import="com.google.gson.JsonElement" %>
<%@ page import="com.google.gson.JsonObject" %>
<%!
  private java.util.List<String> parseCsvLine(String line) {
    java.util.List<String> values = new java.util.ArrayList<>();
    if (line == null) return values;
    StringBuilder current = new StringBuilder();
    boolean inQuotes = false;
    for (int i = 0; i < line.length(); i++) {
      char ch = line.charAt(i);
      if (ch == '"') {
        if (inQuotes && i + 1 < line.length() && line.charAt(i + 1) == '"') {
          current.append('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (ch == ',' && !inQuotes) {
        values.add(current.toString());
        current.setLength(0);
      } else {
        current.append(ch);
      }
    }
    values.add(current.toString());
    return values;
  }
%>
<%
  if (session.getAttribute("admin") == null) {
    response.sendRedirect("/AI/admin/auth/login.jsp");
    return;
  }
  request.setCharacterEncoding("UTF-8");

  String msg = null;
  String msgType = "success";

  String deleteId = request.getParameter("deleteId");
  if (deleteId != null && deleteId.matches("\\d+")) {
    try (Connection c = DBConnect.getConnection();
         PreparedStatement ps = c.prepareStatement("DELETE FROM ai_tools WHERE id=?")) {
      ps.setInt(1, Integer.parseInt(deleteId));
      ps.executeUpdate();
      msg = "AI 도구가 삭제되었습니다.";
    } catch (Exception e) { msg = "삭제 실패: " + e.getMessage(); msgType = "error"; }
  }

  String deleteNewsId = request.getParameter("deleteNewsId");
  if (deleteNewsId != null && deleteNewsId.matches("\\d+")) {
    try (Connection c = DBConnect.getConnection();
         PreparedStatement ps = c.prepareStatement("DELETE FROM ai_tool_news WHERE id=?")) {
      ps.setInt(1, Integer.parseInt(deleteNewsId));
      ps.executeUpdate();
      msg = "뉴스가 삭제되었습니다.";
    } catch (Exception e) { msg = "뉴스 삭제 실패: " + e.getMessage(); msgType = "error"; }
  }

  String deleteBenchmarkId = request.getParameter("deleteBenchmarkId");
  if (deleteBenchmarkId != null && deleteBenchmarkId.matches("\\d+")) {
    try (Connection c = DBConnect.getConnection();
         PreparedStatement ps = c.prepareStatement("DELETE FROM ai_tool_benchmarks WHERE id=?")) {
      ps.setInt(1, Integer.parseInt(deleteBenchmarkId));
      ps.executeUpdate();
      msg = "벤치마크가 삭제되었습니다.";
    } catch (Exception e) { msg = "벤치마크 삭제 실패: " + e.getMessage(); msgType = "error"; }
  }

  if ("POST".equals(request.getMethod()) && "create".equals(request.getParameter("action"))) {
    String toolName = request.getParameter("tool_name");
    String providerName = request.getParameter("provider_name");
    String providerCountry = request.getParameter("provider_country");
    String category = request.getParameter("category");
    String description = request.getParameter("description");
    String pricing = request.getParameter("pricing_model");
    String difficulty = request.getParameter("difficulty_level");
    String websiteUrl = request.getParameter("website_url");
    String docsUrl = request.getParameter("docs_url");
    String rankParam = request.getParameter("global_rank");
    String trendParam = request.getParameter("trend_score");
    String growthParam = request.getParameter("growth_rate");
    String visitsParam = request.getParameter("monthly_visits");
    String mauParam = request.getParameter("monthly_active_users");
    String githubStarsParam = request.getParameter("github_stars");
    boolean apiAvailable = "on".equals(request.getParameter("api_available"));
    boolean freeTier = "on".equals(request.getParameter("free_tier_available"));
    boolean enterpriseReady = "on".equals(request.getParameter("enterprise_ready"));
    boolean openSource = "on".equals(request.getParameter("open_source"));

    if (toolName != null && !toolName.trim().isEmpty()) {
      try (Connection c = DBConnect.getConnection();
           PreparedStatement ps = c.prepareStatement(
             "INSERT INTO ai_tools (" +
             "tool_name, provider_name, provider_country, category, description, pricing_model, difficulty_level, " +
             "website_url, docs_url, api_available, free_tier_available, enterprise_ready, open_source, " +
             "global_rank, trend_score, growth_rate, monthly_visits, monthly_active_users, github_stars" +
             ") VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)")) {
        ps.setString(1, toolName.trim());
        ps.setString(2, providerName != null ? providerName.trim() : "");
        ps.setString(3, providerCountry != null ? providerCountry.trim() : null);
        ps.setString(4, category != null ? category.trim() : "기타");
        ps.setString(5, description != null ? description.trim() : "");
        ps.setString(6, pricing != null ? pricing.trim() : "Free");
        ps.setString(7, difficulty != null ? difficulty.trim() : "Beginner");
        ps.setString(8, websiteUrl != null ? websiteUrl.trim() : null);
        ps.setString(9, docsUrl != null ? docsUrl.trim() : null);
        ps.setBoolean(10, apiAvailable);
        ps.setBoolean(11, freeTier);
        ps.setBoolean(12, enterpriseReady);
        ps.setBoolean(13, openSource);
        if (rankParam != null && !rankParam.trim().isEmpty()) ps.setInt(14, Integer.parseInt(rankParam.trim())); else ps.setNull(14, Types.INTEGER);
        if (trendParam != null && !trendParam.trim().isEmpty()) ps.setBigDecimal(15, new java.math.BigDecimal(trendParam.trim())); else ps.setNull(15, Types.DECIMAL);
        if (growthParam != null && !growthParam.trim().isEmpty()) ps.setBigDecimal(16, new java.math.BigDecimal(growthParam.trim())); else ps.setNull(16, Types.DECIMAL);
        if (visitsParam != null && !visitsParam.trim().isEmpty()) ps.setLong(17, Long.parseLong(visitsParam.trim())); else ps.setNull(17, Types.BIGINT);
        if (mauParam != null && !mauParam.trim().isEmpty()) ps.setLong(18, Long.parseLong(mauParam.trim())); else ps.setNull(18, Types.BIGINT);
        if (githubStarsParam != null && !githubStarsParam.trim().isEmpty()) ps.setInt(19, Integer.parseInt(githubStarsParam.trim())); else ps.setNull(19, Types.INTEGER);
        ps.executeUpdate();
        msg = "AI 도구가 추가되었습니다.";
      } catch (Exception e) { msg = "추가 실패: " + e.getMessage(); msgType = "error"; }
    }
  }

  if ("POST".equals(request.getMethod()) && "quick_rank".equals(request.getParameter("action"))) {
    String idParam = request.getParameter("id");
    if (idParam != null && idParam.matches("\\d+")) {
      try (Connection c = DBConnect.getConnection();
           PreparedStatement ps = c.prepareStatement(
             "UPDATE ai_tools SET global_rank=?, trend_score=?, growth_rate=? WHERE id=?")) {
        String rank = request.getParameter("global_rank");
        String trend = request.getParameter("trend_score");
        String growth = request.getParameter("growth_rate");
        if (rank != null && !rank.trim().isEmpty()) ps.setInt(1, Integer.parseInt(rank.trim())); else ps.setNull(1, Types.INTEGER);
        if (trend != null && !trend.trim().isEmpty()) ps.setBigDecimal(2, new java.math.BigDecimal(trend.trim())); else ps.setNull(2, Types.DECIMAL);
        if (growth != null && !growth.trim().isEmpty()) ps.setBigDecimal(3, new java.math.BigDecimal(growth.trim())); else ps.setNull(3, Types.DECIMAL);
        ps.setInt(4, Integer.parseInt(idParam));
        ps.executeUpdate();
        msg = "랭크/트렌드 지표가 업데이트되었습니다.";
      } catch (Exception e) { msg = "랭크 업데이트 실패: " + e.getMessage(); msgType = "error"; }
    }
  }

  if ("POST".equals(request.getMethod()) && "bulk_import".equals(request.getParameter("action"))) {
    String format = request.getParameter("bulk_format");
    String payload = request.getParameter("bulk_payload");
    int imported = 0;
    if (payload != null && !payload.trim().isEmpty()) {
      try (Connection c = DBConnect.getConnection()) {
        if ("json".equalsIgnoreCase(format)) {
          JsonArray items = new Gson().fromJson(payload, JsonArray.class);
          for (JsonElement item : items) {
            if (item != null && item.isJsonObject()) {
              JsonObject obj = item.getAsJsonObject();
              if (!obj.has("tool_name")) continue;
              try (PreparedStatement ps = c.prepareStatement(
                  "INSERT INTO ai_tools (tool_name, provider_name, provider_country, category, pricing_model, difficulty_level, website_url, docs_url, description, global_rank, trend_score, growth_rate) " +
                  "VALUES (?,?,?,?,?,?,?,?,?,?,?,?)")) {
                ps.setString(1, obj.get("tool_name").getAsString());
                ps.setString(2, obj.has("provider_name") ? obj.get("provider_name").getAsString() : null);
                ps.setString(3, obj.has("provider_country") ? obj.get("provider_country").getAsString() : null);
                ps.setString(4, obj.has("category") ? obj.get("category").getAsString() : "기타");
                ps.setString(5, obj.has("pricing_model") ? obj.get("pricing_model").getAsString() : "Freemium");
                ps.setString(6, obj.has("difficulty_level") ? obj.get("difficulty_level").getAsString() : "Beginner");
                ps.setString(7, obj.has("website_url") ? obj.get("website_url").getAsString() : null);
                ps.setString(8, obj.has("docs_url") ? obj.get("docs_url").getAsString() : null);
                ps.setString(9, obj.has("description") ? obj.get("description").getAsString() : null);
                if (obj.has("global_rank")) ps.setInt(10, obj.get("global_rank").getAsInt()); else ps.setNull(10, Types.INTEGER);
                if (obj.has("trend_score")) ps.setBigDecimal(11, obj.get("trend_score").getAsBigDecimal()); else ps.setNull(11, Types.DECIMAL);
                if (obj.has("growth_rate")) ps.setBigDecimal(12, obj.get("growth_rate").getAsBigDecimal()); else ps.setNull(12, Types.DECIMAL);
                ps.executeUpdate();
                imported++;
              }
            }
          }
        } else {
          String[] lines = payload.split("\\r?\\n");
          for (String line : lines) {
            if (line == null || line.trim().isEmpty() || line.startsWith("tool_name,")) continue;
            java.util.List<String> cols = parseCsvLine(line);
            if (cols.isEmpty() || cols.get(0).trim().isEmpty()) continue;
            try (PreparedStatement ps = c.prepareStatement(
                "INSERT INTO ai_tools (tool_name, provider_name, provider_country, category, pricing_model, difficulty_level, website_url, docs_url, description, global_rank, trend_score, growth_rate) " +
                "VALUES (?,?,?,?,?,?,?,?,?,?,?,?)")) {
              ps.setString(1, cols.get(0).trim());
              ps.setString(2, cols.size() > 1 && !cols.get(1).trim().isEmpty() ? cols.get(1).trim() : null);
              ps.setString(3, cols.size() > 2 && !cols.get(2).trim().isEmpty() ? cols.get(2).trim() : null);
              ps.setString(4, cols.size() > 3 && !cols.get(3).trim().isEmpty() ? cols.get(3).trim() : "기타");
              ps.setString(5, cols.size() > 4 && !cols.get(4).trim().isEmpty() ? cols.get(4).trim() : "Freemium");
              ps.setString(6, cols.size() > 5 && !cols.get(5).trim().isEmpty() ? cols.get(5).trim() : "Beginner");
              ps.setString(7, cols.size() > 6 && !cols.get(6).trim().isEmpty() ? cols.get(6).trim() : null);
              ps.setString(8, cols.size() > 7 && !cols.get(7).trim().isEmpty() ? cols.get(7).trim() : null);
              ps.setString(9, cols.size() > 8 && !cols.get(8).trim().isEmpty() ? cols.get(8).trim() : null);
              if (cols.size() > 9 && !cols.get(9).trim().isEmpty()) ps.setInt(10, Integer.parseInt(cols.get(9).trim())); else ps.setNull(10, Types.INTEGER);
              if (cols.size() > 10 && !cols.get(10).trim().isEmpty()) ps.setBigDecimal(11, new java.math.BigDecimal(cols.get(10).trim())); else ps.setNull(11, Types.DECIMAL);
              if (cols.size() > 11 && !cols.get(11).trim().isEmpty()) ps.setBigDecimal(12, new java.math.BigDecimal(cols.get(11).trim())); else ps.setNull(12, Types.DECIMAL);
              ps.executeUpdate();
              imported++;
            }
          }
        }
        msg = imported + "개 도구를 일괄 등록했습니다.";
      } catch (Exception e) { msg = "일괄 등록 실패: " + e.getMessage(); msgType = "error"; }
    }
  }

  if ("POST".equals(request.getMethod()) && "create_news".equals(request.getParameter("action"))) {
    try (Connection c = DBConnect.getConnection();
         PreparedStatement ps = c.prepareStatement(
           "INSERT INTO ai_tool_news (tool_id, title, summary, content, source_name, source_url, news_type, is_featured, is_active) VALUES (?,?,?,?,?,?,?,?,1)")) {
      String toolId = request.getParameter("news_tool_id");
      if (toolId != null && toolId.matches("\\d+")) ps.setInt(1, Integer.parseInt(toolId)); else ps.setNull(1, Types.INTEGER);
      ps.setString(2, request.getParameter("news_title"));
      ps.setString(3, request.getParameter("news_summary"));
      ps.setString(4, request.getParameter("news_content"));
      ps.setString(5, request.getParameter("news_source_name"));
      ps.setString(6, request.getParameter("news_source_url"));
      ps.setString(7, request.getParameter("news_type") != null ? request.getParameter("news_type") : "update");
      ps.setBoolean(8, "on".equals(request.getParameter("news_featured")));
      ps.executeUpdate();
      msg = "뉴스가 등록되었습니다.";
    } catch (Exception e) { msg = "뉴스 등록 실패: " + e.getMessage(); msgType = "error"; }
  }

  if ("POST".equals(request.getMethod()) && "update_news".equals(request.getParameter("action"))) {
    try (Connection c = DBConnect.getConnection();
         PreparedStatement ps = c.prepareStatement(
           "UPDATE ai_tool_news SET tool_id=?, title=?, summary=?, content=?, source_name=?, source_url=?, news_type=?, is_featured=? WHERE id=?")) {
      String toolId = request.getParameter("news_tool_id");
      if (toolId != null && toolId.matches("\\d+")) ps.setInt(1, Integer.parseInt(toolId)); else ps.setNull(1, Types.INTEGER);
      ps.setString(2, request.getParameter("news_title"));
      ps.setString(3, request.getParameter("news_summary"));
      ps.setString(4, request.getParameter("news_content"));
      ps.setString(5, request.getParameter("news_source_name"));
      ps.setString(6, request.getParameter("news_source_url"));
      ps.setString(7, request.getParameter("news_type") != null ? request.getParameter("news_type") : "update");
      ps.setBoolean(8, "on".equals(request.getParameter("news_featured")));
      ps.setInt(9, Integer.parseInt(request.getParameter("news_id")));
      ps.executeUpdate();
      msg = "뉴스가 수정되었습니다.";
    } catch (Exception e) { msg = "뉴스 수정 실패: " + e.getMessage(); msgType = "error"; }
  }

  if ("POST".equals(request.getMethod()) && "create_benchmark".equals(request.getParameter("action"))) {
    try (Connection c = DBConnect.getConnection();
         PreparedStatement ps = c.prepareStatement(
           "INSERT INTO ai_tool_benchmarks (tool_id, benchmark_name, score, max_score, test_date, source, notes) VALUES (?,?,?,?,?,?,?)")) {
      ps.setInt(1, Integer.parseInt(request.getParameter("benchmark_tool_id")));
      ps.setString(2, request.getParameter("benchmark_name"));
      ps.setBigDecimal(3, new java.math.BigDecimal(request.getParameter("benchmark_score")));
      String maxScore = request.getParameter("benchmark_max_score");
      if (maxScore != null && !maxScore.trim().isEmpty()) ps.setBigDecimal(4, new java.math.BigDecimal(maxScore)); else ps.setNull(4, Types.DECIMAL);
      String testDate = request.getParameter("benchmark_test_date");
      if (testDate != null && !testDate.trim().isEmpty()) ps.setDate(5, java.sql.Date.valueOf(testDate)); else ps.setNull(5, Types.DATE);
      ps.setString(6, request.getParameter("benchmark_source"));
      ps.setString(7, request.getParameter("benchmark_notes"));
      ps.executeUpdate();
      msg = "벤치마크가 등록되었습니다.";
    } catch (Exception e) { msg = "벤치마크 등록 실패: " + e.getMessage(); msgType = "error"; }
  }

  if ("POST".equals(request.getMethod()) && "update_benchmark".equals(request.getParameter("action"))) {
    try (Connection c = DBConnect.getConnection();
         PreparedStatement ps = c.prepareStatement(
           "UPDATE ai_tool_benchmarks SET tool_id=?, benchmark_name=?, score=?, max_score=?, test_date=?, source=?, notes=? WHERE id=?")) {
      ps.setInt(1, Integer.parseInt(request.getParameter("benchmark_tool_id")));
      ps.setString(2, request.getParameter("benchmark_name"));
      ps.setBigDecimal(3, new java.math.BigDecimal(request.getParameter("benchmark_score")));
      String maxScore = request.getParameter("benchmark_max_score");
      if (maxScore != null && !maxScore.trim().isEmpty()) ps.setBigDecimal(4, new java.math.BigDecimal(maxScore)); else ps.setNull(4, Types.DECIMAL);
      String testDate = request.getParameter("benchmark_test_date");
      if (testDate != null && !testDate.trim().isEmpty()) ps.setDate(5, java.sql.Date.valueOf(testDate)); else ps.setNull(5, Types.DATE);
      ps.setString(6, request.getParameter("benchmark_source"));
      ps.setString(7, request.getParameter("benchmark_notes"));
      ps.setInt(8, Integer.parseInt(request.getParameter("benchmark_id")));
      ps.executeUpdate();
      msg = "벤치마크가 수정되었습니다.";
    } catch (Exception e) { msg = "벤치마크 수정 실패: " + e.getMessage(); msgType = "error"; }
  }
%>
<%@ include file="/AI/admin/layout/header.jspf" %>
<div class="admin-layout">
  <%@ include file="/AI/admin/layout/sidebar.jspf" %>
  <div class="admin-main-wrapper">
    <%@ include file="/AI/admin/layout/topbar.jspf" %>
    <main class="admin-content">

      <header class="admin-dashboard-header">
        <div style="display:flex;justify-content:space-between;align-items:center;gap:1rem;flex-wrap:wrap;">
          <div>
            <h1>AI 도구 관리</h1>
            <p>Phase 1 확장 필드를 포함해 AI 도구 메타데이터를 관리합니다.</p>
          </div>
          <div style="display:flex;gap:.75rem;flex-wrap:wrap;">
            <button class="btn secondary" onclick="document.getElementById('newsModal').style.display='flex'">뉴스 등록</button>
            <button class="btn secondary" onclick="document.getElementById('benchmarkModal').style.display='flex'">벤치마크 등록</button>
            <button class="btn secondary" onclick="document.getElementById('bulkModal').style.display='flex'">CSV/JSON 업로드</button>
            <button class="btn primary" onclick="document.getElementById('createModal').style.display='flex'">+ AI 도구 추가</button>
          </div>
        </div>
      </header>

      <% if (msg != null) { %>
      <div class="alert alert-<%= msgType.equals("error") ? "danger" : "success" %>" style="margin-bottom:1rem;padding:12px 16px;border-radius:8px;background:<%=msgType.equals("error")?"rgba(248,113,113,.15)":"rgba(52,211,153,.15)"%>;border:1px solid <%=msgType.equals("error")?"rgba(248,113,113,.4)":"rgba(52,211,153,.4)"%>;color:<%=msgType.equals("error")?"#fca5a5":"#6ee7b7"%>;">
        <%= EscapeUtil.escapeHtml(msg) %>
      </div>
      <% } %>

      <div style="display:flex;justify-content:space-between;align-items:center;gap:1rem;flex-wrap:wrap;margin-bottom:1.2rem;">
        <input type="text" id="searchInput" placeholder="도구명, 제공사, 카테고리, 국가 검색..." onkeyup="filterTable()"
               style="padding:10px 16px;border-radius:8px;border:1px solid rgba(255,255,255,.15);background:rgba(255,255,255,.05);color:inherit;width:min(420px,100%);font-size:.9rem;">
        <div style="font-size:.85rem;color:var(--text-secondary);">트렌드/랭크/방문 지표 포함</div>
      </div>

      <section class="admin-table-section">
        <table class="admin-table" id="toolsTable">
          <thead>
            <tr>
              <th>ID</th>
              <th>도구</th>
              <th>국가</th>
              <th>카테고리</th>
              <th>랭크</th>
              <th>트렌드</th>
              <th>성장률</th>
              <th>월 방문</th>
              <th>빠른 랭크 수정</th>
              <th>플래그</th>
              <th>액션</th>
            </tr>
          </thead>
          <tbody>
<%
  try (Connection c = DBConnect.getConnection();
       PreparedStatement ps = c.prepareStatement(
         "SELECT id, tool_name, provider_name, provider_country, category, description, pricing_model, difficulty_level, " +
         "global_rank, trend_score, growth_rate, monthly_visits, monthly_active_users, github_stars, " +
         "api_available, free_tier_available, enterprise_ready, open_source, website_url, docs_url " +
         "FROM ai_tools ORDER BY id DESC");
       ResultSet rs = ps.executeQuery()) {
    boolean empty = true;
    while (rs.next()) {
      empty = false;
      int id = rs.getInt("id");
      String toolName = rs.getString("tool_name");
      String providerName = rs.getString("provider_name");
      String providerCountry = rs.getString("provider_country");
      String category = rs.getString("category");
      String description = rs.getString("description");
      String pricingModel = rs.getString("pricing_model");
      String difficultyLevel = rs.getString("difficulty_level");
      Integer globalRank = (Integer) rs.getObject("global_rank");
      java.math.BigDecimal trendScore = rs.getBigDecimal("trend_score");
      java.math.BigDecimal growthRate = rs.getBigDecimal("growth_rate");
      Long monthlyVisits = (Long) rs.getObject("monthly_visits");
      Long monthlyActiveUsers = (Long) rs.getObject("monthly_active_users");
      Integer githubStars = (Integer) rs.getObject("github_stars");
      boolean apiAvailable = rs.getBoolean("api_available");
      boolean freeTierAvailable = rs.getBoolean("free_tier_available");
      boolean enterpriseReady = rs.getBoolean("enterprise_ready");
      boolean openSource = rs.getBoolean("open_source");
      String websiteUrl = rs.getString("website_url");
      String docsUrl = rs.getString("docs_url");
%>
            <tr>
              <td><%= id %></td>
              <td>
                <strong><%= EscapeUtil.escapeHtml(toolName != null ? toolName : "-") %></strong>
                <div style="font-size:.78rem;color:var(--text-secondary);margin-top:.2rem;"><%= EscapeUtil.escapeHtml(providerName != null ? providerName : "-") %></div>
              </td>
              <td><%= EscapeUtil.escapeHtml(providerCountry != null ? providerCountry : "-") %></td>
              <td>
                <span class="badge badge-info"><%= EscapeUtil.escapeHtml(category != null ? category : "-") %></span>
                <div style="font-size:.78rem;color:var(--text-secondary);margin-top:.2rem;"><%= EscapeUtil.escapeHtml(difficultyLevel != null ? difficultyLevel : "-") %></div>
              </td>
              <td><%= globalRank != null ? "#" + globalRank : "-" %></td>
              <td><%= trendScore != null ? String.format(java.util.Locale.US, "%.1f", trendScore) : "-" %></td>
              <td><%= growthRate != null ? String.format(java.util.Locale.US, "%+.1f%%", growthRate) : "-" %></td>
              <td>
                <%= monthlyVisits != null ? String.format(java.util.Locale.US, "%,d", monthlyVisits) : "-" %>
                <div style="font-size:.78rem;color:var(--text-secondary);margin-top:.2rem;">MAU <%= monthlyActiveUsers != null ? String.format(java.util.Locale.US, "%,d", monthlyActiveUsers) : "-" %></div>
              </td>
              <td>
                <form method="POST" action="/AI/admin/tools/index.jsp" style="display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:6px;min-width:240px;">
                  <input type="hidden" name="action" value="quick_rank">
                  <input type="hidden" name="id" value="<%= id %>">
                  <input class="f-input" type="number" name="global_rank" placeholder="Rank" value="<%= globalRank != null ? globalRank : "" %>">
                  <input class="f-input" type="number" step="0.1" name="trend_score" placeholder="Trend" value="<%= trendScore != null ? trendScore : "" %>">
                  <div style="display:flex;gap:6px;">
                    <input class="f-input" type="number" step="0.1" name="growth_rate" placeholder="Growth" value="<%= growthRate != null ? growthRate : "" %>">
                    <button class="btn btn-sm" type="submit">저장</button>
                  </div>
                </form>
              </td>
              <td>
                <div style="display:flex;gap:.35rem;flex-wrap:wrap;">
                  <% if (apiAvailable) { %><span class="status-badge status-active">API</span><% } %>
                  <% if (freeTierAvailable) { %><span class="status-badge status-pending">FREE</span><% } %>
                  <% if (enterpriseReady) { %><span class="status-badge status-active">ENT</span><% } %>
                  <% if (openSource) { %><span class="status-badge status-inactive">OSS</span><% } %>
                  <% if (githubStars != null) { %><span class="status-badge status-pending">GH <%= githubStars %></span><% } %>
                </div>
              </td>
              <td>
                <div style="display:flex;gap:.4rem;flex-wrap:wrap;">
                  <button class="btn secondary btn-sm"
                    onclick="editTool(
                      <%= id %>,
                      '<%= EscapeUtil.escapeJavaScript(toolName != null ? toolName : "") %>',
                      '<%= EscapeUtil.escapeJavaScript(providerName != null ? providerName : "") %>',
                      '<%= EscapeUtil.escapeJavaScript(providerCountry != null ? providerCountry : "") %>',
                      '<%= EscapeUtil.escapeJavaScript(category != null ? category : "") %>',
                      '<%= EscapeUtil.escapeJavaScript(description != null ? description : "") %>',
                      '<%= EscapeUtil.escapeJavaScript(pricingModel != null ? pricingModel : "") %>',
                      '<%= EscapeUtil.escapeJavaScript(difficultyLevel != null ? difficultyLevel : "") %>',
                      '<%= websiteUrl != null ? EscapeUtil.escapeJavaScript(websiteUrl) : "" %>',
                      '<%= docsUrl != null ? EscapeUtil.escapeJavaScript(docsUrl) : "" %>',
                      '<%= globalRank != null ? globalRank : "" %>',
                      '<%= trendScore != null ? trendScore : "" %>',
                      '<%= growthRate != null ? growthRate : "" %>',
                      '<%= monthlyVisits != null ? monthlyVisits : "" %>',
                      '<%= monthlyActiveUsers != null ? monthlyActiveUsers : "" %>',
                      '<%= githubStars != null ? githubStars : "" %>',
                      <%= apiAvailable %>,
                      <%= freeTierAvailable %>,
                      <%= enterpriseReady %>,
                      <%= openSource %>
                    )">수정</button>
                  <button class="btn danger btn-sm" onclick="confirmDelete(<%= id %>, '<%= EscapeUtil.escapeHtml(toolName != null ? toolName : "") %>')">삭제</button>
                </div>
              </td>
            </tr>
<%
    }
    if (empty) {
%>
            <tr><td colspan="11" style="text-align:center;padding:40px;color:#64748b;">등록된 AI 도구가 없습니다.</td></tr>
<%
    }
  } catch (Exception e) {
%>
            <tr><td colspan="11" style="text-align:center;padding:40px;color:#fca5a5;">데이터 조회 오류: <%= EscapeUtil.escapeHtml(e.getMessage()) %></td></tr>
<% } %>
          </tbody>
        </table>
      </section>

      <section class="admin-table-section" style="margin-top:1.5rem;">
        <header style="display:flex;justify-content:space-between;align-items:center;margin-bottom:1rem;">
          <div>
            <h2 style="margin:0;font-size:1.05rem;">최근 뉴스</h2>
            <p style="margin:.25rem 0 0;color:var(--text-secondary);font-size:.85rem;">최근 등록된 AI 도구 뉴스 5건</p>
          </div>
        </header>
        <table class="admin-table">
          <thead><tr><th>ID</th><th>제목</th><th>유형</th><th>도구 ID</th><th>게시일</th><th>액션</th></tr></thead>
          <tbody>
          <%
            try (Connection c = DBConnect.getConnection();
                 PreparedStatement ps = c.prepareStatement("SELECT id, title, summary, content, source_name, source_url, news_type, tool_id, published_at, is_featured, is_active FROM ai_tool_news ORDER BY published_at DESC LIMIT 8");
                 ResultSet rs = ps.executeQuery()) {
              boolean empty = true;
              while (rs.next()) {
                empty = false;
          %>
            <tr>
              <td><%= rs.getInt("id") %></td>
              <td><%= EscapeUtil.escapeHtml(rs.getString("title")) %></td>
              <td>
                <%= EscapeUtil.escapeHtml(rs.getString("news_type")) %>
                <div style="font-size:.78rem;color:var(--text-secondary);margin-top:.2rem;">
                  <%= rs.getBoolean("is_featured") ? "featured" : "standard" %> · <%= rs.getBoolean("is_active") ? "active" : "inactive" %>
                </div>
              </td>
              <td><%= rs.getObject("tool_id") != null ? rs.getInt("tool_id") : "-" %></td>
              <td><%= rs.getTimestamp("published_at") != null ? rs.getTimestamp("published_at").toString().substring(0,16) : "-" %></td>
              <td>
                <div style="display:flex;gap:6px;flex-wrap:wrap;">
                  <button class="btn secondary btn-sm"
                    onclick="editNews(
                      <%= rs.getInt("id") %>,
                      '<%= rs.getObject("tool_id") != null ? rs.getInt("tool_id") : "" %>',
                      '<%= EscapeUtil.escapeJavaScript(rs.getString("title") != null ? rs.getString("title") : "") %>',
                      '<%= EscapeUtil.escapeJavaScript(rs.getString("summary") != null ? rs.getString("summary") : "") %>',
                      '<%= EscapeUtil.escapeJavaScript(rs.getString("content") != null ? rs.getString("content") : "") %>',
                      '<%= EscapeUtil.escapeJavaScript(rs.getString("news_type") != null ? rs.getString("news_type") : "update") %>',
                      <%= rs.getBoolean("is_featured") %>,
                      '<%= EscapeUtil.escapeJavaScript(rs.getString("source_name") != null ? rs.getString("source_name") : "") %>',
                      '<%= EscapeUtil.escapeJavaScript(rs.getString("source_url") != null ? rs.getString("source_url") : "") %>'
                    )">수정</button>
                  <a class="btn danger btn-sm" href="/AI/admin/tools/index.jsp?deleteNewsId=<%= rs.getInt("id") %>" onclick="return confirm('이 뉴스를 삭제하시겠습니까?');">삭제</a>
                </div>
              </td>
            </tr>
          <% }
             if (empty) { %><tr><td colspan="6" style="text-align:center;padding:2rem;">뉴스가 없습니다.</td></tr><% }
            } catch (Exception e) { %><tr><td colspan="6" style="text-align:center;padding:2rem;color:#fca5a5;">조회 오류</td></tr><% } %>
          </tbody>
        </table>
      </section>

      <section class="admin-table-section" style="margin-top:1.5rem;">
        <header style="display:flex;justify-content:space-between;align-items:center;margin-bottom:1rem;">
          <div>
            <h2 style="margin:0;font-size:1.05rem;">최근 벤치마크</h2>
            <p style="margin:.25rem 0 0;color:var(--text-secondary);font-size:.85rem;">최근 등록된 벤치마크 5건</p>
          </div>
        </header>
        <table class="admin-table">
          <thead><tr><th>ID</th><th>Benchmark</th><th>도구 ID</th><th>점수</th><th>측정일</th><th>액션</th></tr></thead>
          <tbody>
          <%
            try (Connection c = DBConnect.getConnection();
                 PreparedStatement ps = c.prepareStatement("SELECT id, benchmark_name, tool_id, score, max_score, test_date, source, notes FROM ai_tool_benchmarks ORDER BY COALESCE(test_date, CURRENT_DATE) DESC, id DESC LIMIT 8");
                 ResultSet rs = ps.executeQuery()) {
              boolean empty = true;
              while (rs.next()) {
                empty = false;
          %>
            <tr>
              <td><%= rs.getInt("id") %></td>
              <td>
                <%= EscapeUtil.escapeHtml(rs.getString("benchmark_name")) %>
                <div style="font-size:.78rem;color:var(--text-secondary);margin-top:.2rem;"><%= EscapeUtil.escapeHtml(rs.getString("source") != null ? rs.getString("source") : "-") %></div>
              </td>
              <td><%= rs.getInt("tool_id") %></td>
              <td><%= rs.getBigDecimal("score") != null ? rs.getBigDecimal("score") : "-" %><%= rs.getBigDecimal("max_score") != null ? " / " + rs.getBigDecimal("max_score") : "" %></td>
              <td><%= rs.getDate("test_date") != null ? rs.getDate("test_date") : "-" %></td>
              <td>
                <div style="display:flex;gap:6px;flex-wrap:wrap;">
                  <button class="btn secondary btn-sm"
                    onclick="editBenchmark(
                      <%= rs.getInt("id") %>,
                      '<%= rs.getInt("tool_id") %>',
                      '<%= EscapeUtil.escapeJavaScript(rs.getString("benchmark_name") != null ? rs.getString("benchmark_name") : "") %>',
                      '<%= rs.getBigDecimal("score") != null ? rs.getBigDecimal("score") : "" %>',
                      '<%= rs.getBigDecimal("max_score") != null ? rs.getBigDecimal("max_score") : "" %>',
                      '<%= rs.getDate("test_date") != null ? rs.getDate("test_date") : "" %>',
                      '<%= EscapeUtil.escapeJavaScript(rs.getString("source") != null ? rs.getString("source") : "") %>',
                      '<%= EscapeUtil.escapeJavaScript(rs.getString("notes") != null ? rs.getString("notes") : "") %>'
                    )">수정</button>
                  <a class="btn danger btn-sm" href="/AI/admin/tools/index.jsp?deleteBenchmarkId=<%= rs.getInt("id") %>" onclick="return confirm('이 벤치마크를 삭제하시겠습니까?');">삭제</a>
                </div>
              </td>
            </tr>
          <% }
             if (empty) { %><tr><td colspan="6" style="text-align:center;padding:2rem;">벤치마크가 없습니다.</td></tr><% }
            } catch (Exception e) { %><tr><td colspan="6" style="text-align:center;padding:2rem;color:#fca5a5;">조회 오류</td></tr><% } %>
          </tbody>
        </table>
      </section>

    </main>
  </div>
</div>

<div id="bulkModal" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,.7);z-index:9999;align-items:center;justify-content:center;overflow:auto;padding:24px;">
  <div style="background:#1e293b;border:1px solid rgba(255,255,255,.12);border-radius:16px;padding:32px;width:min(860px,95vw);">
    <h3 style="margin-bottom:16px;">도구 일괄 등록</h3>
    <p style="color:#94a3b8;font-size:.9rem;line-height:1.6;margin-bottom:18px;">
      CSV 또는 JSON 배열을 그대로 붙여 넣어 다건 등록합니다. CSV 컬럼 순서:
      <code>tool_name,provider_name,provider_country,category,pricing_model,difficulty_level,website_url,docs_url,description,global_rank,trend_score,growth_rate</code>
    </p>
    <form method="POST" action="/AI/admin/tools/index.jsp">
      <input type="hidden" name="action" value="bulk_import">
      <div style="display:flex;gap:12px;align-items:center;margin-bottom:12px;">
        <label class="f-label" style="margin:0;">포맷</label>
        <select class="f-input" name="bulk_format" style="max-width:160px;">
          <option value="csv">CSV</option>
          <option value="json">JSON</option>
        </select>
      </div>
      <textarea class="f-input" name="bulk_payload" rows="14" style="resize:vertical;font-family:monospace;"
        placeholder='tool_name,provider_name,provider_country,category,pricing_model,difficulty_level,website_url,docs_url,description,global_rank,trend_score,growth_rate&#10;GPT Lab,OpenAI,US,Text Generation,Freemium,Beginner,https://example.com,https://docs.example.com,설명,1,92.5,8.3'></textarea>
      <div style="display:flex;gap:10px;justify-content:flex-end;margin-top:20px;">
        <button type="button" class="btn secondary" onclick="closeModal('bulkModal')">취소</button>
        <button type="submit" class="btn primary">업로드</button>
      </div>
    </form>
  </div>
</div>

<div id="newsModal" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,.7);z-index:9999;align-items:center;justify-content:center;overflow:auto;padding:24px;">
  <div style="background:#1e293b;border:1px solid rgba(255,255,255,.12);border-radius:16px;padding:32px;width:min(860px,95vw);">
    <h3 style="margin-bottom:16px;">뉴스 등록</h3>
    <form method="POST" action="/AI/admin/tools/index.jsp">
      <input type="hidden" name="action" value="create_news" id="newsAction">
      <input type="hidden" name="news_id" id="newsId">
      <div style="display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:12px;">
        <div><label class="f-label">도구 ID</label><input class="f-input" type="number" name="news_tool_id" id="newsToolId"></div>
        <div><label class="f-label">유형</label><select class="f-input" name="news_type" id="newsType"><option>update</option><option>launch</option><option>funding</option><option>comparison</option><option>tutorial</option><option>industry</option></select></div>
        <div style="grid-column:1 / -1;"><label class="f-label">제목</label><input class="f-input" type="text" name="news_title" id="newsTitle" required></div>
        <div style="grid-column:1 / -1;"><label class="f-label">요약</label><textarea class="f-input" name="news_summary" id="newsSummary" rows="2"></textarea></div>
        <div style="grid-column:1 / -1;"><label class="f-label">본문</label><textarea class="f-input" name="news_content" id="newsContent" rows="6"></textarea></div>
        <div><label class="f-label">출처명</label><input class="f-input" type="text" name="news_source_name" id="newsSourceName"></div>
        <div><label class="f-label">출처 URL</label><input class="f-input" type="url" name="news_source_url" id="newsSourceUrl"></div>
      </div>
      <div style="margin-top:12px;"><label><input type="checkbox" name="news_featured" id="newsFeatured"> Featured</label></div>
      <div style="display:flex;gap:10px;justify-content:flex-end;margin-top:20px;"><button type="button" class="btn secondary" onclick="closeModal('newsModal')">취소</button><button type="submit" class="btn primary">등록</button></div>
    </form>
  </div>
</div>

<div id="benchmarkModal" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,.7);z-index:9999;align-items:center;justify-content:center;overflow:auto;padding:24px;">
  <div style="background:#1e293b;border:1px solid rgba(255,255,255,.12);border-radius:16px;padding:32px;width:min(860px,95vw);">
    <h3 style="margin-bottom:16px;">벤치마크 등록</h3>
    <form method="POST" action="/AI/admin/tools/index.jsp">
      <input type="hidden" name="action" value="create_benchmark" id="benchmarkAction">
      <input type="hidden" name="benchmark_id" id="benchmarkId">
      <div style="display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:12px;">
        <div><label class="f-label">도구 ID</label><input class="f-input" type="number" name="benchmark_tool_id" id="benchmarkToolId" required></div>
        <div><label class="f-label">Benchmark 명</label><input class="f-input" type="text" name="benchmark_name" id="benchmarkName" placeholder="MMLU" required></div>
        <div><label class="f-label">점수</label><input class="f-input" type="number" step="0.001" name="benchmark_score" id="benchmarkScore" required></div>
        <div><label class="f-label">최대 점수</label><input class="f-input" type="number" step="0.001" name="benchmark_max_score" id="benchmarkMaxScore"></div>
        <div><label class="f-label">측정일</label><input class="f-input" type="date" name="benchmark_test_date" id="benchmarkTestDate"></div>
        <div><label class="f-label">출처</label><input class="f-input" type="text" name="benchmark_source" id="benchmarkSource"></div>
        <div style="grid-column:1 / -1;"><label class="f-label">노트</label><textarea class="f-input" name="benchmark_notes" id="benchmarkNotes" rows="4"></textarea></div>
      </div>
      <div style="display:flex;gap:10px;justify-content:flex-end;margin-top:20px;"><button type="button" class="btn secondary" onclick="closeModal('benchmarkModal')">취소</button><button type="submit" class="btn primary">등록</button></div>
    </form>
  </div>
</div>

<div id="createModal" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,.7);z-index:9999;align-items:center;justify-content:center;overflow:auto;padding:24px;">
  <div style="background:#1e293b;border:1px solid rgba(255,255,255,.12);border-radius:16px;padding:32px;width:min(820px,95vw);">
    <h3 style="margin-bottom:20px;">AI 도구 추가</h3>
    <form method="POST" action="/AI/admin/tools/index.jsp">
      <input type="hidden" name="action" value="create">
      <div style="display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:14px;">
        <div><label class="f-label">도구명 *</label><input class="f-input" type="text" name="tool_name" required></div>
        <div><label class="f-label">제공사</label><input class="f-input" type="text" name="provider_name"></div>
        <div><label class="f-label">국가 코드</label><input class="f-input" type="text" name="provider_country" placeholder="US, KR, CN"></div>
        <div><label class="f-label">카테고리</label><input class="f-input" type="text" name="category" value="종합 AI 어시스턴트"></div>
        <div><label class="f-label">요금제</label><input class="f-input" type="text" name="pricing_model" value="Freemium"></div>
        <div><label class="f-label">난이도</label><select class="f-input" name="difficulty_level"><option>Beginner</option><option>Intermediate</option><option>Advanced</option></select></div>
        <div><label class="f-label">글로벌 랭크</label><input class="f-input" type="number" name="global_rank"></div>
        <div><label class="f-label">트렌드 점수</label><input class="f-input" type="number" step="0.1" name="trend_score"></div>
        <div><label class="f-label">성장률</label><input class="f-input" type="number" step="0.1" name="growth_rate"></div>
        <div><label class="f-label">월간 방문</label><input class="f-input" type="number" name="monthly_visits"></div>
        <div><label class="f-label">활성 사용자</label><input class="f-input" type="number" name="monthly_active_users"></div>
        <div><label class="f-label">GitHub Stars</label><input class="f-input" type="number" name="github_stars"></div>
        <div><label class="f-label">웹사이트 URL</label><input class="f-input" type="url" name="website_url"></div>
        <div><label class="f-label">문서 URL</label><input class="f-input" type="url" name="docs_url"></div>
      </div>
      <div style="margin-top:14px;">
        <label class="f-label">설명</label>
        <textarea class="f-input" name="description" rows="3" style="resize:vertical;"></textarea>
      </div>
      <div style="display:flex;gap:18px;flex-wrap:wrap;margin-top:14px;">
        <label><input type="checkbox" name="api_available" checked> API 제공</label>
        <label><input type="checkbox" name="free_tier_available"> 무료 플랜</label>
        <label><input type="checkbox" name="enterprise_ready"> Enterprise</label>
        <label><input type="checkbox" name="open_source"> Open Source</label>
      </div>
      <div style="display:flex;gap:10px;justify-content:flex-end;margin-top:20px;">
        <button type="button" class="btn secondary" onclick="closeModal('createModal')">취소</button>
        <button type="submit" class="btn primary">추가</button>
      </div>
    </form>
  </div>
</div>

<div id="editModal" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,.7);z-index:9999;align-items:center;justify-content:center;overflow:auto;padding:24px;">
  <div style="background:#1e293b;border:1px solid rgba(255,255,255,.12);border-radius:16px;padding:32px;width:min(820px,95vw);">
    <h3 style="margin-bottom:20px;">AI 도구 수정</h3>
    <form method="POST" action="/AI/admin/tools/update.jsp">
      <input type="hidden" name="id" id="editId">
      <div style="display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:14px;">
        <div><label class="f-label">도구명 *</label><input class="f-input" type="text" name="tool_name" id="editToolName" required></div>
        <div><label class="f-label">제공사</label><input class="f-input" type="text" name="provider_name" id="editProvider"></div>
        <div><label class="f-label">국가 코드</label><input class="f-input" type="text" name="provider_country" id="editProviderCountry"></div>
        <div><label class="f-label">카테고리</label><input class="f-input" type="text" name="category" id="editCategory"></div>
        <div><label class="f-label">요금제</label><input class="f-input" type="text" name="pricing_model" id="editPricing"></div>
        <div><label class="f-label">난이도</label><select class="f-input" name="difficulty_level" id="editDifficulty"><option>Beginner</option><option>Intermediate</option><option>Advanced</option></select></div>
        <div><label class="f-label">글로벌 랭크</label><input class="f-input" type="number" name="global_rank" id="editGlobalRank"></div>
        <div><label class="f-label">트렌드 점수</label><input class="f-input" type="number" step="0.1" name="trend_score" id="editTrendScore"></div>
        <div><label class="f-label">성장률</label><input class="f-input" type="number" step="0.1" name="growth_rate" id="editGrowthRate"></div>
        <div><label class="f-label">월간 방문</label><input class="f-input" type="number" name="monthly_visits" id="editMonthlyVisits"></div>
        <div><label class="f-label">활성 사용자</label><input class="f-input" type="number" name="monthly_active_users" id="editMonthlyActiveUsers"></div>
        <div><label class="f-label">GitHub Stars</label><input class="f-input" type="number" name="github_stars" id="editGithubStars"></div>
        <div><label class="f-label">웹사이트 URL</label><input class="f-input" type="url" name="website_url" id="editWebsiteUrl"></div>
        <div><label class="f-label">문서 URL</label><input class="f-input" type="url" name="docs_url" id="editDocsUrl"></div>
      </div>
      <div style="margin-top:14px;">
        <label class="f-label">설명</label>
        <textarea class="f-input" name="description" id="editDescription" rows="3" style="resize:vertical;"></textarea>
      </div>
      <div style="display:flex;gap:18px;flex-wrap:wrap;margin-top:16px;">
        <label><input type="checkbox" name="api_available" id="editApiAvailable"> API 제공</label>
        <label><input type="checkbox" name="free_tier_available" id="editFreeTier"> 무료 플랜</label>
        <label><input type="checkbox" name="enterprise_ready" id="editEnterpriseReady"> Enterprise</label>
        <label><input type="checkbox" name="open_source" id="editOpenSource"> Open Source</label>
      </div>
      <div style="display:flex;gap:10px;justify-content:flex-end;margin-top:20px;">
        <button type="button" class="btn secondary" onclick="closeModal('editModal')">취소</button>
        <button type="submit" class="btn primary">저장</button>
      </div>
    </form>
  </div>
</div>

<div id="deleteModal" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,.7);z-index:9999;align-items:center;justify-content:center;">
  <div style="background:#1e293b;border:1px solid rgba(255,255,255,.12);border-radius:16px;padding:32px;width:min(400px,90vw);text-align:center;">
    <i class="bi bi-exclamation-triangle-fill" style="font-size:2.5rem;color:#f59e0b;margin-bottom:16px;display:block;"></i>
    <h3 style="margin-bottom:8px;">삭제 확인</h3>
    <p id="deleteMsg" style="color:#94a3b8;margin-bottom:24px;"></p>
    <div style="display:flex;gap:10px;justify-content:center;">
      <button class="btn secondary" onclick="closeModal('deleteModal')">취소</button>
      <a id="deleteConfirmBtn" class="btn danger">삭제</a>
    </div>
  </div>
</div>

<style>
  .f-label { display:block;font-size:.8125rem;color:#94a3b8;margin-bottom:6px; }
  .f-input { width:100%;padding:10px 14px;border-radius:8px;border:1px solid rgba(255,255,255,.15);background:rgba(255,255,255,.05);color:inherit; }
</style>

<script>
function filterTable() {
  const q = document.getElementById('searchInput').value.toLowerCase();
  document.querySelectorAll('#toolsTable tbody tr').forEach(row => {
    row.style.display = row.textContent.toLowerCase().includes(q) ? '' : 'none';
  });
}

function closeModal(id) {
  document.getElementById(id).style.display = 'none';
}

function confirmDelete(id, name) {
  document.getElementById('deleteMsg').textContent = '"' + name + '"을(를) 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.';
  document.getElementById('deleteConfirmBtn').href = '/AI/admin/tools/index.jsp?deleteId=' + id;
  document.getElementById('deleteModal').style.display = 'flex';
}

function editTool(id, name, provider, country, category, description, pricing, difficulty, websiteUrl, docsUrl, rank, trend, growth, visits, mau, stars, apiAvailable, freeTier, enterpriseReady, openSource) {
  document.getElementById('editId').value = id;
  document.getElementById('editToolName').value = name;
  document.getElementById('editProvider').value = provider;
  document.getElementById('editProviderCountry').value = country;
  document.getElementById('editCategory').value = category;
  document.getElementById('editDescription').value = description;
  document.getElementById('editPricing').value = pricing;
  document.getElementById('editDifficulty').value = difficulty || 'Beginner';
  document.getElementById('editWebsiteUrl').value = websiteUrl;
  document.getElementById('editDocsUrl').value = docsUrl;
  document.getElementById('editGlobalRank').value = rank;
  document.getElementById('editTrendScore').value = trend;
  document.getElementById('editGrowthRate').value = growth;
  document.getElementById('editMonthlyVisits').value = visits;
  document.getElementById('editMonthlyActiveUsers').value = mau;
  document.getElementById('editGithubStars').value = stars;
  document.getElementById('editApiAvailable').checked = apiAvailable;
  document.getElementById('editFreeTier').checked = freeTier;
  document.getElementById('editEnterpriseReady').checked = enterpriseReady;
  document.getElementById('editOpenSource').checked = openSource;
  document.getElementById('editModal').style.display = 'flex';
}

function editNews(id, toolId, title, summary, content, type, featured, sourceName, sourceUrl) {
  document.getElementById('newsAction').value = 'update_news';
  document.getElementById('newsId').value = id;
  document.getElementById('newsToolId').value = toolId || '';
  document.getElementById('newsTitle').value = title || '';
  document.getElementById('newsSummary').value = summary || '';
  document.getElementById('newsContent').value = content || '';
  document.getElementById('newsType').value = type || 'update';
  document.getElementById('newsFeatured').checked = !!featured;
  document.getElementById('newsSourceName').value = sourceName || '';
  document.getElementById('newsSourceUrl').value = sourceUrl || '';
  document.getElementById('newsModal').style.display = 'flex';
}

function editBenchmark(id, toolId, name, score, maxScore, testDate, source, notes) {
  document.getElementById('benchmarkAction').value = 'update_benchmark';
  document.getElementById('benchmarkId').value = id;
  document.getElementById('benchmarkToolId').value = toolId || '';
  document.getElementById('benchmarkName').value = name || '';
  document.getElementById('benchmarkScore').value = score || '';
  document.getElementById('benchmarkMaxScore').value = maxScore || '';
  document.getElementById('benchmarkTestDate').value = testDate || '';
  document.getElementById('benchmarkSource').value = source || '';
  document.getElementById('benchmarkNotes').value = notes || '';
  document.getElementById('benchmarkModal').style.display = 'flex';
}

['createModal','editModal','deleteModal','bulkModal','newsModal','benchmarkModal'].forEach(id => {
  document.getElementById(id).addEventListener('click', function(e) {
    if (e.target === this) this.style.display = 'none';
  });
});
</script>

<jsp:include page="/AI/admin/layout/footer.jspf"/>
