<%@ page contentType="text/html; charset=UTF-8" buffer="64kb" %>
<%@ page isELIgnored="true" %>
<%@ page import="dao.LabProjectDAO, dao.UserProgressDAO" %>
<%@ page import="model.LabProject, model.User" %>
<%@ page import="java.util.Map, java.util.List" %>
<%@ include file="/AI/user/_common.jsp" %>

<%
  User user = (User) session.getAttribute("user");
  if (user == null) {
    response.sendRedirect("/AI/user/login.jsp");
    return;
  }

  int projectId = 0;
  try { projectId = Integer.parseInt(request.getParameter("id")); } catch (Exception e) {}

  LabProjectDAO projectDao = new LabProjectDAO();
  LabProject p = projectId > 0 ? projectDao.findById(projectId) : null;
  if (p == null) { response.sendRedirect("/AI/user/lab/index.jsp"); return; }

  UserProgressDAO progressDao = new UserProgressDAO();
  Map<String, Object> progress = progressDao.findByUserAndProject(user.getId(), projectId);

  // Handle POST submission
  String submitError = null;
  boolean submitted = false;
  if ("POST".equals(request.getMethod())) {
    String title       = safeString(request.getParameter("title"), "");
    String description = safeString(request.getParameter("description"), "");
    String processDesc = safeString(request.getParameter("processDescription"), "");
    String toolsUsed   = safeString(request.getParameter("toolsUsed"), "");
    String challenges  = safeString(request.getParameter("challenges"), "");
    String lessons     = safeString(request.getParameter("lessons"), "");
    String isPublicStr = request.getParameter("isPublic");
    boolean isPublic   = "on".equals(isPublicStr) || "true".equals(isPublicStr);

    if (title.isEmpty()) {
      submitError = "제목을 입력해주세요.";
    } else {
      try {
        db.DBConnect conn = null;
        java.sql.Connection c = db.DBConnect.getConnection();
        String sql = "INSERT INTO project_results (user_id, project_id, title, description, process_description, tools_used, challenges_faced, lessons_learned, is_public, completed_at) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";
        java.sql.PreparedStatement ps = c.prepareStatement(sql);
        ps.setLong(1, user.getId());
        ps.setInt(2, projectId);
        ps.setString(3, title);
        ps.setString(4, description);
        ps.setString(5, processDesc);
        ps.setString(6, toolsUsed.isEmpty() ? null : toolsUsed);
        ps.setString(7, challenges);
        ps.setString(8, lessons);
        ps.setBoolean(9, isPublic);
        ps.executeUpdate();
        c.close();

        // mark progress as completed
        progressDao.markCompleted(user.getId(), projectId);
        submitted = true;
      } catch (Exception e) {
        submitError = "제출 중 오류가 발생했습니다: " + e.getMessage();
      }
    }
  }

  // Load notes from progress for pre-fill
  String notesJson = progress != null ? safeString((String)progress.get("notes"), "{}") : "{}";
  double progressPct = progress != null ? (Double)progress.get("progressPercentage") : 0;
  int timeMinutes = progress != null ? (Integer)progress.get("timeSpentMinutes") : 0;
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>결과물 제출 — <%= escapeHtml(p.getTitle()) %></title>
  <link rel="icon" href="data:,">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
  <link rel="stylesheet" href="/AI/assets/css/dark-theme.css">
  <link rel="stylesheet" href="/AI/assets/css/page.css">
</head>
<body>
<%@ include file="/AI/partials/header.jsp" %>

<% if (submitted) { %>
<div class="page-wrap--narrow" style="text-align:center; padding-top: 80px;">
  <i class="bi bi-check-circle-fill" style="font-size:4rem;color:#10b981;display:block;margin-bottom:24px;"></i>
  <h1 style="font-size:1.75rem;font-weight:800;margin-bottom:12px;">제출 완료!</h1>
  <p style="color:var(--text-muted,#64748b);margin-bottom:40px;font-size:.9375rem;line-height:1.7;">
    <strong><%= escapeHtml(p.getTitle()) %></strong> 실습 결과가 저장되었습니다.<br>
    수고 많으셨습니다!
  </p>
  <div style="display:flex;gap:12px;justify-content:center;flex-wrap:wrap;">
    <a href="/AI/user/lab/index.jsp" class="btn-primary">
      <i class="bi bi-grid"></i>다른 실습 보기
    </a>
    <a href="/AI/user/mypage.jsp" class="btn-secondary">
      <i class="bi bi-person"></i>마이페이지
    </a>
  </div>
</div>

<% } else { %>

<div class="page-wrap--narrow">
  <!-- Breadcrumb -->
  <nav style="display:flex;align-items:center;gap:6px;font-size:.8125rem;color:var(--text-muted,#64748b);margin-bottom:32px;">
    <a href="/AI/user/lab/index.jsp" style="color:inherit;text-decoration:none;">AI 실습 랩</a>
    <i class="bi bi-chevron-right" style="opacity:.4;"></i>
    <a href="/AI/user/lab/detail.jsp?id=<%= projectId %>" style="color:inherit;text-decoration:none;"><%= escapeHtml(p.getTitle()) %></a>
    <i class="bi bi-chevron-right" style="opacity:.4;"></i>
    <span style="color:var(--text-secondary,#94a3b8);">결과물 제출</span>
  </nav>

  <div class="page-header">
    <div class="page-header__label"><i class="bi bi-send"></i>결과물 제출</div>
    <h1><span class="grad-text">실습 결과</span>를 기록하세요</h1>
    <p>완료한 실습의 내용, 배운 점, 활용한 도구를 정리하여 포트폴리오로 저장합니다.</p>
  </div>

  <!-- Progress summary card -->
  <div class="glass-card" style="margin-bottom:28px;">
    <div class="card-header"><i class="bi bi-bar-chart-fill"></i>실습 요약</div>
    <div style="display:grid;grid-template-columns:repeat(3,1fr);gap:1px;background:rgba(255,255,255,.07);border-radius:10px;overflow:hidden;">
      <div style="padding:16px 12px;text-align:center;background:rgba(255,255,255,.03);">
        <div style="font-size:1.5rem;font-weight:700;color:#60a5fa;line-height:1;"><%= Math.round(progressPct) %>%</div>
        <div style="font-size:.75rem;color:var(--text-muted,#64748b);margin-top:4px;">진행률</div>
      </div>
      <div style="padding:16px 12px;text-align:center;background:rgba(255,255,255,.03);">
        <div style="font-size:1.5rem;font-weight:700;color:#34d399;line-height:1;"><%= timeMinutes %></div>
        <div style="font-size:.75rem;color:var(--text-muted,#64748b);margin-top:4px;">소요 시간(분)</div>
      </div>
      <div style="padding:16px 12px;text-align:center;background:rgba(255,255,255,.03);">
        <div style="font-size:1.5rem;font-weight:700;color:#fbbf24;line-height:1;"><%= p.getStepCount() %></div>
        <div style="font-size:.75rem;color:var(--text-muted,#64748b);margin-top:4px;">전체 단계</div>
      </div>
    </div>
  </div>

  <% if (submitError != null) { %>
  <div class="alert alert-error"><i class="bi bi-exclamation-triangle-fill me-2"></i><%= escapeHtml(submitError) %></div>
  <% } %>

  <form method="POST" action="/AI/user/lab/submit.jsp?id=<%= projectId %>">
    <div class="glass-card">
      <div class="card-header"><i class="bi bi-file-text"></i>결과물 정보</div>

      <div class="form-field">
        <label>제목 <span style="color:#f87171;">*</span></label>
        <input type="text" name="title" required
               value="<%= escapeHtmlAttribute(p.getTitle()) %> 실습 완료"
               placeholder="결과물 제목을 입력하세요">
      </div>

      <div class="form-field">
        <label>결과물 요약</label>
        <textarea name="description" style="min-height:100px;"
                  placeholder="이 실습에서 만들어낸 결과물을 간략히 설명하세요.&#10;예) ChatGPT 기반 CS 챗봇 프롬프트 10종 세트와 테스트 리포트를 완성했습니다."></textarea>
      </div>

      <div class="form-field">
        <label>과정 설명</label>
        <textarea name="processDescription" style="min-height:140px;" id="processDesc"
                  placeholder="어떤 과정으로 진행했는지 설명하세요.&#10;각 단계에서 시도한 것, 발견한 점, 수정한 내용 등을 자유롭게 적어주세요."></textarea>
        <small>세션에서 작성한 노트를 가져오려면 아래 버튼을 클릭하세요.</small>
        <button type="button" onclick="importNotes()" style="margin-top:8px;padding:6px 14px;border-radius:8px;background:rgba(59,130,246,.1);border:1px solid rgba(59,130,246,.25);color:#60a5fa;font-size:.8125rem;font-weight:600;cursor:pointer;">
          <i class="bi bi-download me-1"></i>세션 노트 가져오기
        </button>
      </div>

      <div class="form-field">
        <label>활용한 AI 도구</label>
        <input type="text" name="toolsUsed"
               value="<% if(p.getToolsRequired()!=null){%><%= String.join(", ", p.getToolsRequired()) %><% } %>"
               placeholder="ChatGPT, Claude, Canva ...">
        <small>실제 사용한 도구를 쉼표로 구분하여 입력하세요.</small>
      </div>

      <div class="form-row">
        <div class="form-field">
          <label>어려웠던 점</label>
          <textarea name="challenges" style="min-height:90px;"
                    placeholder="실습 중 막혔거나 어려웠던 부분을 기록하세요."></textarea>
        </div>
        <div class="form-field">
          <label>배운 점 / 인사이트</label>
          <textarea name="lessons" style="min-height:90px;"
                    placeholder="이 실습을 통해 새롭게 배운 것이나 실무에 적용할 아이디어를 작성하세요."></textarea>
        </div>
      </div>

      <div class="form-field">
        <label style="display:flex;align-items:center;gap:10px;cursor:pointer;font-size:.9rem;color:var(--text-secondary,#94a3b8);">
          <input type="checkbox" name="isPublic" style="width:16px;height:16px;accent-color:#3b82f6;">
          커뮤니티에 공개하기 (다른 학습자가 내 결과물을 참고할 수 있습니다)
        </label>
      </div>
    </div>

    <div style="display:flex;gap:12px;justify-content:flex-end;margin-top:4px;">
      <a href="/AI/user/lab/session.jsp?id=<%= projectId %>" class="btn-secondary">
        <i class="bi bi-arrow-left"></i>세션으로 돌아가기
      </a>
      <button type="submit" class="btn-primary">
        <i class="bi bi-send-fill"></i>제출하기
      </button>
    </div>
  </form>
</div>

<% } %>

<%@ include file="/AI/partials/footer.jsp" %>
<script>
const SESSION_NOTES = <%= notesJson %>;

function importNotes() {
  const ta = document.getElementById('processDesc');
  if (!ta) return;
  let text = '';
  const keys = Object.keys(SESSION_NOTES).sort((a,b) => parseInt(a)-parseInt(b));
  keys.forEach(k => {
    const val = SESSION_NOTES[k];
    if (val && val.trim()) {
      text += '[단계 ' + (parseInt(k)+1) + ']\n' + val.trim() + '\n\n';
    }
  });
  if (text) {
    ta.value = text.trim();
  } else {
    alert('저장된 세션 노트가 없습니다. 세션에서 각 단계의 노트를 먼저 작성해주세요.');
  }
}
</script>
</body>
</html>
