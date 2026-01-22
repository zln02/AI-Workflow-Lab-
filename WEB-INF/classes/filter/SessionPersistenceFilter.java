package filter;

import java.io.IOException;
import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * 세션 유지 필터
 * 모든 요청에서 세션을 활성화하여 로그인 상태를 유지
 */
public class SessionPersistenceFilter implements Filter {
  
  @Override
  public void init(FilterConfig filterConfig) throws ServletException {
    // 초기화 로직 없음
  }

  @Override
  public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
      throws IOException, ServletException {
    
    HttpServletRequest httpRequest = (HttpServletRequest) request;
    HttpServletResponse httpResponse = (HttpServletResponse) response;
    
    // 세션이 존재하지 않으면 생성 (getSession(true)는 세션이 없으면 생성)
    // 세션이 존재하면 기존 세션 반환 (타임아웃 갱신)
    HttpSession session = httpRequest.getSession(true);
    
    // 세션을 터치하여 타임아웃 갱신 (마지막 접근 시간 업데이트)
    // 세션에 아무 속성이 없더라도 세션을 활성화
    session.setAttribute("_lastAccess", System.currentTimeMillis());
    
    chain.doFilter(request, response);
  }

  @Override
  public void destroy() {
    // 정리 로직 없음
  }
}


