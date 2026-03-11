<%@ page contentType="text/html; charset=UTF-8" buffer="128kb" autoFlush="true" %>
<%@ page isELIgnored="true" %>
<%@ page import="dao.LabProjectDAO, dao.UserProgressDAO, dao.CreditDAO" %>
<%@ page import="model.LabProject, model.User" %>
<%@ page import="java.util.List, java.util.Map" %>
<%@ include file="/AI/user/_common.jsp" %>

<%
  User user = (User) session.getAttribute("user");
  if (user == null) {
    response.sendRedirect("/AI/user/login.jsp?redirect=" +
      java.net.URLEncoder.encode(request.getRequestURI() + "?" + request.getQueryString(), "UTF-8"));
    return;
  }

  int projectId = 0;
  try { projectId = Integer.parseInt(request.getParameter("id")); } catch (Exception e) {}

  LabProjectDAO projectDao = new LabProjectDAO();
  LabProject p = projectId > 0 ? projectDao.findById(projectId) : null;
  if (p == null) { response.sendRedirect("/AI/user/lab/index.jsp"); return; }

  UserProgressDAO progressDao = new UserProgressDAO();
  Map<String, Object> progress = progressDao.findByUserAndProject(user.getId(), projectId);

  // 크레딧 잔고
  int creditBalance = 0;
  try { creditBalance = new CreditDAO().getBalance(user.getId()); } catch(Exception e) {}
  boolean hasApiKey = false;
  try {
    java.sql.Connection dbConn = db.DBConnect.getConnection();
    java.sql.PreparedStatement ps2 = dbConn.prepareStatement("SELECT id FROM user_api_keys WHERE user_id=? AND is_verified=1 LIMIT 1");
    ps2.setLong(1, user.getId());
    java.sql.ResultSet rs2 = ps2.executeQuery();
    hasApiKey = rs2.next();
    rs2.close(); ps2.close(); dbConn.close();
  } catch(Exception e) {}
  boolean hasPlatformKey = System.getenv("ANTHROPIC_API_KEY") != null && !System.getenv("ANTHROPIC_API_KEY").trim().isEmpty();
  boolean canUseAI = hasApiKey || (hasPlatformKey && creditBalance > 0);
  String returnToSession = "/AI/user/lab/session.jsp?id=" + projectId;
  String encodedReturnToSession = java.net.URLEncoder.encode(returnToSession, "UTF-8");
  String aiSetupUrl = hasPlatformKey ? "/AI/user/pricing.jsp" : "/AI/user/mypage.jsp?tab=apikeys&return=" + encodedReturnToSession;
  String aiSetupLabel = hasPlatformKey ? "크레딧/플랜 설정" : "API 키 연결";
  String aiSetupMessage = hasPlatformKey
    ? "AI 도우미를 쓰려면 크레딧이 필요합니다. 또는 본인 Anthropic API 키를 연결해서 바로 사용할 수 있습니다."
    : "현재 서버 공용 AI 키가 없어서 AI 도우미를 쓰려면 먼저 본인 Anthropic API 키를 연결해야 합니다.";
  String playgroundHref = "/AI/user/lab/playground.jsp?id=" + projectId;

  String savedNotes     = progress != null ? safeString((String)progress.get("notes"), "{}") : "{}";
  String savedBookmarks = progress != null ? safeString((String)progress.get("bookmarks"), "[]") : "[]";
  int    savedTime      = progress != null ? (Integer)progress.get("timeSpentMinutes") : 0;
  String savedStatus    = progress != null ? safeString((String)progress.get("status"), "Not Started") : "Not Started";

  List<String> steps = p.getStepByStepGuide();
  int totalSteps = steps != null ? steps.size() : 0;

  // increment participant count if first visit
  if (progress == null) {
    projectDao.incrementParticipantCount(projectId);
    progressDao.upsert(user.getId(), projectId, 0, "[]", "{}", 0, "In Progress");
  }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><%= escapeHtml(p.getTitle()) %> — 실습 세션</title>
  <link rel="icon" href="data:,">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
  <link rel="stylesheet" href="/AI/assets/css/dark-theme.css">
  <style>
    body { padding-top: 0; background: var(--bg-primary, #0a0f1e); color: var(--text-primary, #f1f5f9); font-family: 'Noto Sans KR', sans-serif; }

    /* ── Top bar ── */
    .session-topbar {
      position: sticky; top: 0; z-index: 100;
      background: rgba(10,15,30,.95); backdrop-filter: blur(16px);
      border-bottom: 1px solid rgba(255,255,255,.08);
      padding: 12px 24px; display: flex; align-items: center; gap: 16px;
    }
    .topbar-back { color: var(--text-muted,#64748b); text-decoration: none; font-size: .875rem; display: flex; align-items: center; gap: 5px; transition: color .2s; }
    .topbar-back:hover { color: var(--text-primary,#f1f5f9); }
    .topbar-title { flex: 1; font-size: .9375rem; font-weight: 600; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
    .topbar-progress { display: flex; align-items: center; gap: 10px; flex-shrink: 0; }
    .topbar-bar-wrap { width: 120px; height: 6px; background: rgba(255,255,255,.1); border-radius: 99px; overflow: hidden; }
    .topbar-bar-fill { height: 100%; border-radius: 99px; background: linear-gradient(90deg,#3b82f6,#8b5cf6); transition: width .4s; }
    .topbar-pct { font-size: .8rem; color: var(--text-muted,#64748b); min-width: 32px; text-align: right; }
    .timer-badge { display: flex; align-items: center; gap: 5px; font-size: .8125rem; color: var(--text-muted,#64748b); padding: 4px 10px; background: rgba(255,255,255,.05); border-radius: 8px; border: 1px solid rgba(255,255,255,.08); }

    /* ── Layout ── */
    .session-wrap { display: grid; grid-template-columns: 260px 1fr; gap: 0; min-height: calc(100vh - 57px); }

    /* ── Sidebar ── */
    .session-sidebar {
      border-right: 1px solid rgba(255,255,255,.07);
      padding: 20px 16px;
      position: sticky; top: 57px; height: calc(100vh - 57px); overflow-y: auto;
    }
    .sidebar-section-title { font-size: .7rem; font-weight: 700; text-transform: uppercase; letter-spacing: .08em; color: var(--text-muted,#64748b); margin: 0 0 10px; padding: 0 8px; }
    .step-nav-item {
      display: flex; align-items: center; gap: 10px; padding: 9px 10px;
      border-radius: 9px; cursor: pointer; transition: background .18s;
      margin-bottom: 3px; font-size: .8125rem; color: var(--text-secondary,#94a3b8);
    }
    .step-nav-item:hover { background: rgba(255,255,255,.06); }
    .step-nav-item.active { background: rgba(59,130,246,.12); color: #93c5fd; }
    .step-nav-item.done { color: #34d399; }
    .step-nav-num {
      width: 22px; height: 22px; border-radius: 50%; flex-shrink: 0;
      display: flex; align-items: center; justify-content: center;
      font-size: .7rem; font-weight: 700;
      background: rgba(255,255,255,.08); color: var(--text-muted,#64748b);
    }
    .step-nav-item.done .step-nav-num { background: rgba(52,211,153,.2); color: #34d399; }
    .step-nav-item.active .step-nav-num { background: rgba(59,130,246,.25); color: #60a5fa; }
    .step-nav-label { flex: 1; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }

    .sidebar-divider { border: none; border-top: 1px solid rgba(255,255,255,.07); margin: 16px 0; }

    .tools-chip {
      display: inline-flex; align-items: center; gap: 5px; padding: 4px 10px;
      border-radius: 20px; font-size: .7375rem; font-weight: 500;
      background: rgba(59,130,246,.1); border: 1px solid rgba(59,130,246,.2); color: #60a5fa;
      margin: 3px; text-decoration: none;
    }
    .tools-chip:hover { background: rgba(59,130,246,.18); color: #93c5fd; }

    /* ── Main content ── */
    .session-main { padding: 32px 40px 80px; }

    .step-card {
      background: rgba(255,255,255,.03); border: 1px solid rgba(255,255,255,.07);
      border-radius: 16px; padding: 28px; margin-bottom: 24px;
      transition: border-color .2s;
    }
    .step-card.step-active { border-color: rgba(59,130,246,.3); }
    .step-card.step-done { border-color: rgba(52,211,153,.2); background: rgba(52,211,153,.025); }

    .step-header { display: flex; align-items: flex-start; gap: 14px; margin-bottom: 16px; }
    .step-num-circle {
      width: 40px; height: 40px; border-radius: 50%; flex-shrink: 0;
      display: flex; align-items: center; justify-content: center;
      font-size: .875rem; font-weight: 700; color: #fff;
      background: linear-gradient(135deg, #3b82f6, #8b5cf6);
    }
    .step-card.step-done .step-num-circle { background: linear-gradient(135deg,#10b981,#34d399); }
    .step-title { font-size: 1rem; font-weight: 700; margin: 0; letter-spacing: -.01em; line-height: 1.4; }
    .step-body-text { font-size: .9375rem; color: var(--text-secondary,#94a3b8); line-height: 1.8; margin-bottom: 20px; white-space: pre-line; }

    /* Note area */
    .note-label { font-size: .8125rem; font-weight: 600; color: var(--text-muted,#64748b); margin-bottom: 8px; display: flex; align-items: center; gap: 6px; }
    .note-area {
      width: 100%; min-height: 120px; padding: 14px 16px;
      background: rgba(255,255,255,.04); border: 1px solid rgba(255,255,255,.1);
      border-radius: 10px; color: var(--text-primary,#f1f5f9); font-size: .9rem;
      font-family: inherit; line-height: 1.7; resize: vertical; outline: none;
      transition: border-color .2s, box-shadow .2s;
    }
    .note-area::placeholder { color: rgba(148,163,184,.35); }
    .note-area:focus { border-color: rgba(59,130,246,.4); box-shadow: 0 0 0 3px rgba(59,130,246,.08); }

    .step-footer { display: flex; align-items: center; justify-content: space-between; margin-top: 16px; flex-wrap: wrap; gap: 10px; }
    .save-indicator { font-size: .75rem; color: var(--text-muted,#64748b); display: flex; align-items: center; gap: 5px; }
    .save-indicator.saved { color: #34d399; }

    .btn-complete {
      display: inline-flex; align-items: center; gap: 7px;
      padding: 9px 20px; border-radius: 10px; font-size: .875rem; font-weight: 600;
      background: rgba(52,211,153,.12); border: 1px solid rgba(52,211,153,.3); color: #34d399;
      cursor: pointer; transition: all .2s;
    }
    .btn-complete:hover { background: rgba(52,211,153,.22); }
    .btn-complete.done { background: rgba(52,211,153,.2); border-color: rgba(52,211,153,.5); }
    .btn-undo { font-size: .75rem; color: var(--text-muted,#64748b); background: none; border: none; cursor: pointer; padding: 4px 8px; border-radius: 6px; transition: color .2s; }
    .btn-undo:hover { color: var(--text-secondary,#94a3b8); }
    .btn-ai-help {
      display: inline-flex; align-items: center; gap: 7px;
      padding: 9px 14px; border-radius: 10px; font-size: .84rem; font-weight: 700;
      background: rgba(59,130,246,.10); border: 1px solid rgba(59,130,246,.25); color: #93c5fd;
      cursor: pointer; transition: background .2s, border-color .2s;
    }
    .btn-ai-help:hover { background: rgba(59,130,246,.16); border-color: rgba(59,130,246,.38); }

    /* Hint box */
    .hint-box {
      background: rgba(251,191,36,.06); border: 1px solid rgba(251,191,36,.2);
      border-radius: 10px; padding: 14px 16px; margin-top: 16px; display: none;
    }
    .hint-box.show { display: block; }
    .hint-item { font-size: .875rem; color: var(--text-secondary,#94a3b8); line-height: 1.7; margin-bottom: 8px; display: flex; gap: 8px; }
    .hint-item:last-child { margin-bottom: 0; }
    .hint-btn { background: none; border: none; font-size: .8125rem; color: #fbbf24; cursor: pointer; display: flex; align-items: center; gap: 5px; padding: 6px 0; }
    .hint-btn:hover { color: #fde68a; }

    /* Submit section */
    .submit-section {
      background: linear-gradient(135deg, rgba(59,130,246,.1), rgba(139,92,246,.1));
      border: 1px solid rgba(139,92,246,.25); border-radius: 20px;
      padding: 36px; text-align: center; margin-top: 8px;
    }
    .submit-section h3 { font-size: 1.25rem; font-weight: 700; margin-bottom: 10px; }
    .submit-section p { color: var(--text-muted,#64748b); font-size: .9rem; margin-bottom: 24px; }
    .submit-actions { display:flex; gap:10px; justify-content:center; flex-wrap:wrap; }
    .assistant-setup {
      margin: 0 0 20px; padding: 18px 20px; border-radius: 16px;
      background: rgba(251,191,36,.08); border: 1px solid rgba(251,191,36,.22);
    }
    .assistant-setup__title { font-size: .98rem; font-weight: 800; color: #fde68a; margin-bottom: 6px; }
    .assistant-setup__desc { font-size: .86rem; color: #fcd34d; line-height: 1.65; margin-bottom: 12px; }
    .assistant-setup__actions { display:flex; gap:10px; flex-wrap:wrap; }
    .assistant-setup__btn {
      display:inline-flex; align-items:center; gap:7px; padding:10px 14px; border-radius:10px;
      text-decoration:none; font-size:.84rem; font-weight:700; color:#fff;
      background:rgba(255,255,255,.08); border:1px solid rgba(255,255,255,.14);
    }
    .assistant-setup__btn--primary { background:linear-gradient(135deg,#f59e0b,#d97706); border:none; color:#111827; }
    .btn-submit-primary {
      display: inline-flex; align-items: center; gap: 8px;
      padding: 13px 30px; border-radius: 12px; font-size: .9375rem; font-weight: 700;
      background: linear-gradient(135deg, #3b82f6, #8b5cf6);
      color: #fff; text-decoration: none; border: none; cursor: pointer;
      box-shadow: 0 4px 20px rgba(59,130,246,.35); transition: opacity .2s, transform .15s;
    }
    .btn-submit-primary:hover { opacity: .9; transform: translateY(-1px); color: #fff; }
    .btn-submit-disabled { opacity: .4; pointer-events: none; }

    @media (max-width: 900px) {
      .session-wrap { grid-template-columns: 1fr; }
      .session-sidebar { position: static; height: auto; border-right: none; border-bottom: 1px solid rgba(255,255,255,.07); }
      .session-main { padding: 20px 16px 60px; }
      .topbar-bar-wrap { display: none; }
    }

    /* ── AI Assistant Panel ── */
    .ai-fab {
      position: fixed; bottom: 28px; right: 28px; z-index: 200;
      width: 56px; height: 56px; border-radius: 50%;
      background: linear-gradient(135deg,#3b82f6,#8b5cf6);
      border: none; cursor: pointer; display: flex; align-items: center; justify-content: center;
      box-shadow: 0 4px 20px rgba(59,130,246,.5); transition: transform .2s, box-shadow .2s;
      color: #fff; font-size: 1.25rem;
    }
    .ai-fab:hover { transform: scale(1.08); box-shadow: 0 6px 28px rgba(59,130,246,.7); }
    .ai-fab .ai-fab-badge {
      position: absolute; top: -4px; right: -4px;
      background: #10b981; color: #fff; font-size: .6rem; font-weight: 700;
      padding: 2px 5px; border-radius: 99px; white-space: nowrap;
    }

    .ai-panel {
      position: fixed; bottom: 96px; right: 28px; z-index: 199;
      width: 380px; max-height: 600px;
      background: #0f1629; border: 1px solid rgba(59,130,246,.3);
      border-radius: 20px; display: flex; flex-direction: column;
      box-shadow: 0 20px 60px rgba(0,0,0,.5);
      transform: translateY(20px) scale(.96); opacity: 0; pointer-events: none;
      transition: transform .25s, opacity .25s;
    }
    .ai-panel.open { transform: translateY(0) scale(1); opacity: 1; pointer-events: all; }

    .ai-panel-header {
      padding: 14px 18px; border-bottom: 1px solid rgba(255,255,255,.08);
      display: flex; align-items: center; gap: 10px;
    }
    .ai-panel-title { flex: 1; font-size: .9375rem; font-weight: 700; }
    .ai-credit-badge {
      font-size: .7rem; font-weight: 600; padding: 3px 8px; border-radius: 99px;
      background: rgba(59,130,246,.15); border: 1px solid rgba(59,130,246,.3); color: #60a5fa;
    }
    .ai-panel-close { background: none; border: none; color: var(--text-muted,#64748b); cursor: pointer; font-size: 1.1rem; padding: 2px; }
    .ai-panel-close:hover { color: var(--text-primary,#f1f5f9); }

    .ai-msg-list {
      flex: 1; overflow-y: auto; padding: 16px; display: flex; flex-direction: column; gap: 10px;
      min-height: 200px; max-height: 380px;
    }
    .ai-bubble {
      max-width: 90%; padding: 10px 14px; border-radius: 14px;
      font-size: .875rem; line-height: 1.6; white-space: pre-wrap;
    }
    .ai-bubble--user { background: rgba(59,130,246,.18); border: 1px solid rgba(59,130,246,.25); align-self: flex-end; color: #e2eeff; border-radius: 14px 14px 4px 14px; }
    .ai-bubble--assistant { background: rgba(255,255,255,.05); border: 1px solid rgba(255,255,255,.08); align-self: flex-start; color: var(--text-secondary,#94a3b8); border-radius: 14px 14px 14px 4px; }
    .ai-loading { display: flex; gap: 5px; align-items: center; padding: 12px 16px; }
    .ai-loading span { width: 7px; height: 7px; border-radius: 50%; background: #60a5fa; animation: aiDot 1.2s infinite; }
    .ai-loading span:nth-child(2) { animation-delay: .2s; }
    .ai-loading span:nth-child(3) { animation-delay: .4s; }
    @keyframes aiDot { 0%,80%,100% { transform: scale(.6); opacity:.3; } 40% { transform: scale(1); opacity:1; } }

    .ai-no-key {
      margin: 0 12px 10px; padding: 10px 14px; border-radius: 10px;
      background: rgba(251,191,36,.08); border: 1px solid rgba(251,191,36,.25);
      font-size: .8125rem; color: #fbbf24; display: none;
    }
    .ai-no-key a { color: #fde68a; font-weight: 600; }

    .ai-input-row {
      padding: 12px; border-top: 1px solid rgba(255,255,255,.07);
      display: flex; gap: 8px; align-items: flex-end;
    }
    .ai-input-row textarea {
      flex: 1; background: rgba(255,255,255,.05); border: 1px solid rgba(255,255,255,.1);
      border-radius: 10px; color: var(--text-primary,#f1f5f9); font-size: .875rem;
      padding: 9px 12px; resize: none; outline: none; font-family: inherit;
      min-height: 38px; max-height: 100px; line-height: 1.5;
      transition: border-color .2s;
    }
    .ai-input-row textarea:focus { border-color: rgba(59,130,246,.4); }
    .ai-input-row textarea::placeholder { color: rgba(148,163,184,.35); }
    .ai-send-btn {
      width: 38px; height: 38px; border-radius: 10px; flex-shrink: 0;
      background: linear-gradient(135deg,#3b82f6,#8b5cf6); border: none;
      color: #fff; cursor: pointer; display: flex; align-items: center; justify-content: center;
      transition: opacity .2s;
    }
    .ai-send-btn:hover { opacity: .9; }
    .ai-send-btn:disabled { opacity: .4; cursor: not-allowed; }

    @media (max-width: 480px) {
      .ai-panel { width: calc(100vw - 24px); right: 12px; bottom: 80px; }
      .ai-fab { bottom: 16px; right: 16px; }
    }
  </style>
</head>
<body>

<!-- ── Top bar ── -->
<div class="session-topbar">
  <a href="/AI/user/lab/detail.jsp?id=<%= projectId %>" class="topbar-back">
    <i class="bi bi-chevron-left"></i>돌아가기
  </a>
  <div class="topbar-title"><%= escapeHtml(p.getTitle()) %></div>
  <div class="topbar-progress">
    <div class="topbar-bar-wrap">
      <div class="topbar-bar-fill" id="topBarFill" style="width:0%;"></div>
    </div>
    <span class="topbar-pct" id="topBarPct">0%</span>
    <div class="timer-badge"><i class="bi bi-clock"></i><span id="timerDisplay">00:00</span></div>
  </div>
</div>

<div class="session-wrap">
  <!-- ── Sidebar ── -->
  <div class="session-sidebar">
    <div class="sidebar-section-title">진행 단계</div>
    <% if (steps != null) { for (int i = 0; i < steps.size(); i++) {
       String label = steps.get(i);
       // extract step title from "N단계: 제목 — ..." format
       int dashIdx = label.indexOf("—");
       int colonIdx = label.indexOf(":");
       String navLabel = label;
       if (colonIdx > 0 && dashIdx > colonIdx) {
         navLabel = label.substring(colonIdx + 1, dashIdx).trim();
       } else if (colonIdx > 0) {
         navLabel = label.substring(colonIdx + 1, Math.min(label.length(), colonIdx + 30)).trim();
       }
       if (navLabel.length() > 22) navLabel = navLabel.substring(0, 22) + "…";
    %>
    <div class="step-nav-item" id="nav-<%= i %>" onclick="scrollToStep(<%= i %>)">
      <div class="step-nav-num"><%= i+1 %></div>
      <div class="step-nav-label"><%= escapeHtml(navLabel) %></div>
      <i class="bi bi-check2" style="display:none;flex-shrink:0;" id="nav-check-<%= i %>"></i>
    </div>
    <% } } %>

    <hr class="sidebar-divider">
    <div class="sidebar-section-title">필요한 도구</div>
    <% if (p.getToolsRequired() != null) { for (String tool : p.getToolsRequired()) { %>
    <a href="/AI/user/tools/navigator.jsp?keyword=<%= escapeHtmlAttribute(tool) %>"
       class="tools-chip" target="_blank">
      <i class="bi bi-cpu"></i><%= escapeHtml(tool) %>
    </a>
    <% } } %>

    <hr class="sidebar-divider">
    <div style="padding: 0 8px;">
      <div style="font-size:.75rem; color:var(--text-muted,#64748b); margin-bottom:8px;">내 진행률</div>
      <div style="background:rgba(255,255,255,.07);border-radius:99px;height:8px;overflow:hidden;">
        <div id="sidebarBar" style="height:100%;border-radius:99px;background:linear-gradient(90deg,#3b82f6,#8b5cf6);transition:width .4s;width:0%;"></div>
      </div>
      <div style="font-size:.75rem;color:var(--text-muted,#64748b);margin-top:6px;" id="sidebarPctText">0 / <%= totalSteps %> 단계 완료</div>
    </div>
  </div>

  <!-- ── Main ── -->
  <div class="session-main">
    <% if (!canUseAI) { %>
    <div class="assistant-setup">
      <div class="assistant-setup__title"><i class="bi bi-robot"></i> AI 도우미 사용 전 설정이 필요합니다</div>
      <div class="assistant-setup__desc"><%= escapeHtml(aiSetupMessage) %></div>
      <div class="assistant-setup__actions">
        <a href="<%= aiSetupUrl %>" class="assistant-setup__btn assistant-setup__btn--primary"><i class="bi bi-arrow-right-circle"></i><%= escapeHtml(aiSetupLabel) %></a>
        <a href="/AI/user/mypage.jsp?tab=apikeys&return=<%= encodedReturnToSession %>" class="assistant-setup__btn"><i class="bi bi-key"></i>API 키 관리</a>
      </div>
    </div>
    <% } %>
    <% if (steps != null) { for (int i = 0; i < steps.size(); i++) {
       String step = steps.get(i);
       // parse "N단계: 제목 — 내용" or just show full text
       String stepTitle = "";
       String stepBody = step;
       int dashIdx = step.indexOf(" — ");
       int colonIdx = step.indexOf(": ");
       if (colonIdx > 0 && colonIdx < 10) {
         stepTitle = step.substring(0, dashIdx > 0 ? dashIdx : step.length());
         if (dashIdx > 0) stepBody = step.substring(dashIdx + 3);
       }
    %>
    <div class="step-card" id="step-card-<%= i %>">
      <div class="step-header">
        <div class="step-num-circle" id="step-circle-<%= i %>"><%= i+1 %></div>
        <div>
          <% if (!stepTitle.isEmpty()) { %>
          <h3 class="step-title"><%= escapeHtml(stepTitle) %></h3>
          <% } else { %>
          <h3 class="step-title">단계 <%= i+1 %></h3>
          <% } %>
        </div>
      </div>

      <p class="step-body-text"><%= escapeHtml(stepBody) %></p>

      <div class="note-label">
        <i class="bi bi-pencil-square"></i>내 작업 노트
        <span style="font-weight:400;font-size:.75rem;color:var(--text-muted,#64748b);">— 이 단계에서 시도한 내용, 결과, 느낀 점을 자유롭게 기록하세요</span>
      </div>
      <textarea class="note-area" id="note-<%= i %>"
                placeholder="여기에 작업 내용을 기록하세요...&#10;예) 사용한 프롬프트, 얻은 결과, 개선 방향 등"
                oninput="onNoteChange(<%= i %>)"></textarea>

      <% if (p.hasHints() && p.getHints().size() > i) { %>
      <button class="hint-btn" onclick="toggleHint(<%= i %>)">
        <i class="bi bi-lightbulb"></i>힌트 보기
      </button>
      <div class="hint-box" id="hint-<%= i %>">
        <div class="hint-item">
          <i class="bi bi-lightbulb-fill" style="color:#fbbf24;flex-shrink:0;margin-top:2px;"></i>
          <span><%= escapeHtml(p.getHints().get(Math.min(i, p.getHints().size()-1))) %></span>
        </div>
      </div>
      <% } %>

      <div class="step-footer">
        <div class="save-indicator" id="save-ind-<%= i %>">
          <i class="bi bi-cloud-upload"></i><span>자동 저장</span>
        </div>
        <div style="display:flex;align-items:center;gap:8px;">
          <button class="btn-ai-help" type="button" onclick="openAI(<%= i %>)">
            <i class="bi bi-stars"></i>AI 도움
          </button>
          <button class="btn-undo" id="undo-<%= i %>" onclick="undoStep(<%= i %>)" style="display:none;">
            <i class="bi bi-arrow-counterclockwise"></i>취소
          </button>
          <button class="btn-complete" id="btn-complete-<%= i %>" onclick="completeStep(<%= i %>)">
            <i class="bi bi-check-circle" id="complete-icon-<%= i %>"></i>
            <span id="complete-text-<%= i %>">완료</span>
          </button>
        </div>
      </div>
    </div>
    <% } } %>

    <!-- Submit section -->
    <div class="submit-section" id="submitSection">
      <i class="bi bi-award" style="font-size:2.5rem;background:linear-gradient(135deg,#3b82f6,#8b5cf6);-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;display:block;margin-bottom:16px;"></i>
      <h3>실습을 완료하셨나요?</h3>
      <p>모든 단계를 완료하면 결과물을 제출하고 포트폴리오에 기록할 수 있습니다.<br>지금까지 작성한 노트가 자동으로 포함됩니다.</p>
      <div class="submit-actions">
        <a href="/AI/user/lab/submit.jsp?id=<%= projectId %>"
           class="btn-submit-primary btn-submit-disabled" id="submitBtn">
          <i class="bi bi-send"></i>결과물 제출하기
        </a>
        <a href="<%= playgroundHref %>"
           class="btn-submit-primary" style="background:linear-gradient(135deg,#0ea5e9,#2563eb);box-shadow:0 4px 20px rgba(14,165,233,.35);">
          <i class="bi bi-terminal"></i>Playground
        </a>
      </div>
      <div style="margin-top:12px;font-size:.8125rem;color:var(--text-muted,#64748b);" id="submitHint">
        모든 단계를 완료하면 제출 버튼이 활성화됩니다.
      </div>
    </div>
  </div>
</div>

<button type="button" class="ai-fab" onclick="openAI(Math.min(Math.max(currentStepCtx, 0), Math.max(TOTAL_STEPS - 1, 0)))" aria-label="AI 도우미 열기">
  <i class="bi bi-stars"></i>
  <span class="ai-fab-badge"><%= canUseAI ? "AI" : "설정" %></span>
</button>

<div class="ai-panel" id="aiPanel" aria-hidden="true">
  <div class="ai-panel-header">
    <i class="bi bi-robot" style="color:#60a5fa;"></i>
    <div class="ai-panel-title">실습 AI 도우미</div>
    <div class="ai-credit-badge" id="aiCreditBadge"><%= hasApiKey ? "BYOK" : creditBalance + " 크레딧" %></div>
    <button type="button" class="ai-panel-close" onclick="closeAI()" aria-label="닫기">
      <i class="bi bi-x-lg"></i>
    </button>
  </div>
  <div class="ai-msg-list" id="aiMsgList"></div>
  <div class="ai-no-key" id="aiNoKey">
    AI 도우미를 쓰려면 먼저 설정이 필요합니다.
    <a href="<%= aiSetupUrl %>"><%= escapeHtml(aiSetupLabel) %></a>
  </div>
  <div class="ai-input-row">
    <textarea id="aiInput" placeholder="현재 단계에서 막힌 점을 질문하세요" onkeydown="if (event.key === 'Enter' && !event.shiftKey) { event.preventDefault(); sendAI(); }"></textarea>
    <button type="button" class="ai-send-btn" id="aiSendBtn" onclick="sendAI()" aria-label="전송">
      <i class="bi bi-send-fill"></i>
    </button>
  </div>
</div>

<script>
const TOTAL_STEPS = <%= totalSteps %>;

const PROJECT_ID  = <%= projectId %>;
const SAVED_TIME  = <%= savedTime %>;

// ── State ──────────────────────────────────────────────────────────
let completedSteps = new Set();
let stepNotes      = {};
let saveTimer      = null;
let timerInterval  = null;
let elapsedSeconds = SAVED_TIME * 60;

// ── Load saved state ───────────────────────────────────────────────
(function init() {
  try {
    const bm = <%= savedBookmarks %>;
    bm.forEach(i => completedSteps.add(i));
  } catch(e) {}
  try {
    const n = <%= savedNotes %>;
    Object.keys(n).forEach(k => { stepNotes[k] = n[k]; });
  } catch(e) {}

  // Restore notes to textareas
  for (let i = 0; i < TOTAL_STEPS; i++) {
    const ta = document.getElementById('note-' + i);
    if (ta && stepNotes[i]) ta.value = stepNotes[i];
    if (completedSteps.has(i)) renderStepDone(i);
  }
  updateProgress();
  startTimer();
})();

// ── Timer ──────────────────────────────────────────────────────────
function startTimer() {
  timerInterval = setInterval(() => {
    elapsedSeconds++;
    const m = String(Math.floor(elapsedSeconds / 60)).padStart(2, '0');
    const s = String(elapsedSeconds % 60).padStart(2, '0');
    document.getElementById('timerDisplay').textContent = m + ':' + s;
  }, 1000);
}

// ── Step actions ───────────────────────────────────────────────────
function completeStep(i) {
  completedSteps.add(i);
  renderStepDone(i);
  updateProgress();
  scheduleSave(i);
}

function undoStep(i) {
  completedSteps.delete(i);
  renderStepUndone(i);
  updateProgress();
  scheduleSave(i);
}

function renderStepDone(i) {
  const card = document.getElementById('step-card-' + i);
  card.classList.remove('step-active');
  card.classList.add('step-done');
  document.getElementById('complete-icon-' + i).className = 'bi bi-check-circle-fill';
  document.getElementById('complete-text-' + i).textContent = '완료됨';
  document.getElementById('btn-complete-' + i).classList.add('done');
  document.getElementById('undo-' + i).style.display = 'inline-flex';

  const nav = document.getElementById('nav-' + i);
  nav.classList.add('done'); nav.classList.remove('active');
  document.getElementById('nav-check-' + i).style.display = 'block';
}

function renderStepUndone(i) {
  const card = document.getElementById('step-card-' + i);
  card.classList.remove('step-done');
  document.getElementById('complete-icon-' + i).className = 'bi bi-check-circle';
  document.getElementById('complete-text-' + i).textContent = '완료';
  document.getElementById('btn-complete-' + i).classList.remove('done');
  document.getElementById('undo-' + i).style.display = 'none';

  const nav = document.getElementById('nav-' + i);
  nav.classList.remove('done');
  document.getElementById('nav-check-' + i).style.display = 'none';
}

// ── Notes ──────────────────────────────────────────────────────────
function onNoteChange(i) {
  const ta = document.getElementById('note-' + i);
  stepNotes[i] = ta ? ta.value : '';
  const ind = document.getElementById('save-ind-' + i);
  if (ind) { ind.className = 'save-indicator'; ind.innerHTML = '<i class="bi bi-cloud-upload"></i><span>저장 중...</span>'; }
  scheduleSave(i);
}

// ── Progress ───────────────────────────────────────────────────────
function updateProgress() {
  const done = completedSteps.size;
  const pct  = TOTAL_STEPS > 0 ? Math.round(done / TOTAL_STEPS * 100) : 0;
  document.getElementById('topBarFill').style.width = pct + '%';
  document.getElementById('topBarPct').textContent = pct + '%';
  document.getElementById('sidebarBar').style.width = pct + '%';
  document.getElementById('sidebarPctText').textContent = done + ' / ' + TOTAL_STEPS + ' 단계 완료';

  const btn = document.getElementById('submitBtn');
  const hint = document.getElementById('submitHint');
  if (pct === 100) {
    btn.classList.remove('btn-submit-disabled');
    hint.style.display = 'none';
  } else {
    btn.classList.add('btn-submit-disabled');
    hint.style.display = '';
    hint.textContent = (TOTAL_STEPS - done) + '개 단계가 남았습니다.';
  }
}

// ── Scroll navigation ──────────────────────────────────────────────
function scrollToStep(i) {
  document.querySelectorAll('.step-nav-item').forEach(el => el.classList.remove('active'));
  const nav = document.getElementById('nav-' + i);
  if (nav && !nav.classList.contains('done')) nav.classList.add('active');
  const card = document.getElementById('step-card-' + i);
  if (card) { card.scrollIntoView({ behavior: 'smooth', block: 'start' }); card.classList.add('step-active'); }
}

// ── Hints ──────────────────────────────────────────────────────────
function toggleHint(i) {
  const box = document.getElementById('hint-' + i);
  if (box) box.classList.toggle('show');
}

// ── Save to server ─────────────────────────────────────────────────
function scheduleSave(stepIdx) {
  clearTimeout(saveTimer);
  saveTimer = setTimeout(() => saveProgress(stepIdx), 1500);
}

function saveProgress(stepIdx) {
  const bm     = JSON.stringify(Array.from(completedSteps));
  const notes  = JSON.stringify(stepNotes);
  const done   = completedSteps.size;
  const pct    = TOTAL_STEPS > 0 ? Math.round(done / TOTAL_STEPS * 100) : 0;
  const status = pct === 100 ? 'Completed' : (done > 0 ? 'In Progress' : 'Not Started');
  const mins   = Math.floor(elapsedSeconds / 60);

  fetch('/AI/user/lab/save-progress.jsp', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({ projectId: PROJECT_ID, bookmarks: bm, notes: notes, pct: pct, status: status, minutes: mins })
  }).then(r => r.json()).then(data => {
    if (stepIdx !== undefined) {
      const ind = document.getElementById('save-ind-' + stepIdx);
      if (ind) { ind.className = 'save-indicator saved'; ind.innerHTML = '<i class="bi bi-cloud-check-fill"></i><span>저장됨</span>'; setTimeout(() => { ind.className = 'save-indicator'; ind.innerHTML = '<i class="bi bi-cloud-upload"></i><span>자동 저장</span>'; }, 2000); }
    }
  }).catch(() => {});
}

// Auto-save every 30s
setInterval(() => saveProgress(), 30000);

// Save on unload
window.addEventListener('beforeunload', () => saveProgress());

// ── AI Assistant ────────────────────────────────────────────────────
const CAN_USE_AI  = <%= canUseAI %>;
const CREDIT_BAL  = <%= creditBalance %>;
const HAS_API_KEY = <%= hasApiKey %>;
let aiMessages    = [];
let currentStepCtx = 0;

async function persistLabExecution(promptText, responseText, meta) {
  try {
    await fetch('/AI/api/lab-sessions/', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({
        projectId: String(PROJECT_ID),
        sessionType: 'project',
        title: '실습 도우미 실행',
        codeContent: promptText,
        resultContent: responseText,
        modelUsed: meta.model || '',
        tokensUsed: String((meta.promptTokens || 0) + (meta.outputTokens || 0)),
        creditsUsed: String(meta.creditsUsed || 0),
        executionTimeMs: String(meta.executionTimeMs || 0),
        status: 'completed',
        metadata: JSON.stringify({
          feature: 'lab_assistant',
          stepIndex: currentStepCtx,
          byok: !!meta.byok
        })
      })
    });
  } catch (e) {}
}

function openAI(stepIdx) {
  if (TOTAL_STEPS === 0) return;
  currentStepCtx = stepIdx;
  document.getElementById('aiPanel').classList.add('open');
  document.getElementById('aiPanel').setAttribute('aria-hidden', 'false');
  const stepCard = document.getElementById('step-card-' + stepIdx);
  const stepText = stepCard ? stepCard.querySelector('.step-body-text')?.textContent?.trim() : '';
  if (aiMessages.length === 0) {
    addAIBubble('assistant', '안녕하세요! 실습 도우미입니다. 지금 진행 중인 단계에서 막히거나 궁금한 점을 질문해 주세요.' + (stepText ? '\n\n현재 단계 요약:\n' + stepText.substring(0, 180) : ''));
  }
  document.getElementById('aiInput').focus();
}

function closeAI() {
  document.getElementById('aiPanel').classList.remove('open');
  document.getElementById('aiPanel').setAttribute('aria-hidden', 'true');
}

function addAIBubble(role, text) {
  aiMessages.push({ role, text });
  const list = document.getElementById('aiMsgList');
  const div = document.createElement('div');
  div.className = 'ai-bubble ai-bubble--' + role;
  div.textContent = text;
  list.appendChild(div);
  list.scrollTop = list.scrollHeight;
}

function addAILoading() {
  const list = document.getElementById('aiMsgList');
  const div = document.createElement('div');
  div.className = 'ai-bubble ai-bubble--assistant ai-loading';
  div.id = 'aiLoadingBubble';
  div.innerHTML = '<span></span><span></span><span></span>';
  list.appendChild(div);
  list.scrollTop = list.scrollHeight;
}

function removeAILoading() {
  const el = document.getElementById('aiLoadingBubble');
  if (el) el.remove();
}

async function sendAI() {
  const input = document.getElementById('aiInput');
  const msg = input.value.trim();
  if (!msg) return;
  input.value = '';

  if (!CAN_USE_AI) {
    document.getElementById('aiNoKey').style.display = 'block';
    return;
  }

  addAIBubble('user', msg);
  addAILoading();
  document.getElementById('aiSendBtn').disabled = true;

  // Build context from current step
  const stepCard = document.getElementById('step-card-' + currentStepCtx);
  const stepText = stepCard ? stepCard.querySelector('.step-body-text')?.textContent?.trim().substring(0, 500) : '';
  const note = stepNotes[currentStepCtx] || '';
  const systemPrompt = `당신은 AI Workflow Lab의 실습 도우미입니다. 사용자는 지금 다음 실습 단계를 진행 중입니다:\n\n[현재 단계]\n${stepText}\n\n[사용자 작업 노트]\n${note}\n\n이 맥락에서 사용자의 질문에 실용적이고 구체적으로 답변하세요. 프롬프트 예시나 코드가 필요하면 반드시 포함하세요.`;

  try {
    const startedAt = Date.now();
    const resp = await fetch('/AI/api/chat.jsp', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({ message: msg, system: systemPrompt, projectId: PROJECT_ID, feature: 'lab_assistant' })
    });
    const data = await resp.json();
    removeAILoading();

    if (data.ok) {
      addAIBubble('assistant', data.message);
      await persistLabExecution(msg, data.message, {
        model: data.model,
        promptTokens: data.promptTokens || 0,
        outputTokens: data.outputTokens || 0,
        creditsUsed: data.creditsUsed || 0,
        byok: data.byok,
        executionTimeMs: Date.now() - startedAt
      });
      if (data.balance >= 0) {
        document.getElementById('aiCreditBadge').textContent = data.balance + ' 크레딧';
      }
    } else if (data.error === 'no_credits') {
      addAIBubble('assistant', '크레딧이 부족합니다. 플랜을 업그레이드하면 더 많은 AI 도우미를 이용할 수 있어요.');
    } else if (data.error === 'no_key') {
      document.getElementById('aiNoKey').style.display = 'block';
    } else {
      addAIBubble('assistant', '오류가 발생했습니다: ' + (data.message || '잠시 후 다시 시도해주세요.'));
    }
  } catch(e) {
    removeAILoading();
    addAIBubble('assistant', '네트워크 오류가 발생했습니다. 잠시 후 다시 시도해주세요.');
  }
  document.getElementById('aiSendBtn').disabled = false;
  document.getElementById('aiInput').focus();
}

document.addEventListener('keydown', e => {
  if (e.key === 'Escape') closeAI();
});

// IntersectionObserver to highlight active step in nav
const observer = new IntersectionObserver(entries => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      const match = entry.target.id.match(/step-card-(\d+)/);
      if (match) {
        const i = parseInt(match[1]);
        document.querySelectorAll('.step-nav-item').forEach(el => el.classList.remove('active'));
        const nav = document.getElementById('nav-' + i);
        if (nav && !nav.classList.contains('done')) nav.classList.add('active');
      }
    }
  });
}, { threshold: 0.4 });

document.querySelectorAll('.step-card').forEach(c => observer.observe(c));
</script>
</body>
</html>
