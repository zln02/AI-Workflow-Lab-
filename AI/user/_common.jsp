<%-- 
  Common utilities and includes for user pages
  Provides XSS prevention, CSRF protection, and common utilities
--%>
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="util.CSRFUtil" %>
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

