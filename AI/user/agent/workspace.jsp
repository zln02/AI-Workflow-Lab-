<%@ page contentType="text/html; charset=UTF-8" buffer="128kb" autoFlush="true" %>
<%@ page isELIgnored="true" %>
<%@ page import="dao.AgentRunDAO, dao.AgentTemplateDAO, dao.CreditDAO" %>
<%@ page import="model.AgentRun, model.AgentTemplate, model.User" %>
<%@ page import="java.util.List" %>
<%@ include file="/AI/user/_common.jsp" %>
<%
  User user = (User) session.getAttribute("user");
  if (user == null) {
    response.sendRedirect("/AI/user/login.jsp?redirect=" + java.net.URLEncoder.encode(request.getRequestURI(), "UTF-8"));
    return;
  }

  List<AgentTemplate> agentTemplates = new java.util.ArrayList<>();
  List<AgentRun> recentRuns = new java.util.ArrayList<>();
  String agentLoadError = null;
  try {
    agentTemplates = new AgentTemplateDAO().findActiveTemplates();
    recentRuns = new AgentRunDAO().findRecentByUser(user.getId(), 8);
  } catch (Exception e) {
    agentLoadError = e.getMessage();
  }

  int creditBalance = 0;
  try { creditBalance = new CreditDAO().getBalance(user.getId()); } catch (Exception e) {}

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
  String returnToWorkspace = "/AI/user/agent/workspace.jsp";
  String encodedReturn = java.net.URLEncoder.encode(returnToWorkspace, "UTF-8");
  String setupUrl = hasPlatformKey ? "/AI/user/pricing.jsp" : "/AI/user/mypage.jsp?tab=apikeys&return=" + encodedReturn;
  String secondarySetupUrl = "/AI/user/mypage.jsp?tab=apikeys&return=" + encodedReturn;
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Super Agent Lite - AI Workflow Lab</title>
  <link rel="icon" href="data:,">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;700;800&display=swap" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
  <link rel="stylesheet" href="/AI/assets/css/dark-theme.css">
  <style>
    body { padding-top:60px; background:#06111d; color:#eef2ff; font-family:'Noto Sans KR',sans-serif; }
    .agent-wrap { max-width:1360px; margin:0 auto; padding:32px 24px 84px; }
    .hero {
      margin-bottom:22px; padding:28px; border-radius:28px; border:1px solid rgba(255,255,255,.08);
      background:
        radial-gradient(circle at top right, rgba(34,197,94,.14), transparent 28%),
        radial-gradient(circle at left center, rgba(14,165,233,.16), transparent 26%),
        linear-gradient(165deg, rgba(8,15,27,.98), rgba(10,18,35,.95));
    }
    .hero-top { display:flex; justify-content:space-between; gap:18px; flex-wrap:wrap; }
    .hero-title { max-width:780px; }
    .eyebrow { color:#7dd3fc; font-size:.76rem; font-weight:800; letter-spacing:.14em; text-transform:uppercase; }
    .hero h1 { margin:10px 0 10px; font-size:clamp(1.9rem,4vw,3rem); font-weight:800; }
    .hero p { margin:0; color:#a5b4fc; line-height:1.75; }
    .hero-metrics { display:flex; gap:10px; flex-wrap:wrap; margin-top:18px; }
    .metric {
      padding:10px 14px; border-radius:999px; font-size:.82rem;
      background:rgba(255,255,255,.05); border:1px solid rgba(255,255,255,.08); color:#dbeafe;
    }
    .workspace { display:grid; grid-template-columns:280px minmax(0,1fr) 360px; gap:18px; }
    .panel { border-radius:24px; border:1px solid rgba(255,255,255,.08); background:rgba(255,255,255,.04); overflow:hidden; }
    .panel-head { padding:18px 20px; border-bottom:1px solid rgba(255,255,255,.07); display:flex; justify-content:space-between; align-items:center; gap:12px; }
    .panel-head h2 { margin:0; font-size:1rem; font-weight:700; }
    .panel-body { padding:20px; }
    .template-list { display:grid; gap:12px; }
    .template-card {
      padding:15px; border-radius:18px; border:1px solid rgba(255,255,255,.08);
      background:rgba(8,15,29,.78); cursor:pointer; transition:transform .18s ease, border-color .18s ease, background .18s ease;
    }
    .template-card:hover, .template-card.is-active { transform:translateY(-1px); border-color:rgba(56,189,248,.45); background:rgba(8,20,38,.95); }
    .template-badge { display:inline-flex; padding:5px 9px; border-radius:999px; background:rgba(56,189,248,.14); color:#7dd3fc; font-size:.72rem; font-weight:700; }
    .template-name { margin:10px 0 8px; font-size:.96rem; font-weight:800; }
    .template-desc { margin:0; color:#cbd5e1; font-size:.82rem; line-height:1.65; }
    .field { margin-bottom:16px; }
    .field label { display:block; margin-bottom:8px; color:#dbeafe; font-size:.82rem; font-weight:700; }
    .field textarea, .field input {
      width:100%; padding:13px 14px; border-radius:14px; border:1px solid rgba(255,255,255,.09);
      background:rgba(255,255,255,.05); color:#f8fafc; outline:none; font-size:.92rem;
    }
    .field textarea { min-height:140px; resize:vertical; }
    .suggestions { display:flex; gap:8px; flex-wrap:wrap; margin:10px 0 0; }
    .chip { border:none; padding:8px 11px; border-radius:999px; background:rgba(255,255,255,.06); color:#cbd5e1; font-size:.77rem; }
    .run-bar { display:flex; align-items:center; justify-content:space-between; gap:14px; flex-wrap:wrap; }
    .run-btn {
      border:none; border-radius:14px; padding:13px 18px; font-weight:800; color:#04111d;
      background:linear-gradient(135deg,#7dd3fc,#4ade80); box-shadow:0 12px 28px rgba(74,222,128,.18);
    }
    .run-btn:disabled { opacity:.5; cursor:not-allowed; }
    .status { color:#94a3b8; font-size:.82rem; }
    .output-grid { display:grid; gap:14px; }
    .output-card { padding:16px; border-radius:18px; background:rgba(8,15,29,.78); border:1px solid rgba(255,255,255,.07); }
    .output-card h3 { margin:0 0 10px; font-size:.9rem; font-weight:800; color:#f8fafc; }
    .output-text { color:#dbeafe; white-space:pre-wrap; line-height:1.75; font-size:.88rem; }
    .output-list { margin:0; padding-left:18px; color:#dbeafe; font-size:.86rem; line-height:1.75; }
    .empty { color:#64748b; }
    .history-list { display:grid; gap:12px; }
    .history-item {
      padding:14px; border-radius:18px; background:rgba(8,15,29,.78); border:1px solid rgba(255,255,255,.07); cursor:pointer;
    }
    .history-item h3 { margin:0 0 8px; font-size:.88rem; font-weight:800; }
    .history-meta { display:flex; gap:10px; flex-wrap:wrap; color:#94a3b8; font-size:.75rem; margin-bottom:8px; }
    .history-snippet { color:#cbd5e1; font-size:.82rem; line-height:1.65; display:-webkit-box; -webkit-line-clamp:3; -webkit-box-orient:vertical; overflow:hidden; }
    .notice {
      margin-bottom:18px; padding:18px 20px; border-radius:20px; border:1px solid rgba(250,204,21,.25);
      background:rgba(250,204,21,.08); color:#fde68a;
    }
    .notice a { color:#fff; }
    @media (max-width: 1180px) { .workspace { grid-template-columns:1fr; } }
  </style>
</head>
<body>
<%@ include file="/AI/partials/header.jsp" %>
<div class="agent-wrap">
  <section class="hero">
    <div class="hero-top">
      <div class="hero-title">
        <div class="eyebrow">Super Agent Lite</div>
        <h1>한 번의 요청으로 조사, 비교, 실행안을 같이 만듭니다</h1>
        <p>Genspark식 워크스페이스를 현재 스택에 맞게 축소 적용한 MVP입니다. 하나의 목표를 넣으면 요약, 추천 도구, 실행 단계, 보고서 초안과 슬라이드 개요를 한 번에 생성하고 기록으로 남깁니다.</p>
        <div class="hero-metrics">
          <span class="metric"><i class="bi bi-stars"></i> 에이전트 템플릿 <%= agentTemplates.size() %>개</span>
          <span class="metric"><i class="bi bi-clock-history"></i> 최근 실행 <%= recentRuns.size() %>개</span>
          <span class="metric"><i class="bi bi-coin"></i> 현재 크레딧 <%= creditBalance %></span>
        </div>
      </div>
    </div>
  </section>

  <% if (!canUseAI) { %>
  <section class="notice">
    에이전트를 실행하려면 API 키를 연결하거나 크레딧이 필요합니다.
    <a href="<%= setupUrl %>">설정하러 가기</a>
    ·
    <a href="<%= secondarySetupUrl %>">API 키 관리</a>
  </section>
  <% } %>

  <% if (agentLoadError != null) { %>
  <section class="notice">
    `agent_templates` 또는 `agent_runs` 테이블이 아직 없어서 워크스페이스 데이터가 비어 있습니다.
    먼저 `AI/database/migrations/20260316_create_agent_workspace.sql`을 적용하세요.
  </section>
  <% } %>

  <div class="workspace">
    <aside class="panel">
      <div class="panel-head">
        <h2>에이전트 템플릿</h2>
        <span class="status" id="templateCount"><%= agentTemplates.size() %>개</span>
      </div>
      <div class="panel-body">
        <div class="template-list" id="templateList">
          <% for (int i = 0; i < agentTemplates.size(); i++) { AgentTemplate item = agentTemplates.get(i); %>
          <button type="button"
                  class="template-card<%= i == 0 ? " is-active" : "" %>"
                  data-template-id="<%= item.getId() %>"
                  data-template-name="<%= escapeHtmlAttribute(item.getName()) %>"
                  data-template-desc="<%= escapeHtmlAttribute(item.getDescription()) %>"
                  data-template-system="<%= escapeHtmlAttribute(item.getSystemPrompt()) %>"
                  data-template-suggested="<%= escapeHtmlAttribute(safeString(item.getSuggestedGoal(), "")) %>">
            <span class="template-badge"><%= escapeHtml(safeString(item.getBadgeLabel(), "Agent")) %></span>
            <div class="template-name"><%= escapeHtml(item.getName()) %></div>
            <p class="template-desc"><%= escapeHtml(item.getDescription()) %></p>
          </button>
          <% } %>
        </div>
      </div>
    </aside>

    <section class="panel">
      <div class="panel-head">
        <h2 id="activeTemplateTitle">에이전트 실행</h2>
        <span class="status" id="runStatus"><%= canUseAI ? "준비됨" : "실행 불가" %></span>
      </div>
      <div class="panel-body">
        <div class="field">
          <label for="goalInput">목표</label>
          <textarea id="goalInput" placeholder="예: 국내 중견 제조기업의 고객지원팀에 생성형 AI를 도입하기 위한 실행 전략을 조사하고, 바로 발표 가능한 개요까지 만들어줘."></textarea>
          <div class="suggestions">
            <button class="chip" type="button" onclick="applySuggestedGoal()">추천 목표 넣기</button>
            <button class="chip" type="button" onclick="fillGoal('콘텐츠 팀이 사용할 텍스트 생성 도구 조합과 운영 정책을 제안해줘.')">콘텐츠 운영안</button>
            <button class="chip" type="button" onclick="fillGoal('사내 AI 파일럿의 4주 로드맵과 체크리스트를 만들어줘.')">파일럿 로드맵</button>
          </div>
        </div>
        <div class="field">
          <label for="systemPrompt">시스템 프롬프트</label>
          <textarea id="systemPrompt" placeholder="선택한 템플릿의 시스템 프롬프트가 여기에 들어옵니다."><%= agentTemplates.isEmpty() ? "" : escapeHtml(agentTemplates.get(0).getSystemPrompt()) %></textarea>
        </div>
        <div class="run-bar">
          <div class="status" id="tokenInfo">JSON 결과 생성 대기 중</div>
          <button class="run-btn" id="runBtn" type="button" onclick="runAgent()" <%= canUseAI ? "" : "disabled" %>>에이전트 실행</button>
        </div>
        <hr style="border-color:rgba(255,255,255,.08); margin:20px 0;">
        <div class="output-grid">
          <div class="output-card">
            <h3>요약</h3>
            <div class="output-text" id="summaryOutput"><span class="empty">실행하면 요약이 여기에 표시됩니다.</span></div>
          </div>
          <div class="output-card">
            <h3>추천 도구</h3>
            <ul class="output-list" id="toolsOutput"><li class="empty">아직 결과가 없습니다.</li></ul>
          </div>
          <div class="output-card">
            <h3>실행 단계</h3>
            <ul class="output-list" id="planOutput"><li class="empty">아직 결과가 없습니다.</li></ul>
          </div>
          <div class="output-card">
            <h3>보고서 초안</h3>
            <div class="output-text" id="reportOutput"><span class="empty">아직 결과가 없습니다.</span></div>
          </div>
          <div class="output-card">
            <h3>슬라이드 개요</h3>
            <ul class="output-list" id="slidesOutput"><li class="empty">아직 결과가 없습니다.</li></ul>
          </div>
          <div class="output-card">
            <h3>체크리스트</h3>
            <ul class="output-list" id="checklistOutput"><li class="empty">아직 결과가 없습니다.</li></ul>
          </div>
        </div>
      </div>
    </section>

    <aside class="panel">
      <div class="panel-head">
        <h2>최근 실행</h2>
        <span class="status" id="saveStatus">저장 대기</span>
      </div>
      <div class="panel-body">
        <div class="history-list" id="historyList">
          <% if (recentRuns.isEmpty()) { %>
          <div class="empty">아직 저장된 에이전트 실행이 없습니다.</div>
          <% } else { %>
            <% for (AgentRun run : recentRuns) { %>
            <button type="button"
                    class="history-item"
                    data-run-id="<%= run.getId() %>"
                    data-run-json="<%= escapeHtmlAttribute(safeString(run.getFinalOutputJson(), "{}")) %>">
              <h3><%= escapeHtml(safeString(run.getTitle(), "에이전트 실행")) %></h3>
              <div class="history-meta">
                <span><i class="bi bi-stars"></i> <%= escapeHtml(safeString(run.getTemplateName(), "-")) %></span>
                <span><i class="bi bi-cpu"></i> <%= escapeHtml(safeString(run.getModelUsed(), "-")) %></span>
              </div>
              <div class="history-snippet"><%= escapeHtml(safeString(run.getUserGoal(), "")) %></div>
            </button>
            <% } %>
          <% } %>
        </div>
      </div>
    </aside>
  </div>
</div>

<script>
  const CSRF_TOKEN = '<%= escapeJs(getCSRFToken(session)) %>';
  const CAN_USE_AI = <%= canUseAI %>;
  const templates = Array.from(document.querySelectorAll('.template-card')).map((el) => ({
    id: Number(el.dataset.templateId),
    name: el.dataset.templateName || '',
    description: el.dataset.templateDesc || '',
    systemPrompt: el.dataset.templateSystem || '',
    suggestedGoal: el.dataset.templateSuggested || ''
  }));
  let activeTemplate = templates[0] || null;

  function fillGoal(text) {
    document.getElementById('goalInput').value = text;
    document.getElementById('goalInput').focus();
  }

  function applySuggestedGoal() {
    if (activeTemplate && activeTemplate.suggestedGoal) {
      fillGoal(activeTemplate.suggestedGoal);
    }
  }

  function setActiveTemplate(templateId) {
    activeTemplate = templates.find((item) => item.id === templateId) || activeTemplate;
    document.querySelectorAll('.template-card').forEach((el) => {
      el.classList.toggle('is-active', Number(el.dataset.templateId) === templateId);
    });
    if (!activeTemplate) return;
    document.getElementById('activeTemplateTitle').textContent = activeTemplate.name;
    document.getElementById('systemPrompt').value = activeTemplate.systemPrompt || '';
  }

  function renderList(targetId, items) {
    const node = document.getElementById(targetId);
    if (!Array.isArray(items) || !items.length) {
      node.innerHTML = '<li class="empty">결과가 없습니다.</li>';
      return;
    }
    node.innerHTML = items.map((item) => '<li>' + escapeHtml(item) + '</li>').join('');
  }

  function renderOutput(result) {
    const deliverables = result && result.deliverables ? result.deliverables : {};
    document.getElementById('summaryOutput').textContent = result && result.summary ? result.summary : '요약이 없습니다.';
    renderList('toolsOutput', result ? result.recommendedTools : []);
    renderList('planOutput', result ? result.executionPlan : []);
    document.getElementById('reportOutput').textContent = deliverables.report || '보고서 초안이 없습니다.';
    renderList('slidesOutput', deliverables.slidesOutline || []);
    renderList('checklistOutput', deliverables.checklist || []);
  }

  function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text == null ? '' : String(text);
    return div.innerHTML;
  }

  async function saveRun(goal, result, meta) {
    const response = await fetch('/AI/api/agents/runs', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({
        templateId: String(activeTemplate ? activeTemplate.id : ''),
        title: (activeTemplate ? activeTemplate.name : '에이전트 실행') + ' 결과',
        userGoal: goal,
        status: 'completed',
        modelUsed: meta.model || '',
        promptTokens: String(meta.promptTokens || 0),
        outputTokens: String(meta.outputTokens || 0),
        creditsUsed: String(meta.creditsUsed || 0),
        finalOutputJson: JSON.stringify(result),
        _csrf: CSRF_TOKEN
      })
    });
    return response.json();
  }

  async function refreshRuns() {
    try {
      const response = await fetch('/AI/api/agents/runs');
      const data = await response.json();
      if (!data.success || !Array.isArray(data.data)) return;
      const historyList = document.getElementById('historyList');
      if (!data.data.length) {
        historyList.innerHTML = '<div class="empty">아직 저장된 에이전트 실행이 없습니다.</div>';
        return;
      }
      historyList.innerHTML = data.data.map((run) => {
        return '<button type="button" class="history-item" data-run-id="' + run.id + '" data-run-json="' + escapeHtml(run.finalOutputJson || '{}') + '">' +
          '<h3>' + escapeHtml(run.title || '에이전트 실행') + '</h3>' +
          '<div class="history-meta"><span><i class="bi bi-stars"></i> ' + escapeHtml(run.templateName || '-') + '</span><span><i class="bi bi-cpu"></i> ' + escapeHtml(run.modelUsed || '-') + '</span></div>' +
          '<div class="history-snippet">' + escapeHtml(run.userGoal || '') + '</div>' +
          '</button>';
      }).join('');
      bindHistoryEvents();
    } catch (e) {}
  }

  function bindHistoryEvents() {
    document.querySelectorAll('.history-item').forEach((item) => {
      item.addEventListener('click', () => {
        try {
          renderOutput(JSON.parse(item.dataset.runJson || '{}'));
          document.getElementById('saveStatus').textContent = '저장된 결과 불러옴';
        } catch (e) {}
      });
    });
  }

  async function runAgent() {
    const goal = document.getElementById('goalInput').value.trim();
    const systemPrompt = document.getElementById('systemPrompt').value.trim();
    const runBtn = document.getElementById('runBtn');
    const runStatus = document.getElementById('runStatus');
    const tokenInfo = document.getElementById('tokenInfo');
    const saveStatus = document.getElementById('saveStatus');

    if (!goal || !activeTemplate) return;
    if (!CAN_USE_AI) {
      runStatus.textContent = '실행 불가';
      return;
    }

    runBtn.disabled = true;
    runStatus.textContent = '실행 중';
    tokenInfo.textContent = 'AI 호출 중';
    saveStatus.textContent = '저장 대기';

    try {
      const response = await fetch('/AI/api/chat.jsp', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({
          message: goal,
          system: systemPrompt,
          feature: 'super_agent_lite'
        })
      });
      const data = await response.json();
      if (!data.ok) {
        runStatus.textContent = '오류';
        tokenInfo.textContent = data.message || '실행 실패';
        return;
      }

      let parsed;
      try {
        parsed = JSON.parse(data.message || '{}');
      } catch (e) {
        parsed = {
          summary: '구조화 JSON 파싱에 실패했습니다. 아래 원문을 확인하세요.',
          recommendedTools: [],
          executionPlan: [],
          deliverables: {
            report: data.message || '',
            slidesOutline: [],
            checklist: []
          }
        };
      }

      renderOutput(parsed);
      tokenInfo.textContent = 'prompt ' + (data.promptTokens || 0) + ' / output ' + (data.outputTokens || 0);
      runStatus.textContent = '완료';

      const saveResult = await saveRun(goal, parsed, {
        model: data.model,
        promptTokens: data.promptTokens || 0,
        outputTokens: data.outputTokens || 0,
        creditsUsed: data.creditsUsed || 0
      });
      saveStatus.textContent = saveResult && saveResult.success ? '저장 완료' : '저장 실패';
      await refreshRuns();
    } catch (e) {
      runStatus.textContent = '오류';
      tokenInfo.textContent = '네트워크 오류';
      saveStatus.textContent = '저장 안 됨';
    } finally {
      runBtn.disabled = false;
    }
  }

  document.querySelectorAll('.template-card').forEach((el) => {
    el.addEventListener('click', () => setActiveTemplate(Number(el.dataset.templateId)));
  });
  bindHistoryEvents();
  if (activeTemplate && activeTemplate.suggestedGoal) {
    document.getElementById('goalInput').value = activeTemplate.suggestedGoal;
  }
</script>
</body>
</html>
