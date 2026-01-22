// HR 대시보드 전용 필터 관리

const hrFilter = {
  // 필터 상태
  state: {
    department: '전체',
    businessUnit: '전체',
    team: '전체',
    part: '전체',
    line: '전체',
    jobCategory: '전체'
  },
  
  // 초기화
  init() {
    this.loadStateFromURL();
    this.updateFilterOptions();
    this.updateFilterBadges();
    this.updateFilterStates();
  },
  
  // URL에서 필터 상태 로드
  loadStateFromURL() {
    const params = new URLSearchParams(window.location.search);
    this.state.department = params.get('department') || '전체';
    this.state.businessUnit = params.get('businessUnit') || '전체';
    this.state.team = params.get('team') || '전체';
    this.state.part = params.get('part') || '전체';
    this.state.line = params.get('line') || '전체';
    this.state.jobCategory = params.get('jobCategory') || '전체';
    
    // UI에 반영
    this.updateSelectValues();
  },
  
  // 선택된 값들을 UI에 반영
  updateSelectValues() {
    const selectMap = {
      'department': 'filterDepartment',
      'businessUnit': 'filterBusinessUnit',
      'team': 'filterTeam',
      'part': 'filterPart',
      'line': 'filterLine',
      'jobCategory': 'filterJobCategory'
    };
    
    Object.keys(selectMap).forEach(key => {
      const selectId = selectMap[key];
      const select = document.getElementById(selectId);
      if (select && this.state[key]) {
        select.value = this.state[key];
      }
    });
  },
  
  // 본부 변경 시
  onDepartmentChange() {
    const select = document.getElementById('filterDepartment');
    if (!select) return;
    
    this.state.department = select.value;
    
    // 하위 필터 초기화
    this.state.businessUnit = '전체';
    this.state.team = '전체';
    this.state.part = '전체';
    this.state.line = '전체';
    
    this.updateFilterOptions();
    this.updateFilterStates();
  },
  
  // 사업부문 변경 시
  onBusinessUnitChange() {
    const select = document.getElementById('filterBusinessUnit');
    if (!select) return;
    
    this.state.businessUnit = select.value;
    
    // 하위 필터 초기화
    this.state.team = '전체';
    this.state.part = '전체';
    this.state.line = '전체';
    
    this.updateFilterOptions();
    this.updateFilterStates();
  },
  
  // 팀 변경 시
  onTeamChange() {
    const select = document.getElementById('filterTeam');
    if (!select) return;
    
    this.state.team = select.value;
    
    // 하위 필터 초기화
    this.state.part = '전체';
    this.state.line = '전체';
    
    this.updateFilterOptions();
    this.updateFilterStates();
  },
  
  // 파트 변경 시
  onPartChange() {
    const select = document.getElementById('filterPart');
    if (!select) return;
    
    this.state.part = select.value;
    
    // 하위 필터 초기화
    this.state.line = '전체';
    
    this.updateFilterOptions();
    this.updateFilterStates();
  },
  
  // 필터 옵션 업데이트 (계층적)
  updateFilterOptions() {
    // 사업부문 옵션 업데이트
    if (this.state.department && this.state.department !== '전체') {
      this.loadFilterOptions('businessUnit', 'department', this.state.department, 'filterBusinessUnit', () => {
        // 팀 옵션 업데이트
        if (this.state.businessUnit && this.state.businessUnit !== '전체') {
          this.loadFilterOptions('team', 'businessUnit', this.state.businessUnit, 'filterTeam', () => {
            // 파트 옵션 업데이트
            if (this.state.team && this.state.team !== '전체') {
              this.loadFilterOptions('part', 'team', this.state.team, 'filterPart', () => {
                // 라인 옵션 업데이트
                if (this.state.part && this.state.part !== '전체') {
                  this.loadFilterOptions('line', 'part', this.state.part, 'filterLine');
                }
              });
            }
          });
        }
      });
    } else {
      // 본부가 전체이면 하위 필터 비활성화
      this.resetChildFilters(['filterBusinessUnit', 'filterTeam', 'filterPart', 'filterLine']);
    }
  },
  
  // 필터 옵션 로드
  loadFilterOptions(type, parentType, parentValue, selectId, callback) {
    const select = document.getElementById(selectId);
    if (!select) {
      if (callback) callback();
      return;
    }
    
    // 로딩 상태 표시
    const filterItem = select.closest('.hr-filter-item');
    if (filterItem) {
      filterItem.classList.add('hr-filter-loading');
    }
    const wasDisabled = select.disabled;
    select.disabled = true;
    
    // API 호출
    const url = `/AI/api/hr-data.jsp?action=filterOptions&type=${type}&${parentType}=${encodeURIComponent(parentValue)}`;
    
    fetch(url)
      .then(response => {
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }
        return response.json();
      })
      .then(data => {
        // 옵션 초기화
        select.innerHTML = '<option value="전체">전체</option>';
        
        if (data && data.success && data.data && Array.isArray(data.data) && data.data.length > 0) {
          // 상태 키 매핑
          const stateKeyMap = {
            'businessUnit': 'businessUnit',
            'team': 'team',
            'part': 'part',
            'line': 'line'
          };
          const stateKey = stateKeyMap[type] || type;
          
          data.data.forEach(item => {
            if (item && typeof item === 'string') {
              const option = document.createElement('option');
              option.value = item;
              option.textContent = item;
              
              // 현재 선택된 값과 일치하면 선택
              if (item === this.state[stateKey]) {
                option.selected = true;
              }
              
              select.appendChild(option);
            }
          });
        }
        
        // 활성화 (원래 상태로 복원)
        select.disabled = wasDisabled;
        if (filterItem) {
          filterItem.classList.remove('hr-filter-loading');
        }
        
        if (callback) callback();
      })
      .catch(error => {
        console.warn(`${type} 옵션 로드 오류:`, error);
        select.disabled = wasDisabled;
        if (filterItem) {
          filterItem.classList.remove('hr-filter-loading');
        }
        if (callback) callback();
      });
  },
  
  // 하위 필터 초기화
  resetChildFilters(selectIds) {
    selectIds.forEach(id => {
      const select = document.getElementById(id);
      if (select) {
        select.innerHTML = '<option value="전체">전체</option>';
        select.disabled = true;
        const filterItem = select.closest('.hr-filter-item');
        if (filterItem) {
          filterItem.classList.remove('hr-filter-loading');
        }
      }
    });
  },
  
  // 필터 상태 업데이트 (활성/비활성)
  updateFilterStates() {
    const filters = [
      { id: 'filterDepartment', key: 'department', parentKey: null },
      { id: 'filterBusinessUnit', key: 'businessUnit', parentKey: 'department' },
      { id: 'filterTeam', key: 'team', parentKey: 'businessUnit' },
      { id: 'filterPart', key: 'part', parentKey: 'team' },
      { id: 'filterLine', key: 'line', parentKey: 'part' },
      { id: 'filterJobCategory', key: 'jobCategory', parentKey: null }
    ];
    
    filters.forEach((filter) => {
      const select = document.getElementById(filter.id);
      const item = select?.closest('.hr-filter-item');
      
      if (select && item) {
        // 활성 상태 업데이트
        if (this.state[filter.key] && this.state[filter.key] !== '전체') {
          item.classList.add('active');
        } else {
          item.classList.remove('active');
        }
        
        // 비활성화 상태 업데이트 (계층적)
        if (filter.parentKey) {
          const parentValue = this.state[filter.parentKey];
          if (!parentValue || parentValue === '전체') {
            select.disabled = true;
            // 하위 필터도 초기화
            if (filter.key === 'businessUnit') {
              this.state.team = '전체';
              this.state.part = '전체';
              this.state.line = '전체';
            } else if (filter.key === 'team') {
              this.state.part = '전체';
              this.state.line = '전체';
            } else if (filter.key === 'part') {
              this.state.line = '전체';
            }
          } else {
            select.disabled = false;
          }
        }
      }
    });
  },
  
  // 필터 배지 업데이트
  updateFilterBadges() {
    const badgesContainer = document.getElementById('filterBadges');
    if (!badgesContainer) return;
    
    badgesContainer.innerHTML = '';
    
    const activeFilters = [
      { key: 'department', label: '본부', icon: '🏢' },
      { key: 'businessUnit', label: '사업부문', icon: '📊' },
      { key: 'team', label: '팀', icon: '👥' },
      { key: 'part', label: '파트', icon: '📁' },
      { key: 'line', label: '라인', icon: '🔗' },
      { key: 'jobCategory', label: '직군', icon: '💼' }
    ].filter(filter => {
      const value = this.state[filter.key];
      return value && value !== '전체';
    });
    
    if (activeFilters.length === 0) {
      badgesContainer.style.display = 'none';
      return;
    }
    
    badgesContainer.style.display = 'flex';
    
    activeFilters.forEach(filter => {
      const badge = document.createElement('div');
      badge.className = 'hr-filter-badge';
      badge.innerHTML = `
        <span>${filter.icon} ${filter.label}: ${this.state[filter.key]}</span>
        <button class="hr-filter-badge-remove" onclick="hrFilter.removeFilter('${filter.key}')" title="제거">×</button>
      `;
      badgesContainer.appendChild(badge);
    });
  },
  
  // 필터 제거
  removeFilter(key) {
    this.state[key] = '전체';
    
    // 하위 필터도 초기화
    const hierarchy = ['department', 'businessUnit', 'team', 'part', 'line'];
    const index = hierarchy.indexOf(key);
    if (index >= 0) {
      for (let i = index + 1; i < hierarchy.length; i++) {
        this.state[hierarchy[i]] = '전체';
      }
    }
    
    // UI 업데이트
    const selectIdMap = {
      'department': 'filterDepartment',
      'businessUnit': 'filterBusinessUnit',
      'team': 'filterTeam',
      'part': 'filterPart',
      'line': 'filterLine',
      'jobCategory': 'filterJobCategory'
    };
    
    const selectId = selectIdMap[key];
    if (selectId) {
      const select = document.getElementById(selectId);
      if (select) {
        select.value = '전체';
      }
    }
    
    this.updateFilterOptions();
    this.updateFilterStates();
    this.updateFilterBadges();
  },
  
  // 필터 적용
  apply() {
    // 현재 선택된 값들을 state에 반영
    const departmentSelect = document.getElementById('filterDepartment');
    const businessUnitSelect = document.getElementById('filterBusinessUnit');
    const teamSelect = document.getElementById('filterTeam');
    const partSelect = document.getElementById('filterPart');
    const lineSelect = document.getElementById('filterLine');
    const jobCategorySelect = document.getElementById('filterJobCategory');
    
    if (departmentSelect) this.state.department = departmentSelect.value || '전체';
    if (businessUnitSelect) this.state.businessUnit = businessUnitSelect.value || '전체';
    if (teamSelect) this.state.team = teamSelect.value || '전체';
    if (partSelect) this.state.part = partSelect.value || '전체';
    if (lineSelect) this.state.line = lineSelect.value || '전체';
    if (jobCategorySelect) this.state.jobCategory = jobCategorySelect.value || '전체';
    
    // URL 파라미터 생성
    const params = new URLSearchParams();
    
    // 필터 값 추가 (전체가 아닌 것만)
    if (this.state.department && this.state.department !== '전체') {
      params.append('department', this.state.department);
    }
    if (this.state.businessUnit && this.state.businessUnit !== '전체') {
      params.append('businessUnit', this.state.businessUnit);
    }
    if (this.state.team && this.state.team !== '전체') {
      params.append('team', this.state.team);
    }
    if (this.state.part && this.state.part !== '전체') {
      params.append('part', this.state.part);
    }
    if (this.state.line && this.state.line !== '전체') {
      params.append('line', this.state.line);
    }
    if (this.state.jobCategory && this.state.jobCategory !== '전체') {
      params.append('jobCategory', this.state.jobCategory);
    }
    
    // 페이지 이동
    const url = '/AI/admin/hr/dashboard.jsp' + (params.toString() ? '?' + params.toString() : '');
    window.location.href = url;
  },
  
  // 필터 초기화
  reset() {
    Object.keys(this.state).forEach(key => {
      this.state[key] = '전체';
      const selectIdMap = {
        'department': 'filterDepartment',
        'businessUnit': 'filterBusinessUnit',
        'team': 'filterTeam',
        'part': 'filterPart',
        'line': 'filterLine',
        'jobCategory': 'filterJobCategory'
      };
      const selectId = selectIdMap[key];
      if (selectId) {
        const select = document.getElementById(selectId);
        if (select) {
          select.value = '전체';
        }
      }
    });
    
    this.updateFilterOptions();
    this.updateFilterStates();
    this.updateFilterBadges();
    
    // URL 업데이트
    window.location.href = '/AI/admin/hr/dashboard.jsp';
  },
  
  // 개인 검색
  search() {
    const searchTerm = document.getElementById('employeeSearch')?.value.trim();
    if (!searchTerm) {
      alert('사번 또는 이름을 입력해주세요.');
      return;
    }
    
    fetch(`/AI/api/hr-data.jsp?action=searchEmployee&term=${encodeURIComponent(searchTerm)}`)
      .then(response => response.json())
      .then(data => {
        if (data.success && data.data) {
          // showEmployeeCard는 hr-dashboard.js에 정의되어 있음
          if (typeof showEmployeeCard === 'function') {
            showEmployeeCard(data.data);
          } else {
            console.error('showEmployeeCard 함수를 찾을 수 없습니다.');
            alert('검색 결과를 표시할 수 없습니다.');
          }
        } else {
          alert('검색 결과가 없습니다.');
        }
      })
      .catch(error => {
        console.error('직원 검색 오류:', error);
        alert('검색 중 오류가 발생했습니다.');
      });
  }
};

// 페이지 로드 시 초기화
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', function() {
    hrFilter.init();
  });
} else {
  // DOM이 이미 로드된 경우
  hrFilter.init();
}

// 전역 함수 (하위 호환성)
function resetFilters() {
  hrFilter.reset();
}

function applyFilters() {
  hrFilter.apply();
}

function searchEmployee() {
  hrFilter.search();
}
