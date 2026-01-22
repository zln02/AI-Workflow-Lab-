-- ============================================
-- Migration: Plans and Subscriptions
-- Date: 2025-11-30
-- Description: 요금제 및 구독 시스템 테이블 생성
-- ============================================

-- 요금제 테이블
CREATE TABLE IF NOT EXISTS plans (
  id INT AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(30) UNIQUE NOT NULL COMMENT '요금제 코드 (STARTER, GROWTH, PRO)',
  name VARCHAR(50) NOT NULL COMMENT '요금제 이름',
  duration_months INT NOT NULL COMMENT '구독 기간 (개월)',
  price_usd DECIMAL(10,2) NOT NULL COMMENT '가격 (USD)',
  description TEXT COMMENT '요금제 설명',
  features JSON COMMENT '포함 기능 목록',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='요금제 정보';

-- 요금제 데이터 삽입
INSERT INTO plans(code, name, duration_months, price_usd, description, features) VALUES
  ('STARTER', 'Starter', 1, 29.00, '1개월 무제한 사용', JSON_ARRAY('모든 모델 무제한', '모든 패키지 무제한', '우선 지원')),
  ('GROWTH', 'Growth', 6, 149.00, '6개월 무제한 사용', JSON_ARRAY('모든 모델 무제한', '모든 패키지 무제한', '우선 지원', 'API 우선 접근')),
  ('PRO', 'Pro', 12, 249.00, '1년 무제한 사용', JSON_ARRAY('모든 모델 무제한', '모든 패키지 무제한', '전담 지원', 'API 우선 접근', '맞춤 통합'))
ON DUPLICATE KEY UPDATE 
  name=VALUES(name), 
  duration_months=VALUES(duration_months), 
  price_usd=VALUES(price_usd),
  description=VALUES(description),
  features=VALUES(features);

-- 구독 테이블
CREATE TABLE IF NOT EXISTS subscriptions (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT NOT NULL COMMENT '사용자 ID (세션 기반이면 임시 ID)',
  plan_code VARCHAR(30) NOT NULL COMMENT '요금제 코드',
  start_date DATE NOT NULL COMMENT '구독 시작일',
  end_date DATE NOT NULL COMMENT '구독 종료일',
  status ENUM('ACTIVE','EXPIRED','CANCELLED') DEFAULT 'ACTIVE' COMMENT '구독 상태',
  payment_method VARCHAR(50) COMMENT '결제 방법',
  transaction_id VARCHAR(100) COMMENT '거래 ID',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_user_status (user_id, status),
  INDEX idx_status (status),
  INDEX idx_dates (start_date, end_date),
  CONSTRAINT fk_sub_plan FOREIGN KEY (plan_code) REFERENCES plans(code) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='구독 정보';

-- 검색 로그 테이블 (의도 기반 추천 개선용)
-- 기존 search_logs 테이블이 있으면 intent 컬럼 추가
SET @dbname = DATABASE();
SET @tablename = 'search_logs';
SET @columnname = 'intent';
SET @preparedStatement = (SELECT IF(
  (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE
      (TABLE_SCHEMA = @dbname)
      AND (TABLE_NAME = @tablename)
      AND (COLUMN_NAME = @columnname)
  ) > 0,
  'SELECT 1',
  CONCAT('ALTER TABLE ', @tablename, ' ADD COLUMN ', @columnname, ' VARCHAR(100) NULL COMMENT ''검색 의도 (coding, writing, image, audio, data, general)'' AFTER keyword')
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- user_id 컬럼 추가 (없으면)
SET @columnname = 'user_id';
SET @preparedStatement = (SELECT IF(
  (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE
      (TABLE_SCHEMA = @dbname)
      AND (TABLE_NAME = @tablename)
      AND (COLUMN_NAME = @columnname)
  ) > 0,
  'SELECT 1',
  CONCAT('ALTER TABLE ', @tablename, ' ADD COLUMN ', @columnname, ' BIGINT NULL COMMENT ''사용자 ID'' AFTER id')
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- keyword를 q로 변경 (없으면)
SET @columnname = 'q';
SET @oldcolumnname = 'keyword';
SET @preparedStatement = (SELECT IF(
  (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE
      (TABLE_SCHEMA = @dbname)
      AND (TABLE_NAME = @tablename)
      AND (COLUMN_NAME = @oldcolumnname)
  ) > 0 AND (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE
      (TABLE_SCHEMA = @dbname)
      AND (TABLE_NAME = @tablename)
      AND (COLUMN_NAME = @columnname)
  ) = 0,
  CONCAT('ALTER TABLE ', @tablename, ' CHANGE COLUMN ', @oldcolumnname, ' ', @columnname, ' VARCHAR(500) NOT NULL COMMENT ''검색어'''),
  'SELECT 1'
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;



