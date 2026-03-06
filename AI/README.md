# AI Workflow Lab

## 개요
AI Workflow Lab은 인공지능 도구와 모델을 관리하고 사용자가 쉽게 접근할 수 있도록 도와주는 웹 애플리케이션입니다.

## 주요 기능
- **AI 도구 관리**: 다양한 AI 도구를 카테고리별로 관리
- **사용자 인증**: 회원가입, 로그인, 프로필 관리
- **즐겨찾기**: 자주 사용하는 AI 도구 저장
- **검색 기능**: AI 도구 검색 및 필터링
- **랩 프로젝트**: AI 관련 프로젝트 관리
- **구독 서비스**: 프리미엄 기능 제공

## 기술 스택
- **Backend**: Java Servlet, JSP
- **Database**: MySQL
- **Frontend**: HTML5, CSS3, JavaScript
- **Server**: Apache Tomcat 9
- **Security**: CSRF 보호, 보안 헤더 필터

## 프로젝트 구조
```
AI/
├── admin/           # 관리자 페이지
├── api/             # API 엔드포인트
├── assets/          # 정적 리소스 (CSS, JS, 이미지)
├── partials/        # JSP 템플릿 조각
├── user/            # 사용자 페이지
└── WEB-INF/         # 웹 애플리케이션 설정
    ├── src/         # Java 소스 코드
    ├── classes/     # 컴파일된 클래스 파일
    └── web.xml      # 웹 애플리케이션 배포 서술자
```

## 설치 및 실행

### 요구사항
- Java 8 이상
- Apache Tomcat 9
- MySQL 5.7 이상

### 설치 과정
1. 데이터베이스 설정
2. `web.xml`에서 데이터베이스 연결 정보 수정
3. WAR 파일로 배포
4. Tomcat 서버 시작

## 최근 업데이트 (2025-03-06)

### 보안 기능 강화
- **CSRFUtil.java**: CSRF 토큰 생성 및 검증 로직 개선
- **SecurityHeadersFilter.java**: 보안 헤더 필터 강화 (CSP, HSTS, X-Frame-Options 등)
- **DBConnect.java**: 데이터베이스 연결 보안 강화

### UI/UX 개선
- **다크 테마**: `dark-theme.css` 추가로 다크 모드 지원
- **애니메이션**: `animations.js`로 부드러운 UI 애니메이션 구현
- **헤더 개선**: `header.jsp` 네비게이션 UI 개선

### 사용자 기능 확장
- **마이페이지**: `mypage.jsp` 사용자 프로필 관리 기능 강화
- **로그인/회원가입**: 보안 강화 및 UI 개선
- **프로필 이미지**: `FileUploadUtil.java` 이미지 업로드 기능 개선

### API 기능 개선
- **검색 API**: `search.jsp` 검색 성능 최적화
- **추천 시스템**: `recommend.jsp` AI 기반 추천 알고리즘 개선
- **장바구니**: `cart-summary.jsp` 장바구니 기능 안정화
- **주문 관리**: `order-delete.jsp`, `order-update.jsp` 주문 관리 기능 개선
- **구독 관리**: `subscribe.jsp`, `subscription-update.jsp` 구독 기능 개선

### 관리자 기능
- **관리자 로그인**: `admin/auth/login.jsp` 보안 강화
- **통계**: `sales-statistics.jsp` 매출 통계 기능 개선

### 기타
- **favicon.ico**: 웹사이트 아이콘 추가
- **web.xml**: 서블릿 매핑 및 필터 설정 최적화

## 기여자
- 개발팀

## 라이선스
MIT License
