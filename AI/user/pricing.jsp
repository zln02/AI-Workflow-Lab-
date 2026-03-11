<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.CreditPackageDAO" %>
<%@ page import="dao.PackageDAO" %>
<%@ page import="model.CreditPackage" %>
<%@ page import="model.Package" %>
<%@ page import="java.util.List" %>
<%@ page import="util.EscapeUtil" %>
<%
  PackageDAO packageDAO = new PackageDAO();
  List<Package> packages = packageDAO.getAllPackages(1, 1000);
  List<CreditPackage> creditPackages = new java.util.ArrayList<>();
  try {
    creditPackages = new CreditPackageDAO().findAllActive();
  } catch (Exception e) {}
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>요금제 - AI Workflow Lab</title>
  <link rel="icon" href="data:,">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
  <link rel="stylesheet" href="/AI/assets/css/dark-theme.css">
  <link rel="stylesheet" href="/AI/assets/css/page.css">
  <style>
    /* ── Hero ── */
    .pricing-hero { text-align: center; padding: 72px 0 56px; }
    .pricing-hero__eyebrow {
      display: inline-flex; align-items: center; gap: 8px;
      padding: 6px 16px; border-radius: 20px; font-size: .8125rem; font-weight: 600;
      background: rgba(59,130,246,.1); border: 1px solid rgba(59,130,246,.25); color: #60a5fa;
      margin-bottom: 20px;
    }
    .pricing-hero h1 {
      font-size: clamp(2rem, 5vw, 3rem); font-weight: 800; letter-spacing: -.03em;
      background: linear-gradient(135deg, #f1f5f9 30%, #94a3b8);
      -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text;
      margin-bottom: 16px;
    }
    .pricing-hero p { font-size: 1.0625rem; color: var(--text-muted, #64748b); max-width: 520px; margin: 0 auto; line-height: 1.75; }

    /* ── Currency toggle ── */
    .currency-toggle {
      display: flex; align-items: center; justify-content: center; gap: 4px;
      background: rgba(255,255,255,.05); border: 1px solid rgba(255,255,255,.1);
      border-radius: 10px; padding: 4px; width: fit-content; margin: 0 auto 52px;
    }
    .currency-toggle button {
      padding: 8px 20px; border-radius: 8px; font-size: .875rem; font-weight: 600;
      border: none; cursor: pointer; transition: background .2s, color .2s;
      background: transparent; color: var(--text-muted, #64748b);
    }
    .currency-toggle button.active,
    .currency-toggle button[data-currency="KRW"] {
      background: rgba(59,130,246,.2); color: #93c5fd;
    }

    /* ── Pricing grid ── */
    .pricing-grid {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 24px;
      align-items: start;
      margin-bottom: 80px;
    }

    /* ── Plan card ── */
    .plan-card {
      background: rgba(255,255,255,.04);
      border: 1px solid rgba(255,255,255,.08);
      border-radius: 20px;
      padding: 32px;
      display: flex; flex-direction: column;
      position: relative;
      transition: border-color .25s, box-shadow .25s;
    }
    .plan-card:hover { border-color: rgba(255,255,255,.15); box-shadow: 0 20px 60px rgba(0,0,0,.3); }

    /* Growth: featured */
    .plan-card--featured {
      background: rgba(59,130,246,.06);
      border-color: rgba(59,130,246,.35);
      box-shadow: 0 0 40px rgba(59,130,246,.12);
    }
    .plan-card--featured:hover { box-shadow: 0 0 60px rgba(59,130,246,.2); }

    /* Popular badge */
    .popular-badge {
      position: absolute; top: -13px; left: 50%; transform: translateX(-50%);
      display: inline-flex; align-items: center; gap: 5px;
      padding: 5px 16px; border-radius: 20px; font-size: .75rem; font-weight: 700;
      background: linear-gradient(135deg, #3b82f6, #8b5cf6); color: #fff;
      white-space: nowrap; box-shadow: 0 4px 16px rgba(59,130,246,.4);
    }

    /* Plan name */
    .plan-name { font-size: 1.25rem; font-weight: 700; margin-bottom: 6px; }
    .plan-period { font-size: .875rem; color: var(--text-muted, #64748b); margin-bottom: 28px; }

    /* Price */
    .plan-price-block { margin-bottom: 28px; }
    .plan-price { font-size: 2.5rem; font-weight: 800; letter-spacing: -.03em; line-height: 1; }
    .plan-price sub { font-size: 1rem; font-weight: 600; vertical-align: baseline; }
    .plan-price-usd { font-size: .875rem; color: var(--text-muted, #64748b); margin-top: 4px; }

    /* Divider */
    .plan-divider { border: none; border-top: 1px solid rgba(255,255,255,.07); margin: 0 0 24px; }

    /* Feature list */
    .plan-features { list-style: none; padding: 0; margin: 0 0 32px; flex: 1; display: flex; flex-direction: column; gap: 12px; }
    .plan-features li { display: flex; align-items: flex-start; gap: 10px; font-size: .875rem; color: var(--text-secondary, #94a3b8); }
    .plan-features li .fi { flex-shrink: 0; margin-top: 1px; }
    .fi-check { color: #34d399; }
    .fi-cross { color: #f87171; }

    /* Subscribe button */
    .btn-subscribe {
      width: 100%; padding: 13px; border-radius: 12px; font-size: .9375rem; font-weight: 700;
      cursor: pointer; transition: opacity .2s, transform .15s; border: none;
    }
    .btn-subscribe--default {
      background: rgba(255,255,255,.07); border: 1px solid rgba(255,255,255,.12); color: var(--text-primary, #f1f5f9);
    }
    .btn-subscribe--default:hover { background: rgba(255,255,255,.11); transform: translateY(-1px); }
    .btn-subscribe--featured {
      background: linear-gradient(135deg, #3b82f6, #8b5cf6); color: #fff;
      box-shadow: 0 4px 20px rgba(59,130,246,.35);
    }
    .btn-subscribe--featured:hover { opacity: .9; transform: translateY(-2px); box-shadow: 0 8px 28px rgba(59,130,246,.45); }

    /* ── Package section ── */
    .section-heading { text-align: center; margin-bottom: 40px; }
    .section-heading h2 { font-size: 1.75rem; font-weight: 700; letter-spacing: -.02em; margin-bottom: 10px; }
    .section-heading p { font-size: .9375rem; color: var(--text-muted, #64748b); }

    .pkg-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
      gap: 20px;
      margin-bottom: 80px;
    }
    .pkg-card {
      background: rgba(255,255,255,.04); border: 1px solid rgba(255,255,255,.08);
      border-radius: 16px; padding: 24px; display: flex; flex-direction: column;
      transition: border-color .25s, box-shadow .25s;
    }
    .pkg-card:hover { border-color: rgba(255,255,255,.14); box-shadow: 0 12px 40px rgba(0,0,0,.25); }
    .pkg-card__title { font-size: 1.0625rem; font-weight: 700; margin-bottom: 10px; }
    .pkg-card__desc { font-size: .8125rem; color: var(--text-muted, #64748b); line-height: 1.7; flex: 1; margin-bottom: 20px; }
    .pkg-card__price-orig { font-size: .8125rem; color: var(--text-muted, #64748b); text-decoration: line-through; margin-bottom: 4px; }
    .pkg-card__price { font-size: 1.75rem; font-weight: 700; color: #f87171; margin-bottom: 2px; }
    .pkg-card__price--reg { color: var(--text-primary, #f1f5f9); }
    .pkg-card__price-usd { font-size: .8125rem; color: var(--text-muted, #64748b); margin-bottom: 20px; }
    .btn-pkg-detail {
      display: block; text-align: center; padding: 10px; border-radius: 10px; font-size: .875rem; font-weight: 600;
      background: rgba(59,130,246,.12); border: 1px solid rgba(59,130,246,.25); color: #60a5fa;
      text-decoration: none; transition: background .2s;
    }
    .btn-pkg-detail:hover { background: rgba(59,130,246,.22); color: #93c5fd; }

    /* ── Responsive ── */
    @media (max-width: 900px) {
      .pricing-grid { grid-template-columns: 1fr; max-width: 420px; margin-left: auto; margin-right: auto; }
    }
    @media (max-width: 600px) {
      .pricing-hero { padding: 48px 0 40px; }
    }
  </style>
</head>
<body>
<%@ include file="/AI/partials/header.jsp" %>

<div style="max-width: 1100px; margin: 0 auto; padding: 0 24px;">

  <!-- Hero -->
  <div class="pricing-hero">
    <div class="pricing-hero__eyebrow"><i class="bi bi-credit-card-2-front"></i>요금제</div>
    <h1>개인부터 기업까지,<br>딱 맞는 플랜</h1>
    <p>모든 플랜에는 AI 모델 마켓플레이스 및 API 통합이 포함됩니다.</p>
  </div>

  <!-- Currency toggle -->
  <div class="currency-toggle">
    <button type="button" data-currency="KRW" class="active" aria-label="KRW로 전환">KRW</button>
    <button type="button" data-currency="USD" aria-label="USD로 전환">USD</button>
  </div>

  <!-- Pricing cards -->
  <div class="pricing-grid">

    <!-- Starter -->
    <div class="plan-card">
      <div class="plan-name">Starter</div>
      <div class="plan-period">1개월 무제한</div>
      <div class="plan-price-block">
        <div class="plan-price price-display" data-price-usd="9.99"><sub>₩</sub>13,487</div>
        <div class="plan-price-usd">($9.99 / mo)</div>
      </div>
      <hr class="plan-divider">
      <ul class="plan-features">
        <li><i class="bi bi-check-circle-fill fi fi-check"></i><span>모든 패키지 무제한</span></li>
        <li><i class="bi bi-check-circle-fill fi fi-check"></i><span>우선 지원</span></li>
        <li><i class="bi bi-x-circle-fill fi fi-cross"></i><span>API 우선 접근</span></li>
        <li><i class="bi bi-x-circle-fill fi fi-cross"></i><span>맞춤 통합</span></li>
      </ul>
      <button class="btn-subscribe btn-subscribe--default" data-plan="STARTER">구독하기</button>
    </div>

    <!-- Growth (featured) -->
    <div class="plan-card plan-card--featured">
      <div class="popular-badge"><i class="bi bi-star-fill"></i>가장 인기</div>
      <div class="plan-name" style="color:#93c5fd;">Growth</div>
      <div class="plan-period">6개월 무제한</div>
      <div class="plan-price-block">
        <div class="plan-price price-display" data-price-usd="49.99" style="color:#60a5fa;"><sub>₩</sub>67,487</div>
        <div class="plan-price-usd">($49.99 / 6mo)</div>
      </div>
      <hr class="plan-divider">
      <ul class="plan-features">
        <li><i class="bi bi-check-circle-fill fi fi-check"></i><span>모든 AI 도구 무제한</span></li>
        <li><i class="bi bi-check-circle-fill fi fi-check"></i><span>모든 패키지 무제한</span></li>
        <li><i class="bi bi-check-circle-fill fi fi-check"></i><span>우선 지원</span></li>
        <li><i class="bi bi-check-circle-fill fi fi-check"></i><span>API 우선 접근</span></li>
        <li><i class="bi bi-x-circle-fill fi fi-cross"></i><span>맞춤 통합</span></li>
      </ul>
      <button class="btn-subscribe btn-subscribe--featured" data-plan="GROWTH">구독하기</button>
    </div>

    <!-- Enterprise -->
    <div class="plan-card">
      <div class="plan-name">Enterprise</div>
      <div class="plan-period">1년 무제한</div>
      <div class="plan-price-block">
        <div class="plan-price price-display" data-price-usd="99.99"><sub>₩</sub>134,987</div>
        <div class="plan-price-usd">($99.99 / yr)</div>
      </div>
      <hr class="plan-divider">
      <ul class="plan-features">
        <li><i class="bi bi-check-circle-fill fi fi-check"></i><span>모든 AI 도구 무제한</span></li>
        <li><i class="bi bi-check-circle-fill fi fi-check"></i><span>모든 패키지 무제한</span></li>
        <li><i class="bi bi-check-circle-fill fi fi-check"></i><span>전담 지원</span></li>
        <li><i class="bi bi-check-circle-fill fi fi-check"></i><span>API 우선 접근</span></li>
        <li><i class="bi bi-check-circle-fill fi fi-check"></i><span>맞춤 통합</span></li>
      </ul>
      <button class="btn-subscribe btn-subscribe--default" data-plan="ENTERPRISE">구독하기</button>
    </div>

  </div><!-- /pricing-grid -->

  <!-- Package pricing -->
  <% if (!packages.isEmpty()) { %>
  <div class="section-heading">
    <h2>패키지 요금제</h2>
    <p>특별 가격의 사전 구성된 번들</p>
  </div>
  <div class="pkg-grid">
    <% for (Package pkg : packages) {
       double priceUsd = pkg.getPrice() != null ? pkg.getPrice().doubleValue() : 0;
       long priceKrw = Math.round(priceUsd * 1350);
       double discountUsd = pkg.getDiscountPrice() != null && pkg.getDiscountPrice().compareTo(java.math.BigDecimal.ZERO) > 0
           ? pkg.getDiscountPrice().doubleValue() : 0;
       long discountKrw = Math.round(discountUsd * 1350);
       String pkgTitle = pkg.getTitle() != null ? pkg.getTitle() : "Package";
       String pkgDesc  = pkg.getDescription() != null
           ? (pkg.getDescription().length() > 150 ? pkg.getDescription().substring(0, 150) + "…" : pkg.getDescription())
           : "설명 없음";
    %>
    <div class="pkg-card">
      <div class="pkg-card__title"><%= EscapeUtil.escapeHtml(pkgTitle) %></div>
      <div class="pkg-card__desc"><%= EscapeUtil.escapeHtml(pkgDesc) %></div>
      <% if (discountUsd > 0) { %>
        <div class="pkg-card__price-orig"><%= String.format("%,d", priceKrw) %>원 ($<%= String.format("%.0f", priceUsd) %>/월)</div>
        <div class="pkg-card__price"><%= String.format("%,d", discountKrw) %>원</div>
        <div class="pkg-card__price-usd">($<%= String.format("%.0f", discountUsd) %>/월)</div>
      <% } else { %>
        <div class="pkg-card__price pkg-card__price--reg"><%= String.format("%,d", priceKrw) %>원</div>
        <div class="pkg-card__price-usd">($<%= String.format("%.0f", priceUsd) %>/월)</div>
      <% } %>
      <a href="/AI/user/package.jsp?id=<%= pkg.getId() %>" class="btn-pkg-detail">상세보기</a>
    </div>
    <% } %>
  </div>
  <% } %>

  <% if (!creditPackages.isEmpty()) { %>
  <div class="section-heading">
    <h2>추가 크레딧 구매</h2>
    <p>실습과 Playground에서 바로 사용할 수 있는 크레딧 팩</p>
  </div>
  <div class="pkg-grid">
    <% for (CreditPackage creditPackage : creditPackages) { %>
    <div class="pkg-card">
      <div class="pkg-card__title"><%= EscapeUtil.escapeHtml(creditPackage.getPackageName()) %> 크레딧 팩</div>
      <div class="pkg-card__desc">
        기본 <%= creditPackage.getCredits() %> 크레딧
        <% if (creditPackage.getBonusCredits() > 0) { %>
          + 보너스 <%= creditPackage.getBonusCredits() %> 크레딧
        <% } %>
      </div>
      <div class="pkg-card__price pkg-card__price--reg"><%= String.format("%,d", creditPackage.getPrice().intValue()) %>원</div>
      <div class="pkg-card__price-usd">총 <%= creditPackage.getCredits() + creditPackage.getBonusCredits() %> 크레딧</div>
      <a href="/AI/user/checkout.jsp?packageId=<%= creditPackage.getId() %>" class="btn-pkg-detail">구매하기</a>
    </div>
    <% } %>
  </div>
  <% } %>

</div><!-- /wrapper -->

<script src="/AI/assets/js/user.js"></script>
<script type="module">
  import { toast } from '/AI/assets/js/toast.js';

  document.querySelectorAll('[data-plan]').forEach(btn => {
    btn.addEventListener('click', () => {
      const planCode = btn.dataset.plan;
      if (!planCode) return;
      // 결제 페이지로 이동
      window.location.href = '/AI/user/checkout.jsp?plan=' + encodeURIComponent(planCode);
    });
  });
</script>
<jsp:include page="/AI/partials/footer.jsp"/>
</body>
</html>
