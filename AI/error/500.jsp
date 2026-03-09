<%@ page contentType="text/html; charset=UTF-8" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>서버 오류 - AI Workflow Lab</title>
    <link rel="icon" href="data:,">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link rel="stylesheet" href="/AI/assets/css/dark-theme.css">
    <link rel="stylesheet" href="/AI/assets/css/user.css">
</head>
<body>
    <main style="width: min(600px, 100%); margin: 0 auto; padding: 120px 22px; text-align: center;">
        <div class="glass-card" style="padding: 60px 48px;">
            <i class="bi bi-exclamation-triangle" style="font-size: 64px; color: #ff3b30; display: block; margin-bottom: 24px;"></i>
            <h1 style="font-size: 48px; font-weight: 700; margin-bottom: 12px;">500</h1>
            <h2 style="font-size: 24px; margin-bottom: 16px; color: var(--text);">서버 오류가 발생했습니다</h2>
            <p style="color: var(--text-secondary); margin-bottom: 32px; line-height: 1.6;">
                일시적인 서버 문제가 발생했습니다.<br>
                잠시 후 다시 시도해주세요.
            </p>
            <a href="/AI/user/home.jsp" class="btn primary">
                <i class="bi bi-house me-1"></i>홈으로 이동
            </a>
        </div>
    </main>
</body>
</html>
