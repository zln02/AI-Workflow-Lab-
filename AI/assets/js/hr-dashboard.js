// HR 대시보드 JavaScript - 리팩토링 버전

// 차트 인스턴스 관리
const charts = {
  headcountTrend: null,
  vacancyLeadtime: null,
  teamTurnover: null,
  annualLeaveProgress: null,
  overtime: null,
  educationCompletion: null
};

// 임시 데이터 (실제 API 연동 전까지 사용)
const mockData = {
  // 최근 8주 현원 추이
  headcountTrend: {
    dates: ['2025-11-10', '2025-11-17', '2025-11-24', '2025-12-01', '2025-12-08', '2025-12-15', '2025-12-22', '2025-12-29'],
    headcounts: [95, 97, 98, 96, 99, 101, 103, 105]
  },
  // 공석/채용 리드타임
  vacancyLeadtime: {
    weeks: ['1주', '2주', '3주', '4주', '5주', '6주', '7주', '8주'],
    vacancies: [5, 8, 6, 10, 7, 9, 8, 6],
    recruitments: [3, 5, 4, 7, 5, 6, 5, 4],
    leadtimes: [14, 18, 16, 21, 19, 22, 20, 17]
  },
  // 각 팀별 입/퇴사율 (더 많은 팀 데이터)
  teamTurnover: {
    teams: [
      '개발팀', '인프라팀', 'QA팀', 'DevOps팀',
      '영업1팀', '영업2팀', '영업3팀', '해외영업팀',
      '마케팅팀', '브랜드팀', '콘텐츠팀',
      '인사팀', '총무팀', '재무팀', '회계팀',
      '기획팀', '전략팀', 'PM팀', '디자인팀'
    ],
    hireRates: [12, 8, 6, 10, 15, 10, 8, 12, 8, 5, 7, 5, 4, 6, 5, 7, 6, 5, 8, 9],
    resignationRates: [5, 3, 2, 4, 8, 6, 5, 7, 4, 2, 3, 2, 1, 3, 2, 3, 2, 2, 4, 3]
  },
  // 연차 사용 진척률
  annualLeaveProgress: {
    used: 45.8,
    remaining: 54.2,
    expectedPay: 45000000
  },
  // 부문별 초과/야간 근무 (더 많은 부문 데이터)
  overtime: {
    departments: [
      '경영지원본부', '기술본부', '영업본부', '마케팅본부',
      'R&D본부', '생산본부', '품질본부', '물류본부'
    ],
    overtimeHours: [120, 180, 150, 100, 200, 160, 140, 110],
    nightWorkHours: [40, 60, 50, 30, 80, 55, 45, 35],
    // 월별 데이터도 추가
    monthlyOvertime: [
      { month: '9월', hours: [110, 170, 140, 95, 190, 150, 130, 105] },
      { month: '10월', hours: [115, 175, 145, 98, 195, 155, 135, 108] },
      { month: '11월', hours: [120, 180, 150, 100, 200, 160, 140, 110] }
    ]
  },
  // 법정 교육 수료율 (더 많은 부문 및 상세 데이터)
  educationCompletion: {
    departments: [
      '경영지원본부', '기술본부', '영업본부', '마케팅본부',
      'R&D본부', '생산본부', '품질본부', '물류본부'
    ],
    safetyRates: [98, 95, 92, 96, 97, 99, 94, 93],
    nightExamRates: [90, 88, 85, 89, 87, 91, 86, 88],
    // 교육 유형별 상세 데이터
    educationTypes: {
      '안전보건교육': [98, 95, 92, 96, 97, 99, 94, 93],
      '화학물질안전교육': [85, 82, 78, 88, 90, 95, 80, 82],
      '전기안전교육': [92, 90, 88, 91, 93, 96, 89, 90],
      '소방안전교육': [96, 94, 91, 95, 97, 98, 93, 94]
    },
    // 야간 특수 검진 유형별
    nightExamTypes: {
      '야간작업자검진': [90, 88, 85, 89, 87, 91, 86, 88],
      '특수건강검진': [88, 86, 83, 87, 85, 89, 84, 86],
      '일반건강검진': [95, 93, 90, 94, 92, 96, 91, 93]
    }
  }
};

// 페이지 로드 시 초기화
document.addEventListener('DOMContentLoaded', function() {
  initializeDashboard();
});

// 대시보드 초기화
function initializeDashboard() {
  loadAllCharts();
  loadKPIData();
  setupAutoRefresh();
  // 필터 초기화는 hr-filter.js에서 처리됩니다
}

// 모든 차트 로드
function loadAllCharts() {
  loadHeadcountTrend();
  loadVacancyLeadtime();
  loadTeamTurnover();
  loadAnnualLeaveProgress();
  loadOvertime();
  loadEducationCompletion();
}

// ==================== 차트 로드 함수들 ====================

// 현원 추이 차트 로드
function loadHeadcountTrend() {
  const ctx = document.getElementById('headcountTrendChart');
  if (!ctx) return;
  
  // API에서 데이터 가져오기 시도, 실패 시 임시 데이터 사용
  fetch('/AI/api/hr-data.jsp?action=trend&weeks=8')
    .then(response => response.json())
    .then(data => {
      let chartData = mockData.headcountTrend;
      if (data.success && data.data && data.data.length > 0) {
        chartData = {
          dates: data.data.map(item => item.date),
          headcounts: data.data.map(item => item.headcount)
        };
      }
      renderHeadcountTrendChart(ctx, chartData);
    })
    .catch(error => {
      console.warn('현원 추이 API 오류, 임시 데이터 사용:', error);
      renderHeadcountTrendChart(ctx, mockData.headcountTrend);
    });
}

function renderHeadcountTrendChart(ctx, data) {
  if (charts.headcountTrend) {
    charts.headcountTrend.destroy();
  }
  
  charts.headcountTrend = new Chart(ctx, {
    type: 'line',
    data: {
      labels: data.dates,
      datasets: [{
        label: '현원',
        data: data.headcounts,
        borderColor: 'rgb(75, 192, 192)',
        backgroundColor: 'rgba(75, 192, 192, 0.1)',
        tension: 0.4,
        fill: true,
        pointRadius: 4,
        pointHoverRadius: 6
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          display: true,
          position: 'top'
        },
        tooltip: {
          mode: 'index',
          intersect: false
        }
      },
      scales: {
        y: {
          beginAtZero: false,
          title: {
            display: true,
            text: '인원 수'
          }
        },
        x: {
          title: {
            display: true,
            text: '날짜'
          }
        }
      }
    }
  });
}

// 공석/채용 리드타임 차트 로드
function loadVacancyLeadtime() {
  const ctx = document.getElementById('vacancyLeadtimeChart');
  if (!ctx) return;
  
  renderVacancyLeadtimeChart(ctx, mockData.vacancyLeadtime);
}

function renderVacancyLeadtimeChart(ctx, data) {
  if (charts.vacancyLeadtime) {
    charts.vacancyLeadtime.destroy();
  }
  
  charts.vacancyLeadtime = new Chart(ctx, {
    type: 'bar',
    data: {
      labels: data.weeks,
      datasets: [{
        label: '공석',
        data: data.vacancies,
        backgroundColor: 'rgba(255, 152, 0, 0.6)',
        borderColor: 'rgb(255, 152, 0)',
        borderWidth: 1
      }, {
        label: '채용 진행',
        data: data.recruitments,
        backgroundColor: 'rgba(76, 175, 80, 0.6)',
        borderColor: 'rgb(76, 175, 80)',
        borderWidth: 1
      }, {
        label: '평균 리드타임 (일)',
        data: data.leadtimes,
        type: 'line',
        borderColor: 'rgb(156, 39, 176)',
        backgroundColor: 'rgba(156, 39, 176, 0.1)',
        borderWidth: 2,
        fill: false,
        yAxisID: 'y1'
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          display: true,
          position: 'top'
        }
      },
      scales: {
        y: {
          beginAtZero: true,
          title: {
            display: true,
            text: '인원 수'
          }
        },
        y1: {
          type: 'linear',
          display: true,
          position: 'right',
          title: {
            display: true,
            text: '리드타임 (일)'
          },
          grid: {
            drawOnChartArea: false
          }
        }
      }
    }
  });
}

// 각 팀별 입/퇴사율 차트
function loadTeamTurnover() {
  const ctx = document.getElementById('teamTurnoverChart');
  if (!ctx) return;
  
  // 필터에 따라 데이터 필터링
  const filteredData = getFilteredTeamTurnoverData();
  renderTeamTurnoverChart(ctx, filteredData);
}

// 필터에 따른 팀별 입/퇴사율 데이터 필터링
function getFilteredTeamTurnoverData() {
  const department = document.getElementById('filterDepartment')?.value;
  const businessUnit = document.getElementById('filterBusinessUnit')?.value;
  const team = document.getElementById('filterTeam')?.value;
  
  // 필터가 적용되지 않았으면 전체 데이터 반환
  if ((!department || department === '전체') && 
      (!businessUnit || businessUnit === '전체') && 
      (!team || team === '전체')) {
    return mockData.teamTurnover;
  }
  
  // 필터에 맞는 팀만 필터링 (실제로는 API에서 가져와야 함)
  // 여기서는 샘플로 일부 팀만 표시
  return {
    teams: mockData.teamTurnover.teams.slice(0, 8),
    hireRates: mockData.teamTurnover.hireRates.slice(0, 8),
    resignationRates: mockData.teamTurnover.resignationRates.slice(0, 8)
  };
}

function renderTeamTurnoverChart(ctx, data) {
  if (charts.teamTurnover) {
    charts.teamTurnover.destroy();
  }
  
  charts.teamTurnover = new Chart(ctx, {
    type: 'bar',
    data: {
      labels: data.teams,
      datasets: [{
        label: '입사율 (%)',
        data: data.hireRates,
        backgroundColor: 'rgba(76, 175, 80, 0.7)',
        borderColor: 'rgb(76, 175, 80)',
        borderWidth: 2,
        borderRadius: 4
      }, {
        label: '퇴사율 (%)',
        data: data.resignationRates,
        backgroundColor: 'rgba(244, 67, 54, 0.7)',
        borderColor: 'rgb(244, 67, 54)',
        borderWidth: 2,
        borderRadius: 4
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          display: true,
          position: 'top'
        },
        tooltip: {
          callbacks: {
            label: function(context) {
              return context.dataset.label + ': ' + context.parsed.y + '%';
            }
          }
        }
      },
      scales: {
        y: {
          beginAtZero: true,
          max: 25,
          title: {
            display: true,
            text: '비율 (%)',
            color: 'var(--text-secondary)'
          },
          ticks: {
            callback: function(value) {
              return value + '%';
            }
          }
        },
        x: {
          ticks: {
            maxRotation: 45,
            minRotation: 45
          }
        }
      }
    }
  });
}

// 연간 연차 사용 진척률
function loadAnnualLeaveProgress() {
  const ctx = document.getElementById('annualLeaveProgressChart');
  if (!ctx) return;
  
  renderAnnualLeaveProgressChart(ctx, mockData.annualLeaveProgress);
  
  // 연말 연차수당 발생 예상 금액 표시
  document.getElementById('expectedAnnualLeavePay').textContent = 
    formatCurrency(mockData.annualLeaveProgress.expectedPay);
}

function renderAnnualLeaveProgressChart(ctx, data) {
  if (charts.annualLeaveProgress) {
    charts.annualLeaveProgress.destroy();
  }
  
  charts.annualLeaveProgress = new Chart(ctx, {
    type: 'doughnut',
    data: {
      labels: ['사용', '잔여'],
      datasets: [{
        data: [data.used, data.remaining],
        backgroundColor: [
          'rgba(76, 175, 80, 0.8)',
          'rgba(158, 158, 158, 0.3)'
        ],
        borderWidth: 2,
        borderColor: 'var(--bg-primary)'
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          display: true,
          position: 'bottom'
        },
        tooltip: {
          callbacks: {
            label: function(context) {
              return context.label + ': ' + context.parsed + '%';
            }
          }
        }
      }
    }
  });
}

// 부문별 초과/야간 근무 현황
function loadOvertime() {
  const ctx = document.getElementById('overtimeChart');
  if (!ctx) return;
  
  // 필터에 따라 데이터 필터링
  const filteredData = getFilteredOvertimeData();
  renderOvertimeChart(ctx, filteredData);
}

// 필터에 따른 부문별 초과/야간 근무 데이터 필터링
function getFilteredOvertimeData() {
  const department = document.getElementById('filterDepartment')?.value;
  
  // 필터가 적용되지 않았으면 전체 데이터 반환
  if (!department || department === '전체') {
    return mockData.overtime;
  }
  
  // 필터에 맞는 부문만 필터링 (실제로는 API에서 가져와야 함)
  return mockData.overtime;
}

function renderOvertimeChart(ctx, data) {
  if (charts.overtime) {
    charts.overtime.destroy();
  }
  
  charts.overtime = new Chart(ctx, {
    type: 'bar',
    data: {
      labels: data.departments,
      datasets: [{
        label: '초과 근무 (시간)',
        data: data.overtimeHours,
        backgroundColor: 'rgba(33, 150, 243, 0.7)',
        borderColor: 'rgb(33, 150, 243)',
        borderWidth: 2,
        borderRadius: 4
      }, {
        label: '야간 근무 (시간)',
        data: data.nightWorkHours,
        backgroundColor: 'rgba(156, 39, 176, 0.7)',
        borderColor: 'rgb(156, 39, 176)',
        borderWidth: 2,
        borderRadius: 4
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          display: true,
          position: 'top'
        },
        tooltip: {
          callbacks: {
            label: function(context) {
              return context.dataset.label + ': ' + context.parsed.y + '시간';
            }
          }
        }
      },
      scales: {
        y: {
          beginAtZero: true,
          title: {
            display: true,
            text: '시간',
            color: 'var(--text-secondary)'
          },
          ticks: {
            callback: function(value) {
              return value + '시간';
            }
          }
        },
        x: {
          ticks: {
            maxRotation: 45,
            minRotation: 45
          }
        }
      }
    }
  });
}

// 법정 교육 수료율
function loadEducationCompletion() {
  const ctx = document.getElementById('educationCompletionChart');
  if (!ctx) return;
  
  // 필터에 따라 데이터 필터링
  const filteredData = getFilteredEducationData();
  renderEducationCompletionChart(ctx, filteredData);
  
  // 평균 수료율 계산 및 표시
  const avgSafety = filteredData.safetyRates.reduce((a, b) => a + b, 0) / 
                    filteredData.safetyRates.length;
  const avgNight = filteredData.nightExamRates.reduce((a, b) => a + b, 0) / 
                   filteredData.nightExamRates.length;
  
  const safetyEl = document.getElementById('safetyEducationRate');
  const nightEl = document.getElementById('nightExamRate');
  if (safetyEl) safetyEl.textContent = avgSafety.toFixed(1);
  if (nightEl) nightEl.textContent = avgNight.toFixed(1);
}

// 필터에 따른 법정 교육 수료율 데이터 필터링
function getFilteredEducationData() {
  const department = document.getElementById('filterDepartment')?.value;
  
  // 필터가 적용되지 않았으면 전체 데이터 반환
  if (!department || department === '전체') {
    return mockData.educationCompletion;
  }
  
  // 필터에 맞는 부문만 필터링 (실제로는 API에서 가져와야 함)
  return mockData.educationCompletion;
}

function renderEducationCompletionChart(ctx, data) {
  if (charts.educationCompletion) {
    charts.educationCompletion.destroy();
  }
  
  charts.educationCompletion = new Chart(ctx, {
    type: 'bar',
    data: {
      labels: data.departments,
      datasets: [{
        label: '안전 관련 교육 수료율 (%)',
        data: data.safetyRates,
        backgroundColor: 'rgba(76, 175, 80, 0.7)',
        borderColor: 'rgb(76, 175, 80)',
        borderWidth: 2,
        borderRadius: 4
      }, {
        label: '야간 특수 검진 수료율 (%)',
        data: data.nightExamRates,
        backgroundColor: 'rgba(33, 150, 243, 0.7)',
        borderColor: 'rgb(33, 150, 243)',
        borderWidth: 2,
        borderRadius: 4
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          display: true,
          position: 'top'
        },
        tooltip: {
          callbacks: {
            label: function(context) {
              return context.dataset.label + ': ' + context.parsed.y + '%';
            }
          }
        }
      },
      scales: {
        y: {
          beginAtZero: true,
          max: 100,
          title: {
            display: true,
            text: '수료율 (%)',
            color: 'var(--text-secondary)'
          },
          ticks: {
            callback: function(value) {
              return value + '%';
            }
          }
        },
        x: {
          ticks: {
            maxRotation: 45,
            minRotation: 45
          }
        }
      }
    }
  });
}

// ==================== KPI 데이터 로드 ====================

function loadKPIData() {
  fetch('/AI/api/hr-data.jsp?action=summary')
    .then(response => response.json())
    .then(data => {
      if (data.success && data.data) {
        updateKPIData(data.data);
      } else {
        updateKPIDataWithMock();
      }
    })
    .catch(error => {
      console.warn('KPI 데이터 로드 오류, 임시 데이터 사용:', error);
      updateKPIDataWithMock();
    });
}

function updateKPIData(data) {
  // 인건비 상승률 계산
  const currentCost = parseFloat(data.totalLaborCost) || 0;
  const lastYearCost = currentCost * 0.95;
  const increaseRate = lastYearCost > 0 ? ((currentCost - lastYearCost) / lastYearCost * 100).toFixed(1) : '5.3';
  
  const costIncreaseEl = document.getElementById('costIncreaseRate');
  if (costIncreaseEl) costIncreaseEl.textContent = increaseRate;
  
  // 퇴직금, 연차수당 예상
  const severancePayEl = document.getElementById('severancePay');
  const annualLeavePayEl = document.getElementById('annualLeavePay');
  if (severancePayEl) severancePayEl.textContent = formatCurrency(50000000);
  if (annualLeavePayEl) annualLeavePayEl.textContent = formatCurrency(30000000);
}

function updateKPIDataWithMock() {
  const costIncreaseEl = document.getElementById('costIncreaseRate');
  if (costIncreaseEl) costIncreaseEl.textContent = '5.3';
  
  const severancePayEl = document.getElementById('severancePay');
  const annualLeavePayEl = document.getElementById('annualLeavePay');
  if (severancePayEl) severancePayEl.textContent = formatCurrency(50000000);
  if (annualLeavePayEl) annualLeavePayEl.textContent = formatCurrency(30000000);
}

// ==================== 필터 관련 함수 ====================
// 필터 관련 함수는 hr-filter.js로 이동되었습니다.

function showEmployeeCard(employee) {
  const modal = document.getElementById('drillDownModal');
  const modalTitle = document.getElementById('modalTitle');
  const modalContent = document.getElementById('modalContent');
  
  if (!modal || !modalTitle || !modalContent) return;
  
  modalTitle.textContent = employee.name + ' (' + employee.employeeId + ')';
  
  let html = '<div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 1rem;">';
  html += '<div><strong>본부:</strong> ' + (employee.department || '-') + '</div>';
  html += '<div><strong>사업부문:</strong> ' + (employee.businessUnit || '-') + '</div>';
  html += '<div><strong>팀:</strong> ' + (employee.team || '-') + '</div>';
  html += '<div><strong>파트:</strong> ' + (employee.part || '-') + '</div>';
  html += '<div><strong>라인:</strong> ' + (employee.line || '-') + '</div>';
  html += '<div><strong>직급:</strong> ' + (employee.position || '-') + '</div>';
  html += '<div><strong>연고지:</strong> ' + (employee.location || '-') + '</div>';
  html += '<div><strong>고과:</strong> ' + (employee.performanceGrade || '-') + '</div>';
  html += '<div><strong>연봉 등급:</strong> ' + (employee.salaryGrade || '-') + '</div>';
  html += '<div><strong>연봉:</strong> ' + formatCurrency(employee.salary || 0) + '</div>';
  html += '<div><strong>입사일:</strong> ' + (employee.joinDate || '-') + '</div>';
  html += '<div><strong>상태:</strong> ' + (employee.status || '-') + '</div>';
  html += '</div>';
  
  modalContent.innerHTML = html;
  modal.style.display = 'block';
}

// ==================== 드릴다운 기능 ====================

function drillDown(kpiType, organizationLevel, organizationValue) {
  const modal = document.getElementById('drillDownModal');
  const modalTitle = document.getElementById('modalTitle');
  const modalContent = document.getElementById('modalContent');
  
  if (!modal || !modalTitle || !modalContent) return;
  
  const titles = {
    'headcount': '현원 상세 정보',
    'movement': '입사/퇴사/발령 계획',
    'vacancy': 'TO/채용 계획',
    'leave': '휴직&복직 인원 정보',
    'cost': '인력비용 상세',
    'costIncrease': '내년 인건비 상승률 예상 및 대응',
    'temporaryCost': '일시적 인건비 지출 예상'
  };
  
  modalTitle.textContent = titles[kpiType] || '상세 정보';
  modalContent.innerHTML = '<p>데이터를 불러오는 중...</p>';
  modal.style.display = 'block';
  
  const department = document.getElementById('filterDepartment')?.value;
  const businessUnit = document.getElementById('filterBusinessUnit')?.value;
  const team = document.getElementById('filterTeam')?.value;
  
  const params = new URLSearchParams();
  params.append('action', 'drillDown');
  params.append('kpiType', kpiType);
  if (department && department !== '전체') params.append('department', department);
  if (businessUnit && businessUnit !== '전체') params.append('businessUnit', businessUnit);
  if (team && team !== '전체') params.append('team', team);
  if (organizationLevel) params.append('level', organizationLevel);
  if (organizationValue) params.append('value', organizationValue);
  
  fetch('/AI/api/hr-data.jsp?' + params.toString())
    .then(response => response.json())
    .then(data => {
      if (data.success && data.data) {
        modalContent.innerHTML = renderDrillDownContent(kpiType, data.data, organizationLevel);
      } else {
        modalContent.innerHTML = '<p>데이터를 불러올 수 없습니다.</p>';
      }
    })
    .catch(error => {
      console.error('드릴다운 데이터 로드 오류:', error);
      modalContent.innerHTML = '<p>데이터를 불러오는 중 오류가 발생했습니다.</p>';
    });
}

function renderDrillDownContent(kpiType, data, level) {
  const renderers = {
    'headcount': renderHeadcountDetail,
    'movement': renderMovementDetail,
    'vacancy': renderVacancyDetail,
    'leave': renderLeaveDetail,
    'cost': (d) => renderCostDetail(d, 'cost'),
    'costIncrease': (d) => renderCostDetail(d, 'costIncrease'),
    'temporaryCost': (d) => renderCostDetail(d, 'temporaryCost')
  };
  
  const renderer = renderers[kpiType] || renderGenericDetail;
  return renderer(data, level) || '<p>데이터가 없습니다.</p>';
}

function renderHeadcountDetail(data, level) {
  let html = '<div style="margin-bottom: 1rem;">';
  html += '<div style="display: flex; gap: 1rem; margin-bottom: 1rem;">';
  html += '<button onclick="drillDown(\'headcount\', \'department\', null)" class="btn">본부별</button>';
  html += '<button onclick="drillDown(\'headcount\', \'businessUnit\', null)" class="btn">사업부문별</button>';
  html += '<button onclick="drillDown(\'headcount\', \'team\', null)" class="btn">팀별</button>';
  html += '</div>';
  html += '<table class="admin-table" style="width: 100%;">';
  html += '<thead><tr><th>조직</th><th>직급</th><th>연고지</th><th>고과</th><th>연봉 등급</th><th>인원</th></tr></thead><tbody>';
  
  if (data.employees && data.employees.length > 0) {
    data.employees.forEach(emp => {
      html += '<tr onclick="showEmployeeDetail(' + emp.id + ')" style="cursor: pointer;">';
      html += '<td>' + (emp.team || emp.businessUnit || emp.department || '-') + '</td>';
      html += '<td>' + (emp.position || '-') + '</td>';
      html += '<td>' + (emp.location || '-') + '</td>';
      html += '<td>' + (emp.performanceGrade || '-') + '</td>';
      html += '<td>' + (emp.salaryGrade || '-') + '</td>';
      html += '<td>1</td>';
      html += '</tr>';
    });
  } else {
    html += '<tr><td colspan="6" style="text-align: center;">데이터가 없습니다.</td></tr>';
  }
  
  html += '</tbody></table></div>';
  return html;
}

function renderMovementDetail(data) {
  let html = '<table class="admin-table" style="width: 100%;">';
  html += '<thead><tr><th>유형</th><th>계획일</th><th>본부</th><th>사업부문</th><th>팀</th><th>직급</th><th>상태</th></tr></thead><tbody>';
  
  if (data.movements && data.movements.length > 0) {
    data.movements.forEach(mv => {
      html += '<tr>';
      html += '<td>' + (mv.movementType || '-') + '</td>';
      html += '<td>' + (mv.plannedDate || '-') + '</td>';
      html += '<td>' + (mv.department || '-') + '</td>';
      html += '<td>' + (mv.businessUnit || '-') + '</td>';
      html += '<td>' + (mv.team || '-') + '</td>';
      html += '<td>' + (mv.position || '-') + '</td>';
      html += '<td>' + (mv.status || '-') + '</td>';
      html += '</tr>';
    });
  } else {
    html += '<tr><td colspan="7" style="text-align: center;">데이터가 없습니다.</td></tr>';
  }
  
  html += '</tbody></table>';
  return html;
}

function renderVacancyDetail(data) {
  let html = '<table class="admin-table" style="width: 100%;">';
  html += '<thead><tr><th>본부</th><th>사업부문</th><th>팀</th><th>직군</th><th>직급</th><th>채용 인원</th><th>상태</th><th>리드타임</th></tr></thead><tbody>';
  
  if (data.recruitments && data.recruitments.length > 0) {
    data.recruitments.forEach(rec => {
      html += '<tr>';
      html += '<td>' + (rec.department || '-') + '</td>';
      html += '<td>' + (rec.businessUnit || '-') + '</td>';
      html += '<td>' + (rec.team || '-') + '</td>';
      html += '<td>' + (rec.jobCategory || '-') + '</td>';
      html += '<td>' + (rec.position || '-') + '</td>';
      html += '<td>' + (rec.quota || 0) + '</td>';
      html += '<td>' + (rec.status || '-') + '</td>';
      html += '<td>' + (rec.leadtimeDays || '-') + '일</td>';
      html += '</tr>';
    });
  } else {
    html += '<tr><td colspan="8" style="text-align: center;">데이터가 없습니다.</td></tr>';
  }
  
  html += '</tbody></table>';
  return html;
}

function renderLeaveDetail(data) {
  let html = '<table class="admin-table" style="width: 100%;">';
  html += '<thead><tr><th>이름</th><th>휴직 유형</th><th>휴직 시작일</th><th>예상 복직일</th><th>잔여 휴직일</th><th>직급</th><th>연고지</th><th>연봉 등급</th><th>상태</th></tr></thead><tbody>';
  
  if (data.leaves && data.leaves.length > 0) {
    data.leaves.forEach(leave => {
      html += '<tr>';
      html += '<td>' + (leave.employeeName || '-') + '</td>';
      html += '<td>' + (leave.leaveType || '-') + '</td>';
      html += '<td>' + (leave.leaveStartDate || '-') + '</td>';
      html += '<td>' + (leave.expectedReturnDate || '-') + '</td>';
      html += '<td>' + (leave.remainingDays || 0) + '일</td>';
      html += '<td>' + (leave.position || '-') + '</td>';
      html += '<td>' + (leave.location || '-') + '</td>';
      html += '<td>' + (leave.salaryGrade || '-') + '</td>';
      html += '<td>' + (leave.status || '-') + '</td>';
      html += '</tr>';
    });
  } else {
    html += '<tr><td colspan="9" style="text-align: center;">데이터가 없습니다.</td></tr>';
  }
  
  html += '</tbody></table>';
  return html;
}

function renderCostDetail(data, kpiType) {
  let html = '<div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 1rem;">';
  
  if (kpiType === 'costIncrease') {
    html += '<div style="padding: 1rem; background: rgba(244, 67, 54, 0.1); border-radius: var(--radius-md);">';
    html += '<div style="font-size: 0.875rem; color: var(--text-secondary);">내년 인건비 상승률</div>';
    html += '<div style="font-size: 2rem; font-weight: 700; color: #F44336; margin-top: 0.5rem;">' + (data.increaseRate || '5.3') + '%</div>';
    html += '</div>';
    html += '<div style="padding: 1rem; background: rgba(33, 150, 243, 0.1); border-radius: var(--radius-md);">';
    html += '<div style="font-size: 0.875rem; color: var(--text-secondary);">대응 방안</div>';
    html += '<div style="margin-top: 0.5rem; font-size: 0.875rem;">' + (data.countermeasures || '검토 중') + '</div>';
    html += '</div>';
  }
  
  if (kpiType === 'temporaryCost') {
    html += '<div style="padding: 1rem; background: rgba(255, 152, 0, 0.1); border-radius: var(--radius-md);">';
    html += '<div style="font-size: 0.875rem; color: var(--text-secondary);">퇴직금 예상</div>';
    html += '<div style="font-size: 1.5rem; font-weight: 700; color: #FF9800; margin-top: 0.5rem;">' + formatCurrency(data.severancePay || 50000000) + '</div>';
    html += '</div>';
    html += '<div style="padding: 1rem; background: rgba(76, 175, 80, 0.1); border-radius: var(--radius-md);">';
    html += '<div style="font-size: 0.875rem; color: var(--text-secondary);">연차수당 예상</div>';
    html += '<div style="font-size: 1.5rem; font-weight: 700; color: #4CAF50; margin-top: 0.5rem;">' + formatCurrency(data.annualLeavePay || 30000000) + '</div>';
    html += '</div>';
  }
  
  html += '</div>';
  return html;
}

function renderGenericDetail(data) {
  return '<pre>' + JSON.stringify(data, null, 2) + '</pre>';
}

function showEmployeeDetail(employeeId) {
  fetch(`/AI/api/hr-data.jsp?action=employeeDetail&id=${employeeId}`)
    .then(response => response.json())
    .then(data => {
      if (data.success && data.data) {
        showEmployeeCard(data.data);
      }
    })
    .catch(error => {
      console.error('직원 상세 정보 로드 오류:', error);
    });
}

function closeDrillDown() {
  const modal = document.getElementById('drillDownModal');
  if (modal) modal.style.display = 'none';
}

// 모달 외부 클릭 시 닫기
document.addEventListener('click', function(e) {
  const modal = document.getElementById('drillDownModal');
  if (e.target === modal) {
    closeDrillDown();
  }
});

// ==================== 유틸리티 함수 ====================

function formatCurrency(value) {
  if (typeof value === 'number') {
    return value.toLocaleString('ko-KR') + '원';
  }
  if (typeof value === 'object' && value !== null) {
    return parseFloat(value).toLocaleString('ko-KR') + '원';
  }
  return '0원';
}

function setupAutoRefresh() {
  setInterval(function() {
    loadAllCharts();
  }, 5 * 60 * 1000); // 5분마다 차트 새로고침
}
