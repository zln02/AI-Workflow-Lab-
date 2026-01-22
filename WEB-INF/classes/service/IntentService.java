package service;

/**
 * 검색 의도 파서 (Rule 기반)
 */
public class IntentService {
  
  /**
   * 검색어에서 의도 추론
   * @param query 검색어
   * @return 의도 (coding, writing, image, audio, data, general)
   */
  public static String infer(String query) {
    if (query == null || query.trim().isEmpty()) {
      return "general";
    }
    
    String s = query.toLowerCase();
    
    // 코딩 관련
    if (containsAny(s, "코딩", "코드", "프로그래", "개발", "debug", "coding", "programming", "개발자")) {
      return "coding";
    }
    
    // 문서/작성 관련
    if (containsAny(s, "문서", "요약", "리포트", "작성", "번역", "writing", "summary", "translate", "번역")) {
      return "writing";
    }
    
    // 이미지 관련
    if (containsAny(s, "이미지", "그림", "디자인", "사진", "image", "picture", "design", "그림")) {
      return "image";
    }
    
    // 오디오 관련
    if (containsAny(s, "오디오", "음성", "tts", "stt", "audio", "voice", "speech", "음성")) {
      return "audio";
    }
    
    // 데이터/분석 관련
    if (containsAny(s, "데이터", "분석", "sql", "통계", "data", "analytics", "statistics", "데이터")) {
      return "data";
    }
    
    return "general";
  }
  
  /**
   * 의도별 추천 카테고리 이름 목록
   * @param intent 의도
   * @return 카테고리 이름 배열
   */
  public static String[] getRecommendedCategories(String intent) {
    switch (intent.toLowerCase()) {
      case "coding":
        return new String[]{"Code Generation", "Code Assistant", "Debug", "Doc Helper"};
      case "writing":
        return new String[]{"Summarization", "Translation", "Rewrite", "Text Generation"};
      case "image":
        return new String[]{"Image Generation", "Image Understanding", "Image Edit"};
      case "audio":
        return new String[]{"TTS", "STT", "Voice Clone", "Audio Processing"};
      case "data":
        return new String[]{"SQL", "Analytics", "Embedding", "Data Analysis"};
      default:
        return new String[]{"General AI", "Multi-modal"};
    }
  }
  
  /**
   * 의도별 제목
   * @param intent 의도
   * @return 제목
   */
  public static String getIntentTitle(String intent) {
    switch (intent.toLowerCase()) {
      case "coding":
        return "코딩에 적합한 AI 모델";
      case "writing":
        return "문서 작성에 적합한 AI 모델";
      case "image":
        return "이미지 작업에 적합한 AI 모델";
      case "audio":
        return "오디오 작업에 적합한 AI 모델";
      case "data":
        return "데이터 분석에 적합한 AI 모델";
      default:
        return "추천 AI 모델";
    }
  }
  
  private static boolean containsAny(String text, String... keywords) {
    for (String keyword : keywords) {
      if (text.contains(keyword)) {
        return true;
      }
    }
    return false;
  }
}



