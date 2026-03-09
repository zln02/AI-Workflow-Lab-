<%@ page contentType="text/html; charset=UTF-8" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>페이지를 찾을 수 없습니다 - AI Workflow Lab</title>
    <link rel="icon" href="data:,">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link rel="stylesheet" href="/AI/assets/css/dark-theme.css">
    <link rel="stylesheet" href="/AI/assets/css/user.css">
</head>
<body>
    <main style="width: min(600px, 100%); margin: 0 auto; padding: 120px 22px; text-align: center;">
        <div class="glass-card" style="padding: 60px 48px;">
            <i class="bi bi-emoji-frown" style="font-size: 64px; color: var(--accent); display: block; margin-bottom: 24px;"></i>
            <h1 style="font-size: 48px; font-weight: 700; margin-bottom: 12px;">404</h1>
            <h2 style="font-size: 24px; margin-bottom: 16px; color: var(--text);">페이지를 찾을 수 없습니다</h2>
            <p style="color: var(--text-secondary); margin-bottom: 32px; line-height: 1.6;">
                요청하신 페이지가 존재하지 않거나 이동되었습니다.<br>
                URL을 확인하고 다시 시도해주세요.
            </p>
            <div style="display: flex; gap: 12px; justify-content: center; flex-wrap: wrap;">
                <a href="/AI/user/home.jsp" class="btn primary">
                    <i class="bi bi-house me-1"></i>홈으로 이동
                </a>
                <a href="javascript:history.back()" class="btn" style="border: 1px solid var(--border); color: var(--text);">
                    <i class="bi bi-arrow-left me-1"></i>이전 페이지
                </a>
            </div>
        </div>
    </main>
</body>
</html>
