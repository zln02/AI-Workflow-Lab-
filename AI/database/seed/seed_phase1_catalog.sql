-- Phase 1 starter catalog seed
-- Safe to re-run: insert-if-missing semantics are used.

INSERT INTO countries (code, name_ko, name_en, flag_emoji, region, display_order) VALUES
('US', '미국', 'United States', '🇺🇸', 'North America', 1),
('KR', '대한민국', 'South Korea', '🇰🇷', 'Asia', 2),
('CN', '중국', 'China', '🇨🇳', 'Asia', 3),
('FR', '프랑스', 'France', '🇫🇷', 'Europe', 4),
('DE', '독일', 'Germany', '🇩🇪', 'Europe', 5),
('JP', '일본', 'Japan', '🇯🇵', 'Asia', 6),
('CA', '캐나다', 'Canada', '🇨🇦', 'North America', 7),
('IL', '이스라엘', 'Israel', '🇮🇱', 'Middle East', 8),
('IN', '인도', 'India', '🇮🇳', 'Asia', 9),
('GB', '영국', 'United Kingdom', '🇬🇧', 'Europe', 10)
ON DUPLICATE KEY UPDATE
name_ko = VALUES(name_ko),
name_en = VALUES(name_en),
flag_emoji = VALUES(flag_emoji),
region = VALUES(region),
display_order = VALUES(display_order);

CREATE TEMPORARY TABLE tmp_phase1_providers (
    provider_name VARCHAR(255),
    website VARCHAR(255),
    country VARCHAR(100),
    logo_url VARCHAR(500),
    description TEXT,
    headquarters_country VARCHAR(100),
    founded_year INT,
    employee_count VARCHAR(50),
    funding_total VARCHAR(100),
    is_public TINYINT(1),
    stock_ticker VARCHAR(20),
    specialization VARCHAR(255),
    api_docs_url VARCHAR(500),
    status VARCHAR(20)
);

INSERT INTO tmp_phase1_providers VALUES
('OpenAI', 'https://openai.com', 'US', NULL, '범용 생성형 AI 모델과 제품을 제공하는 미국 AI 회사', 'US', 2015, '1,000+', '$10B+', 0, NULL, '종합 AI 어시스턴트, 멀티모달 모델', 'https://platform.openai.com/docs', 'active'),
('Anthropic', 'https://www.anthropic.com', 'US', NULL, 'Claude 계열 모델을 개발하는 안전성 중심 AI 회사', 'US', 2021, '1,000+', '$7B+', 0, NULL, '대화형 AI, 안전한 LLM', 'https://docs.anthropic.com', 'active'),
('Google DeepMind', 'https://deepmind.google', 'US', NULL, 'Gemini와 연구 중심 AI 모델을 운영하는 Google 조직', 'US', 2010, '10,000+', 'Alphabet', 1, 'GOOGL', '멀티모달 AI, 리서치', 'https://ai.google.dev', 'active'),
('Microsoft', 'https://www.microsoft.com', 'US', NULL, 'Copilot 제품군과 Azure AI 생태계를 운영', 'US', 1975, '100,000+', 'Public', 1, 'MSFT', '생산성 AI, 클라우드', 'https://learn.microsoft.com/azure/ai-services/', 'active'),
('xAI', 'https://x.ai', 'US', NULL, 'Grok 계열 모델 제공', 'US', 2023, '100+', 'Private', 0, NULL, '대화형 AI', NULL, 'active'),
('Perplexity', 'https://www.perplexity.ai', 'US', NULL, '검색 중심 AI 어시스턴트', 'US', 2022, '100+', 'Private', 0, NULL, 'AI 검색, 리서치', NULL, 'active'),
('Midjourney', 'https://www.midjourney.com', 'US', NULL, '텍스트 기반 이미지 생성 서비스', 'US', 2022, '50+', 'Private', 0, NULL, '이미지 생성', NULL, 'active'),
('Runway', 'https://runwayml.com', 'US', NULL, '영상 생성 및 편집 AI 플랫폼', 'US', 2018, '100+', '$200M+', 0, NULL, '영상 생성', 'https://docs.dev.runwayml.com', 'active'),
('ElevenLabs', 'https://elevenlabs.io', 'US', NULL, '보이스 생성과 더빙 중심 AI 오디오 회사', 'US', 2022, '100+', '$100M+', 0, NULL, '음성 합성', 'https://elevenlabs.io/docs', 'active'),
('Adobe', 'https://www.adobe.com', 'US', NULL, 'Firefly 중심의 크리에이티브 AI 제품군 제공', 'US', 1982, '10,000+', 'Public', 1, 'ADBE', '디자인, 이미지 생성', 'https://developer.adobe.com/firefly-services/docs/', 'active'),
('Notion', 'https://www.notion.so', 'US', NULL, '협업 문서와 AI 작성 기능 제공', 'US', 2013, '1,000+', 'Private', 0, NULL, '문서/글쓰기', NULL, 'active'),
('GitHub', 'https://github.com', 'US', NULL, 'Copilot을 포함한 개발자 플랫폼 제공', 'US', 2008, '5,000+', 'Microsoft', 0, NULL, '코드 생성', 'https://docs.github.com/copilot', 'active'),
('Cursor', 'https://cursor.com', 'US', NULL, 'AI 코딩 에디터', 'US', 2023, '100+', 'Private', 0, NULL, '코드 생성', NULL, 'active'),
('Hugging Face', 'https://huggingface.co', 'US', NULL, '오픈소스 모델 허브와 추론 플랫폼', 'US', 2016, '500+', '$200M+', 0, NULL, '오픈소스 AI', 'https://huggingface.co/docs', 'active'),
('Meta AI', 'https://ai.meta.com', 'US', NULL, 'Llama 계열 오픈 모델 제공', 'US', 2004, '10,000+', 'Public', 1, 'META', '오픈 모델, 리서치', 'https://ai.meta.com/llama/', 'active'),
('Mistral AI', 'https://mistral.ai', 'FR', NULL, '유럽 기반 오픈 가중치 LLM 회사', 'FR', 2023, '100+', '$500M+', 0, NULL, 'LLM, 오픈 모델', 'https://docs.mistral.ai', 'active'),
('DeepL', 'https://www.deepl.com', 'DE', NULL, '번역 특화 AI 서비스', 'DE', 2017, '1,000+', 'Private', 0, NULL, '번역/로컬라이제이션', 'https://developers.deepl.com/docs', 'active'),
('Baidu', 'https://www.baidu.com', 'CN', NULL, 'ERNIE 계열 모델과 검색 AI 서비스 운영', 'CN', 2000, '10,000+', 'Public', 1, 'BIDU', '검색, 종합 AI', NULL, 'active'),
('Alibaba', 'https://www.alibabagroup.com', 'CN', NULL, 'Tongyi Qianwen 계열 모델 운영', 'CN', 1999, '100,000+', 'Public', 1, 'BABA', '클라우드 AI', NULL, 'active'),
('Tencent', 'https://www.tencent.com', 'CN', NULL, 'Hunyuan 계열 모델 운영', 'CN', 1998, '100,000+', 'Public', 1, 'TCEHY', '멀티모달 AI', NULL, 'active'),
('ByteDance', 'https://www.bytedance.com', 'CN', NULL, 'Doubao 등 AI 제품군 운영', 'CN', 2012, '100,000+', 'Private', 0, NULL, '소비자 AI', NULL, 'active'),
('DeepSeek', 'https://www.deepseek.com', 'CN', NULL, '고성능 추론 모델 제공', 'CN', 2023, '100+', 'Private', 0, NULL, 'LLM, 추론', NULL, 'active'),
('Naver', 'https://www.navercorp.com', 'KR', NULL, 'HyperCLOVA X 기반 AI 서비스 제공', 'KR', 1999, '10,000+', 'Public', 1, '035420', '종합 AI, 검색', NULL, 'active'),
('Kakao Brain', 'https://kakaobrain.com', 'KR', NULL, '한국어 중심 생성형 AI 연구 및 서비스', 'KR', 2016, '100+', 'Kakao', 0, NULL, 'LLM, 이미지 생성', NULL, 'active'),
('LG AI Research', 'https://www.lgresearch.ai', 'KR', NULL, 'EXAONE 계열 모델 제공', 'KR', 2020, '500+', 'LG', 0, NULL, '엔터프라이즈 AI', NULL, 'active'),
('Upstage', 'https://www.upstage.ai', 'KR', NULL, 'Solar 계열 모델과 문서 AI 제공', 'KR', 2020, '100+', '$100M+', 0, NULL, '문서 AI, LLM', 'https://developers.upstage.ai', 'active'),
('Twelve Labs', 'https://www.twelvelabs.io', 'KR', NULL, '영상 이해 모델과 API 제공', 'KR', 2021, '100+', '$100M+', 0, NULL, '비디오 AI', 'https://docs.twelvelabs.io', 'active'),
('Cohere', 'https://cohere.com', 'CA', NULL, '엔터프라이즈 텍스트 생성 및 임베딩 서비스', 'CA', 2019, '500+', '$400M+', 0, NULL, '엔터프라이즈 LLM', 'https://docs.cohere.com', 'active'),
('AI21 Labs', 'https://www.ai21.com', 'IL', NULL, '언어 모델 및 작성 도구 제공', 'IL', 2017, '100+', '$200M+', 0, NULL, '텍스트 생성', 'https://docs.ai21.com', 'active'),
('Sarvam AI', 'https://www.sarvam.ai', 'IN', NULL, '인도 언어 중심 생성형 AI 회사', 'IN', 2023, '100+', 'Private', 0, NULL, '지역 언어 AI', NULL, 'active');

INSERT INTO providers (
    provider_name, website, country, logo_url, description, headquarters_country,
    founded_year, employee_count, funding_total, is_public, stock_ticker,
    specialization, api_docs_url, status
)
SELECT
    t.provider_name, t.website, t.country, t.logo_url, t.description, t.headquarters_country,
    t.founded_year, t.employee_count, t.funding_total, t.is_public, t.stock_ticker,
    t.specialization, t.api_docs_url, t.status
FROM tmp_phase1_providers t
LEFT JOIN providers p
  ON p.provider_name = t.provider_name
WHERE p.id IS NULL;

DROP TEMPORARY TABLE tmp_phase1_providers;

CREATE TEMPORARY TABLE tmp_phase1_tools (
    tool_name VARCHAR(255),
    provider_name VARCHAR(100),
    provider_country VARCHAR(100),
    category VARCHAR(50),
    subcategory VARCHAR(50),
    description TEXT,
    purpose_summary VARCHAR(500),
    pricing_model VARCHAR(50),
    api_available TINYINT(1),
    free_tier_available TINYINT(1),
    website_url VARCHAR(500),
    docs_url VARCHAR(500),
    playground_url VARCHAR(500),
    input_modalities VARCHAR(200),
    output_modalities VARCHAR(200),
    difficulty_level VARCHAR(20),
    tags JSON,
    supported_platforms JSON,
    monthly_active_users BIGINT,
    global_rank INT,
    category_rank INT,
    trend_score DECIMAL(5,2),
    growth_rate DECIMAL(5,2),
    enterprise_ready TINYINT(1),
    open_source TINYINT(1),
    github_url VARCHAR(500),
    github_stars INT,
    monthly_visits BIGINT
);

INSERT INTO tmp_phase1_tools VALUES
('ChatGPT', 'OpenAI', 'US', '종합 AI 어시스턴트', '대화형 AI', '대표적인 멀티모달 AI 어시스턴트', '질문 응답, 문서 작성, 코딩 보조', 'Freemium', 1, 1, 'https://chatgpt.com', 'https://platform.openai.com/docs', 'https://chatgpt.com', 'text,image,audio', 'text,image,audio', 'Beginner', JSON_ARRAY('LLM','멀티모달','생산성'), JSON_ARRAY('web','ios','android','desktop','api'), 400000000, 1, 1, 98.50, 12.40, 1, 0, NULL, NULL, 5000000000),
('Claude', 'Anthropic', 'US', '종합 AI 어시스턴트', '대화형 AI', '긴 문맥 처리에 강한 AI 어시스턴트', '문서 분석, 글쓰기, 코딩, 브레인스토밍', 'Freemium', 1, 1, 'https://claude.ai', 'https://docs.anthropic.com', 'https://claude.ai', 'text,image', 'text', 'Beginner', JSON_ARRAY('장문 처리','안전성','코딩'), JSON_ARRAY('web','ios','android','api'), 180000000, 2, 2, 96.20, 11.80, 1, 0, NULL, NULL, 900000000),
('Gemini', 'Google DeepMind', 'US', '종합 AI 어시스턴트', '대화형 AI', 'Google 생태계와 연결된 멀티모달 AI', '검색, 문서 요약, 생산성 보조', 'Freemium', 1, 1, 'https://gemini.google.com', 'https://ai.google.dev', 'https://gemini.google.com', 'text,image,audio,video', 'text,image', 'Beginner', JSON_ARRAY('Google 연동','멀티모달'), JSON_ARRAY('web','ios','android','api'), 150000000, 3, 3, 93.40, 9.90, 1, 0, NULL, NULL, 1200000000),
('Perplexity', 'Perplexity', 'US', '리서치', 'AI 검색', '출처 기반 답변에 강한 검색형 AI', '리서치, 웹 검색, 보고서 초안', 'Freemium', 1, 1, 'https://www.perplexity.ai', NULL, 'https://www.perplexity.ai', 'text', 'text', 'Beginner', JSON_ARRAY('검색','출처 인용'), JSON_ARRAY('web','ios','android'), 100000000, 6, 1, 89.30, 14.10, 1, 0, NULL, NULL, 650000000),
('Grok', 'xAI', 'US', '종합 AI 어시스턴트', '대화형 AI', '실시간성 강조형 대화 모델', '실시간 질의응답, 브레인스토밍', 'Paid', 1, 0, 'https://grok.com', NULL, 'https://grok.com', 'text,image', 'text,image', 'Beginner', JSON_ARRAY('실시간성','소셜 데이터'), JSON_ARRAY('web','ios','android'), 35000000, 10, 5, 82.10, 8.40, 0, 0, NULL, NULL, 180000000),
('GitHub Copilot', 'GitHub', 'US', '코드 생성', '코딩 보조', 'IDE 기반 코드 자동완성 및 채팅', '코드 생성, 리뷰 보조, 테스트 작성', 'Paid', 1, 0, 'https://github.com/features/copilot', 'https://docs.github.com/copilot', NULL, 'text,code', 'text,code', 'Intermediate', JSON_ARRAY('IDE','코딩','개발자'), JSON_ARRAY('desktop','web'), 20000000, 1, 1, 95.00, 10.20, 1, 0, NULL, NULL, 140000000),
('Cursor', 'Cursor', 'US', '코드 생성', 'AI 에디터', 'AI 네이티브 코드 에디터', '코드 리팩터링, 에이전트 편집, 탐색', 'Freemium', 1, 1, 'https://cursor.com', NULL, NULL, 'text,code', 'text,code', 'Intermediate', JSON_ARRAY('에이전트','에디터'), JSON_ARRAY('desktop'), 8000000, 2, 2, 92.80, 22.60, 1, 0, NULL, NULL, 45000000),
('Replit AI', 'Replit', 'US', '코드 생성', '클라우드 개발', '브라우저 기반 AI 코딩 도우미', '빠른 프로토타이핑, 학습용 개발', 'Freemium', 1, 1, 'https://replit.com', NULL, NULL, 'text,code', 'text,code', 'Beginner', JSON_ARRAY('브라우저 IDE','협업'), JSON_ARRAY('web'), 4000000, 5, 4, 79.20, 7.50, 0, 0, NULL, NULL, 22000000),
('Midjourney', 'Midjourney', 'US', '이미지 생성', '텍스트 투 이미지', '고품질 스타일 이미지 생성 도구', '컨셉 아트, 마케팅 이미지, 브랜딩', 'Paid', 0, 0, 'https://www.midjourney.com', NULL, NULL, 'text,image', 'image', 'Beginner', JSON_ARRAY('아트','이미지 생성'), JSON_ARRAY('web'), 18000000, 1, 1, 94.70, 6.10, 0, 0, NULL, NULL, 110000000),
('DALL-E 3', 'OpenAI', 'US', '이미지 생성', '텍스트 투 이미지', 'OpenAI의 이미지 생성 모델', '마케팅 시안, 콘텐츠 이미지 생성', 'Paid', 1, 0, 'https://openai.com', 'https://platform.openai.com/docs', NULL, 'text', 'image', 'Beginner', JSON_ARRAY('이미지 생성','API'), JSON_ARRAY('web','api'), 30000000, 2, 2, 90.10, 5.60, 1, 0, NULL, NULL, 80000000),
('Stable Diffusion', 'Hugging Face', 'US', '이미지 생성', '오픈소스 이미지', '오픈소스 이미지 생성 생태계의 표준급 모델', '커스텀 이미지 생성, 로컬 배포', 'Free', 1, 1, 'https://huggingface.co', 'https://huggingface.co/docs', NULL, 'text,image', 'image', 'Advanced', JSON_ARRAY('오픈소스','커스터마이즈'), JSON_ARRAY('web','desktop','api'), 12000000, 3, 3, 88.40, 4.80, 1, 1, 'https://github.com/CompVis/stable-diffusion', 71000, 60000000),
('Adobe Firefly', 'Adobe', 'US', '디자인', '크리에이티브 AI', '디자인 워크플로우에 통합된 생성형 AI', '브랜드 자산, 마케팅 디자인', 'Paid', 1, 0, 'https://www.adobe.com/products/firefly.html', 'https://developer.adobe.com/firefly-services/docs/', NULL, 'text,image', 'image', 'Beginner', JSON_ARRAY('디자인','브랜드 세이프'), JSON_ARRAY('web','desktop','api'), 12000000, 4, 1, 87.60, 4.20, 1, 0, NULL, NULL, 95000000),
('Runway Gen-3', 'Runway', 'US', '영상 생성', '텍스트 투 비디오', '상업 수준의 AI 영상 생성', '광고 영상, 콘셉트 영상', 'Paid', 1, 0, 'https://runwayml.com', 'https://docs.dev.runwayml.com', NULL, 'text,image,video', 'video', 'Intermediate', JSON_ARRAY('영상 생성','편집'), JSON_ARRAY('web','api'), 5000000, 1, 1, 91.10, 9.30, 1, 0, NULL, NULL, 30000000),
('Sora', 'OpenAI', 'US', '영상 생성', '텍스트 투 비디오', 'OpenAI의 장면 생성형 영상 모델', '스토리보드, 콘셉트 영상 제작', 'Paid', 1, 0, 'https://openai.com/sora', 'https://platform.openai.com/docs', NULL, 'text,image,video', 'video', 'Intermediate', JSON_ARRAY('영상 생성','시뮬레이션'), JSON_ARRAY('web'), 7000000, 2, 2, 90.90, 15.00, 1, 0, NULL, NULL, 40000000),
('Pika', 'Pika Labs', 'US', '영상 생성', '텍스트 투 비디오', '소셜 친화형 짧은 영상 생성', '짧은 광고, 소셜 콘텐츠', 'Freemium', 1, 1, 'https://pika.art', NULL, NULL, 'text,image,video', 'video', 'Beginner', JSON_ARRAY('짧은 영상','콘텐츠 제작'), JSON_ARRAY('web'), 4000000, 5, 4, 78.40, 8.20, 0, 0, NULL, NULL, 18000000),
('ElevenLabs', 'ElevenLabs', 'US', '음성/오디오', '음성 합성', '고품질 TTS와 음성 복제 서비스', '더빙, 오디오북, 캐릭터 보이스', 'Freemium', 1, 1, 'https://elevenlabs.io', 'https://elevenlabs.io/docs', NULL, 'text,audio', 'audio', 'Beginner', JSON_ARRAY('TTS','보이스 클론'), JSON_ARRAY('web','api'), 15000000, 1, 1, 93.10, 10.40, 1, 0, NULL, NULL, 75000000),
('Whisper', 'OpenAI', 'US', '음성/오디오', '음성 인식', '오픈소스 음성 인식 모델', '회의록 전사, 자막 생성', 'Free', 1, 1, 'https://openai.com/research/whisper', 'https://platform.openai.com/docs', NULL, 'audio', 'text', 'Intermediate', JSON_ARRAY('STT','오픈소스'), JSON_ARRAY('api','desktop'), 10000000, 2, 2, 87.20, 3.30, 1, 1, 'https://github.com/openai/whisper', 78000, 50000000),
('Suno', 'Suno', 'US', '음악 생성', '텍스트 투 뮤직', '프롬프트 기반 음악 생성 서비스', '데모 음악, 콘텐츠 배경음', 'Freemium', 1, 1, 'https://suno.com', NULL, NULL, 'text,audio', 'audio', 'Beginner', JSON_ARRAY('음악 생성','보컬'), JSON_ARRAY('web'), 10000000, 1, 1, 89.40, 11.60, 0, 0, NULL, NULL, 50000000),
('Udio', 'Udio', 'US', '음악 생성', '텍스트 투 뮤직', '보컬 중심 AI 음악 생성', '음악 아이디어, 짧은 음원 제작', 'Freemium', 1, 1, 'https://www.udio.com', NULL, NULL, 'text,audio', 'audio', 'Beginner', JSON_ARRAY('음악 생성','보컬'), JSON_ARRAY('web'), 5000000, 2, 2, 84.30, 7.70, 0, 0, NULL, NULL, 23000000),
('Jasper', 'Jasper', 'US', '문서/글쓰기', '마케팅 글쓰기', '브랜드 톤 중심 AI 글쓰기 도구', '카피라이팅, 캠페인 초안', 'Paid', 1, 0, 'https://www.jasper.ai', NULL, NULL, 'text', 'text', 'Beginner', JSON_ARRAY('카피라이팅','마케팅'), JSON_ARRAY('web'), 3000000, 3, 1, 81.10, 2.90, 1, 0, NULL, NULL, 16000000),
('Notion AI', 'Notion', 'US', '문서/글쓰기', '문서 작성', '문서 요약과 작성 보조 기능', '회의록 정리, 문서 초안', 'Paid', 1, 0, 'https://www.notion.so/product/ai', NULL, NULL, 'text', 'text', 'Beginner', JSON_ARRAY('문서','협업'), JSON_ARRAY('web','desktop','ios','android'), 35000000, 1, 1, 90.40, 6.00, 1, 0, NULL, NULL, 170000000),
('Grammarly', 'Grammarly', 'US', '문서/글쓰기', '교정', '문법 교정과 작성 보조 도구', '이메일, 보고서, 교정', 'Freemium', 1, 1, 'https://www.grammarly.com', NULL, NULL, 'text', 'text', 'Beginner', JSON_ARRAY('교정','영문 글쓰기'), JSON_ARRAY('web','desktop','ios','android'), 30000000, 2, 2, 88.00, 3.50, 1, 0, NULL, NULL, 150000000),
('Julius AI', 'Julius AI', 'US', '데이터 분석', '분석 어시스턴트', '자연어 기반 데이터 분석 도구', 'CSV 분석, 차트 생성', 'Freemium', 1, 1, 'https://julius.ai', NULL, NULL, 'text,file', 'text,image', 'Beginner', JSON_ARRAY('데이터 분석','차트'), JSON_ARRAY('web'), 1200000, 1, 1, 76.90, 8.80, 0, 0, NULL, NULL, 7000000),
('Hex', 'Hex', 'US', '데이터 분석', '협업 분석', '노트북과 BI를 결합한 데이터 워크스페이스', 'SQL, Python, 대시보드', 'Paid', 1, 0, 'https://hex.tech', NULL, NULL, 'text,code,file', 'text,image,code', 'Intermediate', JSON_ARRAY('BI','협업'), JSON_ARRAY('web'), 600000, 3, 2, 72.40, 4.40, 1, 0, NULL, NULL, 2500000),
('Elicit', 'Ought', 'US', '리서치', '논문 리서치', '논문 검색과 요약 중심 연구 보조 도구', '논문 탐색, 문헌 검토', 'Freemium', 1, 1, 'https://elicit.com', NULL, NULL, 'text', 'text', 'Beginner', JSON_ARRAY('논문','리서치'), JSON_ARRAY('web'), 1500000, 2, 2, 80.20, 5.10, 0, 0, NULL, NULL, 8000000),
('DeepL', 'DeepL', 'DE', '번역/로컬라이제이션', '번역', '자연스러운 번역 품질로 알려진 AI 번역 서비스', '문서 번역, 비즈니스 번역', 'Freemium', 1, 1, 'https://www.deepl.com', 'https://developers.deepl.com/docs', NULL, 'text,document', 'text', 'Beginner', JSON_ARRAY('번역','문서'), JSON_ARRAY('web','desktop','ios','android','api'), 20000000, 1, 1, 92.00, 4.00, 1, 0, NULL, NULL, 120000000),
('Papago', 'Naver', 'KR', '번역/로컬라이제이션', '번역', '한국어에 강한 번역 서비스', '웹 번역, 여행 번역', 'Free', 1, 1, 'https://papago.naver.com', NULL, NULL, 'text,image,audio', 'text,audio', 'Beginner', JSON_ARRAY('번역','한국어'), JSON_ARRAY('web','ios','android'), 15000000, 3, 2, 84.60, 2.60, 0, 0, NULL, NULL, 70000000),
('Canva AI', 'Canva', 'US', '디자인', '디자인 자동화', '프레젠테이션과 소셜 디자인 자동 생성', '마케팅 디자인, 슬라이드 제작', 'Freemium', 1, 1, 'https://www.canva.com/ai-image-generator/', NULL, NULL, 'text,image', 'image,text', 'Beginner', JSON_ARRAY('디자인','프레젠테이션'), JSON_ARRAY('web','ios','android'), 60000000, 2, 2, 91.30, 5.20, 1, 0, NULL, NULL, 400000000),
('Khanmigo', 'Khan Academy', 'US', '교육', '튜터링', '교육용 AI 튜터', '학습 보조, 과제 피드백', 'Paid', 1, 0, 'https://www.khanacademy.org/khan-labs', NULL, NULL, 'text', 'text', 'Beginner', JSON_ARRAY('교육','튜터'), JSON_ARRAY('web'), 800000, 2, 1, 70.50, 3.80, 0, 0, NULL, NULL, 3200000),
('Harvey AI', 'Harvey AI', 'US', '법률', '리걸 AI', '법률 전문 워크플로우 지원 도구', '계약서 검토, 리서치', 'Paid', 1, 0, 'https://www.harvey.ai', NULL, NULL, 'text,document', 'text', 'Advanced', JSON_ARRAY('법률','전문가용'), JSON_ARRAY('web'), 400000, 1, 1, 74.20, 6.10, 1, 0, NULL, NULL, 1800000),
('Lunit INSIGHT', 'Lunit', 'KR', '의료/헬스케어', '의료 영상', '의료 영상 판독 지원 AI', '폐 질환, 유방암 진단 보조', 'Paid', 1, 0, 'https://www.lunit.io', NULL, NULL, 'image', 'text,image', 'Advanced', JSON_ARRAY('의료','영상 분석'), JSON_ARRAY('web'), 100000, 1, 1, 68.20, 5.50, 1, 0, NULL, NULL, 400000),
('CrowdStrike Falcon AI', 'CrowdStrike', 'US', '사이버보안', '보안 분석', '보안 위협 분석과 대응 보조', '보안 운영, 위협 탐지', 'Paid', 1, 0, 'https://www.crowdstrike.com', NULL, NULL, 'text,log', 'text', 'Advanced', JSON_ARRAY('보안','SOC'), JSON_ARRAY('web'), 500000, 2, 1, 71.80, 4.20, 1, 0, NULL, NULL, 2100000),
('Meshy', 'Meshy', 'US', '3D/공간컴퓨팅', '3D 생성', '텍스트 기반 3D 자산 생성', '게임 자산, 3D 프로토타이핑', 'Freemium', 1, 1, 'https://www.meshy.ai', NULL, NULL, 'text,image', '3d', 'Intermediate', JSON_ARRAY('3D','게임'), JSON_ARRAY('web'), 700000, 1, 1, 73.40, 7.00, 0, 0, NULL, NULL, 3000000),
('Figure AI', 'Figure AI', 'US', '로보틱스', '휴머노이드', '범용 휴머노이드 로봇 회사', '물류, 제조 자동화', 'Paid', 0, 0, 'https://www.figure.ai', NULL, NULL, 'text,vision', 'action', 'Advanced', JSON_ARRAY('로보틱스','휴머노이드'), JSON_ARRAY('web'), 150000, 1, 1, 67.50, 9.20, 1, 0, NULL, NULL, 900000),
('Inworld AI', 'Inworld AI', 'US', '게임개발', 'NPC AI', '게임용 AI 캐릭터 플랫폼', 'NPC 대화, 인터랙티브 스토리', 'Paid', 1, 0, 'https://inworld.ai', NULL, NULL, 'text,audio', 'text,audio', 'Intermediate', JSON_ARRAY('게임','NPC'), JSON_ARRAY('web','api'), 300000, 1, 1, 69.80, 5.80, 1, 0, NULL, NULL, 1200000),
('HyperCLOVA X', 'Naver', 'KR', '종합 AI 어시스턴트', '한국어 LLM', '한국어 중심 범용 LLM 서비스', '한국어 질의응답, 문서 요약', 'Paid', 1, 0, 'https://clova-x.naver.com', NULL, NULL, 'text,image', 'text', 'Beginner', JSON_ARRAY('한국어','LLM'), JSON_ARRAY('web'), 8000000, 12, 6, 78.90, 4.70, 1, 0, NULL, NULL, 25000000),
('ERNIE Bot', 'Baidu', 'CN', '종합 AI 어시스턴트', '중국어 LLM', '중국 시장 중심 범용 AI 어시스턴트', '중국어 질의응답, 문서 작성', 'Freemium', 1, 1, 'https://yiyan.baidu.com', NULL, NULL, 'text,image', 'text', 'Beginner', JSON_ARRAY('중국어','LLM'), JSON_ARRAY('web'), 60000000, 8, 4, 83.20, 6.30, 1, 0, NULL, NULL, 210000000),
('Tongyi Qianwen', 'Alibaba', 'CN', '종합 AI 어시스턴트', '중국어 LLM', 'Alibaba 생태계 기반 멀티모달 AI', '업무 자동화, 생성형 AI', 'Freemium', 1, 1, 'https://tongyi.aliyun.com', NULL, NULL, 'text,image,audio', 'text,image', 'Beginner', JSON_ARRAY('중국어','클라우드 AI'), JSON_ARRAY('web','api'), 50000000, 9, 5, 82.60, 6.80, 1, 0, NULL, NULL, 190000000),
('DeepSeek Chat', 'DeepSeek', 'CN', '종합 AI 어시스턴트', '추론형 LLM', '추론 성능으로 주목받는 대화형 AI', '코딩, 리서치, 일반 질의응답', 'Freemium', 1, 1, 'https://chat.deepseek.com', NULL, NULL, 'text,image', 'text', 'Beginner', JSON_ARRAY('추론','코딩'), JSON_ARRAY('web','api'), 45000000, 7, 4, 88.80, 18.40, 1, 0, NULL, NULL, 240000000),
('Le Chat', 'Mistral AI', 'FR', '종합 AI 어시스턴트', '유럽 LLM', 'Mistral의 범용 AI 챗 서비스', '문서 작성, 번역, 코딩', 'Freemium', 1, 1, 'https://chat.mistral.ai', 'https://docs.mistral.ai', NULL, 'text,image', 'text', 'Beginner', JSON_ARRAY('유럽 AI','오픈 가중치'), JSON_ARRAY('web','api'), 12000000, 11, 7, 81.40, 7.90, 1, 0, NULL, NULL, 40000000),
('Solar', 'Upstage', 'KR', '종합 AI 어시스턴트', '한국어 LLM', 'Upstage의 문서 친화형 LLM', '문서 처리, 요약, 업무 자동화', 'Paid', 1, 0, 'https://www.upstage.ai/products/solar-pro', 'https://developers.upstage.ai', NULL, 'text,document', 'text', 'Intermediate', JSON_ARRAY('한국어','문서 AI'), JSON_ARRAY('api'), 900000, 15, 8, 72.80, 5.70, 1, 0, NULL, NULL, 2000000);

INSERT INTO ai_tools (
    tool_name, provider_name, provider_country, category, subcategory, description, purpose_summary,
    pricing_model, api_available, free_tier_available, website_url, docs_url, playground_url,
    input_modalities, output_modalities, difficulty_level, tags, supported_platforms,
    monthly_active_users, global_rank, category_rank, trend_score, growth_rate,
    enterprise_ready, open_source, github_url, github_stars, monthly_visits
)
SELECT
    t.tool_name, t.provider_name, t.provider_country, t.category, t.subcategory, t.description, t.purpose_summary,
    t.pricing_model, t.api_available, t.free_tier_available, t.website_url, t.docs_url, t.playground_url,
    t.input_modalities, t.output_modalities, t.difficulty_level, t.tags, t.supported_platforms,
    t.monthly_active_users, t.global_rank, t.category_rank, t.trend_score, t.growth_rate,
    t.enterprise_ready, t.open_source, t.github_url, t.github_stars, t.monthly_visits
FROM tmp_phase1_tools t
LEFT JOIN ai_tools a
  ON a.tool_name = t.tool_name
 AND a.provider_name = t.provider_name
WHERE a.id IS NULL;

DROP TEMPORARY TABLE tmp_phase1_tools;

INSERT INTO ai_tool_news (tool_id, title, summary, source_name, news_type, tags, is_featured)
SELECT
    t.id,
    CONCAT(t.tool_name, ' 전략 업데이트'),
    CONCAT(t.tool_name, ' 관련 주요 기능과 시장 지표를 카탈로그에 반영했습니다.'),
    t.provider_name,
    'update',
    JSON_ARRAY(t.category, t.provider_country),
    CASE WHEN t.global_rank <= 3 THEN 1 ELSE 0 END
FROM ai_tools t
WHERE t.tool_name IN ('ChatGPT', 'Claude', 'Gemini', 'GitHub Copilot', 'Midjourney', 'Runway Gen-3')
  AND NOT EXISTS (
      SELECT 1
      FROM ai_tool_news n
      WHERE n.tool_id = t.id
        AND n.title = CONCAT(t.tool_name, ' 전략 업데이트')
  );

UPDATE countries c
JOIN (
    SELECT provider_country AS code, COUNT(*) AS cnt
    FROM ai_tools
    WHERE provider_country IS NOT NULL
    GROUP BY provider_country
) x ON x.code = c.code
SET c.tool_count = x.cnt;
