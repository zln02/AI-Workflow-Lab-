# AI Workflow Lab

> AI 도구 탐색부터 비즈니스 시나리오 기반 실습 프로젝트까지 — 실무 AI 역량을 키우는 통합 플랫폼

## 프로젝트 개요

AI Workflow Lab은 다양한 AI 도구를 목적에 맞게 탐색·비교하고, 실제 비즈니스 시나리오 기반의 실습 프로젝트를 수행하며 AI 실무 역량을 쌓을 수 있는 웹 애플리케이션입니다. 구독 플랜을 통해 서비스를 이용할 수 있습니다.

### 핵심 기능

- **AI 도구 탐색기**: 카테고리·난이도·키워드 필터로 원하는 AI 도구 검색 및 비교
- **실습 랩 (AI Lab)**: 실제 비즈니스 시나리오 기반 프로젝트 수행 (Tutorial / Real-world / Challenge)
- **구독 플랜**: Starter / Growth / Enterprise 플랜 선택
- **관리자 대시보드**: AI 도구·실습 프로젝트·사용자·구독 플랜·주문 통합 관리

---

## 기술 스택

### Backend
| 기술 | 버전 | 용도 |
|---|---|---|
| Java (JSP/Servlet) | 11 | 웹 애플리케이션 |
| Apache Tomcat | 9.x | 웹 서버 |
| MySQL | 8.0 | 관계형 데이터베이스 |
| HikariCP | 5.1.0 | 커넥션 풀링 |
| Gson | 2.10.1 | JSON 직렬화 |
| BCrypt | 0.10.2 | 비밀번호 해싱 |
| SLF4J | 1.7.x | 로깅 |

### Frontend
| 기술 | 버전 | 용도 |
|---|---|---|
| Bootstrap | 5.3.3 | UI 컴포넌트 |
| Bootstrap Icons | 1.11.3 | 아이콘 |
| GSAP | 3.x | 애니메이션 |
| Axios | 최신 | HTTP 클라이언트 |

### 아키텍처
- **MVC + DAO 패턴**: 명확한 관심사 분리
- **RESTful Servlet**: `/api/tools` JSON API
- **세션 기반 인증**: 사용자·관리자 분리 인증
- **Glassmorphism UI**: 다크모드 중심 현대적 디자인

---

## 프로젝트 구조

```
ROOT/
├── AI/
│   ├── admin/                  # 관리자 페이지
│   │   ├── auth/               # 로그인/로그아웃
│   │   ├── dashboard.jsp       # 관리자 대시보드
│   │   ├── orders/             # 주문 관리
│   │   ├── tools/              # AI 도구 관리
│   │   ├── users/              # 사용자 관리
│   │   ├── packages/           # 구독 플랜 관리
│   │   ├── categories/         # 카테고리 관리
│   │   ├── admins/             # 관리자 계정 관리
│   │   └── layout/             # 공통 레이아웃 (sidebar, topbar 등)
│   ├── api/                    # API 엔드포인트
│   │   ├── subscribe.jsp       # 구독 처리
│   │   └── ...
│   ├── error/                  # 에러 페이지
│   │   ├── 403.jsp
│   │   ├── 404.jsp
│   │   └── 500.jsp
│   ├── user/                   # 사용자 페이지
│   │   ├── home.jsp            # 메인 홈
│   │   ├── tools/
│   │   │   ├── navigator.jsp   # AI 도구 탐색기
│   │   │   └── detail.jsp      # AI 도구 상세
│   │   ├── lab/
│   │   │   ├── index.jsp       # 실습 랩 목록
│   │   │   └── detail.jsp      # 실습 프로젝트 상세
│   │   ├── pricing.jsp         # 요금제
│   │   ├── checkout.jsp        # 결제
│   │   ├── mypage.jsp          # 마이페이지
│   │   ├── login.jsp           # 로그인
│   │   └── signup.jsp          # 회원가입
│   ├── partials/               # 공통 컴포넌트
│   │   ├── header.jsp
│   │   └── footer.jsp
│   ├── assets/
│   │   ├── css/                # 스타일시트
│   │   ├── js/                 # JavaScript
│   │   └── img/                # 이미지·아이콘
│   └── database/               # DB 스키마 및 마이그레이션
│       ├── migrations/
│       └── seed/
├── WEB-INF/
│   ├── src/                    # Java 소스
│   │   ├── dao/                # DAO 클래스
│   │   ├── model/              # 모델 클래스
│   │   ├── servlet/            # 서블릿
│   │   ├── filter/             # 필터 (보안, Rate Limiting 등)
│   │   ├── service/            # 서비스 레이어
│   │   ├── util/               # 유틸리티
│   │   └── constants/          # 상수
│   └── web.xml
├── docs/                       # 프로젝트 문서
│   ├── tasks/                  # 개발 작업 목록
│   ├── DEPLOYMENT.md           # 배포 가이드
│   └── AI-WORKFLOW-LAB-IMPROVEMENT-PLAN.md
└── README.md
```

---

## 설치 및 실행

### 필수 요구사항

- Java 11 이상
- Apache Tomcat 9.0 이상
- MySQL 8.0 이상

### 1. 데이터베이스 설정

```bash
# MySQL 접속
mysql -u root -p

# 데이터베이스 및 사용자 생성
CREATE DATABASE ai_navigator CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'aiworkflow'@'localhost' IDENTIFIED BY 'your_secure_password';
GRANT ALL PRIVILEGES ON ai_navigator.* TO 'aiworkflow'@'localhost';
FLUSH PRIVILEGES;

# 스키마 적용
USE ai_navigator;
SOURCE /path/to/AI/database/ai_workflow_lab_schema.sql;
```

### 2. 환경 변수 설정 (systemd)

```bash
# /etc/systemd/system/tomcat9.service.d/env.conf 생성
sudo mkdir -p /etc/systemd/system/tomcat9.service.d
sudo tee /etc/systemd/system/tomcat9.service.d/env.conf << 'EOF'
[Service]
Environment="ENVIRONMENT=production"
Environment="DB_URL=jdbc:mysql://localhost:3306/ai_navigator?useSSL=true&serverTimezone=UTC&requireSSL=false&verifyServerCertificate=false"
Environment="DB_USER=aiworkflow"
Environment="DB_PASSWORD=your_secure_password"
EOF

sudo systemctl daemon-reload
```

### 3. Java 클래스 컴파일

```bash
cd /var/lib/tomcat9/webapps/ROOT

javac -encoding UTF-8 \
  -cp "WEB-INF/lib/*:/usr/share/tomcat9/lib/*" \
  -d WEB-INF/classes \
  WEB-INF/src/**/*.java \
  WEB-INF/classes/db/DBConnect.java
```

### 4. Tomcat 시작

```bash
sudo systemctl restart tomcat9
```

### 5. 접속 확인

| 경로 | 설명 |
|---|---|
| `http://localhost:8080/` | 메인 홈 (리다이렉트) |
| `http://localhost:8080/AI/user/home.jsp` | 사용자 홈 |
| `http://localhost:8080/AI/user/tools/navigator.jsp` | AI 도구 탐색기 |
| `http://localhost:8080/AI/user/lab/index.jsp` | 실습 랩 |
| `http://localhost:8080/AI/admin/auth/login.jsp` | 관리자 로그인 |

---

## 주요 Java 클래스

| 클래스 | 역할 |
|---|---|
| `db.DBConnect` | HikariCP 커넥션 풀 관리, 환경변수 기반 설정 |
| `dao.AIToolDAO` | AI 도구 CRUD, 검색, 추천 |
| `dao.LabProjectDAO` | 실습 프로젝트 CRUD, 필터링 |
| `dao.UserDAO` | 사용자 CRUD, 인증 |
| `servlet.AIToolServlet` | `/api/tools` REST API |
| `filter.SecurityHeadersFilter` | 보안 헤더 필터 |
| `filter.RateLimitFilter` | IP 기반 Rate Limiting (로그인 5회/분, 일반 60회/분) |
| `filter.AuthFilter` | 관리자 페이지 인증 필터 |
| `util.PasswordUtil` | BCrypt 비밀번호 해싱 |
| `util.EscapeUtil` | XSS 방지 HTML 이스케이프 |
| `util.CSRFUtil` | CSRF 토큰 생성·검증 |

---

## 보안

- **환경변수 DB 설정**: DB 자격증명 코드 외부화, 프로덕션에서 환경변수 미설정 시 서버 시작 차단
- **Session Fixation 방지**: 로그인·회원가입 시 `session.invalidate()` 후 세션 재생성
- **XSS 방지**: 모든 사용자 입력 출력 시 `EscapeUtil.escapeHtml()` 적용
- **CSRF 보호**: 폼 제출 시 토큰 검증
- **Rate Limiting**: IP 기반 요청 제한 (로그인 5회/분, 일반 60회/분)
- **보안 헤더**: `X-Content-Type-Options`, `X-Frame-Options`, `CSP` 자동 적용
- **역할 기반 접근 제어**: 사용자 / 관리자 / Superadmin 분리

---

## 라이선스

이 프로젝트는 포트폴리오 목적으로 제작되었습니다.

## 작성자

- **박진영**
- GitHub: [zln02](https://github.com/zln02)
