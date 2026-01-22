<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.AIModelDAO" %>
<%@ page import="dao.OrderDAO" %>
<%@ page import="dao.PackageDAO" %>
<%@ page import="model.AIModel" %>
<%@ page import="java.util.List" %>
<%
  // 관리자 인증 확인
  if (session.getAttribute("admin") == null) {
    response.sendRedirect("/AI/admin/auth/login.jsp");
    return;
  }

  String adminRole = (String) session.getAttribute("adminRole");
  boolean isSuperadmin = "superadmin".equals(adminRole) || "SUPER".equals(adminRole);
  
  // 실제 DB 데이터 조회
  AIModelDAO modelDAO = new AIModelDAO();
  OrderDAO orderDAO = new OrderDAO();
  PackageDAO packageDAO = new PackageDAO();
  
  // 활성 모델 수 조회
  List<AIModel> allModels = modelDAO.findAll();
  int activeModelCount = 0;
  StringBuilder activeModelNames = new StringBuilder();
  try {
    for (AIModel model : allModels) {
      boolean isActive = true;
      try {
        isActive = model.isApiAvailable();
      } catch (Exception e) {
        // api_available 필드가 없거나 접근 불가능한 경우 모든 모델을 활성으로 간주
      }
      
      if (isActive) {
        activeModelCount++;
        if (activeModelNames.length() > 0) {
          activeModelNames.append(" / ");
        }
        if (activeModelNames.length() < 100) {
          String modelName = model.getModelName() != null ? model.getModelName() : "모델 #" + model.getId();
          activeModelNames.append(modelName);
        }
      }
    }
    if (activeModelNames.length() == 0) {
      activeModelNames.append("등록된 활성 모델이 없습니다");
    } else if (activeModelNames.length() > 100) {
      activeModelNames.append(" 외 ").append(activeModelCount - 3).append("개");
    }
  } catch (Exception e) {
    activeModelCount = allModels.size();
    activeModelNames.append("모델 조회 중 오류 발생");
  }
  
  // 최근 7일간 체크아웃 수 조회
  int recentCheckoutCount = orderDAO.countRecentOrders();
  
  // 전체 패키지 수
  int totalPackageCount = packageDAO.findAll().size();
%>
<%@ include file="/AI/admin/layout/header.jspf" %>
<div class="admin-layout">
  <%@ include file="/AI/admin/layout/sidebar.jspf" %>
  <div class="admin-main-wrapper">
    <%@ include file="/AI/admin/layout/topbar.jspf" %>
    <main class="admin-content">
      <header class="admin-dashboard-header">
        <h1>관리자 대시보드</h1>
        <p>AI Navigator 전체 흐름을 한 화면에서 모니터링합니다.</p>
      </header>

      <section class="admin-grid">
        <article>
          <h2>활성 모델</h2>
          <p><%= activeModelNames.toString() %></p>
          <span class="counter"><%= activeModelCount %></span>
        </article>
        <article>
          <h2>신규 체크아웃</h2>
          <p>최근 7일간</p>
          <span class="counter"><%= recentCheckoutCount %></span>
        </article>
        <article>
          <h2>등록된 패키지</h2>
          <p>전체 패키지 수</p>
          <span class="counter"><%= totalPackageCount %></span>
        </article>
      </section>

      <!-- 실시간 통계 섹션 -->
      <section class="admin-statistics" style="margin-top: 2rem;">
        <header style="margin-bottom: 1.5rem;">
          <h2>실시간 판매 통계</h2>
          <p>최근 30일간의 판매 현황을 실시간으로 확인합니다.</p>
        </header>
        <div class="admin-grid">
          <article id="statTotalOrders">
            <h2>총 주문 수</h2>
            <p>최근 30일간</p>
            <span class="counter" id="statTotalOrdersValue">-</span>
          </article>
          <article id="statTotalRevenue">
            <h2>총 매출</h2>
            <p>최근 30일간</p>
            <span class="counter" id="statTotalRevenueValue">-</span>
          </article>
          <article id="statAvgOrderValue">
            <h2>평균 주문 금액</h2>
            <p>최근 30일간</p>
            <span class="counter" id="statAvgOrderValueValue">-</span>
          </article>
        </div>
      </section>

      <!-- 실시간 알림 영역 -->
      <div id="orderNotification" class="order-notification" style="display: none;" role="alert" aria-live="polite">
        <div class="notification-content">
          <span class="notification-icon">🔔</span>
          <div class="notification-text">
            <strong>새로운 주문이 발생했습니다!</strong>
            <span id="notificationOrderInfo"></span>
          </div>
          <button class="notification-close" onclick="closeNotification()" aria-label="알림 닫기">×</button>
        </div>
      </div>

      <!-- 최근 주문 섹션 -->
      <section class="admin-recent-orders" style="margin-top: 2rem;">
        <header style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem;">
          <div>
            <h2>최근 주문 내역</h2>
            <p>실시간으로 업데이트되는 최근 주문 정보입니다.</p>
          </div>
          <div style="display: flex; align-items: center; gap: 10px;">
            <span id="lastUpdateTime" class="last-update-time" style="font-size: 0.875rem; color: var(--text-secondary);"></span>
            <button id="refreshOrdersBtn" class="btn" onclick="loadRecentOrders()" style="padding: 8px 16px;">
              <span>🔄</span> 새로고침
            </button>
          </div>
        </header>
        <div id="recentOrdersContainer" class="recent-orders-container">
          <div class="loading-spinner" style="text-align: center; padding: 2rem;">
            <p>주문 정보를 불러오는 중...</p>
          </div>
        </div>
      </section>

      <section class="admin-notice">
        <h2>빠른 링크</h2>
        <div style="display: flex; gap: 10px; flex-wrap: wrap;">
          <a class="btn primary" href="/AI/admin/statistics/index.jsp">판매 통계 보기</a>
          <a class="btn" href="/AI/admin/packages/index.jsp">패키지 관리</a>
          <a class="btn" href="/AI/admin/models/index.jsp">모델 관리</a>
          <% if (isSuperadmin) { %>
            <a class="btn" href="/AI/admin/admins/index.jsp">관리자 관리</a>
          <% } %>
        </div>
      </section>

      <% if (isSuperadmin) { %>
        <section class="admin-superadmin-panel" style="margin-top: 2rem; background: var(--glass-bg); backdrop-filter: blur(20px); border: 1px solid var(--glass-border); border-radius: var(--radius-xl); padding: var(--spacing-xl);">
          <header>
            <h2>Superadmin 요청 대기열</h2>
            <p>로그인 직후의 관리자 생성 요청을 여기서 승인하거나 거절하세요.</p>
          </header>
          <div id="superadminQueueFeedback" class="admin-queue-feedback" aria-live="polite"></div>
          <div class="admin-table-section" style="margin-top: 1.5rem;">
            <table class="admin-table">
              <thead>
                <tr>
                  <th>요청자</th>
                  <th>아이디</th>
                  <th>역할</th>
                  <th>권한</th>
                  <th>상태</th>
                  <th>액션</th>
                </tr>
              </thead>
              <tbody id="requestQueueBody"></tbody>
            </table>
            <p id="requestQueueEmpty" class="admin-queue-empty">현재 대기 중인 요청이 없습니다.</p>
          </div>
        </section>
      <% } %>

<%@ include file="/AI/admin/layout/footer.jspf" %>
