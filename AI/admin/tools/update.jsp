<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="db.DBConnect" %>
<%
  if (session.getAttribute("admin") == null) {
    response.sendRedirect("/AI/admin/auth/login.jsp");
    return;
  }
  request.setCharacterEncoding("UTF-8");

  String id = request.getParameter("id");
  String toolName = request.getParameter("tool_name");
  String provider = request.getParameter("provider_name");
  String providerCountry = request.getParameter("provider_country");
  String category = request.getParameter("category");
  String description = request.getParameter("description");
  String pricing = request.getParameter("pricing_model");
  String difficulty = request.getParameter("difficulty_level");
  String websiteUrl = request.getParameter("website_url");
  String docsUrl = request.getParameter("docs_url");
  String globalRank = request.getParameter("global_rank");
  String trendScore = request.getParameter("trend_score");
  String growthRate = request.getParameter("growth_rate");
  String monthlyVisits = request.getParameter("monthly_visits");
  String monthlyActiveUsers = request.getParameter("monthly_active_users");
  String githubStars = request.getParameter("github_stars");
  boolean apiAvailable = "on".equals(request.getParameter("api_available"));
  boolean freeTierAvailable = "on".equals(request.getParameter("free_tier_available"));
  boolean enterpriseReady = "on".equals(request.getParameter("enterprise_ready"));
  boolean openSource = "on".equals(request.getParameter("open_source"));

  if (id != null && id.matches("\\d+") && toolName != null && !toolName.trim().isEmpty()) {
    try (Connection c = DBConnect.getConnection();
         PreparedStatement ps = c.prepareStatement(
           "UPDATE ai_tools SET " +
           "tool_name=?, provider_name=?, provider_country=?, category=?, description=?, pricing_model=?, difficulty_level=?, " +
           "website_url=?, docs_url=?, api_available=?, free_tier_available=?, enterprise_ready=?, open_source=?, " +
           "global_rank=?, trend_score=?, growth_rate=?, monthly_visits=?, monthly_active_users=?, github_stars=?, " +
           "updated_at=CURRENT_TIMESTAMP WHERE id=?")) {
      ps.setString(1, toolName.trim());
      ps.setString(2, provider != null ? provider.trim() : "");
      ps.setString(3, providerCountry != null && !providerCountry.trim().isEmpty() ? providerCountry.trim() : null);
      ps.setString(4, category != null ? category.trim() : "기타");
      ps.setString(5, description != null ? description.trim() : "");
      ps.setString(6, pricing != null ? pricing.trim() : "Free");
      ps.setString(7, difficulty != null ? difficulty.trim() : "Beginner");
      ps.setString(8, websiteUrl != null && !websiteUrl.trim().isEmpty() ? websiteUrl.trim() : null);
      ps.setString(9, docsUrl != null && !docsUrl.trim().isEmpty() ? docsUrl.trim() : null);
      ps.setBoolean(10, apiAvailable);
      ps.setBoolean(11, freeTierAvailable);
      ps.setBoolean(12, enterpriseReady);
      ps.setBoolean(13, openSource);
      if (globalRank != null && !globalRank.trim().isEmpty()) ps.setInt(14, Integer.parseInt(globalRank.trim())); else ps.setNull(14, Types.INTEGER);
      if (trendScore != null && !trendScore.trim().isEmpty()) ps.setBigDecimal(15, new java.math.BigDecimal(trendScore.trim())); else ps.setNull(15, Types.DECIMAL);
      if (growthRate != null && !growthRate.trim().isEmpty()) ps.setBigDecimal(16, new java.math.BigDecimal(growthRate.trim())); else ps.setNull(16, Types.DECIMAL);
      if (monthlyVisits != null && !monthlyVisits.trim().isEmpty()) ps.setLong(17, Long.parseLong(monthlyVisits.trim())); else ps.setNull(17, Types.BIGINT);
      if (monthlyActiveUsers != null && !monthlyActiveUsers.trim().isEmpty()) ps.setLong(18, Long.parseLong(monthlyActiveUsers.trim())); else ps.setNull(18, Types.BIGINT);
      if (githubStars != null && !githubStars.trim().isEmpty()) ps.setInt(19, Integer.parseInt(githubStars.trim())); else ps.setNull(19, Types.INTEGER);
      ps.setInt(20, Integer.parseInt(id));
      ps.executeUpdate();
    } catch (Exception e) {
      e.printStackTrace();
    }
  }
  response.sendRedirect("/AI/admin/tools/index.jsp");
%>
