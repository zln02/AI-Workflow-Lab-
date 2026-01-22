-- ============================================
-- Seed Data: Providers (Optional)
-- ============================================
-- 기본 제공사 데이터
INSERT INTO providers (provider_name, website, country) VALUES
('OpenAI', 'https://openai.com', 'USA'),
('Anthropic', 'https://www.anthropic.com', 'USA'),
('Google', 'https://ai.google', 'USA'),
('Meta', 'https://ai.meta.com', 'USA'),
('Microsoft', 'https://www.microsoft.com', 'USA'),
('Amazon', 'https://aws.amazon.com', 'USA'),
('Cohere', 'https://cohere.com', 'Canada'),
('Mistral AI', 'https://mistral.ai', 'France'),
('Hugging Face', 'https://huggingface.co', 'USA')
ON DUPLICATE KEY UPDATE provider_name = provider_name;

