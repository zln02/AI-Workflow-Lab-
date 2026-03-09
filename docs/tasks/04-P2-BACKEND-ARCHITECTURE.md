# Task 04: P2 백엔드 아키텍처 개선

## 프로젝트 경로
`/var/lib/tomcat9/webapps/ROOT/`

---

## 작업 4-1: API JSP -> Servlet 마이그레이션

현재 `AI/api/` 디렉토리의 JSP 파일들이 비즈니스 로직 + DB 접근을 직접 수행함.
이를 Servlet + Service 패턴으로 분리.

### 마이그레이션 대상 파일:

| 현재 JSP | 변환할 Servlet | 메서드 |
|----------|---------------|--------|
| `AI/api/search.jsp` | `servlet.SearchServlet` | GET |
| `AI/api/categories.jsp` | `servlet.CategoryServlet` | GET |
| `AI/api/models.jsp` | `servlet.ModelServlet` | GET |
| `AI/api/packages.jsp` | (기존 PackagesServlet 활용) | GET |
| `AI/api/recommend.jsp` | `servlet.RecommendServlet` | GET |
| `AI/api/cart-summary.jsp` | `servlet.CartServlet` | GET |
| `AI/api/order-update.jsp` | `servlet.OrderServlet` | PUT |
| `AI/api/order-delete.jsp` | `servlet.OrderServlet` | DELETE |
| `AI/api/sales-statistics.jsp` | `servlet.StatisticsServlet` | GET |
| `AI/api/subscribe.jsp` | (Task 03에서 PaymentServlet으로 대체) | POST |
| `AI/api/subscription-update.jsp` | `servlet.SubscriptionServlet` | PUT |
| `AI/api/recent-orders.jsp` | `servlet.OrderServlet` | GET /recent |

### 공통 패턴 (각 Servlet에 적용):

```java
package servlet;

import dto.ApiResponse;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;

@WebServlet("/api/endpoint/*")
public class ExampleServlet extends HttpServlet {
    private Gson gson;

    @Override
    public void init() {
        gson = new GsonBuilder().setDateFormat("yyyy-MM-dd HH:mm:ss").create();
    }

    // JSON body 읽기 헬퍼
    protected String readBody(HttpServletRequest request) throws IOException {
        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) sb.append(line);
        }
        return sb.toString();
    }

    // 세션에서 로그인 사용자 확인
    protected model.User getLoggedInUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return null;
        model.User user = (model.User) session.getAttribute("user");
        return (user != null && user.isActive()) ? user : null;
    }

    // 관리자 확인
    protected boolean isAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null && session.getAttribute("admin") != null;
    }

    // JSON 응답 보내기
    protected void sendJson(HttpServletResponse response, int status, Object data) throws IOException {
        response.setContentType("application/json; charset=UTF-8");
        response.setStatus(status);
        response.getWriter().print(gson.toJson(data));
    }
}
```

### 예시: SearchServlet.java

```java
package servlet;

import dao.SearchDAO;
import dao.SearchLogDAO;
import dto.ApiResponse;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import util.EscapeUtil;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/api/search")
public class SearchServlet extends HttpServlet {
    private SearchDAO searchDAO;
    private SearchLogDAO searchLogDAO;
    private Gson gson;

    @Override
    public void init() {
        searchDAO = new SearchDAO();
        searchLogDAO = new SearchLogDAO();
        gson = new GsonBuilder().setDateFormat("yyyy-MM-dd HH:mm:ss").create();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json; charset=UTF-8");

        String keyword = request.getParameter("q");
        if (keyword == null || keyword.trim().isEmpty()) {
            sendJson(response, 400, ApiResponse.badRequest("검색어를 입력해주세요."));
            return;
        }

        // 검색어 길이 제한
        if (keyword.length() > 100) {
            keyword = keyword.substring(0, 100);
        }

        try {
            List<Map<String, Object>> results = searchDAO.search(keyword.trim());

            // 검색 로그 저장
            searchLogDAO.logSearch(keyword.trim(), results.size());

            sendJson(response, 200, ApiResponse.success(results));
        } catch (Exception e) {
            e.printStackTrace();
            sendJson(response, 500, ApiResponse.error("검색 중 오류가 발생했습니다."));
        }
    }

    private void sendJson(HttpServletResponse response, int status, Object data) throws IOException {
        response.setStatus(status);
        response.getWriter().print(gson.toJson(data));
    }
}
```

**각 JSP 파일을 읽고 동일한 패턴으로 Servlet으로 변환하세요.**
- 기존 JSP 파일의 비즈니스 로직을 그대로 Servlet으로 이동
- 입력 검증 추가 (null 체크, 길이 제한, 화이트리스트)
- try-with-resources 패턴 유지
- 에러 응답에 적절한 HTTP 상태 코드 사용

### web.xml 업데이트

마이그레이션한 모든 Servlet의 매핑을 web.xml에 추가:
```xml
<servlet>
    <servlet-name>SearchServlet</servlet-name>
    <servlet-class>servlet.SearchServlet</servlet-class>
</servlet>
<servlet-mapping>
    <servlet-name>SearchServlet</servlet-name>
    <url-pattern>/api/search</url-pattern>
</servlet-mapping>

<!-- 나머지도 동일 패턴 -->
```

기존 API JSP 파일들은 삭제하지 말고 Servlet이 정상 동작 확인 후 삭제.

---

## 작업 4-2: Service 레이어 추가

### 새 파일들:

#### `WEB-INF/src/service/ToolService.java`
```java
package service;

import dao.AIToolDAO;
import model.AITool;
import java.sql.SQLException;
import java.util.List;

public class ToolService {
    private final AIToolDAO toolDAO = new AIToolDAO();

    public List<AITool> search(String keyword, String category, String difficulty) throws SQLException {
        if (keyword != null && !keyword.trim().isEmpty()) {
            return toolDAO.searchByKeyword(keyword.trim());
        }
        if (category != null && !category.trim().isEmpty()) {
            return toolDAO.findByCategory(category.trim());
        }
        if (difficulty != null && !difficulty.trim().isEmpty()) {
            return toolDAO.findByDifficulty(difficulty.trim());
        }
        return toolDAO.findAll();
    }

    public AITool getById(int id) throws SQLException {
        return toolDAO.findById(id);
    }

    public List<AITool> getPopular(int limit) throws SQLException {
        return toolDAO.findPopular(Math.min(50, Math.max(1, limit)));
    }

    public List<AITool> recommend(String query, String difficulty, String category) throws SQLException {
        if (query == null || query.trim().isEmpty()) {
            throw new IllegalArgumentException("검색어가 필요합니다.");
        }
        return toolDAO.recommendTools(query.trim(), difficulty, category);
    }
}
```

#### `WEB-INF/src/service/SubscriptionService.java`
```java
package service;

import dao.SubscriptionDAO;
import dao.PlanDAO;
import model.Subscription;
import model.Plan;
import java.sql.SQLException;
import java.time.LocalDate;

public class SubscriptionService {
    private final SubscriptionDAO subscriptionDAO = new SubscriptionDAO();
    private final PlanDAO planDAO = new PlanDAO();

    public Subscription getActiveSubscription(long userId) throws SQLException {
        return subscriptionDAO.findActiveByUserId(userId);
    }

    public Plan getPlan(String planCode) throws SQLException {
        return planDAO.findByCode(planCode);
    }

    public long createSubscription(long userId, String planCode, String transactionId)
            throws SQLException {
        Plan plan = planDAO.findByCode(planCode);
        if (plan == null) {
            throw new IllegalArgumentException("요금제를 찾을 수 없습니다: " + planCode);
        }

        // 기존 활성 구독 확인
        Subscription existing = subscriptionDAO.findActiveByUserId(userId);
        if (existing != null && existing.isActiveNow()) {
            throw new IllegalStateException("이미 활성 구독이 존재합니다.");
        }

        Subscription subscription = new Subscription();
        subscription.setUserId(userId);
        subscription.setPlanCode(planCode);
        subscription.setStartDate(LocalDate.now());
        subscription.setEndDate(LocalDate.now().plusMonths(plan.getDurationMonths()));
        subscription.setStatus("ACTIVE");
        subscription.setPaymentMethod("card");
        subscription.setTransactionId(transactionId);

        return subscriptionDAO.insert(subscription);
    }
}
```

**OrderService, LabService도 동일 패턴으로 작성. 각 DAO를 직접 호출하던 JSP/Servlet의 비즈니스 로직을 Service로 이동.**

---

## 작업 4-3: 로깅 개선

### 모든 Java 파일에서 다음 교체:

| 현재 | 변경 후 |
|------|---------|
| `System.out.println(...)` | `logger.info(...)` |
| `System.err.println(...)` | `logger.error(...)` |
| `e.printStackTrace()` | `logger.error("설명", e)` |

### 각 클래스 상단에 추가:
```java
import java.util.logging.Logger;
import java.util.logging.Level;

// 클래스 내부 첫 줄
private static final Logger logger = Logger.getLogger(ClassName.class.getName());
```

### 사용 예:
```java
// 변경 전
System.out.println("HikariCP connection pool initialized successfully");
e.printStackTrace();

// 변경 후
logger.info("HikariCP connection pool initialized successfully");
logger.log(Level.SEVERE, "Failed to initialize connection pool", e);
```

**대상 파일 목록**:
- `WEB-INF/classes/db/DBConnect.java`
- `WEB-INF/src/dao/*.java` (모든 DAO)
- `WEB-INF/src/servlet/*.java` (모든 Servlet)
- `WEB-INF/src/service/*.java` (모든 Service)
- `WEB-INF/src/filter/*.java` (모든 Filter)

---

## 컴파일
```bash
cd /var/lib/tomcat9/webapps/ROOT
javac -cp "WEB-INF/lib/*:/usr/share/tomcat9/lib/*" \
  -d WEB-INF/classes \
  WEB-INF/src/**/*.java WEB-INF/classes/db/DBConnect.java
sudo systemctl restart tomcat9
```
