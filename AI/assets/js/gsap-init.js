/**
 * GSAP Initialization
 * Scroll Reveal & Parallax Effects
 */

let gsapLoaded = false;
let ScrollTriggerLoaded = false;

/**
 * GSAP 로드
 */
async function loadGSAP() {
  if (window.gsap) {
    gsapLoaded = true;
    return;
  }
  
  try {
    // CDN에서 GSAP 로드
    await loadScript('https://cdn.skypack.dev/gsap');
    gsapLoaded = true;
  } catch (e) {
    console.warn('GSAP 로드 실패, 기본 애니메이션 사용:', e);
  }
}

/**
 * ScrollTrigger 로드
 */
async function loadScrollTrigger() {
  if (window.ScrollTrigger) {
    ScrollTriggerLoaded = true;
    return;
  }
  
  if (!gsapLoaded) {
    await loadGSAP();
  }
  
  try {
    await loadScript('https://cdn.skypack.dev/gsap/ScrollTrigger');
    if (window.gsap && window.ScrollTrigger) {
      window.gsap.registerPlugin(window.ScrollTrigger);
      ScrollTriggerLoaded = true;
    }
  } catch (e) {
    console.warn('ScrollTrigger 로드 실패:', e);
  }
}

/**
 * 스크립트 동적 로드
 */
function loadScript(src) {
  return new Promise((resolve, reject) => {
    if (document.querySelector(`script[src="${src}"]`)) {
      resolve();
      return;
    }
    
    const script = document.createElement('script');
    script.src = src;
    script.type = 'module';
    script.onload = resolve;
    script.onerror = reject;
    document.head.appendChild(script);
  });
}

/**
 * Scroll Reveal 초기화 (GSAP 사용)
 */
async function initRevealGSAP() {
  if (!gsapLoaded || !ScrollTriggerLoaded) {
    await loadScrollTrigger();
  }
  
  if (window.gsap && window.ScrollTrigger) {
    const elements = document.querySelectorAll('.gsap-stagger > *');
    
    elements.forEach((el, i) => {
      window.gsap.to(el, {
        opacity: 1,
        y: 0,
        duration: 0.5,
        delay: i * 0.03,
        scrollTrigger: {
          trigger: el,
          start: 'top 85%',
          toggleActions: 'play none none none'
        }
      });
    });
  }
}

/**
 * Scroll Reveal 초기화 (기본 CSS 사용)
 */
function initRevealBasic() {
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.style.opacity = '1';
        entry.target.style.transform = 'translateY(0)';
        observer.unobserve(entry.target);
      }
    });
  }, {
    threshold: 0.1,
    rootMargin: '0px 0px -50px 0px'
  });
  
  document.querySelectorAll('.gsap-stagger > *').forEach(el => {
    observer.observe(el);
  });
}

/**
 * 전역 reveal 함수
 */
window.initReveal = async function() {
  try {
    await initRevealGSAP();
  } catch (e) {
    console.warn('GSAP reveal 실패, 기본 애니메이션 사용:', e);
    initRevealBasic();
  }
};

/**
 * Parallax 효과 초기화
 */
window.initParallax = async function() {
  if (!gsapLoaded || !ScrollTriggerLoaded) {
    await loadScrollTrigger();
  }
  
  if (window.gsap && window.ScrollTrigger) {
    const parallaxElements = document.querySelectorAll('.parallax-element');
    
    parallaxElements.forEach(el => {
      window.gsap.to(el, {
        y: -50,
        ease: 'none',
        scrollTrigger: {
          trigger: el,
          start: 'top bottom',
          end: 'bottom top',
          scrub: true
        }
      });
    });
  }
};

// DOM 로드 시 자동 초기화 (지연 실행으로 성능 개선)
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => {
    // 지연 초기화로 초기 로딩 속도 개선
    setTimeout(() => {
      if (window.initReveal) window.initReveal();
    }, 100);
  });
} else {
  setTimeout(() => {
    if (window.initReveal) window.initReveal();
  }, 100);
}

