<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="description" content="AI Navigator - AI 모델 마켓플레이스 프로젝트 소개">
  <title>AI Navigator - 프로젝트 소개</title>
  <link rel="stylesheet" href="/AI/assets/css/landing.css?v=2.0">
  <link rel="stylesheet" href="/AI/assets/css/animations.css">
  <style>
    /* ===== Intro Section ===== */
    .intro-section {
      padding: 120px 20px 80px;
      max-width: 1200px;
      margin: 0 auto;
    }

    /* ===== Header Styles ===== */
    .intro-header {
      text-align: center;
      margin-bottom: 80px;
    }

    .intro-title {
      font-size: 56px;
      font-weight: 700;
      letter-spacing: -0.005em;
      color: var(--text);
      margin-bottom: 24px;
      background: linear-gradient(135deg, var(--accent), #5856d6);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      background-clip: text;
    }

    .intro-subtitle {
      font-size: 28px;
      line-height: 1.14286;
      font-weight: 400;
      letter-spacing: 0.007em;
      color: var(--text-secondary);
    }

    /* ===== Architecture Grid ===== */
    .architecture-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(500px, 1fr));
      gap: 40px;
      margin-bottom: 80px;
    }

    .architecture-card {
      background: var(--card);
      border: 1px solid var(--border);
      border-radius: 20px;
      padding: 40px;
      transition: all 0.3s ease;
      box-shadow: 0 2px 16px rgba(0, 0, 0, 0.08);
    }

    .architecture-card:hover {
      transform: translateY(-8px);
      box-shadow: 0 8px 32px rgba(0, 0, 0, 0.12);
    }

    .architecture-card h2 {
      font-size: 32px;
      font-weight: 700;
      letter-spacing: -0.003em;
      color: var(--text);
      margin-bottom: 24px;
      display: flex;
      align-items: center;
      gap: 12px;
    }

    .architecture-card h2::before {
      content: '';
      width: 4px;
      height: 32px;
      background: var(--accent);
      border-radius: 2px;
    }

    /* ===== Feature List ===== */
    .feature-list {
      list-style: none;
      padding: 0;
      margin: 0;
    }

    .feature-list li {
      padding: 16px 0 16px 32px;
      border-bottom: 1px solid var(--border);
      font-size: 17px;
      line-height: 1.47059;
      color: var(--text);
      position: relative;
    }

    .feature-list li:last-child {
      border-bottom: none;
    }

    .feature-list li::before {
      content: '✓';
      position: absolute;
      left: 0;
      color: var(--accent);
      font-weight: 700;
      font-size: 20px;
    }

    /* ===== Tech Stack ===== */
    .tech-stack {
      background: var(--bg-contrast);
      border-radius: 20px;
      padding: 40px;
      margin-bottom: 80px;
    }

    .tech-stack h2 {
      font-size: 40px;
      font-weight: 700;
      letter-spacing: -0.003em;
      color: var(--text);
      margin-bottom: 32px;
      text-align: center;
    }

    .tech-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
      gap: 24px;
    }

    .tech-item {
      background: var(--card);
      border: 1px solid var(--border);
      border-radius: 12px;
      padding: 24px;
      text-align: center;
      transition: all 0.3s ease;
    }

    .tech-item:hover {
      transform: translateY(-4px);
      box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
    }

    .tech-item h3 {
      font-size: 20px;
      font-weight: 600;
      color: var(--text);
      margin-bottom: 8px;
    }

    .tech-item p {
      font-size: 15px;
      color: var(--text-secondary);
      line-height: 1.5;
    }

    /* ===== Action Buttons ===== */
    .action-buttons {
      display: flex;
      gap: 20px;
      justify-content: center;
      margin-top: 60px;
      flex-wrap: wrap;
    }

    .btn-intro {
      padding: 16px 32px;
      font-size: 17px;
      font-weight: 500;
      border-radius: 12px;
      text-decoration: none;
      transition: all 0.3s ease;
      display: inline-flex;
      align-items: center;
      gap: 8px;
      cursor: pointer;
    }

    .btn-primary-intro {
      background: var(--accent);
      color: #ffffff;
      border: none;
    }

    .btn-primary-intro:hover {
      background: #0051d5;
      transform: translateY(-2px);
      box-shadow: 0 4px 16px rgba(0, 113, 227, 0.3);
    }

    .btn-secondary-intro {
      background: var(--surface);
      color: var(--text);
      border: 1px solid var(--border);
    }

    .btn-secondary-intro:hover {
      background: var(--bg-contrast);
      transform: translateY(-2px);
    }

    /* ===== Highlight Box ===== */
    .highlight-box {
      background: linear-gradient(135deg, rgba(0, 113, 227, 0.1), rgba(88, 86, 214, 0.1));
      border-left: 4px solid var(--accent);
      border-radius: 12px;
      padding: 24px;
      margin: 24px 0;
    }

    .highlight-box strong {
      color: var(--accent);
      font-weight: 600;
    }

    .highlight-box ul {
      list-style: none;
      padding-left: 0;
      margin-top: 12px;
    }

    /* ===== JSP Files Section ===== */
    .jsp-files-section {
      margin-top: 80px;
    }

    .jsp-files-grid {
      grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
    }

    /* ===== Responsive Design ===== */
    @media (max-width: 768px) {
      .intro-section {
        padding: 80px 20px 60px;
      }

      .intro-title {
        font-size: 40px;
      }

      .intro-subtitle {
        font-size: 22px;
      }

      .architecture-grid {
        grid-template-columns: 1fr;
        gap: 24px;
      }

      .architecture-card {
        padding: 24px;
      }

      .tech-stack {
        padding: 24px;
      }

      .action-buttons {
        flex-direction: column;
        align-items: stretch;
      }

      .btn-intro {
        width: 100%;
        justify-content: center;
      }
    }
  </style>
</head>
<body>
  <!-- Navigation -->
  <nav class="navbar" id="navbar" role="navigation" aria-label="메인 네비게이션">
    <div class="navbar-container">
      <a href="/intro.jsp" class="navbar-logo" aria-label="AI Navigator 홈">AI Navigator</a>
      <ul class="navbar-menu" id="navbarMenu" role="menubar">
        <li role="none"><a href="/AI/user/home.jsp" role="menuitem">유저 페이지</a></li>
        <li role="none"><a href="/AI/admin/auth/login.jsp" role="menuitem">관리자 페이지</a></li>
      </ul>
    </div>
  </nav>

  <!-- Main Content -->
  <main class="intro-section" role="main">
    <div class="intro-header fade-in">
      <h1 class="intro-title">AI Navigator</h1>
      <p class="intro-subtitle">AI 모델 마켓플레이스 프로젝트 소개</p>
    </div>

    <div class="architecture-grid" role="list">
      <!-- User Page Section -->
      <article class="architecture-card fade-in" role="listitem">
        <h2>유저 페이지</h2>
        <div class="highlight-box">
          <strong>주요 기능:</strong> 일반 사용자들을 위한 AI 모델 검색, 탐색, 구매 인터페이스
        </div>
        <ul class="feature-list">
          <li><strong>홈페이지:</strong> 추천 AI 모델 및 패키지 카드 레이아웃으로 제공</li>
          <li><strong>검색 기능:</strong> 모달리티(이미지, 비디오, 오디오 등) 기반 키워드 검색</li>
          <li><strong>모델 목록:</strong> 텍스트/이미지/비디오/오디오/임베딩 카테고리 필터링</li>
          <li><strong>모델 상세:</strong> 각 모델의 기능, 사양, 가격 정보 제공</li>
          <li><strong>패키지 구매:</strong> 여러 모델을 묶은 패키지 상품 제공</li>
          <li><strong>장바구니:</strong> 실시간 가격 계산 및 수량 조정</li>
          <li><strong>결제 시스템:</strong> 주문 내역 확인 및 결제 진행</li>
          <li><strong>마이페이지:</strong> 구독 내역, 구매 내역, 주문 관리</li>
        </ul>
        
        <div class="highlight-box">
          <strong>구현 특징:</strong>
          <ul>
            <li>• 반응형 디자인 (모바일/태블릿/데스크톱 지원)</li>
            <li>• Glassmorphism UI (투명 효과 및 블러 적용)</li>
            <li>• 실시간 AJAX 검색 및 필터링</li>
            <li>• 부드러운 스크롤 애니메이션</li>
            <li>• 세션 기반 인증 및 장바구니 관리</li>
          </ul>
        </div>
      </article>

      <!-- Admin Page Section -->
      <article class="architecture-card fade-in" role="listitem">
        <h2>관리자 페이지</h2>
        <div class="highlight-box">
          <strong>주요 기능:</strong> 시스템 관리자가 AI 모델, 패키지, 사용자를 관리하는 백오피스
        </div>
        <ul class="feature-list">
          <li><strong>대시보드:</strong> 활성 모델 수, 최근 주문, 통계 정보</li>
          <li><strong>모델 관리:</strong> AI 모델 추가/수정/삭제, 상세 정보 입력</li>
          <li><strong>카테고리 관리:</strong> 모델 카테고리 분류 시스템</li>
          <li><strong>제공자 관리:</strong> AI 모델 제공 업체 정보 관리</li>
          <li><strong>패키지 관리:</strong> 모델 패키지 구성 및 가격 설정</li>
          <li><strong>요금제 관리:</strong> 구독 요금제 생성 및 관리</li>
          <li><strong>고객 관리:</strong> 사용자 정보, 구매 내역, 구독 현황 조회</li>
          <li><strong>판매 통계:</strong> 매출, 주문 추이, 인기 모델 분석</li>
        </ul>
        
        <div class="highlight-box">
          <strong>구현 특징:</strong>
          <ul>
            <li>• 사이드바 네비게이션 (고정 레이아웃)</li>
            <li>• Role-based 접근 제어 (일반 관리자/슈퍼관리자)</li>
            <li>• 모달 팝업을 통한 상세 정보 조회</li>
            <li>• CRUD 작업 통합 인터페이스</li>
            <li>• 다크모드 지원 (선택적)</li>
          </ul>
        </div>
      </article>
    </div>

    <!-- Tech Stack Section -->
    <section class="tech-stack fade-in" aria-labelledby="tech-stack-title">
      <h2 id="tech-stack-title">기술 스택</h2>
      <div class="tech-grid" role="list">
        <article class="tech-item" role="listitem">
          <h3>Backend</h3>
          <p>Java (JSP/Servlet)<br>Tomcat 9<br>MySQL Database</p>
        </article>
        <article class="tech-item" role="listitem">
          <h3>Frontend</h3>
          <p>HTML5, CSS3<br>JavaScript (ES6+)<br>Glassmorphism UI</p>
        </article>
        <article class="tech-item" role="listitem">
          <h3>Database</h3>
          <p>MySQL 8.0<br>JDBC Connection<br>Connection Pooling</p>
        </article>
        <article class="tech-item" role="listitem">
          <h3>Architecture</h3>
          <p>MVC Pattern<br>DAO Pattern<br>Session Management</p>
        </article>
        <article class="tech-item" role="listitem">
          <h3>Security</h3>
          <p>CSRF Protection<br>Role-based Access<br>Password Hashing</p>
        </article>
        <article class="tech-item" role="listitem">
          <h3>Features</h3>
          <p>Real-time Search<br>AJAX Updates<br>Smooth Animations</p>
        </article>
      </div>
    </section>

    <!-- JSP Files Section -->
    <section class="tech-stack fade-in jsp-files-section" aria-labelledby="jsp-files-title">
      <h2 id="jsp-files-title">주요 JSP 파일</h2>
      <div class="architecture-grid jsp-files-grid" role="list">
        <!-- User Page JSP Files -->
        <article class="architecture-card" role="listitem">
          <h2>유저 페이지 JSP</h2>
          <ul class="feature-list">
            <li><strong>home.jsp</strong> - 메인 홈페이지 (추천 모델/패키지)</li>
            <li><strong>models.jsp</strong> - AI 모델 목록 및 필터링</li>
            <li><strong>modelDetail.jsp</strong> - 모델 상세 정보</li>
            <li><strong>package.jsp</strong> - 패키지 목록</li>
            <li><strong>packageDetail.jsp</strong> - 패키지 상세 정보</li>
            <li><strong>search.jsp</strong> - 검색 결과 페이지</li>
            <li><strong>cart.jsp</strong> - 장바구니</li>
            <li><strong>checkout.jsp</strong> - 결제 페이지</li>
            <li><strong>pricing.jsp</strong> - 요금제 안내</li>
            <li><strong>mypage.jsp</strong> - 마이페이지 (주문/구독 관리)</li>
            <li><strong>login.jsp</strong> - 로그인</li>
            <li><strong>signup.jsp</strong> - 회원가입</li>
          </ul>
        </article>

        <!-- Admin Page JSP Files -->
        <article class="architecture-card" role="listitem">
          <h2>관리자 페이지 JSP</h2>
          <ul class="feature-list">
            <li><strong>dashboard.jsp</strong> - 관리자 대시보드</li>
            <li><strong>models/index.jsp</strong> - 모델 관리 목록</li>
            <li><strong>models/form.jsp</strong> - 모델 추가/수정 폼</li>
            <li><strong>categories/index.jsp</strong> - 카테고리 관리</li>
            <li><strong>providers/index.jsp</strong> - 제공자 관리</li>
            <li><strong>packages/index.jsp</strong> - 패키지 관리</li>
            <li><strong>pricing/index.jsp</strong> - 요금제 관리</li>
            <li><strong>users/index.jsp</strong> - 사용자 관리</li>
            <li><strong>statistics/index.jsp</strong> - 통계 대시보드</li>
            <li><strong>auth/login.jsp</strong> - 관리자 로그인</li>
          </ul>
        </article>

        <!-- API and Other JSP Files -->
        <article class="architecture-card" role="listitem">
          <h2>API 및 기타 JSP</h2>
          <ul class="feature-list">
            <li><strong>api/search.jsp</strong> - 검색 API</li>
            <li><strong>api/models.jsp</strong> - 모델 목록 API</li>
            <li><strong>api/packages.jsp</strong> - 패키지 목록 API</li>
            <li><strong>api/categories.jsp</strong> - 카테고리 목록 API</li>
            <li><strong>api/subscribe.jsp</strong> - 구독 API</li>
            <li><strong>api/cart-summary.jsp</strong> - 장바구니 요약 API</li>
            <li><strong>landing/index.jsp</strong> - 랜딩 페이지</li>
            <li><strong>landing/tech.jsp</strong> - 기술 소개</li>
            <li><strong>landing/roadmap.jsp</strong> - 로드맵</li>
            <li><strong>partials/header.jsp</strong> - 공통 헤더</li>
            <li><strong>partials/footer.jsp</strong> - 공통 푸터</li>
          </ul>
        </article>

        <!-- DAO and DTO (Model) -->
        <article class="architecture-card" role="listitem">
          <h2>DAO 및 DTO (Model)</h2>
          <ul class="feature-list">
            <li><strong>AdminDAO</strong> - 관리자 데이터 접근</li>
            <li><strong>AIModelDAO</strong> - AI 모델 데이터 접근</li>
            <li><strong>CategoryDAO</strong> - 카테고리 데이터 접근</li>
            <li><strong>OrderDAO</strong> - 주문 데이터 접근</li>
            <li><strong>PackageDAO</strong> - 패키지 데이터 접근</li>
            <li><strong>PackageItemDAO</strong> - 패키지 아이템 데이터 접근</li>
            <li><strong>PlanDAO</strong> - 요금제 데이터 접근</li>
            <li><strong>ProviderDAO</strong> - 제공자 데이터 접근</li>
            <li><strong>SearchDAO</strong> - 검색 기능 데이터 접근</li>
            <li><strong>SubscriptionDAO</strong> - 구독 데이터 접근</li>
            <li><strong>TagDAO</strong> - 태그 데이터 접근</li>
            <li><strong>UserDAO</strong> - 사용자 데이터 접근</li>
            <li><strong>Model Classes</strong> - Admin, AIModel, Category, Order, Package, Plan, Provider, Subscription, Tag, User 등</li>
          </ul>
        </article>
      </div>
    </section>

    <!-- Action Buttons -->
    <nav class="action-buttons fade-in" aria-label="주요 페이지 링크">
      <a href="/AI/user/home.jsp" class="btn-intro btn-primary-intro" aria-label="유저 페이지로 이동">
        <span aria-hidden="true">🚀</span> 유저 페이지 둘러보기
      </a>
      <a href="/AI/admin/auth/login.jsp" class="btn-intro btn-secondary-intro" aria-label="관리자 페이지 로그인으로 이동">
        <span aria-hidden="true">⚙️</span> 관리자 페이지 로그인
      </a>
    </nav>
  </main>

  <script src="/AI/assets/js/landing.js" defer></script>
  <script>
    (function() {
      'use strict';

      /**
       * Navbar 스크롤 효과 초기화
       */
      function initNavbarScroll() {
        const navbar = document.getElementById('navbar');
        if (!navbar) return;

        const SCROLL_THRESHOLD = 50;

        function handleScroll() {
          if (window.scrollY > SCROLL_THRESHOLD) {
            navbar.classList.add('scrolled');
          } else {
            navbar.classList.remove('scrolled');
          }
        }

        window.addEventListener('scroll', handleScroll, { passive: true });
      }

      /**
       * Fade-in 애니메이션 초기화
       */
      function initFadeInAnimation() {
        const fadeElements = document.querySelectorAll('.fade-in');
        if (fadeElements.length === 0) return;

        const observerOptions = {
          threshold: 0.1,
          rootMargin: '0px 0px -50px 0px'
        };

        const observer = new IntersectionObserver((entries) => {
          entries.forEach(entry => {
            if (entry.isIntersecting) {
              entry.target.style.opacity = '1';
              entry.target.style.transform = 'translateY(0)';
              observer.unobserve(entry.target);
            }
          });
        }, observerOptions);

        fadeElements.forEach(el => {
          el.style.opacity = '0';
          el.style.transform = 'translateY(20px)';
          el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
          observer.observe(el);
        });
      }

      /**
       * 초기화 함수
       */
      function init() {
        initNavbarScroll();
        initFadeInAnimation();
      }

      // DOM 로드 완료 시 초기화
      if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
      } else {
        init();
      }
    })();
  </script>
  <jsp:include page="/AI/partials/footer.jsp"/>
</body>
</html>
