<%@ page contentType="text/html; charset=UTF-8" %>
<!-- ======================================================
     Footer
     ====================================================== -->
<footer class="site-footer">
  <div class="site-footer__inner">

    <div class="site-footer__grid">

      <!-- Left: Brand -->
      <div class="site-footer__brand">
        <a href="/AI/user/home.jsp" class="site-footer__logo">
          <i class="bi bi-hexagon-fill" style="font-size:1.1rem;background:linear-gradient(135deg,#3b82f6,#8b5cf6);-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;"></i>
          <span class="site-footer__logo-text">AI Workflow Lab</span>
        </a>
        <p class="site-footer__desc">
          AI 도구 탐색부터 실전 프로젝트까지,<br>AI 실무 역량을 키우는 가장 빠른 플랫폼.
        </p>
      </div>

      <!-- Center: Quick Links -->
      <div class="site-footer__col">
        <p class="site-footer__col-title">빠른 링크</p>
        <ul class="site-footer__links">
          <li><a href="/AI/user/home.jsp">홈</a></li>
          <li><a href="/AI/user/tools/navigator.jsp">AI 도구 탐색</a></li>
          <li><a href="/AI/user/lab/index.jsp">실습 랩</a></li>
          <li><a href="/AI/user/pricing.jsp">요금제</a></li>
        </ul>
      </div>

      <!-- Right: GitHub -->
      <div class="site-footer__col">
        <p class="site-footer__col-title">프로젝트</p>
        <ul class="site-footer__links">
          <li>
            <a href="https://github.com/zln02/AI-Workflow-Lab-" target="_blank" rel="noopener noreferrer">
              <i class="bi bi-github"></i> GitHub
            </a>
          </li>
        </ul>
      </div>

    </div><!-- /.site-footer__grid -->

    <div class="site-footer__bottom">
      <p>&copy; 2026 AI Workflow Lab. 포트폴리오 프로젝트. | 박진영</p>
    </div>

  </div><!-- /.site-footer__inner -->
</footer>

<!-- Bootstrap bundle (enables Offcanvas from header) -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-YvpcrYf0tY3lHB60NNkmXc4s9bIOgUxi8T/jzmFhFRUNpDwz19m1WgfU0f0BeLe"
        crossorigin="anonymous"></script>

<style>
/* ===== Site Footer ===== */
.site-footer {
  background: var(--bg-secondary, #111827);
  border-top: 1px solid var(--glass-border, rgba(255,255,255,0.10));
  margin-top: 80px;
  padding: 56px 0 28px;
}

.site-footer__inner {
  max-width: 1280px;
  margin: 0 auto;
  padding: 0 24px;
}

.site-footer__grid {
  display: grid;
  grid-template-columns: 2fr 1fr 1fr;
  gap: 48px;
  margin-bottom: 40px;
}

/* Brand */
.site-footer__logo {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  text-decoration: none;
  margin-bottom: 14px;
}


.site-footer__logo-text {
  font-size: 0.9375rem;
  font-weight: 700;
  letter-spacing: -0.02em;
  background: linear-gradient(135deg, #3b82f6, #8b5cf6);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.site-footer__desc {
  font-size: 0.875rem;
  color: var(--text-muted, #64748b);
  line-height: 1.75;
  margin: 0;
}

/* Columns */
.site-footer__col-title {
  font-size: 0.75rem;
  font-weight: 600;
  color: var(--text-secondary, #94a3b8);
  text-transform: uppercase;
  letter-spacing: 0.08em;
  margin: 0 0 16px;
}

.site-footer__links {
  list-style: none;
  padding: 0;
  margin: 0;
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.site-footer__links a {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  font-size: 0.875rem;
  color: var(--text-muted, #64748b);
  text-decoration: none;
  transition: color 0.2s;
}

.site-footer__links a:hover {
  color: var(--text-primary, #f1f5f9);
}

/* Bottom bar */
.site-footer__bottom {
  border-top: 1px solid var(--glass-border, rgba(255,255,255,0.07));
  padding-top: 24px;
  text-align: center;
}

.site-footer__bottom p {
  margin: 0;
  font-size: 0.8125rem;
  color: var(--text-muted, #64748b);
}

/* Responsive */
@media (max-width: 768px) {
  .site-footer__grid {
    grid-template-columns: 1fr 1fr;
    gap: 32px;
  }

  .site-footer__brand {
    grid-column: 1 / -1;
  }

  .site-footer { margin-top: 48px; padding: 40px 0 24px; }
}

@media (max-width: 480px) {
  .site-footer__grid {
    grid-template-columns: 1fr;
    gap: 24px;
  }
}
</style>
