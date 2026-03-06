<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.AIToolDAO" %>
<%@ page import="dao.LabProjectDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.sql.*" %>
<%@ page import="db.DBConnect" %>
<%
  if (session.getAttribute("admin") == null) {
    response.sendRedirect("/AI/admin/auth/login.jsp");
    return;
  }

  String adminRole = (String) session.getAttribute("adminRole");
  boolean isSuperadmin = "superadmin".equals(adminRole) || "SUPER".equals(adminRole);

  int toolCount = 0, projectCount = 0, userCount = 0, subscriberCount = 0;
  String topCategory = "-";
  try (Connection c = DBConnect.getConnection()) {
    try (PreparedStatement ps = c.prepareStatement("SELECT COUNT(*) FROM ai_tools");
         ResultSet rs = ps.executeQuery()) {
      if (rs.next()) toolCount = rs.getInt(1);
    }
    try (PreparedStatement ps = c.prepareStatement("SELECT COUNT(*) FROM lab_projects");
         ResultSet rs = ps.executeQuery()) {
      if (rs.next()) projectCount = rs.getInt(1);
    }
    try (PreparedStatement ps = c.prepareStatement("SELECT COUNT(*) FROM users WHERE is_active = 1");
         ResultSet rs = ps.executeQuery()) {
      if (rs.next()) userCount = rs.getInt(1);
    }
    try (PreparedStatement ps = c.prepareStatement(
           "SELECT COUNT(*) FROM users WHERE experience_level IS NOT NULL AND is_active = 1");
         ResultSet rs = ps.executeQuery()) {
      if (rs.next()) subscriberCount = rs.getInt(1);
    }
    try (PreparedStatement ps = c.prepareStatement(
           "SELECT category, COUNT(*) AS cnt FROM ai_tools GROUP BY category ORDER BY cnt DESC LIMIT 1");
         ResultSet rs = ps.executeQuery()) {
      if (rs.next()) topCategory = rs.getString("category");
    }
  } catch (Exception e) { /* 기본값 유지 */ }
%>
<%@ include file="/AI/admin/layout/header.jspf" %>
<div class="admin-layout">
  <%@ include file="/AI/admin/layout/sidebar.jspf" %>
  <div class="admin-main-wrapper">
    <%@ include file="/AI/admin/layout/topbar.jspf" %>
    <main class="admin-content">

      <header class="admin-dashboard-header" style="margin-bottom:2rem;">
        <h1>AI Workflow Lab 대시보드</h1>
        <p>플랫폼 콘텐츠 현황을 한눈에 확인하세요.</p>
      </header>

      <!-- KPI 카드 -->
      <section class="kpi-grid">
        <article class="kpi-card kpi-tools">
          <div class="kpi-icon"><i class="bi bi-cpu-fill"></i></div>
          <div class="kpi-body">
            <span class="kpi-label">AI 도구</span>
            <span class="kpi-value"><%= toolCount %></span>
            <span class="kpi-desc">등록된 AI 도구 수</span>
          </div>
        </article>
        <article class="kpi-card kpi-lab">
          <div class="kpi-icon"><i class="bi bi-flask-fill"></i></div>
          <div class="kpi-body">
            <span class="kpi-label">실습 프로젝트</span>
            <span class="kpi-value"><%= projectCount %></span>
            <span class="kpi-desc">등록된 랩 프로젝트 수</span>
          </div>
        </article>
        <article class="kpi-card kpi-users">
          <div class="kpi-icon"><i class="bi bi-people-fill"></i></div>
          <div class="kpi-body">
            <span class="kpi-label">활성 사용자</span>
            <span class="kpi-value"><%= userCount %></span>
            <span class="kpi-desc">is_active 회원 수</span>
          </div>
        </article>
        <article class="kpi-card kpi-category">
          <div class="kpi-icon"><i class="bi bi-grid-3x3-gap-fill"></i></div>
          <div class="kpi-body">
            <span class="kpi-label">인기 카테고리</span>
            <span class="kpi-value kpi-value-sm"><%= topCategory %></span>
            <span class="kpi-desc">AI 도구 최다 카테고리</span>
          </div>
        </article>
      </section>

      <!-- 빠른 관리 -->
      <section class="admin-notice" style="margin-bottom:2.5rem;">
        <h2 style="margin-bottom:1.25rem;">빠른 관리</h2>
        <div class="quick-links-grid">
          <a class="quick-link-card quick-primary" href="/AI/admin/tools/index.jsp">
            <i class="bi bi-cpu"></i>
            <span>AI 도구 관리</span>
          </a>
          <a class="quick-link-card" href="/AI/admin/lab/index.jsp">
            <i class="bi bi-flask"></i>
            <span>실습 랩 관리</span>
          </a>
          <a class="quick-link-card" href="/AI/admin/users/index.jsp">
            <i class="bi bi-people"></i>
            <span>사용자 관리</span>
          </a>
          <a class="quick-link-card" href="/AI/admin/packages/index.jsp">
            <i class="bi bi-credit-card"></i>
            <span>구독 플랜</span>
          </a>
          <a class="quick-link-card" href="/AI/admin/categories/index.jsp">
            <i class="bi bi-folder2-open"></i>
            <span>카테고리</span>
          </a>
          <% if (isSuperadmin) { %>
          <a class="quick-link-card" href="/AI/admin/admins/index.jsp">
            <i class="bi bi-shield-lock"></i>
            <span>관리자 관리</span>
          </a>
          <% } %>
        </div>
      </section>

      <!-- 최근 등록 AI 도구 -->
      <section style="margin-bottom:2.5rem;background:var(--glass-bg);backdrop-filter:blur(20px);border:1px solid var(--glass-border);border-radius:var(--radius-xl);padding:var(--spacing-xl);">
        <header style="display:flex;justify-content:space-between;align-items:center;margin-bottom:1.25rem;">
          <div>
            <h2 style="margin:0;">최근 등록된 AI 도구</h2>
            <p style="margin:.25rem 0 0;font-size:.85rem;color:var(--text-secondary);">최근 추가된 AI 도구 5개</p>
          </div>
          <a class="btn" href="/AI/admin/tools/index.jsp" style="padding:6px 14px;font-size:.85rem;">전체 보기</a>
        </header>
        <div class="admin-table-section">
          <table class="admin-table">
            <thead>
              <tr><th>도구명</th><th>카테고리</th><th>난이도</th><th>평점</th><th>상태</th></tr>
            </thead>
            <tbody>
              <%
                try (Connection c2 = DBConnect.getConnection();
                     PreparedStatement ps2 = c2.prepareStatement(
                       "SELECT name, category, difficulty_level, rating, is_active FROM ai_tools ORDER BY created_at DESC LIMIT 5");
                     ResultSet rs2 = ps2.executeQuery()) {
                  int rowCount = 0;
                  while (rs2.next()) {
                    rowCount++;
              %>
              <tr>
                <td><strong><%= rs2.getString("name") != null ? rs2.getString("name") : "-" %></strong></td>
                <td><%= rs2.getString("category") != null ? rs2.getString("category") : "-" %></td>
                <td><%= rs2.getString("difficulty_level") != null ? rs2.getString("difficulty_level") : "-" %></td>
                <td><i class="bi bi-star-fill" style="color:#f59e0b;margin-right:3px;"></i><%= rs2.getObject("rating") != null ? String.format("%.1f", rs2.getDouble("rating")) : "-" %></td>
                <td><span class="status-badge <%= rs2.getBoolean("is_active") ? "status-active" : "status-inactive" %>">
                  <%= rs2.getBoolean("is_active") ? "활성" : "비활성" %>
                </span></td>
              </tr>
              <%
                  }
                  if (rowCount == 0) {
              %>
              <tr><td colspan="5" style="text-align:center;color:var(--text-secondary);padding:2rem;">등록된 AI 도구가 없습니다.</td></tr>
              <% } } catch (Exception e2) { %>
              <tr><td colspan="5" style="text-align:center;color:var(--text-secondary);padding:2rem;">데이터를 불러올 수 없습니다.</td></tr>
              <% } %>
            </tbody>
          </table>
        </div>
      </section>

      <!-- 최근 등록 실습 프로젝트 -->
      <section style="margin-bottom:2.5rem;background:var(--glass-bg);backdrop-filter:blur(20px);border:1px solid var(--glass-border);border-radius:var(--radius-xl);padding:var(--spacing-xl);">
        <header style="display:flex;justify-content:space-between;align-items:center;margin-bottom:1.25rem;">
          <div>
            <h2 style="margin:0;">최근 등록된 실습 프로젝트</h2>
            <p style="margin:.25rem 0 0;font-size:.85rem;color:var(--text-secondary);">최근 추가된 랩 프로젝트 5개</p>
          </div>
          <a class="btn" href="/AI/admin/lab/index.jsp" style="padding:6px 14px;font-size:.85rem;">전체 보기</a>
        </header>
        <div class="admin-table-section">
          <table class="admin-table">
            <thead>
              <tr><th>프로젝트명</th><th>카테고리</th><th>난이도</th><th>유형</th><th>예상 시간</th></tr>
            </thead>
            <tbody>
              <%
                try (Connection c3 = DBConnect.getConnection();
                     PreparedStatement ps3 = c3.prepareStatement(
                       "SELECT title, category, difficulty_level, project_type, estimated_duration_hours FROM lab_projects ORDER BY created_at DESC LIMIT 5");
                     ResultSet rs3 = ps3.executeQuery()) {
                  int rowCount3 = 0;
                  while (rs3.next()) {
                    rowCount3++;
              %>
              <tr>
                <td><strong><%= rs3.getString("title") != null ? rs3.getString("title") : "-" %></strong></td>
                <td><%= rs3.getString("category") != null ? rs3.getString("category") : "-" %></td>
                <td><%= rs3.getString("difficulty_level") != null ? rs3.getString("difficulty_level") : "-" %></td>
                <td><%= rs3.getString("project_type") != null ? rs3.getString("project_type") : "-" %></td>
                <td><%= rs3.getObject("estimated_duration_hours") != null ? rs3.getDouble("estimated_duration_hours") + "h" : "-" %></td>
              </tr>
              <%
                  }
                  if (rowCount3 == 0) {
              %>
              <tr><td colspan="5" style="text-align:center;color:var(--text-secondary);padding:2rem;">등록된 프로젝트가 없습니다.</td></tr>
              <% } } catch (Exception e3) { %>
              <tr><td colspan="5" style="text-align:center;color:var(--text-secondary);padding:2rem;">데이터를 불러올 수 없습니다.</td></tr>
              <% } %>
            </tbody>
          </table>
        </div>
      </section>

      <% if (isSuperadmin) { %>
      <section style="margin-bottom:2rem;background:var(--glass-bg);backdrop-filter:blur(20px);border:1px solid var(--glass-border);border-radius:var(--radius-xl);padding:var(--spacing-xl);">
        <header style="margin-bottom:1.5rem;">
          <h2>Superadmin 요청 대기열</h2>
          <p>관리자 생성 요청을 승인하거나 거절하세요.</p>
        </header>
        <div id="superadminQueueFeedback" class="admin-queue-feedback" aria-live="polite"></div>
        <div class="admin-table-section" style="margin-top:1.5rem;">
          <table class="admin-table">
            <thead>
              <tr><th>요청자</th><th>아이디</th><th>역할</th><th>권한</th><th>상태</th><th>액션</th></tr>
            </thead>
            <tbody id="requestQueueBody"></tbody>
          </table>
          <p id="requestQueueEmpty" class="admin-queue-empty">현재 대기 중인 요청이 없습니다.</p>
        </div>
      </section>
      <% } %>

<%@ include file="/AI/admin/layout/footer.jspf" %>
