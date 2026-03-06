-- ============================================
-- Seed Data: Admins
-- ============================================
-- 기본 SUPER 관리자 계정 생성
-- 주의: 실제 배포 시 이메일 주소와 비밀번호를 변경하세요
-- 비밀번호는 BCrypt로 해싱되어야 합니다
-- 예시: 비밀번호 'your-password'를 BCrypt로 해싱한 값을 사용하세요
INSERT INTO admins (username, password, name, email, role, status) VALUES
('admin', '$2a$10$CHANGE_THIS_HASHED_PASSWORD', '시스템 관리자', 'admin@yourdomain.com', 'SUPER', 'ACTIVE')
ON DUPLICATE KEY UPDATE username = username;
