package util;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;

/**
 * CSRF 토큰 유틸리티
 */
public class CSRFUtil {
    private static final String CSRF_TOKEN_SESSION_KEY = "csrf_token";
    private static final String CSRF_TOKEN_REQUEST_PARAM = "csrf_token";
    private static final SecureRandom secureRandom = new SecureRandom();
    
    /**
     * CSRF 토큰 생성
     * @return 생성된 토큰
     */
    public static String generateToken() {
        byte[] randomBytes = new byte[32];
        secureRandom.nextBytes(randomBytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(randomBytes);
    }
    
    /**
     * 세션에 CSRF 토큰 저장
     * @param request HttpServletRequest
     * @return 생성된 토큰
     */
    public static String setToken(HttpServletRequest request) {
        String token = generateToken();
        HttpSession session = request.getSession(true);
        session.setAttribute(CSRF_TOKEN_SESSION_KEY, token);
        return token;
    }
    
    /**
     * 세션에서 CSRF 토큰 가져오기
     * @param request HttpServletRequest
     * @return 토큰
     */
    public static String getToken(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return null;
        }
        return (String) session.getAttribute(CSRF_TOKEN_SESSION_KEY);
    }

    /**
     * 세션에서 CSRF 토큰 가져오기 (HttpSession 오버로드)
     * @param session HttpSession
     * @return 토큰
     */
    public static String getToken(HttpSession session) {
        if (session == null) {
            return null;
        }
        return (String) session.getAttribute(CSRF_TOKEN_SESSION_KEY);
    }
    
    /**
     * CSRF 토큰 검증
     * @param request HttpServletRequest
     * @return 검증 결과
     */
    public static boolean validateToken(HttpServletRequest request) {
        String sessionToken = getToken(request);
        String requestToken = request.getParameter(CSRF_TOKEN_REQUEST_PARAM);
        return validateToken(sessionToken, requestToken);
    }

    public static boolean validateToken(HttpServletRequest request, String requestToken) {
        return validateToken(getToken(request), requestToken);
    }

    private static boolean validateToken(String sessionToken, String requestToken) {
        if (sessionToken == null || requestToken == null) {
            return false;
        }
        return MessageDigest.isEqual(sessionToken.getBytes(), requestToken.getBytes());
    }
    
    /**
     * CSRF 토큰 파라미터 이름
     * @return 파라미터 이름
     */
    public static String getTokenParamName() {
        return CSRF_TOKEN_REQUEST_PARAM;
    }
    
    /**
     * 히든 필드 HTML 생성
     * @param request HttpServletRequest
     * @return CSRF 히든 필드 HTML
     */
    public static String getHiddenFieldHtml(HttpServletRequest request) {
        String token = getToken(request);
        if (token == null) {
            token = setToken(request);
        }
        return "<input type=\"hidden\" name=\"" + CSRF_TOKEN_REQUEST_PARAM + "\" value=\"" + token + "\" />";
    }
}
