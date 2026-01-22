<%@ page contentType="text/html; charset=UTF-8" isELIgnored="true" %>
<%@ page import="dao.UserDAO" %>
<%@ page import="model.User" %>
<%@ page import="java.util.List" %>
<%
  if (session.getAttribute("admin") == null) {
    response.sendRedirect("/AI/admin/auth/login.jsp");
    return;
  }
  UserDAO userDAO = new UserDAO();
  List<User> users = userDAO.findAll();
%>
<%@ include file="/AI/admin/layout/header.jspf" %>
<div class="admin-layout">
  <%@ include file="/AI/admin/layout/sidebar.jspf" %>
  <div class="admin-main-wrapper">
    <%@ include file="/AI/admin/layout/topbar.jspf" %>
    <main class="admin-content">
      <header class="admin-dashboard-header">
        <div style="display: flex; justify-content: space-between; align-items: center;">
          <div>
            <h1>고객 관리</h1>
            <p>고객 정보를 조회하고 관리할 수 있습니다.</p>
          </div>
          <button type="button" class="btn primary" onclick="showCreateUserModal()">+ 고객 추가</button>
        </div>
      </header>
      <section class="admin-table-section">
        <table class="admin-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>이름</th>
              <th>이메일</th>
              <th>상태</th>
              <th>가입일</th>
              <th>마지막 로그인</th>
              <th>액션</th>
            </tr>
          </thead>
          <tbody>
            <% if (users.isEmpty()) { %>
              <tr><td colspan="7" style="text-align: center; padding: 40px;">등록된 고객이 없습니다.</td></tr>
            <% } else { %>
              <% for (User user : users) { %>
                <tr>
                  <td><%= user.getId() %></td>
                  <td><strong><%= user.getName() != null ? user.getName() : "-" %></strong></td>
                  <td><%= user.getEmail() != null ? user.getEmail() : "-" %></td>
                  <td>
                    <span class="badge <%= "ACTIVE".equals(user.getStatus()) ? "badge-success" : "badge-secondary" %>">
                      <%= user.getStatus() != null && user.getStatus().equals("ACTIVE") ? "활성" : "비활성" %>
                    </span>
                  </td>
                  <td>
                    <% if (user.getCreatedAt() != null) { %>
                      <%= new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(user.getCreatedAt()) %>
                    <% } else { %>
                      -
                    <% } %>
                  </td>
                  <td>
                    <% if (user.getLastLogin() != null) { %>
                      <%= new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(user.getLastLogin()) %>
                    <% } else { %>
                      로그인 없음
                    <% } %>
                  </td>
                  <td>
                    <div style="display: flex; gap: 8px;">
                      <button type="button" class="btn btn-sm" onclick="showUserDetail(<%= user.getId() %>)">상세보기</button>
                      <button type="button" class="btn btn-sm" onclick="showEditUserModal(<%= user.getId() %>, '<%= user.getName() != null ? user.getName().replace("'", "\\'") : "" %>', '<%= user.getEmail() != null ? user.getEmail().replace("'", "\\'") : "" %>', '<%= user.getStatus() != null ? user.getStatus() : "ACTIVE" %>')">수정</button>
                      <button type="button" class="btn btn-sm" style="background: #ff3b30; color: white;" onclick="deleteUser(<%= user.getId() %>, '<%= user.getName() != null ? user.getName().replace("'", "\\'") : "고객" %>')">삭제</button>
                    </div>
                  </td>
                </tr>
              <% } %>
            <% } %>
          </tbody>
        </table>
      </section>
<%@ include file="/AI/admin/layout/footer.jspf" %>

<!-- 고객 생성 모달 -->
<div id="createUserModal" class="admin-modal" style="display: none;">
  <div class="admin-modal-overlay" onclick="closeCreateUserModal()"></div>
  <div class="admin-modal-content" style="max-width: 500px;">
    <div class="admin-modal-header">
      <h2>고객 추가</h2>
      <button type="button" class="admin-modal-close" onclick="closeCreateUserModal()" aria-label="닫기">×</button>
    </div>
    <div class="admin-modal-body">
      <form id="createUserForm" onsubmit="createUser(event)">
        <div class="form-group">
          <label for="createUserName">이름 *</label>
          <input type="text" id="createUserName" name="name" required maxlength="100">
        </div>
        <div class="form-group">
          <label for="createUserEmail">이메일 *</label>
          <input type="email" id="createUserEmail" name="email" required maxlength="255">
        </div>
        <div class="form-group">
          <label for="createUserPassword">비밀번호 *</label>
          <input type="password" id="createUserPassword" name="password" required minlength="8">
          <small style="color: var(--text-secondary); font-size: 12px;">최소 8자 이상</small>
        </div>
        <div class="form-group">
          <label for="createUserStatus">상태</label>
          <select id="createUserStatus" name="status">
            <option value="ACTIVE">활성</option>
            <option value="INACTIVE">비활성</option>
          </select>
        </div>
        <div style="display: flex; gap: 12px; margin-top: 24px;">
          <button type="submit" class="btn primary" style="flex: 1;">생성</button>
          <button type="button" class="btn secondary" onclick="closeCreateUserModal()" style="flex: 1;">취소</button>
        </div>
      </form>
    </div>
  </div>
</div>

<!-- 고객 수정 모달 -->
<div id="editUserModal" class="admin-modal" style="display: none;">
  <div class="admin-modal-overlay" onclick="closeEditUserModal()"></div>
  <div class="admin-modal-content" style="max-width: 500px;">
    <div class="admin-modal-header">
      <h2>고객 수정</h2>
      <button type="button" class="admin-modal-close" onclick="closeEditUserModal()" aria-label="닫기">×</button>
    </div>
    <div class="admin-modal-body">
      <form id="editUserForm" onsubmit="updateUser(event)">
        <input type="hidden" id="editUserId" name="userId">
        <div class="form-group">
          <label for="editUserName">이름 *</label>
          <input type="text" id="editUserName" name="name" required maxlength="100">
        </div>
        <div class="form-group">
          <label for="editUserEmail">이메일 *</label>
          <input type="email" id="editUserEmail" name="email" required maxlength="255">
        </div>
        <div class="form-group">
          <label for="editUserStatus">상태</label>
          <select id="editUserStatus" name="status">
            <option value="ACTIVE">활성</option>
            <option value="INACTIVE">비활성</option>
          </select>
        </div>
        <div style="display: flex; gap: 12px; margin-top: 24px;">
          <button type="submit" class="btn primary" style="flex: 1;">수정</button>
          <button type="button" class="btn secondary" onclick="closeEditUserModal()" style="flex: 1;">취소</button>
        </div>
      </form>
    </div>
  </div>
</div>

<!-- 고객 상세 정보 팝업 모달 -->
<div id="userDetailModal" class="admin-modal" style="display: none;">
  <div class="admin-modal-overlay" onclick="closeUserDetailModal()"></div>
  <div class="admin-modal-content" style="max-width: 900px; max-height: 90vh; overflow-y: auto;">
    <div class="admin-modal-header">
      <h2>고객 상세 정보</h2>
      <button type="button" class="admin-modal-close" onclick="closeUserDetailModal()" aria-label="닫기">×</button>
    </div>
    <div class="admin-modal-body" id="userDetailContent">
      <div style="text-align: center; padding: 40px;">
        <div class="loading-spinner"></div>
        <p style="margin-top: 16px; color: var(--text-secondary);">로딩 중...</p>
      </div>
    </div>
  </div>
</div>

<style>
.admin-modal {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: 10000;
  display: flex;
  align-items: center;
  justify-content: center;
}

.admin-modal-overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.7);
  backdrop-filter: blur(4px);
}

.admin-modal-content {
  position: relative;
  background: var(--bg-secondary);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-xl);
  width: 90%;
  max-width: 900px;
  max-height: 90vh;
  overflow-y: auto;
  z-index: 10001;
}

.admin-modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 24px 32px;
  border-bottom: 1px solid var(--glass-border);
}

.admin-modal-header h2 {
  margin: 0;
  font-size: 24px;
  font-weight: 600;
  color: var(--text-primary);
}

.admin-modal-close {
  background: none;
  border: none;
  font-size: 32px;
  color: var(--text-secondary);
  cursor: pointer;
  padding: 0;
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: var(--radius-sm);
  transition: all 0.2s ease;
}

.admin-modal-close:hover {
  background: var(--glass-hover);
  color: var(--text-primary);
}

.admin-modal-body {
  padding: 32px;
}

.loading-spinner {
  width: 40px;
  height: 40px;
  border: 3px solid var(--glass-border);
  border-top-color: var(--accent-primary);
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
  margin: 0 auto;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}
</style>

<script>
async function showUserDetail(userId) {
  const modal = document.getElementById('userDetailModal');
  const content = document.getElementById('userDetailContent');
  
  if (!modal || !content) return;
  
  // 모달에 userId 저장 (삭제 후 재로드용)
  modal.dataset.userId = userId;
  
  // 모달 표시
  modal.style.display = 'flex';
  document.body.style.overflow = 'hidden';
  
  // 로딩 표시
  content.innerHTML = `
    <div style="text-align: center; padding: 40px;">
      <div class="loading-spinner"></div>
      <p style="margin-top: 16px; color: var(--text-secondary);">로딩 중...</p>
    </div>
  `;
  
  try {
    const response = await fetch('/AI/api/user-detail.jsp?userId=' + userId);
    if (!response.ok) {
      throw new Error('서버 오류: ' + response.status);
    }
    
    const data = await response.json();
    
    if (data.error) {
      content.innerHTML = `
        <div style="text-align: center; padding: 40px;">
          <p style="color: var(--error); margin-bottom: 16px;">오류 발생</p>
          <p style="color: var(--text-secondary);">${escapeHtml(data.error)}</p>
        </div>
      `;
      return;
    }
    
    const user = data.user;
    const orders = data.orders || [];
    const subscriptions = data.subscriptions || [];
    
    // 상태 관련 변수 계산 (JSP EL 충돌 방지)
    const userStatusClass = user.status == 'ACTIVE' ? 'badge-success' : 'badge-secondary';
    const userStatusText = user.status == 'ACTIVE' ? '활성' : '비활성';
    
    // 고객 정보 HTML
    let userInfoHtml = `
      <section style="margin-bottom: 32px;">
        <h3 style="margin-bottom: 16px; font-size: 20px; font-weight: 600; color: var(--text-primary);">고객 정보</h3>
        <div class="glass-card" style="padding: 24px;">
          <table style="width: 100%; border-collapse: collapse;">
            <tr>
              <td style="padding: 12px; width: 150px; font-weight: 600; color: var(--text-secondary);">ID</td>
              <td style="padding: 12px; color: var(--text-primary);">` + user.id + `</td>
            </tr>
            <tr>
              <td style="padding: 12px; font-weight: 600; color: var(--text-secondary);">이름</td>
              <td style="padding: 12px; color: var(--text-primary);">` + escapeHtml(user.name || '-') + `</td>
            </tr>
            <tr>
              <td style="padding: 12px; font-weight: 600; color: var(--text-secondary);">이메일</td>
              <td style="padding: 12px; color: var(--text-primary);">` + escapeHtml(user.email || '-') + `</td>
            </tr>
            <tr>
              <td style="padding: 12px; font-weight: 600; color: var(--text-secondary);">상태</td>
              <td style="padding: 12px;">
                <span class="badge ` + userStatusClass + `">
                  ` + userStatusText + `
                </span>
              </td>
            </tr>
            <tr>
              <td style="padding: 12px; font-weight: 600; color: var(--text-secondary);">가입일</td>
              <td style="padding: 12px; color: var(--text-primary);">` + (user.createdAt || '-') + `</td>
            </tr>
            <tr>
              <td style="padding: 12px; font-weight: 600; color: var(--text-secondary);">마지막 로그인</td>
              <td style="padding: 12px; color: var(--text-primary);">` + (user.lastLogin || '로그인 없음') + `</td>
            </tr>
          </table>
        </div>
      </section>
    `;
    
    // 구독 내역 HTML
    let subscriptionsHtml = '';
    if (subscriptions.length > 0) {
      subscriptionsHtml = `
        <section style="margin-bottom: 32px;">
          <h3 style="margin-bottom: 16px; font-size: 20px; font-weight: 600; color: var(--text-primary);">구독 내역</h3>
          <table class="admin-table">
            <thead>
              <tr>
                <th>구독 ID</th>
                <th>요금제</th>
                <th>시작일</th>
                <th>종료일</th>
                <th>상태</th>
                <th>결제 방법</th>
                <th>액션</th>
              </tr>
            </thead>
            <tbody>
              ` + subscriptions.map(sub => {
                const plan = sub.plan || {};
                const statusClass = sub.status == 'ACTIVE' ? 'badge-success' : 'badge-secondary';
                const planName = escapeHtml(plan.name || sub.planCode || '-');
                const durationText = plan.durationMonths ? '(' + plan.durationMonths + '개월)' : '';
                const statusText = sub.status || '-';
                const paymentMethod = escapeHtml(sub.paymentMethod || '-');
                return `
                  <tr>
                    <td>` + sub.id + `</td>
                    <td>
                      <strong>` + planName + `</strong>
                      ` + durationText + `
                    </td>
                    <td>` + (sub.startDate || '-') + `</td>
                    <td>` + (sub.endDate || '-') + `</td>
                    <td>
                      <span class="badge ` + statusClass + `">
                        ` + statusText + `
                      </span>
                    </td>
                    <td>` + paymentMethod + `</td>
                    <td>
                      <div style="display: flex; gap: 4px;">
                        <button type="button" class="btn btn-sm" onclick="showEditSubscriptionModal(` + sub.id + `, \`` + escapeHtml(JSON.stringify(sub).replace(/`/g, '\\`')) + `\`)">수정</button>
                        <button type="button" class="btn btn-sm danger" onclick="deleteSubscription(` + sub.id + `, \`` + escapeHtml(planName).replace(/`/g, '\\`') + `\`)">삭제</button>
                      </div>
                    </td>
                  </tr>
                `;
              }).join('') + `
            </tbody>
          </table>
        </section>
      `;
    } else {
      subscriptionsHtml = `
        <section style="margin-bottom: 32px;">
          <h3 style="margin-bottom: 16px; font-size: 20px; font-weight: 600; color: var(--text-primary);">구독 내역</h3>
          <div class="glass-card" style="padding: 40px; text-align: center;">
            <p style="color: var(--text-secondary);">구독 내역이 없습니다.</p>
          </div>
        </section>
      `;
    }
    
    // 구매 내역 HTML
    let ordersHtml = '';
    if (orders.length > 0) {
      ordersHtml = `
        <section>
          <h3 style="margin-bottom: 16px; font-size: 20px; font-weight: 600; color: var(--text-primary);">구매 내역</h3>
          ${orders.map(order => {
            const items = order.items || [];
            return `
              <div class="glass-card" style="padding: 24px; margin-bottom: 24px;">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
                  <div>
                    <h4 style="margin: 0 0 8px 0; font-size: 18px; font-weight: 600; color: var(--text-primary);">주문 #${order.id}</h4>
                    <p style="margin: 0; color: var(--text-secondary); font-size: 14px;">
                      주문일: ${order.createdAt ? order.createdAt.substring(0, 19) : '-'} | 
                      결제 방법: ${escapeHtml(order.paymentMethod || '-')} |
                      상태: <span class="badge badge-success">${order.orderStatus || '-'}</span>
                    </p>
                  </div>
                  <div style="text-align: right;">
                    <p style="margin: 0; font-size: 24px; font-weight: 600; color: var(--accent-primary);">
                      $${order.totalPrice ? order.totalPrice.toFixed(2) : '0.00'}
                    </p>
                    <div style="display: flex; gap: 4px; justify-content: flex-end; margin-top: 8px;">
                      <button type="button" class="btn btn-sm" onclick="showEditOrderModal(${order.id}, \`` + escapeHtml(JSON.stringify(order).replace(/`/g, '\\`')) + `\`)">수정</button>
                      <button type="button" class="btn btn-sm danger" data-order-id="${order.id || ''}" onclick="deleteOrderFromButton(this)">삭제</button>
                    </div>
                  </div>
                </div>
                
                ${items.length > 0 ? `
                  <table style="width: 100%; border-collapse: collapse; margin-top: 16px;">
                    <thead>
                      <tr style="border-bottom: 1px solid var(--glass-border);">
                        <th style="padding: 12px; text-align: left; color: var(--text-secondary); font-weight: 600;">타입</th>
                        <th style="padding: 12px; text-align: left; color: var(--text-secondary); font-weight: 600;">아이템</th>
                        <th style="padding: 12px; text-align: right; color: var(--text-secondary); font-weight: 600;">수량</th>
                        <th style="padding: 12px; text-align: right; color: var(--text-secondary); font-weight: 600;">단가</th>
                        <th style="padding: 12px; text-align: right; color: var(--text-secondary); font-weight: 600;">소계</th>
                      </tr>
                    </thead>
                    <tbody>
                      ` + items.map(item => {
                        const itemType = item.itemType || '';
                        const subtotal = (item.price || 0) * (item.quantity || 1);
                        const itemTypeText = itemType == 'PACKAGE' ? '패키지' : '모델';
                        const itemName = escapeHtml(item.itemName || '-');
                        const quantity = item.quantity || 1;
                        const price = (item.price || 0).toFixed(2);
                        const subtotalFormatted = subtotal.toFixed(2);
                        return `
                          <tr style="border-bottom: 1px solid var(--glass-border);">
                            <td style="padding: 12px;">
                              <span class="badge badge-info">` + itemTypeText + `</span>
                            </td>
                            <td style="padding: 12px; color: var(--text-primary);">` + itemName + `</td>
                            <td style="padding: 12px; text-align: right; color: var(--text-primary);">` + quantity + `</td>
                            <td style="padding: 12px; text-align: right; color: var(--text-primary);">$` + price + `</td>
                            <td style="padding: 12px; text-align: right; font-weight: 600; color: var(--text-primary);">
                              $` + subtotalFormatted + `
                            </td>
                          </tr>
                        `;
                      }).join('') + `
                    </tbody>
                    <tfoot>
                      <tr>
                        <td colspan="4" style="padding: 12px; text-align: right; font-weight: 600; color: var(--text-secondary);">총계</td>
                        <td style="padding: 12px; text-align: right; font-weight: 600; font-size: 18px; color: var(--accent-primary);">
                          $${order.totalPrice ? order.totalPrice.toFixed(2) : '0.00'}
                        </td>
                      </tr>
                    </tfoot>
                  </table>
                ` : '<p style="color: var(--text-secondary); margin-top: 16px;">주문 아이템이 없습니다.</p>'}
              </div>
            `;
          }).join('')}
        </section>
      `;
    } else {
      ordersHtml = `
        <section>
          <h3 style="margin-bottom: 16px; font-size: 20px; font-weight: 600; color: var(--text-primary);">구매 내역</h3>
          <div class="glass-card" style="padding: 40px; text-align: center;">
            <p style="color: var(--text-secondary);">구매 내역이 없습니다.</p>
          </div>
        </section>
      `;
    }
    
    content.innerHTML = userInfoHtml + subscriptionsHtml + ordersHtml;
    
  } catch (error) {
    console.error('고객 상세 정보 로드 오류:', error);
    content.innerHTML = `
      <div style="text-align: center; padding: 40px;">
        <p style="color: var(--error); margin-bottom: 16px;">오류 발생</p>
        <p style="color: var(--text-secondary);">고객 정보를 불러오는 중 오류가 발생했습니다.</p>
        <p style="color: var(--text-secondary); font-size: 14px; margin-top: 8px;">${escapeHtml(error.message)}</p>
      </div>
    `;
  }
}

function closeUserDetailModal() {
  const modal = document.getElementById('userDetailModal');
  if (modal) {
    modal.style.display = 'none';
    document.body.style.overflow = '';
  }
}

function escapeHtml(text) {
  if (!text) return '';
  const div = document.createElement('div');
  div.textContent = text;
  return div.innerHTML;
}

// ESC 키로 모달 닫기
document.addEventListener('keydown', function(e) {
  if (e.key === 'Escape') {
    closeUserDetailModal();
    closeCreateUserModal();
    closeEditUserModal();
  }
});

// 고객 생성 모달
function showCreateUserModal() {
  const modal = document.getElementById('createUserModal');
  if (modal) {
    modal.style.display = 'flex';
    document.body.style.overflow = 'hidden';
    document.getElementById('createUserForm').reset();
  }
}

function closeCreateUserModal() {
  const modal = document.getElementById('createUserModal');
  if (modal) {
    modal.style.display = 'none';
    document.body.style.overflow = '';
  }
}

// 고객 수정 모달
function showEditUserModal(userId, name, email, status) {
  const modal = document.getElementById('editUserModal');
  if (modal) {
    modal.style.display = 'flex';
    document.body.style.overflow = 'hidden';
    document.getElementById('editUserId').value = userId;
    document.getElementById('editUserName').value = name || '';
    document.getElementById('editUserEmail').value = email || '';
    document.getElementById('editUserStatus').value = status || 'ACTIVE';
  }
}

function closeEditUserModal() {
  const modal = document.getElementById('editUserModal');
  if (modal) {
    modal.style.display = 'none';
    document.body.style.overflow = '';
  }
}

// 고객 생성
async function createUser(event) {
  event.preventDefault();
  const form = event.target;
  const formData = new FormData(form);
  
  try {
    const response = await fetch('/AI/api/user-create.jsp', {
      method: 'POST',
      body: formData
    });
    
    const data = await response.json();
    
    if (data.success) {
      alert('고객이 성공적으로 생성되었습니다.');
      closeCreateUserModal();
      location.reload();
    } else {
      alert('오류: ' + (data.error || '고객 생성에 실패했습니다.'));
    }
  } catch (error) {
    console.error('Create user error:', error);
    alert('고객 생성 중 오류가 발생했습니다.');
  }
}

// 고객 수정
async function updateUser(event) {
  event.preventDefault();
  const form = event.target;
  const formData = new FormData(form);
  
  try {
    const response = await fetch('/AI/api/user-update.jsp', {
      method: 'POST',
      body: formData
    });
    
    const data = await response.json();
    
    if (data.success) {
      alert('고객 정보가 성공적으로 수정되었습니다.');
      closeEditUserModal();
      location.reload();
    } else {
      alert('오류: ' + (data.error || '고객 수정에 실패했습니다.'));
    }
  } catch (error) {
    console.error('Update user error:', error);
    alert('고객 수정 중 오류가 발생했습니다.');
  }
}

// 고객 삭제
async function deleteUser(userId, userName) {
  if (!confirm('정말로 "' + userName + '" 고객을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.')) {
    return;
  }
  
  try {
    const response = await fetch('/AI/api/user-delete.jsp', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: 'userId=' + userId
    });
    
    const data = await response.json();
    
    if (data.success) {
      alert('고객이 성공적으로 삭제되었습니다.');
      location.reload();
    } else {
      alert('오류: ' + (data.error || '고객 삭제에 실패했습니다.'));
    }
  } catch (error) {
    console.error('Delete user error:', error);
    alert('고객 삭제 중 오류가 발생했습니다.');
  }
}

// 구독 수정 모달
function showEditSubscriptionModal(subscriptionId, subscriptionJson) {
  try {
    const sub = JSON.parse(subscriptionJson);
    alert('구독 수정 기능은 준비 중입니다.\n구독 ID: ' + subscriptionId + '\n요금제: ' + (sub.planCode || '-'));
    // TODO: 구독 수정 모달 구현
  } catch (error) {
    console.error('Error parsing subscription:', error);
    alert('구독 정보를 불러오는 중 오류가 발생했습니다.');
  }
}

// 구독 삭제
async function deleteSubscription(subscriptionId, planName) {
  // subscriptionId를 숫자로 확실히 변환
  let numericSubscriptionId;
  if (typeof subscriptionId === 'string') {
    numericSubscriptionId = parseInt(subscriptionId.trim(), 10);
  } else if (typeof subscriptionId === 'number') {
    numericSubscriptionId = subscriptionId;
  } else {
    numericSubscriptionId = parseInt(String(subscriptionId).trim(), 10);
  }
  
  if (isNaN(numericSubscriptionId) || numericSubscriptionId <= 0) {
    console.error('Invalid subscription ID:', subscriptionId, 'type:', typeof subscriptionId);
    alert('유효하지 않은 구독 ID입니다: ' + subscriptionId);
    return;
  }
  
  if (!confirm('정말로 "' + planName + '" 구독을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.')) {
    return;
  }
  
  console.log('Deleting subscription with ID:', numericSubscriptionId);
  
  try {
    const response = await fetch('/AI/api/subscription-delete.jsp', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ id: numericSubscriptionId })
    });
    
    if (!response.ok) {
      const errorText = await response.text();
      console.error('Subscription delete response error:', response.status, errorText);
      try {
        const errorData = JSON.parse(errorText);
        alert('오류: ' + (errorData.error || '구독 삭제에 실패했습니다.'));
      } catch (e) {
        alert('구독 삭제 중 오류가 발생했습니다. (상태 코드: ' + response.status + ')');
      }
      return;
    }
    
    const data = await response.json();
    
    if (data.success) {
      alert('구독이 성공적으로 삭제되었습니다.');
      // 모달을 닫고 다시 열어서 최신 정보 표시
      const userId = document.getElementById('userDetailModal').dataset.userId;
      if (userId) {
        closeUserDetailModal();
        setTimeout(() => showUserDetail(userId), 100);
      } else {
        location.reload();
      }
    } else {
      alert('오류: ' + (data.error || '구독 삭제에 실패했습니다.'));
    }
  } catch (error) {
    console.error('Delete subscription error:', error);
    alert('구독 삭제 중 오류가 발생했습니다: ' + (error.message || error.toString()));
  }
}

// 주문 수정 모달
function showEditOrderModal(orderId, orderJson) {
  try {
    const order = JSON.parse(orderJson);
    alert('주문 수정 기능은 준비 중입니다.\n주문 ID: ' + orderId + '\n주문자: ' + (order.customerName || '-'));
    // TODO: 주문 수정 모달 구현
  } catch (error) {
    console.error('Error parsing order:', error);
    alert('주문 정보를 불러오는 중 오류가 발생했습니다.');
  }
}

// 주문 삭제 (버튼에서 호출)
async function deleteOrderFromButton(button) {
  const orderId = button.getAttribute('data-order-id');
  if (!orderId || orderId.trim() === '') {
    alert('주문 ID를 찾을 수 없습니다.');
    return;
  }
  await deleteOrder(orderId, orderId);
}

// 주문 삭제
async function deleteOrder(orderId, orderNumber) {
  // orderId를 숫자로 확실히 변환
  let numericOrderId;
  if (typeof orderId === 'string') {
    numericOrderId = parseInt(orderId.trim(), 10);
  } else if (typeof orderId === 'number') {
    numericOrderId = orderId;
  } else {
    numericOrderId = parseInt(String(orderId).trim(), 10);
  }
  
  if (isNaN(numericOrderId) || numericOrderId <= 0) {
    console.error('Invalid order ID:', orderId, 'type:', typeof orderId);
    alert('유효하지 않은 주문 ID입니다: ' + orderId);
    return;
  }
  
  if (!confirm('정말로 주문 #' + (orderNumber || numericOrderId) + '을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.')) {
    return;
  }
  
  console.log('Deleting order with ID:', numericOrderId);
  
  try {
    const response = await fetch('/AI/api/order-delete.jsp', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ id: numericOrderId })
    });
    
    if (!response.ok) {
      const errorText = await response.text();
      console.error('Order delete response error:', response.status, errorText);
      try {
        const errorData = JSON.parse(errorText);
        alert('오류: ' + (errorData.error || '주문 삭제에 실패했습니다.'));
      } catch (e) {
        alert('주문 삭제 중 오류가 발생했습니다. (상태 코드: ' + response.status + ')');
      }
      return;
    }
    
    const data = await response.json();
    
    if (data.success) {
      alert('주문이 성공적으로 삭제되었습니다.');
      // 모달을 닫고 다시 열어서 최신 정보 표시
      const userId = document.getElementById('userDetailModal').dataset.userId;
      if (userId) {
        closeUserDetailModal();
        setTimeout(() => showUserDetail(userId), 100);
      } else {
        location.reload();
      }
    } else {
      alert('오류: ' + (data.error || '주문 삭제에 실패했습니다.'));
    }
  } catch (error) {
    console.error('Delete order error:', error);
    alert('주문 삭제 중 오류가 발생했습니다: ' + error.message);
  }
}
</script>

