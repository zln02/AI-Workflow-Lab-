package filter;

import java.io.IOException;
import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class CacheControlFilter implements Filter {
  @Override
  public void init(FilterConfig filterConfig) throws ServletException {}

  @Override
  public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
      throws IOException, ServletException {
    HttpServletRequest httpRequest = (HttpServletRequest) request;
    HttpServletResponse httpResponse = (HttpServletResponse) response;
    
    String uri = httpRequest.getRequestURI();
    
    // 정적 리소스에 캐싱 헤더 추가
    if (uri != null && (
        uri.endsWith(".css") ||
        uri.endsWith(".js") ||
        uri.endsWith(".png") ||
        uri.endsWith(".jpg") ||
        uri.endsWith(".jpeg") ||
        uri.endsWith(".gif") ||
        uri.endsWith(".svg") ||
        uri.endsWith(".ico") ||
        uri.endsWith(".woff") ||
        uri.endsWith(".woff2") ||
        uri.endsWith(".ttf") ||
        uri.endsWith(".eot")
    )) {
      // 1년 캐싱 (31536000초)
      httpResponse.setHeader("Cache-Control", "public, max-age=31536000, immutable");
      httpResponse.setHeader("Expires", "Thu, 31 Dec 2025 23:59:59 GMT");
      httpResponse.setHeader("Pragma", "public");
    } else if (uri != null && uri.endsWith(".jsp")) {
      // JSP 페이지는 캐싱하지 않음
      httpResponse.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
      httpResponse.setHeader("Pragma", "no-cache");
      httpResponse.setDateHeader("Expires", 0);
    }
    
    chain.doFilter(request, response);
  }

  @Override
  public void destroy() {}
}

