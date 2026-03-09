<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="model.User" %>
<%
  request.setCharacterEncoding("UTF-8");
  Object _hUserObj = session.getAttribute("user");
  User _hUser = (_hUserObj instanceof User) ? (User) _hUserObj : null;
  boolean _hLoggedIn = _hUser != null && _hUser.isActive();

  String _uri = request.getRequestURI();
  boolean _isHome    = _uri.equals("/AI/user/home.jsp") || _uri.equals("/AI/") || _uri.equals("/");
  boolean _isTools   = _uri.contains("/tools/");
  boolean _isLab     = _uri.contains("/lab/");
  boolean _isPricing = _uri.contains("/pricing") || _uri.contains("/package");
  boolean _isMypage  = _uri.contains("/mypage");
%>
<!-- ======================================================
     Header / Navigation
     ====================================================== -->
<nav class="site-nav" id="siteNav">
  <div class="site-nav__inner">

    <!-- Logo -->
    <a href="/AI/user/home.jsp" class="site-nav__logo">
      <span class="site-nav__logo-icon">🤖</span>
      <span class="site-nav__logo-text">AI Workflow Lab</span>
    </a>

    <!-- Desktop menu -->
    <ul class="site-nav__menu" id="desktopMenu">
      <li>
        <a href="/AI/user/home.jsp" class="site-nav__link<%= _isHome ? " site-nav__link--active" : "" %>">
          홈
        </a>
      </li>
      <li>
        <a href="/AI/user/tools/navigator.jsp" class="site-nav__link<%= _isTools ? " site-nav__link--active" : "" %>">
          AI 도구 탐색
        </a>
      </li>
      <li>
        <a href="/AI/user/lab/index.jsp" class="site-nav__link<%= _isLab ? " site-nav__link--active" : "" %>">
          실습 랩
        </a>
      </li>
      <li>
        <a href="/AI/user/pricing.jsp" class="site-nav__link<%= _isPricing ? " site-nav__link--active" : "" %>">
          요금제
        </a>
      </li>
    </ul>

    <!-- Desktop auth -->
    <div class="site-nav__auth">
      <% if (_hLoggedIn) { %>
        <a href="/AI/user/mypage.jsp" class="site-nav__link<%= _isMypage ? " site-nav__link--active" : "" %>"
           title="마이페이지">
          <i class="bi bi-person-circle"></i>
          <%= util.EscapeUtil.escapeHtml(_hUser.getDisplayName()) %>
        </a>
        <a href="/AI/user/logout.jsp" class="site-nav__btn site-nav__btn--outline">로그아웃</a>
      <% } else { %>
        <a href="/AI/user/login.jsp"  class="site-nav__btn site-nav__btn--outline">로그인</a>
        <a href="/AI/user/signup.jsp" class="site-nav__btn site-nav__btn--filled">시작하기</a>
      <% } %>
    </div>

    <!-- Mobile: hamburger -->
    <button class="site-nav__hamburger" id="navHamburger"
            data-bs-toggle="offcanvas" data-bs-target="#mobileNav"
            aria-label="메뉴 열기">
      <span></span><span></span><span></span>
    </button>

  </div><!-- /.site-nav__inner -->
</nav>

<!-- Mobile Offcanvas -->
<div class="offcanvas offcanvas-end mobile-nav" tabindex="-1" id="mobileNav">
  <div class="offcanvas-header mobile-nav__header">
    <a href="/AI/user/home.jsp" class="site-nav__logo">
      <span class="site-nav__logo-icon">🤖</span>
      <span class="site-nav__logo-text">AI Workflow Lab</span>
    </a>
    <button type="button" class="mobile-nav__close" data-bs-dismiss="offcanvas" aria-label="닫기">
      <i class="bi bi-x-lg"></i>
    </button>
  </div>
  <div class="offcanvas-body mobile-nav__body">
    <ul class="mobile-nav__menu">
      <li>
        <a href="/AI/user/home.jsp" class="mobile-nav__link<%= _isHome ? " mobile-nav__link--active" : "" %>">
          <i class="bi bi-house"></i> 홈
        </a>
      </li>
      <li>
        <a href="/AI/user/tools/navigator.jsp" class="mobile-nav__link<%= _isTools ? " mobile-nav__link--active" : "" %>">
          <i class="bi bi-compass"></i> AI 도구 탐색
        </a>
      </li>
      <li>
        <a href="/AI/user/lab/index.jsp" class="mobile-nav__link<%= _isLab ? " mobile-nav__link--active" : "" %>">
          <i class="bi bi-flask"></i> 실습 랩
        </a>
      </li>
      <li>
        <a href="/AI/user/pricing.jsp" class="mobile-nav__link<%= _isPricing ? " mobile-nav__link--active" : "" %>">
          <i class="bi bi-tag"></i> 요금제
        </a>
      </li>
    </ul>

    <div class="mobile-nav__divider"></div>

    <div class="mobile-nav__auth">
      <% if (_hLoggedIn) { %>
        <a href="/AI/user/mypage.jsp" class="mobile-nav__link<%= _isMypage ? " mobile-nav__link--active" : "" %>">
          <i class="bi bi-person-circle"></i>
          <%= util.EscapeUtil.escapeHtml(_hUser.getDisplayName()) %>
        </a>
        <a href="/AI/user/logout.jsp" class="site-nav__btn site-nav__btn--outline" style="width:100%;justify-content:center;margin-top:8px;">
          로그아웃
        </a>
      <% } else { %>
        <a href="/AI/user/login.jsp"  class="site-nav__btn site-nav__btn--outline" style="width:100%;justify-content:center;margin-bottom:8px;">
          로그인
        </a>
        <a href="/AI/user/signup.jsp" class="site-nav__btn site-nav__btn--filled"  style="width:100%;justify-content:center;">
          시작하기
        </a>
      <% } %>
    </div>
  </div>
</div>

<style>
/* ===== Site Nav ===== */
.site-nav {
  position: fixed;
  top: 0; left: 0; right: 0;
  z-index: 1030;
  height: 60px;
  display: flex;
  align-items: center;
  background: rgba(10, 15, 30, 0.55);
  backdrop-filter: blur(16px) saturate(180%);
  -webkit-backdrop-filter: blur(16px) saturate(180%);
  border-bottom: 1px solid rgba(255,255,255,0.07);
  transition: background 0.35s ease, box-shadow 0.35s ease, border-color 0.35s ease;
}

.site-nav.scrolled {
  background: rgba(10, 15, 30, 0.92);
  border-bottom-color: rgba(255,255,255,0.12);
  box-shadow: 0 4px 32px rgba(0,0,0,0.45);
}

.site-nav__inner {
  max-width: 1280px;
  margin: 0 auto;
  padding: 0 24px;
  width: 100%;
  display: flex;
  align-items: center;
  gap: 0;
}

/* Logo */
.site-nav__logo {
  display: flex;
  align-items: center;
  gap: 8px;
  text-decoration: none;
  flex-shrink: 0;
  margin-right: 32px;
}

.site-nav__logo-icon { font-size: 1.2rem; line-height: 1; }

.site-nav__logo-text {
  font-size: 0.9375rem;
  font-weight: 700;
  letter-spacing: -0.02em;
  background: linear-gradient(135deg, #3b82f6, #8b5cf6);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  white-space: nowrap;
}

/* Desktop menu */
.site-nav__menu {
  display: flex;
  list-style: none;
  margin: 0; padding: 0;
  gap: 2px;
  flex: 1;
}

.site-nav__link {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  padding: 6px 12px;
  border-radius: 8px;
  font-size: 0.875rem;
  font-weight: 500;
  color: rgba(241,245,249,0.65);
  text-decoration: none;
  transition: color 0.2s, background 0.2s;
  white-space: nowrap;
  -webkit-text-fill-color: rgba(241,245,249,0.65);
}

.site-nav__link:hover {
  color: #f1f5f9;
  -webkit-text-fill-color: #f1f5f9;
  background: rgba(255,255,255,0.07);
}

.site-nav__link--active {
  color: #60a5fa !important;
  -webkit-text-fill-color: #60a5fa !important;
  background: rgba(59,130,246,0.12) !important;
}

/* Auth area */
.site-nav__auth {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-left: auto;
  flex-shrink: 0;
}

/* Auth buttons */
.site-nav__btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  padding: 7px 16px;
  border-radius: 8px;
  font-size: 0.8125rem;
  font-weight: 500;
  text-decoration: none;
  white-space: nowrap;
  transition: all 0.2s ease;
  cursor: pointer;
  border: none;
}

.site-nav__btn--outline {
  background: transparent;
  color: rgba(241,245,249,0.75);
  border: 1px solid rgba(255,255,255,0.18);
  -webkit-text-fill-color: rgba(241,245,249,0.75);
}

.site-nav__btn--outline:hover {
  background: rgba(255,255,255,0.08);
  color: #f1f5f9;
  -webkit-text-fill-color: #f1f5f9;
  border-color: rgba(255,255,255,0.28);
}

.site-nav__btn--filled {
  background: linear-gradient(135deg, #3b82f6, #8b5cf6);
  color: #fff;
  -webkit-text-fill-color: #fff;
  border: 1px solid transparent;
  box-shadow: 0 2px 8px rgba(59,130,246,0.35);
}

.site-nav__btn--filled:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 16px rgba(59,130,246,0.55);
  color: #fff;
  -webkit-text-fill-color: #fff;
}

/* Hamburger */
.site-nav__hamburger {
  display: none;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  gap: 5px;
  width: 40px; height: 40px;
  padding: 0;
  background: rgba(255,255,255,0.06);
  border: 1px solid rgba(255,255,255,0.1);
  border-radius: 8px;
  cursor: pointer;
  margin-left: auto;
  transition: background 0.2s;
}

.site-nav__hamburger:hover { background: rgba(255,255,255,0.1); }

.site-nav__hamburger span {
  display: block;
  width: 18px; height: 2px;
  background: #f1f5f9;
  border-radius: 2px;
  transition: all 0.25s ease;
}

/* ===== Mobile Offcanvas ===== */
.mobile-nav {
  width: 300px !important;
  background: rgba(10, 15, 30, 0.97) !important;
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border-left: 1px solid rgba(255,255,255,0.1) !important;
}

.mobile-nav__header {
  padding: 20px 20px 16px;
  border-bottom: 1px solid rgba(255,255,255,0.08);
}

.mobile-nav__close {
  background: rgba(255,255,255,0.06);
  border: 1px solid rgba(255,255,255,0.1);
  border-radius: 8px;
  color: #94a3b8;
  width: 36px; height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  font-size: 1rem;
  transition: all 0.2s;
  flex-shrink: 0;
}

.mobile-nav__close:hover { background: rgba(255,255,255,0.1); color: #f1f5f9; }

.mobile-nav__body { padding: 16px 16px 24px; }

.mobile-nav__menu {
  list-style: none;
  margin: 0; padding: 0;
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.mobile-nav__link {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 11px 14px;
  border-radius: 10px;
  font-size: 0.9375rem;
  font-weight: 500;
  color: rgba(241,245,249,0.7);
  text-decoration: none;
  transition: all 0.2s;
  -webkit-text-fill-color: rgba(241,245,249,0.7);
}

.mobile-nav__link:hover {
  background: rgba(255,255,255,0.07);
  color: #f1f5f9;
  -webkit-text-fill-color: #f1f5f9;
}

.mobile-nav__link--active {
  background: rgba(59,130,246,0.14) !important;
  color: #60a5fa !important;
  -webkit-text-fill-color: #60a5fa !important;
}

.mobile-nav__link i { font-size: 1rem; width: 20px; text-align: center; flex-shrink: 0; }

.mobile-nav__divider {
  height: 1px;
  background: rgba(255,255,255,0.07);
  margin: 12px 0;
}

.mobile-nav__auth {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

/* Bootstrap offcanvas backdrop override */
.offcanvas-backdrop { background: rgba(0,0,0,0.6) !important; backdrop-filter: blur(4px); }

/* ===== Responsive ===== */
@media (max-width: 768px) {
  .site-nav__menu,
  .site-nav__auth { display: none; }
  .site-nav__hamburger { display: flex; }
  .site-nav__logo { margin-right: 0; }
}

@media (min-width: 769px) {
  .site-nav__hamburger { display: none; }
}
</style>

<script>
(function () {
  var nav = document.getElementById('siteNav');
  if (!nav) return;

  /* Scroll: opacity increase */
  var onScroll = function () {
    if (window.scrollY > 20) {
      nav.classList.add('scrolled');
    } else {
      nav.classList.remove('scrolled');
    }
  };

  window.addEventListener('scroll', onScroll, { passive: true });
  onScroll();

  /* Fallback toggle (when Bootstrap JS not yet loaded) */
  var hamburger = document.getElementById('navHamburger');
  if (hamburger && typeof bootstrap === 'undefined') {
    hamburger.addEventListener('click', function () {
      var target = document.getElementById('mobileNav');
      if (!target) return;
      target.style.cssText = 'position:fixed;top:0;right:0;bottom:0;z-index:1050;display:flex;flex-direction:column;visibility:visible;transform:none;';
    });
  }
})();
</script>
