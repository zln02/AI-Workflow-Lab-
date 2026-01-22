-- ============================================
-- HR 현황 데이터베이스 스키마
-- ============================================

-- HR 데이터 테이블
CREATE TABLE IF NOT EXISTS hr_data (
  id INT AUTO_INCREMENT PRIMARY KEY,
  department VARCHAR(100) COMMENT '본부',
  division VARCHAR(100) COMMENT '사업부/조직',
  job_category VARCHAR(100) COMMENT '직군',
  quota INT NOT NULL DEFAULT 0 COMMENT '정원',
  current_headcount INT NOT NULL DEFAULT 0 COMMENT '현원',
  new_hires INT NOT NULL DEFAULT 0 COMMENT '입사',
  resignations INT NOT NULL DEFAULT 0 COMMENT '퇴사',
  transfers INT NOT NULL DEFAULT 0 COMMENT '이동',
  vacancies INT NOT NULL DEFAULT 0 COMMENT '공석',
  on_leave INT NOT NULL DEFAULT 0 COMMENT '휴직',
  returned INT NOT NULL DEFAULT 0 COMMENT '복귀',
  labor_cost DECIMAL(15, 2) NOT NULL DEFAULT 0 COMMENT '인력비용',
  as_of_date TIMESTAMP NOT NULL COMMENT '기준일시',
  data_quality ENUM('NORMAL', 'WARNING') NOT NULL DEFAULT 'NORMAL' COMMENT '데이터 품질',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_department (department),
  INDEX idx_division (division),
  INDEX idx_job_category (job_category),
  INDEX idx_as_of_date (as_of_date),
  INDEX idx_data_quality (data_quality)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='HR 현황 데이터';

-- 샘플 데이터 삽입 (테스트용)
INSERT INTO hr_data (department, division, job_category, quota, current_headcount, new_hires, resignations, transfers, vacancies, on_leave, returned, labor_cost, as_of_date, data_quality) VALUES
('경영지원본부', '인사팀', '인사', 10, 9, 2, 1, 0, 1, 0, 0, 50000000, NOW(), 'NORMAL'),
('경영지원본부', '재무팀', '재무', 8, 8, 1, 0, 1, 0, 0, 0, 45000000, NOW(), 'NORMAL'),
('기술본부', '개발팀', '개발', 30, 28, 5, 2, 3, 2, 1, 0, 180000000, NOW(), 'NORMAL'),
('기술본부', '인프라팀', '인프라', 15, 14, 2, 1, 1, 1, 0, 1, 90000000, NOW(), 'NORMAL'),
('영업본부', '영업1팀', '영업', 20, 19, 3, 1, 2, 1, 0, 0, 120000000, NOW(), 'NORMAL'),
('영업본부', '영업2팀', '영업', 18, 17, 2, 2, 1, 1, 1, 0, 110000000, NOW(), 'NORMAL'),
('마케팅본부', '마케팅팀', '마케팅', 12, 11, 1, 1, 0, 1, 0, 0, 70000000, NOW(), 'NORMAL');


