# Task 02: P1 Rate Limiting 구현 + 에러 페이지 생성

## 프로젝트 경로
`/var/lib/tomcat9/webapps/ROOT/`

## 기술 스택
- Java 11, Tomcat 9.0.58, javax.servlet, JSP

---

## 작업 2-1: Rate Limiting 필터 구현

### 새 파일: `WEB-INF/src/filter/RateLimitFilter.java`

```java
package filter;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicLong;

/**
 * IP 기반 + 사용자 기반 Rate Limiting 필터
 * - 로그인 API: IP당 5회/분
 * - 일반 API: IP당 60회/분
 */
public class RateLimitFilter implements Filter {

    // IP별 요청 기록: IP -> [카운트, 윈도우시작시간]
    private final ConcurrentHashMap<String, long[]> requestCounts = new ConcurrentHashMap<>();

    // 로그인 경로 전용 제한
    private final ConcurrentHashMap<String, long[]> loginCounts = new ConcurrentHashMap<>();

    private static final int GENERAL_LIMIT = 60;      // 일반 요청: 60회/분
    private static final int LOGIN_LIMIT = 5;          // 로그인 요청: 5회/분
    private static final long WINDOW_MS = 60_000L;     // 1분 윈도우
    private static final long CLEANUP_INTERVAL = 300_000L; // 5분마다 정리
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

        // 오래된 엔트리 정리
        cleanupIfNeeded();

        // 로그인 경로 특별 제한
        boolean isLoginPath = path.contains("/login") || path.contains("/auth/login");
        if (isLoginPath && "POST".equals(httpReq.getMethod())) {
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
                return new long[]{1, now}; // 새 윈도우 시작
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
```

### web.xml에 필터 추가 (SecurityHeadersFilter 바로 뒤에):
```xml
<filter>
    <filter-name>RateLimitFilter</filter-name>
    <filter-class>filter.RateLimitFilter</filter-class>
</filter>
<filter-mapping>
    <filter-name>RateLimitFilter</filter-name>
    <url-pattern>/AI/*</url-pattern>
</filter-mapping>
```

---

## 작업 2-2: 에러 페이지 생성

### 새 파일: `AI/error/404.jsp`
```jsp
<%@ page contentType="text/html; charset=UTF-8" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>페이지를 찾을 수 없습니다 - AI Workflow Lab</title>
    <link rel="icon" href="data:,">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link rel="stylesheet" href="/AI/assets/css/dark-theme.css">
    <link rel="stylesheet" href="/AI/assets/css/user.css">
</head>
<body>
    <main style="width: min(600px, 100%); margin: 0 auto; padding: 120px 22px; text-align: center;">
        <div class="glass-card" style="padding: 60px 48px;">
            <i class="bi bi-emoji-frown" style="font-size: 64px; color: var(--accent); display: block; margin-bottom: 24px;"></i>
            <h1 style="font-size: 48px; font-weight: 700; margin-bottom: 12px;">404</h1>
            <h2 style="font-size: 24px; margin-bottom: 16px; color: var(--text);">페이지를 찾을 수 없습니다</h2>
            <p style="color: var(--text-secondary); margin-bottom: 32px; line-height: 1.6;">
                요청하신 페이지가 존재하지 않거나 이동되었습니다.<br>
                URL을 확인하고 다시 시도해주세요.
            </p>
            <div style="display: flex; gap: 12px; justify-content: center; flex-wrap: wrap;">
                <a href="/AI/user/home.jsp" class="btn primary">
                    <i class="bi bi-house me-1"></i>홈으로 이동
                </a>
                <a href="javascript:history.back()" class="btn" style="border: 1px solid var(--border); color: var(--text);">
                    <i class="bi bi-arrow-left me-1"></i>이전 페이지
                </a>
            </div>
        </div>
    </main>
</body>
</html>
```

### 새 파일: `AI/error/500.jsp`
```jsp
<%@ page contentType="text/html; charset=UTF-8" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>서버 오류 - AI Workflow Lab</title>
    <link rel="icon" href="data:,">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link rel="stylesheet" href="/AI/assets/css/dark-theme.css">
    <link rel="stylesheet" href="/AI/assets/css/user.css">
</head>
<body>
    <main style="width: min(600px, 100%); margin: 0 auto; padding: 120px 22px; text-align: center;">
        <div class="glass-card" style="padding: 60px 48px;">
            <i class="bi bi-exclamation-triangle" style="font-size: 64px; color: #ff3b30; display: block; margin-bottom: 24px;"></i>
            <h1 style="font-size: 48px; font-weight: 700; margin-bottom: 12px;">500</h1>
            <h2 style="font-size: 24px; margin-bottom: 16px; color: var(--text);">서버 오류가 발생했습니다</h2>
            <p style="color: var(--text-secondary); margin-bottom: 32px; line-height: 1.6;">
                일시적인 서버 문제가 발생했습니다.<br>
                잠시 후 다시 시도해주세요.
            </p>
            <a href="/AI/user/home.jsp" class="btn primary">
                <i class="bi bi-house me-1"></i>홈으로 이동
            </a>
        </div>
    </main>
</body>
</html>
```

### 새 파일: `AI/error/403.jsp`
```jsp
<%@ page contentType="text/html; charset=UTF-8" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>접근 권한 없음 - AI Workflow Lab</title>
    <link rel="icon" href="data:,">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link rel="stylesheet" href="/AI/assets/css/dark-theme.css">
    <link rel="stylesheet" href="/AI/assets/css/user.css">
</head>
<body>
    <main style="width: min(600px, 100%); margin: 0 auto; padding: 120px 22px; text-align: center;">
        <div class="glass-card" style="padding: 60px 48px;">
            <i class="bi bi-shield-lock" style="font-size: 64px; color: #ff9500; display: block; margin-bottom: 24px;"></i>
            <h1 style="font-size: 48px; font-weight: 700; margin-bottom: 12px;">403</h1>
            <h2 style="font-size: 24px; margin-bottom: 16px; color: var(--text);">접근 권한이 없습니다</h2>
            <p style="color: var(--text-secondary); margin-bottom: 32px; line-height: 1.6;">
                이 페이지에 접근할 수 있는 권한이 없습니다.<br>
                로그인하거나 관리자에게 문의해주세요.
            </p>
            <div style="display: flex; gap: 12px; justify-content: center; flex-wrap: wrap;">
                <a href="/AI/user/login.jsp" class="btn primary">
                    <i class="bi bi-box-arrow-in-right me-1"></i>로그인
                </a>
                <a href="/AI/user/home.jsp" class="btn" style="border: 1px solid var(--border); color: var(--text);">
                    <i class="bi bi-house me-1"></i>홈으로
                </a>
            </div>
        </div>
    </main>
</body>
</html>
```

### web.xml에 에러 페이지 매핑 추가 (`</web-app>` 바로 전에):
```xml
<!-- 에러 페이지 설정 -->
<error-page>
    <error-code>404</error-code>
    <location>/AI/error/404.jsp</location>
</error-page>
<error-page>
    <error-code>403</error-code>
    <location>/AI/error/403.jsp</location>
</error-page>
<error-page>
    <error-code>500</error-code>
    <location>/AI/error/500.jsp</location>
</error-page>
<error-page>
    <exception-type>java.lang.Exception</exception-type>
    <location>/AI/error/500.jsp</location>
</error-page>
```

---

## 컴파일 및 테스트
```bash
cd /var/lib/tomcat9/webapps/ROOT

# RateLimitFilter 컴파일
javac -cp "WEB-INF/lib/*:/usr/share/tomcat9/lib/*" \
  -d WEB-INF/classes \
  WEB-INF/src/filter/RateLimitFilter.java

sudo systemctl restart tomcat9

# Rate Limit 테스트 (6번 연속 로그인 시도하면 429 반환)
for i in {1..6}; do
  curl -s -o /dev/null -w "%{http_code}" -X POST http://localhost:8080/AI/user/login.jsp
  echo ""
done

# 에러 페이지 테스트
curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/nonexistent-page
```
