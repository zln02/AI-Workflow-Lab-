<%@ page contentType="text/html; charset=UTF-8" buffer="128kb" autoFlush="true" %>
<%@ page isELIgnored="true" %>
<%@ page import="dao.AIToolDAO" %>
<%@ page import="model.AITool" %>
<%@ page import="java.util.List" %>
<%@ include file="/AI/user/_common.jsp" %>

<%
  AIToolDAO toolDao = new AIToolDAO();
  List<AITool> tools = toolDao.findAll();

  String initKeyword    = safeString(request.getParameter("keyword"),    "");
  String initCategory   = safeString(request.getParameter("category"),   "");
  String initDifficulty = safeString(request.getParameter("difficulty"),  "");
  String initCountry    = safeString(request.getParameter("country"),     "");
  String initSort       = safeString(request.getParameter("sort"),        "default");
%>
<%!
  /* ── 카테고리 정규화 (한국어/영어 → 통일된 한국어) ── */
  private String normalizeCategory(String cat) {
    if (cat == null) return "";
    switch (cat.trim()) {
      case "Text Generation":   case "텍스트 생성": return "텍스트 생성";
      case "Code Generation":   case "코드 생성":   return "코드 생성";
      case "Image Generation":  case "이미지 생성":
      case "이미지 편집":                            return "이미지 생성";
      case "Voice Processing":  case "음성 생성":
      case "음성 처리":                              return "음성/오디오";
      case "Video Processing":  case "영상 생성":   return "영상 생성";
      case "Translation":       case "문서 생산성":
      case "마케팅 콘텐츠":                          return "문서/글쓰기";
      case "Data Analysis":     case "데이터 분석": return "데이터 분석";
      case "자동화":                                return "자동화";
      case "디자인":                                return "디자인";
      case "교육":                                  return "교육";
      case "리서치":                                return "리서치";
      case "고객 서비스":                            return "고객 서비스";
      case "음악 생성":                              return "음악 생성";
      case "SEO 최적화":                            return "SEO";
      case "법률":                                  return "법률";
      default:                                       return cat.trim();
    }
  }

  /* ── 카테고리별 그라데이션 컬러바 ── */
  private String catGradient(String cat) {
    if (cat == null) return "linear-gradient(135deg,#64748b,#94a3b8)";
    switch (cat) {
      case "텍스트 생성":   return "linear-gradient(135deg,#3b82f6,#60a5fa)";
      case "코드 생성":     return "linear-gradient(135deg,#22c55e,#4ade80)";
      case "이미지 생성":   return "linear-gradient(135deg,#a855f7,#c084fc)";
      case "음성/오디오":   return "linear-gradient(135deg,#f97316,#fb923c)";
      case "영상 생성":     return "linear-gradient(135deg,#8b5cf6,#a78bfa)";
      case "문서/글쓰기":   return "linear-gradient(135deg,#ec4899,#f472b6)";
      case "데이터 분석":   return "linear-gradient(135deg,#06b6d4,#22d3ee)";
      case "자동화":        return "linear-gradient(135deg,#eab308,#fbbf24)";
      case "디자인":        return "linear-gradient(135deg,#f43f5e,#fb7185)";
      case "음악 생성":     return "linear-gradient(135deg,#10b981,#34d399)";
      case "교육":          return "linear-gradient(135deg,#0ea5e9,#38bdf8)";
      case "리서치":        return "linear-gradient(135deg,#6366f1,#818cf8)";
      case "고객 서비스":   return "linear-gradient(135deg,#14b8a6,#2dd4bf)";
      case "SEO":           return "linear-gradient(135deg,#84cc16,#a3e635)";
      case "법률":          return "linear-gradient(135deg,#78716c,#a8a29e)";
      default:              return "linear-gradient(135deg,#64748b,#94a3b8)";
    }
  }

  /* ── 카테고리별 아이콘 ── */
  private String catIcon(String cat) {
    if (cat == null) return "bi-stars";
    switch (cat) {
      case "텍스트 생성":   return "bi-chat-dots-fill";
      case "코드 생성":     return "bi-code-slash";
      case "이미지 생성":   return "bi-image-fill";
      case "음성/오디오":   return "bi-soundwave";
      case "영상 생성":     return "bi-camera-video-fill";
      case "문서/글쓰기":   return "bi-file-text-fill";
      case "데이터 분석":   return "bi-bar-chart-fill";
      case "자동화":        return "bi-lightning-fill";
      case "디자인":        return "bi-palette-fill";
      case "음악 생성":     return "bi-music-note-beamed";
      case "교육":          return "bi-mortarboard-fill";
      case "리서치":        return "bi-search";
      case "고객 서비스":   return "bi-headset";
      case "SEO":           return "bi-graph-up-arrow";
      case "법률":          return "bi-briefcase-fill";
      default:              return "bi-stars";
    }
  }

  /* ── 난이도 한글 ── */
  private String diffKo(String diff) {
    if ("Beginner".equals(diff))     return "입문";
    if ("Intermediate".equals(diff)) return "중급";
    if ("Advanced".equals(diff))     return "고급";
    return diff != null ? diff : "";
  }

  private String countryLabel(String code) {
    if (code == null) return "";
    switch (code) {
      case "US": return "미국";
      case "KR": return "한국";
      case "CN": return "중국";
      case "FR": return "프랑스";
      case "DE": return "독일";
      case "JP": return "일본";
      case "CA": return "캐나다";
      case "IL": return "이스라엘";
      case "IN": return "인도";
      case "GB": return "영국";
      default: return code;
    }
  }

  /* ── 웹사이트 URL에서 도메인 추출 ── */
  private String extractDomain(String url) {
    if (url == null || url.isEmpty()) return "";
    try {
      url = url.replace("http://","").replace("https://","");
      int slash = url.indexOf('/');
      if (slash > 0) url = url.substring(0, slash);
      return url;
    } catch (Exception e) { return ""; }
  }

  /* ── 로고 URL 결정 (website_url → favicon 서비스) ── */
  private String getToolLogoUrl(String websiteUrl, String providerName) {
    String domain = extractDomain(websiteUrl);
    if (!domain.isEmpty()) {
      return "https://www.google.com/s2/favicons?domain=" + domain + "&sz=64";
    }
    // 제공사 이름으로 fallback
    if (providerName == null) return "";
    String p = providerName.toLowerCase().trim();
    if (p.contains("openai"))     return "https://www.google.com/s2/favicons?domain=openai.com&sz=64";
    if (p.contains("anthropic"))  return "https://www.google.com/s2/favicons?domain=anthropic.com&sz=64";
    if (p.contains("google"))     return "https://www.google.com/s2/favicons?domain=google.com&sz=64";
    if (p.contains("microsoft") || p.contains("github")) return "https://www.google.com/s2/favicons?domain=github.com&sz=64";
    if (p.contains("meta"))       return "https://www.google.com/s2/favicons?domain=meta.com&sz=64";
    if (p.contains("midjourney")) return "https://www.google.com/s2/favicons?domain=midjourney.com&sz=64";
    if (p.contains("stability"))  return "https://www.google.com/s2/favicons?domain=stability.ai&sz=64";
    if (p.contains("mistral"))    return "https://www.google.com/s2/favicons?domain=mistral.ai&sz=64";
    if (p.contains("cohere"))     return "https://www.google.com/s2/favicons?domain=cohere.com&sz=64";
    return "";
  }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>AI 도구 탐색기 — AI Workflow Lab</title>
  <meta name="description" content="카테고리·난이도·키워드로 AI 도구를 검색하고 비교하세요.">
  <link rel="icon" href="data:,">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
  <link rel="stylesheet" href="/AI/assets/css/dark-theme.css">
  <link rel="stylesheet" href="/AI/assets/css/page.css">
  <link rel="stylesheet" href="/AI/assets/css/animations.css">

  <style>
    /* ===== Page Header ===== */
    .nav-header {
      padding: 48px 0 0;
      background: var(--bg-primary, #0a0f1e);
    }
    .nav-header__inner {
      max-width: 1200px;
      margin: 0 auto;
      padding: 0 24px;
    }
    .nav-header__title {
      font-size: clamp(1.75rem, 4vw, 2.5rem);
      font-weight: 700;
      letter-spacing: -0.025em;
      margin: 0 0 8px;
      color: var(--text-primary, #f1f5f9);
    }
    .nav-header__sub {
      font-size: 1rem;
      color: var(--text-secondary, #94a3b8);
      margin: 0 0 28px;
    }

    /* ===== Search Bar ===== */
    .nav-search { position: relative; margin-bottom: 20px; }
    .nav-search__icon {
      position: absolute; left: 16px; top: 50%;
      transform: translateY(-50%);
      color: var(--text-muted, #64748b); font-size: 1.1rem; pointer-events: none;
    }
    .nav-search__input {
      width: 100%; padding: 14px 48px;
      background: rgba(255,255,255,0.05);
      border: 1px solid rgba(255,255,255,0.10);
      border-radius: 12px; color: var(--text-primary, #f1f5f9);
      font-size: 0.9375rem; font-family: inherit; transition: all 0.2s ease;
    }
    .nav-search__input::placeholder { color: var(--text-muted, #64748b); }
    .nav-search__input:focus {
      outline: none; border-color: rgba(59,130,246,0.5);
      background: rgba(255,255,255,0.07);
      box-shadow: 0 0 0 3px rgba(59,130,246,0.12);
    }
    .nav-search__clear {
      position: absolute; right: 14px; top: 50%; transform: translateY(-50%);
      background: none; border: none; color: var(--text-muted, #64748b);
      cursor: pointer; padding: 4px; display: none; font-size: 1rem; line-height: 1;
      transition: color 0.2s;
    }
    .nav-search__clear:hover { color: var(--text-primary, #f1f5f9); }
    .nav-search__input:not(:placeholder-shown) ~ .nav-search__clear { display: block; }

    /* ===== Category Filter Pills ===== */
    .filter-row1 {
      overflow-x: auto; display: flex; gap: 8px;
      padding-bottom: 4px; margin-bottom: 12px; scrollbar-width: none;
    }
    .filter-row1::-webkit-scrollbar { display: none; }
    .cat-btn {
      display: inline-flex; align-items: center; gap: 5px;
      padding: 7px 14px; border-radius: 999px; font-size: 0.8125rem;
      font-weight: 500; white-space: nowrap;
      border: 1px solid rgba(255,255,255,0.12);
      background: rgba(255,255,255,0.05); color: var(--text-secondary, #94a3b8);
      cursor: pointer; transition: all 0.18s ease; flex-shrink: 0;
    }
    .cat-btn:hover {
      background: rgba(255,255,255,0.09); color: var(--text-primary, #f1f5f9);
      border-color: rgba(255,255,255,0.20);
    }
    .cat-btn.active[data-cat=""]           { background: rgba(255,255,255,0.12); color: #f1f5f9; border-color: rgba(255,255,255,0.25); }
    .cat-btn.active[data-cat="텍스트 생성"] { background: rgba(59,130,246,0.18);  color: #60a5fa; border-color: rgba(59,130,246,0.40); }
    .cat-btn.active[data-cat="코드 생성"]   { background: rgba(34,197,94,0.18);   color: #4ade80; border-color: rgba(34,197,94,0.40); }
    .cat-btn.active[data-cat="이미지 생성"] { background: rgba(168,85,247,0.18);  color: #c084fc; border-color: rgba(168,85,247,0.40); }
    .cat-btn.active[data-cat="음성/오디오"] { background: rgba(249,115,22,0.18);  color: #fb923c; border-color: rgba(249,115,22,0.40); }
    .cat-btn.active[data-cat="영상 생성"]   { background: rgba(139,92,246,0.18);  color: #a78bfa; border-color: rgba(139,92,246,0.40); }
    .cat-btn.active[data-cat="문서/글쓰기"] { background: rgba(236,72,153,0.18);  color: #f472b6; border-color: rgba(236,72,153,0.40); }
    .cat-btn.active[data-cat="데이터 분석"] { background: rgba(6,182,212,0.18);   color: #22d3ee; border-color: rgba(6,182,212,0.40); }
    .cat-btn.active[data-cat="자동화"]      { background: rgba(234,179,8,0.18);   color: #fbbf24; border-color: rgba(234,179,8,0.40); }
    .cat-btn.active[data-cat="디자인"]      { background: rgba(244,63,94,0.18);   color: #fb7185; border-color: rgba(244,63,94,0.40); }
    .cat-btn.active[data-cat="음악 생성"]   { background: rgba(16,185,129,0.18);  color: #34d399; border-color: rgba(16,185,129,0.40); }

    /* ===== Filter Row 2: Difficulty + Sort ===== */
    .filter-row2 {
      display: flex; align-items: center; gap: 10px; margin-bottom: 0; flex-wrap: wrap;
    }
    .country-select {
      padding: 6px 12px; border-radius: 8px;
      border: 1px solid rgba(255,255,255,0.10); background: rgba(255,255,255,0.05);
      color: var(--text-secondary, #94a3b8); font-size: 0.8125rem; font-family: inherit;
      cursor: pointer; transition: all 0.18s ease;
    }
    .country-select:focus { outline: none; border-color: rgba(59,130,246,0.4); color: var(--text-primary, #f1f5f9); }
    .country-select option { background: #1e293b; color: #f1f5f9; }
    .diff-group { display: flex; gap: 6px; }
    .diff-btn {
      padding: 6px 14px; border-radius: 8px; font-size: 0.8125rem; font-weight: 500;
      border: 1px solid rgba(255,255,255,0.10); background: rgba(255,255,255,0.04);
      color: var(--text-secondary, #94a3b8); cursor: pointer; transition: all 0.18s ease; white-space: nowrap;
    }
    .diff-btn:hover { background: rgba(255,255,255,0.08); color: var(--text-primary, #f1f5f9); }
    .diff-btn.active { background: rgba(255,255,255,0.10); color: var(--text-primary, #f1f5f9); border-color: rgba(255,255,255,0.22); }
    .diff-btn.active[data-diff="Beginner"]     { background: rgba(34,197,94,0.15);  color: #4ade80; border-color: rgba(34,197,94,0.35); }
    .diff-btn.active[data-diff="Intermediate"] { background: rgba(245,158,11,0.15); color: #fbbf24; border-color: rgba(245,158,11,0.35); }
    .diff-btn.active[data-diff="Advanced"]     { background: rgba(239,68,68,0.15);  color: #f87171; border-color: rgba(239,68,68,0.35); }
    .sort-select {
      margin-left: auto; padding: 6px 12px; border-radius: 8px;
      border: 1px solid rgba(255,255,255,0.10); background: rgba(255,255,255,0.05);
      color: var(--text-secondary, #94a3b8); font-size: 0.8125rem; font-family: inherit;
      cursor: pointer; transition: all 0.18s ease;
    }
    .sort-select:focus { outline: none; border-color: rgba(59,130,246,0.4); color: var(--text-primary, #f1f5f9); }
    .sort-select option { background: #1e293b; color: #f1f5f9; }

    /* ===== Results area ===== */
    .nav-results { max-width: 1200px; margin: 0 auto; padding: 24px 24px 80px; }
    .results-meta {
      display: flex; align-items: center; justify-content: space-between;
      margin-bottom: 20px; font-size: 0.875rem; color: var(--text-muted, #64748b);
    }
    .results-meta strong { color: var(--text-secondary, #94a3b8); }

    /* ===== Tool Grid ===== */
    .tool-grid {
      display: grid; grid-template-columns: repeat(3, 1fr); gap: 18px;
    }

    /* ===== Tool Card ===== */
    .tc {
      background: rgba(255,255,255,0.045); border: 1px solid rgba(255,255,255,0.09);
      border-radius: 14px; overflow: hidden; display: flex; flex-direction: column;
      transition: border-color 0.22s ease, transform 0.22s ease, box-shadow 0.22s ease;
      cursor: pointer;
    }
    .tc:hover {
      border-color: rgba(59,130,246,0.32); transform: translateY(-4px);
      box-shadow: 0 0 28px rgba(59,130,246,0.14), 0 12px 32px rgba(0,0,0,0.28);
    }
    .tc__bar { height: 4px; transition: height 0.22s ease; }
    .tc:hover .tc__bar { height: 8px; }
    .tc__body { padding: 18px 20px 20px; display: flex; flex-direction: column; flex: 1; }
    .tc__top { display: flex; align-items: flex-start; justify-content: space-between; margin-bottom: 14px; }

    /* Logo area */
    .tc__logo-wrap {
      width: 42px; height: 42px; border-radius: 10px;
      background: rgba(255,255,255,0.07); border: 1px solid rgba(255,255,255,0.10);
      display: flex; align-items: center; justify-content: center; overflow: hidden; flex-shrink: 0;
    }
    .tc__logo-img { width: 28px; height: 28px; object-fit: contain; border-radius: 4px; }
    .tc__logo-icon {
      font-size: 1.5rem; line-height: 1;
      background: var(--cat-gradient, linear-gradient(135deg,#64748b,#94a3b8));
      -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text;
    }

    .tc__provider {
      display: flex; align-items: center; gap: 6px; max-width: 55%;
    }
    .tc__pname {
      font-size: 0.72rem; color: var(--text-muted, #64748b);
      white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
    }
    .tc__name { font-size: 1.0625rem; font-weight: 700; color: var(--text-primary, #f1f5f9); margin: 0 0 8px; letter-spacing: -0.01em; }
    .tc__desc {
      font-size: 0.84375rem; color: var(--text-secondary, #94a3b8);
      line-height: 1.65; margin: 0 0 14px;
      display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; flex: 1;
    }
    .tc__meta-grid {
      display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 8px; margin: 0 0 14px;
    }
    .tc__meta {
      padding: 8px 10px; border-radius: 10px; background: rgba(255,255,255,0.04);
      border: 1px solid rgba(255,255,255,0.06);
    }
    .tc__meta-label {
      display: block; font-size: 0.65rem; color: var(--text-muted, #64748b);
      margin-bottom: 3px; text-transform: uppercase; letter-spacing: 0.04em;
    }
    .tc__meta-value { font-size: 0.82rem; color: var(--text-primary, #f1f5f9); font-weight: 600; }
    .tc__meta-value--up { color: #4ade80; }
    .tc__meta-value--down { color: #f87171; }
    .tc__tags { display: flex; gap: 5px; flex-wrap: wrap; margin-bottom: 14px; }
    .tc__tag {
      font-size: 0.6875rem; font-weight: 500; padding: 2px 9px; border-radius: 999px;
      background: rgba(255,255,255,0.06); color: var(--text-muted, #64748b);
      border: 1px solid rgba(255,255,255,0.09);
    }
    .tc__cat-tag {
      font-size: 0.6875rem; font-weight: 600; padding: 2px 9px; border-radius: 999px;
    }
    .tc__footer {
      border-top: 1px solid rgba(255,255,255,0.07); padding-top: 12px;
      display: flex; align-items: center; justify-content: space-between; gap: 8px;
    }
    .tc__badges { display: flex; align-items: center; gap: 6px; flex-wrap: wrap; }
    .tc__badge { font-size: 0.6875rem; font-weight: 600; padding: 2px 8px; border-radius: 5px; }
    .tc__badge--beginner     { background: rgba(34,197,94,0.12);  color: #4ade80; border: 1px solid rgba(34,197,94,0.22); }
    .tc__badge--intermediate { background: rgba(245,158,11,0.12); color: #fbbf24; border: 1px solid rgba(245,158,11,0.22); }
    .tc__badge--advanced     { background: rgba(239,68,68,0.12);  color: #f87171; border: 1px solid rgba(239,68,68,0.22); }
    .tc__badge--free         { background: rgba(34,197,94,0.10);  color: #4ade80; border: 1px solid rgba(34,197,94,0.18); }
    .tc__badge--paid         { background: rgba(255,255,255,0.05); color: var(--text-muted,#64748b); border: 1px solid rgba(255,255,255,0.09); }
    .tc__stars { font-size: 0.75rem; color: #f59e0b; letter-spacing: 1px; }
    .tc__link {
      font-size: 0.8125rem; font-weight: 600; color: #60a5fa; -webkit-text-fill-color: #60a5fa;
      text-decoration: none; white-space: nowrap; display: inline-flex; align-items: center; gap: 3px;
      transition: gap 0.15s ease, color 0.15s ease; flex-shrink: 0;
    }
    .tc__link:hover { gap: 6px; color: #93c5fd; -webkit-text-fill-color: #93c5fd; }

    /* ===== Empty State ===== */
    .empty-state {
      grid-column: 1 / -1; display: flex; flex-direction: column;
      align-items: center; justify-content: center; padding: 80px 24px; text-align: center;
    }
    .empty-state__emoji { font-size: 3.5rem; margin-bottom: 16px; }
    .empty-state__title { font-size: 1.125rem; font-weight: 600; color: var(--text-primary,#f1f5f9); margin: 0 0 8px; }
    .empty-state__sub   { font-size: 0.9rem; color: var(--text-muted,#64748b); margin: 0 0 24px; }
    .reset-btn {
      padding: 9px 20px; border-radius: 9px; background: rgba(59,130,246,0.12);
      color: #60a5fa; -webkit-text-fill-color: #60a5fa; border: 1px solid rgba(59,130,246,0.25);
      font-size: 0.875rem; font-weight: 600; cursor: pointer; transition: all 0.18s ease; text-decoration: none;
    }
    .reset-btn:hover { background: rgba(59,130,246,0.20); color: #93c5fd; -webkit-text-fill-color: #93c5fd; }

    /* ===== Show More Button ===== */
    .show-more-wrap {
      display: flex; justify-content: center; align-items: center;
      margin-top: 32px; gap: 12px; flex-direction: column;
    }
    .show-more-btn {
      display: inline-flex; align-items: center; gap: 8px;
      padding: 12px 32px; border-radius: 12px;
      background: rgba(59,130,246,0.10); color: #60a5fa; -webkit-text-fill-color: #60a5fa;
      border: 1px solid rgba(59,130,246,0.25); font-size: 0.9375rem; font-weight: 600;
      cursor: pointer; transition: all 0.2s ease; font-family: inherit;
    }
    .show-more-btn:hover {
      background: rgba(59,130,246,0.20); border-color: rgba(59,130,246,0.45);
      transform: translateY(-1px); box-shadow: 0 4px 16px rgba(59,130,246,0.15);
    }
    .show-more-btn:disabled { opacity: 0.4; cursor: not-allowed; transform: none; }
    .show-more-counter {
      font-size: 0.8rem; color: var(--text-muted, #64748b);
    }

    /* ===== Divider ===== */
    .nav-divider { max-width: 1200px; margin: 24px auto 0; padding: 0 24px; border-top: 1px solid rgba(255,255,255,0.07); }

    /* ===== Responsive ===== */
    @media (max-width: 1024px) { .tool-grid { grid-template-columns: repeat(2, 1fr); } }
    @media (max-width: 640px) {
      .tool-grid { grid-template-columns: 1fr; }
      .filter-row2 { flex-direction: column; align-items: flex-start; gap: 8px; }
      .sort-select, .country-select { margin-left: 0; width: 100%; }
    }
  </style>
</head>
<body>
  <%@ include file="/AI/partials/header.jsp" %>

  <!-- Page Header + Filters -->
  <div class="nav-header" id="navHeaderBlock">
    <div class="nav-header__inner">
      <h1 class="nav-header__title"><i class="bi bi-compass-fill" style="color:#60a5fa;margin-right:8px;"></i>AI 도구 탐색기</h1>
      <p class="nav-header__sub">원하는 AI 도구를 탐색하고 비교해보세요 — <%= tools.size() %>개 도구 등록됨</p>
      <div style="display:flex;gap:10px;flex-wrap:wrap;margin:0 0 22px;">
        <a href="/AI/user/tools/rankings.jsp" style="display:inline-flex;align-items:center;gap:8px;padding:9px 14px;border-radius:999px;background:rgba(59,130,246,0.16);color:#93c5fd;text-decoration:none;border:1px solid rgba(59,130,246,0.24);font-size:.85rem;font-weight:600;">
          <i class="bi bi-trophy"></i> 랭킹 보기
        </a>
        <a href="/AI/user/news/index.jsp" style="display:inline-flex;align-items:center;gap:8px;padding:9px 14px;border-radius:999px;background:rgba(251,191,36,0.12);color:#fcd34d;text-decoration:none;border:1px solid rgba(251,191,36,0.22);font-size:.85rem;font-weight:600;">
          <i class="bi bi-newspaper"></i> 뉴스 보기
        </a>
      </div>

      <!-- Search -->
      <div class="nav-search">
        <i class="bi bi-search nav-search__icon"></i>
        <input id="searchInput" class="nav-search__input" type="text"
          placeholder="도구명, 기능, 키워드로 검색..." autocomplete="off" spellcheck="false">
        <button class="nav-search__clear" id="searchClear" title="지우기">
          <i class="bi bi-x-lg"></i>
        </button>
      </div>

      <!-- Category filter pills -->
      <div class="filter-row1" role="group" aria-label="카테고리 필터">
        <button class="cat-btn" data-cat="">전체</button>
        <button class="cat-btn" data-cat="텍스트 생성"><i class="bi bi-chat-dots-fill"></i> 텍스트</button>
        <button class="cat-btn" data-cat="코드 생성"><i class="bi bi-code-slash"></i> 코드</button>
        <button class="cat-btn" data-cat="이미지 생성"><i class="bi bi-image-fill"></i> 이미지</button>
        <button class="cat-btn" data-cat="음성/오디오"><i class="bi bi-soundwave"></i> 음성</button>
        <button class="cat-btn" data-cat="영상 생성"><i class="bi bi-camera-video-fill"></i> 영상</button>
        <button class="cat-btn" data-cat="문서/글쓰기"><i class="bi bi-file-text-fill"></i> 문서/글쓰기</button>
        <button class="cat-btn" data-cat="데이터 분석"><i class="bi bi-bar-chart-fill"></i> 데이터분석</button>
        <button class="cat-btn" data-cat="자동화"><i class="bi bi-lightning-fill"></i> 자동화</button>
        <button class="cat-btn" data-cat="디자인"><i class="bi bi-palette-fill"></i> 디자인</button>
        <button class="cat-btn" data-cat="음악 생성"><i class="bi bi-music-note-beamed"></i> 음악</button>
      </div>

      <!-- Row 2: Difficulty + Sort -->
      <div class="filter-row2">
        <div class="diff-group" role="group" aria-label="난이도 필터">
          <button class="diff-btn" data-diff="">전체</button>
          <button class="diff-btn" data-diff="Beginner">입문</button>
          <button class="diff-btn" data-diff="Intermediate">중급</button>
          <button class="diff-btn" data-diff="Advanced">고급</button>
        </div>
        <select class="country-select" id="countrySelect" aria-label="국가 필터">
          <option value="">전체 국가</option>
          <option value="US">미국</option>
          <option value="KR">한국</option>
          <option value="CN">중국</option>
          <option value="FR">프랑스</option>
          <option value="DE">독일</option>
          <option value="JP">일본</option>
          <option value="CA">캐나다</option>
        </select>
        <select class="sort-select" id="sortSelect" aria-label="정렬">
          <option value="default">추천순</option>
          <option value="rating">별점순</option>
          <option value="reviews">사용자순</option>
          <option value="trend">트렌드순</option>
          <option value="rank">랭킹순</option>
          <option value="visits">방문순</option>
          <option value="github">GitHub순</option>
          <option value="newest">최신순</option>
        </select>
      </div>
    </div>
  </div>

  <div class="nav-divider"></div>

  <!-- Results -->
  <div class="nav-results">
    <div class="results-meta">
      <span>총 <strong id="resultsCount"><%= tools.size() %></strong>개 도구</span>
      <span id="visibleInfo" style="font-size:0.8rem;"></span>
    </div>

    <div class="tool-grid" id="toolGrid">

      <% for (AITool tool : tools) {
           String rawCat = safeString(tool.getCategory(), "");
           String cat    = normalizeCategory(rawCat);
           String diff   = safeString(tool.getDifficultyLevel(), "");
           String desc   = safeString(tool.getPurposeSummary(), safeString(tool.getDescription(), ""));
           String logoUrl = getToolLogoUrl(tool.getWebsiteUrl(), tool.getProviderName());
           String gradient = catGradient(cat);
           String icon     = catIcon(cat);

           StringBuilder tagsStr = new StringBuilder();
           if (tool.getTags() != null) {
             for (String t : tool.getTags()) { if (tagsStr.length() > 0) tagsStr.append(","); tagsStr.append(t); }
           }

           Double rating  = tool.getRating();
           int reviews    = tool.getReviewCount() != null ? tool.getReviewCount() : 0;
           String diffClass = "tc__badge--" + diff.toLowerCase();
           Double growth = tool.getGrowthRate();
      %>
      <div class="tc"
           data-name="<%= escapeHtmlAttribute(tool.getToolName()) %>"
           data-desc="<%= escapeHtmlAttribute(desc) %>"
           data-category="<%= escapeHtmlAttribute(cat) %>"
           data-difficulty="<%= escapeHtmlAttribute(diff) %>"
           data-country="<%= escapeHtmlAttribute(safeString(tool.getProviderCountry(), "")) %>"
           data-tags="<%= escapeHtmlAttribute(tagsStr.toString()) %>"
           data-rating="<%= rating != null ? rating : 0 %>"
           data-reviews="<%= reviews %>"
           data-mau="<%= tool.getMonthlyActiveUsers() != null ? tool.getMonthlyActiveUsers() : 0 %>"
           data-trend="<%= tool.getTrendScore() != null ? tool.getTrendScore() : 0 %>"
           data-visits="<%= tool.getMonthlyVisits() != null ? tool.getMonthlyVisits() : 0 %>"
           data-stars="<%= tool.getGithubStars() != null ? tool.getGithubStars() : 0 %>"
           data-rank="<%= tool.getGlobalRank() != null ? tool.getGlobalRank() : 999999 %>"
           data-id="<%= tool.getId() %>"
           onclick="location.href='/AI/user/tools/detail.jsp?id=<%= tool.getId() %>'">

        <div class="tc__bar" style="background:<%= gradient %>;"></div>

        <div class="tc__body">
          <div class="tc__top">
            <!-- Logo -->
            <div class="tc__logo-wrap">
              <% if (!logoUrl.isEmpty()) { %>
              <img src="<%= logoUrl %>"
                   alt="<%= escapeHtml(safeString(tool.getProviderName(), "")) %>"
                   class="tc__logo-img"
                   onerror="this.style.display='none';this.nextElementSibling.style.display='flex';">
              <i class="bi <%= icon %> tc__logo-icon" style="--cat-gradient:<%= gradient %>;display:none;"></i>
              <% } else { %>
              <i class="bi <%= icon %> tc__logo-icon" style="--cat-gradient:<%= gradient %>;"></i>
              <% } %>
            </div>

            <!-- Provider -->
            <div class="tc__provider">
              <span class="tc__pname"><%= escapeHtml(safeString(tool.getProviderName(), "")) %></span>
            </div>
          </div>

          <h3 class="tc__name"><%= escapeHtml(tool.getToolName()) %></h3>
          <p class="tc__desc"><%= escapeHtml(desc) %></p>

          <div class="tc__meta-grid">
            <div class="tc__meta">
              <span class="tc__meta-label">Rank</span>
              <span class="tc__meta-value"><%= escapeHtml(tool.getRankDisplay()) %></span>
            </div>
            <div class="tc__meta">
              <span class="tc__meta-label">Trend</span>
              <span class="tc__meta-value"><%= escapeHtml(tool.getTrendDisplay()) %></span>
            </div>
            <div class="tc__meta">
              <span class="tc__meta-label">Growth</span>
              <span class="tc__meta-value <%= growth != null && growth < 0 ? "tc__meta-value--down" : "tc__meta-value--up" %>"><%= escapeHtml(tool.getGrowthDisplay()) %></span>
            </div>
            <div class="tc__meta">
              <span class="tc__meta-label"><%= escapeHtml(countryLabel(tool.getProviderCountry())) %></span>
              <span class="tc__meta-value"><%= escapeHtml(tool.getFormattedMonthlyVisits()) %>/월</span>
            </div>
          </div>

          <!-- Tags -->
          <% if (tool.getTags() != null && !tool.getTags().isEmpty()) { %>
          <div class="tc__tags">
            <% int tagCount = 0;
               for (String tag : tool.getTags()) { if (tagCount >= 3) break; %>
            <span class="tc__tag"><%= escapeHtml(tag) %></span>
            <%   tagCount++; } %>
          </div>
          <% } else if (!cat.isEmpty()) { %>
          <div class="tc__tags">
            <span class="tc__tag"><%= escapeHtml(cat) %></span>
          </div>
          <% } %>

          <!-- Footer -->
          <div class="tc__footer">
            <div class="tc__badges">
              <% if (!diff.isEmpty()) { %>
              <span class="tc__badge <%= diffClass %>"><%= diffKo(diff) %></span>
              <% } %>
              <% if (tool.isFreeTierAvailable()) { %>
              <span class="tc__badge tc__badge--free">무료</span>
              <% } else { %>
              <span class="tc__badge tc__badge--paid">유료</span>
              <% } %>
              <% if (rating != null && rating > 0) { %>
              <span class="tc__stars"><%= tool.getStarRating() %></span>
              <% } %>
            </div>
            <a href="/AI/user/tools/detail.jsp?id=<%= tool.getId() %>"
               class="tc__link" onclick="event.stopPropagation()">
              자세히 <i class="bi bi-arrow-right"></i>
            </a>
          </div>
        </div>
      </div>
      <% } %>

      <!-- Empty State -->
      <div class="empty-state" id="emptyState" style="display:none;">
        <div class="empty-state__emoji"><i class="bi bi-search" style="font-size:3.5rem;color:#475569;"></i></div>
        <h3 class="empty-state__title">검색 결과가 없습니다</h3>
        <p class="empty-state__sub">다른 키워드나 필터를 시도해보세요.</p>
        <button class="reset-btn" id="resetBtn">필터 초기화</button>
      </div>
    </div><!-- /#toolGrid -->

    <!-- Show More -->
    <div class="show-more-wrap" id="showMoreWrap" style="display:none;">
      <button class="show-more-btn" id="showMoreBtn">
        <i class="bi bi-chevron-down"></i> 더 보기
      </button>
      <span class="show-more-counter" id="showMoreCounter"></span>
    </div>
  </div>

  <%@ include file="/AI/partials/footer.jsp" %>

  <script>
  (function () {
    'use strict';

    var INITIAL_SHOW = 12;  // 처음에 보여줄 카드 수
    var LOAD_MORE    = 12;  // 더 보기 클릭 시 추가로 보여줄 수

    /* ── State ── */
    var state = {
      keyword:    '<%= escapeHtmlAttribute(initKeyword) %>',
      category:   '<%= escapeHtmlAttribute(initCategory) %>',
      difficulty: '<%= escapeHtmlAttribute(initDifficulty) %>',
      country:    '<%= escapeHtmlAttribute(initCountry) %>',
      sort:       '<%= escapeHtmlAttribute(initSort) %>',
      visibleCount: INITIAL_SHOW
    };

    /* ── DOM refs ── */
    var searchInput   = document.getElementById('searchInput');
    var searchClear   = document.getElementById('searchClear');
    var countrySelect = document.getElementById('countrySelect');
    var sortSelect    = document.getElementById('sortSelect');
    var toolGrid      = document.getElementById('toolGrid');
    var resultsCount  = document.getElementById('resultsCount');
    var visibleInfo   = document.getElementById('visibleInfo');
    var emptyState    = document.getElementById('emptyState');
    var showMoreWrap  = document.getElementById('showMoreWrap');
    var showMoreBtn   = document.getElementById('showMoreBtn');
    var showMoreCounter = document.getElementById('showMoreCounter');
    var catBtns       = document.querySelectorAll('.cat-btn');
    var diffBtns      = document.querySelectorAll('.diff-btn');
    var resetBtn      = document.getElementById('resetBtn');

    var allCards = Array.from(document.querySelectorAll('.tc'));

    /* ── Init UI from URL params ── */
    if (state.keyword) searchInput.value = state.keyword;
    if (state.country) countrySelect.value = state.country;
    sortSelect.value = state.sort || 'default';
    catBtns.forEach(function(b) { b.classList.toggle('active', b.dataset.cat === state.category); });
    diffBtns.forEach(function(b) { b.classList.toggle('active', b.dataset.diff === state.difficulty); });

    /* ── Sort cards in DOM ── */
    function sortCards() {
      var s = state.sort;
      var sorted = allCards.slice().sort(function(a, b) {
        if (s === 'rating')  return parseFloat(b.dataset.rating  || 0) - parseFloat(a.dataset.rating  || 0);
        if (s === 'reviews') return parseInt(b.dataset.mau       || 0) - parseInt(a.dataset.mau       || 0);
        if (s === 'trend')   return parseFloat(b.dataset.trend   || 0) - parseFloat(a.dataset.trend   || 0);
        if (s === 'rank')    return parseInt(a.dataset.rank      || 999999) - parseInt(b.dataset.rank || 999999);
        if (s === 'visits')  return parseInt(b.dataset.visits    || 0) - parseInt(a.dataset.visits    || 0);
        if (s === 'github')  return parseInt(b.dataset.stars     || 0) - parseInt(a.dataset.stars     || 0);
        if (s === 'newest')  return parseInt(b.dataset.id        || 0) - parseInt(a.dataset.id        || 0);
        var rankDiff = parseInt(a.dataset.rank || 999999) - parseInt(b.dataset.rank || 999999);
        if (rankDiff !== 0) return rankDiff;
        var trendDiff = parseFloat(b.dataset.trend || 0) - parseFloat(a.dataset.trend || 0);
        if (trendDiff !== 0) return trendDiff;
        var rDiff = parseFloat(b.dataset.rating || 0) - parseFloat(a.dataset.rating || 0);
        return rDiff !== 0 ? rDiff : parseInt(b.dataset.reviews || 0) - parseInt(a.dataset.reviews || 0);
      });
      sorted.forEach(function(card) { toolGrid.insertBefore(card, emptyState); });
    }

    /* ── Filter + Show More logic ── */
    function apply() {
      sortCards();

      var kw   = state.keyword.trim().toLowerCase();
      var cat  = state.category;
      var diff = state.difficulty;
      var country = state.country;

      // 1) Determine which cards match filters
      var matched = [];
      allCards.forEach(function(card) {
        var name  = (card.dataset.name  || '').toLowerCase();
        var desc  = (card.dataset.desc  || '').toLowerCase();
        var tags  = (card.dataset.tags  || '').toLowerCase();
        var cCat  = card.dataset.category  || '';
        var cDiff = card.dataset.difficulty || '';
        var cCountry = card.dataset.country || '';

        var matchKw   = !kw   || name.includes(kw) || desc.includes(kw) || tags.includes(kw);
        var matchCat  = !cat  || cCat === cat;
        var matchDiff = !diff || cDiff === diff;
        var matchCountry = !country || cCountry === country;

        if (matchKw && matchCat && matchDiff && matchCountry) {
          matched.push(card);
        } else {
          card.style.display = 'none';
        }
      });

      // 2) Apply visibleCount limit to matched cards
      var total   = matched.length;
      var showing = Math.min(state.visibleCount, total);

      matched.forEach(function(card, idx) {
        card.style.display = idx < showing ? '' : 'none';
      });

      // 3) Update count display
      resultsCount.textContent = total;
      if (total > 0 && showing < total) {
        visibleInfo.textContent = showing + '개 표시 중';
      } else {
        visibleInfo.textContent = '';
      }

      // 4) Empty state
      emptyState.style.display = total === 0 ? 'flex' : 'none';

      // 5) Show More button
      if (total > showing) {
        showMoreWrap.style.display = 'flex';
        var remaining = total - showing;
        showMoreCounter.textContent = '남은 ' + remaining + '개';
        showMoreBtn.disabled = false;
      } else {
        showMoreWrap.style.display = 'none';
      }
    }

    /* ── Event: Search ── */
    var debounceTimer;
    searchInput.addEventListener('input', function() {
      state.keyword = this.value;
      state.visibleCount = INITIAL_SHOW;
      clearTimeout(debounceTimer);
      debounceTimer = setTimeout(apply, 160);
    });
    searchClear.addEventListener('click', function() {
      searchInput.value = '';
      state.keyword = '';
      state.visibleCount = INITIAL_SHOW;
      apply();
      searchInput.focus();
    });

    /* ── Event: Category ── */
    catBtns.forEach(function(btn) {
      btn.addEventListener('click', function() {
        catBtns.forEach(function(b) { b.classList.remove('active'); });
        btn.classList.add('active');
        state.category = btn.dataset.cat;
        state.visibleCount = INITIAL_SHOW;
        apply();
      });
    });

    /* ── Event: Difficulty ── */
    diffBtns.forEach(function(btn) {
      btn.addEventListener('click', function() {
        diffBtns.forEach(function(b) { b.classList.remove('active'); });
        btn.classList.add('active');
        state.difficulty = btn.dataset.diff;
        state.visibleCount = INITIAL_SHOW;
        apply();
      });
    });

    countrySelect.addEventListener('change', function() {
      state.country = this.value;
      state.visibleCount = INITIAL_SHOW;
      apply();
    });

    /* ── Event: Sort ── */
    sortSelect.addEventListener('change', function() {
      state.sort = this.value;
      apply();
    });

    /* ── Event: Show More ── */
    showMoreBtn.addEventListener('click', function() {
      state.visibleCount += LOAD_MORE;
      apply();
      // Smooth scroll to newly visible cards area
      showMoreWrap.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
    });

    /* ── Event: Reset ── */
    resetBtn.addEventListener('click', function() {
      state.keyword = '';
      state.category = '';
      state.difficulty = '';
      state.country = '';
      state.sort = 'default';
      state.visibleCount = INITIAL_SHOW;

      searchInput.value = '';
      countrySelect.value = '';
      sortSelect.value = 'default';
      catBtns.forEach(function(b) { b.classList.remove('active'); });
      diffBtns.forEach(function(b) { b.classList.remove('active'); });
      document.querySelector('.cat-btn[data-cat=""]').classList.add('active');
      document.querySelector('.diff-btn[data-diff=""]').classList.add('active');

      apply();
    });

    /* ── Initial run ── */
    apply();

  })();
  </script>
</body>
</html>
