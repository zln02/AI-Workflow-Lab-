# Task 07: P3 프론트엔드 UX 개선 + 추가 기능

## 프로젝트 경로
`/var/lib/tomcat9/webapps/ROOT/`

---

## 작업 7-1: 프론트엔드 UX 개선

### 전체 JSP 파일에 공통 적용:

#### 1. 로딩 스피너 컴포넌트 추가
`AI/assets/css/user.css`에 추가:
```css
/* Loading Spinner */
.loading-spinner {
    display: inline-block;
    width: 20px;
    height: 20px;
    border: 2px solid var(--border);
    border-top-color: var(--accent);
    border-radius: 50%;
    animation: spin 0.6s linear infinite;
}
.loading-spinner.lg { width: 40px; height: 40px; border-width: 3px; }
@keyframes spin { to { transform: rotate(360deg); } }

/* Skeleton Loading */
.skeleton {
    background: linear-gradient(90deg, var(--surface) 25%, var(--border) 50%, var(--surface) 75%);
    background-size: 200% 100%;
    animation: shimmer 1.5s infinite;
    border-radius: 8px;
}
@keyframes shimmer { 0% { background-position: 200% 0; } 100% { background-position: -200% 0; } }

/* Page Loading Overlay */
.page-loading {
    position: fixed;
    top: 0; left: 0; right: 0; bottom: 0;
    background: rgba(0,0,0,0.5);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 9999;
    opacity: 0;
    pointer-events: none;
    transition: opacity 0.2s;
}
.page-loading.active { opacity: 1; pointer-events: all; }

/* Toast improvements */
.toast-container {
    position: fixed;
    top: 20px;
    right: 20px;
    z-index: 10000;
    display: flex;
    flex-direction: column;
    gap: 8px;
}

/* Mobile responsive improvements */
@media (max-width: 768px) {
    .user-hero h1 { font-size: 28px; }
    .glass-card { padding: 24px !important; }
    .pricing-grid { grid-template-columns: 1fr !important; }
    .user-cards { grid-template-columns: 1fr !important; }
}

@media (max-width: 480px) {
    main { padding: 40px 16px !important; }
    .user-hero h1 { font-size: 24px; }
}
```

#### 2. 더블 클릭 방지 유틸리티
`AI/assets/js/user.js`에 추가:
```javascript
// 더블 클릭 방지
function preventDoubleClick(button, originalText) {
    button.disabled = true;
    button.innerHTML = '<span class="loading-spinner" style="margin-right:8px;"></span>처리 중...';
    return () => {
        button.disabled = false;
        button.textContent = originalText;
    };
}

// fetch wrapper with error handling
async function apiFetch(url, options = {}) {
    try {
        const response = await fetch(url, {
            headers: { 'Content-Type': 'application/json', ...options.headers },
            ...options
        });
        const data = await response.json();
        if (!response.ok) {
            throw new Error(data.error || data.message || `HTTP ${response.status}`);
        }
        return data;
    } catch (err) {
        console.error('API Error:', err);
        throw err;
    }
}
```

#### 3. 이미지 lazy loading
모든 `<img>` 태그에 `loading="lazy"` 추가:
- `AI/user/home.jsp` - 프로바이더 로고, 도구 카드 이미지
- `AI/user/tools/navigator.jsp` - 도구 목록 이미지
- `AI/user/tools/detail.jsp` - 도구 상세 이미지

#### 4. GSAP 로드 최적화
`AI/user/home.jsp`에서만 GSAP 사용. 다른 페이지에서는 GSAP 스크립트 제거:
```
확인 대상: tools/navigator.jsp, tools/detail.jsp, lab/index.jsp, lab/detail.jsp
```

#### 5. CSS/JS 캐시 버스팅
모든 CSS/JS 참조에 버전 파라미터 추가:
```html
<link rel="stylesheet" href="/AI/assets/css/user.css?v=20260308">
<script src="/AI/assets/js/user.js?v=20260308"></script>
```

---

## 작업 7-2: 이메일 인증 구현

### 새 파일: `WEB-INF/src/service/EmailService.java`

```java
package service;

import java.util.Properties;
import javax.mail.*;
import javax.mail.internet.*;

public class EmailService {
    private final String smtpHost;
    private final String smtpPort;
    private final String smtpUser;
    private final String smtpPassword;
    private final String fromAddress;

    public EmailService() {
        this.smtpHost = System.getenv("SMTP_HOST");
        this.smtpPort = System.getenv("SMTP_PORT") != null ? System.getenv("SMTP_PORT") : "587";
        this.smtpUser = System.getenv("SMTP_USER");
        this.smtpPassword = System.getenv("SMTP_PASSWORD");
        this.fromAddress = System.getenv("SMTP_FROM") != null ? System.getenv("SMTP_FROM") : "noreply@aiworkflowlab.com";
    }

    public void sendVerificationEmail(String toEmail, String userName, String token) throws MessagingException {
        String subject = "[AI Workflow Lab] 이메일 인증";
        String verifyUrl = System.getenv("APP_BASE_URL") + "/AI/api/verify-email?token=" + token;

        String body = "<div style='max-width:600px;margin:0 auto;font-family:sans-serif;'>"
            + "<h2>안녕하세요, " + userName + "님!</h2>"
            + "<p>AI Workflow Lab 회원가입을 환영합니다.</p>"
            + "<p>아래 버튼을 클릭하여 이메일 인증을 완료해주세요.</p>"
            + "<a href='" + verifyUrl + "' style='display:inline-block;padding:12px 32px;"
            + "background:#6366f1;color:white;text-decoration:none;border-radius:8px;"
            + "font-weight:600;margin:20px 0;'>이메일 인증하기</a>"
            + "<p style='color:#666;font-size:12px;'>이 링크는 24시간 동안 유효합니다.</p>"
            + "</div>";

        sendHtml(toEmail, subject, body);
    }

    public void sendPasswordResetEmail(String toEmail, String token) throws MessagingException {
        String subject = "[AI Workflow Lab] 비밀번호 재설정";
        String resetUrl = System.getenv("APP_BASE_URL") + "/AI/user/reset-password.jsp?token=" + token;

        String body = "<div style='max-width:600px;margin:0 auto;font-family:sans-serif;'>"
            + "<h2>비밀번호 재설정</h2>"
            + "<p>비밀번호 재설정을 요청하셨습니다.</p>"
            + "<a href='" + resetUrl + "' style='display:inline-block;padding:12px 32px;"
            + "background:#6366f1;color:white;text-decoration:none;border-radius:8px;"
            + "font-weight:600;margin:20px 0;'>비밀번호 재설정</a>"
            + "<p style='color:#666;font-size:12px;'>이 링크는 1시간 동안 유효합니다.</p>"
            + "<p style='color:#999;font-size:11px;'>요청하지 않으셨다면 이 이메일을 무시하세요.</p>"
            + "</div>";

        sendHtml(toEmail, subject, body);
    }

    private void sendHtml(String to, String subject, String htmlBody) throws MessagingException {
        if (smtpHost == null || smtpUser == null) {
            System.err.println("[WARNING] SMTP 설정 없음. 이메일 미발송: " + to);
            return;
        }

        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", smtpHost);
        props.put("mail.smtp.port", smtpPort);

        Session session = Session.getInstance(props, new Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(smtpUser, smtpPassword);
            }
        });

        Message message = new MimeMessage(session);
        message.setFrom(new InternetAddress(fromAddress));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
        message.setSubject(subject);
        message.setContent(htmlBody, "text/html; charset=UTF-8");

        Transport.send(message);
    }
}
```

### DB 스키마 추가 (마이그레이션):
```sql
CREATE TABLE IF NOT EXISTS email_verification_tokens (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    token VARCHAR(255) NOT NULL UNIQUE,
    expires_at TIMESTAMP NOT NULL,
    used BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_token (token),
    INDEX idx_expires (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS password_reset_tokens (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    token VARCHAR(255) NOT NULL UNIQUE,
    expires_at TIMESTAMP NOT NULL,
    used BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_token (token),
    INDEX idx_expires (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### 이메일 인증 Servlet:
```java
// servlet/EmailVerificationServlet.java
@WebServlet("/AI/api/verify-email")
// GET: 토큰 검증 -> users.email_verified = true 업데이트
// 성공 시 login.jsp로 리다이렉트 + 성공 메시지
```

### 비밀번호 찾기 페이지:
```
AI/user/forgot-password.jsp - 이메일 입력 폼
AI/user/reset-password.jsp  - 새 비밀번호 입력 폼 (토큰 필요)
```

### Maven dependency 추가 (pom.xml):
```xml
<dependency>
    <groupId>com.sun.mail</groupId>
    <artifactId>javax.mail</artifactId>
    <version>1.6.2</version>
</dependency>
```

### 환경변수:
```bash
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-app-password
SMTP_FROM=noreply@aiworkflowlab.com
APP_BASE_URL=https://your-domain.com
```

---

## 작업 7-3: 테스트 코드 작성

### `src/test/java/util/PasswordUtilTest.java`
```java
package util;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class PasswordUtilTest {
    @Test
    void hashAndVerify() {
        String password = "TestPassword123!";
        String hash = PasswordUtil.hashPassword(password);
        assertNotNull(hash);
        assertTrue(PasswordUtil.verifyPassword(password, hash));
        assertFalse(PasswordUtil.verifyPassword("wrong", hash));
    }

    @Test
    void passwordStrength() {
        assertTrue(PasswordUtil.checkPasswordStrength("a") < 30);
        assertTrue(PasswordUtil.checkPasswordStrength("Abcd1234!") >= 60);
    }

    @Test
    void generateSecurePassword() {
        String pwd = PasswordUtil.generateSecurePassword(16);
        assertEquals(16, pwd.length());
    }
}
```

### `src/test/java/util/EscapeUtilTest.java`
```java
package util;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class EscapeUtilTest {
    @Test
    void escapeHtml() {
        assertEquals("&lt;script&gt;alert(1)&lt;&#x2F;script&gt;",
            EscapeUtil.escapeHtml("<script>alert(1)</script>"));
        assertEquals("&amp;", EscapeUtil.escapeHtml("&"));
        assertEquals("&quot;", EscapeUtil.escapeHtml("\""));
        assertEquals("", EscapeUtil.escapeHtml(null));
    }

    @Test
    void escapeJavaScript() {
        assertEquals("test\\nline", EscapeUtil.escapeJavaScript("test\nline"));
        assertEquals("test\\\"quote", EscapeUtil.escapeJavaScript("test\"quote"));
    }

    @Test
    void escapeSqlLike() {
        assertEquals("test\\%pattern", EscapeUtil.escapeSqlLike("test%pattern"));
        assertEquals("test\\_pattern", EscapeUtil.escapeSqlLike("test_pattern"));
    }
}
```

### `src/test/java/util/CSRFUtilTest.java`
```java
package util;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class CSRFUtilTest {
    @Test
    void generateToken() {
        String token1 = CSRFUtil.generateToken();
        String token2 = CSRFUtil.generateToken();
        assertNotNull(token1);
        assertNotNull(token2);
        assertNotEquals(token1, token2); // 매번 고유해야 함
        assertTrue(token1.length() > 20);
    }
}
```

---

## 작업 우선순위 (이 파일 내)
1. 프론트엔드 UX (CSS/JS 개선) - 즉시 적용 가능
2. 테스트 코드 - Maven 전환 후 적용
3. 이메일 인증 - SMTP 설정 필요
