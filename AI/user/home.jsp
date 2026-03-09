<%--
  AI Workflow Lab 홈페이지 — 리디자인 (Linear/Raycast dark theme)
--%>
<%@ page contentType="text/html; charset=UTF-8" buffer="128kb" autoFlush="true" %>
<%@ page isELIgnored="true" %>
<%@ page import="dao.AIToolDAO" %>
<%@ page import="model.AITool" %>
<%@ page import="model.User" %>
<%@ page import="java.util.List" %>
<%@ include file="/AI/user/_common.jsp" %>

<%
  User user = (User) session.getAttribute("user");

  AIToolDAO toolDao = new AIToolDAO();
  List<AITool> allPopular = toolDao.findPopular(8);
  List<AITool> popularTools = allPopular.subList(0, Math.min(4, allPopular.size()));
%>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>AI Workflow Lab — AI 도구 탐색과 실습 프로젝트 플랫폼</title>
  <meta name="description" content="AI 도구 탐색부터 실습 프로젝트까지, AI 실무 역량을 키우는 통합 플랫폼.">
  <link rel="icon" href="data:,">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
  <link rel="stylesheet" href="/AI/assets/css/dark-theme.css">
  <link rel="stylesheet" href="/AI/assets/css/tools.css">
  <link rel="stylesheet" href="/AI/assets/css/animations.css">
  <script src="https://cdn.jsdelivr.net/npm/gsap@3.12.2/dist/gsap.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/gsap@3.12.2/dist/ScrollTrigger.min.js"></script>

  <style>
    /* ===== Reset / Base ===== */
    body {
      padding-top: 60px;
      background: var(--bg-primary, #0a0f1e);
      color: var(--text-primary, #f1f5f9);
      font-family: 'Noto Sans KR', -apple-system, BlinkMacSystemFont, sans-serif;
      overflow-x: hidden;
    }

    /* ===== Hero ===== */
    .home-hero {
      position: relative;
      min-height: 80vh;
      display: flex;
      align-items: center;
      justify-content: center;
      overflow: hidden;
      padding: 80px 24px 96px;
    }

    /* Mesh gradient orbs */
    .home-hero::before {
      content: '';
      position: absolute;
      inset: 0;
      background:
        radial-gradient(ellipse 60% 50% at 20% 30%,  rgba(59,130,246,0.18) 0%, transparent 70%),
        radial-gradient(ellipse 50% 60% at 80% 20%,  rgba(139,92,246,0.16) 0%, transparent 70%),
        radial-gradient(ellipse 40% 40% at 50% 80%,  rgba(6,182,212,0.12)  0%, transparent 70%),
        radial-gradient(ellipse 70% 70% at 50% 50%,  rgba(10,15,30,0.0)    0%, transparent 100%);
      pointer-events: none;
      z-index: 0;
    }

    /* Subtle grid overlay */
    .home-hero::after {
      content: '';
      position: absolute;
      inset: 0;
      background-image:
        linear-gradient(rgba(255,255,255,0.025) 1px, transparent 1px),
        linear-gradient(90deg, rgba(255,255,255,0.025) 1px, transparent 1px);
      background-size: 60px 60px;
      mask-image: radial-gradient(ellipse 80% 80% at 50% 50%, black 30%, transparent 100%);
      pointer-events: none;
      z-index: 0;
    }

    .home-hero__content {
      position: relative;
      z-index: 1;
      text-align: center;
      max-width: 760px;
      width: 100%;
    }

    .home-hero__eyebrow {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      padding: 5px 14px;
      border-radius: 999px;
      background: rgba(59,130,246,0.12);
      border: 1px solid rgba(59,130,246,0.25);
      font-size: 0.8125rem;
      font-weight: 500;
      color: #60a5fa;
      margin-bottom: 28px;
      letter-spacing: 0.01em;
    }

    .home-hero__title {
      font-size: clamp(2.25rem, 6vw, 3.75rem);
      font-weight: 700;
      line-height: 1.15;
      letter-spacing: -0.03em;
      margin: 0 0 20px;
      color: var(--text-primary, #f1f5f9);
    }

    .home-hero__title .accent {
      background: linear-gradient(135deg, #3b82f6, #8b5cf6);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      background-clip: text;
    }

    .home-hero__sub {
      font-size: clamp(1rem, 2.5vw, 1.125rem);
      color: var(--text-secondary, #94a3b8);
      line-height: 1.7;
      margin: 0 0 40px;
      max-width: 520px;
      margin-left: auto;
      margin-right: auto;
    }

    .home-hero__cta {
      display: flex;
      gap: 12px;
      justify-content: center;
      flex-wrap: wrap;
    }

    .hero-btn-primary {
      display: inline-flex;
      align-items: center;
      gap: 8px;
      padding: 13px 28px;
      border-radius: 10px;
      background: linear-gradient(135deg, #3b82f6, #8b5cf6);
      color: #fff;
      -webkit-text-fill-color: #fff;
      font-size: 0.9375rem;
      font-weight: 600;
      text-decoration: none;
      border: none;
      box-shadow: 0 4px 20px rgba(59,130,246,0.4);
      transition: all 0.2s ease;
    }

    .hero-btn-primary:hover {
      transform: translateY(-2px);
      box-shadow: 0 8px 30px rgba(59,130,246,0.55);
      color: #fff;
      -webkit-text-fill-color: #fff;
    }

    .hero-btn-secondary {
      display: inline-flex;
      align-items: center;
      gap: 8px;
      padding: 13px 28px;
      border-radius: 10px;
      background: rgba(255,255,255,0.06);
      color: var(--text-primary, #f1f5f9);
      -webkit-text-fill-color: var(--text-primary, #f1f5f9);
      font-size: 0.9375rem;
      font-weight: 600;
      text-decoration: none;
      border: 1px solid rgba(255,255,255,0.14);
      transition: all 0.2s ease;
    }

    .hero-btn-secondary:hover {
      background: rgba(255,255,255,0.10);
      border-color: rgba(255,255,255,0.24);
      color: #fff;
      -webkit-text-fill-color: #fff;
      transform: translateY(-2px);
    }

    /* ===== Logo Scroll Banner ===== */
    .logos-banner {
      padding: 28px 0;
      overflow: hidden;
      border-top: 1px solid rgba(255,255,255,0.06);
      border-bottom: 1px solid rgba(255,255,255,0.06);
      background: rgba(255,255,255,0.015);
    }

    .logos-track {
      display: flex;
      gap: 44px;
      align-items: center;
      animation: scrollLogos 28s linear infinite;
      width: max-content;
    }

    .logos-track:hover { animation-play-state: paused; }

    @keyframes scrollLogos {
      0%   { transform: translateX(0); }
      100% { transform: translateX(-50%); }
    }

    .logos-item {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 6px;
      opacity: 0.4;
      transition: opacity 0.2s;
      flex-shrink: 0;
      cursor: default;
    }

    .logos-item:hover { opacity: 0.85; }
    .logos-item img { width: 36px; height: 36px; border-radius: 8px; object-fit: contain; }
    .logos-item span { font-size: 10px; color: var(--text-muted, #64748b); font-weight: 500; white-space: nowrap; }

    /* ===== Section Shared ===== */
    .home-section {
      padding: 88px 0;
    }

    .home-section + .home-section {
      border-top: 1px solid rgba(255,255,255,0.06);
    }

    .section-inner {
      max-width: 1200px;
      margin: 0 auto;
      padding: 0 24px;
    }

    .section-header {
      margin-bottom: 48px;
    }

    .section-eyebrow {
      font-size: 0.75rem;
      font-weight: 600;
      color: #60a5fa;
      text-transform: uppercase;
      letter-spacing: 0.1em;
      margin-bottom: 10px;
    }

    .section-title {
      font-size: clamp(1.5rem, 3.5vw, 2rem);
      font-weight: 700;
      letter-spacing: -0.02em;
      color: var(--text-primary, #f1f5f9);
      margin: 0 0 10px;
    }

    .section-sub {
      font-size: 1rem;
      color: var(--text-secondary, #94a3b8);
      margin: 0;
    }

    /* ===== Feature Cards ===== */
    .feature-grid {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 20px;
    }

    .feature-card {
      background: var(--glass-bg, rgba(255,255,255,0.05));
      border: 1px solid var(--glass-border, rgba(255,255,255,0.10));
      border-radius: 16px;
      padding: 32px 28px;
      transition: all 0.25s ease;
      position: relative;
      overflow: hidden;
    }

    .feature-card::before {
      content: '';
      position: absolute;
      inset: 0;
      border-radius: 16px;
      opacity: 0;
      transition: opacity 0.25s ease;
    }

    .feature-card--blue::before  { background: radial-gradient(ellipse 60% 40% at 30% 20%, rgba(59,130,246,0.12), transparent); }
    .feature-card--purple::before { background: radial-gradient(ellipse 60% 40% at 30% 20%, rgba(139,92,246,0.12), transparent); }
    .feature-card--cyan::before   { background: radial-gradient(ellipse 60% 40% at 30% 20%, rgba(6,182,212,0.12), transparent); }

    .feature-card:hover {
      border-color: rgba(59,130,246,0.30);
      transform: translateY(-5px);
      box-shadow: 0 12px 40px rgba(0,0,0,0.3), 0 0 0 1px rgba(59,130,246,0.08);
    }

    .feature-card:hover::before { opacity: 1; }

    .feature-icon {
      font-size: 2.25rem;
      line-height: 1;
      margin-bottom: 20px;
      display: block;
      position: relative;
      z-index: 1;
    }

    .feature-card__name {
      font-size: 1.0625rem;
      font-weight: 700;
      color: var(--text-primary, #f1f5f9);
      margin: 0 0 10px;
      position: relative;
      z-index: 1;
    }

    .feature-card__desc {
      font-size: 0.875rem;
      color: var(--text-secondary, #94a3b8);
      line-height: 1.7;
      margin: 0 0 20px;
      position: relative;
      z-index: 1;
    }

    .feature-card__link {
      display: inline-flex;
      align-items: center;
      gap: 5px;
      font-size: 0.8125rem;
      font-weight: 600;
      color: #60a5fa;
      -webkit-text-fill-color: #60a5fa;
      text-decoration: none;
      transition: gap 0.2s;
      position: relative;
      z-index: 1;
    }

    .feature-card__link:hover { gap: 8px; color: #93c5fd; -webkit-text-fill-color: #93c5fd; }

    /* ===== Tools Section ===== */
    .tools-section-header {
      display: flex;
      justify-content: space-between;
      align-items: flex-end;
      margin-bottom: 32px;
      flex-wrap: wrap;
      gap: 16px;
    }

    .view-all-link {
      display: inline-flex;
      align-items: center;
      gap: 5px;
      font-size: 0.875rem;
      font-weight: 500;
      color: #60a5fa;
      -webkit-text-fill-color: #60a5fa;
      text-decoration: none;
      transition: gap 0.2s;
      flex-shrink: 0;
    }

    .view-all-link:hover { gap: 8px; color: #93c5fd; -webkit-text-fill-color: #93c5fd; }

    /* Tool card (dark variant matching tools.css) */
    .h-tool-card {
      background: var(--glass-bg, rgba(255,255,255,0.05));
      border: 1px solid var(--glass-border, rgba(255,255,255,0.10));
      border-radius: 14px;
      overflow: hidden;
      display: flex;
      flex-direction: column;
      height: 100%;
      transition: all 0.22s ease;
    }

    .h-tool-card:hover {
      border-color: rgba(59,130,246,0.35);
      transform: translateY(-4px);
      box-shadow: 0 0 24px rgba(59,130,246,0.18), 0 12px 32px rgba(0,0,0,0.3);
    }

    .h-tool-card__header {
      padding: 12px 16px;
      border-bottom: 1px solid var(--glass-border, rgba(255,255,255,0.10));
      background: rgba(255,255,255,0.03);
      display: flex;
      justify-content: space-between;
      align-items: center;
      gap: 8px;
    }

    .h-tool-card__provider {
      display: flex;
      align-items: center;
      gap: 8px;
      min-width: 0;
    }

    .h-tool-card__logo {
      width: 22px;
      height: 22px;
      border-radius: 5px;
      object-fit: contain;
      flex-shrink: 0;
    }

    .h-tool-card__provider-name {
      font-size: 0.75rem;
      color: var(--text-muted, #64748b);
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }

    .h-tool-card__free {
      font-size: 0.6875rem;
      font-weight: 600;
      padding: 2px 8px;
      border-radius: 999px;
      background: rgba(34,197,94,0.12);
      color: #4ade80;
      border: 1px solid rgba(34,197,94,0.25);
      flex-shrink: 0;
    }

    .h-tool-card__body {
      padding: 16px;
      flex: 1;
    }

    .h-tool-card__name {
      font-size: 0.9375rem;
      font-weight: 700;
      color: var(--text-primary, #f1f5f9);
      margin: 0 0 8px;
    }

    .h-tool-card__desc {
      font-size: 0.8125rem;
      color: var(--text-secondary, #94a3b8);
      line-height: 1.6;
      margin: 0 0 14px;
      display: -webkit-box;
      -webkit-line-clamp: 2;
      -webkit-box-orient: vertical;
      overflow: hidden;
    }

    .h-tool-card__tags {
      display: flex;
      gap: 6px;
      flex-wrap: wrap;
    }

    .h-tool-card__cat {
      font-size: 0.6875rem;
      font-weight: 500;
      padding: 2px 8px;
      border-radius: 5px;
      background: rgba(59,130,246,0.10);
      color: #60a5fa;
      border: 1px solid rgba(59,130,246,0.20);
    }

    .h-tool-card__diff {
      font-size: 0.6875rem;
      font-weight: 500;
      padding: 2px 8px;
      border-radius: 5px;
    }

    .h-tool-card__diff--beginner     { background: rgba(34,197,94,0.10); color: #4ade80; border: 1px solid rgba(34,197,94,0.20); }
    .h-tool-card__diff--intermediate { background: rgba(245,158,11,0.10); color: #fbbf24; border: 1px solid rgba(245,158,11,0.20); }
    .h-tool-card__diff--advanced     { background: rgba(239,68,68,0.10);  color: #f87171; border: 1px solid rgba(239,68,68,0.20); }

    .h-tool-card__footer {
      padding: 12px 16px;
      border-top: 1px solid var(--glass-border, rgba(255,255,255,0.10));
    }

    .h-tool-card__btn {
      display: block;
      text-align: center;
      padding: 8px 16px;
      border-radius: 8px;
      background: rgba(59,130,246,0.12);
      color: #60a5fa;
      -webkit-text-fill-color: #60a5fa;
      font-size: 0.8125rem;
      font-weight: 600;
      text-decoration: none;
      border: 1px solid rgba(59,130,246,0.22);
      transition: all 0.2s ease;
    }

    .h-tool-card__btn:hover {
      background: rgba(59,130,246,0.22);
      color: #93c5fd;
      -webkit-text-fill-color: #93c5fd;
    }

    /* ===== Stats Section ===== */
    .stats-section {
      background: rgba(255,255,255,0.015);
    }

    .stats-grid {
      display: grid;
      grid-template-columns: repeat(4, 1fr);
      gap: 20px;
    }

    .stat-card {
      background: var(--glass-bg, rgba(255,255,255,0.05));
      border: 1px solid var(--glass-border, rgba(255,255,255,0.10));
      border-radius: 14px;
      padding: 28px 24px;
      text-align: center;
      transition: all 0.22s ease;
    }

    .stat-card:hover {
      border-color: rgba(59,130,246,0.25);
      transform: translateY(-3px);
      box-shadow: 0 8px 24px rgba(0,0,0,0.2);
    }

    .stat-card__number {
      font-size: 2.25rem;
      font-weight: 800;
      letter-spacing: -0.03em;
      background: linear-gradient(135deg, #3b82f6, #8b5cf6);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      background-clip: text;
      margin-bottom: 6px;
      display: block;
    }

    .stat-card__label {
      font-size: 0.875rem;
      color: var(--text-secondary, #94a3b8);
      font-weight: 500;
    }

    /* ===== Responsive ===== */
    @media (max-width: 992px) {
      .feature-grid { grid-template-columns: 1fr; gap: 16px; }
      .stats-grid   { grid-template-columns: repeat(2, 1fr); }
    }

    @media (max-width: 768px) {
      .home-hero { min-height: 70vh; padding: 60px 20px 72px; }
      .home-section { padding: 64px 0; }
      .stats-grid { grid-template-columns: repeat(2, 1fr); }
    }

    @media (max-width: 480px) {
      .stats-grid { grid-template-columns: 1fr 1fr; gap: 12px; }
      .stat-card  { padding: 20px 16px; }
      .stat-card__number { font-size: 1.75rem; }
    }
  </style>
</head>
<body>
  <%@ include file="/AI/partials/header.jsp" %>

  <!-- ================================================================
       Hero Section
       ================================================================ -->
  <section class="home-hero" id="hero">
    <div class="home-hero__content">
      <div class="home-hero__eyebrow" id="heroEyebrow">
        <i class="bi bi-stars"></i>
        AI 실무 학습 플랫폼
      </div>
      <h1 class="home-hero__title" id="heroTitle">
        AI 도구 탐색부터<br>
        <span class="accent">실습 프로젝트</span>까지
      </h1>
      <p class="home-hero__sub" id="heroSub">
        실무 AI 역량을 키우는 통합 플랫폼
      </p>
      <div class="home-hero__cta" id="heroCta">
        <a href="/AI/user/tools/navigator.jsp" class="hero-btn-primary">
          <i class="bi bi-compass"></i>
          도구 탐색하기
        </a>
        <a href="/AI/user/lab/index.jsp" class="hero-btn-secondary">
          <i class="bi bi-flask"></i>
          실습 시작하기
        </a>
      </div>
    </div>
  </section>

  <!-- ================================================================
       AI Provider Logo Scroll
       ================================================================ -->
  <div class="logos-banner">
    <div class="logos-track">
      <!-- 1세트 -->
      <div class="logos-item"><img src="/AI/assets/img/providers/openai.svg"    alt="OpenAI"><span>ChatGPT</span></div>
      <div class="logos-item"><img src="/AI/assets/img/providers/google.svg"    alt="Google"><span>Gemini</span></div>
      <div class="logos-item"><img src="/AI/assets/img/providers/anthropic.svg" alt="Anthropic"><span>Claude</span></div>
      <div class="logos-item"><img src="/AI/assets/img/providers/meta.svg"      alt="Meta"><span>Llama</span></div>
      <div class="logos-item"><img src="/AI/assets/img/providers/microsoft.svg" alt="Microsoft"><span>Copilot</span></div>
      <div class="logos-item"><img src="/AI/assets/img/providers/mistral.svg"   alt="Mistral"><span>Mistral</span></div>
      <div class="logos-item"><img src="/AI/assets/img/providers/stability.svg" alt="Stability"><span>Stable Diffusion</span></div>
      <div class="logos-item"><img src="/AI/assets/img/providers/cohere.svg"    alt="Cohere"><span>Cohere</span></div>
      <div class="logos-item"><img src="/AI/assets/img/providers/huggingface.svg" alt="HuggingFace"><span>HuggingFace</span></div>
      <!-- 2세트 (무한 루프) -->
      <div class="logos-item"><img src="/AI/assets/img/providers/openai.svg"    alt="OpenAI"><span>ChatGPT</span></div>
      <div class="logos-item"><img src="/AI/assets/img/providers/google.svg"    alt="Google"><span>Gemini</span></div>
      <div class="logos-item"><img src="/AI/assets/img/providers/anthropic.svg" alt="Anthropic"><span>Claude</span></div>
      <div class="logos-item"><img src="/AI/assets/img/providers/meta.svg"      alt="Meta"><span>Llama</span></div>
      <div class="logos-item"><img src="/AI/assets/img/providers/microsoft.svg" alt="Microsoft"><span>Copilot</span></div>
      <div class="logos-item"><img src="/AI/assets/img/providers/mistral.svg"   alt="Mistral"><span>Mistral</span></div>
      <div class="logos-item"><img src="/AI/assets/img/providers/stability.svg" alt="Stability"><span>Stable Diffusion</span></div>
      <div class="logos-item"><img src="/AI/assets/img/providers/cohere.svg"    alt="Cohere"><span>Cohere</span></div>
      <div class="logos-item"><img src="/AI/assets/img/providers/huggingface.svg" alt="HuggingFace"><span>HuggingFace</span></div>
    </div>
  </div>

  <!-- ================================================================
       Feature Cards — 핵심 기능 3개
       ================================================================ -->
  <section class="home-section">
    <div class="section-inner">
      <div class="section-header scroll-reveal">
        <p class="section-eyebrow">PLATFORM</p>
        <h2 class="section-title">AI 실무 역량을 키우는 모든 것</h2>
        <p class="section-sub">도구 탐색, 실습 랩, 구독 플랜 — 한 플랫폼에서</p>
      </div>

      <div class="feature-grid">
        <!-- 1 -->
        <div class="feature-card feature-card--blue scroll-reveal">
          <span class="feature-icon">🔍</span>
          <h3 class="feature-card__name">AI 도구 탐색기</h3>
          <p class="feature-card__desc">카테고리·난이도·키워드로 AI 도구를 검색하고 비교하세요. 50+ 도구 수록.</p>
          <a href="/AI/user/tools/navigator.jsp" class="feature-card__link">
            탐색하기 <i class="bi bi-arrow-right"></i>
          </a>
        </div>
        <!-- 2 -->
        <div class="feature-card feature-card--purple scroll-reveal">
          <span class="feature-icon">🧪</span>
          <h3 class="feature-card__name">실습 랩</h3>
          <p class="feature-card__desc">비즈니스 시나리오 기반 Tutorial · Real-world · Challenge 프로젝트로 실전 역량을 쌓으세요.</p>
          <a href="/AI/user/lab/index.jsp" class="feature-card__link">
            랩 입장하기 <i class="bi bi-arrow-right"></i>
          </a>
        </div>
        <!-- 3 -->
        <div class="feature-card feature-card--cyan scroll-reveal">
          <span class="feature-icon">💎</span>
          <h3 class="feature-card__name">구독 플랜</h3>
          <p class="feature-card__desc">Starter · Growth · Enterprise 단계별 플랜으로 나에게 맞는 AI 학습 환경을 구성하세요.</p>
          <a href="/AI/user/pricing.jsp" class="feature-card__link">
            요금제 보기 <i class="bi bi-arrow-right"></i>
          </a>
        </div>
      </div>
    </div>
  </section>

  <!-- ================================================================
       Popular Tools — 인기 AI 도구 4개
       ================================================================ -->
  <section class="home-section" style="background: rgba(255,255,255,0.015);">
    <div class="section-inner">
      <div class="tools-section-header scroll-reveal">
        <div>
          <p class="section-eyebrow">POPULAR</p>
          <h2 class="section-title">🔥 인기 AI 도구</h2>
          <p class="section-sub">가장 많이 활용되는 AI 도구들을 만나보세요</p>
        </div>
        <a href="/AI/user/tools/navigator.jsp" class="view-all-link">
          전체 보기 <i class="bi bi-arrow-right"></i>
        </a>
      </div>

      <div class="row g-4">
        <% if (popularTools.isEmpty()) { %>
        <div class="col-12 text-center py-5" style="color: var(--text-muted, #64748b);">
          <i class="bi bi-robot" style="font-size: 2.5rem;"></i>
          <p class="mt-3">등록된 AI 도구가 없습니다.</p>
        </div>
        <% } %>

        <% for (AITool tool : popularTools) {
             String[] logoInfo = getProviderLogo(tool.getProviderName(), tool.getToolName());
             String diffLevel = tool.getDifficultyLevel() != null ? tool.getDifficultyLevel().toLowerCase() : "beginner";
        %>
        <div class="col-lg-3 col-md-6 scroll-reveal">
          <div class="h-tool-card">
            <div class="h-tool-card__header">
              <div class="h-tool-card__provider">
                <img src="<%= logoInfo[0] %>"
                     alt="<%= escapeHtml(tool.getProviderName()) %>"
                     class="h-tool-card__logo"
                     onerror="this.style.display='none'">
                <span class="h-tool-card__provider-name">
                  <%= escapeHtml(safeString(tool.getProviderName(), "")) %>
                </span>
              </div>
              <% if (tool.isFreeTierAvailable()) { %>
              <span class="h-tool-card__free">무료</span>
              <% } %>
            </div>

            <div class="h-tool-card__body">
              <h5 class="h-tool-card__name"><%= escapeHtml(tool.getToolName()) %></h5>
              <p class="h-tool-card__desc"><%= escapeHtml(safeString(tool.getPurposeSummary(), "")) %></p>
              <div class="h-tool-card__tags">
                <span class="h-tool-card__cat"><%= escapeHtml(safeString(tool.getCategory(), "기타")) %></span>
                <span class="h-tool-card__diff h-tool-card__diff--<%= diffLevel %>">
                  <%= escapeHtml(safeString(tool.getDifficultyLevel(), "")) %>
                </span>
              </div>
            </div>

            <div class="h-tool-card__footer">
              <a href="/AI/user/tools/detail.jsp?id=<%= tool.getId() %>" class="h-tool-card__btn">
                자세히 보기
              </a>
            </div>
          </div>
        </div>
        <% } %>
      </div>
    </div>
  </section>

  <!-- ================================================================
       Stats Section — 통계
       ================================================================ -->
  <section class="home-section stats-section">
    <div class="section-inner">
      <div class="stats-grid">
        <div class="stat-card scroll-reveal">
          <span class="stat-card__number" data-target="50" data-suffix="+">0</span>
          <span class="stat-card__label">AI 도구</span>
        </div>
        <div class="stat-card scroll-reveal">
          <span class="stat-card__number" data-target="30" data-suffix="+">0</span>
          <span class="stat-card__label">실습 프로젝트</span>
        </div>
        <div class="stat-card scroll-reveal">
          <span class="stat-card__number" data-target="8" data-suffix="+">0</span>
          <span class="stat-card__label">카테고리</span>
        </div>
        <div class="stat-card scroll-reveal">
          <span class="stat-card__number" data-target="1000" data-suffix="+">0</span>
          <span class="stat-card__label">활성 사용자</span>
        </div>
      </div>
    </div>
  </section>

  <%@ include file="/AI/partials/footer.jsp" %>

  <!-- ================================================================
       GSAP Animations
       ================================================================ -->
  <script>
  (function () {
    if (typeof gsap === 'undefined') return;

    gsap.registerPlugin(ScrollTrigger);

    /* --- Hero fade-in sequence --- */
    var tl = gsap.timeline({ defaults: { ease: 'power3.out' } });

    tl.from('#heroEyebrow', { opacity: 0, y: 24, duration: 0.6 })
      .from('#heroTitle',   { opacity: 0, y: 40, duration: 0.7 }, '-=0.35')
      .from('#heroSub',     { opacity: 0, y: 28, duration: 0.6 }, '-=0.45')
      .from('#heroCta > *', { opacity: 0, y: 24, duration: 0.5, stagger: 0.12 }, '-=0.4');

    /* --- Scroll reveal (all .scroll-reveal elements) --- */
    document.querySelectorAll('.scroll-reveal').forEach(function (el) {
      ScrollTrigger.create({
        trigger: el,
        start: 'top 88%',
        onEnter: function () { el.classList.add('revealed'); }
      });
    });

    /* --- Stats count-up --- */
    document.querySelectorAll('.stat-card__number[data-target]').forEach(function (el) {
      var target = parseInt(el.dataset.target, 10);
      var suffix = el.dataset.suffix || '';

      ScrollTrigger.create({
        trigger: el,
        start: 'top 85%',
        once: true,
        onEnter: function () {
          gsap.to({ val: 0 }, {
            val: target,
            duration: 1.6,
            ease: 'power2.out',
            onUpdate: function () {
              el.textContent = Math.round(this.targets()[0].val).toLocaleString() + suffix;
            }
          });
        }
      });
    });
  })();
  </script>
</body>
</html>
