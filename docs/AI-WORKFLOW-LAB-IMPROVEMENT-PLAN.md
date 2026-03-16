# AI Workflow Lab - 전체 개선 계획서 (Sonnet 작업용 프롬프트)

> **프로젝트**: AI Workflow Lab - AI 도구 추천 + 실무 프로젝트 경험 플랫폼
> **위치**: `/var/lib/tomcat9/webapps/ROOT/`
> **스택**: Java 11 + Tomcat 9.0.58 + MySQL + JSP/Servlet + Bootstrap 5 + HikariCP
> **Git**: https://github.com/zln02/AI-Workflow-Lab-.git

---

## 0. 아이디어 평가

### 좋은 점
- AI 도구 추천 + 실습 랩 + 학습 경로의 조합은 시장 수요가 높음
- 초급~고급 난이도별 분류 체계가 잘 구성됨
- B2C (개인) + B2B (팀/기업) 구독 모델 동시 지원
- 포트폴리오 + 커뮤니티 리뷰 기능으로 사용자 참여 유도

### 우려 사항
- AI 도구 정보가 빠르게 변하므로 데이터 유지보수 체계 필요
- 현재 결제가 미구현 (checkout.jsp가 "준비 중" 페이지)
- 구독 시 실제 결제 검증 없이 DB에 바로 저장됨 (치명적)
- 차별화 요소 부족 (There's an AI for That, Futurepedia 등과의 차별점)

---

## 1. [치명적] 보안 개선사항

### 1-1. DB 비밀번호 하드코딩 제거
**파일**: `WEB-INF/src/db/DBConnect.java:30`
```
현재: dbPassword = "1234!";  // 하드코딩된 기본 비밀번호
개선: 환경변수 필수 + 기본값 제거. 환경변수 없으면 시작 실패하도록 변경
```

**Sonnet 프롬프트**:
```
DBConnect.java 파일에서 하드코딩된 기본 비밀번호 "1234!" 제거.
환경변수(DB_URL, DB_USER, DB_PASSWORD)가 없으면 IllegalStateException을 throw하여
서버 시작을 차단하도록 수정. 개발환경에서만 사용할 수 있도록
ENVIRONMENT=dev 환경변수가 설정된 경우에만 기본값 허용.
```

### 1-2. 결제(구독) 검증 없이 DB 저장 문제
**파일**: `AI/api/subscribe.jsp`
```
현재: 사용자가 구독 버튼만 누르면 결제 없이 바로 ACTIVE 구독이 생성됨
     transactionId = "TXN-" + System.currentTimeMillis() (가짜 트랜잭션)
개선: 실제 PG(결제 게이트웨이) 연동 필수
```

**Sonnet 프롬프트**:
```
subscribe.jsp를 Servlet으로 리팩토링 (SubscriptionServlet.java).
결제 흐름 구현:
1. 결제 요청 시 주문 상태를 PENDING으로 생성
2. Toss Payments / 아임포트(PortOne) / Stripe 중 하나의 PG 연동
3. PG 결제 성공 콜백 수신 후에만 ACTIVE로 변경
4. 결제 실패/취소 시 FAILED/CANCELLED 상태 처리
5. 중복 결제 방지 (idempotency key)
6. 결제 검증: 서버사이드에서 PG API로 결제 금액 재검증

필요한 파일:
- WEB-INF/src/servlet/PaymentServlet.java (결제 처리)
- WEB-INF/src/servlet/PaymentCallbackServlet.java (PG 콜백)
- WEB-INF/src/service/PaymentService.java (비즈니스 로직)
- AI/user/checkout.jsp (실제 결제 UI)
```

### 1-3. CORS 헤더 하드코딩
**파일**: `AI/api/subscribe.jsp:12`
```
현재: response.setHeader("Access-Control-Allow-Origin", "http://localhost:8080");
개선: 프로덕션 도메인으로 변경 또는 환경변수로 관리
```

### 1-4. mypage.jsp XSS 취약점
**파일**: `AI/user/mypage.jsp:439`
```
현재: <%= passwordError %> (HTML 이스케이프 없이 출력)
     errorMessage에 String.join("<br>", errors) 사용 - HTML 태그 직접 삽입
개선: 모든 출력에 escapeHtml() 적용, <br> 대신 리스트 렌더링
```

**Sonnet 프롬프트**:
```
mypage.jsp에서 passwordError, passwordSuccess 출력 시
EscapeUtil.escapeHtml()을 적용.
signup.jsp에서도 errorMessage에 String.join("<br>", errors) 대신
List<String> errors를 for문으로 개별 출력하면서 각각 escapeHtml() 적용.
모든 JSP에서 <%= %> 사용 부분 전수 검사하여 사용자 입력이 포함될 수 있는
모든 곳에 escapeHtml() 적용.

검사 대상 파일:
- AI/user/mypage.jsp (passwordError, passwordSuccess)
- AI/user/signup.jsp (errorMessage)
- AI/user/pricing.jsp (Package 데이터 출력)
- AI/admin/dashboard.jsp
- AI/admin/users/detail.jsp
```

### 1-5. pricing.jsp 구독 버튼 planCode 불일치
**파일**: `AI/user/pricing.jsp`
```
현재: data-plan="ENTERPRISE" 이지만 subscribe.jsp 화이트리스트는
     "STARTER|GROWTH|PRO" -> ENTERPRISE는 허용되지 않음
개선: 화이트리스트와 프론트엔드 planCode 일치시키기
```

### 1-6. Rate Limiting 미구현
```
현재: API 엔드포인트에 요청 제한이 없음
개선: 로그인 시도, API 호출에 Rate Limiting 적용
```

**Sonnet 프롬프트**:
```
Rate Limiting 필터 구현:
- WEB-INF/src/filter/RateLimitFilter.java 생성
- IP 기반 + 사용자 기반 요청 제한
- 로그인 API: IP당 5회/분
- 일반 API: 사용자당 60회/분
- ConcurrentHashMap + 슬라이딩 윈도우 방식
- web.xml에 필터 등록
```

### 1-7. Session Fixation - signup.jsp
**파일**: `AI/user/signup.jsp:37`
```
현재: 회원가입 후 세션 재생성 없이 바로 session.setAttribute("user", user)
개선: login.jsp처럼 session.invalidate() 후 새 세션 생성
```

---

## 2. [높음] 백엔드 아키텍처 개선

### 2-1. JSP에 비즈니스 로직 혼재
```
현재: subscribe.jsp, search.jsp 등 API JSP에 DB 접근 로직이 직접 포함
개선: 모든 API JSP를 Servlet으로 마이그레이션
```

**Sonnet 프롬프트**:
```
다음 API JSP 파일들을 Servlet으로 마이그레이션:
1. AI/api/subscribe.jsp -> servlet/SubscriptionServlet.java
2. AI/api/search.jsp -> servlet/SearchServlet.java
3. AI/api/categories.jsp -> servlet/CategoryServlet.java
4. AI/api/models.jsp -> servlet/ModelServlet.java
5. AI/api/packages.jsp -> servlet/PackageServlet.java (기존 PackagesServlet 활용)
6. AI/api/recommend.jsp -> servlet/RecommendServlet.java
7. AI/api/cart-summary.jsp -> servlet/CartServlet.java
8. AI/api/order-update.jsp -> servlet/OrderServlet.java
9. AI/api/order-delete.jsp -> servlet/OrderServlet.java (같은 서블릿, DELETE 메서드)
10. AI/api/sales-statistics.jsp -> servlet/StatisticsServlet.java

각 Servlet 구현 시:
- Service 레이어를 통해 DAO 접근
- 입력 검증 (ValidationUtil 활용)
- 에러 핸들링 통일 (ApiResponse 사용)
- CSRF 토큰 검증 (POST/PUT/DELETE)
- 적절한 HTTP 상태 코드 반환
- web.xml에 서블릿 매핑 추가
```

### 2-2. Service 레이어 부재
```
현재: Servlet -> DAO 직접 호출 (비즈니스 로직이 Servlet에 혼재)
개선: Service 레이어 추가
```

**Sonnet 프롬프트**:
```
다음 Service 클래스 생성:
1. service/ToolService.java - AI 도구 관련 비즈니스 로직
2. service/LabService.java - 실습 랩 관련 비즈니스 로직
3. service/SubscriptionService.java - 구독 관련 비즈니스 로직
4. service/OrderService.java - 주문 관련 비즈니스 로직
5. service/SearchService.java - 검색 관련 비즈니스 로직

각 Service 클래스:
- 트랜잭션 관리 (Connection 수동 관리, auto-commit false)
- 비즈니스 검증 로직
- 여러 DAO를 조합한 복합 작업
- 예외를 비즈니스 예외로 변환
```

### 2-3. 빌드 시스템 부재
```
현재: javac 수동 컴파일, lib/ 폴더에 JAR 직접 관리
개선: Maven 또는 Gradle 빌드 시스템 도입
```

**Sonnet 프롬프트**:
```
프로젝트 루트에 pom.xml 생성 (Maven):
- Java 11
- javax.servlet-api 4.0.1 (provided)
- mysql-connector-j 9.5.0
- HikariCP 5.1.0
- gson 2.10.1
- bcrypt 0.10.2
- slf4j-api + slf4j-simple
- JUnit 5 (테스트)

디렉토리 구조를 Maven 표준으로 재구성하는 가이드 작성:
src/main/java/ <- WEB-INF/src/ 내용 이동
src/main/webapp/ <- AI/, WEB-INF/web.xml 이동
src/main/resources/ <- properties 파일
src/test/java/ <- 테스트 코드

maven-war-plugin 설정으로 WAR 파일 빌드
Tomcat 배포 자동화 스크립트
```

### 2-4. 로깅 개선
```
현재: System.out.println / System.err.println / e.printStackTrace()
개선: SLF4J + Logback 적용
```

**Sonnet 프롬프트**:
```
모든 Java 파일에서:
- System.out.println -> logger.info()
- System.err.println -> logger.error()
- e.printStackTrace() -> logger.error("message", e)

LoggerUtil.java가 이미 있으므로 확인 후 활용.
각 클래스에 private static final Logger logger = LoggerFactory.getLogger(ClassName.class) 추가.
logback.xml 설정 파일 생성 (콘솔 + 파일 로그, 일별 롤링).
```

---

## 3. [높음] 프론트엔드 개선

### 3-1. 결제 흐름 구현
**Sonnet 프롬프트**:
```
checkout.jsp를 실제 결제 페이지로 구현:
1. 주문 요약 정보 표시 (선택한 플랜/패키지, 가격, 할인)
2. 결제 수단 선택 UI (카드, 은행이체, 가상계좌)
3. PG 결제 모듈 JavaScript SDK 연동
   - Toss Payments: tossPayments.requestPayment()
   - 또는 PortOne: IMP.request_pay()
4. 결제 성공 시 complete.jsp로 리다이렉트
5. 결제 실패 시 에러 메시지 표시
6. 로딩 상태 표시 (스피너)
7. 모바일 반응형 디자인
```

### 3-2. 에러 페이지 누락
```
현재: 404, 500 등 에러 페이지가 없음
개선: 커스텀 에러 페이지 생성
```

**Sonnet 프롬프트**:
```
1. AI/error/404.jsp - 페이지를 찾을 수 없음
2. AI/error/500.jsp - 서버 오류
3. AI/error/403.jsp - 접근 권한 없음
4. web.xml에 에러 페이지 매핑 추가:
   <error-page>
     <error-code>404</error-code>
     <location>/AI/error/404.jsp</location>
   </error-page>
   (500, 403도 동일하게)
5. 기존 dark-theme.css 스타일 적용
6. 홈으로 돌아가기 버튼 포함
```

### 3-3. 로딩 상태 & UX 개선
**Sonnet 프롬프트**:
```
전체 프론트엔드 UX 개선:
1. 모든 fetch 호출에 로딩 스피너 추가
2. 버튼 클릭 시 더블 클릭 방지 (disabled 처리)
3. 토스트 메시지 일관성 있게 적용 (toast.js 활용)
4. 폼 제출 시 클라이언트 사이드 검증 강화
5. Skeleton loading 추가 (데이터 로딩 중 빈 카드 표시)
6. 무한 스크롤 또는 페이지네이션 (도구 목록이 많을 때)
7. 모바일 반응형 개선 (현재 min(980px) 고정)
8. 접근성 개선 (aria-label, role, tab navigation)
```

### 3-4. 프론트엔드 성능 최적화
```
현재: 모든 페이지에서 Bootstrap 5 + Google Fonts + Bootstrap Icons + GSAP 전체 로드
개선: 필요한 것만 로드, lazy loading
```

**Sonnet 프롬프트**:
```
1. CSS/JS 번들 최적화 - 미사용 Bootstrap 컴포넌트 제거
2. Google Fonts에 &display=swap + preconnect 이미 적용됨 (OK)
3. 이미지 lazy loading 추가 (loading="lazy")
4. GSAP는 home.jsp에서만 사용 -> 다른 페이지에서 제거
5. CSS/JS 파일에 버전 쿼리 파라미터 추가 (캐시 버스팅)
   예: user.css?v=2024120801
```

---

## 4. [중간] 인프라 & DevOps 개선

### 4-1. HTTPS 미설정
```
현재: Tomcat이 HTTP(8080)만 사용, web.xml에 <secure>true</secure> 설정은 있지만
     실제 HTTPS 미설정 (세션 쿠키가 HTTP에서 전송 불가 이슈 가능)
개선: Nginx 리버스 프록시 + Let's Encrypt SSL
```

**Sonnet 프롬프트**:
```
Nginx + Let's Encrypt 설정 가이드 작성:
1. Nginx 설치 및 리버스 프록시 설정
   - 80 -> 443 리다이렉트
   - 443 -> localhost:8080 프록시
   - WebSocket 지원 (필요 시)
   - gzip 압축
   - 정적 파일 캐싱 (assets/)
2. Certbot으로 Let's Encrypt SSL 인증서 발급
3. 자동 갱신 크론잡 설정
4. Tomcat server.xml 수정 (proxyName, proxyPort)
5. web.xml에서 <secure>true</secure> 정상 작동 확인

Nginx 설정 파일: /etc/nginx/sites-available/ai-workflow-lab
```

### 4-2. CI/CD 파이프라인 구축
**Sonnet 프롬프트**:
```
GitHub Actions CI/CD 파이프라인 구성:
.github/workflows/deploy.yml 생성:

1. main 브랜치 push 시 자동 실행
2. Java 11 + Maven 빌드
3. 단위 테스트 실행
4. WAR 파일 생성
5. SSH로 서버에 배포 (rsync 또는 scp)
6. Tomcat 재시작

.github/workflows/pr-check.yml:
1. PR 시 자동 빌드 + 테스트
2. 코드 품질 검사

필요한 GitHub Secrets:
- SERVER_HOST, SERVER_USER, SSH_KEY
- DB_URL, DB_USER, DB_PASSWORD
```

### 4-3. Tomcat 버전 업그레이드
```
현재: Tomcat 9.0.58 (2022년 릴리스, 보안 패치 필요)
개선: Tomcat 9 최신 패치(9.0.96+) 또는 Tomcat 10 마이그레이션
주의: Tomcat 10은 Jakarta EE (javax -> jakarta 패키지명 변경)
추천: Tomcat 9 최신 패치로 업그레이드
```

### 4-4. DB 접속 정보 분리
```
현재: supabase_connection.properties가 Git 저장소에 포함 (비밀번호는 YOUR_PASSWORD_HERE)
     DBConnect.java에서 환경변수 사용하지만 기본값 하드코딩
개선: 환경변수 전용 + .env 파일로 관리
```

**Sonnet 프롬프트**:
```
1. /var/lib/tomcat9/conf/environment.conf 생성
   DB_URL=jdbc:mysql://...
   DB_USER=...
   DB_PASSWORD=...
   ENVIRONMENT=production

2. Tomcat systemd 서비스에 EnvironmentFile 추가
3. DBConnect.java에서 기본값 제거 (ENVIRONMENT=dev일 때만 허용)
4. supabase_connection.properties를 .gitignore에 추가 (이미 추가됨 확인)
```

---

## 5. [중간] 데이터베이스 개선

### 5-1. 스키마 불일치
```
현재: schema.sql (ai_models 중심)과 ai_workflow_lab_schema.sql (ai_tools 중심)
     두 개의 스키마가 혼재
     - 실제 코드는 ai_tools 테이블 사용 (AIToolDAO)
     - schema.sql의 ai_models도 사용 (AIModelDAO)
개선: 스키마 통합 및 마이그레이션 관리
```

**Sonnet 프롬프트**:
```
1. Flyway 또는 수동 마이그레이션 관리 도입
2. 두 스키마 통합:
   - ai_tools = AI 도구 추천 시스템 (navigator)
   - ai_models = 마켓플레이스 상품
   이 구분이 맞는지 확인 후 관계 정리
3. users 테이블과 orders 테이블에 user_id FK 추가
   (현재 orders는 customer_email로만 연결)
4. subscriptions 테이블에 orders FK 연결
5. 인덱스 최적화 검토
```

### 5-2. 감사 로그 테이블
```
현재: user_activity_logs 스키마만 존재, 실제 로깅 구현 없음
개선: 주요 활동에 대한 감사 로그 구현
```

---

## 6. [중간] 기능 추가 필요

### 6-1. 이메일 인증
```
현재: email_verified 컬럼이 있지만 인증 로직 없음
개선: 회원가입 시 이메일 인증 메일 발송
```

**Sonnet 프롬프트**:
```
이메일 인증 기능 구현:
1. service/EmailService.java - SMTP 이메일 발송
   - Jakarta Mail 또는 JavaMail API 사용
   - 환경변수로 SMTP 설정 관리
2. 인증 토큰 테이블 생성 (email_verification_tokens)
3. 회원가입 후 인증 이메일 발송
4. /AI/api/verify-email?token=xxx 엔드포인트
5. 인증 완료 전까지 일부 기능 제한
```

### 6-2. 비밀번호 찾기
```
현재: 구현되어 있지 않음
개선: 이메일 기반 비밀번호 재설정
```

### 6-3. 소셜 로그인
```
개선: Google/GitHub OAuth2 로그인 지원
```

---

## 7. [낮음] 코드 품질 개선

### 7-1. 테스트 코드 부재
**Sonnet 프롬프트**:
```
JUnit 5 기반 테스트 코드 작성:
1. dao/UserDAOTest.java - CRUD 테스트
2. dao/AIToolDAOTest.java - 검색, 필터 테스트
3. service/UserServiceTest.java - 인증, 검증 로직 테스트
4. util/PasswordUtilTest.java - 해싱, 검증 테스트
5. util/CSRFUtilTest.java - 토큰 생성, 검증 테스트
6. util/EscapeUtilTest.java - XSS 이스케이프 테스트
7. servlet/AIToolServletTest.java - API 응답 테스트

H2 인메모리 DB 사용 또는 Testcontainers(MySQL)
```

### 7-2. .gitignore에 .class 파일 포함되어 있으나 이미 추적 중인 파일
```
현재: .gitignore에 *.class 있지만 WEB-INF/classes/ 아래 .class 파일이
     이미 Git에 추적되고 있을 수 있음
개선: git rm --cached로 추적 해제
```

**Sonnet 프롬프트**:
```
git rm -r --cached WEB-INF/classes/
git rm -r --cached WEB-INF/lib/
git commit -m "Remove compiled files and libraries from tracking"
```

---

## 8. 작업 우선순위 요약

| 우선순위 | 카테고리 | 항목 | 예상 난이도 |
|---------|---------|------|-----------|
| P0 | 보안 | DB 비밀번호 하드코딩 제거 | 쉬움 |
| P0 | 보안 | 결제 검증 없이 구독 생성 수정 | 어려움 |
| P0 | 보안 | XSS 취약점 수정 (mypage.jsp 등) | 보통 |
| P0 | 보안 | Session Fixation (signup.jsp) | 쉬움 |
| P1 | 인프라 | HTTPS 설정 (Nginx + Let's Encrypt) | 보통 |
| P1 | 보안 | Rate Limiting 구현 | 보통 |
| P1 | 보안 | CORS 설정 수정 | 쉬움 |
| P1 | 보안 | planCode 화이트리스트 불일치 수정 | 쉬움 |
| P1 | 프론트 | 실제 결제 UI 구현 | 어려움 |
| P1 | 프론트 | 에러 페이지 (404, 500, 403) | 쉬움 |
| P2 | 백엔드 | API JSP -> Servlet 마이그레이션 | 보통 |
| P2 | 백엔드 | Service 레이어 추가 | 보통 |
| P2 | 백엔드 | Maven 빌드 시스템 도입 | 보통 |
| P2 | 백엔드 | 로깅 개선 (SLF4J) | 쉬움 |
| P2 | 인프라 | CI/CD 파이프라인 | 보통 |
| P2 | DB | 스키마 통합 + 마이그레이션 | 보통 |
| P3 | 기능 | 이메일 인증 | 보통 |
| P3 | 기능 | 비밀번호 찾기 | 보통 |
| P3 | 기능 | 소셜 로그인 | 어려움 |
| P3 | 프론트 | UX 개선 (로딩, 반응형) | 보통 |
| P3 | 프론트 | 성능 최적화 | 쉬움 |
| P3 | 품질 | 테스트 코드 작성 | 보통 |
| P3 | Git | .class/.jar 파일 추적 해제 | 쉬움 |

---

## 9. Sonnet에게 작업 지시 시 참고사항

### 프로젝트 구조
```
/var/lib/tomcat9/webapps/ROOT/
├── AI/
│   ├── admin/          # 관리자 페이지 (JSP)
│   ├── api/            # API 엔드포인트 (JSP -> Servlet으로 변경 필요)
│   ├── assets/
│   │   ├── css/        # dark-theme.css, user.css, admin.css 등
│   │   ├── js/         # user.js, admin.js, toast.js 등
│   │   └── img/        # 로고, 프로바이더 아이콘
│   ├── database/       # SQL 스키마, 마이그레이션
│   ├── partials/       # header.jsp, footer.jsp
│   └── user/           # 사용자 페이지 (JSP)
├── WEB-INF/
│   ├── classes/        # 컴파일된 .class 파일
│   ├── lib/            # JAR 라이브러리
│   ├── src/            # Java 소스 코드
│   │   ├── constants/  # AppConstants.java
│   │   ├── dao/        # DAO 클래스
│   │   ├── dto/        # ApiResponse.java
│   │   ├── filter/     # SecurityHeadersFilter.java
│   │   ├── model/      # 엔티티 클래스
│   │   ├── servlet/    # 서블릿 클래스
│   │   └── util/       # 유틸리티 클래스
│   └── web.xml         # 서블릿 설정
└── .git/
```

### 컴파일 방법 (현재)
```bash
cd /var/lib/tomcat9/webapps/ROOT
javac -cp "WEB-INF/lib/*:/usr/share/tomcat9/lib/*" \
  -d WEB-INF/classes \
  $(find WEB-INF/src -name "*.java")
sudo systemctl restart tomcat9
```

### 주의사항
- Java 11 문법만 사용 (var 키워드 OK)
- javax.servlet 패키지 사용 (jakarta 아님)
- MySQL 8+ 문법 사용
- 모든 문자열 출력에 EscapeUtil.escapeHtml() 적용
- PreparedStatement만 사용 (SQL Injection 방지)
- try-with-resources로 Connection/Statement 관리
- UTF-8 인코딩 통일
