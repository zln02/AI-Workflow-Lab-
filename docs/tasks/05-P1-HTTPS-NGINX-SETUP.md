# Task 05: P1 HTTPS 설정 (Nginx 리버스 프록시 + SSL)

## 현재 상태
- Tomcat 9가 HTTP 8080 포트에서 동작
- web.xml에 `<secure>true</secure>` 설정 있지만 실제 HTTPS 미구현
- 세션 쿠키에 `secure` 플래그가 있어 HTTP에서 쿠키 전송 안 될 수 있음

---

## 작업 5-1: Nginx 설치 및 리버스 프록시 설정

### 1. Nginx 설치
```bash
sudo apt update
sudo apt install -y nginx
```

### 2. Nginx 설정 파일 생성
`/etc/nginx/sites-available/ai-workflow-lab`:

```nginx
# HTTP -> HTTPS 리다이렉트
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;

    # Let's Encrypt 인증용
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 301 https://$host$request_uri;
    }
}

# HTTPS 설정
server {
    listen 443 ssl http2;
    server_name your-domain.com www.your-domain.com;

    # SSL 인증서 (Let's Encrypt)
    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;

    # SSL 보안 설정
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # HSTS
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    # 요청 크기 제한 (파일 업로드 대응)
    client_max_body_size 10M;

    # gzip 압축
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml text/javascript image/svg+xml;
    gzip_min_length 1000;

    # 정적 파일 캐싱
    location /AI/assets/ {
        proxy_pass http://127.0.0.1:8080;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    # Tomcat 리버스 프록시
    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Port $server_port;

        # 타임아웃 설정
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
```

### 3. 사이트 활성화
```bash
sudo ln -s /etc/nginx/sites-available/ai-workflow-lab /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default  # 기본 설정 제거
sudo nginx -t  # 설정 검증
sudo systemctl restart nginx
```

---

## 작업 5-2: Let's Encrypt SSL 인증서 발급

```bash
# Certbot 설치
sudo apt install -y certbot python3-certbot-nginx

# 인증서 발급 (Nginx 플러그인 사용)
sudo certbot --nginx -d your-domain.com -d www.your-domain.com

# 자동 갱신 테스트
sudo certbot renew --dry-run

# 자동 갱신 크론잡 (이미 설정됨 확인)
sudo systemctl status certbot.timer
```

---

## 작업 5-3: Tomcat 설정 수정

### `/etc/tomcat9/server.xml` 수정

Connector 부분에 프록시 설정 추가:
```xml
<Connector port="8080" protocol="HTTP/1.1"
           connectionTimeout="20000"
           redirectPort="8443"
           proxyName="your-domain.com"
           proxyPort="443"
           scheme="https"
           secure="true" />
```

### Tomcat을 localhost만 리스닝하도록 변경 (외부 직접 접근 차단):
```xml
<Connector port="8080" protocol="HTTP/1.1"
           address="127.0.0.1"
           connectionTimeout="20000"
           redirectPort="8443"
           proxyName="your-domain.com"
           proxyPort="443"
           scheme="https"
           secure="true" />
```

```bash
sudo systemctl restart tomcat9
```

---

## 작업 5-4: 방화벽 설정

```bash
# UFW 활성화 및 포트 열기
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP (Let's Encrypt + 리다이렉트)
sudo ufw allow 443/tcp   # HTTPS
sudo ufw deny 8080/tcp   # Tomcat 직접 접근 차단
sudo ufw enable
sudo ufw status
```

---

## 도메인이 없는 경우 (IP만 사용)

자체 서명 SSL 인증서 사용:
```bash
sudo mkdir -p /etc/ssl/ai-workflow-lab
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/ai-workflow-lab/server.key \
  -out /etc/ssl/ai-workflow-lab/server.crt \
  -subj "/C=KR/ST=Seoul/L=Seoul/O=AIWorkflowLab/CN=your-server-ip"
```

Nginx 설정에서 인증서 경로 변경:
```nginx
ssl_certificate /etc/ssl/ai-workflow-lab/server.crt;
ssl_certificate_key /etc/ssl/ai-workflow-lab/server.key;
```

---

## 검증
```bash
# Nginx 상태 확인
sudo systemctl status nginx

# SSL 테스트
curl -I https://your-domain.com

# HTTP -> HTTPS 리다이렉트 확인
curl -I http://your-domain.com

# Tomcat 직접 접근 차단 확인
curl http://your-server-ip:8080  # 접근 불가해야 함
```
