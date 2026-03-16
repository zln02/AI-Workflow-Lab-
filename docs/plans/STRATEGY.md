# AI Workflow Lab — Grand Strategy & Implementation Blueprint

> Codex Implementation Guide: 이 문서는 AI Workflow Lab을 세계적 수준의 AI 도구 탐색·실습·비교 플랫폼으로
> 고도화하기 위한 전체 전략과 구현 명세입니다. 각 Phase를 순서대로 구현하세요.

---

## 현재 상태 요약

| 영역 | 현재 | 목표 |
|------|------|------|
| AI 도구 | 66개, 14개 카테고리 | 500+ 도구, 30+ 카테고리, 국가/회사별 분류 |
| AI 모델 | 0개 (빈 테이블) | 200+ 모델, 벤치마크 비교, 실시간 순위 |
| 실습 랩 | 기본 템플릿만 | 실제 AI API 연동 실습, 토큰 기반 실행 |
| 결제 | 폼만 존재 (PG 없음) | PortOne(아임포트) 연동, 구독·크레딧 과금 |
| 인증 | 이메일+OAuth 기본 | 2FA, API 키 관리, 역할 기반 접근 |
| 데이터 시각화 | 없음 | Chart.js 기반 모델 비교, 트렌드, 순위 |
| 프론트엔드 | 기본 다크 테마 JSP | 반응형, 인터랙티브, 실시간 업데이트 |

---

## 기술 스택 (변경 없이 기존 스택 활용)

- **Backend**: Java 11 + JSP + Servlet 4.0 + Tomcat 9
- **DB**: MySQL 8 + HikariCP
- **Frontend**: Vanilla ES6 + Bootstrap 5 + Chart.js + GSAP
- **JSON**: Gson
- **빌드**: javac (기존 방식 유지)
- **새로 추가**: Chart.js (CDN), Marked.js (마크다운), Prism.js (코드 하이라이트)

---

## 진행 현황 체크리스트

- [x] Phase 1.1 DB 스키마 확장
- [x] Phase 1.2 시드 데이터 기초 반영
  - providers, countries, ai_tools, ai_tool_news starter seed 반영 완료
  - 500+ 전체 시드와 30+ 뉴스 전체 확장은 미완료
- [x] Phase 1.3 새로운 DAO 파일
- [x] Phase 1.4 새로운 Model 파일
- [x] Phase 1.5 API 서블릿 확장 완료
  - `AIToolServlet.java` 확장은 완료
  - `NewsServlet.java`, `RankingServlet.java` 신규 생성 완료
- [x] Phase 2.1 Navigator 페이지 개편
- [x] Phase 2.2 도구 상세 페이지 개편
- [x] Phase 2.3 순위 페이지 신규 추가
- [x] Phase 2.4 비교 페이지 신규 추가
- [x] Phase 2.5 뉴스/인사이트 페이지 신규 추가
- [x] Phase 2.6 데이터 시각화
- [x] Phase 3 실습 랩 고도화
  - `LabSession.java`, `LabSessionDAO.java`, `LabSessionServlet.java` 추가 완료
  - `playground.jsp` 추가 및 `session.jsp` 실행 이력 저장 연동 완료
- [x] Phase 4 결제 시스템 고도화
  - `Plan`/`Order`/`Subscription`/`CreditPackage` 모델 및 DAO 추가 완료
  - `PaymentServlet.java`, `SubscriptionServlet.java`, `payment.js` 추가 완료
- [x] Phase 5 인증·마이페이지 고도화
  - `EncryptionUtil.java`, `UserAPIKeyServlet.java` 추가 완료
  - `mypage.jsp`에 크레딧/실습 기록/API 키 탭 추가 완료
- [x] Phase 6.1 관리자 대시보드 개편
- [x] Phase 6.2 관리자 도구 관리 고도화 일부
  - `admin/tools/index.jsp` 확장 완료
  - CSV/JSON 업로드, 빠른 랭크 수정 추가 완료
  - 뉴스 등록/삭제/최근 목록, 벤치마크 등록/삭제/최근 목록 추가 완료
  - `admin/analytics/index.jsp` 및 세부 analytics(`users/credits/revenue/tools`) 신설 완료
- [x] Phase 7.1 홈페이지 개편 일부
  - 트렌딩 도구, 랭킹 스냅샷, 최신 뉴스 섹션 연결 완료
  - 인기 실습, 국가별 AI 생태계, 요금제 미리보기 연결 완료
- [x] Phase 8 SEO, 성능, 보안

---

# PHASE 1: 데이터 기반 — AI 도구·모델 대규모 확장

## 1.1 DB 스키마 확장

### providers 테이블 고도화
```sql
ALTER TABLE providers
  ADD COLUMN logo_url VARCHAR(500) DEFAULT NULL,
  ADD COLUMN description TEXT DEFAULT NULL,
  ADD COLUMN headquarters_country VARCHAR(100) DEFAULT NULL,
  ADD COLUMN founded_year INT DEFAULT NULL,
  ADD COLUMN employee_count VARCHAR(50) DEFAULT NULL,
  ADD COLUMN funding_total VARCHAR(100) DEFAULT NULL,
  ADD COLUMN is_public TINYINT(1) DEFAULT 0,
  ADD COLUMN stock_ticker VARCHAR(20) DEFAULT NULL,
  ADD COLUMN specialization VARCHAR(255) DEFAULT NULL,
  ADD COLUMN api_docs_url VARCHAR(500) DEFAULT NULL,
  ADD COLUMN status ENUM('active','acquired','shutdown') DEFAULT 'active',
  ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;
```

### ai_tools 테이블 확장
```sql
ALTER TABLE ai_tools
  ADD COLUMN provider_country VARCHAR(100) DEFAULT NULL AFTER provider_name,
  ADD COLUMN monthly_active_users BIGINT DEFAULT NULL,
  ADD COLUMN launch_date DATE DEFAULT NULL,
  ADD COLUMN last_major_update DATE DEFAULT NULL,
  ADD COLUMN global_rank INT DEFAULT NULL,
  ADD COLUMN category_rank INT DEFAULT NULL,
  ADD COLUMN trend_score DECIMAL(5,2) DEFAULT 0.00 COMMENT '인기도 점수 0-100',
  ADD COLUMN growth_rate DECIMAL(5,2) DEFAULT 0.00 COMMENT '전월 대비 성장률 %',
  ADD COLUMN pros JSON DEFAULT NULL COMMENT '장점 리스트',
  ADD COLUMN cons JSON DEFAULT NULL COMMENT '단점 리스트',
  ADD COLUMN alternatives JSON DEFAULT NULL COMMENT '대안 도구 ID 리스트',
  ADD COLUMN integrations JSON DEFAULT NULL COMMENT '연동 가능 서비스',
  ADD COLUMN supported_platforms JSON DEFAULT NULL COMMENT '["web","ios","android","desktop","api"]',
  ADD COLUMN data_privacy_score INT DEFAULT NULL COMMENT '1-10 점수',
  ADD COLUMN enterprise_ready TINYINT(1) DEFAULT 0,
  ADD COLUMN open_source TINYINT(1) DEFAULT 0,
  ADD COLUMN github_url VARCHAR(500) DEFAULT NULL,
  ADD COLUMN github_stars INT DEFAULT NULL,
  ADD COLUMN monthly_visits BIGINT DEFAULT NULL COMMENT 'SimilarWeb 기준 추정치',
  ADD INDEX idx_tools_country (provider_country),
  ADD INDEX idx_tools_global_rank (global_rank),
  ADD INDEX idx_tools_trend (trend_score DESC),
  ADD INDEX idx_tools_mau (monthly_active_users DESC);
```

### ai_tool_news 테이블 (새로 생성)
```sql
CREATE TABLE ai_tool_news (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tool_id INT DEFAULT NULL,
  title VARCHAR(500) NOT NULL,
  summary TEXT NOT NULL,
  content LONGTEXT DEFAULT NULL,
  source_url VARCHAR(500) DEFAULT NULL,
  source_name VARCHAR(200) DEFAULT NULL,
  image_url VARCHAR(500) DEFAULT NULL,
  news_type ENUM('update','launch','funding','comparison','tutorial','industry') DEFAULT 'update',
  tags JSON DEFAULT NULL,
  view_count INT DEFAULT 0,
  published_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  is_featured TINYINT(1) DEFAULT 0,
  is_active TINYINT(1) DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (tool_id) REFERENCES ai_tools(id) ON DELETE SET NULL,
  INDEX idx_news_type (news_type),
  INDEX idx_news_featured (is_featured, published_at DESC),
  INDEX idx_news_published (published_at DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### ai_tool_benchmarks 테이블 (새로 생성)
```sql
CREATE TABLE ai_tool_benchmarks (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tool_id INT NOT NULL,
  benchmark_name VARCHAR(200) NOT NULL COMMENT 'MMLU, HumanEval, HellaSwag 등',
  score DECIMAL(8,3) NOT NULL,
  max_score DECIMAL(8,3) DEFAULT NULL,
  test_date DATE DEFAULT NULL,
  source VARCHAR(200) DEFAULT NULL,
  notes TEXT DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (tool_id) REFERENCES ai_tools(id) ON DELETE CASCADE,
  INDEX idx_bench_tool (tool_id),
  INDEX idx_bench_name (benchmark_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### ai_model_comparisons 테이블 (새로 생성)
```sql
CREATE TABLE ai_model_comparisons (
  id INT AUTO_INCREMENT PRIMARY KEY,
  model_a_id INT NOT NULL,
  model_b_id INT NOT NULL,
  comparison_data JSON NOT NULL COMMENT '{"speed":{"a":95,"b":87},"accuracy":{"a":92,"b":96},...}',
  winner_id INT DEFAULT NULL,
  summary TEXT DEFAULT NULL,
  view_count INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_comp_models (model_a_id, model_b_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### countries 테이블 (새로 생성)
```sql
CREATE TABLE countries (
  code VARCHAR(10) PRIMARY KEY COMMENT 'ISO 3166-1 alpha-2',
  name_ko VARCHAR(100) NOT NULL,
  name_en VARCHAR(100) NOT NULL,
  flag_emoji VARCHAR(10) DEFAULT NULL,
  region VARCHAR(50) DEFAULT NULL COMMENT 'Asia, North America, Europe 등',
  tool_count INT DEFAULT 0,
  display_order INT DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

## 1.2 시드 데이터 — 주요 AI 회사 및 도구

### providers 시드 데이터
Codex가 INSERT 문으로 다음 회사들을 등록:

**미국 (US)**:
OpenAI, Anthropic, Google DeepMind, Meta AI, Microsoft, Amazon (AWS Bedrock), Apple, xAI (Grok), Stability AI, Midjourney, Runway, ElevenLabs, Jasper, Copy.ai, Notion AI, Perplexity, Cohere, Hugging Face, Scale AI, Databricks (Mosaic), Together AI, Groq, Inflection AI, Character.ai, Pika Labs, Luma AI, Suno, Udio, Ideogram, Replit, Cursor, GitHub Copilot, Adobe Firefly, Canva AI, Grammarly, Descript, Synthesia, HeyGen, D-ID, Glean, Harvey AI, Casetext

**중국 (CN)**:
Baidu (ERNIE/Wenxin), Alibaba (Tongyi Qianwen), Tencent (Hunyuan), ByteDance (Doubao), Zhipu AI (ChatGLM), Moonshot AI (Kimi), Minimax, 01.AI (Yi), Baichuan, SenseTime, iFLYTEK, DeepSeek

**한국 (KR)**:
Naver (HyperCLOVA X), Kakao Brain, LG AI Research (EXAONE), SK Telecom (A.), Upstage (Solar), Twelve Labs, Riiid, Lunit, Vuno

**유럽**:
Mistral AI (FR), Aleph Alpha (DE), DeepL (DE), Helsing (DE/UK), Poolside AI (FR), Photoroom (FR)

**일본 (JP)**:
Preferred Networks, ABEJA, Sakana AI, rinna

**캐나다 (CA)**:
Cohere, Lightricks, Ada Support

**이스라엘 (IL)**:
AI21 Labs, Habana Labs (Intel)

**인도 (IN)**:
Krutrim (Ola), Sarvam AI

### ai_tools 시드 데이터 (500+)

**카테고리 재정의** — 30개 카테고리:
```
텍스트 생성, 코드 생성, 이미지 생성, 영상 생성, 음성/오디오, 음악 생성,
문서/글쓰기, 데이터 분석, 자동화, 디자인, 리서치, 교육,
고객 서비스, 법률, 의료/헬스케어, 금융/핀테크,
마케팅, SEO, 번역/로컬라이제이션, 프레젠테이션,
3D/공간컴퓨팅, 로보틱스, 사이버보안, HR/채용,
게임개발, 과학/연구, 농업/환경, 부동산, 이커머스, 종합 AI 어시스턴트
```

**도구 목록 (카테고리별 주요 도구들):**

종합 AI 어시스턴트: ChatGPT, Claude, Gemini, Copilot, Perplexity, Grok, Pi, Poe, HyperCLOVA X, ERNIE Bot, Tongyi Qianwen, Kimi, DeepSeek Chat, Le Chat (Mistral)

코드 생성: GitHub Copilot, Cursor, Replit AI, Tabnine, Codeium, Amazon CodeWhisperer, Sourcegraph Cody, Devin, Sweep, Continue.dev

이미지 생성: Midjourney, DALL-E 3, Stable Diffusion, Adobe Firefly, Ideogram, Leonardo.ai, Playground AI, Flux, Bing Image Creator, Canva AI Art, Krea AI, Craiyon

영상 생성: Runway Gen-3, Sora, Pika, Luma Dream Machine, Kling, Synthesia, HeyGen, D-ID, InVideo AI, Veo (Google), Minimax Video

음성/오디오: ElevenLabs, Whisper (OpenAI), CLOVA Voice, Play.ht, Resemble.ai, Descript, Murf.ai, Speechify, Assembly AI, Deepgram

음악 생성: Suno, Udio, AIVA, Soundraw, Boomy, Amper Music, Loudly

문서/글쓰기: Jasper, Copy.ai, Notion AI, Grammarly, Writesonic, Rytr, Sudowrite, Lex, Wordtune, QuillBot

데이터 분석: Julius AI, Hex, Mode, Obviously AI, Polymer, Databricks AI, Akkio, MonkeyLearn

리서치: Elicit, Consensus, Semantic Scholar, Scite, Connected Papers, Iris.ai, Scholarcy

번역/로컬라이제이션: DeepL, Google Translate, Papago, Amazon Translate, Unbabel

디자인: Canva AI, Figma AI, Framer AI, Looka, Brandmark, Photoroom, Remove.bg, Clipdrop

마케팅: HubSpot AI, Persado, Phrasee, Albert.ai, Seventh Sense, Drift

SEO: Surfer SEO, Clearscope, MarketMuse, Frase, NeuronWriter, SEO.ai

교육: Khan Academy (Khanmigo), Duolingo Max, Quizlet AI, Elsa Speak, Photomath, Socratic

의료/헬스케어: Lunit, Vuno, PathAI, Zebra Medical, Aidoc, Butterfly Network

법률: Harvey AI, Casetext (CoCounsel), Luminance, Kira Systems, Ross Intelligence

금융/핀테크: Bloomberg GPT, Kensho, Numerai, AlphaSense, Upstart

HR/채용: HireVue, Eightfold.ai, Pymetrics, Textio, Beamery

사이버보안: Darktrace, CrowdStrike Falcon AI, SentinelOne, Vectra AI

3D/공간컴퓨팅: Meshy, Point-E, GET3D, Luma AI (3D), CSM, Kaedim

로보틱스: Figure AI, Boston Dynamics, Agility Robotics, Covariant, Sanctuary AI

게임개발: Scenario.gg, Ludo.ai, Promethean AI, Inworld AI

이커머스: Nate, Shopify Magic, Algolia AI, Dynamic Yield

농업/환경: Blue River Technology, Prospera, Taranis, ClimateAI

고객 서비스: Intercom Fin, Zendesk AI, Ada, Tidio AI, Freshdesk Freddy

자동화: Zapier AI, Make (Integromat), UiPath AI, Automation Anywhere

프레젠테이션: Gamma, Tome, Beautiful.ai, SlidesAI, Decktopus

과학/연구: AlphaFold, Isomorphic Labs, BioNTech AI, InstaDeep

부동산: Zillow AI, Compass AI, Rex, Restb.ai

각 도구 INSERT 시 포함할 필드:
- `tool_name`, `provider_name`, `provider_country`, `category`
- `description` (2-3문장 한국어), `purpose_summary` (1문장)
- `pricing_model` ('Free', 'Freemium', 'Paid', 'Enterprise', 'Open Source')
- `website_url`, `api_available`, `free_tier_available`
- `difficulty_level`, `rating` (4.0~4.9 범위), `review_count`
- `monthly_visits` (추정치), `global_rank`, `trend_score`
- `input_modalities`, `output_modalities`
- `supported_platforms` (JSON: ["web","api","ios","android"] 등)
- `pros`, `cons` (JSON 배열, 한국어)
- `enterprise_ready`, `open_source`
- `is_active` = 1

### countries 시드 데이터
주요 AI 국가 20개 이상 등록 (US, CN, KR, JP, GB, DE, FR, IL, CA, IN, SE, FI, NL, AU, SG, AE, CH, IE, TW, RU 등)

### ai_tool_news 시드 데이터
최소 30개 뉴스 기사 등록:
- 각 주요 도구의 최신 업데이트 소식
- AI 산업 트렌드 기사
- 투자/펀딩 뉴스
- 비교 분석 기사

## 1.3 새로운 DAO 파일

### `ProviderDAO.java` — `/WEB-INF/src/dao/ProviderDAO.java`
```java
// 메서드:
findAll() → List<Provider>
findById(int id) → Provider
findByCountry(String country) → List<Provider>
search(String keyword) → List<Provider>
getTopProviders(int limit) → List<Provider>
getProviderWithToolCount() → List<Map>  // provider + tool_count JOIN
```

### `AIToolNewsDAO.java` — `/WEB-INF/src/dao/AIToolNewsDAO.java`
```java
findLatest(int limit) → List<AIToolNews>
findByToolId(int toolId) → List<AIToolNews>
findByType(String newsType, int limit) → List<AIToolNews>
findFeatured(int limit) → List<AIToolNews>
search(String keyword) → List<AIToolNews>
incrementViewCount(int id) → boolean
```

### `BenchmarkDAO.java` — `/WEB-INF/src/dao/BenchmarkDAO.java`
```java
findByToolId(int toolId) → List<Benchmark>
findByBenchmarkName(String name) → List<Benchmark>  // 벤치마크별 전체 도구 점수
getTopScores(String benchmarkName, int limit) → List<Benchmark>
```

### `CountryDAO.java` — `/WEB-INF/src/dao/CountryDAO.java`
```java
findAll() → List<Country>
findByCode(String code) → Country
getCountriesWithToolCount() → List<Map>  // country + tool_count
```

## 1.4 새로운 Model 파일

### `Provider.java`, `AIToolNews.java`, `Benchmark.java`, `Country.java`
- 각 테이블 매핑 POJO
- getter/setter + 유틸 메서드

## 1.5 API 서블릿 확장

### `AIToolServlet.java` 확장
기존 `/api/ai-tools/*` 에 추가 엔드포인트:
```
GET /api/ai-tools/rankings?sort=global_rank|trend_score|rating|monthly_visits&category=X&country=X&limit=50
GET /api/ai-tools/by-country?country=US&page=1&pageSize=20
GET /api/ai-tools/by-provider?provider=OpenAI
GET /api/ai-tools/compare?ids=1,2,3  (최대 4개 비교)
GET /api/ai-tools/trends  (카테고리별 성장률, 월간 트렌드)
GET /api/ai-tools/stats  (총 도구수, 카테고리 분포, 국가 분포)
```

### 새 서블릿: `NewsServlet.java` → `/api/news/*`
```
GET /api/news?type=update|launch|funding&limit=10
GET /api/news/{id}
GET /api/news/tool/{toolId}
```

### 새 서블릿: `RankingServlet.java` → `/api/rankings/*`
```
GET /api/rankings/global?limit=100
GET /api/rankings/category/{category}?limit=50
GET /api/rankings/country/{countryCode}?limit=50
GET /api/rankings/rising  (성장률 TOP 20)
GET /api/rankings/benchmarks?name=MMLU
```

---

# PHASE 2: 프론트엔드 — 도구 탐색 UI 대규모 개편

## 2.1 Navigator 페이지 개편 — `/AI/user/tools/navigator.jsp`

### 레이아웃 구조
```
┌─────────────────────────────────────────────────────┐
│ [검색바: 키워드 + 자동완성]                            │
│ [필터: 카테고리 | 국가 | 가격 | 난이도 | 정렬]          │
├──────────┬──────────────────────────────────────────┤
│ 사이드바   │ 메인 콘텐츠                               │
│          │                                          │
│ 카테고리   │  [뷰 전환: 카드 | 리스트 | 테이블]          │
│ (30개)    │                                          │
│          │  ┌────┐ ┌────┐ ┌────┐ ┌────┐             │
│ 국가별     │  │카드│ │카드│ │카드│ │카드│             │
│ (국기+수)  │  └────┘ └────┘ └────┘ └────┘             │
│          │  ┌────┐ ┌────┐ ┌────┐ ┌────┐             │
│ 회사별     │  │카드│ │카드│ │카드│ │카드│             │
│          │  └────┘ └────┘ └────┘ └────┘             │
│ 가격필터   │                                          │
│ ○무료      │  [더 보기 / 무한 스크롤]                    │
│ ○프리미엄  │                                          │
│ ○유료      │                                          │
│          │                                          │
│ 플랫폼     │                                          │
│ □웹       │                                          │
│ □API      │                                          │
│ □모바일    │                                          │
└──────────┴──────────────────────────────────────────┘
```

### 카드 디자인
```
┌──────────────────────────────┐
│ [파비콘] 도구명         ★4.7  │
│ CompanyName · 🇺🇸 US         │
│                              │
│ 1-2줄 요약 설명 ...           │
│                              │
│ [카테고리] [Freemium] [API]   │
│                              │
│ 🔥 순위 #3  📈 +12.5%        │
│ ♥ 1.2K     👁 50K/월        │
└──────────────────────────────┘
```

### 정렬 옵션
- 글로벌 순위순 (기본)
- 인기순 (trend_score)
- 별점순 (rating)
- 성장률순 (growth_rate)
- 최신순 (launch_date)
- 방문자순 (monthly_visits)
- 이름순 (가나다/ABC)

### JavaScript: `/AI/assets/js/navigator.js` 개편
```javascript
// 서버사이드 필터링으로 전환 (500+ 도구는 클라이언트 처리 불가)
// Fetch API로 /api/ai-tools/rankings 호출
// IntersectionObserver 기반 무한 스크롤
// URL 파라미터로 필터 상태 유지 (뒤로가기 지원)
// debounce 검색 (300ms)
// 뷰 모드 전환 (카드/리스트/테이블) localStorage 저장
```

### CSS: `/AI/assets/css/navigator.css` 개편
```css
/* 사이드바 필터 패널 */
/* 카드 뷰 (4열 그리드) */
/* 리스트 뷰 (1열, 더 많은 정보) */
/* 테이블 뷰 (스프레드시트 스타일, 정렬 가능 헤더) */
/* 모바일: 사이드바 → 바텀시트, 2열 그리드 */
/* 국가 필터: 국기 이모지 + 도구 수 뱃지 */
```

## 2.2 도구 상세 페이지 개편 — `/AI/user/tools/detail.jsp`

### 레이아웃
```
┌────────────────────────────────────────────┐
│ [뒤로가기]                                   │
│                                            │
│ [파비콘 64px] Tool Name             ★4.7   │
│ by ProviderName · 🇺🇸 US · Since 2023      │
│                                            │
│ [카테고리] [가격] [플랫폼] [API] [오픈소스]    │
│                                            │
│ [웹사이트 방문] [API 문서] [♥ 즐겨찾기]       │
├──────┬──────┬──────┬──────┬────────────────┤
│ 개요  │ 벤치  │ 비교  │ 뉴스  │ 리뷰          │
│      │ 마크  │      │      │               │
├──────┴──────┴──────┴──────┴────────────────┤
│                                            │
│ [탭: 개요]                                   │
│  설명                                       │
│  장점/단점 (pros/cons)                       │
│  주요 기능                                   │
│  사용 사례                                   │
│  가격 정보                                   │
│  대안 도구 (alternatives) → 카드 캐러셀       │
│                                            │
│ [탭: 벤치마크]                                │
│  레이더 차트 (Chart.js)                      │
│  벤치마크 점수 테이블                         │
│                                            │
│ [탭: 비교]                                   │
│  "비교할 도구 선택" → 2~4개 나란히 비교        │
│  막대 차트로 각 항목 비교                     │
│                                            │
│ [탭: 뉴스]                                   │
│  이 도구 관련 최신 뉴스/업데이트               │
│                                            │
│ [탭: 리뷰]                                   │
│  사용자 리뷰 (community_reviews 테이블)       │
│  별점 분포 차트                              │
│                                            │
└────────────────────────────────────────────┘
```

## 2.3 순위 페이지 (신규) — `/AI/user/tools/rankings.jsp`

### 레이아웃
```
┌────────────────────────────────────────────┐
│ AI 도구 글로벌 순위                          │
│                                            │
│ [탭: 종합 | 카테고리별 | 국가별 | 급상승]      │
│                                            │
│ [종합 순위]                                  │
│ #1  ChatGPT      ★4.9  📈+5.2%  🇺🇸       │
│ #2  Claude       ★4.8  📈+8.1%  🇺🇸       │
│ #3  Gemini       ★4.7  📈+3.5%  🇺🇸       │
│ ...                                        │
│                                            │
│ [사이드: 카테고리 분포 도넛 차트]              │
│ [사이드: 국가별 도구 수 바 차트]               │
│ [사이드: 월간 트렌드 라인 차트]               │
└────────────────────────────────────────────┘
```

## 2.4 비교 페이지 (신규) — `/AI/user/tools/compare.jsp`

### 기능
- URL: `/AI/user/tools/compare.jsp?ids=1,2,3`
- 최대 4개 도구 나란히 비교
- 항목: 가격, 기능, 벤치마크, 플랫폼, API, 장단점
- 레이더 차트 (성능, 가격, 사용성, 기능, 지원)
- "승자" 하이라이트 (각 항목별)
- 공유 링크 생성

## 2.5 뉴스/인사이트 페이지 (신규) — `/AI/user/news/`

### 파일 구조
```
/AI/user/news/
  index.jsp      — 뉴스 피드 (최신순, 타입 필터)
  detail.jsp     — 뉴스 상세 (마크다운 렌더링)
```

### 뉴스 카드
```
┌────────────────────────────────────────┐
│ [썸네일 이미지]                          │
│                                        │
│ [UPDATE] GPT-5 출시 임박: 알려진 것들    │
│ OpenAI가 차세대 모델 GPT-5를 ...        │
│                                        │
│ 2026.03.10 · OpenAI · 조회 1.2K        │
└────────────────────────────────────────┘
```

## 2.6 데이터 시각화 — `/AI/assets/js/charts.js`

Chart.js CDN: `https://cdn.jsdelivr.net/npm/chart.js`

### 차트 유틸리티 함수들
```javascript
// renderRadarChart(canvasId, labels, datasets) — 벤치마크 비교
// renderBarChart(canvasId, labels, data, options) — 순위/점수
// renderDoughnutChart(canvasId, labels, data) — 카테고리 분포
// renderLineChart(canvasId, labels, datasets) — 트렌드
// renderHorizontalBarChart(canvasId, data) — 국가별 도구 수
// renderComparisonChart(canvasId, tools[]) — 도구 비교 (그룹 바)
// 공통: 다크 테마 (#0a0a0a 배경), 한국어 라벨, 반응형
```

### 차트 테마 (다크)
```javascript
Chart.defaults.color = '#a0a0b0';
Chart.defaults.borderColor = 'rgba(255,255,255,0.06)';
// 색상 팔레트: ['#6366f1','#8b5cf6','#a855f7','#ec4899','#f43f5e','#f97316','#eab308','#22c55e','#06b6d4','#3b82f6']
```

---

# PHASE 3: 실습 랩 고도화 — 실제 AI API 실행 환경

## 3.1 핵심 컨셉

사용자가 사이트 내에서 **실제 AI API를 호출**하여 실습할 수 있는 환경.
- 사용자 크레딧(토큰)으로 API 호출 비용 차감
- 코드 에디터 + 실행 결과 패널
- 프롬프트 엔지니어링 실습
- 다양한 AI 모델 비교 실행

## 3.2 DB 스키마

### user_api_keys 테이블 활용 (기존)
```sql
-- 사용자가 자신의 API 키를 등록하여 사용 가능
ALTER TABLE user_api_keys
  ADD COLUMN provider VARCHAR(50) NOT NULL DEFAULT 'openai' AFTER user_id,
  ADD COLUMN key_name VARCHAR(100) DEFAULT NULL,
  ADD COLUMN is_active TINYINT(1) DEFAULT 1,
  ADD COLUMN last_used_at TIMESTAMP DEFAULT NULL,
  ADD COLUMN usage_count INT DEFAULT 0;
```

### lab_sessions 테이블 (새로 생성)
```sql
CREATE TABLE lab_sessions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  project_id INT DEFAULT NULL,
  session_type ENUM('playground','project','challenge') DEFAULT 'playground',
  title VARCHAR(255) DEFAULT NULL,
  code_content LONGTEXT DEFAULT NULL COMMENT '사용자 코드/프롬프트',
  result_content LONGTEXT DEFAULT NULL COMMENT 'AI 응답 결과',
  model_used VARCHAR(100) DEFAULT NULL,
  tokens_used INT DEFAULT 0,
  credits_used DECIMAL(10,2) DEFAULT 0,
  execution_time_ms INT DEFAULT NULL,
  status ENUM('draft','running','completed','error') DEFAULT 'draft',
  metadata JSON DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (project_id) REFERENCES lab_projects(id) ON DELETE SET NULL,
  INDEX idx_session_user (user_id, created_at DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### lab_templates 테이블 (새로 생성)
```sql
CREATE TABLE lab_templates (
  id INT AUTO_INCREMENT PRIMARY KEY,
  project_id INT DEFAULT NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT DEFAULT NULL,
  template_type ENUM('prompt','code','workflow') DEFAULT 'prompt',
  category VARCHAR(100) DEFAULT NULL,
  difficulty_level ENUM('Beginner','Intermediate','Advanced') DEFAULT 'Beginner',
  initial_code LONGTEXT DEFAULT NULL COMMENT '시작 코드/프롬프트',
  expected_output TEXT DEFAULT NULL COMMENT '예상 결과 가이드',
  hints JSON DEFAULT NULL,
  model_recommendation VARCHAR(100) DEFAULT NULL,
  estimated_tokens INT DEFAULT NULL,
  estimated_credits DECIMAL(10,2) DEFAULT NULL,
  tags JSON DEFAULT NULL,
  is_active TINYINT(1) DEFAULT 1,
  use_count INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (project_id) REFERENCES lab_projects(id) ON DELETE SET NULL,
  INDEX idx_template_cat (category),
  INDEX idx_template_type (template_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

## 3.3 실습 유형

### Type A: AI Playground (자유 실습)
```
┌────────────────────────────────────────────────────┐
│ AI Playground                                       │
│                                                    │
│ 모델 선택: [GPT-4o ▼] [Claude 3.5 ▼] [Gemini ▼]   │
│ 모드: [○채팅] [○완성] [○이미지] [○코드]              │
│                                                    │
│ ┌─────────────────┬──────────────────────────────┐ │
│ │ 프롬프트 입력     │ 결과 출력                     │ │
│ │                 │                              │ │
│ │ System:         │ (AI 응답이 여기 표시)           │ │
│ │ [시스템 프롬프트]  │                              │ │
│ │                 │ 토큰: 523 / 크레딧: 0.05      │ │
│ │ User:           │ 소요시간: 1.2s                │ │
│ │ [사용자 프롬프트]  │                              │ │
│ │                 │                              │ │
│ │ [실행 ▶] [초기화] │ [복사] [저장] [공유]          │ │
│ └─────────────────┴──────────────────────────────┘ │
│                                                    │
│ 잔여 크레딧: 🪙 450 / 500                           │
└────────────────────────────────────────────────────┘
```

### Type B: 프롬프트 엔지니어링 실습
미리 정의된 과제 + 힌트 + 평가 기준:
- "이 이미지를 분석하여 마케팅 카피를 작성하세요"
- "이 코드의 버그를 찾아 수정하세요"
- "이 데이터를 요약하고 인사이트를 도출하세요"
- 사용자 프롬프트 → AI 실행 → 자동 평가 (키워드/구조 체크)

### Type C: 워크플로우 실습
여러 AI를 연결하는 파이프라인:
1. 텍스트 입력 → GPT로 번역 → DALL-E로 이미지 생성
2. PDF 업로드 → Claude로 요약 → 핵심 포인트 추출
3. 코드 분석 → 리팩토링 제안 → 테스트 코드 생성

## 3.4 AI API 프록시 서블릿

### `AIProxyServlet.java` → `/api/ai-proxy/*` (새로 생성)

보안을 위해 AI API 호출은 반드시 서버 사이드에서:

```java
/**
 * AI API 프록시 서블릿
 * 사용자의 크레딧을 차감하고 AI API를 대리 호출
 *
 * POST /api/ai-proxy/chat
 *   body: { "model": "gpt-4o", "messages": [...], "max_tokens": 1000 }
 *
 * POST /api/ai-proxy/image
 *   body: { "model": "dall-e-3", "prompt": "...", "size": "1024x1024" }
 *
 * 처리 흐름:
 * 1. 세션에서 User 확인
 * 2. 크레딧 잔액 확인 (CreditDAO.getBalance)
 * 3. 예상 비용 계산
 * 4. AI API 호출 (HttpURLConnection)
 * 5. 크레딧 차감 (CreditDAO.deduct)
 * 6. lab_sessions에 기록
 * 7. 결과 반환
 *
 * 지원 API:
 * - OpenAI: chat/completions, images/generations
 * - Anthropic: messages
 * - Google: generateContent
 *
 * API 키 우선순위:
 * 1. 사용자 등록 키 (user_api_keys)
 * 2. 플랫폼 공유 키 (환경변수) — 크레딧 차감
 *
 * 크레딧 비용 계산:
 * - GPT-4o: 입력 1K토큰 = 0.5크레딧, 출력 1K토큰 = 1.5크레딧
 * - Claude 3.5 Sonnet: 입력 1K토큰 = 0.3크레딧, 출력 1K토큰 = 1.5크레딧
 * - DALL-E 3: 1이미지 = 10크레딧
 * - Gemini Pro: 입력 1K토큰 = 0.1크레딧, 출력 1K토큰 = 0.3크레딧
 */
```

### `LabSessionServlet.java` → `/api/lab-sessions/*` (새로 생성)
```
POST /api/lab-sessions          — 세션 생성
GET  /api/lab-sessions          — 내 세션 목록
GET  /api/lab-sessions/{id}     — 세션 상세
PUT  /api/lab-sessions/{id}     — 세션 업데이트 (코드 저장)
DELETE /api/lab-sessions/{id}   — 세션 삭제
```

## 3.5 프론트엔드 — 실습 UI

### `/AI/user/lab/` 페이지 구조 개편
```
/AI/user/lab/
  index.jsp          — 실습 허브 (프로젝트 목록 + Playground 진입)
  playground.jsp     — AI Playground (자유 실습)
  project.jsp        — 프로젝트 기반 실습
  session.jsp        — 진행 중인 세션 (기존 개편)
  history.jsp        — 실습 히스토리
```

### `/AI/assets/js/playground.js` (신규)
```javascript
// CodeMirror 또는 textarea 기반 코드/프롬프트 에디터
// 모델 선택 드롭다운
// 실행 버튼 → fetch('/api/ai-proxy/chat', {...})
// 스트리밍 응답 표시 (Server-Sent Events 또는 폴링)
// 토큰 카운터 (tiktoken 근사치)
// 크레딧 잔액 표시
// 세션 자동 저장 (30초 간격)
// 마크다운 렌더링 (Marked.js)
// 코드 하이라이트 (Prism.js)
// 결과 복사/저장/공유
```

### `/AI/assets/js/lab-project.js` (신규)
```javascript
// 프로젝트 단계별 진행 UI
// 힌트 토글
// 자동 평가 로직 (키워드 매칭, 구조 체크)
// 진행률 바
// 평가 결과 모달
```

## 3.6 lab_templates 시드 데이터 (30개 이상)

**Beginner (10개):**
1. "ChatGPT에게 자기소개서 작성 요청하기"
2. "Claude로 영어 이메일 번역하기"
3. "AI로 블로그 포스트 아이디어 브레인스토밍"
4. "프롬프트로 원하는 이미지 설명하기 (DALL-E)"
5. "AI 코드 리뷰 받아보기"
6. "회의록 요약 프롬프트 작성"
7. "AI로 Excel 수식 만들기"
8. "SNS 마케팅 문구 생성"
9. "AI로 면접 질문 준비하기"
10. "간단한 Python 코드 AI로 작성하기"

**Intermediate (10개):**
11. "Few-shot 프롬프트로 감성 분석기 만들기"
12. "Chain-of-Thought 추론으로 수학 문제 풀기"
13. "시스템 프롬프트로 AI 페르소나 만들기"
14. "AI로 데이터 시각화 코드 생성하기"
15. "멀티턴 대화로 기획서 완성하기"
16. "AI 모델 3개 비교 실행 (같은 프롬프트)"
17. "프롬프트 최적화: 비용 대비 품질 개선"
18. "AI로 REST API 설계하기"
19. "이미지 분석 + 텍스트 생성 워크플로우"
20. "AI로 SQL 쿼리 생성 및 최적화"

**Advanced (10개):**
21. "RAG 파이프라인 시뮬레이션"
22. "AI 에이전트 워크플로우 설계"
23. "멀티모달 입력 처리 (텍스트+이미지)"
24. "프롬프트 인젝션 방어 실습"
25. "AI 응답 품질 평가 프레임워크 구축"
26. "커스텀 AI 챗봇 시스템 프롬프트 설계"
27. "AI 기반 코드 리팩토링 파이프라인"
28. "대규모 문서 처리 전략 (청킹+요약)"
29. "AI 모델 파인튜닝 데이터 준비"
30. "프로덕션급 AI 애플리케이션 아키텍처 설계"

---

# PHASE 4: 결제 시스템 고도화

## 4.1 요금제 구조

### plans 테이블 재설계
```sql
DROP TABLE IF EXISTS plans;
CREATE TABLE plans (
  id INT AUTO_INCREMENT PRIMARY KEY,
  plan_code VARCHAR(50) NOT NULL UNIQUE,
  plan_name VARCHAR(100) NOT NULL,
  plan_name_ko VARCHAR(100) NOT NULL,
  plan_type ENUM('free','starter','pro','enterprise') NOT NULL,
  billing_cycle ENUM('monthly','yearly','lifetime') DEFAULT 'monthly',
  price_monthly DECIMAL(12,2) NOT NULL DEFAULT 0,
  price_yearly DECIMAL(12,2) DEFAULT NULL COMMENT '연간 결제 시 할인가',
  currency VARCHAR(10) DEFAULT 'KRW',
  credits_monthly INT NOT NULL DEFAULT 0 COMMENT '월간 크레딧',
  credits_rollover TINYINT(1) DEFAULT 0 COMMENT '미사용 크레딧 이월 여부',
  max_api_calls_daily INT DEFAULT NULL COMMENT '일일 API 호출 제한',
  max_projects INT DEFAULT NULL COMMENT '동시 프로젝트 수 제한',
  features JSON NOT NULL COMMENT '기능 목록',
  is_popular TINYINT(1) DEFAULT 0,
  is_active TINYINT(1) DEFAULT 1,
  display_order INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### 요금제 시드 데이터
```sql
INSERT INTO plans (plan_code, plan_name, plan_name_ko, plan_type, price_monthly, price_yearly, credits_monthly, max_api_calls_daily, max_projects, features, is_popular, display_order) VALUES

('free', 'Free', '무료', 'free', 0, 0, 50, 20, 3,
 '{"tools_access":"basic","lab_access":"basic_only","playground":"limited","export":false,"priority_support":false,"api_key_slots":0,"history_days":7}',
 0, 1),

('starter', 'Starter', '스타터', 'starter', 9900, 99000, 500, 100, 10,
 '{"tools_access":"full","lab_access":"all","playground":"standard","export":true,"priority_support":false,"api_key_slots":2,"history_days":30,"model_compare":true}',
 0, 2),

('pro', 'Professional', '프로', 'pro', 29900, 299000, 2000, 500, 50,
 '{"tools_access":"full","lab_access":"all","playground":"advanced","export":true,"priority_support":true,"api_key_slots":10,"history_days":90,"model_compare":true,"team_sharing":true,"custom_templates":true,"advanced_analytics":true}',
 1, 3),

('enterprise', 'Enterprise', '엔터프라이즈', 'enterprise', 99900, 999000, 10000, -1, -1,
 '{"tools_access":"full","lab_access":"all","playground":"unlimited","export":true,"priority_support":true,"api_key_slots":-1,"history_days":-1,"model_compare":true,"team_sharing":true,"custom_templates":true,"advanced_analytics":true,"sso":true,"audit_log":true,"dedicated_support":true,"custom_models":true}',
 0, 4);
```

## 4.2 결제 연동 — PortOne (아임포트)

### 환경변수 추가
```
PORTONE_IMP_CODE=impXXXXXXXX
PORTONE_API_KEY=XXXX
PORTONE_API_SECRET=XXXX
```

### `PaymentServlet.java` → `/api/payments/*` (새로 생성)
```java
/**
 * 결제 처리 서블릿
 *
 * POST /api/payments/prepare    — 결제 사전 등록
 *   body: { "planId": 2, "billingCycle": "monthly" }
 *   response: { "merchantUid": "order_...", "amount": 9900 }
 *
 * POST /api/payments/complete   — 결제 완료 검증
 *   body: { "impUid": "imp_...", "merchantUid": "order_..." }
 *   처리: PortOne API로 결제 검증 → 금액 일치 확인 → 구독 활성화 → 크레딧 부여
 *
 * POST /api/payments/webhook    — PortOne 웹훅 (서버간)
 *   결제 상태 변경 알림 처리
 *
 * GET  /api/payments/history    — 결제 내역
 * POST /api/payments/cancel     — 결제 취소/환불
 *
 * 처리 흐름:
 * 1. 프론트: PortOne JS SDK로 결제창 호출
 * 2. 사용자 결제 완료
 * 3. 프론트 → /api/payments/complete (impUid, merchantUid)
 * 4. 서버: PortOne REST API로 결제 정보 조회
 * 5. 금액/상태 검증
 * 6. subscriptions 테이블 INSERT/UPDATE
 * 7. user_credits에 크레딧 부여
 * 8. orders 테이블에 기록
 */
```

### `SubscriptionServlet.java` → `/api/subscriptions/*` (새로 생성)
```java
/**
 * 구독 관리 서블릿
 *
 * GET  /api/subscriptions/current — 현재 구독 정보
 * POST /api/subscriptions/change  — 플랜 변경 (업/다운그레이드)
 * POST /api/subscriptions/cancel  — 구독 취소
 * GET  /api/subscriptions/usage   — 이번 달 사용량
 */
```

### subscriptions 테이블 확장
```sql
ALTER TABLE subscriptions
  ADD COLUMN plan_id INT DEFAULT NULL,
  ADD COLUMN billing_cycle ENUM('monthly','yearly') DEFAULT 'monthly',
  ADD COLUMN next_billing_date DATE DEFAULT NULL,
  ADD COLUMN cancel_at_period_end TINYINT(1) DEFAULT 0,
  ADD COLUMN portone_customer_uid VARCHAR(100) DEFAULT NULL,
  ADD COLUMN last_payment_id INT DEFAULT NULL,
  ADD INDEX idx_sub_user (user_id),
  ADD INDEX idx_sub_plan (plan_id);
```

## 4.3 크레딧 시스템 고도화

### credit_packages 테이블 (새로 생성 — 추가 크레딧 구매)
```sql
CREATE TABLE credit_packages (
  id INT AUTO_INCREMENT PRIMARY KEY,
  package_name VARCHAR(100) NOT NULL,
  credits INT NOT NULL,
  price DECIMAL(12,2) NOT NULL,
  bonus_credits INT DEFAULT 0 COMMENT '보너스 크레딧',
  is_active TINYINT(1) DEFAULT 1,
  display_order INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO credit_packages (package_name, credits, price, bonus_credits, display_order) VALUES
('소량', 100, 3900, 0, 1),
('기본', 500, 14900, 50, 2),
('대량', 2000, 49900, 400, 3),
('벌크', 10000, 199000, 3000, 4);
```

## 4.4 프론트엔드 — 결제 UI

### `/AI/user/pricing.jsp` 개편
```
┌──────────────────────────────────────────────────────┐
│ 요금제                                [월간] [연간 20%↓] │
│                                                      │
│ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ │
│ │   무료    │ │  스타터   │ │   프로    │ │엔터프라이즈│ │
│ │          │ │          │ │ ★인기★   │ │          │ │
│ │  ₩0/월   │ │₩9,900/월 │ │₩29,900/월│ │₩99,900/월│ │
│ │          │ │          │ │          │ │          │ │
│ │ 50크레딧  │ │500크레딧  │ │2000크레딧 │ │10000크레딧│ │
│ │ 20회/일   │ │100회/일  │ │500회/일   │ │ 무제한   │ │
│ │ 3프로젝트 │ │10프로젝트 │ │50프로젝트  │ │ 무제한   │ │
│ │          │ │          │ │          │ │          │ │
│ │ ✓ 기본도구 │ │ ✓ 전체도구│ │ ✓ 전체도구│ │ ✓ 전체도구│ │
│ │ ✓ 기본실습 │ │ ✓ 전체실습│ │ ✓ 전체실습│ │ ✓ 전체실습│ │
│ │ ✗ 내보내기 │ │ ✓ 내보내기│ │ ✓ 내보내기│ │ ✓ 내보내기│ │
│ │ ✗ API키   │ │ ✓ 2개    │ │ ✓ 10개  │ │ ✓ 무제한 │ │
│ │ 7일 기록  │ │ 30일 기록 │ │ 90일 기록 │ │ 무제한   │ │
│ │          │ │          │ │ ✓ 팀공유  │ │ ✓ SSO   │ │
│ │          │ │          │ │ ✓ 분석   │ │ ✓ 전담지원│ │
│ │          │ │          │ │          │ │          │ │
│ │ [현재 플랜]│ │ [시작하기]│ │ [시작하기]│ │ [문의하기]│ │
│ └──────────┘ └──────────┘ └──────────┘ └──────────┘ │
│                                                      │
│ ─────── 추가 크레딧 구매 ───────                        │
│ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐         │
│ │100크레딧│ │500+50  │ │2000+400│ │10K+3K  │         │
│ │ ₩3,900 │ │₩14,900 │ │₩49,900 │ │₩199,000│         │
│ │[구매]  │ │[구매]  │ │[구매]  │ │[구매]  │         │
│ └────────┘ └────────┘ └────────┘ └────────┘         │
└──────────────────────────────────────────────────────┘
```

### `/AI/assets/js/payment.js` (신규)
```javascript
// PortOne SDK 초기화
// IMP.init('impXXXXXXXX')
//
// requestPay(planId, billingCycle):
//   1. fetch('/api/payments/prepare', {planId, billingCycle})
//   2. IMP.request_pay({...merchantUid, amount, buyer_*})
//   3. on success: fetch('/api/payments/complete', {impUid, merchantUid})
//   4. 결과 처리 (성공 → pricing 페이지 갱신, 실패 → 에러 모달)
//
// requestCreditPurchase(packageId):
//   추가 크레딧 구매 (같은 흐름)
```

---

# PHASE 5: 인증·마이페이지 고도화

## 5.1 마이페이지 개편 — `/AI/user/mypage.jsp`

### 탭 구조
```
[프로필] [구독·크레딧] [실습 기록] [즐겨찾기] [API 키] [설정]
```

**프로필 탭:**
- 프로필 이미지 변경
- 기본 정보 수정
- 관심 분야, 스킬 태그
- 경험 수준

**구독·크레딧 탭:**
- 현재 플랜 표시
- 크레딧 잔액 + 이번 달 사용량 차트
- 사용 내역 (날짜, 모델, 토큰, 크레딧)
- 플랜 변경/취소 버튼
- 추가 크레딧 구매

**실습 기록 탭:**
- 세션 목록 (날짜, 모델, 타입)
- 세션 재개/복사
- 프로젝트 진행률
- 완료한 실습 수/뱃지

**즐겨찾기 탭:**
- 즐겨찾기한 도구 목록
- 카테고리별 그룹

**API 키 관리 탭:**
- 등록된 API 키 목록 (마스킹 표시)
- 새 키 등록 (provider 선택 + 키 입력)
- 키 삭제
- 키 사용 현황

**설정 탭:**
- 비밀번호 변경
- 알림 설정
- 계정 삭제

## 5.2 `UserAPIKeyServlet.java` → `/api/user/api-keys/*` (새로 생성)
```
GET    /api/user/api-keys       — 내 API 키 목록 (마스킹)
POST   /api/user/api-keys       — 키 등록
DELETE /api/user/api-keys/{id}  — 키 삭제
PUT    /api/user/api-keys/{id}  — 키 이름/상태 변경
```

API 키는 DB에 암호화 저장 (AES-256):
```java
// util/EncryptionUtil.java (신규)
// AES-256-GCM 암호화/복호화
// 키: 환경변수 ENCRYPTION_KEY
```

---

# PHASE 6: 관리자 대시보드 고도화

## 6.1 `/AI/admin/dashboard.jsp` 개편

```
┌────────────────────────────────────────────────────┐
│ AI Workflow Lab 대시보드                             │
│                                                    │
│ [KPI 카드 행]                                       │
│ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐       │
│ │총 도구   │ │활성 유저 │ │월 매출   │ │총 크레딧  │       │
│ │ 523     │ │ 1,247  │ │₩4.2M   │ │사용률 67%│       │
│ │+12 이번주│ │+48 금주 │ │+15% MoM│ │         │       │
│ └────────┘ └────────┘ └────────┘ └────────┘       │
│                                                    │
│ [차트 행 — Chart.js]                                │
│ ┌──────────────────────┐ ┌───────────────────┐     │
│ │ 월간 가입자 추이 (라인) │ │ 카테고리 분포 (도넛)│     │
│ └──────────────────────┘ └───────────────────┘     │
│ ┌──────────────────────┐ ┌───────────────────┐     │
│ │ 매출 추이 (바)        │ │ 플랜 분포 (파이)   │     │
│ └──────────────────────┘ └───────────────────┘     │
│                                                    │
│ [최근 활동]                                         │
│ 최근 가입 유저 5명                                   │
│ 최근 주문 5건                                       │
│ 인기 도구 TOP 5                                     │
└────────────────────────────────────────────────────┘
```

## 6.2 관리자 도구 관리 고도화

### `/AI/admin/tools/index.jsp`
- 도구 일괄 등록 (CSV/JSON 업로드)
- 순위 수동 조정
- 뉴스 등록/관리
- 벤치마크 데이터 관리

### `/AI/admin/analytics/` (신규)
```
index.jsp      — 종합 분석 대시보드
users.jsp      — 사용자 분석 (DAU/MAU, 리텐션)
credits.jsp    — 크레딧 사용 분석 (모델별, 유저별)
revenue.jsp    — 매출 분석 (플랜별, 기간별)
tools.jsp      — 도구 인기도 분석
```

---

# PHASE 7: 홈페이지 & 랜딩 페이지

## 7.1 `/AI/user/home.jsp` 개편

```
┌────────────────────────────────────────────────────┐
│ [히어로 섹션]                                       │
│ "AI의 모든 것을 탐색하고 실습하세요"                    │
│ [도구 탐색] [실습 시작] [무료 가입]                    │
├────────────────────────────────────────────────────┤
│ [실시간 통계]                                       │
│ 🔧 523개 AI 도구  👥 1,247 사용자  🏆 42개 카테고리   │
├────────────────────────────────────────────────────┤
│ [🔥 트렌딩 AI 도구]                                 │
│ 카드 캐러셀 — 성장률 TOP 8                           │
├────────────────────────────────────────────────────┤
│ [📊 AI 순위 미리보기]                                │
│ TOP 10 테이블 + "전체 순위 보기" 링크                  │
├────────────────────────────────────────────────────┤
│ [🧪 인기 실습]                                      │
│ 인기 실습 프로젝트 카드 6개                           │
├────────────────────────────────────────────────────┤
│ [📰 최신 AI 뉴스]                                   │
│ 뉴스 카드 4개                                       │
├────────────────────────────────────────────────────┤
│ [🌍 국가별 AI 생태계]                                │
│ 세계 지도 or 국가 카드 그리드                         │
├────────────────────────────────────────────────────┤
│ [💰 요금제]                                         │
│ 간단한 요금제 비교 + "자세히 보기" 링크                 │
├────────────────────────────────────────────────────┤
│ [푸터]                                              │
└────────────────────────────────────────────────────┘
```

---

# PHASE 8: SEO, 성능, 보안

## 8.1 SEO
- 모든 페이지에 meta title, description, og:tags
- 도구 상세 페이지: 구조화 데이터 (JSON-LD SoftwareApplication)
- sitemap.xml 자동 생성 (서블릿)
- robots.txt

## 8.2 성능
- 정적 자산 캐시 헤더 (1year for versioned, no-cache for HTML)
- JS/CSS 번들링은 안 하되, 불필요한 코드 제거
- DB 인덱스 최적화 (위 ALTER 문에 포함)
- 이미지 lazy loading
- API 응답 캐싱 (인메모리 HashMap, 5분 TTL)

## 8.3 보안 강화
- API 키 AES-256 암호화 저장
- AI Proxy 서블릿에 요율 제한 (유저별 분당 30회)
- 결제 웹훅 서명 검증
- admin 2FA (TOTP) — 선택적

---

# 구현 순서 (Codex 작업 순서)

## Step 1: DB 마이그레이션
모든 ALTER TABLE, CREATE TABLE 실행

## Step 2: 시드 데이터 삽입
providers → countries → ai_tools (500+) → ai_tool_news → lab_templates → plans → credit_packages

## Step 3: Model/DAO 생성
Provider, Country, AIToolNews, Benchmark, LabSession, LabTemplate, Plan, CreditPackage 모델 + DAO

## Step 4: 서블릿 생성 및 web.xml 업데이트
AIProxyServlet, PaymentServlet, SubscriptionServlet, LabSessionServlet, UserAPIKeyServlet, NewsServlet, RankingServlet

## Step 5: 프론트엔드 — Navigator 개편
navigator.jsp + navigator.js + navigator.css (서버사이드 필터링, 3뷰모드, 사이드바)

## Step 6: 프론트엔드 — 도구 상세/비교/순위
detail.jsp, compare.jsp, rankings.jsp + charts.js

## Step 7: 프론트엔드 — 뉴스 페이지
news/index.jsp, news/detail.jsp

## Step 8: 프론트엔드 — 실습 랩
playground.jsp + playground.js, lab project 개편

## Step 9: 프론트엔드 — 결제/요금제
pricing.jsp 개편 + payment.js + checkout 개편

## Step 10: 마이페이지 개편
mypage.jsp 탭 구조 + API 키 관리

## Step 11: 홈페이지 개편
home.jsp 섹션별 동적 데이터

## Step 12: 관리자 대시보드
dashboard.jsp 차트 + analytics 페이지

## Step 13: 컴파일 & 배포
```bash
cd /var/lib/tomcat9/webapps/ROOT
javac -cp "WEB-INF/lib/*:/usr/share/tomcat9/lib/*" \
  -d WEB-INF/classes \
  $(find WEB-INF/src -name "*.java")
sudo systemctl restart tomcat9
```

---

# 파일 생성/수정 목록

## 새로 생성 (약 45개)

### Models (6개)
```
WEB-INF/src/model/Provider.java
WEB-INF/src/model/AIToolNews.java
WEB-INF/src/model/Benchmark.java
WEB-INF/src/model/Country.java
WEB-INF/src/model/LabSession.java
WEB-INF/src/model/LabTemplate.java
WEB-INF/src/model/Plan.java
WEB-INF/src/model/CreditPackage.java
```

### DAOs (8개)
```
WEB-INF/src/dao/ProviderDAO.java
WEB-INF/src/dao/AIToolNewsDAO.java
WEB-INF/src/dao/BenchmarkDAO.java
WEB-INF/src/dao/CountryDAO.java
WEB-INF/src/dao/LabSessionDAO.java
WEB-INF/src/dao/LabTemplateDAO.java
WEB-INF/src/dao/PlanDAO.java
WEB-INF/src/dao/CreditPackageDAO.java
```

### Servlets (5개)
```
WEB-INF/src/servlet/AIProxyServlet.java
WEB-INF/src/servlet/PaymentServlet.java
WEB-INF/src/servlet/SubscriptionServlet.java
WEB-INF/src/servlet/LabSessionServlet.java
WEB-INF/src/servlet/RankingServlet.java
WEB-INF/src/servlet/NewsServlet.java
WEB-INF/src/servlet/UserAPIKeyServlet.java
```

### Utils (1개)
```
WEB-INF/src/util/EncryptionUtil.java
```

### JSP Pages (12개)
```
AI/user/tools/rankings.jsp
AI/user/tools/compare.jsp
AI/user/news/index.jsp
AI/user/news/detail.jsp
AI/user/lab/playground.jsp
AI/user/lab/history.jsp
AI/admin/analytics/index.jsp
AI/admin/analytics/users.jsp
AI/admin/analytics/credits.jsp
AI/admin/analytics/revenue.jsp
AI/admin/analytics/tools.jsp
AI/admin/tools/news.jsp
```

### JavaScript (5개)
```
AI/assets/js/charts.js
AI/assets/js/playground.js
AI/assets/js/payment.js
AI/assets/js/rankings.js
AI/assets/js/lab-project.js
```

### CSS (2개)
```
AI/assets/css/playground.css
AI/assets/css/rankings.css
```

### Database (3개)
```
AI/database/phase1_schema.sql
AI/database/phase1_seed_providers.sql
AI/database/phase1_seed_tools.sql
AI/database/phase1_seed_news.sql
AI/database/phase2_lab_templates.sql
AI/database/phase4_plans.sql
```

## 수정 (약 15개)
```
WEB-INF/web.xml                    — 새 서블릿 매핑 추가
WEB-INF/src/servlet/AIToolServlet.java — 순위/필터 엔드포인트 추가
WEB-INF/src/dao/AIToolDAO.java     — 순위/국가/회사별 메서드 추가
WEB-INF/src/dao/CreditDAO.java     — 크레딧 패키지 메서드 추가
AI/user/tools/navigator.jsp        — 전면 개편
AI/user/tools/detail.jsp           — 탭 구조, 차트 추가
AI/user/home.jsp                   — 섹션별 동적 데이터
AI/user/pricing.jsp                — 4단 요금제 + 크레딧 패키지
AI/user/mypage.jsp                 — 탭 구조 개편
AI/user/lab/index.jsp              — 실습 허브 개편
AI/user/lab/session.jsp            — Playground 연동
AI/admin/dashboard.jsp             — Chart.js 통계
AI/partials/header.jsp             — 네비게이션 메뉴 추가
AI/assets/js/navigator.js          — 서버사이드 필터링 전환
AI/assets/css/navigator.css        — 사이드바+3뷰 모드
AI/_common.jsp                     — 새 유틸 함수 추가
```

---

# 핵심 원칙

1. **기존 스택 유지**: Maven/Gradle 도입 없이 javac + JSP 유지
2. **import 경로**: 모든 새 DAO는 `import db.DBConnect;` 사용
3. **리소스 관리**: 모든 DB 작업은 try-with-resources 패턴
4. **보안**: PreparedStatement 필수, XSS 이스케이프, CSRF 토큰
5. **다크 테마**: 배경 `#0a0a0a`, 기존 CSS 변수 활용
6. **한국어 UI**: 모든 사용자 facing 텍스트는 한국어
7. **CDN**: Chart.js, Marked.js, Prism.js는 CDN으로 로드
8. **반응형**: 모바일 768px 이하 대응
9. **컴파일 명령**: `javac -cp "WEB-INF/lib/*:/usr/share/tomcat9/lib/*" -d WEB-INF/classes $(find WEB-INF/src -name "*.java")`
10. **배포**: `sudo systemctl restart tomcat9`
