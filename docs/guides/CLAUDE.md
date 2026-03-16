# AI Workflow Lab — Claude Code Guide

## Commands

### Compile Java sources
```bash
cd /var/lib/tomcat9/webapps/ROOT
javac -cp "WEB-INF/lib/*:/usr/share/tomcat9/lib/*" \
  -d WEB-INF/classes \
  $(find WEB-INF/src -name "*.java")
```

### Deploy (restart Tomcat)
```bash
sudo systemctl restart tomcat9
```

### View logs
```bash
sudo tail -f /var/log/tomcat9/catalina.out
```

### Database access (CLI)
```bash
# Use debian-sys-maint — aiworkflow user has socket auth issues
MYSQL_PWD=$(sudo awk -F= '/password/{print $2; exit}' /etc/mysql/debian.cnf | tr -d ' ') \
  mysql -u debian-sys-maint -S /var/run/mysqld/mysqld.sock ai_navigator
```

### After any Java change
Recompile + restart Tomcat (no hot-reload):
```bash
javac -cp "WEB-INF/lib/*:/usr/share/tomcat9/lib/*" -d WEB-INF/classes \
  $(find WEB-INF/src -name "*.java") \
  && sudo systemctl restart tomcat9
```

---

## Architecture

**Stack:** Java 11, JSP, Servlet 4, Tomcat 9, MySQL 8, Gson — no Maven/Gradle
**Pattern:** MVC + DAO, session-based auth (user/admin roles)
**No tests, no linter.**

### Directory layout
```
ROOT/
  AI/
    user/          # User-facing JSP pages
    admin/         # Admin JSP pages
    partials/      # header.jsp, footer.jsp (included by all pages)
    assets/
      css/         # Per-page CSS files
      js/          # Per-page JS files
      img/
        providers/ # Local SVG fallback logos
      video/
  WEB-INF/
    src/
      constants/   # Shared constants
      dao/         # Database access objects (AIToolDAO, UserDAO, …)
      db/          # Shared connection factory
      dto/         # Data transfer objects
      filter/      # AuthFilter, AdminFilter
      listener/    # ServletContext lifecycle hooks
      model/       # POJOs (AITool, User, …)
      servlet/     # HttpServlet subclasses — API endpoints at /api/*
      util/        # Helpers (CSRFUtil, …)
    classes/       # Compiled output only
    lib/           # JAR dependencies (mysql-connector, gson, …)
```

---

## Key Patterns

### DAO
Use try-with-resources + PreparedStatement via `DBConnect.getConnection()`:
```java
try (Connection conn = DBConnect.getConnection();
     PreparedStatement ps = conn.prepareStatement("SELECT ...")) {
    ps.setInt(1, id);
    try (ResultSet rs = ps.executeQuery()) { ... }
}
```

JSON columns (`tags`, `features`, `use_cases`) store JSON arrays as TEXT; deserialize with Gson:
```java
Type listType = new TypeToken<List<String>>(){}.getType();
List<String> tags = new Gson().fromJson(rs.getString("tags"), listType);
```

### JSP includes
Every JSP must include `_common.jsp` first:
```jsp
<%@ include file="/AI/_common.jsp" %>
```
Provides: `escapeHtml()`, `escapeHtmlAttribute()`, `CSRFUtil`, `getProviderLogo()`

### Auth / Session
- User session key: `"user"` → `User` object
- Admin session key: `"admin"` → `Admin` object
- Enforced by `AuthFilter` (user pages) and `AdminFilter` (admin pages)
- When adding new paths, update filter mappings in `web.xml`

### XSS / CSRF
- Always escape output: `<%= escapeHtml(value) %>` / `escapeHtmlAttribute()`
- Include CSRF token in all state-changing forms via `CSRFUtil.getToken(session)`
- Validate token server-side on every POST

### REST API servlets
- Mounted at `/api/*` in `web.xml`; return `application/json`
- Parse body: `new Gson().fromJson(request.getReader(), MyDto.class)`
- Respond: `response.getWriter().write(new Gson().toJson(result))`
- Always validate session before processing

---

## Database Conventions

**Env vars** (set in Tomcat context — not accessible directly from CLI):
| Variable     | Value                                          |
|--------------|------------------------------------------------|
| `DB_URL`     | `jdbc:mysql://127.0.0.1:3306/ai_navigator`     |
| `DB_USER`    | `aiworkflow`                                   |
| `DB_PASSWORD`| Tomcat 환경 변수에 설정된 실제 값 사용         |

**Category names** in `ai_tools.category` **must be Korean** — English categories break the UI filter:
- 텍스트 생성, 코드 생성, 이미지 생성, 음성/오디오, 영상 생성
- 문서/글쓰기, 데이터 분석, 자동화, 디자인, 음악 생성
- 리서치, 교육, 고객 서비스, 법률

**Logo URLs:** resolved via Google Favicon API using the tool's `website_url` field:
```
https://www.google.com/s2/favicons?domain={domain}&sz=64
```
Local SVG fallbacks in `/AI/assets/img/providers/`.

---

## Assets & Styling

- Dark theme throughout; default body background near-black (`#0a0a0a`)
- Per-page CSS in `/AI/assets/css/` (e.g., `navigator.css`, `home.css`)
- JS in `/AI/assets/js/`; plain ES6 — no build step
- Edit `AI/partials/header.jsp` / `footer.jsp` for site-wide layout changes
