# AI Workflow Lab

> AI 도구 탐색부터 비즈니스 시나리오 기반 실습 프로젝트까지 — 실무 AI 역량을 키우는 통합 플랫폼

## 프로젝트 개요

AI Workflow Lab은 다양한 AI 도구를 목적에 맞게 탐색·비교하고, 실제 비즈니스 시나리오 기반의 실습 프로젝트를 수행하며 AI 실무 역량을 쌓을 수 있는 웹 애플리케이션입니다. 구독 플랜을 통해 토큰 기반 서비스를 이용할 수 있습니다.

### 핵심 기능

- **AI 도구 탐색기**: 카테고리·난이도·키워드 필터로 원하는 AI 도구 검색 및 비교
- **실습 랩 (AI Lab)**: 실제 비즈니스 시나리오 기반 프로젝트 수행 (Tutorial / Real-world / Challenge)
- **구독 플랜**: 토큰 기반 서비스 이용을 위한 플랜 선택 및 결제
- **관리자 대시보드**: AI 도구·실습 프로젝트·사용자·구독 플랜 통합 관리

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
│   │   ├── tools/              # AI 도구 관리
│   │   ├── lab/                # 실습 랩 관리
│   │   ├── users/              # 사용자 관리
│   │   ├── packages/           # 구독 플랜 관리
│   │   ├── categories/         # 카테고리 관리
│   │   ├── admins/             # 관리자 계정 관리
│   │   └── layout/             # 공통 레이아웃 (sidebar, topbar 등)
│   ├── user/                   # 사용자 페이지
│   │   ├── home.jsp            # 메인 홈
│   │   ├── tools/
│   │   │   └── navigator.jsp   # AI 도구 탐색기
│   │   ├── lab/
│   │   │   ├── index.jsp       # 실습 랩 목록
│   │   │   └── detail.jsp      # 실습 프로젝트 상세
│   │   ├── package.jsp         # 구독 플랜 목록
│   │   ├── checkout.jsp        # 결제
│   │   ├── mypage.jsp          # 마이페이지
│   │   ├── login.jsp           # 로그인
│   │   └── signup.jsp          # 회원가입
│   ├── partials/               # 공통 컴포넌트
│   │   ├── header.jsp
│   │   ├── footer.jsp
│   │   └── key-visual.jsp
│   ├── assets/
│   │   ├── css/                # 스타일시트
│   │   ├── js/                 # JavaScript
│   │   └── img/                # 이미지·아이콘
│   └── database/
│       ├── schema.sql          # 기존 스키마
│       └── ai_workflow_lab_schema.sql  # AI Workflow Lab 스키마
├── WEB-INF/
│   ├── src/                    # Java 소스
│   │   ├── dao/                # AIToolDAO, LabProjectDAO, UserDAO 등
│   │   ├── model/              # AITool, LabProject, User 등
│   │   ├── servlet/            # AIToolServlet
│   │   ├── filter/             # SecurityHeadersFilter 등
│   │   ├── util/               # PasswordUtil, ValidationUtil
│   │   └── db/                 # DBConnect (HikariCP)
│   ├── classes/                # 컴파일된 .class 파일
│   ├── lib/                    # JAR 파일
│   │   ├── HikariCP-5.1.0.jar
│   │   ├── gson-2.10.1.jar
│   │   ├── mysql-connector-j-9.5.0.jar
│   │   ├── slf4j-api.jar
│   │   └── slf4j-simple.jar
│   └── web.xml
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

# 데이터베이스 생성
CREATE DATABASE ai_navigator CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

# 스키마 적용
USE ai_navigator;
SOURCE /path/to/AI/database/ai_workflow_lab_schema.sql;
```

### 2. 환경 변수 설정

```bash
# /etc/tomcat9/tomcat9.conf 또는 setenv.sh
export DB_HOST=localhost
export DB_PORT=3306
export DB_NAME=ai_navigator
export DB_USER=your_user
export DB_PASSWORD=your_password
```

### 3. Java 클래스 컴파일

```bash
cd /var/lib/tomcat9/webapps/ROOT

javac -encoding UTF-8 \
  -cp "WEB-INF/lib/*:/usr/share/tomcat9/lib/*" \
  -d WEB-INF/classes \
  WEB-INF/src/**/*.java
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
| `http://localhost:8080/AI/admin/dashboard.jsp` | 관리자 대시보드 |

---

## 주요 Java 클래스

| 클래스 | 역할 |
|---|---|
| `db.DBConnect` | HikariCP 커넥션 풀 관리 |
| `dao.AIToolDAO` | AI 도구 CRUD, 검색, 추천 |
| `dao.LabProjectDAO` | 실습 프로젝트 CRUD, 필터링 |
| `dao.UserDAO` | 사용자 CRUD, 인증 |
| `servlet.AIToolServlet` | `/api/tools` REST API |
| `filter.SecurityHeadersFilter` | 보안 헤더 필터 |
| `util.PasswordUtil` | 비밀번호 해싱 |

---

## 보안

- **역할 기반 접근 제어**: 사용자 / 관리자 / Superadmin 분리
- **세션 인증**: 관리자 페이지 접근 시 세션 검증
- **보안 헤더**: `X-Content-Type-Options`, `X-Frame-Options`, `CSP` 등 자동 적용
- **환경 변수 DB 설정**: DB 자격증명 하드코딩 금지

---

## 라이선스

이 프로젝트는 포트폴리오 목적으로 제작되었습니다.

## 작성자

- **박진영** · 동신대학교 컴퓨터공학과
- GitHub: [zln02](https://github.com/zln02)

