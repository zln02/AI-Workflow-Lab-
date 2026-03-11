<%@ page contentType="text/html; charset=UTF-8" buffer="128kb" autoFlush="true" %>
<%@ page isELIgnored="true" %>
<%@ page import="dao.CreditDAO, dao.LabProjectDAO, dao.LabSessionDAO" %>
<%@ page import="model.LabProject, model.LabSession, model.User" %>
<%@ page import="java.util.List" %>
<%@ include file="/AI/user/_common.jsp" %>
<%
  User user = (User) session.getAttribute("user");
  if (user == null) {
    response.sendRedirect("/AI/user/login.jsp?redirect=" + java.net.URLEncoder.encode(request.getRequestURI() + "?" + safeString(request.getQueryString(), ""), "UTF-8"));
    return;
  }

  int projectId = 0;
  try { projectId = Integer.parseInt(request.getParameter("id")); } catch (Exception e) {}

  LabProjectDAO projectDao = new LabProjectDAO();
  LabProject project = projectId > 0 ? projectDao.findById(projectId) : null;

  int creditBalance = 0;
  try { creditBalance = new CreditDAO().getBalance(user.getId()); } catch (Exception e) {}

  List<LabSession> recentSessions = null;
  String sessionLoadError = null;
  try {
    LabSessionDAO labSessionDAO = new LabSessionDAO();
    recentSessions = project != null
      ? labSessionDAO.findRecentByUserAndProject(user.getId(), project.getId(), 6)
      : labSessionDAO.findRecentByUser(user.getId(), 6);
  } catch (Exception e) {
    sessionLoadError = e.getMessage();
  }

  boolean hasApiKey = false;
  try {
    java.sql.Connection dbConn = db.DBConnect.getConnection();
    java.sql.PreparedStatement ps = dbConn.prepareStatement("SELECT id FROM user_api_keys WHERE user_id=? AND is_verified=1 LIMIT 1");
    ps.setLong(1, user.getId());
    java.sql.ResultSet rs = ps.executeQuery();
    hasApiKey = rs.next();
    rs.close(); ps.close(); dbConn.close();
  } catch (Exception e) {}
  boolean hasPlatformKey = System.getenv("ANTHROPIC_API_KEY") != null && !System.getenv("ANTHROPIC_API_KEY").trim().isEmpty();
  boolean canUseAI = hasApiKey || (hasPlatformKey && creditBalance > 0);
  String returnToPlayground = "/AI/user/lab/playground.jsp?id=" + projectId;
  String encodedReturnToPlayground = java.net.URLEncoder.encode(returnToPlayground, "UTF-8");
  String setupUrl = hasPlatformKey ? "/AI/user/pricing.jsp" : "/AI/user/mypage.jsp?tab=apikeys&return=" + encodedReturnToPlayground;
  String secondarySetupUrl = "/AI/user/mypage.jsp?tab=apikeys&return=" + encodedReturnToPlayground;
  String setupPrimaryLabel = hasPlatformKey ? "크레딧/플랜 보기" : "API 키 연결하기";
  String setupMessage = hasPlatformKey
    ? "이 서버는 크레딧 방식 실행을 지원합니다. 크레딧이 없으면 충전하거나, 본인 Anthropic API 키를 연결해서 바로 실행할 수 있습니다."
    : "현재 서버 공용 AI 키가 없어서, 먼저 본인 Anthropic API 키를 연결해야 실습을 실행할 수 있습니다.";
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><%= project != null ? escapeHtml(project.getTitle()) + " - " : "" %>AI Playground</title>
  <link rel="icon" href="data:,">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
  <link rel="stylesheet" href="/AI/assets/css/dark-theme.css">
  <style>
    body { padding-top:60px; background:#07111f; color:#f8fafc; font-family:'Noto Sans KR',sans-serif; }
    .play-wrap { max-width:1280px; margin:0 auto; padding:32px 24px 80px; }
    .hero { padding:28px; border-radius:24px; margin-bottom:20px; border:1px solid rgba(255,255,255,.08);
      background: radial-gradient(circle at top right, rgba(59,130,246,.16), transparent 26%), linear-gradient(160deg, rgba(15,23,42,.95), rgba(8,15,29,.98));}
    .hero h1 { margin:10px 0 8px; font-size:clamp(1.8rem,4vw,2.8rem); font-weight:800; }
    .hero p { margin:0; color:#94a3b8; max-width:780px; }
    .hero-meta { display:flex; gap:10px; flex-wrap:wrap; margin-top:18px; }
    .hero-pill { padding:8px 12px; border-radius:999px; background:rgba(255,255,255,.05); border:1px solid rgba(255,255,255,.08); color:#cbd5e1; font-size:.82rem; }
    .layout { display:grid; grid-template-columns:1.25fr .75fr; gap:18px; }
    .panel { border-radius:20px; border:1px solid rgba(255,255,255,.08); background:rgba(255,255,255,.04); }
    .panel-head { padding:18px 20px; border-bottom:1px solid rgba(255,255,255,.07); display:flex; justify-content:space-between; gap:12px; align-items:center; }
    .panel-head h2 { margin:0; font-size:1rem; font-weight:700; }
    .panel-body { padding:20px; }
    .field { margin-bottom:16px; }
    .field label { display:block; margin-bottom:8px; color:#cbd5e1; font-size:.82rem; font-weight:600; }
    .field textarea, .field input, .field select {
      width:100%; border-radius:12px; border:1px solid rgba(255,255,255,.10); background:rgba(255,255,255,.05); color:#f8fafc;
      padding:12px 14px; font-size:.92rem; outline:none;
    }
    .field textarea { min-height:160px; resize:vertical; }
    .helper-row { display:flex; justify-content:space-between; gap:12px; flex-wrap:wrap; color:#94a3b8; font-size:.78rem; margin-top:8px; }
    .btn-run {
      display:inline-flex; align-items:center; gap:8px; border:none; border-radius:12px; padding:12px 18px; font-weight:700;
      color:#fff; background:linear-gradient(135deg,#3b82f6,#8b5cf6); box-shadow:0 10px 26px rgba(59,130,246,.22);
    }
    .btn-run:disabled { opacity:.45; cursor:not-allowed; }
    .status { font-size:.8rem; color:#94a3b8; }
    .result-box { min-height:220px; white-space:pre-wrap; line-height:1.7; color:#dbeafe; }
    .empty { color:#64748b; }
    .history-list { display:grid; gap:12px; }
    .history-item { padding:14px; border-radius:16px; background:rgba(255,255,255,.04); border:1px solid rgba(255,255,255,.08); }
    .history-title { font-size:.92rem; font-weight:700; color:#f8fafc; margin-bottom:6px; }
    .history-meta { display:flex; gap:10px; flex-wrap:wrap; color:#94a3b8; font-size:.76rem; margin-bottom:8px; }
    .history-body { color:#cbd5e1; font-size:.84rem; line-height:1.65; display:-webkit-box; -webkit-line-clamp:3; -webkit-box-orient:vertical; overflow:hidden; }
    .quick-buttons { display:flex; gap:8px; flex-wrap:wrap; margin-top:10px; }
    .quick-btn { padding:8px 10px; border-radius:10px; border:1px solid rgba(255,255,255,.10); background:rgba(255,255,255,.05); color:#cbd5e1; font-size:.78rem; cursor:pointer; }
    .warn { color:#fbbf24; font-size:.82rem; }
    .setup-card {
      margin-bottom:18px; padding:18px 20px; border-radius:20px;
      border:1px solid rgba(251,191,36,.24); background:rgba(251,191,36,.08);
    }
    .setup-card h2 { margin:0 0 8px; font-size:1rem; font-weight:800; color:#fef3c7; }
    .setup-card p { margin:0; color:#fde68a; line-height:1.65; }
    .setup-actions { display:flex; gap:10px; flex-wrap:wrap; margin-top:14px; }
    .setup-btn {
      display:inline-flex; align-items:center; gap:8px; padding:10px 14px; border-radius:12px;
      text-decoration:none; font-weight:700; font-size:.86rem; border:1px solid rgba(255,255,255,.14);
      background:rgba(255,255,255,.08); color:#fff;
    }
    .setup-btn--primary { background:linear-gradient(135deg,#f59e0b,#d97706); border:none; color:#111827; }
    .setup-list { margin:12px 0 0; padding-left:18px; color:#fde68a; font-size:.82rem; line-height:1.7; }
    @media (max-width: 1024px) { .layout { grid-template-columns:1fr; } }
  </style>
</head>
<body>
<%@ include file="/AI/partials/header.jsp" %>
<div class="play-wrap">
  <section class="hero">
    <div style="color:#60a5fa;font-size:.76rem;font-weight:700;letter-spacing:.12em;text-transform:uppercase;">Playground</div>
    <h1><%= project != null ? escapeHtml(project.getTitle()) : "실습 Playground" %></h1>
    <p>실습 중 떠오른 프롬프트와 아이디어를 바로 실행하고, 결과를 세션 로그로 남길 수 있는 작업 공간입니다.</p>
    <div class="hero-meta">
      <span class="hero-pill"><i class="bi bi-lightning-charge"></i> 실습 실행 기록 저장</span>
      <span class="hero-pill"><i class="bi bi-coin"></i> 현재 크레딧 <%= creditBalance %></span>
      <span class="hero-pill"><i class="bi bi-key"></i> API 키 <%= hasApiKey ? "연결됨" : "미설정" %></span>
    </div>
  </section>

  <% if (!canUseAI) { %>
  <section class="setup-card">
    <h2><i class="bi bi-unlock"></i> 실습 실행 준비가 필요합니다</h2>
    <p><%= escapeHtml(setupMessage) %></p>
    <ul class="setup-list">
      <li>가장 빠른 방법: 마이페이지에서 Anthropic API 키를 연결</li>
      <li>Anthropic API 키를 연결하면 크레딧 없이도 바로 실행 가능</li>
      <li>크레딧 실행은 서버 공용 Anthropic 키가 있을 때만 동작</li>
      <li>설정이 끝나면 이 페이지에서 바로 다시 실행할 수 있음</li>
    </ul>
    <div class="setup-actions">
      <a class="setup-btn setup-btn--primary" href="<%= setupUrl %>"><i class="bi bi-arrow-right-circle"></i><%= escapeHtml(setupPrimaryLabel) %></a>
      <a class="setup-btn" href="<%= secondarySetupUrl %>"><i class="bi bi-key"></i>API 키 관리</a>
    </div>
  </section>
  <% } %>

  <div class="layout">
    <section class="panel">
      <div class="panel-head">
        <h2>실행 패널</h2>
        <div class="status" id="runStatus"><%= canUseAI ? "준비됨" : "AI 사용 불가" %></div>
      </div>
      <div class="panel-body">
        <div class="field">
          <label for="systemPrompt">시스템 프롬프트</label>
          <textarea id="systemPrompt"><%= project != null ? escapeHtml("당신은 AI Workflow Lab의 실습 코치입니다. 프로젝트 제목: " + project.getTitle() + ". 사용자가 실무형 결과물을 만들 수 있게 한국어로 구체적인 지침과 예시를 제공하세요.") : "당신은 AI Workflow Lab의 실습 코치입니다. 한국어로 구체적인 예시와 실행 가능한 답변을 제공합니다." %></textarea>
        </div>
        <div class="field">
          <label for="userPrompt">실행할 프롬프트</label>
          <textarea id="userPrompt" placeholder="예: 이 프로젝트의 핵심 사용 시나리오 3개를 정리하고, 테스트용 프롬프트 세트를 만들어줘."></textarea>
          <div class="helper-row">
            <span>실행 결과는 최근 세션 기록에 자동 저장됩니다.</span>
            <span id="tokenInfo">토큰 정보 대기 중</span>
          </div>
        </div>
        <div class="quick-buttons">
          <button class="quick-btn" type="button" onclick="applyPreset('핵심 목표를 5줄로 요약해줘.')">목표 요약</button>
          <button class="quick-btn" type="button" onclick="applyPreset('실무 검증 체크리스트를 표 형태로 만들어줘.')">검증 체크리스트</button>
          <button class="quick-btn" type="button" onclick="applyPreset('사용자에게 바로 적용할 프롬프트 예시 5개를 작성해줘.')">프롬프트 예시</button>
        </div>
        <div style="margin-top:16px;">
          <button class="btn-run" id="runBtn" type="button" onclick="runPlayground()" <%= canUseAI ? "" : "disabled" %>><i class="bi bi-play-fill"></i><%= canUseAI ? "실행하기" : "먼저 설정하기" %></button>
        </div>
        <div class="field" style="margin-top:18px; margin-bottom:0;">
          <label>실행 결과</label>
          <div class="result-box" id="resultBox"><span class="empty">아직 실행 결과가 없습니다.</span></div>
        </div>
      </div>
    </section>

    <aside class="panel">
      <div class="panel-head">
        <h2>최근 실행</h2>
        <a href="<%= project != null ? "/AI/user/lab/session.jsp?id=" + project.getId() : "/AI/user/lab/index.jsp" %>" style="color:#93c5fd;font-size:.82rem;text-decoration:none;">세션으로 이동</a>
      </div>
      <div class="panel-body">
        <% if (sessionLoadError != null) { %>
          <div class="warn">`lab_sessions` 테이블이 아직 준비되지 않아 기록을 불러오지 못했습니다.</div>
        <% } else if (recentSessions == null || recentSessions.isEmpty()) { %>
          <div class="empty">저장된 실행 기록이 없습니다.</div>
        <% } else { %>
          <div class="history-list" id="historyList">
            <% for (LabSession item : recentSessions) { %>
              <div class="history-item">
                <div class="history-title"><%= escapeHtml(safeString(item.getTitle(), "실습 실행")) %></div>
                <div class="history-meta">
                  <span><i class="bi bi-cpu"></i> <%= escapeHtml(safeString(item.getModelUsed(), "-")) %></span>
                  <span><i class="bi bi-lightning"></i> <%= item.getTokensUsed() %> tokens</span>
                  <span><i class="bi bi-coin"></i> <%= item.getCreditsUsed() %> credits</span>
                </div>
                <div class="history-body"><%= escapeHtml(safeString(item.getResultContent(), "")) %></div>
              </div>
            <% } %>
          </div>
        <% } %>
      </div>
    </aside>
  </div>
</div>
<script>
  const PROJECT_ID = <%= project != null ? project.getId() : 0 %>;
  const CAN_USE_AI = <%= canUseAI %>;

  function applyPreset(text) {
    document.getElementById('userPrompt').value = text;
    document.getElementById('userPrompt').focus();
  }

  async function persistSession(prompt, result, meta) {
    try {
      await fetch('/AI/api/lab-sessions/', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({
          projectId: String(PROJECT_ID || ''),
          sessionType: 'playground',
          title: 'Playground 실행',
          codeContent: prompt,
          resultContent: result,
          modelUsed: meta.model || '',
          tokensUsed: String((meta.promptTokens || 0) + (meta.outputTokens || 0)),
          creditsUsed: String(meta.creditsUsed || 0),
          executionTimeMs: String(meta.executionTimeMs || 0),
          status: 'completed',
          metadata: JSON.stringify(meta)
        })
      });
    } catch (e) {}
  }

  async function runPlayground() {
    const btn = document.getElementById('runBtn');
    const systemPrompt = document.getElementById('systemPrompt').value.trim();
    const userPrompt = document.getElementById('userPrompt').value.trim();
    const resultBox = document.getElementById('resultBox');
    const tokenInfo = document.getElementById('tokenInfo');
    const status = document.getElementById('runStatus');

    if (!userPrompt) return;
    if (!CAN_USE_AI) {
      resultBox.textContent = 'AI 기능을 사용하려면 API 키를 등록하거나 크레딧을 확보해야 합니다.';
      status.textContent = '실행 불가';
      return;
    }

    btn.disabled = true;
    resultBox.textContent = '실행 중...';
    status.textContent = '실행 중';
    const startedAt = Date.now();

    try {
      const resp = await fetch('/AI/api/chat.jsp', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({
          message: userPrompt,
          system: systemPrompt,
          projectId: String(PROJECT_ID || ''),
          feature: 'lab_playground'
        })
      });
      const data = await resp.json();
      if (data.ok) {
        resultBox.textContent = data.message || '';
        tokenInfo.textContent = 'prompt ' + (data.promptTokens || 0) + ' / output ' + (data.outputTokens || 0);
        status.textContent = '완료';
        await persistSession(userPrompt, data.message || '', {
          model: data.model,
          promptTokens: data.promptTokens || 0,
          outputTokens: data.outputTokens || 0,
          creditsUsed: data.creditsUsed || 0,
          executionTimeMs: Date.now() - startedAt
        });
      } else {
        resultBox.textContent = data.message || '실행 중 오류가 발생했습니다.';
        status.textContent = '오류';
      }
    } catch (e) {
      resultBox.textContent = '네트워크 오류가 발생했습니다.';
      status.textContent = '오류';
    } finally {
      btn.disabled = false;
    }
  }
</script>
</body>
</html>
