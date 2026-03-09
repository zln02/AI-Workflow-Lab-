# AI 폴더 리팩토링 보고서

## 리팩토링 개요
- **대상**: /var/lib/tomcat9/webapps/ROOT/AI 폴더
- **목적**: 중복 파일 제거, 구조 개선, Supabase 연동 준비
- **수행일**: 2026-03-05

## 1. 파일 구조 분석

### 현재 구조
```
AI/
├── admin/           # 관리자 페이지 (35개 JSP)
├── api/             # API 엔드포인트 (10개 JSP)
├── assets/          # 정적 파일 (9개 JS, 6개 CSS)
├── database/        # DB 스키마 및 유틸리티
├── partials/        # 공통 JSP 조각 (3개)
└── user/            # 사용자 페이지 (15개 JSP)
```

### 파일 통계
- **총 JSP 파일**: 60개
- **JavaScript 파일**: 9개
- **CSS 파일**: 6개
- **DB 관련 파일**: 8개

## 2. 데이터베이스 스키마

### 기존 스키마 (MySQL)
- **13개 주요 테이블**
  - admins, providers, categories, ai_models
  - tags, model_tags, packages, package_categories
  - package_items, cart, orders, order_items, search_logs
  - hr_data (HR 현황 테이블)

### Supabase용 스키마 변환
- **데이터베이스**: MySQL → PostgreSQL
- **기본 키**: INT AUTO_INCREMENT → UUID
- **타임스탬프**: TIMESTAMP → TIMESTAMPTZ
- **SET 타입**: → TEXT[] 배열
- **JSON 타입**: → JSONB (PostgreSQL 최적화)
- **RLS 정책**: Row Level Security 활성화
- **인덱스**: PostgreSQL 최적화

## 3. Supabase 연동 설정

### 필요한 라이브러리
```xml
<!-- PostgreSQL JDBC Driver -->
<dependency>
    <groupId>org.postgresql</groupId>
    <artifactId>postgresql</artifactId>
    <version>42.7.3</version>
</dependency>

<!-- Supabase Java Client (선택사항) -->
<dependency>
    <groupId>supabase</groupId>
    <artifactId>supabase-java</artifactId>
    <version>1.0.0</version>
</dependency>
```

### 연결 설정 파일
- `supabase_connection.properties`: 데이터베이스 연결 정보
- `DBConnect_Supabase.java`: Supabase 연결 클래스
- `supabase_schema.sql`: PostgreSQL 스키마

### 설정 방법
1. Supabase 프로젝트 생성
2. `supabase_connection.properties` 파일에 프로젝트 정보 입력
3. PostgreSQL JDBC Driver를 `WEB-INF/lib`에 추가
4. `supabase_schema.sql` 실행하여 테이블 생성

## 4. 리팩토링 권장사항

### 코드 개선
1. **DAO 클래스 수정**: MySQL 문법 → PostgreSQL 문법
   - AUTO_INCREMENT → DEFAULT uuid_generate_v4()
   - ENUM 타입 → CHECK 제약조건
   - SET 타입 → 배열

2. **JSP 파일 개선**
   - 중복 코드 제거
   - 공통 모듈화 (partials 활용)
   - SQL 인젝션 방어 (PreparedStatement 사용)

3. **JavaScript/CSS 최적화**
   - 파일 병합 및 압축
   - CDN 활용 고려
   - 모듈화 개선

### 보안 강화
1. **SQL 인젝션 방어**
   ```java
   // Before
   String sql = "SELECT * FROM users WHERE id = " + userId;
   
   // After
   String sql = "SELECT * FROM users WHERE id = ?";
   PreparedStatement ps = conn.prepareStatement(sql);
   ps.setInt(1, userId);
   ```

2. **XSS 방어**
   ```jsp
   <!-- Before -->
   <%= user.getName() %>
   
   <!-- After -->
   <c:out value="${user.name}" escapeXml="true"/>
   ```

3. **CSRF 방어**
   - CSRFUtil 클래스 활용
   - 토큰 검증 구현

## 5. 성능 최적화

### 데이터베이스
1. **인덱스 최적화**
   - 검색 자주 하는 컬럼에 인덱스 추가
   - 복합 인덱스 고려

2. **쿼리 최적화**
   - N+1 문제 해결
   - JOIN 최적화
   - 페이징 처리 개선

### 애플리케이션
1. **캐싱 전략**
   - 정적 파일 캐싱
   - DB 쿼리 결과 캐싱
   - Redis 도입 고려

2. **리소스 최적화**
   - 이미지 최적화
   - CSS/JS 압축
   - Lazy Loading 구현

## 6. 다음 단계

1. **Supabase 마이그레이션**
   - [ ] Supabase 프로젝트 생성
   - [ ] 스키마 마이그레이션 실행
   - [ ] 데이터 마이그레이션 (기존 데이터가 있는 경우)
   - [ ] 연결 테스트

2. **코드 리팩토링**
   - [ ] DAO 클래스 PostgreSQL용으로 수정
   - [ ] JSP 파일 SQL 쿼리 수정
   - [ ] 테스트 케이스 작성

3. **배포 및 테스트**
   - [ ] 개발 환경 배포
   - [ ] 기능 테스트
   - [ ] 성능 테스트
   - [ ] 보안 점검

## 7. 연락처 및 지원

- **Supabase 문서**: https://supabase.com/docs
- **PostgreSQL JDBC 문서**: https://jdbc.postgresql.org/documentation/
- **마이그레이션 지원**: 기술팀 문의
