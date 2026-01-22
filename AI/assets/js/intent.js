/**
 * Intent Parser - 검색 의도 추론
 * Rule-based intent inference
 */

/**
 * 검색어에서 의도 추론
 * @param {string} q - 검색어
 * @returns {string} 의도 (coding, writing, image, audio, data, general)
 */
export function inferIntent(q = "") {
  if (!q || typeof q !== 'string') {
    return 'general';
  }
  
  const s = q.toLowerCase();
  const kw = (k) => s.includes(k);
  
  // 코딩 관련
  if (kw('코딩') || kw('코드') || kw('프로그래') || kw('개발') || 
      kw('debug') || kw('coding') || kw('programming') || kw('개발자')) {
    return 'coding';
  }
  
  // 문서/작성 관련
  if (kw('문서') || kw('요약') || kw('리포트') || kw('작성') || 
      kw('번역') || kw('writing') || kw('summary') || kw('translate')) {
    return 'writing';
  }
  
  // 이미지 관련
  if (kw('이미지') || kw('그림') || kw('디자인') || kw('사진') || 
      kw('image') || kw('picture') || kw('design')) {
    return 'image';
  }
  
  // 오디오 관련
  if (kw('오디오') || kw('음성') || kw('tts') || kw('stt') || 
      kw('audio') || kw('voice') || kw('speech')) {
    return 'audio';
  }
  
  // 데이터/분석 관련
  if (kw('데이터') || kw('분석') || kw('sql') || kw('통계') || 
      kw('data') || kw('analytics') || kw('statistics')) {
    return 'data';
  }
  
  return 'general';
}

/**
 * 의도별 추천 카테고리 매핑
 */
export const INTENT_TO_CATS = {
  coding: ['Code Generation', 'Code Assistant', 'Debug', 'Doc Helper'],
  writing: ['Summarization', 'Translation', 'Rewrite', 'Text Generation'],
  image: ['Image Generation', 'Image Understanding', 'Image Edit'],
  audio: ['TTS', 'STT', 'Voice Clone', 'Audio Processing'],
  data: ['SQL', 'Analytics', 'Embedding', 'Data Analysis'],
  general: ['General AI', 'Multi-modal']
};

/**
 * 의도별 제목
 */
export function getIntentTitle(intent) {
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



