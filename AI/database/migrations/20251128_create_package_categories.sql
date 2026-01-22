-- 패키지-카테고리 다중 연결 테이블 생성
-- 실행일: 2025-11-28

CREATE TABLE IF NOT EXISTS package_categories (
  id INT AUTO_INCREMENT PRIMARY KEY,
  package_id INT NOT NULL,
  category_id INT NOT NULL,
  FOREIGN KEY (package_id) REFERENCES packages(id) ON DELETE CASCADE,
  FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE,
  UNIQUE KEY uk_package_category (package_id, category_id),
  INDEX idx_package_id (package_id),
  INDEX idx_category_id (category_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='패키지-카테고리 다중 연결';
