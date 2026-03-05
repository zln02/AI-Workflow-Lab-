-- ============================================
-- Users 테이블 생성 (AI Workflow Lab용)
-- ============================================

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100),
    profile_image_url VARCHAR(500),
    bio TEXT,
    company VARCHAR(100),
    job_title VARCHAR(100),
    skills JSON,
    interests JSON,
    experience_level ENUM('Beginner', 'Intermediate', 'Advanced') DEFAULT 'Beginner',
    email_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_username (username),
    INDEX idx_experience (experience_level),
    INDEX idx_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 샘플 사용자 데이터 (테스트용)
INSERT IGNORE INTO users (username, email, password_hash, full_name, company, job_title, experience_level) VALUES
('testuser', 'test@example.com', '$2a$10$N9qo8uLOickgx2ZMRZoMye.IY4J.y5j7OWg6K8WQV3cLyOv4Zj2Ky', '테스트 사용자', '테스트 회사', '개발자', 'Intermediate'),
('beginner', 'beginner@example.com', '$2a$10$N9qo8uLOickgx2ZMRZoMye.IY4J.y5j7OWg6K8WQV3cLyOv4Zj2Ky', '초보자', '스타트업', '기획자', 'Beginner'),
('expert', 'expert@example.com', '$2a$10$N9qo8uLOickgx2ZMRZoMye.IY4J.y5j7OWg6K8WQV3cLyOv4Zj2Ky', '전문가', '대기업', 'AI 전문가', 'Advanced');
