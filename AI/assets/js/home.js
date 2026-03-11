/* ============================================================
   AI Workflow Lab — Home Page JS
   IntersectionObserver animations + scroll interactions
   ============================================================ */

(function () {
  'use strict';

  /* ── IntersectionObserver factory ── */
  function observe(selector, options) {
    var els = document.querySelectorAll(selector);
    if (!els.length) return;
    var observer = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          entry.target.classList.add('visible');
          observer.unobserve(entry.target);
        }
      });
    }, Object.assign({ threshold: 0.15, rootMargin: '0px 0px -60px 0px' }, options || {}));
    els.forEach(function (el) { observer.observe(el); });
  }

  /* ── Observe all animated elements ── */
  function initObservers() {
    observe('.fade-up');
    observe('.problem-line', { threshold: 0.3, rootMargin: '0px 0px -80px 0px' });
    observe('.feature-card', { threshold: 0.1 });
    observe('.modality-card', { threshold: 0.1 });
    observe('.cta-title');
    observe('.cta-sub');
    observe('.cta-buttons');
  }

  /* ── Scroll indicator click → scroll to next section ── */
  function initScrollIndicator() {
    var ind = document.querySelector('.scroll-indicator');
    if (!ind) return;
    ind.addEventListener('click', function () {
      var next = document.querySelector('.problem-section');
      if (next) next.scrollIntoView({ behavior: 'smooth' });
    });
  }

  /* ── Navbar scroll state (already in header.jsp but reinforce) ── */
  function initNav() {
    var nav = document.getElementById('siteNav');
    if (!nav) return;
    var handler = function () {
      nav.classList.toggle('scrolled', window.scrollY > 20);
    };
    window.addEventListener('scroll', handler, { passive: true });
    handler();
  }

  /* ── Animated counter on hero stats ── */
  function animateCounter(el, target, duration) {
    var start = 0;
    var step = target / (duration / 16);
    var timer = setInterval(function () {
      start = Math.min(start + step, target);
      el.textContent = Math.floor(start).toLocaleString('ko-KR') + (el.dataset.suffix || '');
      if (start >= target) clearInterval(timer);
    }, 16);
  }

  function initCounters() {
    var stats = document.querySelectorAll('.hero-stat .num[data-target]');
    if (!stats.length) return;
    var observer = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          var el = entry.target;
          animateCounter(el, parseInt(el.dataset.target), 1200);
          observer.unobserve(el);
        }
      });
    }, { threshold: 0.5 });
    stats.forEach(function (el) { observer.observe(el); });
  }

  /* ── Parallax on hero orbs ── */
  function initParallax() {
    var orbs = document.querySelectorAll('.hero-orb');
    if (!orbs.length) return;
    window.addEventListener('scroll', function () {
      var y = window.scrollY;
      orbs[0] && (orbs[0].style.transform = 'translate(' + (y * .03) + 'px,' + (-(y * .05)) + 'px) scale(1)');
      orbs[1] && (orbs[1].style.transform = 'translate(' + (-(y * .04)) + 'px,' + (-(y * .03)) + 'px) scale(1)');
      orbs[2] && (orbs[2].style.transform = 'translateY(' + (-(y * .02)) + 'px)');
    }, { passive: true });
  }

  /* ── Keyboard scroll accessibility ── */
  function initKeyScroll() {
    document.addEventListener('keydown', function (e) {
      if (e.key === 'ArrowDown') {
        e.preventDefault();
        window.scrollBy({ top: window.innerHeight * .9, behavior: 'smooth' });
      }
    });
  }

  /* ── Init ── */
  function init() {
    initNav();
    initObservers();
    initScrollIndicator();
    initCounters();
    initParallax();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }

})();
