/**
 * AI Navigator - User Interface JavaScript
 * Production-ready utilities and interactions
 */

(function() {
  'use strict';

  // ============================================
  // Currency Management
  // ============================================
  
  const CURRENCY_STORAGE_KEY = 'currency';
  const DEFAULT_CURRENCY = 'USD';
  const DEFAULT_RATE = 1350; // USD to KRW

  /**
   * Get current currency from localStorage
   */
  function getCurrency() {
    const stored = localStorage.getItem(CURRENCY_STORAGE_KEY);
    return stored === 'KRW' ? 'KRW' : DEFAULT_CURRENCY;
  }

  /**
   * Set currency in localStorage
   */
  function setCurrency(currency) {
    localStorage.setItem(CURRENCY_STORAGE_KEY, currency);
    updateCurrencyDisplay();
  }

  /**
   * Get exchange rate (can be overridden via rate.jsp)
   */
  function getExchangeRate() {
    // Try to get from window if set by rate.jsp
    if (window.exchangeRate && typeof window.exchangeRate === 'number') {
      return window.exchangeRate;
    }
    return DEFAULT_RATE;
  }

  /**
   * Format currency amount
   * @param {number} amountUSD - Amount in USD
   * @param {string} currency - 'USD' or 'KRW'
   * @param {number} rate - Exchange rate (default: 1350)
   * @returns {string} Formatted currency string
   */
  function formatCurrency(amountUSD, currency, rate) {
    if (amountUSD == null || isNaN(amountUSD)) {
      return 'N/A';
    }

    currency = currency || getCurrency();
    rate = rate || getExchangeRate();

    if (currency === 'KRW') {
      const krwAmount = Math.round(amountUSD * rate);
      return new Intl.NumberFormat('ko-KR', {
        style: 'currency',
        currency: 'KRW',
        minimumFractionDigits: 0,
        maximumFractionDigits: 0
      }).format(krwAmount);
    } else {
      return new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: 'USD',
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
      }).format(amountUSD);
    }
  }

  /**
   * Update all currency displays on the page
   */
  function updateCurrencyDisplay() {
    const currency = getCurrency();
    const rate = getExchangeRate();
    
    document.querySelectorAll('[data-price-usd]').forEach(el => {
      const amountUSD = parseFloat(el.getAttribute('data-price-usd'));
      if (!isNaN(amountUSD)) {
        // Check if it's a price-display-usd element (secondary price display)
        if (el.classList.contains('price-display-usd') || el.classList.contains('original-price-display')) {
          // For secondary displays, show USD in parentheses or original price
          if (currency === 'KRW') {
            el.textContent = '($' + amountUSD.toFixed(0) + '/월)';
          } else {
            el.textContent = '($' + amountUSD.toFixed(0) + '/월)';
          }
        } else {
          // Main price display
          if (currency === 'KRW') {
            const krwAmount = Math.round(amountUSD * rate);
            el.textContent = new Intl.NumberFormat('ko-KR').format(krwAmount) + '원';
          } else {
            el.textContent = '$' + amountUSD.toFixed(0);
          }
        }
      }
    });
    
    // Update currency toggle buttons
    document.querySelectorAll('.currency-toggle button').forEach(btn => {
      btn.classList.toggle('active', btn.textContent === currency);
    });
  }

  /**
   * Initialize currency toggle
   */
  function initCurrencyToggle() {
    const toggleContainer = document.querySelector('.currency-toggle');
    if (!toggleContainer) return;

    const usdBtn = toggleContainer.querySelector('[data-currency="USD"]');
    const krwBtn = toggleContainer.querySelector('[data-currency="KRW"]');

    if (usdBtn) {
      usdBtn.addEventListener('click', () => {
        setCurrency('USD');
      });
    }

    if (krwBtn) {
      krwBtn.addEventListener('click', () => {
        setCurrency('KRW');
      });
    }

    // Set initial active state
    updateCurrencyDisplay();
  }

  // ============================================
  // Image Fallback
  // ============================================

  /**
   * Create fallback icon element
   * @param {string} icon - Emoji or icon text (default: 🤖)
   * @returns {HTMLElement} Fallback element
   */
  function createFallbackIcon(icon = '🤖') {
    const fallback = document.createElement('div');
    fallback.className = 'image-fallback';
    fallback.textContent = icon;
    fallback.setAttribute('aria-label', 'Image placeholder');
    return fallback;
  }

  /**
   * Initialize image lazy loading and fallbacks
   */
  function initImageFallbacks() {
    document.querySelectorAll('img[loading="lazy"]').forEach(img => {
      // Set loading attribute if not already set
      if (!img.hasAttribute('loading')) {
        img.setAttribute('loading', 'lazy');
      }

      // Add error handler
      img.addEventListener('error', function() {
        const fallback = createFallbackIcon();
        this.replaceWith(fallback);
      });
    });
  }

  // ============================================
  // Loading Overlay
  // ============================================

  /**
   * Show loading overlay
   */
  function showLoading() {
    const overlay = document.getElementById('loading-overlay');
    if (overlay) {
      overlay.classList.add('active');
    }
  }

  /**
   * Hide loading overlay
   */
  function hideLoading() {
    const overlay = document.getElementById('loading-overlay');
    if (overlay) {
      overlay.classList.remove('active');
    }
  }

  /**
   * Initialize form loading states
   */
  function initFormLoading() {
    document.querySelectorAll('form').forEach(form => {
      form.addEventListener('submit', function(e) {
        // Only show loading for forms that don't prevent default
        if (!e.defaultPrevented) {
          showLoading();
          
          // Hide after 3 seconds max (safety)
          setTimeout(hideLoading, 3000);
        }
      });
    });
  }

  // ============================================
  // Cart Quantity Controls
  // ============================================

  /**
   * Update cart item quantity
   */
  function updateCartQuantity(index, newQuantity) {
    if (newQuantity < 1) {
      if (confirm('이 아이템을 장바구니에서 제거하시겠습니까?')) {
        window.location.href = `/AI/user/cart.jsp?action=remove&id=${index}`;
      }
      return;
    }

    // Update via form submission
    const form = document.createElement('form');
    form.method = 'POST';
    form.action = '/AI/user/cart.jsp';
    
    const actionInput = document.createElement('input');
    actionInput.type = 'hidden';
    actionInput.name = 'action';
    actionInput.value = 'update';
    
    const indexInput = document.createElement('input');
    indexInput.type = 'hidden';
    indexInput.name = 'index';
    indexInput.value = index;
    
    const quantityInput = document.createElement('input');
    quantityInput.type = 'hidden';
    quantityInput.name = 'quantity';
    quantityInput.value = newQuantity;
    
    form.appendChild(actionInput);
    form.appendChild(indexInput);
    form.appendChild(quantityInput);
    
    // Add CSRF token if available
    const csrfInput = document.querySelector('input[name="csrf"]');
    if (csrfInput) {
      const csrfClone = csrfInput.cloneNode(true);
      form.appendChild(csrfClone);
    }
    
    document.body.appendChild(form);
    form.submit();
  }

  /**
   * Initialize cart quantity controls
   */
  function initCartControls() {
    document.querySelectorAll('.quantity-controls').forEach(control => {
      const minusBtn = control.querySelector('[data-action="decrease"]');
      const plusBtn = control.querySelector('[data-action="increase"]');
      const quantityInput = control.querySelector('input[type="number"]');
      
      if (minusBtn && quantityInput) {
        minusBtn.addEventListener('click', () => {
          const current = parseInt(quantityInput.value) || 1;
          const index = parseInt(quantityInput.getAttribute('data-index')) || 0;
          updateCartQuantity(index, current - 1);
        });
      }
      
      if (plusBtn && quantityInput) {
        plusBtn.addEventListener('click', () => {
          const current = parseInt(quantityInput.value) || 1;
          const index = parseInt(quantityInput.getAttribute('data-index')) || 0;
          updateCartQuantity(index, current + 1);
        });
      }
    });
  }

  // ============================================
  // Accessibility
  // ============================================

  /**
   * Initialize accessibility features
   */
  function initAccessibility() {
    // Add aria-labels to buttons without text
    document.querySelectorAll('button:not([aria-label]):empty').forEach(btn => {
      const icon = btn.textContent.trim() || btn.innerHTML.trim();
      if (icon && icon.length < 3) {
        btn.setAttribute('aria-label', 'Button');
      }
    });

    // Ensure focus styles are visible
    document.addEventListener('keydown', function(e) {
      if (e.key === 'Tab') {
        document.body.classList.add('keyboard-navigation');
      }
    });

    document.addEventListener('mousedown', function() {
      document.body.classList.remove('keyboard-navigation');
    });
  }

  // ============================================
  // Initialization
  // ============================================

  /**
   * Initialize all features when DOM is ready
   */
  function init() {
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', init);
      return;
    }

    initCurrencyToggle();
    initImageFallbacks();
    initFormLoading();
    initCartControls();
    initAccessibility();

    // Hide loading overlay if page is fully loaded (최적화)
    if (document.readyState === 'complete') {
      hideLoading();
    } else {
      window.addEventListener('load', hideLoading);
    }

    // Navbar mobile menu toggle
    const navbar = document.getElementById('navbar');
    const navbarToggle = document.getElementById('navbarToggle');
    const navbarMenu = document.getElementById('navbarMenu');
    if (navbarToggle && navbarMenu) {
      navbarToggle.addEventListener('click', () => {
        navbarMenu.classList.toggle('active');
      });

      // Close menu when clicking outside
      document.addEventListener('click', (e) => {
        if (navbar && !navbar.contains(e.target) && navbarMenu.classList.contains('active')) {
          navbarMenu.classList.remove('active');
        }
      });
    }

    // Active menu item highlighting
    const currentPath = window.location.pathname;
    const menuLinks = document.querySelectorAll('.navbar-menu a');
    menuLinks.forEach(link => {
      const href = link.getAttribute('href');
      if (href === currentPath || 
          (currentPath.includes('/user/') && href.includes(currentPath.split('/').pop()))) {
        link.classList.add('active');
      }
    });
  }

  // Start initialization
  init();

  // Export functions for global use
  window.AINavigator = {
    formatCurrency: formatCurrency,
    getCurrency: getCurrency,
    setCurrency: setCurrency,
    showLoading: showLoading,
    hideLoading: hideLoading,
    createFallbackIcon: createFallbackIcon
  };

})();
