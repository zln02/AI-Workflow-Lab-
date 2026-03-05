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
    COUNT(DISTINCT cr.id) as review_count_view,
    AVG(cr.rating) as avg_rating,
    COUNT(DISTINCT tr.id) as recommendation_count
FROM ai_tools t
LEFT JOIN community_reviews cr ON t.id = cr.item_id AND cr.item_type = 'tool'
LEFT JOIN tool_recommendations tr ON t.id = tr.clicked_tool_id
GROUP BY t.id
ORDER BY avg_rating DESC, review_count_view DESC;

-- 프로젝트 결과 갤러리 뷰
CREATE OR REPLACE VIEW project_gallery AS
SELECT 
    pr.*,
    p.title as project_title,
    p.category as project_category,
    u.username as author_username,
    COUNT(DISTINCT prl.id) as view_like_count,
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
DROP TRIGGER IF EXISTS update_skill_usage_count//
CREATE TRIGGER update_skill_usage_count
    AFTER INSERT ON item_skill_tags
    FOR EACH ROW
BEGIN
    UPDATE skill_tags 
    SET usage_count = usage_count + 1 
    WHERE id = NEW.skill_id;
END//

-- 도구 추천 시 자동 로그 생성 트리거
DROP TRIGGER IF EXISTS log_tool_recommendation//
CREATE TRIGGER log_tool_recommendation
    AFTER INSERT ON tool_recommendations
    FOR EACH ROW
BEGIN
    INSERT INTO user_activity_logs (user_id, activity_type, item_type, item_id, details)
    VALUES (NEW.user_id, 'tool_recommended', 'tool', NEW.clicked_tool_id, 
            JSON_OBJECT('query', NEW.query_text, 'tools_count', JSON_LENGTH(NEW.recommended_tools)));
END//

-- 프로젝트 완료 시 진행도 업데이트 트리거
DROP TRIGGER IF EXISTS update_project_completion//
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
