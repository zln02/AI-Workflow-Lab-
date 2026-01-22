package util;

import javax.servlet.http.HttpSession;
import java.util.UUID;

public class CSRFUtil {
  private static final String CSRF_TOKEN_ATTR = "csrf";
  
  /**
   * Get or create CSRF token for the session
   */
  public static String getToken(HttpSession session) {
    if (session == null) {
      return null;
    }
    
    String token = (String) session.getAttribute(CSRF_TOKEN_ATTR);
    if (token == null || token.isEmpty()) {
      token = UUID.randomUUID().toString();
      session.setAttribute(CSRF_TOKEN_ATTR, token);
    }
    return token;
  }
  
  /**
   * Validate CSRF token
   */
  public static boolean validateToken(HttpSession session, String submittedToken) {
    if (session == null || submittedToken == null || submittedToken.isEmpty()) {
      return false;
    }
    
    String sessionToken = (String) session.getAttribute(CSRF_TOKEN_ATTR);
    return sessionToken != null && sessionToken.equals(submittedToken);
  }
  
  /**
   * Regenerate CSRF token (for logout or security refresh)
   */
  public static String regenerateToken(HttpSession session) {
    if (session == null) {
      return null;
    }
    
    String token = UUID.randomUUID().toString();
    session.setAttribute(CSRF_TOKEN_ATTR, token);
    return token;
  }
}

