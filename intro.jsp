<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="description" content="AI Workflow Lab - AI 도구 추천과 실무 경험 플랫폼">
  <title>AI Workflow Lab</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
  <style>
    :root {
      --accent: #0071e3;
      --text: #1d1d1f;
      --text-secondary: #86868b;
      --bg-contrast: #f5f5f7;
      --border: #d2d2d7;
    }
    * { box-sizing: border-box; }
    body { margin: 0; font-family: -apple-system, BlinkMacSystemFont, 'Noto Sans KR', sans-serif; background: #fff; color: var(--text); padding-top: 60px; }

    /* Navbar */
    .top-nav { position: fixed; top: 0; left: 0; right: 0; z-index: 100; background: rgba(255,255,255,0.85); backdrop-filter: blur(20px); border-bottom: 0.5px solid rgba(0,0,0,0.1); height: 60px; display: flex; align-items: center; }
    .top-nav .nav-inner { max-width: 1100px; margin: 0 auto; padding: 0 24px; display: flex; justify-content: space-between; align-items: center; width: 100%; }
    .nav-brand { font-size: 18px; font-weight: 600; color: var(--text); text-decoration: none; }
    .nav-links { display: flex; gap: 24px; align-items: center; }
    .nav-links a { color: var(--text); text-decoration: none; font-size: 14px; transition: color 0.2s; }
    .nav-links a:hover { color: var(--accent); }
    .nav-links a.btn-nav { background: var(--accent); color: #fff; padding: 8px 18px; border-radius: 20px; font-weight: 500; }
    .nav-links a.btn-nav:hover { background: #0051d5; color: #fff; }

    /* Hero */
    .hero { text-align: center; padding: 100px 24px 80px; max-width: 800px; margin: 0 auto; }
    .hero-eyebrow { font-size: 14px; font-weight: 600; color: var(--accent); letter-spacing: 0.08em; text-transform: uppercase; margin-bottom: 16px; }
    .hero-title { font-size: 56px; font-weight: 700; letter-spacing: -0.005em; background: linear-gradient(135deg, #1d1d1f, #0071e3); -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text; margin-bottom: 20px; line-height: 1.05; }
    .hero-subtitle { font-size: 21px; color: var(--text-secondary); line-height: 1.5; margin-bottom: 40px; }
    .hero-actions { display: flex; gap: 16px; justify-content: center; flex-wrap: wrap; }
    .btn-hero-primary { padding: 14px 32px; background: var(--accent); color: #fff; border: none; border-radius: 980px; font-size: 17px; font-weight: 500; cursor: pointer; text-decoration: none; transition: all 0.2s; display: inline-flex; align-items: center; gap: 8px; }
    .btn-hero-primary:hover { background: #0051d5; transform: scale(1.02); color: #fff; }
    .btn-hero-secondary { padding: 14px 32px; background: transparent; color: var(--accent); border: 1.5px solid var(--accent); border-radius: 980px; font-size: 17px; font-weight: 500; cursor: pointer; text-decoration: none; transition: all 0.2s; display: inline-flex; align-items: center; gap: 8px; }
    .btn-hero-secondary:hover { background: var(--accent); color: #fff; transform: scale(1.02); }

    /* AI Logos */
    .logos-section { padding: 40px 0; background: var(--bg-contrast); overflow: hidden; }
    .logos-label { text-align: center; font-size: 13px; color: var(--text-secondary); margin-bottom: 20px; }
    .logos-track { display: flex; gap: 48px; align-items: center; animation: scrollLogos 25s linear infinite; width: max-content; padding: 0 24px; }
    .logos-track:hover { animation-play-state: paused; }
    .logo-chip { display: flex; align-items: center; gap: 8px; opacity: 0.6; transition: opacity 0.2s; }
    .logo-chip:hover { opacity: 1; }
    .logo-chip img { width: 28px; height: 28px; border-radius: 6px; }
    .logo-chip span { font-size: 13px; font-weight: 600; color: var(--text); white-space: nowrap; }
    @keyframes scrollLogos { 0% { transform: translateX(0); } 100% { transform: translateX(-50%); } }

    /* Features */
    .features { padding: 80px 24px; max-width: 1100px; margin: 0 auto; }
    .features-title { text-align: center; font-size: 40px; font-weight: 700; margin-bottom: 12px; letter-spacing: -0.003em; }
    .features-sub { text-align: center; font-size: 18px; color: var(--text-secondary); margin-bottom: 60px; }
    .features-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 24px; }
    .feature-card { background: #fff; border: 1px solid var(--border); border-radius: 20px; padding: 36px 32px; transition: all 0.25s ease; }
    .feature-card:hover { transform: translateY(-6px); box-shadow: 0 12px 40px rgba(0,0,0,0.08); border-color: var(--accent); }
    .feature-icon { font-size: 2.5rem; margin-bottom: 20px; }
    .feature-title { font-size: 22px; font-weight: 700; margin-bottom: 12px; }
    .feature-desc { font-size: 16px; color: var(--text-secondary); line-height: 1.6; }

    /* Stats */
    .stats { background: linear-gradient(135deg, #0071e3, #5856d6); padding: 60px 24px; }
    .stats-inner { max-width: 900px; margin: 0 auto; display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 32px; text-align: center; }
    .stat-num { font-size: 48px; font-weight: 700; color: #fff; }
    .stat-label { font-size: 15px; color: rgba(255,255,255,0.8); margin-top: 4px; }

    /* CTA */
    .bottom-cta { padding: 80px 24px; text-align: center; }
    .bottom-cta h2 { font-size: 36px; font-weight: 700; margin-bottom: 16px; }
    .bottom-cta p { font-size: 18px; color: var(--text-secondary); margin-bottom: 36px; }

    @media (max-width: 768px) {
      .hero-title { font-size: 36px; }
      .hero-subtitle { font-size: 17px; }
      .features-title { font-size: 28px; }
      .stat-num { font-size: 36px; }
    }
  </style>
</head>
<body>
  <nav class="top-nav">
    <div class="nav-inner">
      <a href="/intro.jsp" class="nav-brand"><i class="bi bi-cpu-fill me-2" style="color:#0071e3;"></i>AI Workflow Lab</a>
      <div class="nav-links">
        <a href="/AI/user/tools/navigator.jsp">AI 도구 탐색</a>
        <a href="/AI/user/lab/index.jsp">실습 랩</a>
        <a href="/AI/admin/auth/login.jsp">관리자</a>
        <a href="/AI/user/home.jsp" class="btn-nav">시작하기</a>
      </div>
    </div>
  </nav>

  <!-- Hero -->
  <section class="hero">
    <div class="hero-eyebrow">AI Workflow Lab</div>
    <h1 class="hero-title">AI 실무 역량을<br>가장 빠르게</h1>
    <p class="hero-subtitle">AI 도구 탐색부터 실전 프로젝트까지,<br>체계적인 AI 학습 플랫폼</p>
    <div class="hero-actions">
      <a href="/AI/user/home.jsp" class="btn-hero-primary">
        <i class="bi bi-rocket-takeoff"></i> 지금 시작하기
      </a>
      <a href="/AI/user/tools/navigator.jsp" class="btn-hero-secondary">
        <i class="bi bi-compass"></i> AI 도구 탐색
      </a>
    </div>
  </section>

  <!-- AI 로고 배너 -->
  <section class="logos-section">
    <p class="logos-label">지원하는 AI 서비스</p>
    <div class="logos-track">
      <div class="logo-chip"><img src="/AI/assets/img/providers/openai.svg" alt="OpenAI"><span>ChatGPT</span></div>
      <div class="logo-chip"><img src="/AI/assets/img/providers/anthropic.svg" alt="Anthropic"><span>Claude</span></div>
      <div class="logo-chip"><img src="/AI/assets/img/providers/google.svg" alt="Google"><span>Gemini</span></div>
      <div class="logo-chip"><img src="/AI/assets/img/providers/meta.svg" alt="Meta"><span>Llama</span></div>
      <div class="logo-chip"><img src="/AI/assets/img/providers/microsoft.svg" alt="Microsoft"><span>Copilot</span></div>
      <div class="logo-chip"><img src="/AI/assets/img/providers/mistral.svg" alt="Mistral"><span>Mistral</span></div>
      <div class="logo-chip"><img src="/AI/assets/img/providers/stability.svg" alt="Stability"><span>Stable Diffusion</span></div>
      <div class="logo-chip"><img src="/AI/assets/img/providers/cohere.svg" alt="Cohere"><span>Cohere</span></div>
      <div class="logo-chip"><img src="/AI/assets/img/providers/huggingface.svg" alt="HuggingFace"><span>HuggingFace</span></div>
      <!-- 복사 (무한 스크롤) -->
      <div class="logo-chip"><img src="/AI/assets/img/providers/openai.svg" alt="OpenAI"><span>ChatGPT</span></div>
      <div class="logo-chip"><img src="/AI/assets/img/providers/anthropic.svg" alt="Anthropic"><span>Claude</span></div>
      <div class="logo-chip"><img src="/AI/assets/img/providers/google.svg" alt="Google"><span>Gemini</span></div>
      <div class="logo-chip"><img src="/AI/assets/img/providers/meta.svg" alt="Meta"><span>Llama</span></div>
      <div class="logo-chip"><img src="/AI/assets/img/providers/microsoft.svg" alt="Microsoft"><span>Copilot</span></div>
      <div class="logo-chip"><img src="/AI/assets/img/providers/mistral.svg" alt="Mistral"><span>Mistral</span></div>
      <div class="logo-chip"><img src="/AI/assets/img/providers/stability.svg" alt="Stability"><span>Stable Diffusion</span></div>
      <div class="logo-chip"><img src="/AI/assets/img/providers/cohere.svg" alt="Cohere"><span>Cohere</span></div>
      <div class="logo-chip"><img src="/AI/assets/img/providers/huggingface.svg" alt="HuggingFace"><span>HuggingFace</span></div>
    </div>
  </section>

  <!-- 핵심 기능 -->
  <section class="features">
    <h2 class="features-title">AI 역량 성장을 위한 모든 것</h2>
    <p class="features-sub">처음 AI를 시작하는 사람부터 실무 전문가까지</p>
    <div class="features-grid">
      <div class="feature-card">
        <div class="feature-icon">🧭</div>
        <h3 class="feature-title">AI 도구 탐색기</h3>
        <p class="feature-desc">업무 목적과 난이도에 맞는 AI 도구를 추천받고, ChatGPT·Claude·Gemini 등 50+ 도구를 비교·탐색하세요.</p>
        <a href="/AI/user/tools/navigator.jsp" class="btn btn-outline-primary btn-sm mt-3">탐색하기 →</a>
      </div>
      <div class="feature-card">
        <div class="feature-icon">🧪</div>
        <h3 class="feature-title">AI 실습 랩</h3>
        <p class="feature-desc">실제 비즈니스 시나리오로 AI를 활용하는 실전 프로젝트를 수행하고, 포트폴리오를 쌓으세요.</p>
        <a href="/AI/user/lab/index.jsp" class="btn btn-outline-success btn-sm mt-3">실습 시작 →</a>
      </div>
      <div class="feature-card">
        <div class="feature-icon">📊</div>
        <h3 class="feature-title">워크플로우 가이드</h3>
        <p class="feature-desc">마케팅, 개발, 디자인, 데이터 분석 등 분야별 AI 워크플로우를 단계적으로 학습하세요.</p>
        <a href="/AI/user/guides/index.jsp" class="btn btn-outline-secondary btn-sm mt-3">가이드 보기 →</a>
      </div>
    </div>
  </section>

  <!-- 통계 -->
  <section class="stats">
    <div class="stats-inner">
      <div>
        <div class="stat-num">50+</div>
        <div class="stat-label">등록된 AI 도구</div>
      </div>
      <div>
        <div class="stat-num">20+</div>
        <div class="stat-label">실습 프로젝트</div>
      </div>
      <div>
        <div class="stat-num">3</div>
        <div class="stat-label">난이도 레벨</div>
      </div>
      <div>
        <div class="stat-num">100%</div>
        <div class="stat-label">무료 시작 가능</div>
      </div>
    </div>
  </section>

  <!-- 하단 CTA -->
  <section class="bottom-cta">
    <h2>지금 바로 AI 여정을 시작하세요</h2>
    <p>회원가입 없이도 AI 도구를 탐색할 수 있습니다</p>
    <div class="hero-actions">
      <a href="/AI/user/home.jsp" class="btn-hero-primary">
        <i class="bi bi-arrow-right-circle"></i> 플랫폼 입장하기
      </a>
      <a href="/AI/admin/auth/login.jsp" class="btn-hero-secondary">
        <i class="bi bi-shield-lock"></i> 관리자 로그인
      </a>
    </div>
  </section>
</body>
</html>
