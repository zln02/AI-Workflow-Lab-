-- ============================================
-- order_items 테이블 생성
-- ============================================

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


