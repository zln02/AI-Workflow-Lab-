<%@ page contentType="text/html; charset=UTF-8" isELIgnored="true" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="db.DBConnect" %>
<%@ page import="util.EscapeUtil" %>
<%!
  private String formatAdminTimestamp(Object value) {
    return value == null ? "-" : new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(value);
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

  if ("POST".equals(request.getMethod()) && "update".equals(request.getParameter("action"))) {
    String idParam = request.getParameter("id");
    if (idParam != null && idParam.matches("\\d+")) {
      try (Connection c = DBConnect.getConnection();
           PreparedStatement ps = c.prepareStatement(
             "UPDATE agent_templates SET name=?, description=?, system_prompt=?, output_schema_json=?, badge_label=?, suggested_goal=?, is_active=? WHERE id=?")) {
        ps.setString(1, request.getParameter("name"));
        ps.setString(2, request.getParameter("description"));
        ps.setString(3, request.getParameter("system_prompt"));
        ps.setString(4, request.getParameter("output_schema_json"));
        ps.setString(5, request.getParameter("badge_label"));
        ps.setString(6, request.getParameter("suggested_goal"));
        ps.setBoolean(7, "on".equals(request.getParameter("is_active")));
        ps.setInt(8, Integer.parseInt(idParam));
        ps.executeUpdate();
        msg = "에이전트 템플릿이 업데이트되었습니다.";
      } catch (Exception e) {
        msg = "업데이트 실패: " + e.getMessage();
        msgType = "error";
      }
    }
  }

  if ("POST".equals(request.getMethod()) && "create".equals(request.getParameter("action"))) {
    try (Connection c = DBConnect.getConnection();
         PreparedStatement ps = c.prepareStatement(
           "INSERT INTO agent_templates (code, name, description, system_prompt, output_schema_json, badge_label, suggested_goal, is_active) VALUES (?,?,?,?,?,?,?,?)")) {
      ps.setString(1, request.getParameter("code"));
      ps.setString(2, request.getParameter("name"));
      ps.setString(3, request.getParameter("description"));
      ps.setString(4, request.getParameter("system_prompt"));
      ps.setString(5, request.getParameter("output_schema_json"));
      ps.setString(6, request.getParameter("badge_label"));
      ps.setString(7, request.getParameter("suggested_goal"));
      ps.setBoolean(8, "on".equals(request.getParameter("is_active")));
      ps.executeUpdate();
      msg = "새 에이전트 템플릿이 추가되었습니다.";
    } catch (Exception e) {
      msg = "추가 실패: " + e.getMessage();
      msgType = "error";
    }
  }

  List<Map<String, Object>> templates = new ArrayList<>();
  List<Map<String, Object>> recentRuns = new ArrayList<>();
  int activeCount = 0;
  int runCount = 0;
  try (Connection c = DBConnect.getConnection()) {
    try (PreparedStatement ps = c.prepareStatement("SELECT COUNT(*) FROM agent_templates WHERE is_active = 1");
         ResultSet rs = ps.executeQuery()) {
      if (rs.next()) activeCount = rs.getInt(1);
    }
    try (PreparedStatement ps = c.prepareStatement("SELECT COUNT(*) FROM agent_runs");
         ResultSet rs = ps.executeQuery()) {
      if (rs.next()) runCount = rs.getInt(1);
    }
    try (PreparedStatement ps = c.prepareStatement("SELECT * FROM agent_templates ORDER BY id ASC");
         ResultSet rs = ps.executeQuery()) {
      while (rs.next()) {
        Map<String, Object> row = new HashMap<>();
        row.put("id", rs.getInt("id"));
        row.put("code", rs.getString("code"));
        row.put("name", rs.getString("name"));
        row.put("description", rs.getString("description"));
        row.put("system_prompt", rs.getString("system_prompt"));
        row.put("output_schema_json", rs.getString("output_schema_json"));
        row.put("badge_label", rs.getString("badge_label"));
        row.put("suggested_goal", rs.getString("suggested_goal"));
        row.put("is_active", rs.getBoolean("is_active"));
        row.put("created_at", rs.getTimestamp("created_at"));
        templates.add(row);
      }
    }
    try (PreparedStatement ps = c.prepareStatement(
        "SELECT ar.id, ar.title, ar.user_goal, ar.created_at, at.name AS template_name, at.code AS template_code " +
        "FROM agent_runs ar LEFT JOIN agent_templates at ON at.id = ar.template_id " +
        "ORDER BY ar.created_at DESC LIMIT 8");
         ResultSet rs = ps.executeQuery()) {
      while (rs.next()) {
        Map<String, Object> row = new HashMap<>();
        row.put("id", rs.getInt("id"));
        row.put("title", rs.getString("title"));
        row.put("user_goal", rs.getString("user_goal"));
        row.put("template_name", rs.getString("template_name"));
        row.put("template_code", rs.getString("template_code"));
        row.put("created_at", rs.getTimestamp("created_at"));
        recentRuns.add(row);
      }
    }
  } catch (Exception e) {
    if (msg == null) {
      msg = "데이터를 불러오지 못했습니다: " + e.getMessage();
      msgType = "error";
    }
  }

%>
<%@ include file="/AI/admin/layout/header.jspf" %>
<div class="admin-layout">
  <%@ include file="/AI/admin/layout/sidebar.jspf" %>
  <div class="admin-main-wrapper">
    <%@ include file="/AI/admin/layout/topbar.jspf" %>
    <main class="admin-content">
      <section class="page-hero" style="margin-bottom:24px;">
        <div>
          <div class="eyebrow" style="color:#7dd3fc;font-size:.78rem;font-weight:800;letter-spacing:.12em;text-transform:uppercase;">Agent Admin</div>
          <h1 style="margin:8px 0 10px;font-size:2rem;font-weight:800;">에이전트 템플릿 관리</h1>
          <p style="margin:0;color:#94a3b8;max-width:760px;">Super Agent Lite에서 사용하는 템플릿, 시스템 프롬프트, 추천 목표를 여기서 관리합니다.</p>
        </div>
      </section>

      <% if (msg != null) { %>
      <div class="dashboard-alert <%= "error".equals(msgType) ? "dashboard-alert--error" : "" %>" style="margin-bottom:18px;">
        <%= EscapeUtil.escapeHtml(msg) %>
      </div>
      <% } %>

      <section class="stats-grid" style="margin-bottom:18px;">
        <article class="stat-card">
          <div class="stat-card__icon"><i class="bi bi-stars"></i></div>
          <div class="stat-card__label">전체 템플릿</div>
          <div class="stat-card__value"><%= templates.size() %></div>
        </article>
        <article class="stat-card">
          <div class="stat-card__icon"><i class="bi bi-check2-circle"></i></div>
          <div class="stat-card__label">활성 템플릿</div>
          <div class="stat-card__value"><%= activeCount %></div>
        </article>
        <article class="stat-card">
          <div class="stat-card__icon"><i class="bi bi-lightning-charge"></i></div>
          <div class="stat-card__label">누적 실행</div>
          <div class="stat-card__value"><%= runCount %></div>
        </article>
      </section>

      <section class="content-grid" style="display:grid;grid-template-columns:1.3fr .7fr;gap:18px;">
        <div class="glass-panel">
          <div class="panel-header">
            <h2>템플릿 목록</h2>
            <span class="panel-subtext">수정 후 바로 저장됩니다.</span>
          </div>
          <div class="panel-body" style="display:grid;gap:16px;">
            <% for (Map<String, Object> item : templates) { %>
            <form method="post" action="/AI/admin/agents/index.jsp" class="admin-form-card" style="display:grid;gap:12px;padding:18px;border:1px solid rgba(255,255,255,.08);border-radius:18px;background:rgba(255,255,255,.03);">
              <input type="hidden" name="action" value="update">
              <input type="hidden" name="id" value="<%= item.get("id") %>">
              <div style="display:flex;justify-content:space-between;gap:12px;align-items:flex-start;flex-wrap:wrap;">
                <div>
                  <div style="font-size:1rem;font-weight:800;"><%= EscapeUtil.escapeHtml(String.valueOf(item.get("name"))) %></div>
                  <div style="color:#94a3b8;font-size:.8rem;"><%= EscapeUtil.escapeHtml(String.valueOf(item.get("code"))) %> · 생성 <%= formatAdminTimestamp(item.get("created_at")) %></div>
                </div>
                <label style="display:flex;align-items:center;gap:8px;color:#dbeafe;font-size:.82rem;font-weight:700;">
                  <input type="checkbox" name="is_active" <%= Boolean.TRUE.equals(item.get("is_active")) ? "checked" : "" %>>
                  활성
                </label>
              </div>
              <div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:12px;">
                <div class="form-field">
                  <label>코드</label>
                  <input type="text" name="code" value="<%= EscapeUtil.escapeHtml(String.valueOf(item.get("code"))) %>" disabled>
                </div>
                <div class="form-field">
                  <label>배지</label>
                  <input type="text" name="badge_label" value="<%= EscapeUtil.escapeHtml(String.valueOf(item.get("badge_label") != null ? item.get("badge_label") : "")) %>">
                </div>
                <div class="form-field">
                  <label>이름</label>
                  <input type="text" name="name" value="<%= EscapeUtil.escapeHtml(String.valueOf(item.get("name"))) %>">
                </div>
              </div>
              <div class="form-field">
                <label>설명</label>
                <textarea name="description" rows="2"><%= EscapeUtil.escapeHtml(String.valueOf(item.get("description") != null ? item.get("description") : "")) %></textarea>
              </div>
              <div class="form-field">
                <label>추천 목표</label>
                <input type="text" name="suggested_goal" value="<%= EscapeUtil.escapeHtml(String.valueOf(item.get("suggested_goal") != null ? item.get("suggested_goal") : "")) %>">
              </div>
              <div class="form-field">
                <label>시스템 프롬프트</label>
                <textarea name="system_prompt" rows="5"><%= EscapeUtil.escapeHtml(String.valueOf(item.get("system_prompt") != null ? item.get("system_prompt") : "")) %></textarea>
              </div>
              <div class="form-field">
                <label>출력 스키마 JSON</label>
                <textarea name="output_schema_json" rows="3"><%= EscapeUtil.escapeHtml(String.valueOf(item.get("output_schema_json") != null ? item.get("output_schema_json") : "")) %></textarea>
              </div>
              <div>
                <button type="submit" class="btn-primary"><i class="bi bi-save"></i>저장</button>
              </div>
            </form>
            <% } %>
          </div>
        </div>

        <div style="display:grid;gap:18px;">
          <div class="glass-panel">
            <div class="panel-header">
              <h2>새 템플릿 추가</h2>
            </div>
            <div class="panel-body">
              <form method="post" action="/AI/admin/agents/index.jsp" style="display:grid;gap:12px;">
                <input type="hidden" name="action" value="create">
                <div class="form-field">
                  <label>코드</label>
                  <input type="text" name="code" placeholder="예: report-builder" required>
                </div>
                <div class="form-field">
                  <label>이름</label>
                  <input type="text" name="name" placeholder="예: 보고서 작성 에이전트" required>
                </div>
                <div class="form-field">
                  <label>배지</label>
                  <input type="text" name="badge_label" placeholder="예: Report">
                </div>
                <div class="form-field">
                  <label>설명</label>
                  <textarea name="description" rows="2" required></textarea>
                </div>
                <div class="form-field">
                  <label>추천 목표</label>
                  <input type="text" name="suggested_goal">
                </div>
                <div class="form-field">
                  <label>시스템 프롬프트</label>
                  <textarea name="system_prompt" rows="6" required></textarea>
                </div>
                <div class="form-field">
                  <label>출력 스키마 JSON</label>
                  <textarea name="output_schema_json" rows="3"></textarea>
                </div>
                <label style="display:flex;align-items:center;gap:8px;color:#dbeafe;font-size:.82rem;font-weight:700;">
                  <input type="checkbox" name="is_active" checked>
                  생성 즉시 활성화
                </label>
                <button type="submit" class="btn-primary"><i class="bi bi-plus-circle"></i>템플릿 추가</button>
              </form>
            </div>
          </div>

          <div class="glass-panel">
            <div class="panel-header">
              <h2>최근 실행</h2>
            </div>
            <div class="panel-body" style="display:grid;gap:12px;">
              <% if (recentRuns.isEmpty()) { %>
              <div class="empty-state">아직 저장된 에이전트 실행이 없습니다.</div>
              <% } else { %>
                <% for (Map<String, Object> run : recentRuns) { %>
                <div style="padding:14px;border:1px solid rgba(255,255,255,.08);border-radius:16px;background:rgba(255,255,255,.03);">
                  <div style="font-size:.92rem;font-weight:800;"><%= EscapeUtil.escapeHtml(String.valueOf(run.get("title"))) %></div>
                  <div style="color:#94a3b8;font-size:.78rem;margin:6px 0 8px;"><%= EscapeUtil.escapeHtml(String.valueOf(run.get("template_name") != null ? run.get("template_name") : "-")) %> · <%= formatAdminTimestamp(run.get("created_at")) %></div>
                  <div style="color:#cbd5e1;font-size:.82rem;line-height:1.65;"><%= EscapeUtil.escapeHtml(String.valueOf(run.get("user_goal") != null ? run.get("user_goal") : "")) %></div>
                </div>
                <% } %>
              <% } %>
            </div>
          </div>
        </div>
      </section>
    </main>
    <%@ include file="/AI/admin/layout/footer.jspf" %>
  </div>
</div>
<%@ include file="/AI/admin/layout/scripts.jspf" %>
</body>
</html>
