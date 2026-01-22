-- ============================================
-- Migration: Users Authentication System
-- Date: 2025-12-01
-- Description: 회원 시스템 테이블 생성
-- ============================================

-- Users 테이블
CREATE TABLE IF NOT EXISTS users (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL COMMENT '이메일 (로그인 ID)',
  password_hash VARCHAR(255) NOT NULL COMMENT 'BCrypt 해시된 비밀번호',
  name VARCHAR(100) NOT NULL COMMENT '사용자 이름',
  status ENUM('ACTIVE', 'DISABLED') DEFAULT 'ACTIVE' COMMENT '계정 상태',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '가입일시',
  last_login TIMESTAMP NULL COMMENT '마지막 로그인 일시',
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_email (email),
  INDEX idx_status (status),
  INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='사용자 계정';



