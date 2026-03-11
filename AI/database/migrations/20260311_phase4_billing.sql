CREATE TABLE IF NOT EXISTS plans (
  id INT AUTO_INCREMENT PRIMARY KEY,
  plan_code VARCHAR(50) NOT NULL UNIQUE,
  plan_name VARCHAR(100) NOT NULL,
  plan_name_ko VARCHAR(100) NOT NULL,
  plan_type ENUM('free','starter','pro','enterprise') NOT NULL,
  billing_cycle ENUM('monthly','yearly','lifetime') DEFAULT 'monthly',
  price_monthly DECIMAL(12,2) NOT NULL DEFAULT 0,
  price_yearly DECIMAL(12,2) DEFAULT NULL,
  currency VARCHAR(10) DEFAULT 'KRW',
  credits_monthly INT NOT NULL DEFAULT 0,
  credits_rollover TINYINT(1) DEFAULT 0,
  max_api_calls_daily INT DEFAULT NULL,
  max_projects INT DEFAULT NULL,
  features JSON DEFAULT NULL,
  is_popular TINYINT(1) DEFAULT 0,
  is_active TINYINT(1) DEFAULT 1,
  display_order INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO plans (plan_code, plan_name, plan_name_ko, plan_type, billing_cycle, price_monthly, price_yearly, currency, credits_monthly, max_api_calls_daily, max_projects, features, is_popular, is_active, display_order)
VALUES
('free', 'Free', '무료', 'free', 'monthly', 0, 0, 'KRW', 50, 20, 3, '{"tools_access":"basic","lab_access":"basic_only"}', 0, 1, 1),
('starter', 'Starter', '스타터', 'starter', 'monthly', 9900, 99000, 'KRW', 500, 100, 10, '{"tools_access":"full","lab_access":"all"}', 0, 1, 2),
('pro', 'Professional', '프로', 'pro', 'monthly', 29900, 299000, 'KRW', 2000, 500, 50, '{"tools_access":"full","lab_access":"all","advanced_analytics":true}', 1, 1, 3),
('enterprise', 'Enterprise', '엔터프라이즈', 'enterprise', 'yearly', 99900, 999000, 'KRW', 10000, -1, -1, '{"tools_access":"full","lab_access":"all","sso":true}', 0, 1, 4)
ON DUPLICATE KEY UPDATE
  plan_name = VALUES(plan_name),
  plan_name_ko = VALUES(plan_name_ko),
  price_monthly = VALUES(price_monthly),
  price_yearly = VALUES(price_yearly),
  credits_monthly = VALUES(credits_monthly),
  display_order = VALUES(display_order);

CREATE TABLE IF NOT EXISTS subscriptions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  plan_id INT DEFAULT NULL,
  plan_code VARCHAR(50) DEFAULT NULL,
  start_date DATE DEFAULT NULL,
  end_date DATE DEFAULT NULL,
  status VARCHAR(50) DEFAULT 'ACTIVE',
  payment_method VARCHAR(50) DEFAULT NULL,
  transaction_id VARCHAR(120) DEFAULT NULL,
  billing_cycle ENUM('monthly','yearly') DEFAULT 'monthly',
  next_billing_date DATE DEFAULT NULL,
  cancel_at_period_end TINYINT(1) DEFAULT 0,
  portone_customer_uid VARCHAR(100) DEFAULT NULL,
  last_payment_id INT DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_sub_user (user_id),
  INDEX idx_sub_plan (plan_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS credit_packages (
  id INT AUTO_INCREMENT PRIMARY KEY,
  package_name VARCHAR(100) NOT NULL,
  credits INT NOT NULL,
  price DECIMAL(12,2) NOT NULL,
  bonus_credits INT DEFAULT 0,
  is_active TINYINT(1) DEFAULT 1,
  display_order INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO credit_packages (package_name, credits, price, bonus_credits, is_active, display_order)
VALUES
('소량', 100, 3900, 0, 1, 1),
('기본', 500, 14900, 50, 1, 2),
('대량', 2000, 49900, 400, 1, 3),
('벌크', 10000, 199000, 3000, 1, 4)
ON DUPLICATE KEY UPDATE
  credits = VALUES(credits),
  price = VALUES(price),
  bonus_credits = VALUES(bonus_credits),
  display_order = VALUES(display_order);

CREATE TABLE IF NOT EXISTS user_credits (
  user_id INT PRIMARY KEY,
  total_granted INT NOT NULL DEFAULT 0,
  total_used INT NOT NULL DEFAULT 0,
  plan_code VARCHAR(50) DEFAULT NULL,
  reset_date DATE DEFAULT NULL,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS credit_usage_logs (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  credits_used INT NOT NULL DEFAULT 0,
  model_used VARCHAR(100) DEFAULT NULL,
  prompt_tokens INT NOT NULL DEFAULT 0,
  output_tokens INT NOT NULL DEFAULT 0,
  feature VARCHAR(100) DEFAULT NULL,
  project_id INT DEFAULT NULL,
  request_summary VARCHAR(255) DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_credit_usage_user (user_id, created_at DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
