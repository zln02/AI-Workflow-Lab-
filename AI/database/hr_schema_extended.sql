-- ============================================
-- HR 현황 데이터베이스 스키마 확장
-- ============================================

-- 기존 hr_data 테이블에 컬럼 추가
ALTER TABLE hr_data 
  ADD COLUMN IF NOT EXISTS business_unit VARCHAR(100) COMMENT '사업부문' AFTER department,
  ADD COLUMN IF NOT EXISTS team VARCHAR(100) COMMENT '팀' AFTER business_unit,
  ADD COLUMN IF NOT EXISTS part VARCHAR(100) COMMENT '파트' AFTER team,
  ADD COLUMN IF NOT EXISTS line VARCHAR(100) COMMENT '라인(조)' AFTER part;

-- 개인 인사 정보 테이블
CREATE TABLE IF NOT EXISTS employees (
  id INT AUTO_INCREMENT PRIMARY KEY,
  employee_id VARCHAR(50) NOT NULL UNIQUE COMMENT '사번',
  name VARCHAR(100) NOT NULL COMMENT '이름',
  department VARCHAR(100) COMMENT '본부',
  business_unit VARCHAR(100) COMMENT '사업부문',
  team VARCHAR(100) COMMENT '팀',
  part VARCHAR(100) COMMENT '파트',
  line VARCHAR(100) COMMENT '라인(조)',
  job_category VARCHAR(100) COMMENT '직군',
  position VARCHAR(50) COMMENT '직급',
  location VARCHAR(100) COMMENT '연고지',
  performance_grade VARCHAR(10) COMMENT '고과',
  salary_grade VARCHAR(20) COMMENT '연봉 등급',
  salary DECIMAL(15, 2) COMMENT '연봉',
  join_date DATE COMMENT '입사일',
  status ENUM('ACTIVE', 'ON_LEAVE', 'RESIGNED') NOT NULL DEFAULT 'ACTIVE' COMMENT '상태',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_employee_id (employee_id),
  INDEX idx_department (department),
  INDEX idx_business_unit (business_unit),
  INDEX idx_team (team),
  INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='개인 인사 정보';

-- 휴직/복직 정보 테이블
CREATE TABLE IF NOT EXISTS leave_info (
  id INT AUTO_INCREMENT PRIMARY KEY,
  employee_id INT NOT NULL COMMENT '직원 ID',
  employee_name VARCHAR(100) COMMENT '직원 이름',
  leave_type ENUM('출산', '육아', '병가', '기타') NOT NULL COMMENT '휴직 유형',
  leave_start_date DATE NOT NULL COMMENT '휴직 시작일',
  expected_return_date DATE COMMENT '예상 복직일',
  actual_return_date DATE COMMENT '실제 복직일',
  remaining_days INT DEFAULT 0 COMMENT '잔여 휴직일',
  position VARCHAR(50) COMMENT '직급',
  location VARCHAR(100) COMMENT '연고지',
  salary_grade VARCHAR(20) COMMENT '연봉 등급',
  status ENUM('ON_LEAVE', 'RETURNED') NOT NULL DEFAULT 'ON_LEAVE' COMMENT '상태',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
  INDEX idx_employee_id (employee_id),
  INDEX idx_status (status),
  INDEX idx_leave_start_date (leave_start_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='휴직/복직 정보';

-- 입사/퇴사/발령 계획 테이블
CREATE TABLE IF NOT EXISTS movement_plans (
  id INT AUTO_INCREMENT PRIMARY KEY,
  employee_id INT COMMENT '직원 ID (발령 시)',
  movement_type ENUM('입사', '퇴사', '발령') NOT NULL COMMENT '이동 유형',
  planned_date DATE NOT NULL COMMENT '계획일',
  department VARCHAR(100) COMMENT '본부',
  business_unit VARCHAR(100) COMMENT '사업부문',
  team VARCHAR(100) COMMENT '팀',
  position VARCHAR(50) COMMENT '직급',
  status ENUM('PLANNED', 'COMPLETED', 'CANCELLED') NOT NULL DEFAULT 'PLANNED' COMMENT '상태',
  notes TEXT COMMENT '비고',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_movement_type (movement_type),
  INDEX idx_planned_date (planned_date),
  INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='입사/퇴사/발령 계획';

-- TO/채용 계획 테이블
CREATE TABLE IF NOT EXISTS recruitment_plans (
  id INT AUTO_INCREMENT PRIMARY KEY,
  department VARCHAR(100) COMMENT '본부',
  business_unit VARCHAR(100) COMMENT '사업부문',
  team VARCHAR(100) COMMENT '팀',
  job_category VARCHAR(100) COMMENT '직군',
  position VARCHAR(50) COMMENT '직급',
  quota INT NOT NULL DEFAULT 1 COMMENT '채용 인원',
  status ENUM('PLANNED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED') NOT NULL DEFAULT 'PLANNED' COMMENT '상태',
  planned_start_date DATE COMMENT '채용 시작 예정일',
  planned_end_date DATE COMMENT '채용 완료 예정일',
  actual_end_date DATE COMMENT '실제 채용 완료일',
  leadtime_days INT COMMENT '리드타임 (일)',
  notes TEXT COMMENT '비고',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_status (status),
  INDEX idx_planned_start_date (planned_start_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='TO/채용 계획';

-- 인건비 예측 테이블
CREATE TABLE IF NOT EXISTS labor_cost_forecast (
  id INT AUTO_INCREMENT PRIMARY KEY,
  forecast_year INT NOT NULL COMMENT '예측 연도',
  forecast_month INT COMMENT '예측 월',
  department VARCHAR(100) COMMENT '본부',
  base_cost DECIMAL(15, 2) NOT NULL COMMENT '기본 인건비',
  increase_rate DECIMAL(5, 2) COMMENT '상승률 (%)',
  forecasted_cost DECIMAL(15, 2) COMMENT '예측 인건비',
  severance_pay DECIMAL(15, 2) DEFAULT 0 COMMENT '퇴직금 예상',
  annual_leave_pay DECIMAL(15, 2) DEFAULT 0 COMMENT '연차수당 예상',
  total_forecasted_cost DECIMAL(15, 2) COMMENT '총 예측 비용',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_forecast_year (forecast_year),
  INDEX idx_department (department)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='인건비 예측';

-- 연차 사용 현황 테이블
CREATE TABLE IF NOT EXISTS annual_leave_status (
  id INT AUTO_INCREMENT PRIMARY KEY,
  employee_id INT NOT NULL COMMENT '직원 ID',
  year INT NOT NULL COMMENT '연도',
  total_days INT NOT NULL DEFAULT 15 COMMENT '총 연차일수',
  used_days INT DEFAULT 0 COMMENT '사용 일수',
  remaining_days INT COMMENT '잔여 일수',
  expected_pay DECIMAL(12, 2) COMMENT '예상 연차수당',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
  INDEX idx_employee_id (employee_id),
  INDEX idx_year (year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='연차 사용 현황';

-- 초과/야간 근무 현황 테이블
CREATE TABLE IF NOT EXISTS overtime_status (
  id INT AUTO_INCREMENT PRIMARY KEY,
  employee_id INT NOT NULL COMMENT '직원 ID',
  department VARCHAR(100) COMMENT '본부',
  business_unit VARCHAR(100) COMMENT '사업부문',
  work_date DATE NOT NULL COMMENT '근무일',
  overtime_hours DECIMAL(5, 2) DEFAULT 0 COMMENT '초과 근무 시간',
  night_work_hours DECIMAL(5, 2) DEFAULT 0 COMMENT '야간 근무 시간',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
  INDEX idx_employee_id (employee_id),
  INDEX idx_work_date (work_date),
  INDEX idx_department (department)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='초과/야간 근무 현황';

-- 법정 교육 수료 현황 테이블
CREATE TABLE IF NOT EXISTS education_completion (
  id INT AUTO_INCREMENT PRIMARY KEY,
  employee_id INT NOT NULL COMMENT '직원 ID',
  education_type ENUM('안전관련', '야간특수검진', '기타') NOT NULL COMMENT '교육 유형',
  education_name VARCHAR(200) NOT NULL COMMENT '교육명',
  completion_date DATE COMMENT '수료일',
  expiry_date DATE COMMENT '만료일',
  status ENUM('COMPLETED', 'PENDING', 'EXPIRED') NOT NULL DEFAULT 'PENDING' COMMENT '상태',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
  INDEX idx_employee_id (employee_id),
  INDEX idx_education_type (education_type),
  INDEX idx_status (status),
  INDEX idx_expiry_date (expiry_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='법정 교육 수료 현황';

-- ETL 파이프라인 로그 테이블
CREATE TABLE IF NOT EXISTS etl_pipeline_log (
  id INT AUTO_INCREMENT PRIMARY KEY,
  pipeline_name VARCHAR(100) NOT NULL COMMENT '파이프라인 이름',
  execution_date TIMESTAMP NOT NULL COMMENT '실행일시',
  status ENUM('SUCCESS', 'FAILED', 'WARNING') NOT NULL COMMENT '상태',
  data_quality ENUM('NORMAL', 'WARNING') COMMENT '데이터 품질',
  records_processed INT DEFAULT 0 COMMENT '처리된 레코드 수',
  error_message TEXT COMMENT '오류 메시지',
  execution_time_seconds INT COMMENT '실행 시간 (초)',
  sla_met BOOLEAN DEFAULT TRUE COMMENT 'SLA 준수 여부',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_pipeline_name (pipeline_name),
  INDEX idx_execution_date (execution_date),
  INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='ETL 파이프라인 로그';


