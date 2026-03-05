-- ============================================
-- AI Workflow Lab 데이터베이스 스키마
-- AI 도구 추천 + 실무 프로젝트 경험 플랫폼
-- ============================================

-- 1. AI 도구 추천 시스템 테이블
CREATE TABLE IF NOT EXISTS ai_tools (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tool_name VARCHAR(255) NOT NULL,
    provider_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    subcategory VARCHAR(50),
    description TEXT,
    purpose_summary VARCHAR(500),
    use_cases JSON,
    features JSON,
    pricing_model VARCHAR(50),
    pricing_details JSON,
    api_available BOOLEAN DEFAULT TRUE,
    free_tier_available BOOLEAN DEFAULT FALSE,
    website_url VARCHAR(500),
    docs_url VARCHAR(500),
    playground_url VARCHAR(500),
    supported_languages JSON,
    input_modalities VARCHAR(200),
    output_modalities VARCHAR(200),
    max_file_size_mb DECIMAL(10,2),
    rate_limit_per_min INT,
    commercial_use_allowed BOOLEAN DEFAULT FALSE,
    onprem_available BOOLEAN DEFAULT FALSE,
    license_type VARCHAR(50),
    difficulty_level ENUM('Beginner', 'Intermediate', 'Advanced') DEFAULT 'Beginner',
    tags JSON,
    rating DECIMAL(3,2) DEFAULT 0.00,
    review_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_category (category),
    INDEX idx_provider (provider_name),
    INDEX idx_difficulty (difficulty_level),
    INDEX idx_rating (rating),
    FULLTEXT idx_search (tool_name, description, purpose_summary)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. 워크플로우 가이드 테이블
CREATE TABLE IF NOT EXISTS workflow_guides (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100) NOT NULL,
    difficulty_level ENUM('Beginner', 'Intermediate', 'Advanced') DEFAULT 'Beginner',
    estimated_duration_minutes INT,
    prerequisites JSON,
    learning_objectives JSON,
    steps JSON,
    tools_required JSON,
    sample_prompts JSON,
    tips_tricks TEXT,
    common_mistakes JSON,
    created_by VARCHAR(100),
    view_count INT DEFAULT 0,
    like_count INT DEFAULT 0,
    is_published BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_category (category),
    INDEX idx_difficulty (difficulty_level),
    INDEX idx_published (is_published)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. 실습 랩 프로젝트 테이블
CREATE TABLE IF NOT EXISTS lab_projects (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100) NOT NULL,
    difficulty_level ENUM('Beginner', 'Intermediate', 'Advanced') DEFAULT 'Beginner',
    project_type ENUM('Tutorial', 'Challenge', 'Real-world') DEFAULT 'Tutorial',
    business_context TEXT,
    project_goals JSON,
    requirements JSON,
    step_by_step_guide JSON,
    expected_outcomes JSON,
    evaluation_criteria JSON,
    hints JSON,
    solution_guide JSON,
    tools_required JSON,
    estimated_duration_hours DECIMAL(5,2),
    max_participants INT,
    current_participants INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_by VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_category (category),
    INDEX idx_difficulty (difficulty_level),
    INDEX idx_type (project_type),
    INDEX idx_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. 사용자 학습 진행도 테이블
CREATE TABLE IF NOT EXISTS user_progress (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    item_type ENUM('tool', 'guide', 'project') NOT NULL,
    item_id INT NOT NULL,
    status ENUM('Not Started', 'In Progress', 'Completed') DEFAULT 'Not Started',
    progress_percentage DECIMAL(5,2) DEFAULT 0.00,
    started_at TIMESTAMP NULL,
    completed_at TIMESTAMP NULL,
    notes TEXT,
    bookmarks JSON,
    time_spent_minutes INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_item (user_id, item_type, item_id),
    INDEX idx_user_status (user_id, status),
    INDEX idx_item_type (item_type, item_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. 프로젝트 결과/포트폴리오 테이블
CREATE TABLE IF NOT EXISTS project_results (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    project_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    process_description TEXT,
    results_json JSON,
    files_attached JSON,
    tools_used JSON,
    skills_gained JSON,
    challenges_faced TEXT,
    lessons_learned TEXT,
    business_impact TEXT,
    is_public BOOLEAN DEFAULT FALSE,
    featured BOOLEAN DEFAULT FALSE,
    view_count INT DEFAULT 0,
    like_count INT DEFAULT 0,
    completed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (project_id) REFERENCES lab_projects(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_project (project_id),
    INDEX idx_public (is_public),
    INDEX idx_featured (featured)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. AI 도구 추천 히스토리 테이블
CREATE TABLE IF NOT EXISTS tool_recommendations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    session_id VARCHAR(255),
    query_text TEXT NOT NULL,
    query_context JSON,
    recommended_tools JSON,
    user_feedback ENUM('Helpful', 'Not Helpful', 'Neutral') NULL,
    feedback_notes TEXT,
    clicked_tool_id INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (clicked_tool_id) REFERENCES ai_tools(id) ON DELETE SET NULL,
    INDEX idx_user (user_id),
    INDEX idx_session (session_id),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 7. 커뮤니티 리뷰/평가 테이블
CREATE TABLE IF NOT EXISTS community_reviews (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    item_type ENUM('tool', 'guide', 'project', 'result') NOT NULL,
    item_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    pros TEXT,
    cons TEXT,
    helpful_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_item_review (user_id, item_type, item_id),
    INDEX idx_item (item_type, item_id),
    INDEX idx_rating (rating)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8. 학습 경로 추천 테이블
CREATE TABLE IF NOT EXISTS learning_paths (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    target_audience VARCHAR(255),
    difficulty_level ENUM('Beginner', 'Intermediate', 'Advanced') DEFAULT 'Beginner',
    duration_weeks INT,
    modules JSON,
    prerequisites JSON,
    learning_outcomes JSON,
    is_active BOOLEAN DEFAULT TRUE,
    enrollment_count INT DEFAULT 0,
    created_by VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_difficulty (difficulty_level),
    INDEX idx_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 9. 사용자 학습 경로 등록 테이블
CREATE TABLE IF NOT EXISTS user_learning_paths (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    path_id INT NOT NULL,
    enrollment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completion_date TIMESTAMP NULL,
    progress_percentage DECIMAL(5,2) DEFAULT 0.00,
    current_module INT DEFAULT 1,
    status ENUM('Active', 'Completed', 'Dropped') DEFAULT 'Active',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (path_id) REFERENCES learning_paths(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_path (user_id, path_id),
    INDEX idx_user_status (user_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 10. 북마크 테이블
CREATE TABLE IF NOT EXISTS user_bookmarks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    item_type ENUM('tool', 'guide', 'project', 'result', 'path') NOT NULL,
    item_id INT NOT NULL,
    folder_name VARCHAR(100) DEFAULT 'General',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_item_bookmark (user_id, item_type, item_id),
    INDEX idx_user_folder (user_id, folder_name),
    INDEX idx_item_type (item_type, item_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 11. 스킬 태그 테이블
CREATE TABLE IF NOT EXISTS skill_tags (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tag_name VARCHAR(100) NOT NULL UNIQUE,
    category VARCHAR(50),
    description TEXT,
    usage_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_category (category),
    INDEX idx_usage (usage_count DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 12. 아이템-스킬 연결 테이블
CREATE TABLE IF NOT EXISTS item_skill_tags (
    id INT AUTO_INCREMENT PRIMARY KEY,
    item_type ENUM('tool', 'guide', 'project', 'result') NOT NULL,
    item_id INT NOT NULL,
    skill_id INT NOT NULL,
    relevance_score DECIMAL(3,2) DEFAULT 1.00 CHECK (relevance_score >= 0.00 AND relevance_score <= 5.00),
    FOREIGN KEY (skill_id) REFERENCES skill_tags(id) ON DELETE CASCADE,
    UNIQUE KEY unique_item_skill (item_type, item_id, skill_id),
    INDEX idx_skill (skill_id),
    INDEX idx_relevance (relevance_score DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 13. 사용자 활동 로그 테이블
CREATE TABLE IF NOT EXISTS user_activity_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    activity_type VARCHAR(50) NOT NULL,
    item_type ENUM('tool', 'guide', 'project', 'result', 'path') NULL,
    item_id INT NULL,
    details JSON,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_user_activity (user_id, activity_type, created_at),
    INDEX idx_item (item_type, item_id),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 기본 데이터 삽입
-- ============================================

-- 스킬 태그 기본 데이터
INSERT IGNORE INTO skill_tags (tag_name, category, description) VALUES
('Text Generation', 'AI', '텍스트 생성 및 요약 기술'),
('Image Generation', 'AI', '이미지 생성 및 편집 기술'),
('Data Analysis', 'Business', '데이터 분석 및 시각화'),
('Content Creation', 'Creative', '콘텐츠 제작 및 편집'),
('Automation', 'Productivity', '업무 자동화 및 효율화'),
('Translation', 'Language', '다국어 번역'),
('Code Generation', 'Development', '코드 생성 및 프로그래밍'),
('Voice Processing', 'Audio', '음성 인식 및 합성'),
('Video Processing', 'Video', '비디오 생성 및 편집'),
('Business Strategy', 'Business', '비즈니스 전략 수립'),
('Marketing', 'Business', '마케팅 및 광고'),
('Research', 'Academic', '학술 연구 및 조사');

-- 카테고리별 샘플 AI 도구 데이터
INSERT IGNORE INTO ai_tools (tool_name, provider_name, category, subcategory, description, purpose_summary, difficulty_level, rating, review_count) VALUES
('ChatGPT', 'OpenAI', 'Text Generation', 'Conversational AI', 'GPT-4 기반의 대화형 AI 어시스턴트로, 다양한 질문에 답변하고 텍스트를 생성합니다.', '자연어 대화, 질문 답변, 텍스트 생성', 'Beginner', 4.50, 1250),
('DALL-E 3', 'OpenAI', 'Image Generation', 'Text-to-Image', '텍스트 설명만으로 고품질의 이미지를 생성하는 AI 모델입니다.', '텍스트 기반 이미지 생성', 'Beginner', 4.30, 890),
('GitHub Copilot', 'GitHub', 'Code Generation', 'AI Assistant', 'AI 기반 코드 자동 완성 도구로, 개발 생산성을 크게 향상시킵니다.', 'AI 기반 코드 자동 완성', 'Intermediate', 4.60, 2100),
('Gemini Pro', 'Google', 'Text Generation', 'Multimodal AI', '텍스트, 이미지, 오디오, 비디오를 동시에 이용하는 멀티모달 AI 모델입니다.', '멀티모달 AI 통합 처리', 'Intermediate', 4.40, 650),
('Claude', 'Anthropic', 'Text Generation', 'Conversational AI', '안전하고 도움이 되는 AI 어시스턴트로, 긴 문서 분석에 특화되어 있습니다.', '안전한 AI 어시스턴트, 긴 문서 분석', 'Beginner', 4.55, 980),
('Midjourney', 'Midjourney Labs', 'Image Generation', 'Artistic AI', '예술적이고 창의적인 이미지 생성에 특화된 AI입니다.', '예술적 이미지 생성', 'Intermediate', 4.35, 760),
('Whisper', 'OpenAI', 'Voice Processing', 'Speech-to-Text', '다국어 음성 인식 시스템으로, 정확한 음성-텍스트 변환을 제공합니다.', '다국어 음성 인식 및 번역', 'Beginner', 4.25, 440),
('Stable Diffusion', 'Stability AI', 'Image Generation', 'Text-to-Image', '오픈소스 이미지 생성 모델로, 상업적 이용이 가능합니다.', '오픈소스 이미지 생성', 'Advanced', 4.20, 820);

-- 샘플 워크플로우 가이드
INSERT IGNORE INTO workflow_guides (title, description, category, difficulty_level, estimated_duration_minutes, prerequisites, learning_objectives, is_published) VALUES
('ChatGPT로 블로그 포스트 작성하기', 'ChatGPT를 활용하여 매력적인 블로그 포스트를 작성하는 방법을 단계별로 안내합니다.', 'Content Creation', 'Beginner', 30, 
'["ChatGPT 계정", "기본적인 글쓰기 능력"]', 
'["효과적인 프롬프트 작성법", "블로그 구조화 방법", "콘텐츠 개선 팁"]', 
TRUE),
('DALL-E 3으로 마케팅 이미지 만들기', 'DALL-E 3를 사용하여 브랜드에 맞는 마케팅 이미지를 생성하는 과정을 배웁니다.', 'Marketing', 'Intermediate', 45,
'["DALL-E 3 접근 권한", "기본 디자인 지식"]',
'["프롬프트 엔지니어링", "스타일 일관성 유지", "상업적 이미지 제작"]',
TRUE),
('GitHub Copilot으로 코딩 효율 높이기', 'GitHub Copilot을 최대한 활용하여 코딩 속도와 품질을 향상시키는 방법을 배웁니다.', 'Development', 'Intermediate', 60,
'["VS Code 또는 지원 IDE", "기본 프로그래밍 지식"]',
'["Copilot 명령어 마스터", "코드 품질 유지", "생산성 팁"]',
TRUE);

-- 샘플 실습 프로젝트
INSERT IGNORE INTO lab_projects (title, description, category, difficulty_level, project_type, business_context, project_goals, estimated_duration_hours) VALUES
('AI 챗봇 고객 서비스 구축', 'ChatGPT API를 활용하여 기업용 고객 서비스 챗봇을 구축하는 실습 프로젝트입니다.', 'Customer Service', 'Intermediate', 'Real-world', 
'대표적인 이커머스 기업의 고객 문의 응대 시간을 50% 단축하고 24/7 서비스를 제공해야 합니다.',
'["ChatGPT API 연동", "고객 문의 자동 분류", "답변 템플릿 구축", "핸드오프 프로세스 설계"]',
3.5),
('AI 이미지로 소셜미디어 콘텐츠 대량 생산', 'DALL-E 3를 사용하여 소셜미디어 마케팅 캠페인용 이미지를 대량으로 생성하는 방법을 배웁니다.', 'Marketing', 'Beginner', 'Tutorial',
'스타트업 마케팅팀이 한 달간 사용할 소셜미디어 이미지 30개를 제한된 예산으로 제작해야 합니다.',
'["브랜드 스타일 가이드 정의", "효율적인 프롬프트 템플릿 생성", "이미지 일관성 유지", "배치 프로세스 구축"]',
2.0),
('AI 코드 리뷰 자동화 시스템', 'GitHub Copilot과 추가 AI 도구를 활용하여 코드 리뷰 프로세스를 자동화하는 시스템을 구축합니다.', 'Development', 'Advanced', 'Challenge',
'개발팀의 코드 리뷰 시간을 40% 단축하고 코드 품질을 일관되게 유지해야 합니다.',
'["코드 품질 기준 정의", "자동 리뷰 규칙 설정", "CI/CD 파이프라인 연동", "팀워크 통합"]',
5.0);

-- 샘플 학습 경로
INSERT IGNORE INTO learning_paths (title, description, target_audience, difficulty_level, duration_weeks, modules) VALUES
('AI 콘텐츠 마케터 양성 과정', '초보자를 위한 AI 활용 콘텐츠 마케팅 종합 과정입니다. ChatGPT, DALL-E 등 다양한 AI 도구를 활용하는 법을 배웁니다.', '마케팅 초보자, 콘텐츠 제작자', 'Beginner', 4,
'[
  {"module": 1, "title": "AI 도구 소개 및 계정 설정", "duration": 3, "items": ["tool:1", "tool:2"]},
  {"module": 2, "title": "텍스트 생성 마스터하기", "duration": 7, "items": ["guide:1", "project:1"]},
  {"module": 3, "title": "이미지 생성 활용법", "duration": 10, "items": ["guide:2", "project:2"]},
  {"module": 4, "title": "실전 캠페인 실행", "duration": 8, "items": ["project:3"]}
]'),
('AI 개발자 실무 과정', '개발자를 위한 AI 도구 활용 실무 과정입니다. 코드 생성, 리뷰 자동화 등 실용적인 기술을 배웁니다.', '주니어 개발자, 개발팀 리더', 'Intermediate', 6,
'[
  {"module": 1, "title": "AI 코딩 도구 설정", "duration": 4, "items": ["tool:3"]},
  {"module": 2, "title": "효율적인 코드 생성", "duration": 8, "items": ["guide:3"]},
  {"module": 3, "title": "코드 품질 관리", "duration": 10, "items": ["project:3"]},
  {"module": 4, "title": "팀协作 워크플로우", "duration": 12, "items": ["project:1", "project:2"]},
  {"module": 5, "title": "고급 자동화 기법", "duration": 8, "items": ["guide:1", "guide:2"]},
  {"module": 6, "title": "포트폴리오 프로젝트", "duration": 10, "items": ["project:3"]}
]');

-- ============================================
-- 뷰 생성 (편의를 위한 가상 테이블)
-- ============================================

-- 사용자 학습 현황 종합 뷰
CREATE OR REPLACE VIEW user_learning_summary AS
SELECT 
    u.id as user_id,
    u.username,
    COUNT(CASE WHEN up.status = 'Completed' THEN 1 END) as completed_items,
    COUNT(CASE WHEN up.status = 'In Progress' THEN 1 END) as in_progress_items,
    COUNT(CASE WHEN up.status = 'Not Started' THEN 1 END) as not_started_items,
    AVG(up.progress_percentage) as overall_progress,
    SUM(up.time_spent_minutes) as total_time_spent
FROM users u
LEFT JOIN user_progress up ON u.id = up.user_id
GROUP BY u.id, u.username;

-- 인기 AI 도구 순위 뷰
CREATE OR REPLACE VIEW popular_tools AS
SELECT 
    t.*,
    COUNT(cr.id) as review_count,
    AVG(cr.rating) as avg_rating,
    COUNT(DISTINCT tr.id) as recommendation_count
FROM ai_tools t
LEFT JOIN community_reviews cr ON t.id = cr.item_id AND cr.item_type = 'tool'
LEFT JOIN tool_recommendations tr ON t.id = tr.clicked_tool_id
GROUP BY t.id
ORDER BY avg_rating DESC, review_count DESC;

-- 프로젝트 결과 갤러리 뷰
CREATE OR REPLACE VIEW project_gallery AS
SELECT 
    pr.*,
    p.title as project_title,
    p.category as project_category,
    u.username as author_username,
    COUNT(DISTINCT prl.id) as like_count,
    COUNT(DISTINCT cr.id) as review_count
FROM project_results pr
JOIN lab_projects p ON pr.project_id = p.id
JOIN users u ON pr.user_id = u.id
LEFT JOIN user_activity_logs prl ON prl.activity_type = 'like_result' AND prl.item_id = pr.id
LEFT JOIN community_reviews cr ON cr.item_id = pr.id AND cr.item_type = 'result'
WHERE pr.is_public = TRUE
GROUP BY pr.id;

-- ============================================
-- 트리거 생성 (데이터 자동 업데이트)
-- ============================================

DELIMITER //

-- 스킬 태그 사용 카운트 업데이트 트리거
CREATE TRIGGER update_skill_usage_count
    AFTER INSERT ON item_skill_tags
    FOR EACH ROW
BEGIN
    UPDATE skill_tags 
    SET usage_count = usage_count + 1 
    WHERE id = NEW.skill_id;
END//

-- 도구 추천 시 자동 로그 생성 트리거
CREATE TRIGGER log_tool_recommendation
    AFTER INSERT ON tool_recommendations
    FOR EACH ROW
BEGIN
    INSERT INTO user_activity_logs (user_id, activity_type, item_type, item_id, details)
    VALUES (NEW.user_id, 'tool_recommended', 'tool', NEW.clicked_tool_id, 
            JSON_OBJECT('query', NEW.query_text, 'tools_count', JSON_LENGTH(NEW.recommended_tools)));
END//

-- 프로젝트 완료 시 진행도 업데이트 트리거
CREATE TRIGGER update_project_completion
    AFTER INSERT ON project_results
    FOR EACH ROW
BEGIN
    UPDATE user_progress 
    SET status = 'Completed', 
        progress_percentage = 100.00,
        completed_at = NOW()
    WHERE user_id = NEW.user_id 
      AND item_type = 'project' 
      AND item_id = NEW.project_id;
END//

DELIMITER ;

-- ============================================
-- 스키마 설명
-- ============================================
/*
이 스키마는 AI Workflow Lab 플랫폼의 핵심 기능을 지원합니다:

1. AI 도구 추천 (ai_tools, tool_recommendations)
2. 워크플로우 가이드 (workflow_guides)
3. 실습 랩 (lab_projects, project_results)
4. 학습 관리 (user_progress, learning_paths)
5. 커뮤니티 (community_reviews, user_activity_logs)
6. 포트폴리오 (project_results)
7. 개인화 (user_bookmarks, skill_tags)

각 테이블은 확장 가능한 구조로 설계되었으며,
JSON 필드를 통해 유연한 데이터 저장을 지원합니다.
*/
