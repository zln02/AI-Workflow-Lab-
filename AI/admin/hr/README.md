# HR 현황 대시보드

## 개요
경영진이 회의에서 최신 HR 현황을 즉시 파악할 수 있는 실시간 대시보드입니다.

## ETL/ELT 처리 흐름

### 1. 수집 (Extract)
- HR 시스템, 조직도, 채용 시스템, 근태 시스템 등에서 주기적 연동
- 데이터 소스별 API 또는 파일 기반 수집

### 2. 정제 (Transform)
- 조직/직군/지역 코드 통일
- 중복 제거 및 데이터 정규화
- 데이터 타입 변환 및 검증

### 3. 품질 체크 (Quality Check)
- 누락 데이터 탐지
- 중복 데이터 탐지
- 불일치 데이터 탐지
- 경고/알림 생성
- 신뢰도 표시 (NORMAL/WARNING)

### 4. 집계 (Aggregate)
- 회의용 KPI 요약 테이블 생성
- 조직 단위별 집계
- 시간대별 집계

### 5. 반영 (Load)
- 대시보드 자동 갱신
- D-1 09:00까지 갱신 완료 (SLA)
- 실패/지연 시 알림 발송

## SLA (Service Level Agreement)
- **갱신 주기**: D-1 (전날 데이터 기준)
- **갱신 완료 시간**: 매일 09:00까지
- **실패/지연 시**: 즉시 알림 발송 (Data Owner, Data Engineer, 운영 담당자)

## 주요 기능

### 1. 상단 상태 바
- **As-of 날짜**: 데이터 기준 시점 표시 (예: `2026-01-05 09:00 기준`)
- **신뢰도 상태**: 데이터 품질 표시 (✅ 정상 / ⚠️ 경고)

### 2. 핵심 KPI 카드
- **내년 임직원 인건비 상승률 예상 및 대응**: 인건비 상승률 예측 및 대응 방안
- **일시적 인건비 지출 예상**: 퇴직금, 연차 수당 등 일시적 지출 예상
- **현 근무 인원**: 직급/연고지/고과/연봉 등급별 분포
- **입사/퇴사/발령 계획**: 계획된 인력 변동 현황
- **TO/채용 계획**: 공석 및 채용 진행 현황
- **휴직&복직 인원 정보**: 잔여 휴직, 복직일, 직급, 연고지, 연봉 등급, 휴직 사유

### 3. 필터 기능 (계층적)
- **본부** → **사업부문** → **팀** → **파트** → **라인(조)** → **개인 인사 카드**
- 직군별 필터링
- 개인 검색 (사번 또는 이름)

### 4. 시각화
- **각 팀별 입/퇴사율**: 팀별 이직률 분석
- **공석에 의한 채용 리드타임**: 채용 소요 시간 분석
- **연간 연차 사용 진척률**: 연차 사용 현황 및 연말 연차수당 발생 예상 금액
- **부문별 초과 근무, 야간 근무 각각 현황**: 근무 시간 분석
- **법정 교육 수료율**: 안전 관련, 야간 특수 검진 등 교육 수료 현황
- **최근 8주 현원 추이**: 현원 변화 추이

### 5. 드릴다운 기능 (검색 엔진)
- **조직 단위 → 팀 → 개인 상세 정보**: KPI 클릭 시 계층적 드릴다운
- 조직 단위별 상세 정보 표시
- 개인 인사 카드 조회

## 설치 및 설정

### 1. 데이터베이스 스키마 생성
```sql
-- 기본 스키마 실행
mysql -u root -p < /var/lib/tomcat9/webapps/ROOT/AI/database/hr_schema.sql

-- 확장 스키마 실행
mysql -u root -p < /var/lib/tomcat9/webapps/ROOT/AI/database/hr_schema_extended.sql
```

또는 MySQL 클라이언트에서 직접 실행:
```sql
SOURCE /var/lib/tomcat9/webapps/ROOT/AI/database/hr_schema.sql;
SOURCE /var/lib/tomcat9/webapps/ROOT/AI/database/hr_schema_extended.sql;
```

### 2. 샘플 데이터 확인
기본 스키마 파일에 포함된 샘플 데이터가 자동으로 삽입됩니다.

### 3. ETL 파이프라인 설정
- 스케줄러 설정 (매일 08:00 실행)
- 데이터 소스 연결 설정
- 품질 체크 규칙 설정
- 알림 설정 (SLA 실패 시)

### 3. 접근 방법
1. 관리자 계정으로 로그인
2. 사이드바에서 "HR 현황" 메뉴 클릭
3. 또는 직접 URL 접근: `/AI/admin/hr/dashboard.jsp`

## 데이터 업데이트

### 자동 업데이트 (권장)
실시간 데이터 파이프라인을 구축하여 D-1 또는 시간 단위로 자동 갱신:
1. 데이터 수집 (HR 시스템, 조직도, 채용 시스템 등)
2. 전처리 및 정제
3. 집계 및 검증
4. `hr_data` 테이블에 INSERT 또는 UPDATE

### 수동 업데이트
```sql
INSERT INTO hr_data (
  department, division, job_category, 
  quota, current_headcount, new_hires, resignations, 
  transfers, vacancies, on_leave, returned, 
  labor_cost, as_of_date, data_quality
) VALUES (
  '경영지원본부', '인사팀', '인사',
  10, 9, 2, 1, 0, 1, 0, 0,
  50000000, NOW(), 'NORMAL'
);
```

## KPI 지표 정의

### 표준화된 지표
- **정원 (quota)**: 조직에 배정된 총 인원 수
- **현원 (current_headcount)**: 현재 재직 중인 인원 수 (휴직 제외)
- **입사 (new_hires)**: 해당 기간 동안 입사한 인원 수
- **퇴사 (resignations)**: 해당 기간 동안 퇴사한 인원 수
- **이동 (transfers)**: 조직 간 이동한 인원 수
- **공석 (vacancies)**: 정원 대비 현재 채용이 필요한 인원 수
- **휴직 (on_leave)**: 현재 휴직 중인 인원 수
- **복귀 (returned)**: 해당 기간 동안 복귀한 인원 수
- **인력비용 (labor_cost)**: 월간 예상 인력비용 (원 단위)

## API 엔드포인트

### 요약 데이터 조회
```
GET /AI/api/hr-data.jsp?action=summary&department=경영지원본부&division=인사팀&jobCategory=인사
```

### 현원 추이 조회
```
GET /AI/api/hr-data.jsp?action=trend&weeks=8
```

### 조직별 상세 정보 조회
```
GET /AI/api/hr-data.jsp?action=organization&department=경영지원본부&division=인사팀
```

### 필터 옵션 조회
```
GET /AI/api/hr-data.jsp?action=filters
```

## 파일 구조

```
webapps/ROOT/
├── AI/
│   ├── admin/
│   │   └── hr/
│   │       ├── dashboard.jsp          # HR 대시보드 메인 페이지
│   │       └── README.md              # 이 파일
│   └── assets/
│       └── js/
│           └── hr-dashboard.js        # HR 대시보드 JavaScript
├── api/
│   └── hr-data.jsp                    # HR 데이터 API 엔드포인트
├── database/
│   └── hr_schema.sql                  # HR 데이터베이스 스키마
└── WEB-INF/
    └── classes/
        ├── model/
        │   └── HRData.java            # HR 데이터 모델
        └── dao/
            └── HRDAO.java             # HR 데이터 접근 객체
```

## 운영 역할

- **Data Owner (HR)**: 데이터 정확성 책임, KPI 정의 및 검증
- **Data Engineer/IT**: ETL 파이프라인 구축 및 운영, 데이터 품질 관리
- **대시보드 운영 담당**: 일상적인 모니터링 및 리포트 생성
- **승인/권한 담당**: 접근 권한 관리 및 데이터 보안

## 필요한 데이터

### 필수 데이터
- **인사 기본 정보**: 사번, 이름, 본부, 사업부문, 팀, 파트, 라인, 직급, 연고지, 고과, 연봉 등급
- **인력 변동**: 입사, 퇴사, 발령 계획 및 실적
- **채용 정보**: TO, 채용 계획, 채용 진행 현황, 리드타임
- **휴직/복직**: 휴직 유형, 시작일, 예상/실제 복직일, 잔여 휴직일
- **인건비**: 기본 인건비, 예상 상승률, 퇴직금, 연차수당
- **근무 현황**: 초과 근무, 야간 근무 시간
- **교육 현황**: 법정 교육 수료 현황 (안전 관련, 야간 특수 검진 등)
- **연차 현황**: 연차 사용 진척률, 잔여 연차, 예상 연차수당

## 향후 개선 사항

1. **실시간 자동 갱신 파이프라인 구축**
   - 스케줄러를 통한 주기적 데이터 수집 (D-1 09:00 SLA 준수)
   - 데이터 검증 및 품질 체크 자동화
   - ETL 파이프라인 로그 및 모니터링

2. **추가 시각화**
   - 조직별 현원 분포 파이 차트
   - 채용 진행률 게이지 차트
   - 인력비용 추이 차트

3. **알림 기능**
   - 공석이 일정 수준 이상일 때 알림
   - 데이터 품질 경고 시 알림
   - SLA 실패/지연 시 알림

4. **내보내기 기능**
   - PDF 리포트 생성
   - Excel 다운로드

