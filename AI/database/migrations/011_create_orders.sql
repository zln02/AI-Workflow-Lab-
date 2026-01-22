-- ============================================
-- Migration 011: Create orders and order_items tables
-- ============================================
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

CREATE TABLE IF NOT EXISTS order_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL COMMENT '주문 ID',
  item_type ENUM('MODEL', 'PACKAGE') NOT NULL COMMENT '아이템 타입',
  item_id INT NOT NULL COMMENT '아이템 ID',
  quantity INT NOT NULL DEFAULT 1 COMMENT '수량',
  price DECIMAL(12,2) NOT NULL COMMENT '단가',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시',
  PRIMARY KEY (id),
  INDEX idx_order_id (order_id),
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='주문 아이템';

