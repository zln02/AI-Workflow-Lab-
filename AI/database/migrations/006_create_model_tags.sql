-- ============================================
-- Migration 006: Create model_tags table
-- ============================================
CREATE TABLE IF NOT EXISTS model_tags (
  id INT AUTO_INCREMENT PRIMARY KEY,
  model_id INT NOT NULL,
  tag_id INT NOT NULL,
  FOREIGN KEY (model_id) REFERENCES ai_models(id) ON DELETE CASCADE,
  FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE,
  UNIQUE KEY uk_model_tag (model_id, tag_id),
  INDEX idx_model_id (model_id),
  INDEX idx_tag_id (tag_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='모델-태그 연결';

