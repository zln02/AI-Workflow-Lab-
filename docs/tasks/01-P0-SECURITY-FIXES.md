# Task 01: P0 보안 취약점 긴급 수정

## 프로젝트 경로
`/var/lib/tomcat9/webapps/ROOT/`

## 기술 스택
- Java 11, Tomcat 9.0.58, MySQL 8+, JSP/Servlet, HikariCP, BCrypt, Gson
- javax.servlet 패키지 사용 (jakarta 아님)

---

## 작업 1-1: DB 비밀번호 하드코딩 제거

### 파일: `WEB-INF/src/db/DBConnect.java`

**현재 문제**: 30행에 `dbPassword = "1234!"` 하드코딩되어 있음

**수정 방법**:
1. `ENVIRONMENT` 환경변수 확인 추가
2. `ENVIRONMENT=dev` 또는 `ENVIRONMENT=development`인 경우에만 로컬 기본값 허용
3. 프로덕션(ENVIRONMENT 미설정 또는 production)에서는 `DB_URL`, `DB_USER`, `DB_PASSWORD` 환경변수가 없으면 `IllegalStateException` throw
4. 개발환경에서도 비밀번호는 `DB_DEV_PASSWORD` 환경변수에서 읽기 (하드코딩 절대 금지)

**수정 코드**:
```java
// 환경 변수에서 데이터베이스 설정 읽기
String dbUrl = System.getenv("DB_URL");
String dbUser = System.getenv("DB_USER");
String dbPassword = System.getenv("DB_PASSWORD");
String environment = System.getenv("ENVIRONMENT");

boolean isDev = "dev".equalsIgnoreCase(environment) || "development".equalsIgnoreCase(environment);

if (dbUrl == null) {
    if (!isDev) {
        throw new IllegalStateException(
            "[FATAL] DB_URL 환경 변수가 설정되지 않았습니다. " +
            "프로덕션 환경에서는 DB_URL, DB_USER, DB_PASSWORD 환경 변수를 반드시 설정하세요. " +
            "개발 환경에서는 ENVIRONMENT=dev 를 설정하면 기본값을 사용합니다.");
    }
    dbUrl = "jdbc:mysql://localhost:3306/ai_navigator?useSSL=true&serverTimezone=UTC&requireSSL=false&verifyServerCertificate=false";
    System.err.println("[DEV MODE] DB_URL 기본값 사용");
}
if (dbUser == null) {
    if (!isDev) {
        throw new IllegalStateException("[FATAL] DB_USER 환경 변수가 설정되지 않았습니다.");
    }
    dbUser = "root";
    System.err.println("[DEV MODE] DB_USER 기본값 사용");
}
if (dbPassword == null) {
    if (!isDev) {
        throw new IllegalStateException("[FATAL] DB_PASSWORD 환경 변수가 설정되지 않았습니다.");
    }
    dbPassword = System.getenv("DB_DEV_PASSWORD");
    if (dbPassword == null) {
        throw new IllegalStateException(
            "[FATAL] 개발 환경에서도 DB_DEV_PASSWORD 환경 변수를 설정해야 합니다.");
    }
    System.err.println("[DEV MODE] DB_DEV_PASSWORD 환경 변수 사용");
}
```

**Tomcat 환경변수 설정 파일 생성**: `/etc/default/tomcat9`에 추가:
```bash
ENVIRONMENT=production
DB_URL=jdbc:mysql://your-host:3306/ai_navigator?useSSL=true&serverTimezone=UTC
DB_USER=your_user
DB_PASSWORD=your_secure_password
```

---

## 작업 1-2: Session Fixation 수정 (signup.jsp)

### 파일: `AI/user/signup.jsp`

**현재 문제**: 36~39행에서 회원가입 후 세션 재생성 없이 바로 `session.setAttribute("user", user)` 호출

**수정 방법**: login.jsp와 동일하게 `session.invalidate()` 후 새 세션 생성

**변경 전** (36~39행):
```java
if (user != null) {
    // 자동 로그인 (세션에 사용자 저장)
    session.setAttribute("user", user);
    response.sendRedirect("/AI/user/home.jsp");
```

**변경 후**:
```java
if (user != null) {
    // 세션 재생성 (session fixation 방지) 후 자동 로그인
    session.invalidate();
    HttpSession newSession = request.getSession(true);
    newSession.setAttribute("user", user);
    response.sendRedirect("/AI/user/home.jsp");
```

---

## 작업 1-3: XSS 취약점 수정 (mypage.jsp)

### 파일: `AI/user/mypage.jsp`

**문제 1**: 149행 `passwordError = String.join("<br>", errors)` - HTML 태그 직접 삽입
**문제 2**: 439행 `<%= passwordError %>` - 이스케이프 없이 출력
**문제 3**: 392~400행 `user.getEmail()`, `user.getFullName()` 이스케이프 없이 출력

**수정 방법**:

1. import 추가: `<%@ page import="util.EscapeUtil" %>`

2. passwordError 타입을 `List<String>`으로 변경 (134행):
```java
List<String> passwordError = null;
```

3. errors 할당 시 join 대신 리스트 그대로 사용 (148~149행):
```java
} else {
    passwordError = errors;
}
```

4. passwordError 출력부 변경 (438~441행):
```jsp
<% if (passwordError != null && !passwordError.isEmpty()) { %>
  <div id="password-error" class="error-message" style="background: #ff3b30; color: #ffffff; padding: 16px; border-radius: 12px; margin-bottom: 24px; font-size: 14px; line-height: 1.42859;">
    <ul style="margin: 0; padding-left: 16px; list-style: disc;">
      <% for (String err : passwordError) { %>
        <li><%= EscapeUtil.escapeHtml(err) %></li>
      <% } %>
    </ul>
  </div>
<% } %>
```

5. 계정 정보 출력에 escapeHtml 추가 (392~400행):
```jsp
<%= EscapeUtil.escapeHtml(user.getEmail() != null ? user.getEmail() : "") %>
...
<%= EscapeUtil.escapeHtml(user.getFullName() != null ? user.getFullName() : "") %>
```

---

## 작업 1-4: signup.jsp XSS 수정

### 파일: `AI/user/signup.jsp`

**문제**: 30행 `errorMessage = String.join("<br>", errors)` + 82행에서 `EscapeUtil.escapeHtml(errorMessage)` 호출 시 `<br>`도 이스케이프되어 깨짐

**수정 방법**: mypage.jsp와 동일하게 List<String>으로 변경

1. 변수 선언 변경 (10행):
```java
List<String> errorMessages = null;
String errorMessage = null;
```

2. errors 할당 변경 (29~30행):
```java
if (!errors.isEmpty()) {
    errorMessages = errors;
} else {
```

3. 단일 에러 메시지는 기존 errorMessage 유지 (17행, 41행)

4. 에러 출력 변경 (80~83행):
```jsp
<% if (errorMessage != null) { %>
  <div id="error-message" class="error-message" style="background: #ff3b30; color: #ffffff; padding: 16px; border-radius: 12px; margin-bottom: 24px; font-size: 14px; line-height: 1.42859;">
    <%= EscapeUtil.escapeHtml(errorMessage) %>
  </div>
<% } %>
<% if (errorMessages != null && !errorMessages.isEmpty()) { %>
  <div id="error-message" class="error-message" style="background: #ff3b30; color: #ffffff; padding: 16px; border-radius: 12px; margin-bottom: 24px; font-size: 14px; line-height: 1.42859;">
    <ul style="margin: 0; padding-left: 16px; list-style: disc;">
      <% for (String err : errorMessages) { %>
        <li><%= EscapeUtil.escapeHtml(err) %></li>
      <% } %>
    </ul>
  </div>
<% } %>
```

---

## 작업 1-5: CORS 하드코딩 수정

### 파일: `AI/api/subscribe.jsp` (12행)

**변경 전**:
```java
response.setHeader("Access-Control-Allow-Origin", "http://localhost:8080");
```

**변경 후**:
```java
// CORS는 같은 도메인 내 요청이므로 불필요. 제거
// 만약 외부 도메인에서 접근 필요 시 환경변수로 관리
String allowedOrigin = System.getenv("CORS_ALLOWED_ORIGIN");
if (allowedOrigin != null && !allowedOrigin.isEmpty()) {
    response.setHeader("Access-Control-Allow-Origin", allowedOrigin);
}
```

---

## 작업 1-6: planCode 화이트리스트 불일치 수정

### 파일: `AI/api/subscribe.jsp` (58행)

**현재**: `planCode.matches("^(STARTER|GROWTH|PRO)$")` - ENTERPRISE 없음
**pricing.jsp**: data-plan="ENTERPRISE" 버튼 존재

**변경**:
```java
if (!planCode.matches("^(STARTER|GROWTH|ENTERPRISE)$")) {
```

---

## 작업 1-7: pricing.jsp 패키지 데이터 XSS 방지

### 파일: `AI/user/pricing.jsp`

**문제**: 122~126행에서 패키지 title, description을 이스케이프 없이 출력

**수정**: import `util.EscapeUtil` 추가 후:
```jsp
<%@ page import="util.EscapeUtil" %>
```

122행:
```jsp
<h3>...<%= EscapeUtil.escapeHtml(pkg.getTitle() != null ? pkg.getTitle() : "Package") %></h3>
```

124~126행:
```jsp
<%= EscapeUtil.escapeHtml(pkg.getDescription() != null && pkg.getDescription().length() > 150
    ? pkg.getDescription().substring(0, 150) + "..."
    : (pkg.getDescription() != null ? pkg.getDescription() : "설명 없음")) %>
```

---

## 컴파일 및 테스트 방법
```bash
cd /var/lib/tomcat9/webapps/ROOT
javac -cp "WEB-INF/lib/*:/usr/share/tomcat9/lib/*" \
  -d WEB-INF/classes \
  $(find WEB-INF/src -name "*.java")
sudo systemctl restart tomcat9
sudo journalctl -u tomcat9 -f  # 로그 확인
```
