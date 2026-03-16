# Task 06: P2 Maven 빌드 시스템 + CI/CD 파이프라인

## 현재 상태
- 빌드 시스템 없음 (javac 수동 컴파일)
- JAR 라이브러리를 WEB-INF/lib/에 직접 관리
- .class 파일이 Git에 추적됨
- CI/CD 없음

---

## 작업 6-1: Maven 프로젝트 구조로 전환

### 새 파일: `pom.xml` (프로젝트 루트)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.aiworkflowlab</groupId>
    <artifactId>ai-workflow-lab</artifactId>
    <version>1.0.0</version>
    <packaging>war</packaging>
    <name>AI Workflow Lab</name>

    <properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <maven.compiler.source>11</maven.compiler.source>
        <maven.compiler.target>11</maven.compiler.target>
    </properties>

    <dependencies>
        <!-- Servlet API (Tomcat 제공) -->
        <dependency>
            <groupId>javax.servlet</groupId>
            <artifactId>javax.servlet-api</artifactId>
            <version>4.0.1</version>
            <scope>provided</scope>
        </dependency>
        <dependency>
            <groupId>javax.servlet.jsp</groupId>
            <artifactId>javax.servlet.jsp-api</artifactId>
            <version>2.3.3</version>
            <scope>provided</scope>
        </dependency>

        <!-- MySQL Connector -->
        <dependency>
            <groupId>com.mysql</groupId>
            <artifactId>mysql-connector-j</artifactId>
            <version>9.5.0</version>
        </dependency>

        <!-- HikariCP Connection Pool -->
        <dependency>
            <groupId>com.zaxxer</groupId>
            <artifactId>HikariCP</artifactId>
            <version>5.1.0</version>
        </dependency>

        <!-- Gson JSON -->
        <dependency>
            <groupId>com.google.code.gson</groupId>
            <artifactId>gson</artifactId>
            <version>2.10.1</version>
        </dependency>

        <!-- BCrypt -->
        <dependency>
            <groupId>at.favre.lib</groupId>
            <artifactId>bcrypt</artifactId>
            <version>0.10.2</version>
        </dependency>

        <!-- SLF4J Logging -->
        <dependency>
            <groupId>org.slf4j</groupId>
            <artifactId>slf4j-api</artifactId>
            <version>2.0.9</version>
        </dependency>
        <dependency>
            <groupId>org.slf4j</groupId>
            <artifactId>slf4j-simple</artifactId>
            <version>2.0.9</version>
        </dependency>

        <!-- JUnit 5 (테스트) -->
        <dependency>
            <groupId>org.junit.jupiter</groupId>
            <artifactId>junit-jupiter</artifactId>
            <version>5.10.1</version>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <finalName>ROOT</finalName>
        <sourceDirectory>src/main/java</sourceDirectory>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-war-plugin</artifactId>
                <version>3.4.0</version>
                <configuration>
                    <warSourceDirectory>src/main/webapp</warSourceDirectory>
                </configuration>
            </plugin>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.11.0</version>
                <configuration>
                    <source>11</source>
                    <target>11</target>
                    <encoding>UTF-8</encoding>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
```

### 디렉토리 재구성 가이드

```
프로젝트 루트/
├── pom.xml
├── src/
│   ├── main/
│   │   ├── java/               <- WEB-INF/src/ 내용 이동
│   │   │   ├── constants/
│   │   │   ├── dao/
│   │   │   ├── db/             <- WEB-INF/src/db/DBConnect.java
│   │   │   ├── dto/
│   │   │   ├── filter/
│   │   │   ├── model/
│   │   │   ├── service/
│   │   │   ├── servlet/
│   │   │   └── util/
│   │   ├── resources/          <- properties 등 설정 파일
│   │   └── webapp/             <- 웹 리소스
│   │       ├── AI/             <- 기존 AI/ 폴더 그대로
│   │       └── WEB-INF/
│   │           └── web.xml
│   └── test/
│       └── java/               <- 테스트 코드
├── .gitignore
└── README.md
```

### 마이그레이션 스크립트:

```bash
#!/bin/bash
PROJECT_ROOT="/var/lib/tomcat9/webapps/ROOT"
cd "$PROJECT_ROOT"

# Maven 디렉토리 구조 생성
mkdir -p src/main/java
mkdir -p src/main/resources
mkdir -p src/main/webapp
mkdir -p src/test/java

# Java 소스 이동
cp -r WEB-INF/src/* src/main/java/
cp -r WEB-INF/classes/db src/main/java/

# 웹 리소스 이동
cp -r AI src/main/webapp/
cp WEB-INF/web.xml src/main/webapp/WEB-INF/

# pom.xml은 프로젝트 루트에 이미 생성됨

echo "Maven 구조 전환 완료. 'mvn clean package'로 빌드하세요."
```

---

## 작업 6-2: Git에서 컴파일 파일 추적 해제

```bash
cd /var/lib/tomcat9/webapps/ROOT

# 컴파일된 파일 추적 해제
git rm -r --cached WEB-INF/classes/ 2>/dev/null || true
git rm -r --cached WEB-INF/lib/ 2>/dev/null || true

# .gitignore에 이미 포함되어 있는지 확인 (이미 있음)
# WEB-INF/classes/**/*.class
# WEB-INF/lib/

git add .gitignore
git commit -m "chore: remove compiled files and libraries from git tracking"
```

---

## 작업 6-3: GitHub Actions CI/CD

### 새 파일: `.github/workflows/ci.yml`

```yaml
name: CI Build & Test

on:
  pull_request:
    branches: [master, main]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Set up JDK 11
        uses: actions/setup-java@v4
        with:
          java-version: '11'
          distribution: 'temurin'

      - name: Build with Maven
        run: mvn clean compile -B

      - name: Run tests
        run: mvn test -B

      - name: Package WAR
        run: mvn package -B -DskipTests
```

### 새 파일: `.github/workflows/deploy.yml`

```yaml
name: Deploy to Production

on:
  push:
    branches: [master, main]

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Set up JDK 11
        uses: actions/setup-java@v4
        with:
          java-version: '11'
          distribution: 'temurin'

      - name: Build WAR
        run: mvn clean package -B -DskipTests

      - name: Deploy to server
        uses: appleboy/scp-action@v0.1.7
        with:
          host: ${{ secrets.SERVER_HOST }}
          username: ${{ secrets.SERVER_USER }}
          key: ${{ secrets.SSH_PRIVATE_KEY }}
          source: "target/ROOT.war"
          target: "/tmp/"

      - name: Restart Tomcat
        uses: appleboy/ssh-action@v1.0.3
        with:
          host: ${{ secrets.SERVER_HOST }}
          username: ${{ secrets.SERVER_USER }}
          key: ${{ secrets.SSH_PRIVATE_KEY }}
          script: |
            sudo systemctl stop tomcat9
            sudo rm -rf /var/lib/tomcat9/webapps/ROOT
            sudo cp /tmp/target/ROOT.war /var/lib/tomcat9/webapps/
            sudo systemctl start tomcat9
            sleep 5
            curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 || echo "Health check failed"
```

### GitHub Secrets 설정 필요:
- `SERVER_HOST` - 서버 IP/도메인
- `SERVER_USER` - SSH 사용자
- `SSH_PRIVATE_KEY` - SSH 개인키

---

## 작업 6-4: 배포 스크립트 (수동 배포용)

### 새 파일: `deploy.sh`

```bash
#!/bin/bash
set -e

echo "=== AI Workflow Lab 배포 ==="

# Maven 빌드
echo "[1/4] Maven 빌드..."
mvn clean package -DskipTests -q

# Tomcat 중지
echo "[2/4] Tomcat 중지..."
sudo systemctl stop tomcat9

# WAR 배포
echo "[3/4] WAR 파일 배포..."
sudo rm -rf /var/lib/tomcat9/webapps/ROOT
sudo cp target/ROOT.war /var/lib/tomcat9/webapps/

# Tomcat 시작
echo "[4/4] Tomcat 시작..."
sudo systemctl start tomcat9

# 헬스체크
sleep 5
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080)
if [ "$HTTP_CODE" = "200" ]; then
    echo "=== 배포 완료! (HTTP $HTTP_CODE) ==="
else
    echo "=== 경고: HTTP $HTTP_CODE 반환 ==="
    sudo journalctl -u tomcat9 --no-pager -n 20
fi
```

```bash
chmod +x deploy.sh
```
