-- ============================================
-- Migration 010: Create search_logs table
-- ============================================
CREATE TABLE IF NOT EXISTS search_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  keyword VARCHAR(255),
  results INT NOT NULL DEFAULT 0,
  searched_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_keyword (keyword),
  INDEX idx_searched_at (searched_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='검색 로그';

