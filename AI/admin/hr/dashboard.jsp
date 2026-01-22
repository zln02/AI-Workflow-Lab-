<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.HRDAO" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.List" %>
<%
  // 관리자 인증 확인
  if (session.getAttribute("admin") == null) {
    response.sendRedirect("/AI/admin/auth/login.jsp");
    return;
  }

  HRDAO hrDAO = new HRDAO();
  
  // 필터 파라미터
  String department = request.getParameter("department");
  String division = request.getParameter("division");
  String jobCategory = request.getParameter("jobCategory");
  
  if (department == null) department = "전체";
  if (division == null) division = "전체";
  if (jobCategory == null) jobCategory = "전체";
  
  // HR 요약 데이터 조회
  Map<String, Object> summary = hrDAO.getHRSummary(department, division, jobCategory);
  
  // 필터 옵션 조회
  Map<String, List<String>> filterOptions = hrDAO.getFilterOptions();
  
  // As-of 날짜 (수기 작성)
  String asOfDateStr = "2026-01-05";
  String asOfTimeStr = "13:00";
  
  // 데이터 품질 상태
  String dataQuality = (String) summary.getOrDefault("dataQuality", "WARNING");
  boolean isDataNormal = "NORMAL".equals(dataQuality);
  
  // 캐시 버스팅을 위한 타임스탬프
  long cacheBuster = System.currentTimeMillis();
%>
<%@ include file="/AI/admin/hr/layout/header.jspf" %>
<meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="0">
<div class="admin-layout hr-layout">
  <%@ include file="/AI/admin/hr/layout/sidebar.jspf" %>
  <div class="admin-main-wrapper hr-main-wrapper">
    <%@ include file="/AI/admin/hr/layout/topbar.jspf" %>
    <main class="admin-content">
      <header class="admin-dashboard-header">
        <div style="display: flex; align-items: center; gap: 1rem; margin-bottom: 0.5rem;">
          <h1 style="margin: 0;">HR 관리자 대시보드</h1>
          <span style="padding: 0.25rem 0.75rem; background: rgba(56, 189, 248, 0.15); border: 1px solid rgba(56, 189, 248, 0.3); border-radius: var(--radius-full); font-size: 0.75rem; color: var(--accent-primary);">인사 관리</span>
        </div>
        <p style="margin: 0; color: var(--text-secondary);">실시간 인력 현황을 한눈에 파악하고 경영 의사결정을 지원합니다</p>
      </header>

      <!-- 상단 바: As-of 및 신뢰도 -->
      <section class="hr-status-bar" style="background: var(--glass-bg); backdrop-filter: blur(20px); border: 1px solid var(--glass-border); border-radius: var(--radius-xl); padding: 1.5rem; margin-bottom: 2rem; display: flex; justify-content: space-between; align-items: center;">
        <div style="display: flex; align-items: center; gap: 1rem;">
          <div>
            <span style="color: var(--text-secondary); font-size: 0.875rem;">As-of</span>
            <div style="font-size: 1.25rem; font-weight: 600; margin-top: 0.25rem;">
              <%= asOfDateStr %> <%= asOfTimeStr %> 기준
            </div>
          </div>
        </div>
        <div style="display: flex; align-items: center; gap: 0.5rem;">
          <span style="color: var(--text-secondary); font-size: 0.875rem;">신뢰도 상태</span>
          <span style="font-size: 1.5rem;" id="dataQualityIcon">
            <%= isDataNormal ? "✅" : "⚠️" %>
          </span>
          <span id="dataQualityText" style="font-weight: 500;">
            <%= isDataNormal ? "정상" : "경고" %>
          </span>
        </div>
      </section>

      <!-- HR 전용 필터 섹션 -->
      <section class="hr-filter-section">
        <div class="hr-filter-header">
          <h3 class="hr-filter-title">조직 필터</h3>
          <button onclick="resetFilters()" class="hr-filter-reset">초기화</button>
        </div>
        
        <div class="hr-filter-grid">
          <div class="hr-filter-item" id="filterItemDepartment">
            <label class="hr-filter-label">
              <span class="hr-filter-label-icon">🏢</span>
              <span>본부</span>
            </label>
            <select id="filterDepartment" class="hr-filter-select" onchange="hrFilter.onDepartmentChange()">
              <option value="전체" <%= "전체".equals(department) ? "selected" : "" %>>전체</option>
              <% for (String dept : filterOptions.get("departments")) { %>
                <option value="<%= dept %>" <%= dept.equals(department) ? "selected" : "" %>><%= dept %></option>
              <% } %>
            </select>
          </div>
          
          <div class="hr-filter-item" id="filterItemBusinessUnit">
            <label class="hr-filter-label">
              <span class="hr-filter-label-icon">📊</span>
              <span>사업부문</span>
            </label>
            <select id="filterBusinessUnit" class="hr-filter-select" onchange="hrFilter.onBusinessUnitChange()" <%= (department == null || "전체".equals(department)) ? "disabled" : "" %>>
              <option value="전체">전체</option>
            </select>
          </div>
          
          <div class="hr-filter-item" id="filterItemTeam">
            <label class="hr-filter-label">
              <span class="hr-filter-label-icon">👥</span>
              <span>팀</span>
            </label>
            <select id="filterTeam" class="hr-filter-select" onchange="hrFilter.onTeamChange()" disabled>
              <option value="전체">전체</option>
            </select>
          </div>
          
          <div class="hr-filter-item" id="filterItemPart">
            <label class="hr-filter-label">
              <span class="hr-filter-label-icon">📁</span>
              <span>파트</span>
            </label>
            <select id="filterPart" class="hr-filter-select" onchange="hrFilter.onPartChange()" disabled>
              <option value="전체">전체</option>
            </select>
          </div>
          
          <div class="hr-filter-item" id="filterItemLine">
            <label class="hr-filter-label">
              <span class="hr-filter-label-icon">🔗</span>
              <span>라인(조)</span>
            </label>
            <select id="filterLine" class="hr-filter-select" disabled>
              <option value="전체">전체</option>
            </select>
          </div>
          
          <div class="hr-filter-item" id="filterItemJobCategory">
            <label class="hr-filter-label">
              <span class="hr-filter-label-icon">💼</span>
              <span>직군</span>
            </label>
            <select id="filterJobCategory" class="hr-filter-select">
              <option value="전체" <%= "전체".equals(jobCategory) ? "selected" : "" %>>전체</option>
              <% for (String job : filterOptions.get("jobCategories")) { %>
                <option value="<%= job %>" <%= job.equals(jobCategory) ? "selected" : "" %>><%= job %></option>
              <% } %>
            </select>
          </div>
        </div>
        
        <div class="hr-filter-actions">
          <button onclick="hrFilter.apply()" class="hr-filter-btn hr-filter-btn-primary">
            <span>✓</span>
            <span>필터 적용</span>
          </button>
          <button onclick="hrFilter.search()" class="hr-filter-btn hr-filter-btn-secondary">
            <span>🔍</span>
            <span>개인 검색</span>
          </button>
          <div class="hr-filter-search">
            <span class="hr-filter-search-icon">🔎</span>
            <input type="text" id="employeeSearch" class="hr-filter-search-input" placeholder="사번 또는 이름으로 검색..." onkeypress="if(event.key==='Enter') hrFilter.search()">
          </div>
        </div>
        
        <!-- 선택된 필터 배지 -->
        <div class="hr-filter-badges" id="filterBadges" style="display: none;"></div>
      </section>

      <!-- 핵심 KPI 카드 -->
      <section class="hr-kpi-grid" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 1.5rem; margin-bottom: 2rem;">
        <!-- 인건비 상승률 예상 -->
        <article class="hr-kpi-card" data-kpi="costIncrease" onclick="drillDown('costIncrease')" style="cursor: pointer; background: var(--glass-bg); backdrop-filter: blur(20px); border: 1px solid var(--glass-border); border-radius: var(--radius-xl); padding: 1.5rem; transition: transform 0.2s, box-shadow 0.2s;" onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 8px 16px rgba(0,0,0,0.2)';" onmouseout="this.style.transform=''; this.style.boxShadow='';">
          <h3 style="font-size: 0.875rem; color: var(--text-secondary); margin-bottom: 0.5rem;">내년 인건비 상승률 예상</h3>
          <div style="font-size: 2rem; font-weight: 700; color: #F44336; margin-bottom: 0.5rem;">
            <span id="costIncreaseRate">-</span>%
          </div>
          <p style="font-size: 0.875rem; color: var(--text-secondary);">
            대응 방안 확인 필요
          </p>
        </article>

        <!-- 일시적 인건비 지출 -->
        <article class="hr-kpi-card" data-kpi="temporaryCost" onclick="drillDown('temporaryCost')" style="cursor: pointer; background: var(--glass-bg); backdrop-filter: blur(20px); border: 1px solid var(--glass-border); border-radius: var(--radius-xl); padding: 1.5rem; transition: transform 0.2s, box-shadow 0.2s;" onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 8px 16px rgba(0,0,0,0.2)';" onmouseout="this.style.transform=''; this.style.boxShadow='';">
          <h3 style="font-size: 0.875rem; color: var(--text-secondary); margin-bottom: 0.5rem;">일시적 인건비 지출 예상</h3>
          <div style="font-size: 1.5rem; font-weight: 700; color: #FF9800; margin-bottom: 0.5rem;">
            <div>퇴직금: <span id="severancePay">-</span>원</div>
            <div style="margin-top: 0.5rem;">연차수당: <span id="annualLeavePay">-</span>원</div>
          </div>
          <p style="font-size: 0.875rem; color: var(--text-secondary);">
            연말 집행 예상
          </p>
        </article>

        <!-- 현 근무 인원 상세 -->
        <article class="hr-kpi-card" data-kpi="headcount" onclick="drillDown('headcount')" style="cursor: pointer; background: var(--glass-bg); backdrop-filter: blur(20px); border: 1px solid var(--glass-border); border-radius: var(--radius-xl); padding: 1.5rem; transition: transform 0.2s, box-shadow 0.2s;" onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 8px 16px rgba(0,0,0,0.2)';" onmouseout="this.style.transform=''; this.style.boxShadow='';">
          <h3 style="font-size: 0.875rem; color: var(--text-secondary); margin-bottom: 0.5rem;">현 근무 인원</h3>
          <div style="font-size: 2.5rem; font-weight: 700; color: var(--accent-primary); margin-bottom: 0.5rem;">
            <%= summary.getOrDefault("totalCurrentHeadcount", 0) %>
          </div>
          <div style="font-size: 0.875rem; color: var(--text-secondary); margin-top: 0.5rem;">
            <div>정원: <%= summary.getOrDefault("totalQuota", 0) %></div>
            <div style="margin-top: 0.25rem;">직급/연고지/고과/연봉 등급별 분포</div>
          </div>
        </article>

        <article class="hr-kpi-card" data-kpi="movement" onclick="drillDown('movement')" style="cursor: pointer; background: var(--glass-bg); backdrop-filter: blur(20px); border: 1px solid var(--glass-border); border-radius: var(--radius-xl); padding: 1.5rem; transition: transform 0.2s, box-shadow 0.2s;" onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 8px 16px rgba(0,0,0,0.2)';" onmouseout="this.style.transform=''; this.style.boxShadow='';">
          <h3 style="font-size: 0.875rem; color: var(--text-secondary); margin-bottom: 0.5rem;">입사/퇴사/이동</h3>
          <div style="display: flex; gap: 1rem; margin-bottom: 0.5rem;">
            <div>
              <div style="font-size: 1.5rem; font-weight: 700; color: #4CAF50;">+<%= summary.getOrDefault("totalNewHires", 0) %></div>
              <div style="font-size: 0.75rem; color: var(--text-secondary);">입사</div>
            </div>
            <div>
              <div style="font-size: 1.5rem; font-weight: 700; color: #F44336;">-<%= summary.getOrDefault("totalResignations", 0) %></div>
              <div style="font-size: 0.75rem; color: var(--text-secondary);">퇴사</div>
            </div>
            <div>
              <div style="font-size: 1.5rem; font-weight: 700; color: #FF9800;"><%= summary.getOrDefault("totalTransfers", 0) %></div>
              <div style="font-size: 0.75rem; color: var(--text-secondary);">이동</div>
            </div>
          </div>
        </article>

        <!-- 입사/퇴사/발령 계획 -->
        <article class="hr-kpi-card" data-kpi="movement" onclick="drillDown('movement')" style="cursor: pointer; background: var(--glass-bg); backdrop-filter: blur(20px); border: 1px solid var(--glass-border); border-radius: var(--radius-xl); padding: 1.5rem; transition: transform 0.2s, box-shadow 0.2s;" onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 8px 16px rgba(0,0,0,0.2)';" onmouseout="this.style.transform=''; this.style.boxShadow='';">
          <h3 style="font-size: 0.875rem; color: var(--text-secondary); margin-bottom: 0.5rem;">입사/퇴사/발령 계획</h3>
          <div style="display: flex; gap: 1rem; margin-bottom: 0.5rem;">
            <div>
              <div style="font-size: 1.5rem; font-weight: 700; color: #4CAF50;">+<%= summary.getOrDefault("totalNewHires", 0) %></div>
              <div style="font-size: 0.75rem; color: var(--text-secondary);">입사</div>
            </div>
            <div>
              <div style="font-size: 1.5rem; font-weight: 700; color: #F44336;">-<%= summary.getOrDefault("totalResignations", 0) %></div>
              <div style="font-size: 0.75rem; color: var(--text-secondary);">퇴사</div>
            </div>
            <div>
              <div style="font-size: 1.5rem; font-weight: 700; color: #FF9800;"><%= summary.getOrDefault("totalTransfers", 0) %></div>
              <div style="font-size: 0.75rem; color: var(--text-secondary);">발령</div>
            </div>
          </div>
        </article>

        <!-- TO/채용 계획 -->
        <article class="hr-kpi-card" data-kpi="vacancy" onclick="drillDown('vacancy')" style="cursor: pointer; background: var(--glass-bg); backdrop-filter: blur(20px); border: 1px solid var(--glass-border); border-radius: var(--radius-xl); padding: 1.5rem; transition: transform 0.2s, box-shadow 0.2s;" onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 8px 16px rgba(0,0,0,0.2)';" onmouseout="this.style.transform=''; this.style.boxShadow='';">
          <h3 style="font-size: 0.875rem; color: var(--text-secondary); margin-bottom: 0.5rem;">TO/채용 계획</h3>
          <div style="font-size: 2.5rem; font-weight: 700; color: #FF9800; margin-bottom: 0.5rem;">
            <%= summary.getOrDefault("totalVacancies", 0) %>
          </div>
          <p style="font-size: 0.875rem; color: var(--text-secondary);">
            공석 / 채용 진행 중
          </p>
        </article>

        <!-- 휴직&복직 인원 정보 -->
        <article class="hr-kpi-card" data-kpi="leave" onclick="drillDown('leave')" style="cursor: pointer; background: var(--glass-bg); backdrop-filter: blur(20px); border: 1px solid var(--glass-border); border-radius: var(--radius-xl); padding: 1.5rem; transition: transform 0.2s, box-shadow 0.2s;" onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 8px 16px rgba(0,0,0,0.2)';" onmouseout="this.style.transform=''; this.style.boxShadow='';">
          <h3 style="font-size: 0.875rem; color: var(--text-secondary); margin-bottom: 0.5rem;">휴직&복직 인원</h3>
          <div style="display: flex; gap: 1rem; margin-bottom: 0.5rem;">
            <div>
              <div style="font-size: 1.5rem; font-weight: 700; color: #9C27B0;"><%= summary.getOrDefault("totalOnLeave", 0) %></div>
              <div style="font-size: 0.75rem; color: var(--text-secondary);">휴직</div>
            </div>
            <div>
              <div style="font-size: 1.5rem; font-weight: 700; color: #4CAF50;">+<%= summary.getOrDefault("totalReturned", 0) %></div>
              <div style="font-size: 0.75rem; color: var(--text-secondary);">복직</div>
            </div>
          </div>
          <p style="font-size: 0.75rem; color: var(--text-secondary); margin-top: 0.5rem;">
            잔여 휴직, 복직일, 직급, 연고지, 연봉 등급, 휴직 사유
          </p>
        </article>

        <article class="hr-kpi-card" data-kpi="cost" onclick="drillDown('cost')" style="cursor: pointer; background: var(--glass-bg); backdrop-filter: blur(20px); border: 1px solid var(--glass-border); border-radius: var(--radius-xl); padding: 1.5rem; transition: transform 0.2s, box-shadow 0.2s;" onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 8px 16px rgba(0,0,0,0.2)';" onmouseout="this.style.transform=''; this.style.boxShadow='';">
          <h3 style="font-size: 0.875rem; color: var(--text-secondary); margin-bottom: 0.5rem;">인력비용</h3>
          <div style="font-size: 2rem; font-weight: 700; color: var(--accent-primary); margin-bottom: 0.5rem;">
            <% 
              java.math.BigDecimal laborCost = (java.math.BigDecimal) summary.getOrDefault("totalLaborCost", java.math.BigDecimal.ZERO);
              if (laborCost != null && laborCost.compareTo(java.math.BigDecimal.ZERO) > 0) {
                out.print(String.format("%,.0f", laborCost.doubleValue()));
              } else {
                out.print("0");
              }
            %>원
          </div>
          <p style="font-size: 0.875rem; color: var(--text-secondary);">
            월간 예상
          </p>
        </article>
      </section>

      <!-- 시각화 섹션 -->
      <section class="hr-visualization" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(400px, 1fr)); gap: 1.5rem; margin-bottom: 2rem;">
        <!-- 각 팀별 입/퇴사율 -->
        <div style="background: var(--glass-bg); backdrop-filter: blur(20px); border: 1px solid var(--glass-border); border-radius: var(--radius-xl); padding: 1.5rem;">
          <h3 style="font-size: 1.25rem; font-weight: 600; margin-bottom: 1rem;">각 팀별 입/퇴사율</h3>
          <canvas id="teamTurnoverChart" style="max-height: 300px;"></canvas>
        </div>

        <!-- 공석에 의한 채용 리드타임 -->
        <div style="background: var(--glass-bg); backdrop-filter: blur(20px); border: 1px solid var(--glass-border); border-radius: var(--radius-xl); padding: 1.5rem;">
          <h3 style="font-size: 1.25rem; font-weight: 600; margin-bottom: 1rem;">공석에 의한 채용 리드타임</h3>
          <canvas id="vacancyLeadtimeChart" style="max-height: 300px;"></canvas>
        </div>

        <!-- 연간 연차 사용 진척률 / 연말 연차수당 발생 예상 -->
        <div style="background: var(--glass-bg); backdrop-filter: blur(20px); border: 1px solid var(--glass-border); border-radius: var(--radius-xl); padding: 1.5rem;">
          <h3 style="font-size: 1.25rem; font-weight: 600; margin-bottom: 1rem;">연차 사용 진척률</h3>
          <canvas id="annualLeaveProgressChart" style="max-height: 300px;"></canvas>
          <div style="margin-top: 1rem; padding: 1rem; background: rgba(255, 152, 0, 0.1); border-radius: var(--radius-md);">
            <div style="font-size: 0.875rem; color: var(--text-secondary);">연말 연차수당 발생 예상</div>
            <div style="font-size: 1.5rem; font-weight: 700; color: #FF9800; margin-top: 0.5rem;">
              <span id="expectedAnnualLeavePay">-</span>원
            </div>
          </div>
        </div>

        <!-- 부문별 초과 근무, 야간 근무 현황 -->
        <div style="background: var(--glass-bg); backdrop-filter: blur(20px); border: 1px solid var(--glass-border); border-radius: var(--radius-xl); padding: 1.5rem;">
          <h3 style="font-size: 1.25rem; font-weight: 600; margin-bottom: 1rem;">부문별 초과/야간 근무 현황</h3>
          <canvas id="overtimeChart" style="max-height: 300px;"></canvas>
        </div>

        <!-- 법정 교육 수료율 -->
        <div style="background: var(--glass-bg); backdrop-filter: blur(20px); border: 1px solid var(--glass-border); border-radius: var(--radius-xl); padding: 1.5rem;">
          <h3 style="font-size: 1.25rem; font-weight: 600; margin-bottom: 1rem;">법정 교육 수료율</h3>
          <canvas id="educationCompletionChart" style="max-height: 300px;"></canvas>
          <div style="margin-top: 1rem; display: flex; gap: 1rem; font-size: 0.875rem;">
            <div style="flex: 1; padding: 0.75rem; background: rgba(76, 175, 80, 0.1); border-radius: var(--radius-md);">
              <div style="color: var(--text-secondary);">안전 관련</div>
              <div style="font-weight: 700; color: #4CAF50; margin-top: 0.25rem;"><span id="safetyEducationRate">-</span>%</div>
            </div>
            <div style="flex: 1; padding: 0.75rem; background: rgba(33, 150, 243, 0.1); border-radius: var(--radius-md);">
              <div style="color: var(--text-secondary);">야간 특수 검진</div>
              <div style="font-weight: 700; color: #2196F3; margin-top: 0.25rem;"><span id="nightExamRate">-</span>%</div>
            </div>
          </div>
        </div>

        <!-- 최근 8주 현원 추이 -->
        <div style="background: var(--glass-bg); backdrop-filter: blur(20px); border: 1px solid var(--glass-border); border-radius: var(--radius-xl); padding: 1.5rem;">
          <h3 style="font-size: 1.25rem; font-weight: 600; margin-bottom: 1rem;">최근 8주 현원 추이</h3>
          <canvas id="headcountTrendChart" style="max-height: 300px;"></canvas>
        </div>
      </section>

      <!-- 드릴다운 모달 -->
      <div id="drillDownModal" class="hr-modal" style="display: none; position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.7); z-index: 1000; overflow-y: auto;">
        <div class="hr-modal-content" style="background: var(--bg-primary); margin: 2rem auto; max-width: 900px; border-radius: var(--radius-xl); padding: 2rem;">
          <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem;">
            <h2 id="modalTitle" style="font-size: 1.5rem; font-weight: 600;"></h2>
            <button onclick="closeDrillDown()" style="background: none; border: none; font-size: 2rem; cursor: pointer; color: var(--text-secondary);">&times;</button>
          </div>
          <div id="modalContent"></div>
        </div>
      </div>

    </main>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<script src="/AI/assets/js/hr-dashboard.js?v=2.3&t=<%= cacheBuster %>"></script>
<script src="/AI/assets/js/hr-filter.js?v=2.3&t=<%= cacheBuster %>"></script>
<%@ include file="/AI/admin/hr/layout/footer.jspf" %>

