<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="model.User" %>
<%@ page import="model.Order" %>
<%@ page import="dao.OrderDAO" %>
<%@ page import="util.EscapeUtil" %>
<%
  request.setCharacterEncoding("UTF-8");

  User user = (User) session.getAttribute("user");

  String orderIdStr = request.getParameter("orderId");
  String planCode = request.getParameter("plan");
  if (planCode == null) planCode = "";

  Order order = null;
  if (orderIdStr != null && orderIdStr.matches("\\d+")) {
    try {
      OrderDAO orderDAO = new OrderDAO();
      order = orderDAO.findById(Integer.parseInt(orderIdStr));
    } catch (Exception e) { e.printStackTrace(); }
  }

  String planName = "STARTER".equals(planCode) ? "스타터" :
                    "ENTERPRISE".equals(planCode) ? "엔터프라이즈" : "그로스";
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>결제 완료 - AI Workflow Lab</title>
  <link rel="icon" href="data:,">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
  <link rel="stylesheet" href="/AI/assets/css/dark-theme.css">
  <link rel="stylesheet" href="/AI/assets/css/page.css">
  <style>
    main { max-width: 600px; margin: 0 auto; padding: 80px 20px; text-align: center; }
    h1 { font-size: 2rem; font-weight: 800; letter-spacing: -.03em; margin-bottom: 12px; }
    .sub { color: var(--text-muted, #64748b); font-size: .9375rem; margin-bottom: 40px; line-height: 1.6; }
    .order-card {
      background: rgba(255,255,255,.04); border: 1px solid rgba(255,255,255,.09);
      border-radius: 20px; padding: 28px; text-align: left; margin-bottom: 32px;
    }
    .order-card h3 { font-size: 1rem; font-weight: 700; margin-bottom: 20px; color: var(--text-secondary, #94a3b8); }
    .order-row { display: flex; justify-content: space-between; align-items: center; padding: 10px 0; border-bottom: 1px solid rgba(255,255,255,.06); font-size: .875rem; }
    .order-row:last-child { border-bottom: none; }
    .order-row span:first-child { color: var(--text-muted, #64748b); }
    .order-row span:last-child { font-weight: 600; }
    .plan-pill { display: inline-flex; align-items: center; gap: 6px; padding: 3px 12px; border-radius: 20px; font-size: .75rem; font-weight: 700; background: rgba(59,130,246,.2); color: #93c5fd; }
    .btn-primary-grad {
      display: inline-flex; align-items: center; gap: 8px;
      padding: 14px 32px; border-radius: 12px; font-size: .9375rem; font-weight: 700;
      background: linear-gradient(135deg, #3b82f6, #8b5cf6); color: #fff; text-decoration: none;
      box-shadow: 0 4px 20px rgba(59,130,246,.35); transition: opacity .2s, transform .15s;
    }
    .btn-primary-grad:hover { opacity: .9; transform: translateY(-1px); color: #fff; }
    .btn-outline-sm {
      display: inline-flex; align-items: center; gap: 6px;
      padding: 10px 24px; border-radius: 10px; font-size: .875rem; font-weight: 600;
      background: transparent; color: var(--text-secondary, #94a3b8); text-decoration: none;
      border: 1px solid rgba(255,255,255,.15); transition: all .2s;
    }
    .btn-outline-sm:hover { border-color: rgba(255,255,255,.3); color: var(--text-primary); }
    .actions { display: flex; gap: 12px; justify-content: center; flex-wrap: wrap; }
  </style>
</head>
<body>
<%@ include file="/AI/partials/header.jsp" %>
<main>
  <div style="margin-bottom:32px;">
    <i class="bi bi-check-circle-fill" style="font-size:4rem;color:#10b981;display:block;text-align:center;"></i>
  </div>
  <h1>결제가 완료되었습니다!</h1>
  <p class="sub">
    <%= EscapeUtil.escapeHtml(planName) %> 플랜 구독이 성공적으로 시작되었습니다.<br>
    지금 바로 AI Workflow Lab의 모든 기능을 이용하세요.
  </p>

  <% if (order != null) { %>
  <div class="order-card">
    <h3><i class="bi bi-receipt me-2"></i>주문 정보</h3>
    <div class="order-row">
      <span>주문 번호</span><span>#<%= order.getId() %></span>
    </div>
    <div class="order-row">
      <span>구독 플랜</span>
      <span><span class="plan-pill"><i class="bi bi-star-fill"></i> <%= EscapeUtil.escapeHtml(planCode) %></span></span>
    </div>
    <div class="order-row">
      <span>고객명</span><span><%= EscapeUtil.escapeHtml(order.getCustomerName()) %></span>
    </div>
    <div class="order-row">
      <span>이메일</span><span><%= EscapeUtil.escapeHtml(order.getCustomerEmail()) %></span>
    </div>
    <div class="order-row">
      <span>결제 수단</span>
      <span>
        <% String pm = order.getPaymentMethod();
           if ("kakao".equals(pm)) { out.print("카카오페이");
           } else if ("naver".equals(pm)) { out.print("네이버페이");
           } else { %><i class="bi bi-credit-card me-1"></i>신용/체크카드<% } %>
      </span>
    </div>
    <div class="order-row">
      <span>결제 금액</span>
      <span style="color:#34d399; font-size:1.1rem;">
        &#8361;<%= String.format("%,.0f", order.getTotalPrice().doubleValue()) %>
      </span>
    </div>
    <div class="order-row">
      <span>결제 상태</span>
      <span style="color:#34d399;"><i class="bi bi-check-circle-fill me-1"></i>완료</span>
    </div>
  </div>
  <% } %>

  <div class="actions">
    <a href="/AI/user/home.jsp" class="btn-primary-grad">
      <i class="bi bi-house-fill"></i>홈으로 가기
    </a>
    <a href="/AI/user/mypage.jsp" class="btn-outline-sm">
      <i class="bi bi-person"></i>마이페이지
    </a>
  </div>
</main>
<jsp:include page="/AI/partials/footer.jsp"/>
<script src="/AI/assets/js/user.js"></script>
</body>
</html>
