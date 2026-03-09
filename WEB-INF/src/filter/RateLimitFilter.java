package filter;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.concurrent.ConcurrentHashMap;

/**
 * IP 기반 Rate Limiting 필터
 * - 로그인 API: IP당 5회/분
 * - 일반 API: IP당 60회/분
 */
public class RateLimitFilter implements Filter {

    private final ConcurrentHashMap<String, long[]> requestCounts = new ConcurrentHashMap<>();
    private final ConcurrentHashMap<String, long[]> loginCounts = new ConcurrentHashMap<>();

    private static final int GENERAL_LIMIT = 60;
    private static final int LOGIN_LIMIT = 5;
    private static final long WINDOW_MS = 60_000L;
    private static final long CLEANUP_INTERVAL = 300_000L;
    private long lastCleanup = System.currentTimeMillis();

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpReq = (HttpServletRequest) request;
        HttpServletResponse httpRes = (HttpServletResponse) response;

        String clientIp = getClientIp(httpReq);
        String path = httpReq.getRequestURI();

        // 정적 리소스는 제한 없음
        if (path.contains("/assets/") || path.endsWith(".css") || path.endsWith(".js")
            || path.endsWith(".png") || path.endsWith(".jpg") || path.endsWith(".svg")
            || path.endsWith(".ico") || path.endsWith(".woff2")) {
            chain.doFilter(request, response);
            return;
        }

        cleanupIfNeeded();

        // 로그인 경로 특별 제한
        if ((path.contains("/login") || path.contains("/auth/login")) && "POST".equals(httpReq.getMethod())) {
            if (!checkRate(loginCounts, clientIp, LOGIN_LIMIT)) {
                httpRes.setStatus(429);
                httpRes.setContentType("application/json; charset=UTF-8");
                httpRes.getWriter().write("{\"error\":\"너무 많은 로그인 시도입니다. 1분 후 다시 시도해주세요.\"}");
                return;
            }
        }

        // 일반 요청 제한
        if (!checkRate(requestCounts, clientIp, GENERAL_LIMIT)) {
            httpRes.setStatus(429);
            httpRes.setContentType("application/json; charset=UTF-8");
            httpRes.setHeader("Retry-After", "60");
            httpRes.getWriter().write("{\"error\":\"요청이 너무 많습니다. 잠시 후 다시 시도해주세요.\"}");
            return;
        }

        chain.doFilter(request, response);
    }

    private boolean checkRate(ConcurrentHashMap<String, long[]> counts, String key, int limit) {
        long now = System.currentTimeMillis();
        long[] record = counts.compute(key, (k, v) -> {
            if (v == null || (now - v[1]) > WINDOW_MS) {
                return new long[]{1, now};
            }
            v[0]++;
            return v;
        });
        return record[0] <= limit;
    }

    private String getClientIp(HttpServletRequest request) {
        String xff = request.getHeader("X-Forwarded-For");
        if (xff != null && !xff.isEmpty()) {
            return xff.split(",")[0].trim();
        }
        String realIp = request.getHeader("X-Real-IP");
        if (realIp != null && !realIp.isEmpty()) {
            return realIp;
        }
        return request.getRemoteAddr();
    }

    private void cleanupIfNeeded() {
        long now = System.currentTimeMillis();
        if (now - lastCleanup > CLEANUP_INTERVAL) {
            lastCleanup = now;
            requestCounts.entrySet().removeIf(e -> (now - e.getValue()[1]) > WINDOW_MS * 2);
            loginCounts.entrySet().removeIf(e -> (now - e.getValue()[1]) > WINDOW_MS * 2);
        }
    }

    @Override
    public void destroy() {
        requestCounts.clear();
        loginCounts.clear();
    }
}
