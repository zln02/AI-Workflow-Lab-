<%@ page contentType="text/html; charset=UTF-8" isELIgnored="true" %>
<%@ page import="java.sql.*" %>
<%@ page import="db.DBConnect" %>
<%@ page import="util.EscapeUtil" %>
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
         PreparedStatement ps = c.prepareStatement("DELETE FROM lab_projects WHERE id=?")) {
      ps.setInt(1, Integer.parseInt(deleteId));
      ps.executeUpdate();
      msg = "실습 프로젝트가 삭제되었습니다.";
    } catch (Exception e) { msg = "삭제 실패: " + e.getMessage(); msgType = "error"; }
  }

  if ("POST".equals(request.getMethod()) && "create".equals(request.getParameter("action"))) {
    String title = request.getParameter("title");
    String category = request.getParameter("category");
    String difficulty = request.getParameter("difficulty_level");
    String description = request.getParameter("description");
    if (title != null && !title.trim().isEmpty()) {
      try (Connection c = DBConnect.getConnection();
           PreparedStatement ps = c.prepareStatement(
             "INSERT INTO lab_projects (title, category, difficulty_level, description, is_active) VALUES (?,?,?,?,1)")) {
        ps.setString(1, title.trim());
        ps.setString(2, category != null ? category.trim() : "기타");
        ps.setString(3, difficulty != null ? difficulty : "Beginner");
        ps.setString(4, description != null ? description.trim() : "");
        ps.executeUpdate();
        msg = "실습 프로젝트가 추가되었습니다.";
      } catch (Exception e) { msg = "추가 실패: " + e.getMessage(); msgType = "error"; }
    }
  }
%>
<%@ include file="/AI/admin/layout/header.jspf" %>
<div class="admin-layout">
  <%@ include file="/AI/admin/layout/sidebar.jspf" %>
  <div class="admin-main-wrapper">
    <%@ include file="/AI/admin/layout/topbar.jspf" %>
    <main class="admin-content">

      <header class="admin-dashboard-header">
        <div style="display:flex;justify-content:space-between;align-items:center;">
          <div>
            <h1>실습 랩 관리</h1>
            <p>실습 프로젝트를 조회하고 관리합니다.</p>
          </div>
          <button class="btn primary" onclick="document.getElementById('createModal').style.display='flex'">+ 프로젝트 추가</button>
        </div>
      </header>

      <% if (msg != null) { %>
      <div style="margin-bottom:1rem;padding:12px 16px;border-radius:8px;background:<%=msgType.equals("error")?"rgba(248,113,113,.15)":"rgba(52,211,153,.15)"%>;border:1px solid <%=msgType.equals("error")?"rgba(248,113,113,.4)":"rgba(52,211,153,.4)"%>;color:<%=msgType.equals("error")?"#fca5a5":"#6ee7b7"%>;">
        <%= EscapeUtil.escapeHtml(msg) %>
      </div>
      <% } %>

      <div style="margin-bottom:1.2rem;">
        <input type="text" id="searchInput" placeholder="프로젝트명, 카테고리 검색..."
               onkeyup="filterTable()"
               style="padding:10px 16px;border-radius:8px;border:1px solid rgba(255,255,255,.15);background:rgba(255,255,255,.05);color:inherit;width:300px;font-size:.9rem;">
      </div>

      <section class="admin-table-section">
        <table class="admin-table" id="labTable">
          <thead>
            <tr>
              <th>ID</th>
              <th>프로젝트명</th>
              <th>카테고리</th>
              <th>난이도</th>
              <th>유형</th>
              <th>참가자</th>
              <th>상태</th>
              <th>액션</th>
            </tr>
          </thead>
          <tbody>
<%
  try (Connection c = DBConnect.getConnection();
       PreparedStatement ps = c.prepareStatement(
         "SELECT id, title, category, difficulty_level, project_type, current_participants, is_active FROM lab_projects ORDER BY id DESC");
       ResultSet rs = ps.executeQuery()) {
    boolean empty = true;
    while (rs.next()) {
      empty = false;
      int id = rs.getInt("id");
      String title = rs.getString("title");
      String category = rs.getString("category");
      String diff = rs.getString("difficulty_level");
      String ptype = rs.getString("project_type");
      int participants = rs.getInt("current_participants");
      boolean isActive = rs.getBoolean("is_active");
      String diffColor = "Beginner".equals(diff) ? "#34d399" : "Intermediate".equals(diff) ? "#fbbf24" : "#f87171";
%>
            <tr>
              <td><%= id %></td>
              <td><strong><%= EscapeUtil.escapeHtml(title != null ? title : "-") %></strong></td>
              <td><span class="badge badge-info"><%= EscapeUtil.escapeHtml(category != null ? category : "-") %></span></td>
              <td><span style="color:<%= diffColor %>;font-weight:600;"><%= diff != null ? diff : "-" %></span></td>
              <td><%= ptype != null ? ptype : "-" %></td>
              <td><%= participants %></td>
              <td><span class="badge <%= isActive ? "badge-success" : "badge-secondary" %>"><%= isActive ? "활성" : "비활성" %></span></td>
              <td>
                <button class="btn danger btn-sm" onclick="confirmDelete(<%= id %>, '<%= EscapeUtil.escapeHtml(title) %>')">삭제</button>
              </td>
            </tr>
<%
    }
    if (empty) {
%>
            <tr><td colspan="8" style="text-align:center;padding:40px;color:#64748b;">등록된 실습 프로젝트가 없습니다.</td></tr>
<% } } catch (Exception e) { %>
            <tr><td colspan="8" style="text-align:center;padding:40px;color:#fca5a5;">데이터 조회 오류: <%= EscapeUtil.escapeHtml(e.getMessage()) %></td></tr>
<% } %>
          </tbody>
        </table>
      </section>
    </main>
  </div>
</div>

<!-- 추가 모달 -->
<div id="createModal" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,.7);z-index:9999;align-items:center;justify-content:center;">
  <div style="background:#1e293b;border:1px solid rgba(255,255,255,.12);border-radius:16px;padding:32px;width:min(480px,90vw);">
    <h3 style="margin-bottom:20px;">실습 프로젝트 추가</h3>
    <form method="POST" action="/AI/admin/lab/index.jsp">
      <input type="hidden" name="action" value="create">
      <div style="margin-bottom:14px;">
        <label style="display:block;font-size:.8125rem;color:#94a3b8;margin-bottom:6px;">프로젝트명 *</label>
        <input type="text" name="title" required style="width:100%;padding:10px 14px;border-radius:8px;border:1px solid rgba(255,255,255,.15);background:rgba(255,255,255,.05);color:inherit;">
      </div>
      <div style="margin-bottom:14px;">
        <label style="display:block;font-size:.8125rem;color:#94a3b8;margin-bottom:6px;">카테고리</label>
        <input type="text" name="category" style="width:100%;padding:10px 14px;border-radius:8px;border:1px solid rgba(255,255,255,.15);background:rgba(255,255,255,.05);color:inherit;">
      </div>
      <div style="margin-bottom:14px;">
        <label style="display:block;font-size:.8125rem;color:#94a3b8;margin-bottom:6px;">난이도</label>
        <select name="difficulty_level" style="width:100%;padding:10px 14px;border-radius:8px;border:1px solid rgba(255,255,255,.15);background:#1e293b;color:inherit;">
          <option>Beginner</option>
          <option>Intermediate</option>
          <option>Advanced</option>
        </select>
      </div>
      <div style="margin-bottom:20px;">
        <label style="display:block;font-size:.8125rem;color:#94a3b8;margin-bottom:6px;">설명</label>
        <textarea name="description" rows="3" style="width:100%;padding:10px 14px;border-radius:8px;border:1px solid rgba(255,255,255,.15);background:rgba(255,255,255,.05);color:inherit;resize:vertical;"></textarea>
      </div>
      <div style="display:flex;gap:10px;justify-content:flex-end;">
        <button type="button" class="btn secondary" onclick="document.getElementById('createModal').style.display='none'">취소</button>
        <button type="submit" class="btn primary">추가</button>
      </div>
    </form>
  </div>
</div>

<!-- 삭제 확인 모달 -->
<div id="deleteModal" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,.7);z-index:9999;align-items:center;justify-content:center;">
  <div style="background:#1e293b;border:1px solid rgba(255,255,255,.12);border-radius:16px;padding:32px;width:min(400px,90vw);text-align:center;">
    <i class="bi bi-exclamation-triangle-fill" style="font-size:2.5rem;color:#f59e0b;margin-bottom:16px;display:block;"></i>
    <h3 style="margin-bottom:8px;">삭제 확인</h3>
    <p id="deleteMsg" style="color:#94a3b8;margin-bottom:24px;"></p>
    <div style="display:flex;gap:10px;justify-content:center;">
      <button class="btn secondary" onclick="document.getElementById('deleteModal').style.display='none'">취소</button>
      <a id="deleteConfirmBtn" class="btn danger">삭제</a>
    </div>
  </div>
</div>

<script>
function filterTable() {
  const q = document.getElementById('searchInput').value.toLowerCase();
  document.querySelectorAll('#labTable tbody tr').forEach(r => {
    r.style.display = r.textContent.toLowerCase().includes(q) ? '' : 'none';
  });
}
function confirmDelete(id, name) {
  document.getElementById('deleteMsg').textContent = '"' + name + '"을(를) 삭제하시겠습니까?';
  document.getElementById('deleteConfirmBtn').href = '/AI/admin/lab/index.jsp?deleteId=' + id;
  document.getElementById('deleteModal').style.display = 'flex';
}
['createModal','deleteModal'].forEach(id => {
  document.getElementById(id).addEventListener('click', function(e) {
    if (e.target === this) this.style.display = 'none';
  });
});
</script>
<jsp:include page="/AI/admin/layout/footer.jspf"/>
