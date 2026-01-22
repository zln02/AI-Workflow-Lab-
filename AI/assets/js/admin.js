/* ============================================
   AI Navigator Admin Panel - JavaScript
   ============================================ */

(function() {
  'use strict';

  // ===== Theme Toggle (Dark/Light Mode) =====
  const initThemeToggle = () => {
    const themeToggle = document.getElementById('themeToggle');
    const body = document.body;
    
    // Load saved theme from localStorage
    const savedTheme = localStorage.getItem('adminTheme') || 'dark';
    body.classList.toggle('light-mode', savedTheme === 'light');
    body.classList.toggle('dark-mode', savedTheme === 'dark');
    updateThemeIcon(savedTheme);
    
    if (themeToggle) {
      themeToggle.addEventListener('click', () => {
        const isLight = body.classList.contains('light-mode');
        const newTheme = isLight ? 'dark' : 'light';
        
        body.classList.toggle('light-mode', newTheme === 'light');
        body.classList.toggle('dark-mode', newTheme === 'dark');
        localStorage.setItem('adminTheme', newTheme);
        updateThemeIcon(newTheme);
      });
    }
  };
  
  const updateThemeIcon = (theme) => {
    const themeIcon = document.querySelector('.theme-icon');
    const themeText = document.querySelector('.theme-text');
    if (themeIcon) {
      themeIcon.textContent = theme === 'dark' ? '🌙' : '☀️';
    }
    if (themeText) {
      themeText.textContent = theme === 'dark' ? '다크모드' : '라이트모드';
    }
  };

  // ===== Sidebar Active State =====
  const initSidebarActive = () => {
    const currentPath = window.location.pathname;
    const sidebarItems = document.querySelectorAll('.sidebar-item');
    
    sidebarItems.forEach(item => {
      const itemPath = item.getAttribute('data-path') || item.getAttribute('href');
      if (itemPath && currentPath.includes(itemPath)) {
        item.classList.add('active');
      } else {
        item.classList.remove('active');
      }
    });
  };

  // ===== Mobile Sidebar Toggle =====
  const initMobileSidebar = () => {
    const sidebar = document.getElementById('adminSidebar');
    const sidebarToggle = document.getElementById('sidebarToggle');
    const mobileMenuToggle = document.getElementById('mobileMenuToggle');
    const sidebarOverlay = document.getElementById('sidebarOverlay');
    
    const toggleSidebar = () => {
      sidebar?.classList.toggle('active');
      sidebarOverlay?.classList.toggle('active');
      document.body.style.overflow = sidebar?.classList.contains('active') ? 'hidden' : '';
    };
    
    const closeSidebar = () => {
      sidebar?.classList.remove('active');
      sidebarOverlay?.classList.remove('active');
      document.body.style.overflow = '';
    };
    
    sidebarToggle?.addEventListener('click', toggleSidebar);
    mobileMenuToggle?.addEventListener('click', toggleSidebar);
    sidebarOverlay?.addEventListener('click', closeSidebar);
    
    // Close sidebar on window resize (desktop)
    window.addEventListener('resize', () => {
      if (window.innerWidth > 1024) {
        closeSidebar();
      }
    });
  };

  // ===== Search Functionality =====
  const initSearch = () => {
    const searchInput = document.getElementById('searchInput');
    if (!searchInput) return;
    
    let searchTimeout;
    searchInput.addEventListener('input', (e) => {
      clearTimeout(searchTimeout);
      const query = e.target.value.trim();
      
      if (query.length > 2) {
        searchTimeout = setTimeout(() => {
          // Search functionality
        }, 300);
      }
    });
    
    // Search on Enter key
    searchInput.addEventListener('keypress', (e) => {
      if (e.key === 'Enter') {
        e.preventDefault();
        const query = e.target.value.trim();
        if (query) {
          // Navigate to search results or filter current page
        }
      }
    });
  };

  // ===== Counter Animation =====
  const animateCounter = (element, target, duration = 2000) => {
    if (!element) return;
    
    const start = 0;
    const increment = target / (duration / 16);
    let current = start;
    
    const updateCounter = () => {
      current += increment;
      if (current < target) {
        element.textContent = Math.floor(current);
        requestAnimationFrame(updateCounter);
      } else {
        element.textContent = target;
      }
    };
    
    updateCounter();
  };

  // ===== Initialize Counters on Dashboard =====
  const initDashboardCounters = () => {
    const counters = document.querySelectorAll('.admin-grid article span.counter');
    counters.forEach(counter => {
      const target = parseInt(counter.textContent) || 0;
      counter.textContent = '0';
      counter.classList.add('counter');
      
      // Use Intersection Observer to trigger animation when visible
      const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            animateCounter(counter, target);
            observer.unobserve(entry.target);
          }
        });
      }, { threshold: 0.5 });
      
      observer.observe(counter);
    });
  };

  // ===== Table Row Hover Effects =====
  const initTableEffects = () => {
    const tableRows = document.querySelectorAll('.admin-table tbody tr');
    tableRows.forEach(row => {
      row.addEventListener('mouseenter', function() {
        this.style.transform = 'scale(1.01)';
      });
      row.addEventListener('mouseleave', function() {
        this.style.transform = 'scale(1)';
      });
    });
  };

  // ===== Form Validation Enhancement =====
  const initFormValidation = () => {
    const forms = document.querySelectorAll('form');
    forms.forEach(form => {
      form.addEventListener('submit', (e) => {
        const requiredFields = form.querySelectorAll('[required]');
        let isValid = true;
        
        requiredFields.forEach(field => {
          if (!field.value.trim()) {
            isValid = false;
            field.style.borderColor = 'var(--error)';
            field.addEventListener('input', function() {
              this.style.borderColor = '';
            }, { once: true });
          }
        });
        
        if (!isValid) {
          e.preventDefault();
          // Show error message
          const errorMsg = document.createElement('div');
          errorMsg.className = 'form-error';
          errorMsg.textContent = '필수 항목을 모두 입력해주세요.';
          errorMsg.style.cssText = 'color: var(--error); margin-top: 1rem; padding: 0.75rem; background: rgba(239, 68, 68, 0.1); border-radius: 0.5rem;';
          form.appendChild(errorMsg);
          setTimeout(() => errorMsg.remove(), 5000);
        }
      });
    });
  };

  // ===== Toast Notification System =====
  const showToast = (message, type = 'info') => {
    const toast = document.createElement('div');
    toast.className = `toast toast-${type}`;
    toast.textContent = message;
    toast.style.cssText = `
      position: fixed;
      top: 20px;
      right: 20px;
      padding: 1rem 1.5rem;
      background: var(--glass-bg);
      backdrop-filter: blur(20px);
      border: 1px solid var(--glass-border);
      border-radius: 0.75rem;
      color: var(--text-primary);
      box-shadow: var(--shadow-lg);
      z-index: 10000;
      animation: slideIn 0.3s ease;
    `;
    
    document.body.appendChild(toast);
    
    setTimeout(() => {
      toast.style.animation = 'fadeOut 0.3s ease';
      setTimeout(() => toast.remove(), 300);
    }, 3000);
  };

  // ===== Smooth Scroll =====
  const initSmoothScroll = () => {
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
      anchor.addEventListener('click', function(e) {
        const href = this.getAttribute('href');
        if (href !== '#') {
          const target = document.querySelector(href);
          if (target) {
            e.preventDefault();
            target.scrollIntoView({ behavior: 'smooth', block: 'start' });
          }
        }
      });
    });
  };

  // ===== Admin Request Queue (Existing Functionality) =====
  const storageKey = 'aiAdminRequests';

  const readAdminRequests = () => JSON.parse(localStorage.getItem(storageKey) || '[]');
  const writeAdminRequests = (requests) => localStorage.setItem(storageKey, JSON.stringify(requests));
  const dispatchAdminRequestsUpdated = () =>
    window.dispatchEvent(new CustomEvent('aiAdminRequestsUpdated', { detail: readAdminRequests() }));

  const renderAdminRequests = (requests = readAdminRequests()) => {
    const tableBody = document.getElementById('requestQueueBody');
    const emptyState = document.getElementById('requestQueueEmpty');
    if (!tableBody) return;
    tableBody.innerHTML = '';
    if (!requests.length) {
      emptyState?.classList.remove('hidden');
      return;
    }
    emptyState?.classList.add('hidden');
    requests.forEach((req) => {
      const row = document.createElement('tr');
      const statusLabel = document.createElement('span');
      statusLabel.textContent =
        req.status === 'approved' ? '승인' : req.status === 'rejected' ? '거절' : '대기';
      statusLabel.classList.add('status-label');
      const permissionText =
        Array.isArray(req.permissions) && req.permissions.length > 0
          ? req.permissions.join(', ')
          : '기본 권한 없음';

      row.innerHTML = `
        <td>${req.requestedBy || 'Superadmin'}</td>
        <td>${req.username}</td>
        <td>${req.role}</td>
        <td>${permissionText}</td>
        <td></td>
        <td></td>
      `;
      row.children[4].appendChild(statusLabel);

      const actionCell = row.children[5];
      if (req.status === 'pending') {
        const approveBtn = document.createElement('button');
        approveBtn.type = 'button';
        approveBtn.className = 'btn primary';
        approveBtn.textContent = '허락';
        approveBtn.dataset.requestId = req.id;
        approveBtn.dataset.requestAction = 'approve';

        const rejectBtn = document.createElement('button');
        rejectBtn.type = 'button';
        rejectBtn.className = 'btn ghost';
        rejectBtn.textContent = '거절';
        rejectBtn.dataset.requestId = req.id;
        rejectBtn.dataset.requestAction = 'reject';

        actionCell.appendChild(approveBtn);
        actionCell.appendChild(rejectBtn);
      } else {
        actionCell.textContent = '-';
      }

      tableBody.appendChild(row);
    });
  };

  const updateRequestStatus = (id, status) => {
    const requests = readAdminRequests();
    const index = requests.findIndex((request) => request.id === id);
    if (index === -1) return;
    requests[index].status = status;
    requests[index].handledAt = new Date().toISOString();
    writeAdminRequests(requests);
    dispatchAdminRequestsUpdated();
    const feedback = document.getElementById('superadminQueueFeedback');
    if (feedback) {
      feedback.textContent = `요청 ${status === 'approved' ? '허락' : '거절'}됨: ${requests[index].username}`;
    }
  };

  const addAdminRequest = (request) => {
    const requests = readAdminRequests();
    requests.unshift({
      id: Date.now(),
      status: 'pending',
      createdAt: new Date().toISOString(),
      ...request,
    });
    writeAdminRequests(requests);
    dispatchAdminRequestsUpdated();
  };

  window.addAdminRequest = addAdminRequest;

  // ===== Initialize Everything on DOM Ready =====
  document.addEventListener('DOMContentLoaded', () => {
    initThemeToggle();
    initSidebarActive();
    initMobileSidebar();
    initSearch();
    initDashboardCounters();
    initTableEffects();
    initFormValidation();
    initSmoothScroll();

    // Admin Request Queue
    const policyBtn = document.getElementById('adminPolicyBtn');
    const modal = document.getElementById('adminPolicyModal');
    const overlay = document.getElementById('adminModalOverlay');
    const closeButtons = modal?.querySelectorAll('[data-modal-close]') ?? [];
    const toggleModal = (show) => {
      if (!modal || !overlay) return;
      modal.classList.toggle('active', show);
      overlay.classList.toggle('active', show);
    };
    policyBtn?.addEventListener('click', () => toggleModal(true));
    closeButtons.forEach((button) => button.addEventListener('click', () => toggleModal(false)));
    overlay?.addEventListener('click', () => toggleModal(false));

    const creationForm = document.getElementById('adminCreationForm');
    const feedback = document.getElementById('adminCreationFeedback');
    creationForm?.addEventListener('submit', (event) => {
      event.preventDefault();
      const formData = new FormData(creationForm);
      const username = formData.get('username');
      const role = formData.get('role');
      const permissions = formData.getAll('perm');
      if (typeof username === 'string' && username.trim().length > 0) {
        const permissionText = permissions.length ? permissions.join(', ') : '기본 권한 없음';
        if (feedback) {
          feedback.textContent = `Superadmin 요청: ${username} (${role}) · 권한: ${permissionText}`;
        }
        window.addAdminRequest?.({
          username,
          role,
          permissions,
          requestedBy: 'Superadmin UI',
        });
        toggleModal(false);
      }
    });

    const requestTableBody = document.getElementById('requestQueueBody');
    if (requestTableBody) {
      requestTableBody.addEventListener('click', (event) => {
        const actionButton = event.target.closest('[data-request-action]');
        if (!actionButton) return;
        const id = Number(actionButton.dataset.requestId);
        const action = actionButton.dataset.requestAction;
        updateRequestStatus(id, action === 'approve' ? 'approved' : 'rejected');
      });
      renderAdminRequests();
    }
    window.addEventListener('aiAdminRequestsUpdated', () => renderAdminRequests());
    renderAdminRequests();
  });

  // Export for global use
  window.showToast = showToast;

  // ===== Dashboard Functionality =====
  const initDashboard = () => {
    let lastOrderId = null;
    let orderCheckInterval = null;
    let statisticsCheckInterval = null;
    const CHECK_INTERVAL = 5000;

    // 통계 정보 로드
    function loadSalesStatistics() {
      fetch('/AI/api/sales-statistics.jsp')
        .then(response => response.json())
        .then(data => {
          if (data.success) {
            updateStatistics(data.recent30Days);
          } else {
            console.error('통계 로드 오류:', data.error);
          }
        })
        .catch(error => {
          console.error('통계 로드 오류:', error);
        });
    }

    // 통계 정보 업데이트
    function updateStatistics(stats) {
      const totalOrdersElement = document.getElementById('statTotalOrdersValue');
      if (totalOrdersElement && stats.totalOrders !== undefined) {
        animateCounter(totalOrdersElement, parseInt(totalOrdersElement.textContent.replace(/,/g, '')) || 0, stats.totalOrders);
        totalOrdersElement.textContent = formatNumber(stats.totalOrders);
        highlightUpdate('statTotalOrders');
      }

      const totalRevenueElement = document.getElementById('statTotalRevenueValue');
      if (totalRevenueElement && stats.totalRevenue !== undefined) {
        const currentValue = parseFloat(totalRevenueElement.textContent.replace(/[$,]/g, '')) || 0;
        const newValue = stats.totalRevenue;
        animateCounter(totalRevenueElement, currentValue, newValue);
        totalRevenueElement.textContent = '$' + formatNumber(newValue);
        highlightUpdate('statTotalRevenue');
      }

      const avgOrderValueElement = document.getElementById('statAvgOrderValueValue');
      if (avgOrderValueElement && stats.avgOrderValue !== undefined) {
        const currentValue = parseFloat(avgOrderValueElement.textContent.replace(/[$,]/g, '')) || 0;
        const newValue = stats.avgOrderValue;
        animateCounter(avgOrderValueElement, currentValue, newValue);
        avgOrderValueElement.textContent = '$' + formatNumber(newValue);
        highlightUpdate('statAvgOrderValue');
      }
    }

    function formatNumber(num) {
      if (num === null || num === undefined) return '0';
      return Math.round(num).toLocaleString('ko-KR');
    }

    function animateCounter(element, start, end) {
      if (start === end) return;
      
      const duration = 500;
      const startTime = performance.now();
      const isDecimal = end % 1 !== 0;
      
      function update(currentTime) {
        const elapsed = currentTime - startTime;
        const progress = Math.min(elapsed / duration, 1);
        const easeOut = 1 - Math.pow(1 - progress, 3);
        const current = start + (end - start) * easeOut;
        
        if (isDecimal) {
          element.textContent = '$' + current.toFixed(2);
        } else {
          element.textContent = formatNumber(Math.round(current));
        }
        
        if (progress < 1) {
          requestAnimationFrame(update);
        } else {
          if (isDecimal) {
            element.textContent = '$' + formatNumber(end);
          } else {
            element.textContent = formatNumber(end);
          }
        }
      }
      
      requestAnimationFrame(update);
    }

    function highlightUpdate(elementId) {
      const element = document.getElementById(elementId);
      if (element) {
        element.classList.add('updating');
        setTimeout(() => {
          element.classList.remove('updating');
        }, 500);
      }
    }

    function loadRecentOrders() {
      fetch('/AI/api/recent-orders.jsp?limit=10')
        .then(response => response.json())
        .then(data => {
          if (data.success && data.orders) {
            displayOrders(data.orders);
            updateLastUpdateTime();
            
            if (data.orders.length > 0) {
              const latestOrderId = data.orders[0].id;
              if (lastOrderId !== null && latestOrderId > lastOrderId) {
                showNotification(data.orders[0]);
              }
              lastOrderId = latestOrderId;
            }
          } else {
            showError('주문 정보를 불러올 수 없습니다.');
          }
        })
        .catch(error => {
          console.error('주문 로드 오류:', error);
          showError('주문 정보를 불러오는 중 오류가 발생했습니다.');
        });
    }

    function displayOrders(orders) {
      const container = document.getElementById('recentOrdersContainer');
      
      if (orders.length === 0) {
        container.innerHTML = '<div class="empty-orders"><p>아직 주문이 없습니다.</p></div>';
        return;
      }

      let html = '<div class="orders-list">';
      
      orders.forEach((order, index) => {
        const isNew = index === 0 && lastOrderId !== null && order.id > lastOrderId;
        const orderDate = formatDate(order.createdAt);
        const paymentMethod = getPaymentMethodName(order.paymentMethod);
        
        html += `
          <div class="order-card ${isNew ? 'new-order' : ''}" data-order-id="${order.id}">
            <div class="order-header">
              <div>
                <div class="order-id">주문 #${order.id}</div>
                <div class="order-date">${orderDate}</div>
              </div>
              <span class="order-status ${order.orderStatus === 'COMPLETED' ? 'completed' : ''}">
                ${order.orderStatus === 'COMPLETED' ? '완료' : order.orderStatus}
              </span>
            </div>
            <div class="order-customer">
              <strong>${escapeHtml(order.customerName)}</strong> (${escapeHtml(order.customerEmail)})
            </div>
            <div class="order-items">
              ${order.items.map(item => `
                <div class="order-item">
                  <div>
                    <div class="order-item-name">${escapeHtml(item.itemName)}</div>
                    <div class="order-item-details">
                      ${item.itemType === 'MODEL' ? '모델' : '패키지'} · 수량: ${item.quantity} · 단가: $${item.price.toFixed(2)}
                    </div>
                  </div>
                </div>
              `).join('')}
            </div>
            <div class="order-total">
              <div>
                <strong>결제 방법:</strong> ${paymentMethod}
              </div>
              <strong>총액: $${order.totalPrice.toFixed(2)}</strong>
            </div>
          </div>
        `;
      });
      
      html += '</div>';
      container.innerHTML = html;
    }

    function showNotification(order) {
      const notification = document.getElementById('orderNotification');
      const orderInfo = document.getElementById('notificationOrderInfo');
      
      if (notification && orderInfo) {
        orderInfo.textContent = `주문 #${order.id} - ${order.customerName}님 ($${order.totalPrice.toFixed(2)})`;
        notification.style.display = 'block';
        
        setTimeout(() => {
          closeNotification();
        }, 5000);
      }
    }

    function closeNotification() {
      const notification = document.getElementById('orderNotification');
      if (notification) {
        notification.style.display = 'none';
      }
    }

    function updateLastUpdateTime() {
      const timeElement = document.getElementById('lastUpdateTime');
      if (timeElement) {
        const now = new Date();
        const timeString = now.toLocaleTimeString('ko-KR', { 
          hour: '2-digit', 
          minute: '2-digit',
          second: '2-digit'
        });
        timeElement.textContent = `마지막 업데이트: ${timeString}`;
      }
    }

    function formatDate(dateString) {
      if (!dateString) return '';
      const date = new Date(dateString);
      return date.toLocaleString('ko-KR', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit'
      });
    }

    function getPaymentMethodName(method) {
      const methods = {
        'card': '카드',
        'bank': '은행 이체',
        'virtual': '가상계좌'
      };
      return methods[method] || method;
    }

    function escapeHtml(text) {
      const div = document.createElement('div');
      div.textContent = text;
      return div.innerHTML;
    }

    function showError(message) {
      const container = document.getElementById('recentOrdersContainer');
      if (container) {
        container.innerHTML = `<div class="empty-orders"><p style="color: #ff3b30;">${escapeHtml(message)}</p></div>`;
      }
    }

    // 전역 함수로 export
    window.loadRecentOrders = loadRecentOrders;
    window.closeNotification = closeNotification;

    // 페이지 로드 시 초기화
    if (document.getElementById('recentOrdersContainer')) {
      loadSalesStatistics();
      loadRecentOrders();
      
      statisticsCheckInterval = setInterval(loadSalesStatistics, CHECK_INTERVAL);
      orderCheckInterval = setInterval(loadRecentOrders, CHECK_INTERVAL);
      
      window.addEventListener('beforeunload', function() {
        if (orderCheckInterval) {
          clearInterval(orderCheckInterval);
        }
        if (statisticsCheckInterval) {
          clearInterval(statisticsCheckInterval);
        }
      });
    }
  };

  // Initialize dashboard if on dashboard page
  if (document.getElementById('recentOrdersContainer')) {
    initDashboard();
  }
})();
