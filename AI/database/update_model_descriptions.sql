-- ============================================
-- 모델 설명 및 사양 업데이트 스크립트
-- 실제 AI 모델 정보로 업데이트
-- ============================================

-- GPT-4 업데이트 (OpenAI)
UPDATE ai_models SET
  description = 'GPT-4는 OpenAI에서 개발한 최신 대규모 언어 모델입니다. 이전 버전인 GPT-3.5보다 훨씬 향상된 성능을 제공하며, 더 복잡한 추론, 창의적 작업, 그리고 세밀한 지시사항 이해가 가능합니다. 멀티모달 기능을 지원하여 텍스트뿐만 아니라 이미지 입력도 처리할 수 있습니다. 실제 업무에서 코드 작성, 창의적 글쓰기, 기술적 문서 작성, 번역, 요약 등 다양한 작업에 활용됩니다.',
  purpose_summary = '고급 자연어 이해 및 생성, 멀티모달 작업 지원',
  params_billion = 1800.00,
  input_modalities = 'TEXT,IMAGE',
  output_modalities = 'TEXT',
  latency_ms = 500,
  rate_limit_per_min = 500,
  max_input_size_mb = 32.00,
  languages = '["ko", "en", "es", "fr", "de", "it", "pt", "ru", "ja", "zh", "ar", "hi"]',
  benchmarks = '{"MMLU": 86.4, "HellaSwag": 95.3, "HumanEval": 67.0}',
  homepage_url = 'https://openai.com/gpt-4',
  docs_url = 'https://platform.openai.com/docs/models/gpt-4',
  supported_file_types = 'txt, pdf, docx, csv, json, xml',
  data_retention = 'API 사용 시 입력 데이터는 30일간 보관되며, 이후 자동 삭제됩니다. 개인정보 보호를 위해 데이터 암호화가 적용됩니다.'
WHERE model_name LIKE '%GPT-4%' OR model_name LIKE '%gpt-4%';

-- GPT-3.5 Turbo 업데이트 (OpenAI)
UPDATE ai_models SET
  description = 'GPT-3.5 Turbo는 OpenAI의 고성능이면서도 비용 효율적인 언어 모델입니다. GPT-4보다 빠른 응답 속도와 낮은 비용을 제공하며, 대부분의 텍스트 기반 작업에서 우수한 성능을 보입니다. 대화형 챗봇, 콘텐츠 생성, 코드 작성, 번역, 요약 등 다양한 용도로 활용 가능합니다. 특히 빠른 응답이 필요한 실시간 애플리케이션에 적합합니다.',
  purpose_summary = '빠른 텍스트 생성 및 이해, 실시간 대화형 AI',
  params_billion = 175.00,
  input_modalities = 'TEXT',
  output_modalities = 'TEXT',
  latency_ms = 300,
  rate_limit_per_min = 10000,
  max_input_size_mb = 16.00,
  languages = '["ko", "en", "es", "fr", "de", "it", "pt", "ru", "ja", "zh"]',
  benchmarks = '{"MMLU": 70.0, "HellaSwag": 85.5}',
  homepage_url = 'https://openai.com',
  docs_url = 'https://platform.openai.com/docs/models/gpt-3-5',
  supported_file_types = 'txt, csv, json',
  data_retention = 'API 사용 시 입력 데이터는 30일간 보관되며, 이후 자동 삭제됩니다.'
WHERE model_name LIKE '%GPT-3.5%' OR model_name LIKE '%gpt-3.5%' OR model_name LIKE '%GPT-3%';

-- Gemini Pro 업데이트 (Google)
UPDATE ai_models SET
  description = 'Gemini Pro는 Google DeepMind에서 개발한 차세대 멀티모달 AI 모델입니다. 텍스트, 이미지, 오디오, 비디오를 동시에 이해하고 처리할 수 있는 혁신적인 모델로, 다양한 입력을 통합하여 더 정확하고 맥락에 맞는 응답을 제공합니다. 복잡한 다단계 추론, 코드 생성, 과학적 문제 해결 등에 탁월한 성능을 보이며, 특히 한국어 처리에 최적화되어 있습니다.',
  purpose_summary = '멀티모달 AI, 통합 지능형 작업 처리',
  params_billion = 540.00,
  input_modalities = 'TEXT,IMAGE,AUDIO,VIDEO',
  output_modalities = 'TEXT',
  latency_ms = 600,
  rate_limit_per_min = 1500,
  max_input_size_mb = 20.00,
  languages = '["ko", "en", "es", "fr", "de", "it", "pt", "ru", "ja", "zh", "ar", "hi"]',
  benchmarks = '{"MMLU": 83.7, "HumanEval": 74.4, "GSM8K": 94.4}',
  homepage_url = 'https://deepmind.google/technologies/gemini/',
  docs_url = 'https://ai.google.dev/docs',
  playground_url = 'https://aistudio.google.com',
  supported_file_types = 'txt, pdf, jpg, png, mp3, mp4, webm',
  data_retention = 'Google Cloud 데이터 보존 정책에 따라 처리됩니다. 사용자 데이터는 암호화되어 보호됩니다.'
WHERE model_name LIKE '%Gemini%' OR model_name LIKE '%gemini%';

-- Claude 업데이트 (Anthropic)
UPDATE ai_models SET
  description = 'Claude는 Anthropic에서 개발한 안전하고 도움이 되는 AI 어시스턴트입니다. 긴 문서 분석, 복잡한 추론, 창의적 글쓰기, 코드 리뷰 등 다양한 작업에 활용됩니다. 특히 긴 컨텍스트(최대 200K 토큰)를 처리할 수 있어 긴 문서 전체를 한 번에 분석하거나, 전체 코드베이스를 이해하는 작업에 적합합니다. 안전성과 유용성을 최우선으로 설계되어 기업 환경에서도 신뢰할 수 있습니다.',
  purpose_summary = '안전한 AI 어시스턴트, 긴 문서 분석 및 복잡한 추론',
  params_billion = 520.00,
  input_modalities = 'TEXT,IMAGE',
  output_modalities = 'TEXT',
  latency_ms = 800,
  rate_limit_per_min = 50,
  max_input_size_mb = 100.00,
  languages = '["ko", "en", "es", "fr", "de", "it", "pt", "ru", "ja", "zh"]',
  benchmarks = '{"MMLU": 86.8, "HellaSwag": 95.0, "HumanEval": 56.0}',
  homepage_url = 'https://www.anthropic.com/claude',
  docs_url = 'https://docs.anthropic.com',
  supported_file_types = 'txt, pdf, docx, csv, json, jpg, png',
  data_retention = 'Anthropic은 사용자 데이터를 학습에 사용하지 않으며, 데이터 보존 정책을 명확히 공개합니다.'
WHERE model_name LIKE '%Claude%' OR model_name LIKE '%claude%';

-- DALL-E 업데이트 (OpenAI)
UPDATE ai_models SET
  description = 'DALL-E는 OpenAI에서 개발한 텍스트-이미지 생성 AI 모델입니다. 자연어 설명만으로 고품질의 이미지를 생성할 수 있으며, 다양한 스타일과 개념을 이해하고 시각화합니다. 창의적인 일러스트레이션, 디자인 초안, 마케팅 이미지, 콘텐츠 이미지 생성 등에 활용됩니다. 다양한 해상도와 종횡비를 지원하며, 특정 스타일이나 기존 이미지를 참조한 생성도 가능합니다.',
  purpose_summary = '텍스트 기반 고품질 이미지 생성',
  params_billion = 12.00,
  input_modalities = 'TEXT',
  output_modalities = 'IMAGE',
  latency_ms = 5000,
  rate_limit_per_min = 5,
  max_input_size_mb = 0.5,
  languages = '["ko", "en", "es", "fr", "de", "it", "pt", "ru", "ja", "zh"]',
  benchmarks = '{"FID": 27.5, "CLIP Score": 0.93}',
  homepage_url = 'https://openai.com/dall-e-3',
  docs_url = 'https://platform.openai.com/docs/guides/images',
  playground_url = 'https://labs.openai.com',
  supported_file_types = 'txt',
  data_retention = '생성된 이미지는 OpenAI 서버에 저장되지 않으며, 사용자가 직접 다운로드하여 관리합니다.'
WHERE model_name LIKE '%DALL-E%' OR model_name LIKE '%dalle%' OR model_name LIKE '%DALLE%';

-- Whisper 업데이트 (OpenAI)
UPDATE ai_models SET
  description = 'Whisper는 OpenAI에서 개발한 자동 음성 인식(ASR) 시스템입니다. 다양한 언어와 방언을 지원하며, 배경 소음과 다양한 음성 스타일에 강건합니다. 음성-텍스트 변환, 실시간 자막 생성, 음성 명령 인식, 다국어 번역 등에 활용됩니다. 오픈소스로 공개되어 있어 온프레미스 환경에서도 사용할 수 있으며, 데이터 프라이버시가 중요한 환경에 적합합니다.',
  purpose_summary = '다국어 음성 인식 및 번역',
  params_billion = 1.55,
  input_modalities = 'AUDIO',
  output_modalities = 'TEXT',
  latency_ms = 2000,
  rate_limit_per_min = 50,
  max_input_size_mb = 25.00,
  languages = '["ko", "en", "es", "fr", "de", "it", "pt", "ru", "ja", "zh", "ar", "hi", "th", "vi"]',
  benchmarks = '{"WER (Korean)": 8.5, "WER (English)": 6.8}',
  homepage_url = 'https://openai.com/research/whisper',
  docs_url = 'https://github.com/openai/whisper',
  supported_file_types = 'mp3, wav, m4a, flac, ogg',
  data_retention = '오픈소스 모델이므로 온프레미스 배포 시 데이터가 외부로 전송되지 않습니다.'
WHERE model_name LIKE '%Whisper%' OR model_name LIKE '%whisper%';

-- Stable Diffusion 업데이트 (Stability AI)
UPDATE ai_models SET
  description = 'Stable Diffusion은 Stability AI와 컴퓨너비전 연구팀이 공동 개발한 오픈소스 텍스트-이미지 생성 모델입니다. 오픈소스 라이선스로 제공되어 상업적 이용이 가능하며, 로컬 환경에서 실행할 수 있어 데이터 프라이버시를 보장합니다. 고품질 이미지 생성, 이미지 편집, 이미지 확대, 스타일 변환 등 다양한 작업에 활용됩니다. 커뮤니티의 활발한 지원과 다양한 확장 기능을 통해 계속 발전하고 있습니다.',
  purpose_summary = '오픈소스 이미지 생성, 상업적 이용 가능',
  params_billion = 0.89,
  input_modalities = 'TEXT,IMAGE',
  output_modalities = 'IMAGE',
  latency_ms = 3000,
  rate_limit_per_min = NULL,
  max_input_size_mb = 10.00,
  languages = '["en"]',
  benchmarks = '{"FID": 29.8, "CLIP Score": 0.89}',
  homepage_url = 'https://stability.ai/stable-diffusion',
  docs_url = 'https://github.com/Stability-AI/stablediffusion',
  supported_file_types = 'txt, jpg, png, webp',
  license_type = 'OPEN_SOURCE',
  data_retention = '오픈소스 모델로 로컬 환경에서 실행 가능하여 데이터가 외부로 전송되지 않습니다.'
WHERE model_name LIKE '%Stable Diffusion%' OR model_name LIKE '%stable diffusion%' OR model_name LIKE '%StableDiffusion%';

-- T5 업데이트 (Google)
UPDATE ai_models SET
  description = 'T5(Text-to-Text Transfer Transformer)는 Google에서 개발한 범용 텍스트 변환 모델입니다. 모든 자연어 처리 작업을 "텍스트를 텍스트로" 변환하는 문제로 접근합니다. 번역, 요약, 질문 응답, 분류 등 다양한 작업에 동일한 아키텍처를 사용할 수 있어 범용성이 뛰어납니다. 파인튜닝을 통해 다양한 언어와 도메인에 적용 가능하며, 텍스트 생성과 이해 작업 모두에서 우수한 성능을 보입니다.',
  purpose_summary = '범용 텍스트 변환 모델, 다양한 NLP 작업 지원',
  params_billion = 11.00,
  input_modalities = 'TEXT',
  output_modalities = 'TEXT',
  latency_ms = 400,
  rate_limit_per_min = 1000,
  max_input_size_mb = 8.00,
  languages = '["ko", "en", "es", "fr", "de", "it", "pt", "ru", "ja", "zh"]',
  benchmarks = '{"GLUE": 88.9, "SuperGLUE": 84.3}',
  homepage_url = 'https://github.com/google-research/text-to-text-transfer-transformer',
  docs_url = 'https://github.com/google-research/text-to-text-transfer-transformer',
  supported_file_types = 'txt, csv, json',
  data_retention = '오픈소스 모델이므로 온프레미스 배포 시 데이터가 외부로 전송되지 않습니다.'
WHERE (model_name LIKE '%T5%' OR model_name LIKE '%t5%') AND (description IS NULL OR description = '');

-- BERT 업데이트 (Google)
UPDATE ai_models SET
  description = 'BERT(Bidirectional Encoder Representations from Transformers)는 Google에서 개발한 양방향 언어 표현 모델입니다. 문맥을 양방향으로 이해하여 단어의 의미를 더 정확하게 파악합니다. 텍스트 분류, 질문 응답, 개체명 인식, 감정 분석 등 다양한 자연어 이해 작업에서 뛰어난 성능을 보입니다. 사전 학습된 모델을 다양한 작업에 파인튜닝하여 활용할 수 있어 실무에서 널리 사용됩니다.',
  purpose_summary = '양방향 텍스트 이해, 자연어 처리 기반 모델',
  params_billion = 0.34,
  input_modalities = 'TEXT',
  output_modalities = 'TEXT',
  latency_ms = 50,
  rate_limit_per_min = 5000,
  max_input_size_mb = 0.5,
  languages = '["ko", "en", "es", "fr", "de", "it", "pt", "ru", "ja", "zh"]',
  benchmarks = '{"GLUE": 80.5, "SQuAD": 93.2}',
  homepage_url = 'https://github.com/google-research/bert',
  docs_url = 'https://github.com/google-research/bert',
  supported_file_types = 'txt',
  data_retention = '오픈소스 모델이므로 온프레미스 배포 시 데이터가 외부로 전송되지 않습니다.'
WHERE (model_name LIKE '%BERT%' OR model_name LIKE '%bert%') AND (description IS NULL OR description = '');

-- RoBERTa 업데이트 (Meta/Facebook)
UPDATE ai_models SET
  description = 'RoBERTa(Robustly Optimized BERT Pretraining Approach)는 Meta(구 Facebook)에서 개발한 BERT의 개선 버전입니다. BERT의 사전 학습 방식을 최적화하여 더 나은 성능을 달성했습니다. 더 많은 데이터와 긴 학습 시간, 동적 마스킹 등을 통해 GLUE, SQuAD 등 주요 벤치마크에서 BERT보다 우수한 성능을 보입니다. 텍스트 분류, 자연어 추론, 질문 응답 등 다양한 작업에 활용됩니다.',
  purpose_summary = 'BERT 최적화 모델, 향상된 텍스트 이해',
  params_billion = 0.36,
  input_modalities = 'TEXT',
  output_modalities = 'TEXT',
  latency_ms = 60,
  rate_limit_per_min = 5000,
  max_input_size_mb = 0.5,
  languages = '["en"]',
  benchmarks = '{"GLUE": 88.5, "SQuAD": 94.6}',
  homepage_url = 'https://github.com/facebookresearch/roberta',
  docs_url = 'https://github.com/facebookresearch/roberta',
  supported_file_types = 'txt',
  data_retention = '오픈소스 모델이므로 온프레미스 배포 시 데이터가 외부로 전송되지 않습니다.'
WHERE (model_name LIKE '%RoBERTa%' OR model_name LIKE '%roberta%' OR model_name LIKE '%RoBERTa%') AND (description IS NULL OR description = '');

-- XLNet 업데이트 (Google/CMU)
UPDATE ai_models SET
  description = 'XLNet은 Google과 카네기멜론대학교가 공동 개발한 순열 언어 모델입니다. BERT의 양방향 컨텍스트 학습과 전통적인 언어 모델의 장점을 결합했습니다. 모든 가능한 토큰 순열을 고려하여 더 풍부한 표현을 학습하며, 질문 응답, 자연어 추론, 텍스트 분류 등에서 BERT보다 우수한 성능을 보입니다. 특히 복잡한 추론 작업에서 강점을 발휘합니다.',
  purpose_summary = '순열 기반 언어 모델, 향상된 추론 능력',
  params_billion = 0.34,
  input_modalities = 'TEXT',
  output_modalities = 'TEXT',
  latency_ms = 80,
  rate_limit_per_min = 3000,
  max_input_size_mb = 1.0,
  languages = '["en"]',
  benchmarks = '{"GLUE": 90.8, "SQuAD": 95.1}',
  homepage_url = 'https://github.com/zihangdai/xlnet',
  docs_url = 'https://github.com/zihangdai/xlnet',
  supported_file_types = 'txt',
  data_retention = '오픈소스 모델이므로 온프레미스 배포 시 데이터가 외부로 전송되지 않습니다.'
WHERE (model_name LIKE '%XLNet%' OR model_name LIKE '%xlnet%') AND (description IS NULL OR description = '');

-- Midjourney 업데이트
UPDATE ai_models SET
  description = 'Midjourney는 독립 연구소에서 개발한 텍스트-이미지 생성 AI입니다. 예술적이고 창의적인 이미지 생성에 특화되어 있으며, 독특한 미학적 스타일로 유명합니다. 초현실적인 작품, 판타지 아트, 컨셉 아트 등 창의적인 이미지 생성에 뛰어난 성능을 보입니다. 디자이너, 아티스트, 크리에이터들이 영감을 얻거나 초안을 만드는 데 활용합니다.',
  purpose_summary = '예술적 이미지 생성, 창의적 콘텐츠 제작',
  params_billion = NULL,
  input_modalities = 'TEXT',
  output_modalities = 'IMAGE',
  latency_ms = 6000,
  rate_limit_per_min = 10,
  max_input_size_mb = 1.0,
  languages = '["en"]',
  benchmarks = NULL,
  homepage_url = 'https://www.midjourney.com',
  docs_url = 'https://docs.midjourney.com',
  playground_url = 'https://www.midjourney.com/app',
  supported_file_types = 'txt',
  data_retention = 'Midjourney 사용 약관에 따라 생성된 이미지의 권한이 적용됩니다.'
WHERE (model_name LIKE '%Midjourney%' OR model_name LIKE '%midjourney%') AND (description IS NULL OR description = '');

-- Runway Gen-2 업데이트
UPDATE ai_models SET
  description = 'Runway Gen-2는 Runway에서 개발한 텍스트-비디오 생성 AI 모델입니다. 텍스트 프롬프트나 이미지를 입력하여 짧은 비디오 클립을 생성할 수 있습니다. 영화 제작, 광고, 소셜 미디어 콘텐츠 등 다양한 비디오 생성 작업에 활용됩니다. 고품질의 일관성 있는 비디오 생성이 가능하며, 프로토타이핑과 프리비주얼라이제이션에 특히 유용합니다.',
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
WHERE (model_name LIKE '%Runway%' OR model_name LIKE '%runway%' OR model_name LIKE '%Gen-2%') AND (description IS NULL OR description = '');

-- Sora 업데이트 (OpenAI)
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
WHERE (model_name LIKE '%Sora%' OR model_name LIKE '%sora%') AND (description IS NULL OR description = '');

-- ElevenLabs 업데이트
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
WHERE (model_name LIKE '%ElevenLabs%' OR model_name LIKE '%elevenlabs%' OR model_name LIKE '%Eleven%') AND (description IS NULL OR description = '');

-- Google Speech-to-Text 업데이트
UPDATE ai_models SET
  description = 'Google Speech-to-Text는 Google Cloud에서 제공하는 자동 음성 인식(ASR) API입니다. 실시간 및 배치 음성-텍스트 변환을 지원하며, 125개 이상의 언어와 방언을 인식합니다. 배경 소음 감소, 자동 구두점 추가, 화자 구분 등의 고급 기능을 제공합니다. 전화 통화 기록, 자막 생성, 음성 명령 인식, 콜 센터 분석 등 다양한 비즈니스 애플리케이션에 활용됩니다.',
  purpose_summary = '다국어 음성 인식, 실시간 자동 전사',
  params_billion = NULL,
  input_modalities = 'AUDIO',
  output_modalities = 'TEXT',
  latency_ms = 500,
  rate_limit_per_min = 600,
  max_input_size_mb = 100.00,
  languages = '["ko", "en", "es", "fr", "de", "it", "pt", "ru", "ja", "zh", "ar", "hi", "th", "vi", "id"]',
  benchmarks = NULL,
  homepage_url = 'https://cloud.google.com/speech-to-text',
  docs_url = 'https://cloud.google.com/speech-to-text/docs',
  supported_file_types = 'wav, flac, mp3, ogg, m4a',
  data_retention = 'Google Cloud 데이터 보존 정책에 따라 처리됩니다.'
WHERE (model_name LIKE '%Google Speech%' OR model_name LIKE '%Google STT%' OR model_name LIKE '%Speech-to-Text%') AND (description IS NULL OR description = '');

-- Google Text-to-Speech 업데이트
UPDATE ai_models SET
  description = 'Google Text-to-Speech는 Google Cloud에서 제공하는 자연스러운 음성 합성 API입니다. WaveNet 및 Neural2 음성 엔진을 사용하여 인간의 목소리와 매우 유사한 고품질 음성을 생성합니다. 50개 이상의 언어와 200개 이상의 음성을 지원하며, 음성 스타일, 피치, 말하기 속도 등을 조정할 수 있습니다. 오디오북, 내비게이션, 가상 어시스턴트, 접근성 애플리케이션 등에 활용됩니다.',
  purpose_summary = '자연스러운 음성 합성, 다국어 TTS',
  params_billion = NULL,
  input_modalities = 'TEXT',
  output_modalities = 'AUDIO',
  latency_ms = 800,
  rate_limit_per_min = 1000,
  max_input_size_mb = 5.00,
  languages = '["ko", "en", "es", "fr", "de", "it", "pt", "ru", "ja", "zh", "ar", "hi", "th", "vi"]',
  benchmarks = NULL,
  homepage_url = 'https://cloud.google.com/text-to-speech',
  docs_url = 'https://cloud.google.com/text-to-speech/docs',
  supported_file_types = 'txt, ssml',
  data_retention = 'Google Cloud 데이터 보존 정책에 따라 처리됩니다.'
WHERE (model_name LIKE '%Google TTS%' OR model_name LIKE '%Text-to-Speech%' OR model_name LIKE '%Google Voice%') AND (description IS NULL OR description = '');

-- Cohere Embed 업데이트
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
WHERE (model_name LIKE '%Cohere%' OR model_name LIKE '%cohere%' OR model_name LIKE '%Embed%') AND (description IS NULL OR description = '');

-- VQ-VAE-2 업데이트 (DeepMind)
UPDATE ai_models SET
  description = 'VQ-VAE-2(Vector Quantised Variational AutoEncoder 2)는 DeepMind에서 개발한 고해상도 이미지 생성 모델입니다. 벡터 양자화 기법을 사용하여 이미지를 압축하고 재생성합니다. 고품질 이미지 생성, 이미지 압축, 스타일 변환 등에 활용됩니다. 계층적 구조를 통해 세밀한 디테일과 전체적인 구조를 모두 잘 보존하여 매우 사실적인 이미지를 생성할 수 있습니다.',
  purpose_summary = '고해상도 이미지 생성 및 압축',
  params_billion = NULL,
  input_modalities = 'IMAGE',
  output_modalities = 'IMAGE',
  latency_ms = 2000,
  rate_limit_per_min = 100,
  max_input_size_mb = 50.00,
  languages = NULL,
  benchmarks = NULL,
  homepage_url = 'https://arxiv.org/abs/1906.00446',
  docs_url = 'https://github.com/deepmind/sonnet',
  supported_file_types = 'jpg, png, webp',
  data_retention = '오픈소스 모델이므로 온프레미스 배포 시 데이터가 외부로 전송되지 않습니다.'
WHERE (model_name LIKE '%VQ-VAE%' OR model_name LIKE '%VQVAE%' OR model_name LIKE '%vq-vae%') AND (description IS NULL OR description = '');

-- Perplexity AI 업데이트
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
WHERE (model_name LIKE '%Perplexity%' OR model_name LIKE '%perplexity%') AND (description IS NULL OR description = '');

-- 코멘트: 이 스크립트는 주요 AI 모델들의 설명과 사양을 업데이트합니다.
-- 실제 데이터베이스의 모델명에 맞춰 WHERE 절을 수정해야 할 수 있습니다.
-- 추가 모델이 있다면 동일한 형식으로 UPDATE 문을 추가하세요.

