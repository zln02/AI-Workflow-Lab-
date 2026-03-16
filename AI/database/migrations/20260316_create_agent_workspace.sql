CREATE TABLE IF NOT EXISTS agent_templates (
  id INT AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(100) NOT NULL UNIQUE,
  name VARCHAR(150) NOT NULL,
  description TEXT NOT NULL,
  system_prompt LONGTEXT NOT NULL,
  output_schema_json TEXT NULL,
  badge_label VARCHAR(100) NULL,
  suggested_goal VARCHAR(255) NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS agent_runs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT NOT NULL,
  template_id INT NULL,
  title VARCHAR(200) NOT NULL,
  user_goal TEXT NOT NULL,
  status VARCHAR(50) NOT NULL DEFAULT 'completed',
  model_used VARCHAR(100) NULL,
  prompt_tokens INT NOT NULL DEFAULT 0,
  output_tokens INT NOT NULL DEFAULT 0,
  credits_used DECIMAL(10,2) NOT NULL DEFAULT 0,
  final_output_json LONGTEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_agent_runs_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_agent_runs_template FOREIGN KEY (template_id) REFERENCES agent_templates(id) ON DELETE SET NULL,
  INDEX idx_agent_runs_user_created (user_id, created_at DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO agent_templates (code, name, description, system_prompt, output_schema_json, badge_label, suggested_goal, is_active)
SELECT 'market-research', '시장 조사 에이전트',
       '요청 주제의 핵심 시장 상황, 추천 AI 도구, 실행 단계, 리스크를 한 번에 정리합니다.',
       '당신은 AI Workflow Lab의 시장 조사 에이전트입니다. 사용자의 목표를 분석하고 반드시 한국어 JSON만 반환하세요. 형식은 {"summary":"", "recommendedTools":[""], "executionPlan":[""], "deliverables":{"report":"", "slidesOutline":[""], "checklist":[""]}} 이어야 합니다. 각 항목은 실무적으로 구체적이어야 하며, 추천 도구는 이유를 함께 자연어로 포함하세요.',
       '{"summary":"string","recommendedTools":["string"],"executionPlan":["string"],"deliverables":{"report":"string","slidesOutline":["string"],"checklist":["string"]}}',
       'Research',
       '국내 B2B 고객지원 팀을 위한 생성형 AI 도입 전략을 조사해줘.',
       1
WHERE NOT EXISTS (SELECT 1 FROM agent_templates WHERE code = 'market-research');

INSERT INTO agent_templates (code, name, description, system_prompt, output_schema_json, badge_label, suggested_goal, is_active)
SELECT 'tool-comparison', 'AI 도구 비교 에이전트',
       '복수의 도구를 비교해 추천 조합과 도입 기준을 제안합니다.',
       '당신은 AI Workflow Lab의 도구 비교 에이전트입니다. 사용자의 목표를 바탕으로 반드시 한국어 JSON만 반환하세요. 형식은 {"summary":"", "recommendedTools":[""], "executionPlan":[""], "deliverables":{"report":"", "slidesOutline":[""], "checklist":[""]}} 이어야 합니다. 비교 기준, 선택 이유, 추천 조합, 도입 시 주의점을 포함하세요.',
       '{"summary":"string","recommendedTools":["string"],"executionPlan":["string"],"deliverables":{"report":"string","slidesOutline":["string"],"checklist":["string"]}}',
       'Compare',
       '콘텐츠 팀에서 쓸 텍스트 생성 도구 3개를 비교해줘.',
       1
WHERE NOT EXISTS (SELECT 1 FROM agent_templates WHERE code = 'tool-comparison');

INSERT INTO agent_templates (code, name, description, system_prompt, output_schema_json, badge_label, suggested_goal, is_active)
SELECT 'launch-plan', '실행 계획 에이전트',
       '실행 로드맵, 체크리스트, 발표 개요까지 한 번에 생성합니다.',
       '당신은 AI Workflow Lab의 실행 계획 에이전트입니다. 사용자의 목표를 바탕으로 반드시 한국어 JSON만 반환하세요. 형식은 {"summary":"", "recommendedTools":[""], "executionPlan":[""], "deliverables":{"report":"", "slidesOutline":[""], "checklist":[""]}} 이어야 합니다. 일정, 우선순위, 담당 역할, 빠른 시작 방법이 드러나야 합니다.',
       '{"summary":"string","recommendedTools":["string"],"executionPlan":["string"],"deliverables":{"report":"string","slidesOutline":["string"],"checklist":["string"]}}',
       'Launch',
       '사내 AI 파일럿 프로그램의 4주 실행 계획을 만들어줘.',
       1
WHERE NOT EXISTS (SELECT 1 FROM agent_templates WHERE code = 'launch-plan');
