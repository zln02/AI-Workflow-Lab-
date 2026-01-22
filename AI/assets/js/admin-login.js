/**
 * AI Navigator Admin Login - JavaScript
 * 토스트 메시지 및 폼 처리
 */

(function() {
  'use strict';

  // === Toast Message System ===
  function showToast(message, type = 'info') {
    const container = document.getElementById('toast-container');
    if (!container) return;

    const toast = document.createElement('div');
    toast.className = `toast ${type}`;
    
    const icon = getToastIcon(type);
    toast.innerHTML = `
      <span class="toast-icon">${icon}</span>
      <span class="toast-message">${escapeHtml(message)}</span>
    `;

    container.appendChild(toast);

    // 자동 제거
    setTimeout(() => {
      toast.style.animation = 'fadeOut 0.3s ease forwards';
      setTimeout(() => {
        if (toast.parentNode) {
          toast.parentNode.removeChild(toast);
        }
      }, 300);
    }, 3000);
  }

  function getToastIcon(type) {
    const icons = {
      success: '✓',
      error: '✕',
      info: 'ℹ'
    };
    return icons[type] || icons.info;
  }

  function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
  }

  // === Form Handling ===
  document.addEventListener('DOMContentLoaded', function() {
    const loginForm = document.getElementById('loginForm');
    const loginBtn = loginForm?.querySelector('.login-btn');

    if (loginForm) {
      loginForm.addEventListener('submit', function(e) {
        const username = document.getElementById('username')?.value.trim();
        const password = document.getElementById('password')?.value;

        if (!username || !password) {
          e.preventDefault();
          showToast('아이디와 비밀번호를 모두 입력해 주세요.', 'error');
          return false;
        }

        // 로딩 상태 표시 (폼 제출은 계속 진행)
        if (loginBtn) {
          loginBtn.classList.add('loading');
          // disabled를 설정하면 폼 제출이 막힐 수 있으므로 제거
          // loginBtn.disabled = true;
        }
        
        // 폼 제출은 계속 진행 (preventDefault 호출 안 함)
      });

      // Enter 키로 제출
      const inputs = loginForm.querySelectorAll('input');
      inputs.forEach(input => {
        input.addEventListener('keypress', function(e) {
          if (e.key === 'Enter') {
            loginForm.dispatchEvent(new Event('submit'));
          }
        });
      });
    }
  });

  // 전역 함수로 export
  window.showToast = showToast;
})();

