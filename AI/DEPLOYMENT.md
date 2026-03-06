# 서버 이전 및 배포 가이드

## 새 서버에서 프로젝트 설정하기

### 1. 필수 요구사항 설치
```bash
# Java 8 이상
sudo apt update
sudo apt install openjdk-8-jdk

# Apache Tomcat 9
sudo apt install tomcat9

# MySQL 또는 PostgreSQL
sudo apt install mysql-server
# 또는
sudo apt install postgresql postgresql-contrib
```

### 2. Git 저장소 클론
```bash
# Tomcat 웹앱 디렉토리로 이동
cd /var/lib/tomcat9/webapps/

# 기존 ROOT 디렉토리 백업 (필요시)
sudo mv ROOT ROOT_backup

# 저장소 클론
sudo git clone https://github.com/zln02/AI-Workflow-Lab-.git ROOT

# 권한 설정
sudo chown -R tomcat:tomcat /var/lib/tomcat9/webapps/ROOT
sudo chmod -R 755 /var/lib/tomcat9/webapps/ROOT
```

### 3. 데이터베이스 설정
```bash
# 데이터베이스 생성
mysql -u root -p
CREATE DATABASE ai_workflow;
CREATE USER 'ai_user'@'localhost' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON ai_workflow.* TO 'ai_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;

# 또는 PostgreSQL의 경우
sudo -u postgres psql
CREATE DATABASE ai_workflow;
CREATE USER ai_user WITH PASSWORD 'your_password';
GRANT ALL PRIVILEGES ON DATABASE ai_workflow TO ai_user;
\q
```

### 4. 데이터베이스 연결 설정
```bash
# 민감한 정보 파일 생성 (GitHub에는 올라가지 않음)
sudo nano /var/lib/tomcat9/webapps/ROOT/AI/database/local_connection.properties
```

파일 내용:
```properties
# Database Connection
db.driver=com.mysql.cj.jdbc.Driver
db.url=jdbc:mysql://localhost:3306/ai_workflow?useSSL=false&serverTimezone=UTC
db.username=ai_user
db.password=your_actual_password

# Connection Pool Settings
db.maxPoolSize=20
db.minPoolSize=5
db.initialPoolSize=10
```

### 5. Java 클래스 컴파일
```bash
# WEB-INF/src로 이동
cd /var/lib/tomcat9/webapps/ROOT/WEB-INF/src

# 클래스 컴파일
sudo javac -cp "/usr/share/tomcat9/lib/*:." -d ../classes $(find . -name "*.java")

# 권한 설정
sudo chown -R tomcat:tomcat /var/lib/tomcat9/webapps/ROOT/WEB-INF/classes
```

### 6. Tomcat 서비스 재시작
```bash
sudo systemctl restart tomcat9
sudo systemctl status tomcat9
```

### 7. 접속 확인
- 브라우저에서 `http://localhost:8080` 접속
- 관리자 페이지: `http://localhost:8080/AI/admin/`

## 주기적인 업데이트 방법

### 최신 변경사항 받기
```bash
cd /var/lib/tomcat9/webapps/ROOT
sudo git pull origin master

# Java 파일 변경 시 재컴파일
cd WEB-INF/src
sudo javac -cp "/usr/share/tomcat9/lib/*:." -d ../classes $(find . -name "*.java")

# Tomcat 재시작
sudo systemctl restart tomcat9
```

## 백업 전략
```bash
# 정기적으로 데이터베이스 백업
mysqldump -u ai_user -p ai_workflow > backup_$(date +%Y%m%d).sql

# 파일 시스템 백업
sudo tar -czf ai_workflow_backup_$(date +%Y%m%d).tar.gz /var/lib/tomcat9/webapps/ROOT
```

## 문제 해결

### 로그 확인
```bash
# Tomcat 로그
sudo tail -f /var/log/tomcat9/catalina.out

# 액세스 로그
sudo tail -f /var/log/tomcat9/localhost_access_log.$(date +%Y-%m-%d).txt
```

### 권한 문제
```bash
# 권한 재설정
sudo chown -R tomcat:tomcat /var/lib/tomcat9/webapps/ROOT
sudo chmod -R 755 /var/lib/tomcat9/webapps/ROOT
```

### 포트 충돌
```bash
# 포트 확인
sudo netstat -tlnp | grep :8080

# Tomcat 설정 수정
sudo nano /etc/tomcat9/server.xml
```

## 보안 확인清单
- [ ] 데이터베이스 비밀번호 변경
- [ ] 방화벽 설정 (8080 포트)
- [ ] SSL/TLS 인증서 설정 (HTTPS)
- [ ] 불필요한 서비스 비활성화
- [ ] 정기적인 업데이트 적용
