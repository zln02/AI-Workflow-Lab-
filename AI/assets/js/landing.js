document.addEventListener('DOMContentLoaded', () => {
  // Navbar scroll effect (throttled for performance)
  const navbar = document.getElementById('navbar');
  if (navbar) {
    let ticking = false;
    window.addEventListener('scroll', () => {
      if (!ticking) {
        window.requestAnimationFrame(() => {
          const currentScroll = window.pageYOffset;
          if (currentScroll > 100) {
            navbar.classList.add('scrolled');
          } else {
            navbar.classList.remove('scrolled');
          }
          ticking = false;
        });
        ticking = true;
      }
    });
  }

  // Mobile menu toggle
  const navbarToggle = document.getElementById('navbarToggle');
  const navbarMenu = document.getElementById('navbarMenu');
  if (navbarToggle && navbarMenu) {
    navbarToggle.addEventListener('click', () => {
      navbarMenu.classList.toggle('active');
    });

    // Close menu when clicking outside
    document.addEventListener('click', (e) => {
      if (!navbar.contains(e.target) && navbarMenu.classList.contains('active')) {
        navbarMenu.classList.remove('active');
      }
    });
  }

  // Active menu item highlighting
  const currentPath = window.location.pathname;
  const menuLinks = document.querySelectorAll('.navbar-menu a');
  menuLinks.forEach(link => {
    if (link.getAttribute('href') === currentPath || 
        (currentPath.includes('/user/') && link.getAttribute('href').includes(currentPath.split('/').pop()))) {
      link.classList.add('active');
    }
  });

  // Model item hover effects (CSS로 처리 가능하지만 JS로 유지)
  // CSS transition으로 성능 개선
  const modelItems = document.querySelectorAll('.model-item');
  modelItems.forEach(item => {
    item.style.transition = 'transform 0.2s ease';
    item.addEventListener('mouseenter', () => {
      item.style.transform = 'translateY(-8px)';
    });
    item.addEventListener('mouseleave', () => {
      item.style.transform = 'translateY(0)';
    });
  });

  // Modality selector active state and filtering
  const modalityButtons = document.querySelectorAll('.modality-btn');
  
  // Parse URL hash for modality parameter
  function getModalityFromURL() {
    const hash = window.location.hash;
    if (hash && hash.includes('?')) {
      const params = new URLSearchParams(hash.split('?')[1]);
      return params.get('modality');
    }
    return null;
  }
  
  // Filter models by modality with animation (use global function if available)
  function filterModelsByModality(modality) {
    // 전역 함수가 있으면 사용 (home.jsp에서 정의됨)
    if (window.filterAndScrollToModality) {
      window.filterAndScrollToModality(modality);
      return;
    }
    
    // 폴백: 기본 필터링 (애니메이션 없음)
    const modelItems = document.querySelectorAll('.model-item[data-modality]');
    const scrollContainer = document.getElementById('modelItemsContainer');
    
    let visibleCount = 0;
    
    modelItems.forEach(item => {
      const itemModality = item.getAttribute('data-modality');
      if (!modality || modality === '' || itemModality === modality) {
        item.style.display = '';
        visibleCount++;
      } else {
        item.style.display = 'none';
      }
    });
    
    // 필터링 후 스크롤 위치 초기화
    if (scrollContainer) {
      scrollContainer.scrollLeft = 0;
    }
    
    // Update active button
    modalityButtons.forEach(btn => {
      btn.classList.remove('active');
      const href = btn.getAttribute('href');
      if (href) {
        if (!modality && href === '#models') {
          btn.classList.add('active');
        } else if (modality && href.includes(`modality=${modality}`)) {
          btn.classList.add('active');
        }
      }
    });
    
    console.log(`필터링 완료: ${modality || '전체'} 모델 ${visibleCount}개 표시`);
  }
  
  // Initialize filtering from URL
  const initialModality = getModalityFromURL();
  if (initialModality) {
    filterModelsByModality(initialModality);
  }
  
  // Handle modality button clicks
  modalityButtons.forEach(btn => {
    btn.addEventListener('click', (e) => {
      e.preventDefault();
      const href = btn.getAttribute('href');
      if (href && href.includes('modality=')) {
        const modality = new URLSearchParams(href.split('?')[1]).get('modality');
        filterModelsByModality(modality);
        // Update URL hash without reload
        window.history.replaceState(null, null, `#models?modality=${modality}`);
      } else if (href === '#models') {
        filterModelsByModality(null);
        window.history.replaceState(null, null, '#models');
      }
      // filterModelsByModality가 전역 함수를 사용하면 자동으로 스크롤되므로 여기서는 스크롤하지 않음
    });
  });
  
  // Handle hash change (back/forward button)
  window.addEventListener('hashchange', () => {
    const modality = getModalityFromURL();
    filterModelsByModality(modality);
  });

  // Smooth scroll for anchor links
  document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
      const href = this.getAttribute('href');
      if (href === '#' || href === '#!') {
        e.preventDefault();
        return;
      }
      const target = document.querySelector(href);
      if (target) {
        e.preventDefault();
        const offsetTop = target.offsetTop - 80; // Account for fixed navbar
        window.scrollTo({
          top: offsetTop,
          behavior: 'smooth'
        });
        // Close mobile menu if open
        if (navbarMenu && navbarMenu.classList.contains('active')) {
          navbarMenu.classList.remove('active');
        }
      }
    });
  });

  // Fade in animation on scroll
  const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -50px 0px'
  };

  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('fade-in');
        observer.unobserve(entry.target);
      }
    });
  }, observerOptions);

  document.querySelectorAll('.model-item, .pricing-card, .package-card, .model-spec-card').forEach(el => {
    observer.observe(el);
  });

  // Hero image float animation (already in CSS, but can add JS enhancements)
  const heroImage = document.querySelector('.hero-image img');
  if (heroImage) {
    heroImage.addEventListener('load', () => {
      heroImage.style.opacity = '1';
    });
  }
});

/**
 * 검색어에서 키워드 추출 (코딩, 영상, 이미지, 임베드 등)
 */
function extractKeywords(query) {
  if (!query || typeof query !== 'string') return [];
  
  const keywords = [];
  const queryLower = query.toLowerCase();
  
  // 키워드 매핑
  const keywordMap = {
    '코딩': ['코딩', '코드', '프로그래', '개발'],
    '영상': ['영상', '비디오', 'video'],
    '이미지': ['이미지', '그림', '사진', 'image', 'picture'],
    '임베드': ['임베드', 'embedding', '임베딩'],
    '오디오': ['오디오', '음성', 'audio'],
    '텍스트': ['텍스트', 'text'],
    '번역': ['번역', 'translate'],
    '요약': ['요약', 'summary']
  };
  
  // 검색어에서 키워드 찾기
  for (const [key, variations] of Object.entries(keywordMap)) {
    for (const variation of variations) {
      if (queryLower.includes(variation.toLowerCase())) {
        keywords.push(key);
        break; // 하나만 추가
      }
    }
  }
  
  return keywords;
}

/**
 * 의도 기반 추천 섹션 렌더링
 * @param {HTMLElement} root - 루트 컨테이너
 * @param {string} intent - 의도
 * @param {Object} data - 검색 결과 데이터
 * @param {string} originalQuery - 원본 검색어
 */
window.renderIntentSections = function(root, intent, data, originalQuery) {
  if (!root) return;
  
  let { models = [], packages = [], intentTitle, recommendedCategories = [] } = data;
  
  // 검색어에서 키워드 추출 및 모델 필터링
  if (originalQuery) {
    const keywords = extractKeywords(originalQuery);
    if (keywords.length > 0) {
      // 키워드가 포함된 모델만 필터링
      models = models.filter(model => {
        const modelText = (
          (model.name || '') + ' ' +
          (model.description || '') + ' ' +
          (model.categoryName || '') + ' ' +
          (model.providerName || '')
        ).toLowerCase();
        
        // 하나라도 키워드가 포함되면 통과
        return keywords.some(keyword => modelText.includes(keyword.toLowerCase()));
      });
    }
  }
  
  // 의도 제목
  const title = intentTitle || getIntentTitle(intent);
  
  // Provider별 로고 URL 매핑 함수
  function getProviderLogo(providerName, modelName) {
    if (!providerName) return { logo: '/AI/assets/img/placeholder.png', link: '#' };
    
    const provider = providerName.toLowerCase();
    const model = (modelName || '').toLowerCase();
    
    if (provider.includes('openai')) {
      return { logo: 'https://cdn.simpleicons.org/openai/412991', link: 'https://openai.com' };
    } else if (provider.includes('google') || model.includes('gemini')) {
      return { logo: 'https://cdn.simpleicons.org/google/4285F4', link: 'https://google.com' };
    } else if (provider.includes('anthropic') || provider.includes('claude')) {
      return { logo: 'https://cdn.simpleicons.org/anthropic/D97706', link: 'https://anthropic.com' };
    } else if (provider.includes('meta')) {
      return { logo: 'https://cdn.simpleicons.org/meta/0081FB', link: 'https://meta.com' };
    } else if (provider.includes('microsoft')) {
      return { logo: 'https://cdn.simpleicons.org/microsoft/0078D4', link: 'https://microsoft.com' };
    } else if (provider.includes('adobe')) {
      return { logo: 'https://cdn.simpleicons.org/adobe/FF0000', link: 'https://adobe.com' };
    } else if (provider.includes('midjourney')) {
      return { logo: 'https://cdn.simpleicons.org/midjourney/000000', link: 'https://midjourney.com' };
    } else if (provider.includes('stability')) {
      return { logo: 'https://cdn.simpleicons.org/stabilityai/7575FF', link: 'https://stability.ai' };
    } else if (provider.includes('cohere')) {
      return { logo: 'https://cdn.simpleicons.org/cohere/FA5C5C', link: 'https://cohere.com' };
    } else if (provider.includes('github')) {
      return { logo: 'https://cdn.simpleicons.org/github/181717', link: 'https://github.com' };
    } else if (provider.includes('deepl')) {
      return { logo: 'https://cdn.simpleicons.org/deepl/0F2C46', link: 'https://deepl.com' };
    } else if (provider.includes('elevenlabs')) {
      return { logo: 'https://cdn.simpleicons.org/elevenlabs/000000', link: 'https://elevenlabs.io' };
    } else if (provider.includes('runway')) {
      return { logo: 'https://cdn.simpleicons.org/runwayml/000000', link: 'https://runwayml.com' };
    } else if (provider.includes('perplexity')) {
      return { logo: 'https://cdn.simpleicons.org/perplexity/AA00FF', link: 'https://perplexity.ai' };
    }
    
    return { logo: '/AI/assets/img/placeholder.png', link: '#' };
  }

  // 모델 카드 HTML
  const modelCards = models.map(model => {
    const price = model.priceUsd ? `$${model.priceUsd.toFixed(2)}` : (model.price || '무료 / 문의');
    const providerLogo = getProviderLogo(model.providerName, model.name);
    return `
      <div class="model-item fade-in">
        <div class="model-item-image">
          <a href="${providerLogo.link}" target="_blank" rel="noopener noreferrer" style="display: block; width: 100%; height: 200px; background: var(--surface); border-radius: 12px; overflow: hidden;">
            <img src="${providerLogo.logo}" alt="${escapeHtml(model.providerName || '제공업체')} 로고" style="width: 100%; height: 100%; object-fit: contain; padding: 20px;" onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
            <div style="display: none; width: 100%; height: 100%; align-items: center; justify-content: center; font-size: 3rem; color: var(--text-secondary);">🤖</div>
          </a>
        </div>
        <h3 class="model-item-name">${escapeHtml(model.name || '모델명 없음')}</h3>
        <p class="model-item-provider">
          ${escapeHtml(model.providerName || '제공업체')} 
          ${model.categoryName ? '· ' + escapeHtml(model.categoryName) : ''}
        </p>
        <p class="model-item-description">
          ${escapeHtml((model.description || model.purposeSummary || '설명 없음').substring(0, 120))}${(model.description || '').length > 120 ? '...' : ''}
        </p>
        <div class="model-item-price">${escapeHtml(price)}</div>
        <div class="model-item-actions">
          <a href="/AI/user/modelDetail.jsp?id=${model.id}" class="btn btn-primary btn-sm">상세보기</a>
          <a href="/AI/user/pricing.jsp" class="btn btn-secondary btn-sm">요금제</a>
        </div>
      </div>
    `;
  }).join('');
  
  // 패키지 카드 HTML
  const packCards = packages.map(pkg => {
    const price = pkg.price ? `$${pkg.price.toFixed(2)}` : '가격 문의';
    const discountPrice = pkg.discountPrice ? `$${pkg.discountPrice.toFixed(2)}` : null;
    return `
      <div class="package-card fade-in" style="display: flex; flex-direction: column;">
        <h3 class="package-card-title">${escapeHtml(pkg.title || '패키지')}</h3>
        <p style="color: var(--text-secondary); font-size: 17px; line-height: 1.47059; margin: 12px 0; padding: 0 24px;">
          ${escapeHtml((pkg.description || '설명 없음').substring(0, 100))}${(pkg.description || '').length > 100 ? '...' : ''}
        </p>
        <div class="package-card-price">
          ${discountPrice ? `
            <span style="text-decoration: line-through; color: var(--text-secondary); font-size: 14px;">${escapeHtml(price)}</span><br>
            <span style="color: #ff3b30; font-size: 21px; font-weight: 600;">${escapeHtml(discountPrice)}</span>
          ` : `
            <span style="font-size: 21px; font-weight: 600; color: var(--accent);">${escapeHtml(price)}</span>
          `}
        </div>
        <div class="model-item-actions" style="margin-top: auto; padding-top: 24px; padding-bottom: 24px; display: flex; justify-content: center;">
          <a href="/AI/user/package.jsp?id=${pkg.id}" class="btn btn-primary btn-sm">패키지 보기</a>
        </div>
      </div>
    `;
  }).join('');
  
  root.innerHTML = `
    <h2 class="section-title fade-in">${escapeHtml(title)}</h2>
    ${models.length > 0 ? `
      <div class="intent-models-scroll-wrapper" style="position: relative;">
        <div class="model-items-scroll-container intent-models-scroll-container" style="position: relative;">
          <div class="model-items-scroll intent-models-scroll">
            ${modelCards}
          </div>
        </div>
        <div class="scroll-navigation intent-scroll-navigation" style="position: absolute; bottom: -60px; left: 50%; transform: translateX(-50%); z-index: 10;">
          <button class="scroll-nav-btn scroll-nav-left intent-scroll-left" aria-label="왼쪽으로 이동">‹</button>
          <button class="scroll-nav-btn scroll-nav-right intent-scroll-right" aria-label="오른쪽으로 이동">›</button>
        </div>
      </div>
    ` : ''}
  `;
  
  // AI 추천 모델 섹션 스크롤 네비게이션 초기화
  if (models.length > 0) {
    const scrollContainer = root.querySelector('.intent-models-scroll-container');
    const scrollContent = root.querySelector('.intent-models-scroll');
    const leftBtn = root.querySelector('.intent-scroll-left');
    const rightBtn = root.querySelector('.intent-scroll-right');
    
    if (scrollContainer && scrollContent && leftBtn && rightBtn) {
      // 스크롤 위치 업데이트 함수
      const updateButtons = () => {
        const maxScroll = scrollContent.scrollWidth - scrollContainer.clientWidth;
        leftBtn.disabled = scrollContainer.scrollLeft <= 0;
        rightBtn.disabled = scrollContainer.scrollLeft >= maxScroll - 5; // 5px 오차 허용
      };
      
      // 초기 버튼 상태
      updateButtons();
      
      // 스크롤 이벤트 리스너
      scrollContainer.addEventListener('scroll', updateButtons);
      
      // 화살표 버튼 클릭 이벤트
      leftBtn.addEventListener('click', () => {
        scrollContainer.scrollBy({ left: -420, behavior: 'smooth' });
      });
      
      rightBtn.addEventListener('click', () => {
        scrollContainer.scrollBy({ left: 420, behavior: 'smooth' });
      });
      
      // 리사이즈 이벤트 (컨테이너 크기 변경 시 버튼 상태 업데이트)
      window.addEventListener('resize', updateButtons);
    }
  }
  
  // GSAP reveal 초기화
  if (window.initReveal) {
    window.initReveal();
  }
};

/**
 * 의도별 제목 가져오기
 */
function getIntentTitle(intent) {
  const titles = {
    coding: '코딩에 적합한 AI 모델',
    writing: '문서 작성에 적합한 AI 모델',
    image: '이미지 작업에 적합한 AI 모델',
    audio: '오디오 작업에 적합한 AI 모델',
    data: '데이터 분석에 적합한 AI 모델',
    general: '추천 AI 모델'
  };
  return titles[intent] || titles.general;
}

/**
 * HTML 이스케이프
 */
function escapeHtml(text) {
  if (!text) return '';
  const div = document.createElement('div');
  div.textContent = text;
  return div.innerHTML;
}

/**
 * Home page specific functionality
 */
(function() {
  'use strict';

  // 허용된 검색 키워드 목록
  const ALLOWED_KEYWORDS = [
    // 이미지 관련
    '이미지', 'image', '그림', '사진', '디자인',
    // 비디오 관련
    '비디오', 'video', '영상', '동영상',
    // 오디오 관련
    '오디오', 'audio', '음성', 'speech', 'tts', 'stt',
    // 임베딩 관련
    '임베딩', 'embedding', '벡터', '검색',
    // 텍스트 관련
    '텍스트', 'text', '문서', '코딩', '코드'
  ];

  // 검색어 유효성 검사
  function isValidSearchQuery(q) {
    if (!q || !q.trim()) return false;
    const s = q.toLowerCase().trim();
    return ALLOWED_KEYWORDS.some(keyword => s.includes(keyword.toLowerCase()));
  }

  // 검색어에서 모달리티 키워드 추출
  function detectModalityFromQuery(q) {
    if (!q) return null;
    const s = q.toLowerCase().trim();
    
    if (s.includes('이미지') || s.includes('image') || s.includes('그림') || s.includes('사진') || s.includes('디자인')) {
      return 'IMAGE';
    }
    if (s.includes('비디오') || s.includes('video') || s.includes('영상') || s.includes('동영상')) {
      return 'VIDEO';
    }
    if (s.includes('오디오') || s.includes('audio') || s.includes('음성') || s.includes('speech') || s.includes('tts') || s.includes('stt')) {
      return 'AUDIO';
    }
    if (s.includes('임베딩') || s.includes('embedding') || s.includes('벡터') || s.includes('검색')) {
      return 'EMBEDDING';
    }
    if (s.includes('텍스트') || s.includes('text') || s.includes('문서') || s.includes('코딩') || s.includes('코드')) {
      return 'TEXT';
    }
    
    return null;
  }

  // 모달리티로 모델 필터링 및 애니메이션 (전역 함수)
  window.filterAndScrollToModality = function(modality) {
    const modelItems = document.querySelectorAll('.model-item[data-modality]');
    const modelsSection = document.getElementById('models');
    
    if (!modelsSection) return;
    
    let visibleCount = 0;
    const filteredItems = [];
    
    // 필터링된 아이템만 표시
    modelItems.forEach(item => {
      const itemModality = item.getAttribute('data-modality');
      if (!modality || itemModality === modality || modality === '') {
        item.style.display = '';
        filteredItems.push(item);
        visibleCount++;
        item.style.opacity = '1';
        item.style.transform = 'scale(1)';
      } else {
        item.style.display = 'none';
      }
    });
    
    // 모달리티 버튼 활성화
    document.querySelectorAll('.modality-btn').forEach(btn => {
      btn.classList.remove('active');
      if (modality) {
        const href = btn.getAttribute('href');
        if (href && href.includes(`modality=${modality}`)) {
          btn.classList.add('active');
        }
      } else {
        if (btn.getAttribute('href') === '#models') {
          btn.classList.add('active');
        }
      }
    });
    
    // 스크롤 컨테이너 초기화
    const scrollContainer = document.getElementById('modelItemsContainer');
    if (scrollContainer) {
      scrollContainer.scrollLeft = 0;
    }
    
    // 부드러운 스크롤 애니메이션으로 모델 섹션으로 이동
    if (modelsSection) {
      requestAnimationFrame(() => {
        const offset = 100;
        const targetPosition = modelsSection.getBoundingClientRect().top + window.pageYOffset - offset;
        window.scrollTo({
          top: targetPosition,
          behavior: 'smooth'
        });
      });
    }
    
    console.log(`필터링 완료: ${modality || '전체'} 모델 ${visibleCount}개 표시`);
  };
  
  // 기존 landing.js 함수를 새로운 애니메이션 함수로 교체
  if (window.filterModelsByModality) {
    window.filterModelsByModality = window.filterAndScrollToModality;
  }

  // 검색 실행 함수
  async function runSearch(q) {
    if (!q || !q.trim()) {
      if (window.toast) {
        window.toast('검색어를 입력하세요', 'warning');
      }
      return;
    }

    // 검색어 유효성 검사
    if (!isValidSearchQuery(q)) {
      if (window.toast) {
        window.toast('검색이 유효하지 않습니다. 이미지, 비디오, 오디오, 임베딩, 텍스트 중 하나를 포함한 검색어를 입력해주세요.', 'error');
      }
      const container = document.getElementById('intent-recos');
      if (container) {
        container.innerHTML = '';
      }
      return;
    }

    // 검색어에서 모달리티 감지
    const detectedModality = detectModalityFromQuery(q);
    
    // 모달리티가 감지되면 바로 필터링 및 스크롤
    if (detectedModality) {
      window.filterAndScrollToModality(detectedModality);
      const modalityNames = {
        'IMAGE': '이미지',
        'VIDEO': '비디오',
        'AUDIO': '오디오',
        'EMBEDDING': '임베딩',
        'TEXT': '텍스트'
      };
      if (window.toast) {
        window.toast(`${modalityNames[detectedModality] || detectedModality} 모델을 찾았습니다`, 'success');
      }
    }

    const container = document.getElementById('intent-recos');
    if (!container) return;

    try {
      container.innerHTML = '<div class="loading-shimmer" style="height: 200px; border-radius: 12px;"></div>';
      
      const response = await fetch(`/AI/api/search.jsp?q=${encodeURIComponent(q)}`);
      if (!response.ok) throw new Error('Network error');
      
      const data = await response.json();
      
      if (data.error) {
        if (window.toast) {
          window.toast(data.error, 'error');
        }
        container.innerHTML = '';
        return;
      }

      // 추천 섹션 렌더링
      if (window.renderIntentSections) {
        window.renderIntentSections(container, data.intent, data, q);
        // GSAP는 렌더링 후에만 로드
        if (window.loadGSAPInit) {
          window.loadGSAPInit().catch(() => {});
        }
      } else {
        container.innerHTML = `<h2>${data.intentTitle || '추천 결과'}</h2><p>모델 ${data.models.length}개, 패키지 ${data.packages.length}개</p>`;
      }
    } catch (error) {
      console.error('Search error:', error);
      let errorMessage = '검색 중 오류가 발생했습니다';
      if (error.message) {
        errorMessage += ': ' + error.message;
      }
      if (window.toast) {
        window.toast(errorMessage, 'error');
      }
      if (container) container.innerHTML = '';
    }
  }

  // 검색 이벤트 초기화
  function initSearch() {
    const input = document.getElementById('kvSearchInput') || document.getElementById('searchInput');
    const searchBtn = document.getElementById('kvSearchBtn') || document.getElementById('searchBtn');

    if (searchBtn && input) {
      searchBtn.addEventListener('click', () => {
        runSearch(input.value.trim());
      });

      input.addEventListener('keypress', (e) => {
        if (e.key === 'Enter') {
          runSearch(input.value.trim());
        }
      });
    }
  }

  // 모델 스크롤 네비게이션 초기화
  function initModelScrollNavigation(containerId, scrollId, leftBtnId, rightBtnId) {
    const container = document.getElementById(containerId);
    const scroll = document.getElementById(scrollId);
    if (!container || !scroll) return;

    let autoScrollInterval = null;
    let isPaused = false;
    const scrollSpeed = 1;
    const scrollDelay = 20;

    const leftBtn = document.getElementById(leftBtnId);
    const rightBtn = document.getElementById(rightBtnId);

    const updateButtons = () => {
      const maxScroll = scroll.scrollWidth - container.clientWidth;
      if (leftBtn) leftBtn.disabled = container.scrollLeft <= 0;
      if (rightBtn) rightBtn.disabled = container.scrollLeft >= maxScroll - 5;
    };

    function startAutoScroll() {
      if (autoScrollInterval) return;
      
      autoScrollInterval = setInterval(() => {
        if (!isPaused && container.scrollLeft < scroll.scrollWidth - container.clientWidth) {
          container.scrollLeft += scrollSpeed;
        } else if (container.scrollLeft >= scroll.scrollWidth - container.clientWidth) {
          container.scrollLeft = 0;
        }
      }, scrollDelay);
    }

    function pauseAutoScroll() {
      isPaused = true;
    }

    function resumeAutoScroll() {
      isPaused = false;
    }

    container.addEventListener('mouseenter', pauseAutoScroll);
    container.addEventListener('mouseleave', resumeAutoScroll);

    updateButtons();
    container.addEventListener('scroll', updateButtons);

    if (leftBtn) {
      leftBtn.addEventListener('click', () => {
        pauseAutoScroll();
        container.scrollBy({ left: -420, behavior: 'smooth' });
        setTimeout(resumeAutoScroll, 1000);
      });
    }

    if (rightBtn) {
      rightBtn.addEventListener('click', () => {
        pauseAutoScroll();
        container.scrollBy({ left: 420, behavior: 'smooth' });
        setTimeout(resumeAutoScroll, 1000);
      });
    }

    window.addEventListener('resize', updateButtons);

    setTimeout(startAutoScroll, 1000);
  }

  // 모델 상세 모달 초기화
  function initModelDetailModal() {
    const modal = document.getElementById('modelDetailModal');
    if (!modal) return;

    const closeBtn = document.getElementById('modelDetailModalClose');
    const overlay = modal.querySelector('.model-detail-modal-overlay');
    
    function closeModal() {
      modal.style.display = 'none';
      document.body.style.overflow = '';
    }
    
    if (closeBtn) {
      closeBtn.addEventListener('click', closeModal);
    }
    if (overlay) {
      overlay.addEventListener('click', closeModal);
    }
    
    document.addEventListener('keydown', function(e) {
      if (e.key === 'Escape' && modal.style.display === 'flex') {
        closeModal();
      }
    });

    // 모델 카드 클릭 시 모달 열기
    document.querySelectorAll('.model-item[data-model-id]').forEach(card => {
      card.addEventListener('click', function(e) {
        if (e.target.closest('.model-item-actions')) return;
        
        const modelId = this.getAttribute('data-model-id');
        const modelName = this.getAttribute('data-model-name');
        const modelProvider = this.getAttribute('data-model-provider');
        const modelCategory = this.getAttribute('data-model-category');
        const modelDescription = this.getAttribute('data-model-description');
        const modelPrice = this.getAttribute('data-model-price');
        const modelPriceUsd = parseFloat(this.getAttribute('data-model-price-usd')) || 0;
        const modelApi = this.getAttribute('data-model-api') === 'true';
        const modelFinetune = this.getAttribute('data-model-finetune') === 'true';
        const modelOnprem = this.getAttribute('data-model-onprem') === 'true';
        const modelInput = this.getAttribute('data-model-input');
        const modelOutput = this.getAttribute('data-model-output');
        const modelParams = this.getAttribute('data-model-params');
        const modelLatency = this.getAttribute('data-model-latency');
        const modelHomepage = this.getAttribute('data-model-homepage');
        const modelDocs = this.getAttribute('data-model-docs');
        const modelPlayground = this.getAttribute('data-model-playground');
        
        const img = this.querySelector('.model-item-image img');
        const modelImage = img ? img.src : '/AI/assets/img/placeholder.png';
        
        let featuresHtml = '';
        if (modelInput || modelOutput || modelParams || modelLatency) {
          featuresHtml = '<section class="model-detail-modal-section">' +
            '<h2>기능</h2>' +
            '<ul class="model-detail-modal-specs">' +
            (modelInput ? '<li><strong>입력:</strong> ' + escapeHtml(modelInput) + '</li>' : '') +
            (modelOutput ? '<li><strong>출력:</strong> ' + escapeHtml(modelOutput) + '</li>' : '') +
            (modelParams ? '<li><strong>파라미터:</strong> ' + escapeHtml(modelParams) + 'B</li>' : '') +
            (modelLatency ? '<li><strong>지연시간:</strong> ' + escapeHtml(modelLatency) + 'ms</li>' : '') +
            '</ul>' +
            '</section>';
        }
        
        let linksHtml = '';
        if (modelHomepage || modelDocs || modelPlayground) {
          linksHtml = '<section class="model-detail-modal-section">' +
            '<h2>링크 및 리소스</h2>' +
            '<ul class="model-detail-modal-specs">' +
            (modelHomepage ? '<li><a href="' + escapeHtml(modelHomepage) + '" target="_blank" style="color: var(--accent);">홈페이지</a></li>' : '') +
            (modelDocs ? '<li><a href="' + escapeHtml(modelDocs) + '" target="_blank" style="color: var(--accent);">문서</a></li>' : '') +
            (modelPlayground ? '<li><a href="' + escapeHtml(modelPlayground) + '" target="_blank" style="color: var(--accent);">플레이그라운드</a></li>' : '') +
            '</ul>' +
            '</section>';
        }
        
        const categoryText = modelCategory ? ' · ' + escapeHtml(modelCategory) : '';
        const content = 
          '<div class="model-detail-modal-hero">' +
            '<div class="model-detail-modal-image">' +
              '<img src="' + escapeHtml(modelImage) + '" alt="' + escapeHtml(modelName) + '" onerror="this.style.display=\'none\'; this.nextElementSibling.style.display=\'flex\';">' +
              '<div style="display: none; width: 100%; height: 100%; background: var(--surface); align-items: center; justify-content: center; font-size: 4rem;">🤖</div>' +
            '</div>' +
            '<h1 class="model-detail-modal-title">' + escapeHtml(modelName) + '</h1>' +
            '<p class="model-detail-modal-subtitle">' + escapeHtml(modelProvider) + categoryText + '</p>' +
          '</div>' +
          '<div class="model-detail-modal-body">' +
            '<section class="model-detail-modal-section">' +
              '<h2>설명</h2>' +
              '<p>' + escapeHtml(modelDescription) + '</p>' +
            '</section>' +
            '<section class="model-detail-modal-section">' +
              '<h2>가격 및 이용 가능 여부</h2>' +
              '<ul class="model-detail-modal-specs">' +
                '<li><strong>가격:</strong> ' + escapeHtml(modelPrice) + '</li>' +
                '<li><strong>API 이용 가능:</strong> ' + (modelApi ? '가능' : '불가능') + '</li>' +
                '<li><strong>파인튜닝:</strong> ' + (modelFinetune ? '가능' : '불가능') + '</li>' +
                '<li><strong>온프레미스:</strong> ' + (modelOnprem ? '가능' : '불가능') + '</li>' +
              '</ul>' +
            '</section>' +
            featuresHtml +
            linksHtml +
          '</div>' +
          '<div class="model-detail-modal-actions">' +
            '<form method="GET" action="/AI/user/modelDetail.jsp" style="display: inline;">' +
              '<input type="hidden" name="id" value="' + escapeHtml(modelId) + '">' +
              '<input type="hidden" name="action" value="addToCart">' +
              '<button type="submit" class="btn btn-primary">장바구니에 추가</button>' +
            '</form>' +
            '<form method="GET" action="/AI/user/modelDetail.jsp" style="display: inline;">' +
              '<input type="hidden" name="id" value="' + escapeHtml(modelId) + '">' +
              '<input type="hidden" name="action" value="checkout">' +
              '<button type="submit" class="btn btn-secondary">바로 결제하기</button>' +
            '</form>' +
          '</div>';
        
        const contentEl = document.getElementById('modelDetailContent');
        if (contentEl) {
          contentEl.innerHTML = content;
        }
        modal.style.display = 'flex';
        document.body.style.overflow = 'hidden';
      });
    });
  }

  // GSAP 지연 로딩
  let gsapInitLoaded = false;
  window.loadGSAPInit = async function() {
    if (!gsapInitLoaded) {
      await import('/AI/assets/js/gsap-init.js');
      gsapInitLoaded = true;
    }
  };

  // 초기화
  document.addEventListener('DOMContentLoaded', function() {
    initSearch();
    initModelDetailModal();
    
    if ('requestIdleCallback' in window) {
      requestIdleCallback(() => {
        initModelScrollNavigation('modelItemsContainer', 'modelItemsScroll', 'mainScrollLeft', 'mainScrollRight');
      }, { timeout: 2000 });
    } else {
      setTimeout(() => {
        initModelScrollNavigation('modelItemsContainer', 'modelItemsScroll', 'mainScrollLeft', 'mainScrollRight');
      }, 500);
    }
  });
})();
