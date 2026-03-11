<%@ page contentType="text/html; charset=UTF-8" buffer="128kb" autoFlush="true" %>
<%@ page isELIgnored="true" %>
<%@ page import="dao.LabProjectDAO" %>
<%@ page import="model.LabProject" %>
<%@ page import="java.util.List" %>
<%@ include file="/AI/user/_common.jsp" %>
<%
  LabProjectDAO projectDao = new LabProjectDAO();
  List<LabProject> projects = projectDao.findAll();

  String initPtype = safeString(request.getParameter("type"), "");
  String initDiff  = safeString(request.getParameter("difficulty"), "");
  String initKw    = safeString(request.getParameter("keyword"), "");
%>
<%!
  private String ptypeGradient(String t) {
    if ("Tutorial".equals(t))   return "linear-gradient(135deg,#3b82f6,#60a5fa)";
    if ("Challenge".equals(t))  return "linear-gradient(135deg,#f97316,#fb923c)";
    if ("Real-world".equals(t)) return "linear-gradient(135deg,#22c55e,#4ade80)";
    return "linear-gradient(135deg,#64748b,#94a3b8)";
  }
  private String diffKoL(String d) {
    if ("Beginner".equals(d))     return "입문";
    if ("Intermediate".equals(d)) return "중급";
    if ("Advanced".equals(d))     return "고급";
    return d != null ? d : "";
  }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>AI 실습 랩 — AI Workflow Lab</title>
  <link rel="icon" href="data:,">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
  <link rel="stylesheet" href="/AI/assets/css/dark-theme.css">
  <link rel="stylesheet" href="/AI/assets/css/page.css">
  <link rel="stylesheet" href="/AI/assets/css/animations.css">
  <style>
    .pi{max-width:1100px;margin:0 auto;padding:0 24px;}
    .lab-hdr{padding:48px 0 0;}
    .lab-hdr h1{font-size:clamp(1.75rem,4vw,2.5rem);font-weight:700;letter-spacing:-.025em;margin:0 0 8px;}
    .lab-hdr p{color:var(--text-secondary,#94a3b8);margin:0 0 28px;font-size:1rem;}
    .frow{overflow-x:auto;display:flex;gap:7px;padding-bottom:4px;margin-bottom:10px;scrollbar-width:none;}
    .frow::-webkit-scrollbar{display:none;}
    .frow3{display:flex;align-items:center;gap:8px;margin-bottom:0;flex-wrap:wrap;}
    .fp{display:inline-flex;align-items:center;gap:5px;padding:7px 14px;border-radius:999px;font-size:.8125rem;font-weight:500;white-space:nowrap;border:1px solid rgba(255,255,255,.10);background:rgba(255,255,255,.05);color:var(--text-secondary,#94a3b8);cursor:pointer;flex-shrink:0;transition:all .18s;}
    .fp:hover{background:rgba(255,255,255,.09);color:#f1f5f9;}
    .fp.active[data-ptype=""]{background:rgba(255,255,255,.12);color:#f1f5f9;border-color:rgba(255,255,255,.25);}
    .fp.active[data-ptype="Tutorial"]{background:rgba(59,130,246,.18);color:#60a5fa;border-color:rgba(59,130,246,.40);}
    .fp.active[data-ptype="Challenge"]{background:rgba(249,115,22,.18);color:#fb923c;border-color:rgba(249,115,22,.40);}
    .fp.active[data-ptype="Real-world"]{background:rgba(34,197,94,.18);color:#4ade80;border-color:rgba(34,197,94,.40);}
    .fp.active[data-diff=""]{background:rgba(255,255,255,.10);color:#f1f5f9;border-color:rgba(255,255,255,.20);}
    .fp.active[data-diff="Beginner"]{background:rgba(34,197,94,.15);color:#4ade80;border-color:rgba(34,197,94,.35);}
    .fp.active[data-diff="Intermediate"]{background:rgba(245,158,11,.15);color:#fbbf24;border-color:rgba(245,158,11,.35);}
    .fp.active[data-diff="Advanced"]{background:rgba(239,68,68,.15);color:#f87171;border-color:rgba(239,68,68,.35);}
    .lab-search{flex:1;min-width:160px;padding:7px 14px;border-radius:999px;border:1px solid rgba(255,255,255,.10);background:rgba(255,255,255,.05);color:var(--text-primary,#f1f5f9);font-size:.8125rem;font-family:inherit;}
    .lab-search:focus{outline:none;border-color:rgba(59,130,246,.4);background:rgba(255,255,255,.07);}
    .lab-search::placeholder{color:var(--text-muted,#64748b);}
    .div-line{max-width:1100px;margin:18px auto 0;padding:0 24px;border-top:1px solid rgba(255,255,255,.07);}
    .results-meta{font-size:.875rem;color:var(--text-muted,#64748b);margin-bottom:18px;}
    .results-meta strong{color:var(--text-secondary,#94a3b8);}
    .lc-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:18px;}
    .lc{background:rgba(255,255,255,.045);border:1px solid rgba(255,255,255,.09);border-radius:14px;overflow:hidden;display:flex;flex-direction:column;transition:all .22s;cursor:pointer;}
    .lc:hover{border-color:rgba(59,130,246,.30);transform:translateY(-4px);box-shadow:0 12px 32px rgba(0,0,0,.28);}
    .lc__bar{height:4px;transition:height .22s;}
    .lc:hover .lc__bar{height:8px;}
    .lc__body{padding:18px 20px;flex:1;display:flex;flex-direction:column;}
    .lc__badges{display:flex;gap:6px;margin-bottom:12px;flex-wrap:wrap;}
    .lc__badge{font-size:.6875rem;font-weight:600;padding:2px 9px;border-radius:999px;}
    .lc__badge--tutorial{background:rgba(59,130,246,.12);color:#60a5fa;border:1px solid rgba(59,130,246,.22);}
    .lc__badge--challenge{background:rgba(249,115,22,.12);color:#fb923c;border:1px solid rgba(249,115,22,.22);}
    .lc__badge--real-world{background:rgba(34,197,94,.12);color:#4ade80;border:1px solid rgba(34,197,94,.22);}
    .lc__badge--beginner{background:rgba(34,197,94,.10);color:#4ade80;border:1px solid rgba(34,197,94,.18);}
    .lc__badge--intermediate{background:rgba(245,158,11,.10);color:#fbbf24;border:1px solid rgba(245,158,11,.18);}
    .lc__badge--advanced{background:rgba(239,68,68,.10);color:#f87171;border:1px solid rgba(239,68,68,.18);}
    .lc__title{font-size:.9375rem;font-weight:700;color:var(--text-primary,#f1f5f9);margin:0 0 8px;letter-spacing:-.01em;}
    .lc__desc{font-size:.84375rem;color:var(--text-secondary,#94a3b8);line-height:1.6;margin:0 0 12px;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden;flex:1;}
    .lc__goals{display:flex;gap:5px;flex-wrap:wrap;margin-bottom:12px;}
    .lc__goal{font-size:.6875rem;padding:2px 8px;border-radius:5px;background:rgba(255,255,255,.06);color:var(--text-muted,#64748b);border:1px solid rgba(255,255,255,.08);white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:120px;}
    .lc__meta{border-top:1px solid rgba(255,255,255,.07);padding-top:11px;display:flex;gap:12px;font-size:.75rem;color:var(--text-muted,#64748b);flex-wrap:wrap;}
    .lc__cta{display:block;margin:12px 20px 18px;padding:8px;border-radius:9px;background:rgba(59,130,246,.10);color:#60a5fa;-webkit-text-fill-color:#60a5fa;font-size:.8125rem;font-weight:600;text-decoration:none;border:1px solid rgba(59,130,246,.20);text-align:center;transition:all .18s;}
    .lc__cta:hover{background:rgba(59,130,246,.18);color:#93c5fd;-webkit-text-fill-color:#93c5fd;}
    .empty-st{grid-column:1/-1;display:flex;flex-direction:column;align-items:center;padding:80px 24px;text-align:center;}
    .reset-btn{padding:8px 18px;border-radius:9px;background:rgba(59,130,246,.10);color:#60a5fa;border:1px solid rgba(59,130,246,.22);font-size:.875rem;font-weight:600;cursor:pointer;transition:all .18s;}
    @media(max-width:1024px){.lc-grid{grid-template-columns:repeat(2,1fr);}}
    @media(max-width:640px){.lc-grid{grid-template-columns:1fr;}.frow3{flex-direction:column;align-items:flex-start;}.lab-search{width:100%;min-width:0;}}
  </style>
</head>
<body>
<%@ include file="/AI/partials/header.jsp" %>

<!-- Page Header -->
<div class="lab-hdr">
  <div class="pi">
    <h1>AI 실습 랩</h1>
    <p>비즈니스 시나리오 기반 실습으로 AI 실무 역량을 키우세요</p>

    <!-- Row 1: Type tabs -->
    <div class="frow" role="group">
      <button class="fp" data-ptype="">전체</button>
      <button class="fp" data-ptype="Tutorial"><i class="bi bi-book-fill me-1"></i>Tutorial</button>
      <button class="fp" data-ptype="Challenge"><i class="bi bi-trophy-fill me-1"></i>Challenge</button>
      <button class="fp" data-ptype="Real-world"><i class="bi bi-briefcase-fill me-1"></i>Real-world</button>
    </div>

    <!-- Row 2: Difficulty + Search -->
    <div class="frow3">
      <button class="fp" data-diff="">전체</button>
      <button class="fp" data-diff="Beginner">입문</button>
      <button class="fp" data-diff="Intermediate">중급</button>
      <button class="fp" data-diff="Advanced">고급</button>
      <input class="lab-search" id="labSearch" type="text"
             placeholder="프로젝트 검색..." autocomplete="off">
    </div>
  </div>
</div>
<div class="div-line"></div>

<!-- Results -->
<div class="pi" style="padding-top:20px;padding-bottom:80px;">
  <div class="results-meta">총 <strong id="resultCount"><%= projects.size() %></strong>개 프로젝트</div>

  <div class="lc-grid" id="lcGrid">
    <% for (LabProject p : projects) {
         String pt   = safeString(p.getProjectType(), "");
         String dl   = safeString(p.getDifficultyLevel(), "");
         String ptClass = pt.toLowerCase().replace("-","").equals("realworld") ? "real-world" : pt.toLowerCase();
         String pDesc = safeString(p.getBusinessContext(), safeString(p.getDescription(), ""));
         String dataTitle = escapeHtmlAttribute(p.getTitle());
         String dataDesc  = escapeHtmlAttribute(pDesc);
    %>
    <div class="lc"
         data-ptype="<%= escapeHtmlAttribute(pt) %>"
         data-diff="<%= escapeHtmlAttribute(dl) %>"
         data-title="<%= dataTitle %>"
         data-desc="<%= dataDesc %>"
         onclick="location.href='/AI/user/lab/detail.jsp?id=<%= p.getId() %>'">

      <div class="lc__bar" style="background:<%= ptypeGradient(pt) %>;"></div>

      <div class="lc__body">
        <div class="lc__badges">
          <% if (!pt.isEmpty()) { %>
          <span class="lc__badge lc__badge--<%= ptClass %>"><%= escapeHtml(pt) %></span>
          <% } %>
          <% if (!dl.isEmpty()) { %>
          <span class="lc__badge lc__badge--<%= dl.toLowerCase() %>"><%= diffKoL(dl) %></span>
          <% } %>
        </div>

        <h3 class="lc__title"><%= escapeHtml(p.getTitle()) %></h3>
        <p class="lc__desc"><%= escapeHtml(pDesc) %></p>

        <% if (p.getProjectGoals() != null && !p.getProjectGoals().isEmpty()) { %>
        <div class="lc__goals">
          <% int gc = 0; for (String g : p.getProjectGoals()) { if (gc++ >= 2) break; %>
          <span class="lc__goal" title="<%= escapeHtmlAttribute(g) %>"><%= escapeHtml(g.length()>28?g.substring(0,28)+"…":g) %></span>
          <% } %>
        </div>
        <% } %>

        <div class="lc__meta">
          <span><i class="bi bi-clock me-1"></i><%= escapeHtml(safeString(p.getFormattedDuration(),"")) %></span>
          <% Integer parts = p.getCurrentParticipants(); %>
          <span><i class="bi bi-people me-1"></i><%= (parts != null && parts > 0) ? parts+"명" : "Coming Soon" %></span>
          <% Integer sc = p.getStepCount(); if (sc != null && sc > 0) { %>
          <span><i class="bi bi-list-ol me-1"></i><%= sc %>단계</span>
          <% } %>
        </div>
      </div>

      <div style="display:grid;grid-template-columns:1fr 1fr;gap:8px;margin:12px 20px 18px;">
      <a href="/AI/user/lab/session.jsp?id=<%= p.getId() %>"
         class="lc__cta" onclick="event.stopPropagation()">실습 시작 →</a>
      <a href="/AI/user/lab/playground.jsp?id=<%= p.getId() %>"
         class="lc__cta" style="margin:0;background:rgba(14,165,233,.10);border-color:rgba(14,165,233,.22);color:#7dd3fc;-webkit-text-fill-color:#7dd3fc;" onclick="event.stopPropagation()">Playground</a>
      </div>
    </div>
    <% } %>

    <div class="empty-st" id="emptyLab" style="display:none;">
      <i class="bi bi-search" style="font-size:2.5rem;color:var(--text-muted,#64748b);margin-bottom:14px;display:block;"></i>
      <h3 style="font-size:1.1rem;font-weight:600;margin:0 0 8px;">결과가 없습니다</h3>
      <p style="font-size:.9rem;color:var(--text-muted,#64748b);margin:0 0 20px;">다른 조건으로 시도해보세요.</p>
      <button class="reset-btn" id="labReset">필터 초기화</button>
    </div>
  </div>
</div>

<%@ include file="/AI/partials/footer.jsp" %>

<script>
(function(){
  var state = {
    ptype: '<%= escapeHtmlAttribute(initPtype) %>',
    diff:  '<%= escapeHtmlAttribute(initDiff) %>',
    kw:    '<%= escapeHtmlAttribute(initKw) %>'
  };

  var cards      = Array.from(document.querySelectorAll('.lc'));
  var ptypeBtns  = document.querySelectorAll('.fp[data-ptype]');
  var diffBtns   = document.querySelectorAll('.fp[data-diff]');
  var searchEl   = document.getElementById('labSearch');
  var countEl    = document.getElementById('resultCount');
  var emptyEl    = document.getElementById('emptyLab');
  var grid       = document.getElementById('lcGrid');
  var resetBtn   = document.getElementById('labReset');

  if (state.kw) searchEl.value = state.kw;
  ptypeBtns.forEach(function(b){ b.classList.toggle('active', b.dataset.ptype === state.ptype); });
  diffBtns.forEach(function(b){ b.classList.toggle('active', b.dataset.diff === state.diff); });

  function filter() {
    var kw = state.kw.toLowerCase().trim();
    var n = 0;
    cards.forEach(function(c) {
      var ok = (!kw || (c.dataset.title||'').toLowerCase().includes(kw) || (c.dataset.desc||'').toLowerCase().includes(kw))
            && (!state.ptype || c.dataset.ptype === state.ptype)
            && (!state.diff  || c.dataset.diff  === state.diff);
      c.style.display = ok ? '' : 'none';
      if (ok) n++;
    });
    countEl.textContent = n;
    emptyEl.style.display = n === 0 ? 'flex' : 'none';
  }

  ptypeBtns.forEach(function(b){ b.addEventListener('click', function(){ ptypeBtns.forEach(function(x){x.classList.remove('active');}); b.classList.add('active'); state.ptype = b.dataset.ptype; filter(); }); });
  diffBtns.forEach(function(b){ b.addEventListener('click', function(){ diffBtns.forEach(function(x){x.classList.remove('active');}); b.classList.add('active'); state.diff = b.dataset.diff; filter(); }); });

  var t;
  searchEl.addEventListener('input', function(){ state.kw = this.value; clearTimeout(t); t = setTimeout(filter, 160); });

  resetBtn.addEventListener('click', function(){
    state.ptype = ''; state.diff = ''; state.kw = '';
    searchEl.value = '';
    ptypeBtns.forEach(function(b){b.classList.remove('active'); if(b.dataset.ptype==='')b.classList.add('active');});
    diffBtns.forEach(function(b){b.classList.remove('active'); if(b.dataset.diff==='')b.classList.add('active');});
    filter();
  });

  filter();
})();
</script>
</body>
</html>
