<%@ page contentType="text/html; charset=UTF-8" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>접근 권한 없음 - AI Workflow Lab</title>
    <link rel="icon" href="data:,">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link rel="stylesheet" href="/AI/assets/css/dark-theme.css">
    <link rel="stylesheet" href="/AI/assets/css/user.css">
</head>
<body>
    <main style="width: min(600px, 100%); margin: 0 auto; padding: 120px 22px; text-align: center;">
        <div class="glass-card" style="padding: 60px 48px;">
            <i class="bi bi-shield-lock" style="font-size: 64px; color: #ff9500; display: block; margin-bottom: 24px;"></i>
            <h1 style="font-size: 48px; font-weight: 700; margin-bottom: 12px;">403</h1>
            <h2 style="font-size: 24px; margin-bottom: 16px; color: var(--text);">접근 권한이 없습니다</h2>
            <p style="color: var(--text-secondary); margin-bottom: 32px; line-height: 1.6;">
                이 페이지에 접근할 수 있는 권한이 없습니다.<br>
                로그인하거나 관리자에게 문의해주세요.
            </p>
            <div style="display: flex; gap: 12px; justify-content: center; flex-wrap: wrap;">
                <a href="/AI/user/login.jsp" class="btn primary">
                    <i class="bi bi-box-arrow-in-right me-1"></i>로그인
                </a>
                <a href="/AI/user/home.jsp" class="btn" style="border: 1px solid var(--border); color: var(--text);">
                    <i class="bi bi-house me-1"></i>홈으로
                </a>
            </div>
        </div>
    </main>
</body>
</html>
