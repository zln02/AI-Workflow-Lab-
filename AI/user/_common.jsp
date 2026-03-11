<%-- 
  Common utilities and includes for user pages
  Provides XSS prevention, CSRF protection, and common utilities
--%>
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="util.CSRFUtil" %>
<%@ page import="model.AIModel" %>
<%-- JSTL은 필요시에만 사용 (현재는 사용하지 않음) --%>
<%-- <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %> --%>
<%-- <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %> --%>

<%!
  /**
   * XSS 방지: HTML 특수문자 이스케이프 처리
   * @param input 이스케이프할 문자열
   * @return 이스케이프된 문자열 (null이면 빈 문자열 반환)
   */
  public String escapeHtml(String input) {
    if (input == null || input.isEmpty()) {
      return "";
    }
    // 순서 중요: &를 먼저 처리해야 다른 이스케이프 문자와 충돌 방지
    return input
      .replace("&", "&amp;")
      .replace("<", "&lt;")
      .replace(">", "&gt;")
      .replace("\"", "&quot;")
      .replace("'", "&#x27;");
  }
  
  /**
   * HTML 속성 값 이스케이프 (data-* 속성 등에 사용)
   * @param input 이스케이프할 문자열
   * @return 이스케이프된 문자열
   */
  public String escapeHtmlAttribute(String input) {
    if (input == null || input.isEmpty()) {
      return "";
    }
    return input
      .replace("&", "&amp;")
      .replace("\"", "&quot;")
      .replace("'", "&#x27;")
      .replace("<", "&lt;")
      .replace(">", "&gt;");
  }

  /**
   * JavaScript 문자열 리터럴용 이스케이프
   * @param input 이스케이프할 문자열
   * @return JS 문자열에 안전한 값
   */
  public String escapeJs(String input) {
    if (input == null || input.isEmpty()) {
      return "";
    }
    return input
      .replace("\\", "\\\\")
      .replace("\"", "\\\"")
      .replace("'", "\\'")
      .replace("\r", "\\r")
      .replace("\n", "\\n")
      .replace("</", "<\\/");
  }
  
  /**
   * CSRF 토큰 가져오기
   * @param session HTTP 세션
   * @return CSRF 토큰 문자열
   */
  public String getCSRFToken(HttpSession session) {
    return CSRFUtil.getToken(session);
  }
  
  /**
   * 안전한 문자열 반환 (null 체크 포함)
   * @param value 체크할 값
   * @param defaultValue null일 경우 반환할 기본값
   * @return 안전한 문자열
   */
  public String safeString(String value, String defaultValue) {
    return (value != null && !value.trim().isEmpty()) ? value.trim() : defaultValue;
  }
  
  /**
   * AI 모델의 모달리티 코드 결정
   * input/output modalities, 카테고리명, 모델명을 종합적으로 분석
   * @param model AI 모델 객체
   * @return 모달리티 코드 (TEXT, IMAGE, VIDEO, AUDIO 중 하나)
   */
  public String determineModalityCode(AIModel model) {
    if (model == null) {
      return "";
    }
    
    // 1순위: input/output modalities 확인
    String inputMods = (model.getInputModalities() != null) 
        ? model.getInputModalities().toUpperCase() : "";
    String outputMods = (model.getOutputModalities() != null) 
        ? model.getOutputModalities().toUpperCase() : "";
    
    if (inputMods.contains("AUDIO") || outputMods.contains("AUDIO")) {
      return "AUDIO";
    } else if (inputMods.contains("VIDEO") || outputMods.contains("VIDEO")) {
      return "VIDEO";
    } else if (inputMods.contains("IMAGE") || outputMods.contains("IMAGE")) {
      return "IMAGE";
    } else if (inputMods.contains("TEXT") || outputMods.contains("TEXT") 
        || inputMods.contains("CODE")) {
      return "TEXT";
    }
    
    // 2순위: 카테고리명으로 확인
    if (model.getCategoryName() != null) {
      String categoryName = model.getCategoryName().toUpperCase();
      if (categoryName.contains("AUDIO")) return "AUDIO";
      if (categoryName.contains("VIDEO")) return "VIDEO";
      if (categoryName.contains("IMAGE")) return "IMAGE";
      if (categoryName.contains("TEXT")) return "TEXT";
    }
    
    // 3순위: 모델명으로 확인
    if (model.getModelName() != null) {
      String modelName = model.getModelName().toUpperCase();
      if (modelName.contains("AUDIO")) return "AUDIO";
      if (modelName.contains("VIDEO")) return "VIDEO";
      if (modelName.contains("IMAGE")) return "IMAGE";
      if (modelName.contains("TEXT")) return "TEXT";
    }
    
    return "TEXT"; // 기본값
  }
  
  /**
   * Provider 이름에 따른 로고 파일명 매핑
   * @param providerName 제공사 이름
   * @return 로고 파일명 (확장자 제외)
   */
  public String getProviderLogoFileName(String providerName) {
    if (providerName == null || providerName.trim().isEmpty()) {
      return "default";
    }
    
    String normalized = providerName.toLowerCase().trim()
        .replace(" ", "").replace(".", "").replace("-", "");
    
    switch (normalized) {
      case "openai": return "openai";
      case "google": return "google";
      case "anthropic": return "anthropic";
      case "meta": return "meta";
      case "microsoft": return "microsoft";
      case "cohere": return "cohere";
      case "mistral": return "mistral";
      case "stability": return "stability";
      case "huggingface": return "huggingface";
      default: return "default";
    }
  }
  
  /**
   * Provider 도메인 매핑 (Favicon 서비스용)
   */
  private static final java.util.Map<String, String> PROVIDER_DOMAINS;
  static {
    PROVIDER_DOMAINS = new java.util.HashMap<>();
    PROVIDER_DOMAINS.put("openai",        "openai.com");
    PROVIDER_DOMAINS.put("anthropic",     "anthropic.com");
    PROVIDER_DOMAINS.put("google",        "google.com");
    PROVIDER_DOMAINS.put("meta",          "meta.com");
    PROVIDER_DOMAINS.put("microsoft",     "microsoft.com");
    PROVIDER_DOMAINS.put("github",        "github.com");
    PROVIDER_DOMAINS.put("githubmicrosoft", "github.com");
    PROVIDER_DOMAINS.put("midjourney",    "midjourney.com");
    PROVIDER_DOMAINS.put("midjourneylabs","midjourney.com");
    PROVIDER_DOMAINS.put("stabilityai",   "stability.ai");
    PROVIDER_DOMAINS.put("stability",     "stability.ai");
    PROVIDER_DOMAINS.put("mistralai",     "mistral.ai");
    PROVIDER_DOMAINS.put("mistral",       "mistral.ai");
    PROVIDER_DOMAINS.put("cohere",        "cohere.com");
    PROVIDER_DOMAINS.put("huggingface",   "huggingface.co");
    PROVIDER_DOMAINS.put("perplexity",    "perplexity.ai");
    PROVIDER_DOMAINS.put("xai",           "x.ai");
    PROVIDER_DOMAINS.put("canva",         "canva.com");
    PROVIDER_DOMAINS.put("adobe",         "adobe.com");
    PROVIDER_DOMAINS.put("notion",        "notion.so");
    PROVIDER_DOMAINS.put("anysphere",     "cursor.sh");
    PROVIDER_DOMAINS.put("codeium",       "codeium.com");
    PROVIDER_DOMAINS.put("replit",        "replit.com");
    PROVIDER_DOMAINS.put("elevenlabs",    "elevenlabs.io");
    PROVIDER_DOMAINS.put("suno",          "suno.ai");
    PROVIDER_DOMAINS.put("runway",        "runwayml.com");
    PROVIDER_DOMAINS.put("zapier",        "zapier.com");
  }

  /**
   * Provider 로고 정보 반환 — Favicon 서비스 우선
   * @param providerName 제공사 이름
   * @param modelName 모델명
   * @return [로고 경로, 제공사명] 배열
   */
  public String[] getProviderLogo(String providerName, String modelName) {
    if (providerName != null && !providerName.trim().isEmpty()) {
      String key = providerName.toLowerCase().trim()
          .replace(" ", "").replace(".", "").replace("-", "").replace("/","");
      String domain = PROVIDER_DOMAINS.get(key);
      if (domain != null) {
        return new String[]{"https://www.google.com/s2/favicons?domain=" + domain + "&sz=64", providerName};
      }
    }
    // fallback to local SVG
    String logoFileName = getProviderLogoFileName(providerName);
    String logoPath = "/AI/assets/img/providers/" + logoFileName + ".svg";
    return new String[]{logoPath, providerName != null ? providerName : "Unknown"};
  }
%>

<%
  // CSRF 토큰 세션에 보장
  String csrfToken = CSRFUtil.getToken(session);
  
  // 통화 설정 (요청 파라미터 또는 기본값 USD)
  String currency = request.getParameter("currency");
  if (currency == null || currency.trim().isEmpty()) {
    currency = "USD";
  }
%>
