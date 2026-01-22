package filter;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.User;

import java.io.IOException;

/**
 * 사용자 인증 필터
 * 보호된 경로 접근 시 로그인 확인
 */
public class UserAuthFilter implements Filter {
  
  // 보호된 경로 목록
  private static final String[] PROTECTED_PATHS = {
    "/AI/user/cart.jsp",
    "/AI/user/checkout.jsp",
    "/AI/user/pricing.jsp",
    "/AI/user/mypage.jsp"
  };

  @Override
  public void init(FilterConfig filterConfig) throws ServletException {
    // 초기화 로직 없음
  }

  @Override
  public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
      throws IOException, ServletException {
    
    HttpServletRequest httpRequest = (HttpServletRequest) request;
    HttpServletResponse httpResponse = (HttpServletResponse) response;
    String requestPath = httpRequest.getRequestURI();
    
    // 보호된 경로인지 확인
    boolean isProtected = false;
    for (String protectedPath : PROTECTED_PATHS) {
      if (requestPath.contains(protectedPath) || requestPath.equals(protectedPath)) {
        isProtected = true;
        break;
      }
    }
    
    // 보호된 경로가 아니면 통과
    if (!isProtected) {
      chain.doFilter(request, response);
      return;
    }
    
    // 세션에서 사용자 확인
    HttpSession session = httpRequest.getSession(false);
    User user = null;
    
    if (session != null) {
      Object userObj = session.getAttribute("user");
      if (userObj instanceof User) {
        user = (User) userObj;
      }
    }
    
    // 로그인하지 않은 경우 로그인 페이지로 리다이렉트
    if (user == null || !user.isActive()) {
      String loginUrl = httpRequest.getContextPath() + "/user/login.jsp";
      String redirectUrl = loginUrl + "?redirect=" + java.net.URLEncoder.encode(requestPath, "UTF-8");
      httpResponse.sendRedirect(redirectUrl);
      return;
    }
    
    // 로그인한 경우 통과
    chain.doFilter(request, response);
  }

  @Override
  public void destroy() {
    // 정리 로직 없음
  }
}



