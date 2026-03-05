-- ============================================
-- AI Navigator Database Schema
-- Railway DB Schema - Complete Structure
-- ============================================

-- 1. 관리자 테이블 (admins)
CREATE TABLE IF NOT EXISTS admins (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  name VARCHAR(100),
  email VARCHAR(100),
  role ENUM('SUPER','MANAGER','EDITOR','VIEWER') NOT NULL DEFAULT 'VIEWER',
  status ENUM('PENDING','ACTIVE','SUSPENDED') NOT NULL DEFAULT 'PENDING',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  last_login TIMESTAMP NULL,
  INDEX idx_username (username),
  INDEX idx_status (status),
  INDEX idx_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='관리자 계정';

-- 2. 제공사 테이블 (providers)
CREATE TABLE IF NOT EXISTS providers (
  id INT AUTO_INCREMENT PRIMARY KEY,
  provider_name VARCHAR(255) NOT NULL,
  website VARCHAR(255),
  country VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_provider_name (provider_name),
  INDEX idx_country (country)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='AI 모델 제공사';

-- 3. 카테고리 테이블 (categories)
CREATE TABLE IF NOT EXISTS categories (
  id INT AUTO_INCREMENT PRIMARY KEY,
  category_name VARCHAR(100) NOT NULL UNIQUE,
  INDEX idx_category_name (category_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='AI 모델 카테고리';

-- 4. AI 모델 테이블 (ai_models)
CREATE TABLE IF NOT EXISTS ai_models (
  id INT AUTO_INCREMENT PRIMARY KEY,
  provider_id INT,
  category_id INT,
  model_name VARCHAR(255) NOT NULL,
  price VARCHAR(100),
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  purpose_summary VARCHAR(200),
  input_modalities SET('TEXT','IMAGE','AUDIO','VIDEO','PDF','CODE'),
  output_modalities SET('TEXT','IMAGE','AUDIO','VIDEO'),
  languages JSON,
  benchmarks JSON,
  params_billion DECIMAL(6,2),
  latency_ms INT,
  rate_limit_per_min INT,
  api_available TINYINT(1) NOT NULL DEFAULT 1,
  finetune_available TINYINT(1) NOT NULL DEFAULT 0,
  onprem_available TINYINT(1) NOT NULL DEFAULT 0,
  hosting_options SET('CLOUD','ON_PREM','EDGE'),
  license_type ENUM('FREE','COMMERCIAL','OPEN_SOURCE','MIXED'),
  commercial_use_allowed TINYINT(1) NOT NULL DEFAULT 1,
  data_retention TEXT,
  privacy_url VARCHAR(255),
  tos_url VARCHAR(255),
  homepage_url VARCHAR(255),
  docs_url VARCHAR(255),
  playground_url VARCHAR(255),
  max_input_size_mb DECIMAL(8,2),
  supported_file_types VARCHAR(255),
  FOREIGN KEY (provider_id) REFERENCES providers(id) ON DELETE SET NULL,
  FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL,
  INDEX idx_provider_id (provider_id),
  INDEX idx_category_id (category_id),
  INDEX idx_model_name (model_name),
  INDEX idx_api_available (api_available),
  INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='AI 모델 정보';

-- 5. 태그 테이블 (tags)
CREATE TABLE IF NOT EXISTS tags (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tag_name VARCHAR(100) NOT NULL UNIQUE,
  INDEX idx_tag_name (tag_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='AI 모델 태그';

-- 6. 모델-태그 연결 테이블 (model_tags)
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

-- 7. 패키지 테이블 (packages)
CREATE TABLE IF NOT EXISTS packages (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  price DECIMAL(12,2) NOT NULL,
  discount_price DECIMAL(12,2),
  category_id INT COMMENT '대표 카테고리 (관리자 추천용)',
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL,
  INDEX idx_category_id (category_id),
  INDEX idx_active (active),
  INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='AI 모델 패키지';

-- 7-1. 패키지-카테고리 연결 테이블 (package_categories)
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

-- 8. 패키지 아이템 테이블 (package_items)
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

-- 9. 장바구니 테이블 (cart)
CREATE TABLE IF NOT EXISTS cart (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NULL,
  session_id VARCHAR(255),
  item_type ENUM('MODEL','PACKAGE') NOT NULL,
  item_id INT NOT NULL,
  quantity INT NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_user_id (user_id),
  INDEX idx_session_id (session_id),
  INDEX idx_item (item_type, item_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='장바구니';

-- 10. 주문 테이블 (orders)
CREATE TABLE IF NOT EXISTS orders (
  id INT AUTO_INCREMENT PRIMARY KEY,
  customer_name VARCHAR(100) NOT NULL COMMENT '주문자 이름',
  customer_email VARCHAR(255) NOT NULL COMMENT '주문자 이메일',
  customer_phone VARCHAR(20) COMMENT '주문자 전화번호',
  payment_method VARCHAR(50) NOT NULL COMMENT '결제 방법',
  total_price DECIMAL(12,2) NOT NULL DEFAULT 0 COMMENT '총 결제금액',
  order_status VARCHAR(50) NOT NULL DEFAULT 'COMPLETED' COMMENT '주문 상태',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '주문일시',
  INDEX idx_created_at (created_at),
  INDEX idx_customer_email (customer_email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='주문 정보';

-- 11. 주문 아이템 테이블 (order_items)
CREATE TABLE IF NOT EXISTS order_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL COMMENT '주문 ID',
  item_type ENUM('MODEL', 'PACKAGE') NOT NULL COMMENT '아이템 타입',
  item_id INT NOT NULL COMMENT '아이템 ID',
  quantity INT NOT NULL DEFAULT 1 COMMENT '수량',
  price DECIMAL(12,2) NOT NULL COMMENT '단가',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시',
  INDEX idx_order_id (order_id),
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='주문 아이템';

-- 12. 검색 로그 테이블 (search_logs)
CREATE TABLE IF NOT EXISTS search_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  keyword VARCHAR(255),
  results INT NOT NULL DEFAULT 0,
  searched_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_keyword (keyword),
  INDEX idx_searched_at (searched_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='검색 로그';

