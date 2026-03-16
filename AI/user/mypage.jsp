<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="model.User" %>
<%@ page import="model.Subscription" %>
<%@ page import="model.Plan" %>
<%@ page import="model.Order" %>
<%@ page import="dao.SubscriptionDAO" %>
<%@ page import="dao.PlanDAO" %>
<%@ page import="dao.OrderDAO" %>
<%@ page import="dao.PackageDAO" %>
<%@ page import="dao.AIModelDAO" %>
<%@ page import="dao.CreditDAO" %>
<%@ page import="dao.LabSessionDAO" %>
<%@ page import="dao.AgentRunDAO" %>
<%@ page import="service.UserService" %>
<%@ page import="util.CSRFUtil" %>
<%@ page import="util.EscapeUtil" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="model.LabSession" %>
<%@ page import="model.AgentRun" %>
<%
  request.setCharacterEncoding("UTF-8");
  response.setCharacterEncoding("UTF-8");

  // 로그인 확인
  User user = (User) session.getAttribute("user");
  if (user == null || !user.isActive()) {
    response.sendRedirect("/AI/user/login.jsp?redirect=" +
                         java.net.URLEncoder.encode(request.getRequestURI(), "UTF-8"));
    return;
  }

  // 구독 정보 조회
  SubscriptionDAO subscriptionDAO = new SubscriptionDAO();
  Subscription subscription = subscriptionDAO.findActiveByUserId(user.getId());
  Plan plan = null;
  if (subscription != null) {
    PlanDAO planDAO = new PlanDAO();
    plan = planDAO.findByCode(subscription.getPlanCode());
  }

  // 주문 내역 조회
  OrderDAO orderDAO = new OrderDAO();
  List<Order> orders = new java.util.ArrayList<>();
  List<Map<String, Object>> ordersWithItems = new java.util.ArrayList<>();
  if (user.getEmail() != null && !user.getEmail().trim().isEmpty()) {
    try {
      orders = orderDAO.findByEmail(user.getEmail());
      PackageDAO packageDAO = new PackageDAO();
      AIModelDAO modelDAO = new AIModelDAO();

      for (Order order : orders) {
        Map<String, Object> orderMap = new HashMap<>();
        orderMap.put("id", order.getId());
        orderMap.put("customerName", order.getCustomerName());
        orderMap.put("customerEmail", order.getCustomerEmail());
        orderMap.put("paymentMethod", order.getPaymentMethod());
        orderMap.put("totalPrice", order.getTotalPrice());
        orderMap.put("orderStatus", order.getOrderStatus());
        String createdAtStr = order.getCreatedAt();
        orderMap.put("createdAt", createdAtStr);

        List<Map<String, Object>> orderItems = new java.util.ArrayList<>();
        try {
          orderItems = orderDAO.findOrderItems(order.getId());
        } catch (Exception e) {
          e.printStackTrace();
        }
        List<Map<String, Object>> itemsWithDetails = new java.util.ArrayList<>();

        for (Map<String, Object> item : orderItems) {
          Map<String, Object> itemDetail = new HashMap<>();
          String itemType = (String) item.get("itemType");
          if (itemType != null) {
            int itemId = ((Number) item.get("itemId")).intValue();
            int quantity = item.get("quantity") != null ? ((Number) item.get("quantity")).intValue() : 1;
            BigDecimal priceObj = (BigDecimal) item.get("price");
            if (priceObj == null) priceObj = BigDecimal.ZERO;

            itemDetail.put("itemType", itemType);
            itemDetail.put("itemId", itemId);
            itemDetail.put("quantity", quantity);
            itemDetail.put("price", priceObj);

            String itemName = "";
            try {
              if ("PACKAGE".equals(itemType)) {
                model.Package pkg = packageDAO.getPackageById(itemId);
                itemName = pkg != null && pkg.getTitle() != null ? pkg.getTitle() : "패키지 #" + itemId;
              } else if ("MODEL".equals(itemType)) {
                model.AIModel modelObj = modelDAO.getModelById(itemId);
                if (modelObj != null) {
                  itemName = modelObj.getModelName() != null ? modelObj.getModelName() : "모델 #" + itemId;
                  if (priceObj == null || priceObj.compareTo(BigDecimal.ZERO) == 0) {
                    try {
                      String priceStr = modelObj.getPrice();
                      if (priceStr != null && !priceStr.isEmpty()) {
                        BigDecimal parsedPrice = new BigDecimal(priceStr.replaceAll("[^0-9.]", ""));
                        if (parsedPrice.compareTo(BigDecimal.ZERO) > 0) {
                          priceObj = parsedPrice;
                          itemDetail.put("price", priceObj);
                        }
                      }
                    } catch (Exception e) { /* ignore */ }
                  }
                } else {
                  itemName = "모델 #" + itemId;
                }
              } else {
                itemName = "아이템 #" + itemId;
              }
            } catch (Exception e) {
              System.err.println("Error loading item name for itemId " + itemId + ": " + e.getMessage());
              itemName = "아이템 #" + itemId;
            }
            itemDetail.put("itemName", itemName);
            itemsWithDetails.add(itemDetail);
          }
        }

        orderMap.put("items", itemsWithDetails);
        ordersWithItems.add(orderMap);
      }
    } catch (Exception e) {
      e.printStackTrace();
    }
  }

  // 비밀번호 변경 처리
  List<String> passwordError = null;
  String passwordSuccess = null;
  if ("POST".equals(request.getMethod()) && "changePassword".equals(request.getParameter("action"))
      && CSRFUtil.validateToken(request)) {
    String currentPassword = request.getParameter("currentPassword");
    String newPassword = request.getParameter("newPassword");
    String newPasswordConfirm = request.getParameter("newPasswordConfirm");

    UserService userService = new UserService();
    List<String> errors = userService.changePassword(user.getId(), currentPassword, newPassword, newPasswordConfirm);

    if (errors.isEmpty()) {
      passwordSuccess = "비밀번호가 성공적으로 변경되었습니다.";
    } else {
      passwordError = errors;
    }
  }

  CreditDAO creditDAO = new CreditDAO();
  int creditBalance = 0;
  int totalGranted = 0;
  int totalUsed = 0;
  List<Map<String, Object>> creditLogs = new java.util.ArrayList<>();
  try {
    creditBalance = creditDAO.getBalance(user.getId());
    totalGranted = creditDAO.getTotalGranted(user.getId());
    totalUsed = creditDAO.getTotalUsed(user.getId());
    creditLogs = creditDAO.getUsageLogs(user.getId(), 10);
  } catch (Exception e) {}

  List<LabSession> labSessions = new java.util.ArrayList<>();
  try {
    labSessions = new LabSessionDAO().findRecentByUser(user.getId(), 10);
  } catch (Exception e) {}

  List<AgentRun> agentRuns = new java.util.ArrayList<>();
  try {
    agentRuns = new AgentRunDAO().findRecentByUser(user.getId(), 10);
  } catch (Exception e) {}

  String returnParam = request.getParameter("return");
  String returnUrl = null;
  if (returnParam != null && !returnParam.isEmpty()
      && returnParam.startsWith("/") && !returnParam.startsWith("//")) {
    returnUrl = returnParam;
  }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>마이페이지 - AI Workflow Lab</title>
  <link rel="icon" href="data:,">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
  <link rel="stylesheet" href="/AI/assets/css/dark-theme.css">
  <link rel="stylesheet" href="/AI/assets/css/page.css">
  <style>
    /* ── Page header ── */
    .mp-hero { padding: 52px 0 40px; }
    .mp-hero__avatar {
      width: 80px; height: 80px; border-radius: 50%;
      background: linear-gradient(135deg, #3b82f6, #8b5cf6);
      display: flex; align-items: center; justify-content: center;
      font-size: 1.75rem; font-weight: 700; color: #fff;
      margin-bottom: 16px; overflow: hidden; flex-shrink: 0;
    }
    .mp-hero__avatar img { width: 100%; height: 100%; object-fit: cover; }
    .mp-hero__name { font-size: 1.625rem; font-weight: 700; letter-spacing: -.02em; margin-bottom: 4px; }
    .mp-hero__email { font-size: .9rem; color: var(--text-muted, #64748b); }
    .badge-kakao {
      display: inline-flex; align-items: center; gap: 5px;
      background: #FEE500; color: rgba(0,0,0,.8);
      font-size: .72rem; font-weight: 700; padding: 3px 9px; border-radius: 20px;
      margin-top: 8px;
    }
    /* ── 결제 카드 ── */
    .payment-card-wrap { display: flex; flex-direction: column; gap: 14px; }
    .payment-card {
      background: linear-gradient(135deg, #1e3a5f, #2d1b69);
      border-radius: 14px; padding: 22px 24px; color: #fff;
      display: flex; justify-content: space-between; align-items: flex-end;
      position: relative; overflow: hidden;
    }
    .payment-card::before {
      content: ''; position: absolute; top: -30px; right: -30px;
      width: 120px; height: 120px; border-radius: 50%;
      background: rgba(255,255,255,.07);
    }
    .payment-card__number { font-size: 1rem; font-weight: 600; letter-spacing: .12em; margin-bottom: 10px; }
    .payment-card__name { font-size: .8rem; opacity: .7; }
    .payment-card__expiry { font-size: .8rem; opacity: .7; }
    .payment-card__brand { font-size: 1.5rem; font-weight: 800; opacity: .85; }
    .no-payment { text-align: center; padding: 36px 24px; color: var(--text-muted,#64748b); font-size: .875rem; }
    .no-payment i { font-size: 2rem; display: block; margin-bottom: 10px; opacity: .4; }

    /* ── No subscription ── */
    .no-sub {
      text-align: center; padding: 48px 24px;
      background: rgba(255,255,255,.04); border: 1px solid rgba(255,255,255,.08); border-radius: 16px;
    }
    .no-sub__icon { font-size: 2.5rem; margin-bottom: 16px; opacity: .4; }
    .no-sub h3 { font-size: 1.125rem; font-weight: 600; margin-bottom: 8px; }
    .no-sub p { font-size: .875rem; color: var(--text-muted, #64748b); margin-bottom: 24px; }

    /* ── Order card ── */
    .order-card {
      background: rgba(255,255,255,.03); border: 1px solid rgba(255,255,255,.07);
      border-radius: 12px; padding: 20px; margin-bottom: 14px;
    }
    .order-card:last-child { margin-bottom: 0; }
    .order-card__top { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 12px; }
    .order-card__id { font-size: .875rem; font-weight: 700; margin-bottom: 4px; }
    .order-card__date { font-size: .8125rem; color: var(--text-muted, #64748b); }
    .order-card__price { font-size: 1.25rem; font-weight: 700; color: #60a5fa; }
    .order-card__method { font-size: .75rem; color: var(--text-muted, #64748b); margin-top: 2px; text-align: right; }
    .order-item { display: flex; justify-content: space-between; align-items: center;
      padding: 8px 0; border-bottom: 1px solid rgba(255,255,255,.05); font-size: .875rem; }
    .order-item:last-child { border-bottom: none; }
    .order-item__name { color: var(--text-secondary, #94a3b8); display: flex; align-items: center; gap: 8px; }
    .order-item__price { color: var(--text-primary, #f1f5f9); font-weight: 500; }
    .no-orders { text-align: center; padding: 40px; color: var(--text-muted, #64748b); font-size: .875rem; }

    /* ── Submit button ── */
    .btn-submit {
      width: 100%; margin-top: 8px; padding: 13px; border-radius: 12px;
      font-size: .9375rem; font-weight: 700; border: none; cursor: pointer;
      background: linear-gradient(135deg, #3b82f6, #8b5cf6); color: #fff;
      box-shadow: 0 4px 20px rgba(59,130,246,.3); transition: opacity .2s, transform .15s;
    }
    .btn-submit:hover { opacity: .9; transform: translateY(-1px); }
  </style>
</head>
<body>
<jsp:include page="/AI/partials/header.jsp"/>

<div style="max-width: 800px; margin: 0 auto; padding: 0 24px;">

  <!-- Hero -->
  <div class="mp-hero">
    <div class="mp-hero__avatar">
      <% if (user.getProfileImageUrl() != null && !user.getProfileImageUrl().isEmpty()) { %>
        <img src="<%= EscapeUtil.escapeHtml(user.getProfileImageUrl()) %>" alt="프로필">
      <% } else { %>
        <%= user.getFullName() != null && !user.getFullName().isEmpty()
            ? EscapeUtil.escapeHtml(String.valueOf(user.getFullName().charAt(0)).toUpperCase())
            : "U" %>
      <% } %>
    </div>
    <div class="mp-hero__name"><%= EscapeUtil.escapeHtml(user.getFullName() != null ? user.getFullName() : user.getUsername()) %></div>
    <div class="mp-hero__email"><%= EscapeUtil.escapeHtml(user.getEmail() != null ? user.getEmail() : "") %></div>
    <% if (user.getKakaoId() != null) { %>
    <div class="badge-kakao">
      <svg width="14" height="14" viewBox="0 0 20 20" fill="none"><path fill-rule="evenodd" clip-rule="evenodd" d="M10 2C5.582 2 2 4.836 2 8.333c0 2.21 1.392 4.155 3.49 5.29l-.888 3.317a.25.25 0 0 0 .372.273L9.06 14.95c.31.03.624.05.94.05 4.418 0 8-2.836 8-6.333S14.418 2 10 2Z" fill="rgba(0,0,0,0.8)"/></svg>
      카카오 연동됨
    </div>
    <% } %>
  </div>

  <!-- Tabs -->
  <div class="tab-bar">
    <button class="tab-item active" data-tab="profile" onclick="switchTab('profile', this)">
      <i class="bi bi-person"></i>프로필
    </button>
    <button class="tab-item" data-tab="subscription" onclick="switchTab('subscription', this)">
      <i class="bi bi-credit-card"></i>구독
    </button>
    <button class="tab-item" data-tab="orders" onclick="switchTab('orders', this)">
      <i class="bi bi-receipt"></i>활동 내역
    </button>
    <button class="tab-item" data-tab="payment" onclick="switchTab('payment', this)">
      <i class="bi bi-credit-card-2-front"></i>결제 수단
    </button>
    <button class="tab-item" data-tab="usage" onclick="switchTab('usage', this)">
      <i class="bi bi-coin"></i>크레딧
    </button>
    <button class="tab-item" data-tab="labs" onclick="switchTab('labs', this)">
      <i class="bi bi-bezier2"></i>실습 기록
    </button>
    <button class="tab-item" data-tab="agents" onclick="switchTab('agents', this)">
      <i class="bi bi-stars"></i>에이전트
    </button>
    <button class="tab-item" data-tab="apikeys" onclick="switchTab('apikeys', this)">
      <i class="bi bi-key"></i>API 키
    </button>
  </div>

  <!-- ══ Panel: 프로필 ══ -->
  <div id="panel-profile" class="tab-panel active">

    <!-- Account info -->
    <div class="glass-card">
      <div class="card-header"><i class="bi bi-person-circle"></i>계정 정보</div>
      <div class="glass-card__body">
        <div class="info-row">
          <span class="info-row__label">이메일</span>
          <span class="info-row__val"><%= EscapeUtil.escapeHtml(user.getEmail() != null ? user.getEmail() : "") %></span>
        </div>
        <div class="info-row">
          <span class="info-row__label">이름</span>
          <span class="info-row__val"><%= EscapeUtil.escapeHtml(user.getFullName() != null ? user.getFullName() : "") %></span>
        </div>
        <div class="info-row">
          <span class="info-row__label">계정 상태</span>
          <span class="info-row__val">
            <% if (user.isActive()) { %><span class="badge badge-green"><i class="bi bi-check-circle-fill"></i>활성</span>
            <% } else { %><span class="badge badge-red">비활성</span><% } %>
          </span>
        </div>
        <div class="info-row">
          <span class="info-row__label">로그인 방식</span>
          <span class="info-row__val">
            <% if (user.getKakaoId() != null) { %>
            <span class="badge-kakao" style="font-size:.75rem;">
              <svg width="12" height="12" viewBox="0 0 20 20" fill="none"><path fill-rule="evenodd" clip-rule="evenodd" d="M10 2C5.582 2 2 4.836 2 8.333c0 2.21 1.392 4.155 3.49 5.29l-.888 3.317a.25.25 0 0 0 .372.273L9.06 14.95c.31.03.624.05.94.05 4.418 0 8-2.836 8-6.333S14.418 2 10 2Z" fill="rgba(0,0,0,0.8)"/></svg>
              카카오 로그인
            </span>
            <% } else { %><span style="color:var(--text-muted,#64748b);">이메일/비밀번호</span><% } %>
          </span>
        </div>
        <% if (user.getGender() != null) { %>
        <div class="info-row">
          <span class="info-row__label">성별</span>
          <span class="info-row__val"><%= "male".equals(user.getGender()) ? "남성" : "여성" %></span>
        </div>
        <% } %>
        <% if (user.getAgeRange() != null) { %>
        <div class="info-row">
          <span class="info-row__label">연령대</span>
          <span class="info-row__val"><%= EscapeUtil.escapeHtml(user.getAgeRange()) %>대</span>
        </div>
        <% } %>
        <% if (user.getBirthyear() != null || user.getBirthday() != null) { %>
        <div class="info-row">
          <span class="info-row__label">생년월일</span>
          <span class="info-row__val">
            <%
              String birthDisplay = "";
              if (user.getBirthyear() != null) birthDisplay += user.getBirthyear() + "년 ";
              if (user.getBirthday() != null && user.getBirthday().length() == 4) {
                birthDisplay += user.getBirthday().substring(0,2) + "월 " + user.getBirthday().substring(2) + "일";
              }
            %><%= EscapeUtil.escapeHtml(birthDisplay.trim()) %>
          </span>
        </div>
        <% } %>
        <% if (user.getCreatedAt() != null) { %>
        <div class="info-row">
          <span class="info-row__label">가입일</span>
          <span class="info-row__val" style="color:var(--text-muted,#64748b);">
            <%= new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(user.getCreatedAt()) %>
          </span>
        </div>
        <% } %>
        <% if (user.getLastLogin() != null) { %>
        <div class="info-row">
          <span class="info-row__label">마지막 로그인</span>
          <span class="info-row__val" style="color:var(--text-muted,#64748b);">
            <%= new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(user.getLastLogin()) %>
          </span>
        </div>
        <% } %>
      </div>
    </div>

    <!-- Password change (카카오 전용 계정은 숨김) -->
    <% if (user.getKakaoId() == null || user.getPasswordHash() != null) { %>
    <div class="glass-card">
      <div class="card-header"><i class="bi bi-lock"></i>비밀번호 변경</div>
      <div class="glass-card__body">
        <% if (passwordError != null && !passwordError.isEmpty()) { %>
        <div id="password-error" class="alert-error">
          <ul>
            <% for (String err : passwordError) { %>
            <li><%= EscapeUtil.escapeHtml(err) %></li>
            <% } %>
          </ul>
        </div>
        <% } %>
        <% if (passwordSuccess != null) { %>
        <div class="alert-success"><%= EscapeUtil.escapeHtml(passwordSuccess) %></div>
        <% } %>

        <form method="POST" action="/AI/user/mypage.jsp" id="changePasswordForm">
          <input type="hidden" name="action" value="changePassword">
          <%= CSRFUtil.getHiddenFieldHtml(request) %>

          <div class="form-field">
            <label for="currentPassword">현재 비밀번호 *</label>
            <input type="password" id="currentPassword" name="currentPassword"
                   placeholder="현재 비밀번호를 입력하세요" required autocomplete="current-password">
          </div>
          <div class="form-field">
            <label for="newPassword">새 비밀번호 *</label>
            <input type="password" id="newPassword" name="newPassword"
                   placeholder="최소 8자 이상" required minlength="8" autocomplete="new-password">
            <small>비밀번호는 최소 8자 이상이어야 합니다.</small>
          </div>
          <div class="form-field">
            <label for="newPasswordConfirm">새 비밀번호 확인 *</label>
            <input type="password" id="newPasswordConfirm" name="newPasswordConfirm"
                   placeholder="새 비밀번호를 다시 입력하세요" required minlength="8" autocomplete="new-password">
          </div>
          <button type="submit" class="btn-submit">비밀번호 변경</button>
        </form>
      </div>
    </div>

    <% } %>

  </div><!-- /panel-profile -->

  <!-- ══ Panel: 구독 ══ -->
  <div id="panel-subscription" class="tab-panel">
    <% if (subscription != null && plan != null) { %>
    <div class="glass-card">
      <div class="card-header"><i class="bi bi-stars"></i>현재 구독 플랜</div>
      <div class="glass-card__body">
        <div class="info-row">
          <span class="info-row__label">플랜</span>
          <span class="info-row__val" style="font-weight:700; color:#60a5fa;">
            <%= plan.getName() != null ? EscapeUtil.escapeHtml(plan.getName()) : EscapeUtil.escapeHtml(subscription.getPlanCode()) %>
          </span>
        </div>
        <div class="info-row">
          <span class="info-row__label">구독 기간</span>
          <span class="info-row__val">
            <%= subscription.getStartDate() != null ? subscription.getStartDate().format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd")) : "" %>
            ~
            <%= subscription.getEndDate() != null ? subscription.getEndDate().format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd")) : "" %>
          </span>
        </div>
        <div class="info-row">
          <span class="info-row__label">남은 기간</span>
          <span class="info-row__val">
            <%
              long daysRemaining = subscription.getDaysRemaining();
              if (daysRemaining > 0) {
            %><span style="color:#34d399; font-weight:600;"><%= daysRemaining %>일 남음</span>
            <% } else { %><span style="color:#f87171;">만료됨</span><% } %>
          </span>
        </div>
        <div class="info-row">
          <span class="info-row__label">구독 상태</span>
          <span class="info-row__val">
            <% if (subscription.isActiveNow()) { %>
            <span class="badge badge-green"><i class="bi bi-check-circle-fill"></i>활성</span>
            <% } else { %>
            <span class="badge badge-red">만료</span>
            <% } %>
          </span>
        </div>
      </div>
    </div>
    <% } else { %>
    <div class="no-sub">
      <div class="no-sub__icon"><i class="bi bi-credit-card"></i></div>
      <h3>활성 구독 없음</h3>
      <p>현재 활성화된 구독이 없습니다. 요금제를 선택하여 모든 기능을 이용하세요.</p>
      <a href="/AI/user/pricing.jsp" class="btn-primary"><i class="bi bi-arrow-right"></i>요금제 보기</a>
    </div>
    <% } %>
  </div><!-- /panel-subscription -->

  <!-- ══ Panel: 활동 내역 ══ -->
  <div id="panel-orders" class="tab-panel">
    <% if (ordersWithItems.isEmpty()) { %>
    <div class="no-sub">
      <div class="no-sub__icon"><i class="bi bi-receipt"></i></div>
      <h3>결제 내역 없음</h3>
      <p>아직 결제 내역이 없습니다.</p>
    </div>
    <% } else { %>
    <% for (Map<String, Object> order : ordersWithItems) { %>
    <div class="order-card">
      <div class="order-card__top">
        <div>
          <div class="order-card__id">주문 #<%= order.get("id") %></div>
          <div class="order-card__date">
            <%
              String createdAtStr = (String) order.get("createdAt");
              if (createdAtStr != null && !createdAtStr.trim().isEmpty()) {
                try {
                  java.text.SimpleDateFormat dbFmt = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                  java.util.Date dt = dbFmt.parse(createdAtStr);
                  out.print(new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(dt));
                } catch (Exception e) {
                  out.print(createdAtStr.substring(0, Math.min(createdAtStr.length(), 16)));
                }
              } else { out.print("-"); }
            %>
          </div>
        </div>
        <div style="text-align:right;">
          <div class="order-card__price">
            <%
              BigDecimal totalPrice = (BigDecimal) order.get("totalPrice");
              if (totalPrice != null) {
                long priceKrw = Math.round(totalPrice.doubleValue() * 1350);
            %>
            <span class="price-display" data-price-usd="<%= totalPrice.doubleValue() %>">
              <%= String.format("%,d", priceKrw) %>원
            </span>
            <% } else { %>$0.00<% } %>
          </div>
          <div class="order-card__method">
            <%= "card".equals(order.get("paymentMethod")) ? "카드" :
                "bank".equals(order.get("paymentMethod")) ? "은행 이체" :
                "virtual".equals(order.get("paymentMethod")) ? "가상계좌" :
                order.get("paymentMethod") != null ? EscapeUtil.escapeHtml((String)order.get("paymentMethod")) : "-" %>
          </div>
        </div>
      </div>

      <!-- Items -->
      <%
        @SuppressWarnings("unchecked")
        List<Map<String, Object>> items = (List<Map<String, Object>>) order.get("items");
        if (items != null && !items.isEmpty()) {
          for (Map<String, Object> item : items) {
            String itemType = (String) item.get("itemType");
            String itemName = item.get("itemName") != null ? (String) item.get("itemName") : "";
            if (itemName == null || itemName.isEmpty()) {
              int itemId = item.get("itemId") != null ? ((Number) item.get("itemId")).intValue() : 0;
              if ("PACKAGE".equals(itemType)) itemName = "패키지 #" + itemId;
              else if ("MODEL".equals(itemType)) itemName = "모델 #" + itemId;
              else itemName = "아이템 #" + itemId;
            }
            BigDecimal itemPrice = (BigDecimal) item.get("price");
            if (itemPrice == null) itemPrice = BigDecimal.ZERO;
            int qty = item.get("quantity") != null ? ((Number) item.get("quantity")).intValue() : 1;
      %>
      <div class="order-item">
        <div class="order-item__name">
          <span class="badge badge-gray"><%= "PACKAGE".equals(itemType) ? "패키지" : "모델" %></span>
          <%= itemName.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;") %>
          <span style="color:var(--text-muted,#64748b);">×<%= qty %></span>
        </div>
        <div class="order-item__price">
          <% if (itemPrice.compareTo(BigDecimal.ZERO) > 0) {
               long ip = Math.round(itemPrice.doubleValue() * 1350); %>
          <span class="price-display" data-price-usd="<%= itemPrice.doubleValue() %>"><%= String.format("%,d", ip) %>원</span>
          <% } else { %><span style="color:var(--text-muted,#64748b);">무료</span><% } %>
        </div>
      </div>
      <%   }
        } else { %>
      <p class="no-orders">주문 아이템 정보가 없습니다.</p>
      <% } %>
    </div>
    <% } %>
    <% } %>
  </div><!-- /panel-orders -->

  <!-- ══ Panel: 결제 수단 ══ -->
  <div id="panel-payment" class="tab-panel">
    <div class="glass-card">
      <div class="card-header"><i class="bi bi-credit-card-2-front"></i>등록된 결제 수단</div>
      <div class="glass-card__body">
        <div class="no-payment">
          <i class="bi bi-credit-card"></i>
          등록된 결제 수단이 없습니다.
        </div>
      </div>
    </div>

    <div class="glass-card" style="margin-top:16px;">
      <div class="card-header"><i class="bi bi-plus-circle"></i>카드 등록</div>
      <div class="glass-card__body">
        <!-- 카드 미리보기 -->
        <div class="payment-card" style="margin-bottom:20px;">
          <div>
            <div class="payment-card__number" id="preview-number">•••• •••• •••• ••••</div>
            <div class="payment-card__name" id="preview-name">홍길동</div>
          </div>
          <div style="text-align:right;">
            <div class="payment-card__brand">CARD</div>
            <div class="payment-card__expiry" id="preview-expiry">MM/YY</div>
          </div>
        </div>

        <form id="cardForm" onsubmit="submitCard(event)">
          <div class="form-field">
            <label>카드 번호</label>
            <input type="text" id="cardNumber" placeholder="0000 0000 0000 0000"
                   maxlength="19" inputmode="numeric" autocomplete="cc-number"
                   oninput="formatCardNumber(this)">
          </div>
          <div style="display:grid; grid-template-columns:1fr 1fr; gap:12px;">
            <div class="form-field">
              <label>유효기간</label>
              <input type="text" id="cardExpiry" placeholder="MM/YY"
                     maxlength="5" inputmode="numeric" autocomplete="cc-exp"
                     oninput="formatExpiry(this)">
            </div>
            <div class="form-field">
              <label>CVV</label>
              <input type="password" id="cardCvv" placeholder="•••"
                     maxlength="4" inputmode="numeric" autocomplete="cc-csc">
            </div>
          </div>
          <div class="form-field">
            <label>카드 소유자 이름</label>
            <input type="text" id="cardName" placeholder="카드에 적힌 이름"
                   autocomplete="cc-name" oninput="updatePreview()">
          </div>
          <button type="submit" class="btn-submit" style="margin-top:4px;">
            <i class="bi bi-lock-fill"></i> 카드 등록
          </button>
          <p style="text-align:center; font-size:.75rem; color:var(--text-muted,#64748b); margin-top:12px;">
            <i class="bi bi-shield-lock"></i> 카드 정보는 암호화되어 안전하게 처리됩니다.
          </p>
        </form>
      </div>
    </div>
  </div><!-- /panel-payment -->

  <!-- ══ Panel: 크레딧 ══ -->
  <div id="panel-usage" class="tab-panel">
    <div class="glass-card">
      <div class="card-header"><i class="bi bi-coin"></i>크레딧 현황</div>
      <div class="glass-card__body">
        <div class="info-row">
          <span class="info-row__label">현재 잔액</span>
          <span class="info-row__val" style="font-weight:700;color:#60a5fa;"><%= creditBalance %> credits</span>
        </div>
        <div class="info-row">
          <span class="info-row__label">누적 지급</span>
          <span class="info-row__val"><%= totalGranted %> credits</span>
        </div>
        <div class="info-row">
          <span class="info-row__label">누적 사용</span>
          <span class="info-row__val"><%= totalUsed %> credits</span>
        </div>
      </div>
    </div>

    <div class="glass-card" style="margin-top:16px;">
      <div class="card-header"><i class="bi bi-clock-history"></i>최근 사용 내역</div>
      <div class="glass-card__body">
        <% if (creditLogs.isEmpty()) { %>
          <div class="no-orders">사용 기록이 없습니다.</div>
        <% } else { %>
          <% for (Map<String, Object> log : creditLogs) { %>
            <div class="order-item">
              <div class="order-item__name">
                <strong><%= EscapeUtil.escapeHtml(String.valueOf(log.get("feature"))) %></strong>
                <span style="color:var(--text-muted,#64748b);">
                  <%= log.get("requestSummary") != null ? EscapeUtil.escapeHtml(String.valueOf(log.get("requestSummary"))) : "" %>
                </span>
              </div>
              <div class="order-item__price">
                -<%= log.get("creditsUsed") %> credits
              </div>
            </div>
          <% } %>
        <% } %>
      </div>
    </div>
  </div><!-- /panel-usage -->

  <!-- ══ Panel: 실습 기록 ══ -->
  <div id="panel-labs" class="tab-panel">
    <div class="glass-card">
      <div class="card-header"><i class="bi bi-bezier2"></i>최근 실습 세션</div>
      <div class="glass-card__body">
        <% if (labSessions.isEmpty()) { %>
          <div class="no-orders">저장된 실습 세션이 없습니다.</div>
        <% } else { %>
          <% for (LabSession labSession : labSessions) { %>
            <div class="order-card">
              <div class="order-card__top">
                <div>
                  <div class="order-card__id"><%= EscapeUtil.escapeHtml(labSession.getTitle() != null ? labSession.getTitle() : "실습 실행") %></div>
                  <div class="order-card__date">
                    <%= labSession.getCreatedAt() != null ? new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(labSession.getCreatedAt()) : "-" %>
                  </div>
                </div>
                <div style="text-align:right;">
                  <div class="order-card__price" style="font-size:1rem;"><%= labSession.getTokensUsed() %> tokens</div>
                  <div class="order-card__method"><%= EscapeUtil.escapeHtml(labSession.getSessionType()) %> · <%= EscapeUtil.escapeHtml(String.valueOf(labSession.getCreditsUsed())) %> credits</div>
                </div>
              </div>
              <% if (labSession.getProjectId() != null) { %>
              <a href="/AI/user/lab/session.jsp?id=<%= labSession.getProjectId() %>" class="btn-primary" style="display:inline-flex;padding:8px 14px;font-size:.82rem;">
                <i class="bi bi-arrow-repeat"></i>세션 열기
              </a>
              <% } %>
            </div>
          <% } %>
        <% } %>
      </div>
    </div>
  </div><!-- /panel-labs -->

  <!-- ══ Panel: Agent Runs ══ -->
  <div id="panel-agents" class="tab-panel">
    <div class="glass-card">
      <div class="card-header"><i class="bi bi-stars"></i>최근 에이전트 실행</div>
      <div class="glass-card__body">
        <% if (agentRuns.isEmpty()) { %>
          <div class="no-orders">저장된 에이전트 실행이 없습니다.</div>
        <% } else { %>
          <% for (AgentRun agentRun : agentRuns) { %>
            <div class="order-card">
              <div class="order-card__top">
                <div>
                  <div class="order-card__id"><%= EscapeUtil.escapeHtml(agentRun.getTitle() != null ? agentRun.getTitle() : "에이전트 실행") %></div>
                  <div class="order-card__date">
                    <%= agentRun.getCreatedAt() != null ? new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(agentRun.getCreatedAt()) : "-" %>
                  </div>
                </div>
                <div style="text-align:right;">
                  <div class="order-card__price" style="font-size:1rem;"><%= agentRun.getPromptTokens() + agentRun.getOutputTokens() %> tokens</div>
                  <div class="order-card__method"><%= EscapeUtil.escapeHtml(agentRun.getTemplateName() != null ? agentRun.getTemplateName() : "-") %> · <%= EscapeUtil.escapeHtml(String.valueOf(agentRun.getCreditsUsed())) %> credits</div>
                </div>
              </div>
              <div style="color:var(--text-secondary,#cbd5e1); font-size:.875rem; line-height:1.7; margin-bottom:12px;">
                <strong style="color:var(--text-primary,#f8fafc);">목표</strong><br>
                <%= EscapeUtil.escapeHtml(agentRun.getUserGoal() != null ? agentRun.getUserGoal() : "") %>
              </div>
              <%
                String preview = "";
                if (agentRun.getFinalOutputJson() != null) {
                  preview = agentRun.getFinalOutputJson();
                  if (preview.length() > 220) preview = preview.substring(0, 220) + "...";
                }
              %>
              <div style="color:var(--text-muted,#94a3b8); font-size:.8125rem; line-height:1.65; margin-bottom:14px; white-space:pre-wrap;"><%= EscapeUtil.escapeHtml(preview) %></div>
              <a href="/AI/user/agent/workspace.jsp" class="btn-primary" style="display:inline-flex;padding:8px 14px;font-size:.82rem;">
                <i class="bi bi-arrow-repeat"></i>에이전트 워크스페이스 열기
              </a>
            </div>
          <% } %>
        <% } %>
      </div>
    </div>
  </div><!-- /panel-agents -->

  <!-- ══ Panel: API Keys ══ -->
  <div id="panel-apikeys" class="tab-panel">
    <div class="glass-card">
      <div class="card-header"><i class="bi bi-key"></i>API 키 관리</div>
      <div class="glass-card__body">
        <% if (returnUrl != null) { %>
        <div class="alert-success" style="margin-bottom:14px;">
          실습 화면에서 오셨습니다. Anthropic API 키를 저장하면 바로 돌아가서 실행을 이어갈 수 있습니다.
          <div style="margin-top:10px;">
            <a href="<%= EscapeUtil.escapeHtml(returnUrl) %>" class="btn-primary" style="display:inline-flex;padding:8px 14px;font-size:.82rem;">
              <i class="bi bi-arrow-left"></i>실습으로 돌아가기
            </a>
          </div>
        </div>
        <% } %>
        <form id="apiKeyForm" onsubmit="saveApiKey(event)">
          <%= CSRFUtil.getHiddenFieldHtml(request) %>
          <div class="form-field">
            <label>Provider</label>
            <select id="apiProvider" class="form-input">
              <option value="anthropic">Anthropic</option>
              <option value="openai">OpenAI</option>
              <option value="google">Google</option>
              <option value="mistral">Mistral</option>
            </select>
            <small>실습 실행과 AI 도우미는 현재 Anthropic, OpenAI 키를 지원합니다.</small>
          </div>
          <div class="form-field">
            <label>키 이름</label>
            <input type="text" id="apiKeyName" class="form-input" placeholder="예: 개인 Anthropic 키">
          </div>
          <div class="form-field">
            <label>API 키</label>
            <input type="password" id="apiKeyValue" class="form-input" placeholder="sk-ant-... 또는 sk-proj-...">
          </div>
          <button type="submit" class="btn-submit">API 키 저장</button>
        </form>
      </div>
    </div>

    <div class="glass-card" style="margin-top:16px;">
      <div class="card-header"><i class="bi bi-list-ul"></i>등록된 키</div>
      <div class="glass-card__body">
        <div id="apiKeyList" class="no-orders">불러오는 중...</div>
      </div>
    </div>
  </div><!-- /panel-apikeys -->

</div><!-- /wrapper -->

<script src="/AI/assets/js/user.js"></script>
<script>
  /* ── Tab switch ── */
  function switchTab(name, btn) {
    document.querySelectorAll('.tab-panel').forEach(p => p.classList.remove('active'));
    document.querySelectorAll('.tab-item').forEach(b => b.classList.remove('active'));
    document.getElementById('panel-' + name).classList.add('active');
    btn.classList.add('active');
    if (history.replaceState) {
      const url = new URL(window.location.href);
      url.searchParams.set('tab', name);
      history.replaceState(null, '', url.toString());
    }
  }

  (function initRequestedTab() {
    const params = new URLSearchParams(window.location.search);
    const requestedTab = params.get('tab') || (window.location.hash ? window.location.hash.replace('#', '') : '');
    if (!requestedTab) return;
    const panel = document.getElementById('panel-' + requestedTab);
    const btn = document.querySelector('.tab-item[data-tab="' + requestedTab + '"]');
    if (panel && btn) {
      switchTab(requestedTab, btn);
    }
  })();

  /* ── Open profile tab if password errors exist ── */
  <% if ((passwordError != null && !passwordError.isEmpty()) || passwordSuccess != null) { %>
  switchTab('profile', document.querySelector('.tab-item'));
  <% } %>

  /* ── Password change validation ── */
  document.getElementById('changePasswordForm').addEventListener('submit', function(e) {
    const newPassword = document.getElementById('newPassword').value;
    const newPasswordConfirm = document.getElementById('newPasswordConfirm').value;

    if (newPassword !== newPasswordConfirm) {
      e.preventDefault();
      const errorDiv = document.getElementById('password-error');
      if (errorDiv) {
        errorDiv.textContent = '새 비밀번호가 일치하지 않습니다.';
        errorDiv.style.display = 'block';
      } else {
        alert('새 비밀번호가 일치하지 않습니다.');
      }
      return false;
    }
  });

  /* ── Real-time password match check ── */
  const newPasswordInput = document.getElementById('newPassword');
  const newPasswordConfirmInput = document.getElementById('newPasswordConfirm');

  function checkPasswordMatch() {
    if (newPasswordConfirmInput.value && newPasswordInput.value !== newPasswordConfirmInput.value) {
      newPasswordConfirmInput.setCustomValidity('비밀번호가 일치하지 않습니다.');
    } else {
      newPasswordConfirmInput.setCustomValidity('');
    }
  }

  newPasswordInput.addEventListener('input', checkPasswordMatch);
  newPasswordConfirmInput.addEventListener('input', checkPasswordMatch);

  /* ── 카드 번호 포맷 (4자리마다 공백) ── */
  function formatCardNumber(input) {
    let v = input.value.replace(/\D/g, '').substring(0, 16);
    input.value = v.replace(/(.{4})/g, '$1 ').trim();
    document.getElementById('preview-number').textContent =
      (input.value || '•••• •••• •••• ••••').padEnd(19, '•').replace(/\d(?=.{1,14}$)/g, '•') || '•••• •••• •••• ••••';
    const raw = input.value.replace(/\s/g, '');
    const masked = raw.substring(0,4) + (raw.length > 4 ? ' •••• •••• ' + raw.substring(12) : '');
    document.getElementById('preview-number').textContent = masked || '•••• •••• •••• ••••';
  }

  /* ── 유효기간 포맷 (MM/YY) ── */
  function formatExpiry(input) {
    let v = input.value.replace(/\D/g, '').substring(0, 4);
    if (v.length >= 2) v = v.substring(0, 2) + '/' + v.substring(2);
    input.value = v;
    document.getElementById('preview-expiry').textContent = v || 'MM/YY';
  }

  /* ── 카드 소유자 미리보기 ── */
  function updatePreview() {
    const name = document.getElementById('cardName').value;
    document.getElementById('preview-name').textContent = name || '홍길동';
  }

  /* ── 카드 등록 제출 ── */
  function submitCard(e) {
    e.preventDefault();
    const num = document.getElementById('cardNumber').value.replace(/\s/g, '');
    const exp = document.getElementById('cardExpiry').value;
    const cvv = document.getElementById('cardCvv').value;
    const name = document.getElementById('cardName').value;
    if (num.length < 15 || exp.length < 5 || cvv.length < 3 || !name.trim()) {
      alert('모든 항목을 올바르게 입력해주세요.');
      return;
    }
    alert('결제 수단이 등록되었습니다.\n(실제 결제 게이트웨이 연동 시 처리됩니다)');
  }

  async function loadApiKeys() {
    const wrap = document.getElementById('apiKeyList');
    if (!wrap) return;
    try {
      const resp = await fetch('/AI/api/user/api-keys/');
      const data = await resp.json();
      if (!data.success || !Array.isArray(data.data) || data.data.length === 0) {
        wrap.innerHTML = '<div class="no-orders">등록된 API 키가 없습니다.</div>';
        return;
      }
      wrap.innerHTML = data.data.map(item => `
        <div class="order-item">
          <div class="order-item__name">
            <strong>${item.provider}</strong>
            <span>${item.keyName || ''}</span>
            <span style="color:var(--text-muted,#64748b);">${item.maskedKey || ''}</span>
          </div>
          <div class="order-item__price">
            <button type="button" onclick="deleteApiKey(${item.id})" style="background:none;border:none;color:#f87171;">삭제</button>
          </div>
        </div>
      `).join('');
    } catch (e) {
      wrap.innerHTML = '<div class="no-orders">API 키 목록을 불러오지 못했습니다.</div>';
    }
  }

  async function saveApiKey(e) {
    e.preventDefault();
    const csrfToken = document.querySelector('#apiKeyForm input[name="csrf_token"]')?.value || '';
    const provider = document.getElementById('apiProvider').value;
    const keyName = document.getElementById('apiKeyName').value;
    const apiKey = document.getElementById('apiKeyValue').value;
    if (!apiKey.trim()) {
      alert('API 키를 입력하세요.');
      return;
    }

    const resp = await fetch('/AI/api/user/api-keys/', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({ provider, keyName, apiKey, csrf_token: csrfToken })
    });
    const data = await resp.json();
    if (data.success) {
      document.getElementById('apiKeyForm').reset();
      loadApiKeys();
      <% if (returnUrl != null) { %>
      if (confirm('API 키가 저장되었습니다. 실습 화면으로 돌아갈까요?')) {
        window.location.href = '<%= EscapeUtil.escapeHtml(returnUrl) %>';
        return;
      }
      <% } else { %>
      alert('API 키가 저장되었습니다.');
      <% } %>
    } else {
      alert(data.message || '저장에 실패했습니다.');
    }
  }

  async function deleteApiKey(id) {
    if (!confirm('이 API 키를 삭제할까요?')) return;
    const csrfToken = document.querySelector('#apiKeyForm input[name="csrf_token"]')?.value || '';
    const resp = await fetch('/AI/api/user/api-keys/' + id, {
      method: 'DELETE',
      headers: { 'X-CSRF-Token': csrfToken }
    });
    const data = await resp.json();
    if (data.success) {
      loadApiKeys();
    } else {
      alert(data.message || '삭제에 실패했습니다.');
    }
  }

  (function initApiKeyContext() {
    const params = new URLSearchParams(window.location.search);
    const requestedTab = params.get('tab');
    const returnUrl = params.get('return');
    if (requestedTab === 'apikeys') {
      const providerEl = document.getElementById('apiProvider');
      if (providerEl) providerEl.value = 'anthropic';
    }
    if (returnUrl) {
      const nameEl = document.getElementById('apiKeyName');
      if (nameEl && !nameEl.value) nameEl.value = '실습용 Anthropic 키';
    }
  })();

  loadApiKeys();
</script>
<jsp:include page="/AI/partials/footer.jsp"/>
</body>
</html>
