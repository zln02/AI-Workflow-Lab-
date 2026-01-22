/**
 * Toast Notification Utility
 * Apple Style Toast Messages
 */

let toastContainer = null;

/**
 * Toast 컨테이너 초기화
 */
function initToastContainer() {
  if (!toastContainer) {
    toastContainer = document.createElement('div');
    toastContainer.className = 'toast-container';
    document.body.appendChild(toastContainer);
  }
  return toastContainer;
}

/**
 * Toast 메시지 표시
 * @param {string} message - 메시지
 * @param {string} type - 타입 (success, error, warning, info)
 * @param {number} duration - 표시 시간 (ms, 기본 3000)
 */
export function toast(message, type = 'info', duration = 3000) {
  const container = initToastContainer();
  
  const toastEl = document.createElement('div');
  toastEl.className = `toast ${type}`;
  
  const messageEl = document.createElement('div');
  messageEl.className = 'toast-message';
  messageEl.textContent = message;
  
  const closeBtn = document.createElement('button');
  closeBtn.className = 'toast-close';
  closeBtn.innerHTML = '×';
  closeBtn.setAttribute('aria-label', '닫기');
  closeBtn.onclick = () => {
    toastEl.remove();
  };
  
  toastEl.appendChild(messageEl);
  toastEl.appendChild(closeBtn);
  container.appendChild(toastEl);
  
  // 자동 제거
  setTimeout(() => {
    toastEl.style.animation = 'toastSlideIn 0.3s ease-out reverse';
    setTimeout(() => {
      toastEl.remove();
    }, 300);
  }, duration);
  
  return toastEl;
}

/**
 * 성공 메시지
 */
export function toastSuccess(message, duration) {
  return toast(message, 'success', duration);
}

/**
 * 에러 메시지
 */
export function toastError(message, duration) {
  return toast(message, 'error', duration || 5000);
}

/**
 * 경고 메시지
 */
export function toastWarning(message, duration) {
  return toast(message, 'warning', duration);
}

/**
 * 정보 메시지
 */
export function toastInfo(message, duration) {
  return toast(message, 'info', duration);
}



