<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="db.DBConnect" %>
<%
  if (session.getAttribute("admin") == null) {
    response.sendRedirect("/AI/admin/auth/login.jsp");
    return;
  }

  // 필터 파라미터
  String filterStatus = request.getParameter("status");
  String filterSearch = request.getParameter("search");
  if (filterStatus == null) filterStatus = "";
  if (filterSearch == null) filterSearch = "";

  // 통계
  int totalOrders = 0, completedOrders = 0, pendingOrders = 0, cancelledOrders = 0;
  double totalRevenue = 0.0;
  try (Connection c = DBConnect.getConnection()) {
    try (PreparedStatement ps = c.prepareStatement(
         "SELECT order_status, COUNT(*), COALESCE(SUM(total_price),0) FROM orders GROUP BY order_status");
         ResultSet rs = ps.executeQuery()) {
      while (rs.next()) {
        String s = rs.getString(1);
        int cnt = rs.getInt(2);
        double rev = rs.getDouble(3);
        totalOrders += cnt;
        totalRevenue += rev;
        if ("COMPLETED".equals(s)) { completedOrders = cnt; }
        else if ("PENDING".equals(s)) { pendingOrders = cnt; }
        else if ("CANCELLED".equals(s)) { cancelledOrders = cnt; }
      }
    }
  } catch (Exception e) { /* 기본값 */ }
%>
<%@ include file="/AI/admin/layout/header.jspf" %>
<div class="admin-layout">
  <%@ include file="/AI/admin/layout/sidebar.jspf" %>
  <div class="admin-main-wrapper">
    <%@ include file="/AI/admin/layout/topbar.jspf" %>
    <main class="admin-content">

      <header class="admin-dashboard-header" style="margin-bottom:2rem;">
        <h1>주문 관리</h1>
        <p>사용자 결제 내역을 확인하고 관리합니다.</p>
      </header>

      <!-- 통계 카드 -->
      <section class="kpi-grid" style="margin-bottom:2rem;">
        <article class="kpi-card kpi-orders">
          <div class="kpi-icon"><i class="bi bi-receipt-cutoff"></i></div>
          <div class="kpi-body">
            <span class="kpi-label">전체 주문</span>
            <span class="kpi-value"><%= totalOrders %></span>
            <span class="kpi-desc">누적 주문 건수</span>
          </div>
        </article>
        <article class="kpi-card kpi-revenue">
          <div class="kpi-icon"><i class="bi bi-currency-dollar"></i></div>
          <div class="kpi-body">
            <span class="kpi-label">총 매출</span>
            <span class="kpi-value kpi-value-sm">$<%= String.format("%,.0f", totalRevenue) %></span>
            <span class="kpi-desc">누적 결제 금액</span>
          </div>
        </article>
        <article class="kpi-card kpi-lab">
          <div class="kpi-icon"><i class="bi bi-check-circle-fill"></i></div>
          <div class="kpi-body">
            <span class="kpi-label">완료</span>
            <span class="kpi-value"><%= completedOrders %></span>
            <span class="kpi-desc">결제 완료 건수</span>
          </div>
        </article>
        <article class="kpi-card kpi-category">
          <div class="kpi-icon"><i class="bi bi-clock-history"></i></div>
          <div class="kpi-body">
            <span class="kpi-label">대기 중</span>
            <span class="kpi-value"><%= pendingOrders %></span>
            <span class="kpi-desc">처리 대기 건수</span>
          </div>
        </article>
      </section>

      <!-- 필터 -->
      <section style="margin-bottom:1.5rem;background:var(--glass-bg);backdrop-filter:blur(20px);border:1px solid var(--glass-border);border-radius:var(--radius-xl);padding:1.25rem var(--spacing-xl);">
        <form method="get" style="display:flex;gap:1rem;flex-wrap:wrap;align-items:flex-end;">
          <div style="flex:1;min-width:200px;">
            <label style="font-size:.8rem;color:var(--text-secondary);margin-bottom:.4rem;display:block;">검색 (이름/이메일)</label>
            <input type="text" name="search" value="<%= filterSearch %>" placeholder="고객명 또는 이메일..." style="width:100%;background:var(--input-bg);border:1px solid var(--border);color:var(--text);border-radius:8px;padding:8px 12px;font-size:.9rem;">
          </div>
          <div>
            <label style="font-size:.8rem;color:var(--text-secondary);margin-bottom:.4rem;display:block;">상태</label>
            <select name="status" style="background:var(--input-bg);border:1px solid var(--border);color:var(--text);border-radius:8px;padding:8px 12px;font-size:.9rem;">
              <option value="" <%= "".equals(filterStatus) ? "selected" : "" %>>전체</option>
              <option value="PENDING" <%= "PENDING".equals(filterStatus) ? "selected" : "" %>>대기 중</option>
              <option value="COMPLETED" <%= "COMPLETED".equals(filterStatus) ? "selected" : "" %>>완료</option>
              <option value="CANCELLED" <%= "CANCELLED".equals(filterStatus) ? "selected" : "" %>>취소</option>
            </select>
          </div>
          <div style="display:flex;gap:.5rem;">
            <button type="submit" class="btn btn-primary" style="padding:8px 20px;">검색</button>
            <a href="/AI/admin/orders/index.jsp" class="btn" style="padding:8px 16px;">초기화</a>
          </div>
        </form>
      </section>

      <!-- 주문 목록 -->
      <section style="background:var(--glass-bg);backdrop-filter:blur(20px);border:1px solid var(--glass-border);border-radius:var(--radius-xl);padding:var(--spacing-xl);">
        <div class="admin-table-section">
          <table class="admin-table">
            <thead>
              <tr>
                <th>주문번호</th>
                <th>고객명</th>
                <th>이메일</th>
                <th>연락처</th>
                <th>결제금액</th>
                <th>결제수단</th>
                <th>상태</th>
                <th>주문일시</th>
                <th>액션</th>
              </tr>
            </thead>
            <tbody>
              <%
                StringBuilder sqlSb = new StringBuilder(
                  "SELECT id, customer_name, customer_email, customer_phone, total_price, payment_method, order_status, created_at FROM orders WHERE 1=1");
                if (!filterStatus.isEmpty()) sqlSb.append(" AND order_status = ?");
                if (!filterSearch.isEmpty()) sqlSb.append(" AND (customer_name LIKE ? OR customer_email LIKE ?)");
                sqlSb.append(" ORDER BY created_at DESC");

                try (Connection cList = DBConnect.getConnection();
                     PreparedStatement psList = cList.prepareStatement(sqlSb.toString())) {
                  int paramIdx = 1;
                  if (!filterStatus.isEmpty()) psList.setString(paramIdx++, filterStatus);
                  if (!filterSearch.isEmpty()) {
                    String like = "%" + filterSearch + "%";
                    psList.setString(paramIdx++, like);
                    psList.setString(paramIdx++, like);
                  }
                  ResultSet rsList = psList.executeQuery();
                  int rowCount = 0;
                  while (rsList.next()) {
                    rowCount++;
                    String st = rsList.getString("order_status");
                    String stClass = "COMPLETED".equals(st) ? "status-active" : "PENDING".equals(st) ? "status-pending" : "status-inactive";
                    String stLabel = "COMPLETED".equals(st) ? "완료" : "PENDING".equals(st) ? "대기" : "CANCELLED".equals(st) ? "취소" : (st != null ? st : "-");
                    String createdAt = rsList.getString("created_at");
                    String createdAtDisplay = (createdAt != null && createdAt.length() >= 16) ? createdAt.substring(0, 16) : (createdAt != null ? createdAt : "-");
              %>
              <tr>
                <td><strong>#<%= rsList.getInt("id") %></strong></td>
                <td><%= rsList.getString("customer_name") != null ? rsList.getString("customer_name") : "-" %></td>
                <td style="font-size:.82rem;color:var(--text-secondary);"><%= rsList.getString("customer_email") != null ? rsList.getString("customer_email") : "-" %></td>
                <td style="font-size:.82rem;"><%= rsList.getString("customer_phone") != null ? rsList.getString("customer_phone") : "-" %></td>
                <td><strong>$<%= rsList.getObject("total_price") != null ? String.format("%.2f", rsList.getDouble("total_price")) : "0.00" %></strong></td>
                <td><%= rsList.getString("payment_method") != null ? rsList.getString("payment_method") : "-" %></td>
                <td><span class="status-badge <%= stClass %>"><%= stLabel %></span></td>
                <td style="font-size:.82rem;color:var(--text-secondary);"><%= createdAtDisplay %></td>
                <td>
                  <div style="display:flex;gap:.4rem;flex-wrap:wrap;">
                    <% if ("PENDING".equals(st)) { %>
                    <button class="btn btn-sm btn-primary" onclick="updateOrder(<%= rsList.getInt("id") %>, 'COMPLETED')" style="padding:4px 10px;font-size:.78rem;">완료</button>
                    <button class="btn btn-sm" onclick="updateOrder(<%= rsList.getInt("id") %>, 'CANCELLED')" style="padding:4px 10px;font-size:.78rem;color:#ef4444;border-color:#ef4444;">취소</button>
                    <% } %>
                    <button class="btn btn-sm" onclick="deleteOrder(<%= rsList.getInt("id") %>)" style="padding:4px 10px;font-size:.78rem;opacity:.6;">삭제</button>
                  </div>
                </td>
              </tr>
              <%
                  }
                  if (rowCount == 0) {
              %>
              <tr><td colspan="9" style="text-align:center;color:var(--text-secondary);padding:3rem;">주문 내역이 없습니다.</td></tr>
              <% } rsList.close(); } catch (Exception eList) { %>
              <tr><td colspan="9" style="text-align:center;color:var(--text-secondary);padding:2rem;">데이터를 불러올 수 없습니다.</td></tr>
              <% } %>
            </tbody>
          </table>
        </div>
      </section>

    </main>
  </div>
</div>

<div id="orderFeedback" style="position:fixed;bottom:1.5rem;right:1.5rem;z-index:9999;display:none;"></div>

<script>
async function updateOrder(orderId, newStatus) {
  if (!confirm('주문 #' + orderId + ' 상태를 변경하시겠습니까?')) return;
  try {
    const res = await fetch('/AI/api/order-update.jsp', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ orderId: orderId, status: newStatus })
    });
    const data = await res.json();
    if (data.success) {
      showFeedback('주문 상태가 변경되었습니다.', 'success');
      setTimeout(() => location.reload(), 800);
    } else {
      showFeedback(data.error || '오류가 발생했습니다.', 'error');
    }
  } catch(e) {
    showFeedback('요청 처리 중 오류가 발생했습니다.', 'error');
  }
}

async function deleteOrder(orderId) {
  if (!confirm('주문 #' + orderId + '을(를) 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.')) return;
  try {
    const res = await fetch('/AI/api/order-delete.jsp', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ orderId: orderId })
    });
    const data = await res.json();
    if (data.success) {
      showFeedback('주문이 삭제되었습니다.', 'success');
      setTimeout(() => location.reload(), 800);
    } else {
      showFeedback(data.error || '오류가 발생했습니다.', 'error');
    }
  } catch(e) {
    showFeedback('요청 처리 중 오류가 발생했습니다.', 'error');
  }
}

function showFeedback(msg, type) {
  const el = document.getElementById('orderFeedback');
  el.textContent = msg;
  el.style.display = 'block';
  el.style.padding = '12px 20px';
  el.style.borderRadius = '8px';
  el.style.background = type === 'success' ? '#10b981' : '#ef4444';
  el.style.color = '#fff';
  el.style.fontWeight = '500';
  setTimeout(() => { el.style.display = 'none'; }, 2500);
}
</script>

<%@ include file="/AI/admin/layout/footer.jspf" %>
