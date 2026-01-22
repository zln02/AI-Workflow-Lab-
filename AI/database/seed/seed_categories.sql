-- ============================================
-- Seed Data: Categories (Optional)
-- ============================================
-- 기본 카테고리 데이터
INSERT INTO categories (category_name) VALUES
('LLM (대규모 언어 모델)'),
('Text Generation (텍스트 생성)'),
('Code Generation (코드 생성)'),
('Translation (번역)'),
('Summarization (요약)'),
('Image Generation (이미지 생성)'),
('Image Understanding (이미지 이해)'),
('Video Generation (영상 생성)'),
('Video Understanding (영상 이해)'),
('Speech-to-Text (음성→텍스트)'),
('Text-to-Speech (텍스트→음성)'),
('Multi-modal (멀티모달)'),
('Embedding Model (임베딩)'),
('Search AI (검색AI)'),
('AI Agent / Automation (AI 에이전트·자동화)')
ON DUPLICATE KEY UPDATE category_name = category_name;

