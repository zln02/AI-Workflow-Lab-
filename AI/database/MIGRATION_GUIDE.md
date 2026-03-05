# Supabase 마이그레이션 가이드

## 1. Supabase 프로젝트 설정

### 1.1 프로젝트 생성
1. [Supabase](https://supabase.com) 접속하여 회원가입/로그인
2. New Project 클릭
3. 조직 선택 (없으면 생성)
4. 프로젝트 정보 입력:
   - Name: `ai-navigator`
   - Database Password: 강력한 비밀번호 생성
   - Region: 가까운 지역 선택 (예: Northeast Asia (Seoul))

### 1.2 프로젝트 정보 확인
- Dashboard > Settings > API 에서:
  - Project URL: `https://[PROJECT-REF].supabase.co`
  - Project API Key: `anon` 키와 `service_role` 키 확인

## 2. 데이터베이스 스키마 마이그레이션

### 2.1 스키마 실행
1. Supabase Dashboard > SQL Editor 접속
2. `supabase_schema.sql` 내용 복사하여 실행
3. 모든 테이블, 인덱스, RLS 정책 생성 확인

### 2.2 초기 데이터 삽입 (선택사항)
```sql
-- 관리자 계정 생성
INSERT INTO admins (username, password, name, email, role, status) 
VALUES ('admin', '$2a$10$...', '관리자', 'admin@example.com', 'SUPER', 'ACTIVE');

-- 카테고리 예시 데이터
INSERT INTO categories (category_name, description, icon, display_order) VALUES
('텍스트 생성', 'GPT, Claude 등 텍스트 생성 AI', 'type', 1),
('이미지 생성', 'DALL-E, Midjourney 등 이미지 생성 AI', 'image', 2),
('음성/오디오', 'Whisper, TTS 등 음성 관련 AI', 'soundwave', 3),
('비디오', '비디오 생성 및 편집 AI', 'camera-video', 4),
('임베딩', '텍스트 임베딩 및 검색 AI', 'search', 5);

-- 제공사 예시 데이터
INSERT INTO providers (provider_name, website, country, description) VALUES
('OpenAI', 'https://openai.com', 'USA', 'GPT, DALL-E 등 다양한 AI 모델 제공'),
('Google', 'https://google.com', 'USA', 'Gemini, PaLM 등 구글 AI 모델'),
('Anthropic', 'https://anthropic.com', 'USA', 'Claude 시리즈 AI 모델'),
('Meta', 'https://meta.com', 'USA', 'Llama 오픈소스 모델');
```

## 3. 애플리케이션 설정

### 3.1 PostgreSQL JDBC Driver 추가
1. [PostgreSQL JDBC Driver 다운로드](https://jdbc.postgresql.org/download/)
2. `postgresql-42.7.3.jar` 파일을 `/var/lib/tomcat9/webapps/ROOT/WEB-INF/lib/`에 복사

```bash
# Tomcat lib 디렉토리로 복사
sudo cp postgresql-42.7.3.jar /var/lib/tomcat9/webapps/ROOT/WEB-INF/lib/
sudo chown tomcat:tomcat /var/lib/tomcat9/webapps/ROOT/WEB-INF/lib/postgresql-42.7.3.jar
```

### 3.2 DBConnect 클래스 업데이트
기존 `DBConnect.java`를 `DBConnect_Supabase.java`로 교체:

```bash
cd /var/lib/tomcat9/webapps/ROOT/WEB-INF/classes/db
mv DBConnect.java DBConnect_MySQL.java
cp /var/lib/tomcat9/webapps/ROOT/AI/database/DBConnect_Supabase.java .
javac -cp ".:/var/lib/tomcat9/webapps/ROOT/WEB-INF/lib/*" DBConnect_Supabase.java
```

### 3.3 연결 설정 파일
`supabase_connection.properties` 파일에 실제 프로젝트 정보 입력:

```properties
db.url=jdbc:postgresql://[PROJECT-REF].supabase.co:5432/postgres
db.username=postgres
db.password=[실제 비밀번호]
supabase.url=https://[PROJECT-REF].supabase.co
supabase.anonKey=[실제 anon 키]
supabase.serviceRoleKey=[실제 service_role 키]
supabase.projectRef=[PROJECT-REF]
```

## 4. DAO 클래스 수정

### 4.1 SQL 문법 변경
주요 변경사항:
- `AUTO_INCREMENT` → `DEFAULT uuid_generate_v4()`
- `ENUM` 타입 → `VARCHAR` with CHECK 제약
- `SET` 타입 → `TEXT[]` 배열
- `NOW()` → `NOW()` (동일)
- `LIMIT ?, ?` → `LIMIT ? OFFSET ?`

### 4.2 DAO 수정 예시
```java
// Before (MySQL)
String sql = "SELECT * FROM ai_models WHERE category_id = ? LIMIT ?, ?";

// After (PostgreSQL)
String sql = "SELECT * FROM ai_models WHERE category_id = ? LIMIT ? OFFSET ?";
```

## 5. 테스트 및 검증

### 5.1 연결 테스트
```bash
# Tomcat 재시작
sudo systemctl restart tomcat9

# 로그 확인
sudo tail -f /var/log/tomcat9/catalina.out
```

### 5.2 기능 테스트
1. 관리자 로그인: http://localhost:8080/AI/admin/auth/login.jsp
2. 메인 페이지: http://localhost:8080/AI/user/home.jsp
3. 모델 검색: http://localhost:8080/AI/user/models.jsp

## 6. 문제 해결

### 6.1 일반적인 오류
1. **ClassNotFoundException: org.postgresql.Driver**
   - PostgreSQL JDBC Driver가 lib 폴더에 없음
   - 클래스패스 확인

2. **Connection refused**
   - 방화벽 또는 네트워크 문제
   - Supabase 설정 확인

3. **SSL 연결 오류**
   - `ssl=true` 설정 확인
   - PostgreSQL SSL 모드 확인

### 6.2 로그 위치
- Tomcat 로그: `/var/log/tomcat9/catalina.out`
- 애플리케이션 로그: `/var/log/tomcat9/localhost.YYYY-MM-DD.log`

## 7. 추가 설정

### 7.1 Realtime 기능 활성화
```sql
-- Realtime 활성화
ALTER PUBLICATION supabase_realtime ADD TABLE ai_models;
ALTER PUBLICATION supabase_realtime ADD TABLE packages;
ALTER PUBLICATION supabase_realtime ADD TABLE orders;
```

### 7.2 Storage 설정
```sql
-- Storage 버킷 생성
INSERT INTO storage.buckets (id, name, public) 
VALUES ('model-images', 'model-images', true);
```

## 8. 성능 최적화

### 8.1 Connection Pool
```properties
# supabase_connection.properties
db.maxPoolSize=20
db.minPoolSize=5
db.initialPoolSize=10
```

### 8.2 인덱스 확인
```sql
-- 인덱스 현황 확인
SELECT schemaname, tablename, indexname, indexdef 
FROM pg_indexes 
WHERE schemaname = 'public';
```

## 9. 보안 강화

### 9.1 API 키 관리
- `service_role` 키는 서버에서만 사용
- 클라이언트에서는 `anon` 키만 사용
- 환경변수 또는 보안 저장소에 키 저장

### 9.2 RLS 정책 검토
- 모든 테이블에 RLS 활성화 확인
- 정책이 너무 관대하지 않은지 검토

## 10. 모니터링

### 10.1 Supabase 대시보드
- 사용량 모니터링
- 쿼리 성능 분석
- 에러 로그 확인

### 10.2 애플리케이션 모니터링
- 데이터베이스 연결 상태
- 쿼리 응답 시간
- 에러 발생률
