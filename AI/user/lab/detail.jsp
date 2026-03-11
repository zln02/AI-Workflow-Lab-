<%@ page contentType="text/html; charset=UTF-8" buffer="128kb" autoFlush="true" %>
<%@ page isELIgnored="true" %>
<%@ page import="dao.LabProjectDAO, dao.UserProgressDAO" %>
<%@ page import="model.LabProject, model.User" %>
<%@ page import="java.util.List, java.util.Map" %>
<%@ include file="/AI/user/_common.jsp" %>

<%!
  String ptypeGrad(String t) {
    if (t == null) return "linear-gradient(135deg,#3b82f6,#6366f1)";
    switch (t) {
      case "Tutorial":    return "linear-gradient(135deg,#3b82f6,#6366f1)";
      case "Challenge":   return "linear-gradient(135deg,#f59e0b,#ef4444)";
      case "Real-world":  return "linear-gradient(135deg,#10b981,#06b6d4)";
      default:            return "linear-gradient(135deg,#3b82f6,#6366f1)";
    }
  }
  String ptypeColor(String t) {
    if (t == null) return "#3b82f6";
    switch (t) {
      case "Tutorial":   return "#3b82f6";
      case "Challenge":  return "#f59e0b";
      case "Real-world": return "#10b981";
      default:           return "#3b82f6";
    }
  }
  String diffKoD(String d) {
    if (d == null) return d;
    switch (d) {
      case "Beginner":     return "입문";
      case "Intermediate": return "중급";
      case "Advanced":     return "고급";
      default:             return d;
    }
  }
%>

<%
  int projectId = 0;
  try { projectId = Integer.parseInt(request.getParameter("id")); } catch (Exception e) {}
  LabProjectDAO projectDao = new LabProjectDAO();
  LabProject project = projectId > 0 ? projectDao.findById(projectId) : null;

  if (project == null) {
    response.sendRedirect("/AI/user/lab/index.jsp");
    return;
  }

  List<LabProject> related = projectDao.findByCategory(project.getCategory());
  related.removeIf(p -> p.getId() == project.getId());
  if (related.size() > 3) related = related.subList(0, 3);

  // Load user progress
  User currentUser = (User) session.getAttribute("user");
  Map<String, Object> userProgress = null;
  if (currentUser != null) {
    try {
      UserProgressDAO progressDao = new UserProgressDAO();
      userProgress = progressDao.findByUserAndProject(currentUser.getId(), projectId);
    } catch (Exception e) { /* ignore */ }
  }
  double userPct = userProgress != null ? (Double)userProgress.get("progressPercentage") : 0;
  String userStatus = userProgress != null ? safeString((String)userProgress.get("status"), "") : "";
  boolean isInProgress = "In Progress".equals(userStatus) || "Completed".equals(userStatus);
  boolean isCompleted  = "Completed".equals(userStatus);
  String playgroundHref = "/AI/user/lab/playground.jsp?id=" + project.getId();

  String pt  = project.getProjectType();
  String dl  = project.getDifficultyLevel();
  String typeGrad  = ptypeGrad(pt);
  String typeColor = ptypeColor(pt);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><%= escapeHtml(project.getTitle()) %> - AI 실습 랩</title>
  <link rel="icon" href="data:,">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
  <link rel="stylesheet" href="/AI/assets/css/dark-theme.css">
  <style>
    /* ── Base ── */
    body { padding-top: 60px; background: var(--bg-primary, #0a0f1e); color: var(--text-primary, #f1f5f9); }

    /* ── Breadcrumb ── */
    .ld-breadcrumb { display: flex; align-items: center; gap: 6px; font-size: .8125rem;
      color: var(--text-muted, #64748b); margin-bottom: 28px; }
    .ld-breadcrumb a { color: var(--text-muted, #64748b); text-decoration: none; transition: color .2s; }
    .ld-breadcrumb a:hover { color: var(--text-primary, #f1f5f9); }
    .ld-breadcrumb .sep { opacity: .4; }
    .ld-breadcrumb .cur { color: var(--text-secondary, #94a3b8); }

    /* ── Glass card ── */
    .gc {
      background: rgba(255,255,255,.04);
      border: 1px solid rgba(255,255,255,.08);
      border-radius: 16px;
      backdrop-filter: blur(12px);
      -webkit-backdrop-filter: blur(12px);
      overflow: hidden;
      margin-bottom: 20px;
    }
    .gc-header {
      padding: 16px 20px;
      border-bottom: 1px solid rgba(255,255,255,.07);
      display: flex; align-items: center; gap: 10px;
      font-size: .875rem; font-weight: 600; color: var(--text-secondary, #94a3b8);
    }
    .gc-header .icon { font-size: 1rem; }
    .gc-body { padding: 20px; }

    /* ── Hero card ── */
    .hero-card { position: relative; }
    .hero-card__bar { height: 4px; background: <%= typeGrad %>; }
    .hero-card__inner { padding: 28px; }
    .hero-type-badge {
      display: inline-flex; align-items: center; gap: 6px;
      padding: 4px 12px; border-radius: 20px; font-size: .75rem; font-weight: 600;
      background: <%= typeColor %>22; border: 1px solid <%= typeColor %>44; color: <%= typeColor %>;
    }
    .hero-diff-badge {
      display: inline-flex; align-items: center; gap: 6px;
      padding: 4px 12px; border-radius: 20px; font-size: .75rem; font-weight: 600;
      background: rgba(148,163,184,.12); border: 1px solid rgba(148,163,184,.2); color: var(--text-secondary, #94a3b8);
    }
    .hero-cat-badge {
      display: inline-flex; align-items: center; gap: 6px;
      padding: 4px 12px; border-radius: 20px; font-size: .75rem; font-weight: 600;
      background: rgba(99,102,241,.12); border: 1px solid rgba(99,102,241,.25); color: #a5b4fc;
    }
    .hero-title { font-size: 1.625rem; font-weight: 700; letter-spacing: -.02em; margin: 16px 0 20px; line-height: 1.3; }

    /* ── Stats row ── */
    .stats-row { display: grid; grid-template-columns: repeat(3, 1fr); gap: 1px;
      background: rgba(255,255,255,.07); border-radius: 12px; overflow: hidden; margin-bottom: 0; }
    .stat-cell { padding: 16px 12px; text-align: center; background: rgba(255,255,255,.03); }
    .stat-cell__val { font-size: 1.5rem; font-weight: 700; line-height: 1; margin-bottom: 4px; }
    .stat-cell__lbl { font-size: .75rem; color: var(--text-muted, #64748b); }

    /* ── Business context ── */
    .biz-box {
      margin-top: 24px;
      background: rgba(59,130,246,.07);
      border: 1px solid rgba(59,130,246,.2);
      border-left: 3px solid #3b82f6;
      border-radius: 10px;
      padding: 16px 18px;
    }
    .biz-box__title { font-size: .8125rem; font-weight: 600; color: #93c5fd; margin-bottom: 8px;
      display: flex; align-items: center; gap: 6px; }
    .biz-box__text { font-size: .9rem; color: var(--text-secondary, #94a3b8); line-height: 1.7; margin: 0; }

    /* ── Goals ── */
    .goal-chip {
      display: inline-flex; align-items: center; gap: 6px;
      padding: 5px 12px; border-radius: 20px; font-size: .8125rem;
      background: rgba(99,102,241,.12); border: 1px solid rgba(99,102,241,.25); color: #a5b4fc;
      margin: 3px;
    }

    /* ── Section list items ── */
    .req-item { display: flex; align-items: flex-start; gap: 10px; padding: 10px 0;
      border-bottom: 1px solid rgba(255,255,255,.05); font-size: .9rem; line-height: 1.6; }
    .req-item:last-child { border-bottom: none; }
    .req-item .ico { color: #34d399; margin-top: 2px; flex-shrink: 0; }

    /* ── Step guide ── */
    .step-item { display: flex; gap: 16px; margin-bottom: 20px; }
    .step-item:last-child { margin-bottom: 0; }
    .step-num {
      width: 36px; height: 36px; border-radius: 50%; flex-shrink: 0;
      display: flex; align-items: center; justify-content: center;
      font-size: .8125rem; font-weight: 700;
      background: <%= typeGrad %>; color: #fff;
    }
    .step-body {
      flex: 1; background: rgba(255,255,255,.03); border: 1px solid rgba(255,255,255,.07);
      border-radius: 10px; padding: 14px 16px; font-size: .9rem; line-height: 1.7;
      color: var(--text-secondary, #94a3b8);
    }
    .step-body.done { border-color: rgba(52,211,153,.3); background: rgba(52,211,153,.05); }

    /* ── Outcomes ── */
    .outcome-item { display: flex; align-items: flex-start; gap: 10px; padding: 10px 0;
      border-bottom: 1px solid rgba(255,255,255,.05); font-size: .9rem; line-height: 1.6; }
    .outcome-item:last-child { border-bottom: none; }
    .outcome-item .ico { color: #fbbf24; flex-shrink: 0; margin-top: 2px; }

    /* ── Evaluation ── */
    .eval-item { display: flex; align-items: flex-start; gap: 12px; padding: 10px 0;
      border-bottom: 1px solid rgba(255,255,255,.05); font-size: .9rem; line-height: 1.6; }
    .eval-item:last-child { border-bottom: none; }
    .eval-num {
      min-width: 24px; height: 24px; border-radius: 6px; font-size: .75rem; font-weight: 700;
      display: flex; align-items: center; justify-content: center; flex-shrink: 0;
      background: rgba(139,92,246,.2); color: #c4b5fd; margin-top: 1px;
    }

    /* ── Hints ── */
    .hint-toggle-btn {
      width: 100%; padding: 13px 20px; border-radius: 10px; font-size: .9rem; font-weight: 600;
      background: rgba(251,191,36,.07); border: 1px solid rgba(251,191,36,.25); color: #fbbf24;
      cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 8px;
      transition: background .2s, border-color .2s;
    }
    .hint-toggle-btn:hover { background: rgba(251,191,36,.12); border-color: rgba(251,191,36,.4); }
    .hint-toggle-btn .chevron { transition: transform .3s; }
    .hint-toggle-btn.open .chevron { transform: rotate(180deg); }
    .hints-panel {
      margin-top: 12px; padding: 18px 20px;
      background: rgba(251,191,36,.05); border: 1px solid rgba(251,191,36,.2);
      border-radius: 12px; display: none;
    }
    .hints-panel.show { display: block; }
    .hint-item { display: flex; gap: 10px; margin-bottom: 10px; font-size: .875rem; line-height: 1.6;
      color: var(--text-secondary, #94a3b8); }
    .hint-item:last-child { margin-bottom: 0; }
    .hint-item .ico { color: #fbbf24; flex-shrink: 0; margin-top: 2px; }

    /* ── Submit CTA ── */
    .submit-cta {
      border-radius: 16px; overflow: hidden;
      background: linear-gradient(135deg, rgba(59,130,246,.15), rgba(139,92,246,.15));
      border: 1px solid rgba(139,92,246,.25);
      padding: 32px; text-align: center;
      margin-bottom: 20px;
    }
    .submit-cta h4 { font-size: 1.1rem; font-weight: 700; margin-bottom: 8px; }
    .submit-cta p { font-size: .875rem; color: var(--text-muted, #64748b); margin-bottom: 20px; }
    .btn-submit {
      display: inline-flex; align-items: center; gap: 8px;
      padding: 12px 28px; border-radius: 10px; font-size: .9rem; font-weight: 600;
      background: linear-gradient(135deg, #3b82f6, #8b5cf6);
      color: #fff; text-decoration: none; border: none; cursor: pointer;
      transition: opacity .2s, transform .2s;
    }
    .btn-submit:hover { opacity: .9; transform: translateY(-1px); color: #fff; }

    /* ── Sidebar: Progress tracker ── */
    .sidebar { position: sticky; top: 76px; }
    .progress-card { }
    .prog-bar-wrap { background: rgba(255,255,255,.07); border-radius: 999px; height: 8px; overflow: hidden; }
    .prog-bar-fill { height: 100%; border-radius: 999px; transition: width .4s ease;
      background: linear-gradient(90deg, #3b82f6, #8b5cf6); }
    .prog-pct { font-size: .8125rem; color: var(--text-muted, #64748b); }

    .step-check-row { display: flex; align-items: flex-start; gap: 10px; padding: 8px 0;
      border-bottom: 1px solid rgba(255,255,255,.05); }
    .step-check-row:last-child { border-bottom: none; }
    .step-check-row input[type=checkbox] {
      width: 16px; height: 16px; flex-shrink: 0; margin-top: 2px;
      accent-color: #3b82f6; cursor: pointer;
    }
    .step-check-row label { font-size: .8125rem; color: var(--text-secondary, #94a3b8);
      line-height: 1.5; cursor: pointer; }
    .step-check-row input:checked + label { color: #34d399; text-decoration: line-through; text-decoration-color: rgba(52,211,153,.4); }

    .btn-all-done {
      width: 100%; margin-top: 14px; padding: 10px; border-radius: 10px; font-size: .875rem; font-weight: 600;
      background: rgba(52,211,153,.12); border: 1px solid rgba(52,211,153,.3); color: #34d399;
      cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 6px;
      transition: background .2s;
    }
    .btn-all-done:hover { background: rgba(52,211,153,.2); }

    /* ── Tools list ── */
    .tool-row { display: flex; align-items: center; justify-content: space-between;
      padding: 10px 0; border-bottom: 1px solid rgba(255,255,255,.05); }
    .tool-row:last-child { border-bottom: none; }
    .tool-row__name { display: flex; align-items: center; gap: 8px; font-size: .875rem; color: var(--text-secondary, #94a3b8); }
    .tool-row__name .ico { color: #60a5fa; }
    .btn-find {
      font-size: .75rem; padding: 4px 10px; border-radius: 6px; font-weight: 600;
      background: rgba(59,130,246,.12); border: 1px solid rgba(59,130,246,.25); color: #60a5fa;
      text-decoration: none; white-space: nowrap; transition: background .2s;
    }
    .btn-find:hover { background: rgba(59,130,246,.22); color: #93c5fd; }

    /* ── Related ── */
    .rel-card {
      display: block; padding: 14px 0;
      border-bottom: 1px solid rgba(255,255,255,.05);
      text-decoration: none; transition: opacity .2s;
    }
    .rel-card:last-child { border-bottom: none; }
    .rel-card:hover { opacity: .8; }
    .rel-card__title { font-size: .875rem; font-weight: 500; color: var(--text-primary, #f1f5f9); margin-bottom: 4px; }
    .rel-card__meta { font-size: .75rem; color: var(--text-muted, #64748b); display: flex; align-items: center; gap: 6px; }
    .rel-diff-badge {
      display: inline-flex; align-items: center; padding: 2px 8px; border-radius: 10px;
      font-size: .7rem; font-weight: 600;
      background: rgba(148,163,184,.1); border: 1px solid rgba(148,163,184,.2); color: var(--text-secondary, #94a3b8);
    }

    /* ── Responsive ── */
    @media (max-width: 991px) {
      .sidebar { position: static; }
    }
  </style>
</head>
<body>
<%@ include file="/AI/partials/header.jsp" %>

<div style="max-width:1280px; margin:0 auto; padding:32px 24px;">

  <!-- Breadcrumb -->
  <nav class="ld-breadcrumb">
    <a href="/AI/user/home.jsp">홈</a>
    <span class="sep"><i class="bi bi-chevron-right"></i></span>
    <a href="/AI/user/lab/index.jsp">AI 실습 랩</a>
    <span class="sep"><i class="bi bi-chevron-right"></i></span>
    <span class="cur"><%= escapeHtml(project.getTitle()) %></span>
  </nav>

  <div class="row g-4">
    <!-- ══ LEFT 2/3 ══ -->
    <div class="col-lg-8">

      <!-- Hero card -->
      <div class="gc hero-card">
        <div class="hero-card__bar"></div>
        <div class="hero-card__inner">
          <div class="d-flex flex-wrap gap-2 mb-3">
            <span class="hero-type-badge"><%= escapeHtml(pt != null ? pt : "") %></span>
            <span class="hero-diff-badge"><%= diffKoD(dl) %></span>
            <span class="hero-cat-badge"><%= escapeHtml(project.getCategory()) %></span>
          </div>
          <h1 class="hero-title"><%= escapeHtml(project.getTitle()) %></h1>

          <!-- Stats -->
          <div class="stats-row">
            <div class="stat-cell">
              <div class="stat-cell__val" style="color:#60a5fa;"><%= project.getFormattedDuration() %></div>
              <div class="stat-cell__lbl">예상 소요 시간</div>
            </div>
            <div class="stat-cell">
              <div class="stat-cell__val" style="color:#34d399;"><%= project.getStepCount() %></div>
              <div class="stat-cell__lbl">진행 단계</div>
            </div>
            <div class="stat-cell">
              <div class="stat-cell__val" style="color:#f87171;"><%= project.getCurrentParticipants() != null ? project.getCurrentParticipants() : 0 %></div>
              <div class="stat-cell__lbl">참여자</div>
            </div>
          </div>

          <!-- Business context -->
          <% if (project.getBusinessContext() != null && !project.getBusinessContext().trim().isEmpty()) { %>
          <div class="biz-box">
            <div class="biz-box__title"><i class="bi bi-briefcase"></i>비즈니스 시나리오</div>
            <p class="biz-box__text"><%= escapeHtml(project.getBusinessContext()) %></p>
          </div>
          <% } %>
        </div>
      </div>

      <!-- Project goals -->
      <% if (project.getProjectGoals() != null && !project.getProjectGoals().isEmpty()) { %>
      <div class="gc">
        <div class="gc-header"><i class="bi bi-bullseye icon" style="color:#60a5fa;"></i>프로젝트 목표</div>
        <div class="gc-body" style="padding-top:16px;">
          <% for (String goal : project.getProjectGoals()) { %>
          <span class="goal-chip"><i class="bi bi-check2"></i><%= escapeHtml(goal) %></span>
          <% } %>
        </div>
      </div>
      <% } %>

      <!-- Requirements -->
      <% if (project.getRequirements() != null && !project.getRequirements().isEmpty()) { %>
      <div class="gc">
        <div class="gc-header"><i class="bi bi-clipboard-check icon" style="color:#a78bfa;"></i>사전 요구사항</div>
        <div class="gc-body">
          <% for (String req : project.getRequirements()) { %>
          <div class="req-item"><i class="bi bi-check-circle-fill ico"></i><span><%= escapeHtml(req) %></span></div>
          <% } %>
        </div>
      </div>
      <% } %>

      <!-- Step-by-step guide -->
      <% if (project.getStepByStepGuide() != null && !project.getStepByStepGuide().isEmpty()) { %>
      <div class="gc">
        <div class="gc-header"><i class="bi bi-list-ol icon" style="color:#60a5fa;"></i>단계별 실습 가이드</div>
        <div class="gc-body">
          <% int stepNum = 1; for (String step : project.getStepByStepGuide()) {
             int sn = stepNum; stepNum++; %>
          <div class="step-item" id="step-<%= sn %>">
            <div class="step-num"><%= sn %></div>
            <div class="step-body"><%= escapeHtml(step) %></div>
          </div>
          <% } %>
        </div>
      </div>
      <% } %>

      <!-- Expected outcomes -->
      <% if (project.getExpectedOutcomes() != null && !project.getExpectedOutcomes().isEmpty()) { %>
      <div class="gc">
        <div class="gc-header"><i class="bi bi-trophy icon" style="color:#fbbf24;"></i>예상 결과물</div>
        <div class="gc-body">
          <% for (String outcome : project.getExpectedOutcomes()) { %>
          <div class="outcome-item"><i class="bi bi-star-fill ico"></i><span><%= escapeHtml(outcome) %></span></div>
          <% } %>
        </div>
      </div>
      <% } %>

      <!-- Evaluation criteria -->
      <% if (project.getEvaluationCriteria() != null && !project.getEvaluationCriteria().isEmpty()) { %>
      <div class="gc">
        <div class="gc-header"><i class="bi bi-clipboard2-data icon" style="color:#c4b5fd;"></i>평가 기준</div>
        <div class="gc-body">
          <% int critNum = 1; for (String crit : project.getEvaluationCriteria()) { %>
          <div class="eval-item">
            <div class="eval-num"><%= critNum++ %></div>
            <span><%= escapeHtml(crit) %></span>
          </div>
          <% } %>
        </div>
      </div>
      <% } %>

      <!-- Hints -->
      <% if (project.hasHints()) { %>
      <div style="margin-bottom: 20px;">
        <button class="hint-toggle-btn" id="hintBtn" onclick="toggleHints()">
          <i class="bi bi-lightbulb"></i>
          힌트 보기 (막히면 참고하세요)
          <i class="bi bi-chevron-down chevron"></i>
        </button>
        <div class="hints-panel" id="hintsPanel">
          <% for (String hint : project.getHints()) { %>
          <div class="hint-item"><i class="bi bi-lightbulb-fill ico"></i><span><%= escapeHtml(hint) %></span></div>
          <% } %>
        </div>
      </div>
      <% } %>

      <!-- Start / Continue CTA -->
      <div class="submit-cta">
        <% if (isCompleted) { %>
          <i class="bi bi-award" style="font-size:2.5rem;color:#34d399;display:block;margin-bottom:16px;text-align:center;"></i>
          <h4>실습을 완료하셨습니다!</h4>
          <p>이미 완료한 실습입니다. 세션으로 돌아가 내용을 복습하거나 결과물을 다시 제출할 수 있습니다.</p>
          <div style="display:flex;gap:10px;justify-content:center;flex-wrap:wrap;">
            <a href="/AI/user/lab/session.jsp?id=<%= project.getId() %>" class="btn-submit">
              <i class="bi bi-arrow-repeat"></i>다시 보기
            </a>
            <a href="<%= playgroundHref %>" class="btn-submit" style="background:linear-gradient(135deg,#0ea5e9,#2563eb);box-shadow:0 4px 20px rgba(14,165,233,.35);">
              <i class="bi bi-terminal"></i>Playground
            </a>
            <a href="/AI/user/lab/submit.jsp?id=<%= project.getId() %>" class="btn-submit" style="background:linear-gradient(135deg,#10b981,#34d399);box-shadow:0 4px 20px rgba(16,185,129,.35);">
              <i class="bi bi-send"></i>결과물 제출
            </a>
          </div>
        <% } else if (isInProgress) { %>
          <h4><i class="bi bi-play-circle me-2"></i>실습이 진행 중입니다</h4>
          <p>진행률 <%= Math.round(userPct) %>% — 세션을 이어서 진행하세요.</p>
          <div style="background:rgba(255,255,255,.07);border-radius:999px;height:8px;overflow:hidden;margin-bottom:20px;">
            <div style="height:100%;border-radius:999px;background:linear-gradient(90deg,#3b82f6,#8b5cf6);width:<%= Math.round(userPct) %>%;"></div>
          </div>
          <div style="display:flex;gap:10px;justify-content:center;flex-wrap:wrap;">
            <a href="/AI/user/lab/session.jsp?id=<%= project.getId() %>" class="btn-submit">
              <i class="bi bi-play-fill"></i>이어서 실습하기
            </a>
            <a href="<%= playgroundHref %>" class="btn-submit" style="background:linear-gradient(135deg,#0ea5e9,#2563eb);box-shadow:0 4px 20px rgba(14,165,233,.35);">
              <i class="bi bi-terminal"></i>Playground
            </a>
          </div>
        <% } else { %>
          <h4><i class="bi bi-rocket me-2"></i>실습 시작하기</h4>
          <p>단계별 가이드를 따라 직접 AI 도구를 활용하며 실습을 진행하세요.</p>
          <div style="display:flex;gap:10px;justify-content:center;flex-wrap:wrap;">
            <a href="/AI/user/lab/session.jsp?id=<%= project.getId() %>" class="btn-submit">
              <i class="bi bi-play-fill"></i>지금 시작하기
            </a>
            <a href="<%= playgroundHref %>" class="btn-submit" style="background:linear-gradient(135deg,#0ea5e9,#2563eb);box-shadow:0 4px 20px rgba(14,165,233,.35);">
              <i class="bi bi-terminal"></i>바로 실험하기
            </a>
          </div>
        <% } %>
      </div>

    </div><!-- /col-lg-8 -->

    <!-- ══ RIGHT 1/3 ══ -->
    <aside class="col-lg-4">
      <div class="sidebar">

        <!-- Progress tracker -->
        <div class="gc progress-card">
          <div class="gc-header"><i class="bi bi-check2-circle icon" style="color:#34d399;"></i>내 진행 상황</div>
          <div class="gc-body">
            <div class="d-flex justify-content-between align-items-center mb-8" style="margin-bottom:8px;">
              <span style="font-size:.8125rem; color:var(--text-muted,#64748b);">진행률</span>
              <span class="prog-pct"><%= Math.round(userPct) %>%</span>
            </div>
            <div class="prog-bar-wrap" style="margin-bottom:16px;">
              <div class="prog-bar-fill" style="width:<%= Math.round(userPct) %>%;"></div>
            </div>
            <% if (!isInProgress) { %>
            <p style="font-size:.8125rem;color:var(--text-muted,#64748b);text-align:center;padding:8px 0;">
              아직 시작하지 않은 실습입니다.
            </p>
            <% } else { %>
            <div style="font-size:.8125rem;color:var(--text-muted,#64748b);margin-bottom:12px;">
              <% if (isCompleted) { %>
              <span style="color:#34d399;"><i class="bi bi-check-circle-fill me-1"></i>완료된 실습</span>
              <% } else { %>
              <span style="color:#60a5fa;"><i class="bi bi-play-circle-fill me-1"></i>진행 중</span>
              <% } %>
            </div>
            <% } %>
            <a href="/AI/user/lab/session.jsp?id=<%= project.getId() %>"
               class="btn-all-done" style="text-decoration:none;">
              <% if (isCompleted) { %>
              <i class="bi bi-arrow-repeat"></i>다시 보기
              <% } else if (isInProgress) { %>
              <i class="bi bi-play-fill"></i>이어서 실습
              <% } else { %>
              <i class="bi bi-play-fill"></i>실습 시작
              <% } %>
            </a>
          </div>
        </div>

        <!-- Required tools -->
        <% if (project.getToolsRequired() != null && !project.getToolsRequired().isEmpty()) { %>
        <div class="gc">
          <div class="gc-header"><i class="bi bi-tools icon" style="color:#60a5fa;"></i>필요한 AI 도구</div>
          <div class="gc-body">
            <% for (String tool : project.getToolsRequired()) { %>
            <div class="tool-row">
              <span class="tool-row__name"><i class="bi bi-cpu ico"></i><%= escapeHtml(tool) %></span>
              <a href="/AI/user/tools/navigator.jsp?keyword=<%= escapeHtmlAttribute(tool) %>"
                 class="btn-find" target="_blank">찾기</a>
            </div>
            <% } %>
          </div>
        </div>
        <% } %>

        <!-- Related projects -->
        <% if (!related.isEmpty()) { %>
        <div class="gc">
          <div class="gc-header"><i class="bi bi-grid icon" style="color:#a78bfa;"></i>관련 프로젝트</div>
          <div class="gc-body">
            <% for (LabProject r : related) { %>
            <a href="/AI/user/lab/detail.jsp?id=<%= r.getId() %>" class="rel-card">
              <div class="rel-card__title">
                <span class="rel-diff-badge me-2"><%= diffKoD(r.getDifficultyLevel()) %></span>
                <%= escapeHtml(r.getTitle()) %>
              </div>
              <div class="rel-card__meta">
                <i class="bi bi-clock"></i><%= r.getFormattedDuration() %>
              </div>
            </a>
            <% } %>
          </div>
        </div>
        <% } %>

      </div><!-- /sidebar -->
    </aside>
  </div><!-- /row -->
</div><!-- /wrapper -->

<%@ include file="/AI/partials/footer.jsp" %>
<script>
  /* ── Hints toggle ── */
  function toggleHints() {
    const btn   = document.getElementById('hintBtn');
    const panel = document.getElementById('hintsPanel');
    if (!btn || !panel) return;
    btn.classList.toggle('open');
    panel.classList.toggle('show');
  }
</script>
</body>
</html>
