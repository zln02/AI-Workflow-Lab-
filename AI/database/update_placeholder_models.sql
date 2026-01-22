-- ============================================
-- "대표 모델 등록 (추후 상세값 입력 예정)" 모델들의 상세 정보 업데이트
-- ============================================

-- ChatGPT (ID: 1) - LLM
UPDATE ai_models SET
  description = 'ChatGPT는 OpenAI에서 개발한 대화형 AI 언어 모델입니다. 자연어 대화, 질문 답변, 텍스트 생성, 코드 작성, 번역, 요약 등 다양한 작업을 수행할 수 있습니다. GPT-3.5 또는 GPT-4 아키텍처를 기반으로 하며, 사용자와 자연스러운 대화 형식으로 상호작용합니다. 실시간 대화, 고객 서비스, 콘텐츠 생성, 교육 보조, 프로그래밍 지원 등 광범위한 분야에서 활용됩니다.',
  purpose_summary = '대화형 AI 어시스턴트, 자연어 처리 및 생성',
  params_billion = 175.00,
  input_modalities = 'TEXT',
  output_modalities = 'TEXT',
  latency_ms = 500,
  rate_limit_per_min = 60,
  max_input_size_mb = 16.00,
  languages = '["ko", "en", "es", "fr", "de", "it", "pt", "ru", "ja", "zh", "ar", "hi"]',
  benchmarks = '{"MMLU": 70.0, "HumanEval": 48.1}',
  homepage_url = 'https://chat.openai.com',
  docs_url = 'https://platform.openai.com/docs',
  playground_url = 'https://chat.openai.com',
  supported_file_types = 'txt, pdf, docx, csv, json',
  data_retention = 'OpenAI는 대화 데이터를 학습에 사용하지 않으며, 사용자 설정에 따라 데이터 보존 기간이 달라질 수 있습니다.'
WHERE id = 1 AND description LIKE '%대표 모델 등록%';

-- Llama (ID: 3) - LLM
UPDATE ai_models SET
  description = 'Llama(Large Language Model Meta AI)는 Meta에서 개발한 오픈소스 대규모 언어 모델입니다. 7B, 13B, 33B, 65B 파라미터 규모의 다양한 버전을 제공하며, 연구 및 상업적 용도로 활용할 수 있습니다. 자연어 이해 및 생성, 코드 작성, 추론, 번역 등 다양한 작업에 뛰어난 성능을 보입니다. 오픈소스 모델이므로 온프레미스 배포가 가능하며, 데이터 프라이버시가 중요한 환경에 적합합니다.',
  purpose_summary = '오픈소스 대규모 언어 모델, 다목적 자연어 처리',
  params_billion = 65.00,
  input_modalities = 'TEXT',
  output_modalities = 'TEXT',
  latency_ms = 800,
  rate_limit_per_min = NULL,
  max_input_size_mb = 8.00,
  languages = '["en", "es", "fr", "de", "it", "pt", "ru", "ja", "zh"]',
  benchmarks = '{"MMLU": 68.9, "HellaSwag": 81.2}',
  homepage_url = 'https://ai.meta.com/llama',
  docs_url = 'https://github.com/facebookresearch/llama',
  supported_file_types = 'txt',
  data_retention = '오픈소스 모델이므로 온프레미스 배포 시 데이터가 외부로 전송되지 않습니다.',
  license_type = 'OPEN_SOURCE',
  onprem_available = 1
WHERE id = 3 AND description LIKE '%대표 모델 등록%';

-- GitHub Copilot (ID: 7) - Code Generation
UPDATE ai_models SET
  description = 'GitHub Copilot은 GitHub와 OpenAI가 협력하여 개발한 AI 기반 코드 자동 완성 도구입니다. Visual Studio Code, JetBrains IDE 등 주요 개발 환경에서 사용할 수 있으며, 코드 작성 시 자동으로 코드 스니펫을 제안합니다. 다양한 프로그래밍 언어를 지원하며, 함수, 클래스, 주석, 테스트 코드 등을 자동 생성할 수 있습니다. 개발 생산성을 크게 향상시키며, 학습 및 코드 리뷰에도 활용됩니다.',
  purpose_summary = 'AI 기반 코드 자동 완성 및 생성',
  params_billion = NULL,
  input_modalities = 'TEXT,CODE',
  output_modalities = 'CODE',
  latency_ms = 300,
  rate_limit_per_min = 60,
  max_input_size_mb = 2.00,
  languages = '["ko", "en"]',
  benchmarks = NULL,
  homepage_url = 'https://github.com/features/copilot',
  docs_url = 'https://docs.github.com/en/copilot',
  supported_file_types = 'py, js, ts, java, cpp, go, rs, rb, php, html, css, sql',
  data_retention = 'GitHub Copilot 개인정보 보호 정책에 따라 코드 스니펫은 서버로 전송되어 처리되며, 학습에 사용되지 않습니다.'
WHERE id = 7 AND description LIKE '%대표 모델 등록%';

-- Code Llama (ID: 9) - Code Generation
UPDATE ai_models SET
  description = 'Code Llama는 Meta에서 개발한 코드 생성에 특화된 오픈소스 언어 모델입니다. Llama 2를 기반으로 코드 데이터셋으로 추가 학습하여 만들어졌으며, Python, JavaScript, Java, C++, PHP, TypeScript, C#, Bash 등 다양한 프로그래밍 언어를 지원합니다. 코드 완성, 코드 생성, 코드 리뷰, 디버깅 지원, 문서 작성 등 다양한 개발 작업에 활용됩니다. 오픈소스 모델이므로 온프레미스 배포가 가능합니다.',
  purpose_summary = '코드 생성 및 완성, 다언어 프로그래밍 지원',
  params_billion = 34.00,
  input_modalities = 'TEXT,CODE',
  output_modalities = 'CODE',
  latency_ms = 600,
  rate_limit_per_min = NULL,
  max_input_size_mb = 16.00,
  languages = '["en"]',
  benchmarks = '{"HumanEval": 53.7, "MBPP": 56.2}',
  homepage_url = 'https://ai.meta.com/blog/code-llama-large-language-model-coding',
  docs_url = 'https://github.com/facebookresearch/codellama',
  supported_file_types = 'py, js, ts, java, cpp, php, cs, sh, go, rs, rb',
  data_retention = '오픈소스 모델이므로 온프레미스 배포 시 데이터가 외부로 전송되지 않습니다.',
  license_type = 'OPEN_SOURCE',
  onprem_available = 1
WHERE id = 9 AND description LIKE '%대표 모델 등록%';

-- DeepL (ID: 11) - Translation
UPDATE ai_models SET
  description = 'DeepL은 독일의 DeepL GmbH에서 개발한 고품질 기계 번역 서비스입니다. 신경망 기반의 최첨단 번역 엔진을 사용하여 30개 이상의 언어를 지원하며, 특히 자연스럽고 정확한 번역으로 유명합니다. 문서 번역, 실시간 번역, API 기반 자동화 번역 등 다양한 용도로 활용됩니다. 전문적인 번역 품질과 맥락을 고려한 번역이 특징이며, 비즈니스 문서, 학술 논문, 웹사이트 콘텐츠 번역에 적합합니다.',
  purpose_summary = '고품질 다국어 기계 번역',
  params_billion = NULL,
  input_modalities = 'TEXT',
  output_modalities = 'TEXT',
  latency_ms = 500,
  rate_limit_per_min = 500000,
  max_input_size_mb = 5.00,
  languages = '["ko", "en", "de", "fr", "es", "it", "pt", "ru", "ja", "zh", "pl", "nl", "cs", "tr", "ar", "sv", "da", "fi", "no", "hu", "ro", "sk", "uk", "bg", "hr", "sl", "et", "lv", "lt", "mt"]',
  benchmarks = NULL,
  homepage_url = 'https://www.deepl.com',
  docs_url = 'https://www.deepl.com/docs-api',
  playground_url = 'https://www.deepl.com/translator',
  supported_file_types = 'txt, docx, pptx, xlsx, pdf, html',
  data_retention = 'DeepL은 사용자 데이터를 저장하지 않으며, 번역 요청만 처리하고 즉시 삭제합니다.'
WHERE id = 11 AND description LIKE '%대표 모델 등록%';

-- Google Translate (ID: 12) - Translation
UPDATE ai_models SET
  description = 'Google Translate는 Google에서 제공하는 무료 기계 번역 서비스입니다. 100개 이상의 언어를 지원하며, 텍스트, 이미지, 음성, 실시간 대화 번역 등 다양한 입력 형태를 처리할 수 있습니다. 웹 기반 번역, 모바일 앱, API 서비스로 제공되며, 전 세계에서 가장 널리 사용되는 번역 서비스 중 하나입니다. 일상적인 번역부터 문서 번역까지 다양한 용도로 활용되며, 지속적으로 학습하여 번역 품질을 개선합니다.',
  purpose_summary = '다국어 기계 번역, 다모달 번역 지원',
  params_billion = NULL,
  input_modalities = 'TEXT,IMAGE,AUDIO',
  output_modalities = 'TEXT,AUDIO',
  latency_ms = 300,
  rate_limit_per_min = 600,
  max_input_size_mb = 1.00,
  languages = '["ko", "en", "es", "fr", "de", "it", "pt", "ru", "ja", "zh", "ar", "hi", "th", "vi", "id", "tr", "pl", "nl", "cs", "hu", "ro", "sv", "da", "fi", "no", "uk", "bg", "hr", "sk", "sl", "et", "lv", "lt", "mt"]',
  benchmarks = NULL,
  homepage_url = 'https://translate.google.com',
  docs_url = 'https://cloud.google.com/translate/docs',
  playground_url = 'https://translate.google.com',
  supported_file_types = 'txt, jpg, png, pdf, docx',
  data_retention = 'Google Translate 서비스 약관에 따라 번역 데이터가 처리됩니다.'
WHERE id = 12 AND description LIKE '%대표 모델 등록%';

-- ChatGPT (ID: 13) - Summarization
UPDATE ai_models SET
  description = 'ChatGPT는 OpenAI의 대규모 언어 모델을 활용한 요약 도구입니다. 긴 문서, 기사, 논문, 대화 기록 등을 읽고 핵심 내용을 요약할 수 있습니다. 요약 길이를 조절할 수 있으며, 특정 주제나 관점에 맞춰 요약하는 것도 가능합니다. 뉴스 요약, 학술 논문 요약, 회의록 작성, 문서 분석 등 다양한 작업에 활용됩니다. 맥락을 이해하고 중요한 정보를 식별하여 정확하고 간결한 요약을 생성합니다.',
  purpose_summary = '문서 요약, 핵심 내용 추출',
  params_billion = 175.00,
  input_modalities = 'TEXT',
  output_modalities = 'TEXT',
  latency_ms = 1000,
  rate_limit_per_min = 60,
  max_input_size_mb = 16.00,
  languages = '["ko", "en", "es", "fr", "de", "it", "pt", "ru", "ja", "zh"]',
  benchmarks = NULL,
  homepage_url = 'https://chat.openai.com',
  docs_url = 'https://platform.openai.com/docs',
  supported_file_types = 'txt, pdf, docx',
  data_retention = 'OpenAI는 요약 요청 데이터를 학습에 사용하지 않습니다.'
WHERE id = 13 AND description LIKE '%대표 모델 등록%';

-- DALL·E 3 (ID: 16) - Image Generation
UPDATE ai_models SET
  description = 'DALL·E 3는 OpenAI에서 개발한 최신 텍스트-이미지 생성 AI 모델입니다. DALL·E 2보다 향상된 이미지 품질과 정확도를 제공하며, 복잡한 프롬프트를 더 잘 이해하고 시각화합니다. 다양한 스타일과 장르의 이미지를 생성할 수 있으며, 특정 객체, 캐릭터, 스타일, 구성 등을 정확하게 반영합니다. 디자인 초안, 일러스트레이션, 마케팅 이미지, 창의적 콘텐츠 생성 등에 활용됩니다.',
  purpose_summary = '고품질 텍스트-이미지 생성',
  params_billion = NULL,
  input_modalities = 'TEXT',
  output_modalities = 'IMAGE',
  latency_ms = 8000,
  rate_limit_per_min = 7,
  max_input_size_mb = 0.5,
  languages = '["ko", "en", "es", "fr", "de", "it", "pt", "ru", "ja", "zh"]',
  benchmarks = '{"CLIP Score": 0.95, "FID": 24.5}',
  homepage_url = 'https://openai.com/dall-e-3',
  docs_url = 'https://platform.openai.com/docs/guides/images',
  playground_url = 'https://labs.openai.com',
  supported_file_types = 'txt',
  data_retention = '생성된 이미지는 OpenAI 서버에 저장되지 않으며, 사용자가 직접 다운로드하여 관리합니다.'
WHERE id = 16 AND description LIKE '%대표 모델 등록%';

-- Midjourney (ID: 17) - Image Generation
UPDATE ai_models SET
  description = 'Midjourney는 독립 연구소에서 개발한 텍스트-이미지 생성 AI입니다. 예술적이고 창의적인 이미지 생성에 특화되어 있으며, 독특한 미학적 스타일로 유명합니다. 초현실적인 작품, 판타지 아트, 컨셉 아트, 일러스트레이션 등 창의적인 이미지 생성에 뛰어난 성능을 보입니다. Discord 봇을 통해 서비스되며, 다양한 스타일 파라미터와 설정을 조정하여 원하는 결과를 얻을 수 있습니다. 디자이너, 아티스트, 크리에이터들이 영감을 얻거나 초안을 만드는 데 활용합니다.',
  purpose_summary = '예술적 이미지 생성, 창의적 콘텐츠 제작',
  params_billion = NULL,
  input_modalities = 'TEXT,IMAGE',
  output_modalities = 'IMAGE',
  latency_ms = 6000,
  rate_limit_per_min = 10,
  max_input_size_mb = 10.00,
  languages = '["en"]',
  benchmarks = NULL,
  homepage_url = 'https://www.midjourney.com',
  docs_url = 'https://docs.midjourney.com',
  playground_url = 'https://www.midjourney.com/app',
  supported_file_types = 'txt, jpg, png',
  data_retention = 'Midjourney 사용 약관에 따라 생성된 이미지의 권한이 적용됩니다.'
WHERE id = 17 AND description LIKE '%대표 모델 등록%';

-- Adobe Firefly (ID: 18) - Image Generation
UPDATE ai_models SET
  description = 'Adobe Firefly는 Adobe에서 개발한 생성형 AI 도구 모음입니다. 텍스트-이미지 생성, 이미지 편집, 스타일 전송 등 다양한 기능을 제공하며, Adobe Creative Cloud 생태계와 완벽하게 통합됩니다. 상업적 사용이 안전한 이미지를 생성하며, Adobe Stock 이미지와 라이선스가 명확한 콘텐츠로 학습되어 있습니다. 그래픽 디자인, 마케팅, 브랜딩, 웹 디자인 등 전문적인 크리에이티브 작업에 적합합니다.',
  purpose_summary = '상업용 안전 이미지 생성, Adobe 생태계 통합',
  params_billion = NULL,
  input_modalities = 'TEXT,IMAGE',
  output_modalities = 'IMAGE',
  latency_ms = 5000,
  rate_limit_per_min = 25,
  max_input_size_mb = 20.00,
  languages = '["ko", "en", "es", "fr", "de", "it", "pt", "ru", "ja", "zh"]',
  benchmarks = NULL,
  homepage_url = 'https://firefly.adobe.com',
  docs_url = 'https://helpx.adobe.com/firefly/using/what-is-firefly.html',
  playground_url = 'https://firefly.adobe.com',
  supported_file_types = 'txt, jpg, png, psd',
  data_retention = 'Adobe Firefly 개인정보 보호 정책에 따라 데이터가 처리됩니다.',
  commercial_use_allowed = 1
WHERE id = 18 AND description LIKE '%대표 모델 등록%';

-- LLaVA (ID: 21) - Image Understanding
UPDATE ai_models SET
  description = 'LLaVA(Large Language and Vision Assistant)는 대규모 언어 모델과 비전 모델을 결합한 멀티모달 AI입니다. 이미지를 이해하고 텍스트로 설명하며, 이미지에 대한 질문에 답할 수 있습니다. 이미지 캡셔닝, 시각적 질의응답, 이미지 분석, 문서 이해 등에 활용됩니다. 다양한 이미지 형식과 해상도를 처리할 수 있으며, 복잡한 시각적 내용도 정확하게 이해합니다.',
  purpose_summary = '이미지 이해 및 설명, 멀티모달 AI',
  params_billion = 13.00,
  input_modalities = 'TEXT,IMAGE',
  output_modalities = 'TEXT',
  latency_ms = 2000,
  rate_limit_per_min = 30,
  max_input_size_mb = 20.00,
  languages = '["en"]',
  benchmarks = '{"VQA": 85.5, "TextVQA": 61.3}',
  homepage_url = 'https://llava-vl.github.io',
  docs_url = 'https://github.com/haotian-liu/LLaVA',
  supported_file_types = 'jpg, png, webp, pdf',
  data_retention = '오픈소스 모델이므로 온프레미스 배포 시 데이터가 외부로 전송되지 않습니다.',
  license_type = 'OPEN_SOURCE',
  onprem_available = 1
WHERE id = 21 AND description LIKE '%대표 모델 등록%';

-- Runway Gen-2 (ID: 22) - Video Generation
UPDATE ai_models SET
  description = 'Runway Gen-2는 Runway에서 개발한 텍스트-비디오 생성 AI 모델입니다. 텍스트 프롬프트나 이미지를 입력하여 짧은 비디오 클립을 생성할 수 있습니다. 다양한 스타일과 장르의 비디오를 생성하며, 카메라 움직임, 조명, 색감 등을 제어할 수 있습니다. 영화 제작, 광고, 소셜 미디어 콘텐츠, 프로토타이핑 등 다양한 비디오 생성 작업에 활용됩니다. 고품질의 일관성 있는 비디오 생성이 가능하며, 프리비주얼라이제이션에 특히 유용합니다.',
  purpose_summary = '텍스트/이미지 기반 비디오 생성',
  params_billion = NULL,
  input_modalities = 'TEXT,IMAGE',
  output_modalities = 'VIDEO',
  latency_ms = 12000,
  rate_limit_per_min = 5,
  max_input_size_mb = 10.00,
  languages = '["en"]',
  benchmarks = NULL,
  homepage_url = 'https://runwayml.com',
  docs_url = 'https://docs.runwayml.com',
  playground_url = 'https://runwayml.com',
  supported_file_types = 'txt, jpg, png',
  data_retention = 'Runway 서비스 약관에 따라 데이터가 처리됩니다.'
WHERE id = 22 AND description LIKE '%대표 모델 등록%';

-- Pika 1.0 (ID: 23) - Video Generation
UPDATE ai_models SET
  description = 'Pika 1.0은 Pika Labs에서 개발한 AI 기반 비디오 생성 도구입니다. 텍스트 프롬프트, 이미지, 비디오를 입력하여 새로운 비디오를 생성하거나 기존 비디오를 편집할 수 있습니다. 다양한 비즈니스 및 창의적 용도로 활용되며, 마케팅 비디오, 소셜 미디어 콘텐츠, 프로모션 영상 등을 빠르게 제작할 수 있습니다. 직관적인 인터페이스와 다양한 스타일 옵션을 제공합니다.',
  purpose_summary = 'AI 비디오 생성 및 편집',
  params_billion = NULL,
  input_modalities = 'TEXT,IMAGE,VIDEO',
  output_modalities = 'VIDEO',
  latency_ms = 15000,
  rate_limit_per_min = 4,
  max_input_size_mb = 50.00,
  languages = '["en"]',
  benchmarks = NULL,
  homepage_url = 'https://pika.art',
  docs_url = 'https://pika.art',
  playground_url = 'https://pika.art',
  supported_file_types = 'txt, jpg, png, mp4, mov',
  data_retention = 'Pika Labs 서비스 약관에 따라 데이터가 처리됩니다.'
WHERE id = 23 AND description LIKE '%대표 모델 등록%';

-- Stable Video Diffusion (ID: 24) - Video Generation
UPDATE ai_models SET
  description = 'Stable Video Diffusion은 Stability AI에서 개발한 오픈소스 비디오 생성 모델입니다. 이미지를 입력받아 짧은 비디오 클립으로 변환하거나, 텍스트에서 비디오를 생성할 수 있습니다. 오픈소스 모델이므로 온프레미스 배포가 가능하며, 상업적 용도로도 사용할 수 있습니다. 연구, 콘텐츠 제작, 프로토타이핑 등 다양한 용도로 활용됩니다.',
  purpose_summary = '오픈소스 비디오 생성, 이미지-비디오 변환',
  params_billion = NULL,
  input_modalities = 'TEXT,IMAGE',
  output_modalities = 'VIDEO',
  latency_ms = 10000,
  rate_limit_per_min = NULL,
  max_input_size_mb = 20.00,
  languages = '["en"]',
  benchmarks = NULL,
  homepage_url = 'https://stability.ai/stable-video',
  docs_url = 'https://github.com/Stability-AI/generative-models',
  supported_file_types = 'txt, jpg, png',
  data_retention = '오픈소스 모델이므로 온프레미스 배포 시 데이터가 외부로 전송되지 않습니다.',
  license_type = 'OPEN_SOURCE',
  onprem_available = 1
WHERE id = 24 AND description LIKE '%대표 모델 등록%';

-- Sora (ID: 26) - Video Understanding
UPDATE ai_models SET
  description = 'Sora는 OpenAI에서 개발한 최첨단 텍스트-비디오 생성 AI 모델입니다. 긴 비디오 클립(최대 1분)을 생성할 수 있으며, 복잡한 장면과 물리 법칙을 이해하여 사실적인 비디오를 만듭니다. 다양한 카메라 움직임, 캐릭터 일관성, 복잡한 3D 공간 이해가 가능합니다. 영화 제작, 게임 개발, 가상 현실 콘텐츠 제작 등에 활용될 것으로 기대됩니다.',
  purpose_summary = '고품질 긴 비디오 생성, 사실적인 동영상 제작',
  params_billion = NULL,
  input_modalities = 'TEXT,IMAGE',
  output_modalities = 'VIDEO',
  latency_ms = 30000,
  rate_limit_per_min = 2,
  max_input_size_mb = 20.00,
  languages = '["en"]',
  benchmarks = NULL,
  homepage_url = 'https://openai.com/sora',
  docs_url = 'https://openai.com/research/video-generation-models-as-world-simulators',
  supported_file_types = 'txt, jpg, png',
  data_retention = 'OpenAI 서비스 약관에 따라 데이터가 처리됩니다.'
WHERE id = 26 AND description LIKE '%대표 모델 등록%';

-- Runway Vision (ID: 27) - Video Understanding
UPDATE ai_models SET
  description = 'Runway Vision은 Runway에서 개발한 비디오 이해 및 분석 AI 모델입니다. 비디오를 분석하여 내용을 설명하고, 특정 객체나 이벤트를 감지하며, 비디오에 대한 질문에 답할 수 있습니다. 비디오 요약, 콘텐츠 모더레이션, 동영상 검색, 자동 캡셔닝 등에 활용됩니다.',
  purpose_summary = '비디오 이해 및 분석, 자동 캡셔닝',
  params_billion = NULL,
  input_modalities = 'VIDEO',
  output_modalities = 'TEXT',
  latency_ms = 5000,
  rate_limit_per_min = 10,
  max_input_size_mb = 100.00,
  languages = '["en"]',
  benchmarks = NULL,
  homepage_url = 'https://runwayml.com',
  docs_url = 'https://docs.runwayml.com',
  supported_file_types = 'mp4, mov, avi, webm',
  data_retention = 'Runway 서비스 약관에 따라 데이터가 처리됩니다.'
WHERE id = 27 AND description LIKE '%대표 모델 등록%';

-- Google Speech (ID: 29) - Speech-to-Text
UPDATE ai_models SET
  description = 'Google Speech-to-Text는 Google Cloud에서 제공하는 자동 음성 인식(ASR) API입니다. 실시간 및 배치 음성-텍스트 변환을 지원하며, 125개 이상의 언어와 방언을 인식합니다. 배경 소음 감소, 자동 구두점 추가, 화자 구분 등의 고급 기능을 제공합니다. 전화 통화 기록, 자막 생성, 음성 명령 인식, 콜 센터 분석 등 다양한 비즈니스 애플리케이션에 활용됩니다.',
  purpose_summary = '다국어 음성 인식, 실시간 자동 전사',
  params_billion = NULL,
  input_modalities = 'AUDIO',
  output_modalities = 'TEXT',
  latency_ms = 500,
  rate_limit_per_min = 600,
  max_input_size_mb = 100.00,
  languages = '["ko", "en", "es", "fr", "de", "it", "pt", "ru", "ja", "zh", "ar", "hi", "th", "vi", "id", "tr", "pl", "nl", "cs", "hu", "ro", "sv", "da", "fi", "no", "uk", "bg", "hr", "sk", "sl", "et", "lv", "lt", "mt"]',
  benchmarks = NULL,
  homepage_url = 'https://cloud.google.com/speech-to-text',
  docs_url = 'https://cloud.google.com/speech-to-text/docs',
  supported_file_types = 'wav, flac, mp3, ogg, m4a',
  data_retention = 'Google Cloud 데이터 보존 정책에 따라 처리됩니다.'
WHERE id = 29 AND description LIKE '%대표 모델 등록%';

-- Deepgram (ID: 30) - Speech-to-Text
UPDATE ai_models SET
  description = 'Deepgram은 고성능 음성 인식 API를 제공하는 서비스입니다. 실시간 및 배치 음성-텍스트 변환을 지원하며, 빠른 응답 속도와 높은 정확도로 유명합니다. 다양한 오디오 형식을 지원하며, 다국어 인식과 화자 구분 기능을 제공합니다. 콜 센터, 음성 분석, 자동 캡셔닝, 회의록 작성 등에 활용됩니다.',
  purpose_summary = '고성능 음성 인식, 실시간 전사',
  params_billion = NULL,
  input_modalities = 'AUDIO',
  output_modalities = 'TEXT',
  latency_ms = 300,
  rate_limit_per_min = 1000,
  max_input_size_mb = 200.00,
  languages = '["ko", "en", "es", "fr", "de", "it", "pt", "ru", "ja", "zh"]',
  benchmarks = NULL,
  homepage_url = 'https://deepgram.com',
  docs_url = 'https://developers.deepgram.com',
  supported_file_types = 'wav, flac, mp3, ogg, m4a, webm',
  data_retention = 'Deepgram 개인정보 보호 정책에 따라 데이터가 처리됩니다.'
WHERE id = 30 AND description LIKE '%대표 모델 등록%';

-- ElevenLabs (ID: 31) - Text-to-Speech
UPDATE ai_models SET
  description = 'ElevenLabs는 고품질 음성 합성 및 음성 복제 서비스를 제공하는 AI 기업입니다. 자연스러운 TTS(Text-to-Speech) 음성을 생성하며, 다양한 언어와 음성 스타일을 지원합니다. 음성 클로닝 기능을 통해 특정 사람의 음성을 학습하여 자연스러운 음성 합성이 가능합니다. 팟캐스트, 오디오북, 동영상 더빙, 가상 어시스턴트 등에 활용됩니다.',
  purpose_summary = '고품질 음성 합성 및 음성 복제',
  params_billion = NULL,
  input_modalities = 'TEXT',
  output_modalities = 'AUDIO',
  latency_ms = 1500,
  rate_limit_per_min = 100,
  max_input_size_mb = 5.00,
  languages = '["ko", "en", "es", "fr", "de", "it", "pt", "ru", "ja", "zh", "pl"]',
  benchmarks = NULL,
  homepage_url = 'https://elevenlabs.io',
  docs_url = 'https://elevenlabs.io/docs',
  playground_url = 'https://elevenlabs.io',
  supported_file_types = 'txt',
  data_retention = 'ElevenLabs 개인정보 보호 정책에 따라 데이터가 처리됩니다.'
WHERE id = 31 AND description LIKE '%대표 모델 등록%';

-- Google TTS (ID: 32) - Text-to-Speech
UPDATE ai_models SET
  description = 'Google Text-to-Speech는 Google Cloud에서 제공하는 자연스러운 음성 합성 API입니다. WaveNet 및 Neural2 음성 엔진을 사용하여 인간의 목소리와 매우 유사한 고품질 음성을 생성합니다. 50개 이상의 언어와 200개 이상의 음성을 지원하며, 음성 스타일, 피치, 말하기 속도 등을 조정할 수 있습니다. 오디오북, 내비게이션, 가상 어시스턴트, 접근성 애플리케이션 등에 활용됩니다.',
  purpose_summary = '자연스러운 음성 합성, 다국어 TTS',
  params_billion = NULL,
  input_modalities = 'TEXT',
  output_modalities = 'AUDIO',
  latency_ms = 800,
  rate_limit_per_min = 1000,
  max_input_size_mb = 5.00,
  languages = '["ko", "en", "es", "fr", "de", "it", "pt", "ru", "ja", "zh", "ar", "hi", "th", "vi", "id", "tr", "pl", "nl", "cs", "hu", "ro", "sv", "da", "fi", "no", "uk", "bg", "hr", "sk", "sl", "et", "lv", "lt", "mt"]',
  benchmarks = NULL,
  homepage_url = 'https://cloud.google.com/text-to-speech',
  docs_url = 'https://cloud.google.com/text-to-speech/docs',
  supported_file_types = 'txt, ssml',
  data_retention = 'Google Cloud 데이터 보존 정책에 따라 처리됩니다.'
WHERE id = 32 AND description LIKE '%대표 모델 등록%';

-- Azure Neural TTS (ID: 33) - Text-to-Speech
UPDATE ai_models SET
  description = 'Azure Neural Text-to-Speech는 Microsoft Azure에서 제공하는 고품질 음성 합성 서비스입니다. 신경망 기반 음성 엔진을 사용하여 자연스럽고 표현력이 풍부한 음성을 생성합니다. 100개 이상의 언어와 다양한 음성 스타일을 지원하며, 감정 표현, 말하기 속도, 피치 조절 등 세밀한 제어가 가능합니다. 비즈니스 애플리케이션, 접근성 도구, 콘텐츠 제작 등에 활용됩니다.',
  purpose_summary = '고품질 신경망 음성 합성, 다국어 지원',
  params_billion = NULL,
  input_modalities = 'TEXT',
  output_modalities = 'AUDIO',
  latency_ms = 1000,
  rate_limit_per_min = 800,
  max_input_size_mb = 10.00,
  languages = '["ko", "en", "es", "fr", "de", "it", "pt", "ru", "ja", "zh", "ar", "hi", "th", "vi", "id", "tr", "pl", "nl", "cs", "hu", "ro", "sv", "da", "fi", "no", "uk", "bg", "hr", "sk", "sl", "et", "lv", "lt", "mt"]',
  benchmarks = NULL,
  homepage_url = 'https://azure.microsoft.com/services/cognitive-services/text-to-speech',
  docs_url = 'https://learn.microsoft.com/azure/cognitive-services/speech-service/text-to-speech',
  supported_file_types = 'txt, ssml',
  data_retention = 'Microsoft Azure 데이터 보존 정책에 따라 처리됩니다.'
WHERE id = 33 AND description LIKE '%대표 모델 등록%';

-- text-embedding-3-large (ID: 37) - Embedding
UPDATE ai_models SET
  description = 'text-embedding-3-large는 OpenAI에서 제공하는 최신 텍스트 임베딩 모델입니다. 텍스트를 고차원 벡터로 변환하여 의미적 유사도를 계산할 수 있습니다. 검색, 추천 시스템, 클러스터링, 분류, 의미 기반 검색 등 다양한 작업에 활용됩니다. 더 큰 임베딩 차원(3072차원)을 제공하여 더 정확한 의미 표현이 가능하며, 다국어 지원과 긴 텍스트 처리 능력을 가지고 있습니다.',
  purpose_summary = '고차원 텍스트 임베딩, 의미 기반 검색',
  params_billion = NULL,
  input_modalities = 'TEXT',
  output_modalities = 'TEXT',
  latency_ms = 150,
  rate_limit_per_min = 3000,
  max_input_size_mb = 8.00,
  languages = '["ko", "en", "es", "fr", "de", "it", "pt", "ru", "ja", "zh"]',
  benchmarks = '{"MTEB": 64.6, "BEIR": 56.5}',
  homepage_url = 'https://platform.openai.com/docs/guides/embeddings',
  docs_url = 'https://platform.openai.com/docs/guides/embeddings',
  supported_file_types = 'txt',
  data_retention = 'OpenAI는 임베딩 요청 데이터를 학습에 사용하지 않습니다.'
WHERE id = 37 AND description LIKE '%대표 모델 등록%';

-- bge-large (ID: 38) - Embedding
UPDATE ai_models SET
  description = 'BGE-large는 Beijing Academy of Artificial Intelligence에서 개발한 오픈소스 텍스트 임베딩 모델입니다. 다국어 지원과 우수한 성능으로 유명하며, 검색, 추천, 클러스터링, 분류 등 다양한 작업에 활용됩니다. 오픈소스 모델이므로 온프레미스 배포가 가능하며, 상업적 용도로도 사용할 수 있습니다. 특히 의미 기반 검색과 문서 유사도 분석에 뛰어난 성능을 보입니다.',
  purpose_summary = '오픈소스 다국어 임베딩, 의미 기반 검색',
  params_billion = 335.00,
  input_modalities = 'TEXT',
  output_modalities = 'TEXT',
  latency_ms = 250,
  rate_limit_per_min = NULL,
  max_input_size_mb = 5.00,
  languages = '["ko", "en", "zh", "ja", "es", "fr", "de", "it", "pt", "ru"]',
  benchmarks = '{"MTEB": 63.4, "BEIR": 55.2}',
  homepage_url = 'https://github.com/FlagOpen/FlagEmbedding',
  docs_url = 'https://github.com/FlagOpen/FlagEmbedding',
  supported_file_types = 'txt',
  data_retention = '오픈소스 모델이므로 온프레미스 배포 시 데이터가 외부로 전송되지 않습니다.',
  license_type = 'OPEN_SOURCE',
  onprem_available = 1
WHERE id = 38 AND description LIKE '%대표 모델 등록%';

-- Cohere Embed (ID: 39) - Embedding
UPDATE ai_models SET
  description = 'Cohere Embed는 Cohere에서 제공하는 텍스트 임베딩 모델입니다. 텍스트를 고차원 벡터로 변환하여 의미적 유사도를 계산할 수 있습니다. 검색, 추천 시스템, 클러스터링, 분류 등 다양한 작업에 활용됩니다. 다국어 지원과 긴 텍스트 처리 능력을 가지고 있어 실제 비즈니스 애플리케이션에 적합합니다. 특히 의미 기반 검색과 문서 유사도 분석에 뛰어난 성능을 보입니다.',
  purpose_summary = '텍스트 임베딩, 의미 기반 검색 및 유사도 계산',
  params_billion = NULL,
  input_modalities = 'TEXT',
  output_modalities = 'TEXT',
  latency_ms = 200,
  rate_limit_per_min = 5000,
  max_input_size_mb = 2.00,
  languages = '["ko", "en", "es", "fr", "de", "it", "pt", "ru", "ja", "zh"]',
  benchmarks = NULL,
  homepage_url = 'https://cohere.com',
  docs_url = 'https://docs.cohere.com/docs/embeddings',
  supported_file_types = 'txt',
  data_retention = 'Cohere 서비스 약관에 따라 데이터가 처리됩니다.'
WHERE id = 39 AND description LIKE '%대표 모델 등록%';

-- Perplexity AI (ID: 40) - Search AI
UPDATE ai_models SET
  description = 'Perplexity AI는 실시간 검색 기능을 갖춘 AI 챗봇 서비스입니다. 웹 검색 결과를 기반으로 정확하고 최신 정보를 제공하며, 모든 답변에 출처를 명시합니다. 연구, 정보 조사, 업무 지원, 학습 등에 활용됩니다. 일반적인 챗봇과 달리 최신 정보를 실시간으로 검색하여 제공하므로 뉴스, 최신 트렌드, 실시간 데이터 조회에 특히 유용합니다.',
  purpose_summary = '실시간 검색 기반 AI 어시스턴트',
  params_billion = NULL,
  input_modalities = 'TEXT',
  output_modalities = 'TEXT',
  latency_ms = 2000,
  rate_limit_per_min = 20,
  max_input_size_mb = 4.00,
  languages = '["ko", "en", "es", "fr", "de", "it", "pt", "ru", "ja", "zh"]',
  benchmarks = NULL,
  homepage_url = 'https://www.perplexity.ai',
  docs_url = 'https://www.perplexity.ai',
  playground_url = 'https://www.perplexity.ai',
  supported_file_types = 'txt',
  data_retention = 'Perplexity 개인정보 보호 정책에 따라 데이터가 처리됩니다.'
WHERE id = 40 AND description LIKE '%대표 모델 등록%';

-- You.com AI (ID: 41) - Search AI
UPDATE ai_models SET
  description = 'You.com AI는 검색 엔진과 AI 챗봇을 결합한 서비스입니다. 웹 검색 결과를 통합하여 정확한 답변을 제공하며, 출처를 명시합니다. 일반 검색, 이미지 검색, 코드 검색 등 다양한 검색 기능을 제공합니다. 연구, 정보 조사, 업무 지원 등에 활용됩니다.',
  purpose_summary = '통합 검색 AI, 실시간 정보 제공',
  params_billion = NULL,
  input_modalities = 'TEXT',
  output_modalities = 'TEXT',
  latency_ms = 1500,
  rate_limit_per_min = 30,
  max_input_size_mb = 4.00,
  languages = '["ko", "en", "es", "fr", "de", "it", "pt", "ru", "ja", "zh"]',
  benchmarks = NULL,
  homepage_url = 'https://you.com',
  docs_url = 'https://you.com',
  playground_url = 'https://you.com',
  supported_file_types = 'txt',
  data_retention = 'You.com 개인정보 보호 정책에 따라 데이터가 처리됩니다.'
WHERE id = 41 AND description LIKE '%대표 모델 등록%';

-- Bing Copilot (ID: 42) - Search AI
UPDATE ai_models SET
  description = 'Bing Copilot은 Microsoft가 개발한 AI 검색 어시스턴트입니다. Bing 검색 엔진과 대규모 언어 모델을 결합하여 실시간 정보를 바탕으로 정확한 답변을 제공합니다. 웹 검색, 이미지 생성, 대화형 인터페이스 등 다양한 기능을 제공하며, Microsoft 생태계와 완벽하게 통합됩니다.',
  purpose_summary = '통합 AI 검색 어시스턴트, Microsoft 생태계',
  params_billion = NULL,
  input_modalities = 'TEXT,IMAGE',
  output_modalities = 'TEXT,IMAGE',
  latency_ms = 1500,
  rate_limit_per_min = 60,
  max_input_size_mb = 4.00,
  languages = '["ko", "en", "es", "fr", "de", "it", "pt", "ru", "ja", "zh"]',
  benchmarks = NULL,
  homepage_url = 'https://www.microsoft.com/copilot',
  docs_url = 'https://www.microsoft.com/copilot',
  playground_url = 'https://copilot.microsoft.com',
  supported_file_types = 'txt',
  data_retention = 'Microsoft 서비스 약관에 따라 데이터가 처리됩니다.'
WHERE id = 42 AND description LIKE '%대표 모델 등록%';

-- AutoGPT (ID: 45) - AI Agent
UPDATE ai_models SET
  description = 'AutoGPT는 자율적으로 작동하는 AI 에이전트입니다. 목표를 설정하면 여러 단계를 자동으로 계획하고 실행하여 결과를 도출합니다. 웹 검색, 파일 생성, 코드 작성, 정보 분석 등 다양한 작업을 자동으로 수행할 수 있습니다. 연구, 자동화, 업무 효율화 등에 활용됩니다.',
  purpose_summary = '자율 AI 에이전트, 자동화 작업 수행',
  params_billion = NULL,
  input_modalities = 'TEXT',
  output_modalities = 'TEXT,CODE',
  latency_ms = 5000,
  rate_limit_per_min = 10,
  max_input_size_mb = 10.00,
  languages = '["en"]',
  benchmarks = NULL,
  homepage_url = 'https://github.com/Significant-Gravitas/AutoGPT',
  docs_url = 'https://github.com/Significant-Gravitas/AutoGPT',
  supported_file_types = 'txt, py, js, json',
  data_retention = '오픈소스 모델이므로 온프레미스 배포 시 데이터가 외부로 전송되지 않습니다.',
  license_type = 'OPEN_SOURCE',
  onprem_available = 1
WHERE id = 45 AND description LIKE '%대표 모델 등록%';


