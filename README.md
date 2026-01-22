# AI Navigator - AI 모델 마켓플레이스

AI 모델을 탐색하고 구매할 수 있는 웹 기반 마켓플레이스 플랫폼입니다.

## 📋 프로젝트 개요

AI Navigator는 다양한 AI 모델을 한 곳에서 탐색, 비교, 구매할 수 있는 통합 플랫폼입니다. 사용자는 텍스트, 이미지, 비디오, 오디오, 임베딩 등 다양한 모달리티의 AI 모델을 검색하고 패키지 형태로 구매할 수 있습니다.

### 주요 기능

- **AI 모델 탐색**: 카테고리 및 모달리티별 필터링
- **패키지 구매**: 여러 모델을 묶은 패키지 상품 제공
- **장바구니 및 결제**: 실시간 가격 계산 및 주문 관리
- **마이페이지**: 구독 내역, 구매 내역, 주문 관리
- **관리자 대시보드**: 모델, 패키지, 사용자 관리

## 🛠 기술 스택

### Backend
- **Java**: JSP/Servlet 기반 웹 애플리케이션
- **Tomcat 9**: 웹 애플리케이션 서버
- **MySQL 8.0**: 관계형 데이터베이스
- **JDBC**: 데이터베이스 연결 및 쿼리 실행

### Frontend
- **HTML5/CSS3**: 반응형 웹 디자인
- **JavaScript (ES6+)**: 클라이언트 사이드 로직
- **Glassmorphism UI**: 현대적인 UI 디자인

### Architecture
- **MVC Pattern**: 모델-뷰-컨트롤러 아키텍처
- **DAO Pattern**: 데이터 접근 객체 패턴
- **Session Management**: 세션 기반 인증 및 상태 관리

### Security
- **CSRF Protection**: CSRF 토큰 기반 보안
- **Role-based Access Control**: 역할 기반 접근 제어
- **Password Hashing**: 비밀번호 해싱 (BCrypt)

## 📁 프로젝트 구조

```
ROOT/
├── AI/
│   ├── admin/              # 관리자 페이지
│   │   ├── auth/           # 관리자 인증
│   │   ├── models/         # 모델 관리
│   │   ├── packages/       # 패키지 관리
│   │   ├── categories/     # 카테고리 관리
│   │   ├── providers/      # 제공자 관리
│   │   ├── users/          # 사용자 관리
│   │   ├── pricing/        # 요금제 관리
│   │   └── statistics/     # 통계 대시보드
│   ├── user/               # 사용자 페이지
│   │   ├── home.jsp        # 홈페이지
│   │   ├── models.jsp      # 모델 목록
│   │   ├── modelDetail.jsp # 모델 상세
│   │   ├── package.jsp     # 패키지 목록
│   │   ├── cart.jsp        # 장바구니
│   │   ├── checkout.jsp    # 결제 페이지
│   │   ├── mypage.jsp      # 마이페이지
│   │   ├── login.jsp        # 로그인
│   │   └── signup.jsp       # 회원가입
│   ├── api/                # API 엔드포인트
│   │   ├── search.jsp       # 검색 API
│   │   ├── models.jsp      # 모델 목록 API
│   │   ├── packages.jsp     # 패키지 목록 API
│   │   └── cart-summary.jsp # 장바구니 요약 API
│   ├── assets/             # 정적 리소스
│   │   ├── css/            # 스타일시트
│   │   ├── js/             # JavaScript 파일
│   │   └── img/            # 이미지 파일
│   ├── partials/           # 공통 컴포넌트
│   │   ├── header.jsp      # 헤더
│   │   └── footer.jsp      # 푸터
│   └── database/           # 데이터베이스 스키마
├── WEB-INF/
│   └── classes/
│       ├── dao/            # 데이터 접근 객체
│       ├── model/          # 데이터 모델
│       ├── service/        # 비즈니스 로직
│       ├── util/           # 유틸리티 클래스
│       ├── security/       # 보안 관련 클래스
│       ├── filter/         # 필터 클래스
│       └── db/             # 데이터베이스 연결
├── intro.jsp               # 프로젝트 소개 페이지
└── README.md               # 이 파일
```

## 🚀 설치 및 실행

### 필수 요구사항

- Java 8 이상
- Apache Tomcat 9.0 이상
- MySQL 8.0 이상
- Maven (선택사항)

### 1. 데이터베이스 설정

#### 환경 변수 설정

프로젝트는 환경 변수를 통해 데이터베이스 연결 정보를 관리합니다.

```bash
# 환경 변수 설정 (Linux/Mac)
export DB_HOST=your-db-host
export DB_PORT=3306
export DB_NAME=your-db-name
export DB_USER=your-db-user
export DB_PASSWORD=your-db-password

# 또는 Tomcat 설정 파일에 추가
# /etc/tomcat9/tomcat9.conf 또는 setenv.sh
export DB_HOST=your-db-host
export DB_PORT=3306
export DB_NAME=your-db-name
export DB_USER=your-db-user
export DB_PASSWORD=your-db-password
```

#### 데이터베이스 스키마 생성

```bash
# MySQL에 접속하여 스키마 생성
mysql -u root -p

# 데이터베이스 생성
CREATE DATABASE ai_navigator CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

# 스키마 파일 실행
SOURCE /path/to/AI/database/schema.sql;
```

### 2. 프로젝트 빌드

```bash
# 프로젝트 디렉토리로 이동
cd /var/lib/tomcat9/webapps/ROOT

# Java 클래스 컴파일 (필요한 경우)
javac -cp "$CATALINA_HOME/lib/*:WEB-INF/classes" \
  WEB-INF/classes/**/*.java
```

### 3. Tomcat 배포

```bash
# WAR 파일로 패키징 (선택사항)
jar -cvf ai-navigator.war *

# 또는 직접 ROOT 디렉토리에 배포
# Tomcat이 자동으로 감지하여 배포합니다
```

### 4. Tomcat 시작

```bash
# Tomcat 시작
sudo systemctl start tomcat9

# 또는 직접 실행
$CATALINA_HOME/bin/startup.sh
```

### 5. 접속 확인

- **사용자 페이지**: http://localhost:8080/AI/user/home.jsp
- **관리자 페이지**: http://localhost:8080/AI/admin/auth/login.jsp
- **프로젝트 소개**: http://localhost:8080/intro.jsp

## 🔐 보안 설정

### CSRF 보호

모든 POST 요청은 CSRF 토큰 검증을 거칩니다. 세션에 자동으로 CSRF 토큰이 생성됩니다.

### 비밀번호 해싱

사용자 비밀번호는 BCrypt 알고리즘으로 해싱되어 저장됩니다.

### 세션 관리

- 세션 타임아웃: 30분 (기본값)
- 세션 쿠키: HttpOnly, Secure 플래그 설정 권장

## 📝 주요 파일 설명

### JSP 파일

- **home.jsp**: 메인 홈페이지, 추천 모델 및 패키지 표시
- **models.jsp**: 전체 AI 모델 목록 및 필터링
- **modelDetail.jsp**: 모델 상세 정보 페이지
- **cart.jsp**: 장바구니 관리
- **checkout.jsp**: 결제 페이지
- **mypage.jsp**: 사용자 마이페이지

### Java 클래스

- **DBConnect**: 데이터베이스 연결 관리
- **AIModelDAO**: AI 모델 데이터 접근
- **PackageDAO**: 패키지 데이터 접근
- **UserDAO**: 사용자 데이터 접근
- **CSRFUtil**: CSRF 토큰 관리
- **PasswordUtils**: 비밀번호 해싱 유틸리티

## 🧪 테스트

### 데이터베이스 연결 테스트

```java
import db.DBConnect;
import java.sql.Connection;

Connection conn = DBConnect.getConnection();
if (conn != null) {
    System.out.println("데이터베이스 연결 성공");
    conn.close();
}
```

## 🐛 문제 해결

### 데이터베이스 연결 실패

1. 환경 변수가 올바르게 설정되었는지 확인
2. MySQL 서버가 실행 중인지 확인
3. 방화벽 설정 확인
4. 데이터베이스 사용자 권한 확인

### 세션 문제

1. Tomcat 세션 설정 확인
2. 쿠키 설정 확인
3. 세션 타임아웃 설정 확인

## 📄 라이선스

이 프로젝트는 교육 목적으로 제작되었습니다.

## 👤 작성자

- **이름**: 박진영
- **소속**: 동신대학교 컴퓨터공학과

## 🙏 감사의 말

이 프로젝트는 포트폴리오 목적으로 제작되었으며, 실제 운영 환경에서 사용하기 전에 추가적인 보안 검토 및 테스트가 필요합니다.

## 📞 문의

프로젝트 관련 문의사항이 있으시면 이슈를 등록해주세요.

## 🔄 최근 업데이트

### 리팩토링 완료 사항

- ✅ **코드 가독성 개선**: JSP 및 Java 파일 리팩토링
- ✅ **보안 강화**: XSS 방지 함수 개선, CSRF 보호 강화
- ✅ **환경 변수 지원**: DBConnect 클래스에 환경 변수 지원 추가
- ✅ **문서화**: README.md 및 .gitignore 파일 작성
- ✅ **코드 정리**: 중복 코드 제거, 함수 분리

### 주요 변경사항

1. **`_common.jsp`**: XSS 방지 함수 개선 및 유틸리티 함수 추가
2. **`home.jsp`**: 모달리티 결정 로직 함수화, Provider 로고 매핑 함수화
3. **`DBConnect.java`**: 하드코딩된 비밀번호 제거, 환경 변수 지원
4. **`AIModelDAO.java`**: JavaDoc 주석 추가, 입력 검증 강화

---

**참고**: 이 프로젝트는 과제용 웹사이트입니다. 실제 서비스 운영 시 추가적인 보안 강화 및 성능 최적화가 필요합니다.

