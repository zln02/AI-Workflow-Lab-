-- ============================================
-- Migration 008: Create package_items table
-- ============================================
CREATE TABLE IF NOT EXISTS package_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  package_id INT NOT NULL,
  model_id INT NOT NULL,
  quantity INT NOT NULL DEFAULT 1,
  FOREIGN KEY (package_id) REFERENCES packages(id) ON DELETE CASCADE,
  FOREIGN KEY (model_id) REFERENCES ai_models(id) ON DELETE CASCADE,
  UNIQUE KEY uk_package_model (package_id, model_id),
  INDEX idx_package_id (package_id),
  INDEX idx_model_id (model_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='패키지 구성 아이템';

