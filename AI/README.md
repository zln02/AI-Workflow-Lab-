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

## 주요 업데이트
- 보안 기능 강화 (CSRF 보호, 보안 헤더)
- UI/UX 개선 (다크 테마, 애니메이션)
- 사용자 기능 확장 (프로필 이미지 업로드)
- API 기능 개선 (검색, 추천 시스템)

## 기여자
- 개발팀

## 라이선스
MIT License
