package dao;

import db.DBConnect;
import model.HRData;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * HR 데이터 접근 객체
 */
public class HRDAO {
  
  /**
   * 전체 HR 현황 요약 조회 (최신 데이터 기준)
   */
  public Map<String, Object> getHRSummary(String department, String division, String jobCategory) {
    Map<String, Object> summary = new HashMap<>();
    
    try (Connection conn = DBConnect.getConnection()) {
      // 필터 조건 생성
      StringBuilder whereClause = new StringBuilder("WHERE 1=1");
      List<Object> params = new ArrayList<>();
      
      if (department != null && !department.isEmpty() && !"전체".equals(department)) {
        whereClause.append(" AND department = ?");
        params.add(department);
      }
      if (division != null && !division.isEmpty() && !"전체".equals(division)) {
        whereClause.append(" AND division = ?");
        params.add(division);
      }
      if (jobCategory != null && !jobCategory.isEmpty() && !"전체".equals(jobCategory)) {
        whereClause.append(" AND job_category = ?");
        params.add(jobCategory);
      }
      
      // 최신 기준일 가져오기
      Timestamp latestDate = null;
      String latestDateQuery = "SELECT MAX(as_of_date) as latest_date FROM hr_data " + whereClause;
      try (PreparedStatement ps = conn.prepareStatement(latestDateQuery)) {
        for (int i = 0; i < params.size(); i++) {
          ps.setObject(i + 1, params.get(i));
        }
        try (ResultSet rs = ps.executeQuery()) {
          if (rs.next()) {
            latestDate = rs.getTimestamp("latest_date");
          }
        }
      }
      
      summary.put("asOfDate", latestDate);
      
      if (latestDate == null) {
        // 데이터가 없으면 기본값 반환
        return summary;
      }
      
      // 집계 쿼리
      String aggregateQuery = "SELECT " +
          "SUM(quota) as total_quota, " +
          "SUM(current_headcount) as total_current_headcount, " +
          "SUM(new_hires) as total_new_hires, " +
          "SUM(resignations) as total_resignations, " +
          "SUM(transfers) as total_transfers, " +
          "SUM(vacancies) as total_vacancies, " +
          "SUM(on_leave) as total_on_leave, " +
          "SUM(returned) as total_returned, " +
          "SUM(labor_cost) as total_labor_cost, " +
          "MAX(data_quality) as data_quality " +
          "FROM hr_data " + whereClause + " AND as_of_date = ?";
      
      try (PreparedStatement ps = conn.prepareStatement(aggregateQuery)) {
        int paramIndex = 1;
        for (Object param : params) {
          ps.setObject(paramIndex++, param);
        }
        ps.setTimestamp(paramIndex, latestDate);
        
        try (ResultSet rs = ps.executeQuery()) {
          if (rs.next()) {
            summary.put("totalQuota", rs.getInt("total_quota"));
            summary.put("totalCurrentHeadcount", rs.getInt("total_current_headcount"));
            summary.put("totalNewHires", rs.getInt("total_new_hires"));
            summary.put("totalResignations", rs.getInt("total_resignations"));
            summary.put("totalTransfers", rs.getInt("total_transfers"));
            summary.put("totalVacancies", rs.getInt("total_vacancies"));
            summary.put("totalOnLeave", rs.getInt("total_on_leave"));
            summary.put("totalReturned", rs.getInt("total_returned"));
            summary.put("totalLaborCost", rs.getBigDecimal("total_labor_cost"));
            summary.put("dataQuality", rs.getString("data_quality"));
          }
        }
      }
    } catch (SQLException e) {
      System.err.println("HR 요약 조회 중 오류: " + e.getMessage());
      e.printStackTrace();
      // 기본값 반환
      summary.put("totalQuota", 0);
      summary.put("totalCurrentHeadcount", 0);
      summary.put("totalNewHires", 0);
      summary.put("totalResignations", 0);
      summary.put("totalTransfers", 0);
      summary.put("totalVacancies", 0);
      summary.put("totalOnLeave", 0);
      summary.put("totalReturned", 0);
      summary.put("totalLaborCost", java.math.BigDecimal.ZERO);
      summary.put("dataQuality", "WARNING");
      summary.put("asOfDate", new Timestamp(System.currentTimeMillis()));
    }
    
    return summary;
  }
  
  /**
   * 최근 N주간 현원 추이 조회
   */
  public List<Map<String, Object>> getHeadcountTrend(int weeks) {
    List<Map<String, Object>> trends = new ArrayList<>();
    
    try (Connection conn = DBConnect.getConnection()) {
      String query = "SELECT " +
          "DATE_FORMAT(as_of_date, '%Y-%m-%d') as date, " +
          "SUM(current_headcount) as headcount " +
          "FROM hr_data " +
          "WHERE as_of_date >= DATE_SUB((SELECT MAX(as_of_date) FROM hr_data), INTERVAL ? WEEK) " +
          "GROUP BY DATE_FORMAT(as_of_date, '%Y-%m-%d') " +
          "ORDER BY date ASC";
      
      try (PreparedStatement ps = conn.prepareStatement(query)) {
        ps.setInt(1, weeks);
        try (ResultSet rs = ps.executeQuery()) {
          while (rs.next()) {
            Map<String, Object> trend = new HashMap<>();
            trend.put("date", rs.getString("date"));
            trend.put("headcount", rs.getInt("headcount"));
            trends.add(trend);
          }
        }
      }
    } catch (SQLException e) {
      System.err.println("현원 추이 조회 중 오류: " + e.getMessage());
      e.printStackTrace();
    }
    
    return trends;
  }
  
  /**
   * 조직별 상세 정보 조회 (드릴다운용)
   */
  public List<HRData> getHRByOrganization(String department, String division) {
    List<HRData> hrList = new ArrayList<>();
    
    try (Connection conn = DBConnect.getConnection()) {
      StringBuilder query = new StringBuilder(
          "SELECT * FROM hr_data WHERE as_of_date = (SELECT MAX(as_of_date) FROM hr_data)");
      
      List<Object> params = new ArrayList<>();
      if (department != null && !department.isEmpty()) {
        query.append(" AND department = ?");
        params.add(department);
      }
      if (division != null && !division.isEmpty()) {
        query.append(" AND division = ?");
        params.add(division);
      }
      query.append(" ORDER BY department, division, job_category");
      
      try (PreparedStatement ps = conn.prepareStatement(query.toString())) {
        for (int i = 0; i < params.size(); i++) {
          ps.setObject(i + 1, params.get(i));
        }
        try (ResultSet rs = ps.executeQuery()) {
          while (rs.next()) {
            hrList.add(mapToHRData(rs));
          }
        }
      }
    } catch (SQLException e) {
      System.err.println("조직별 HR 조회 중 오류: " + e.getMessage());
      e.printStackTrace();
    }
    
    return hrList;
  }
  
  /**
   * 필터 옵션 조회 (본부, 사업부문, 팀, 파트, 라인, 직군 목록)
   */
  public Map<String, List<String>> getFilterOptions() {
    Map<String, List<String>> options = new HashMap<>();
    options.put("departments", new ArrayList<>());
    options.put("businessUnits", new ArrayList<>());
    options.put("teams", new ArrayList<>());
    options.put("parts", new ArrayList<>());
    options.put("lines", new ArrayList<>());
    options.put("jobCategories", new ArrayList<>());
    
    try (Connection conn = DBConnect.getConnection()) {
      // 본부 목록
      String deptQuery = "SELECT DISTINCT department FROM hr_data WHERE department IS NOT NULL ORDER BY department";
      try (PreparedStatement ps = conn.prepareStatement(deptQuery);
           ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
          options.get("departments").add(rs.getString("department"));
        }
      }
      
      // 사업부문 목록
      String buQuery = "SELECT DISTINCT business_unit FROM hr_data WHERE business_unit IS NOT NULL ORDER BY business_unit";
      try (PreparedStatement ps = conn.prepareStatement(buQuery);
           ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
          options.get("businessUnits").add(rs.getString("business_unit"));
        }
      }
      
      // 팀 목록
      String teamQuery = "SELECT DISTINCT team FROM hr_data WHERE team IS NOT NULL ORDER BY team";
      try (PreparedStatement ps = conn.prepareStatement(teamQuery);
           ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
          options.get("teams").add(rs.getString("team"));
        }
      }
      
      // 직군 목록
      String jobQuery = "SELECT DISTINCT job_category FROM hr_data WHERE job_category IS NOT NULL ORDER BY job_category";
      try (PreparedStatement ps = conn.prepareStatement(jobQuery);
           ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
          options.get("jobCategories").add(rs.getString("job_category"));
        }
      }
    } catch (SQLException e) {
      System.err.println("필터 옵션 조회 중 오류: " + e.getMessage());
      e.printStackTrace();
    }
    
    return options;
  }
  
  /**
   * 계층적 필터 옵션 조회
   */
  public List<String> getFilterOptionsByType(String type, String parentValue) {
    List<String> options = new ArrayList<>();
    
    try (Connection conn = DBConnect.getConnection()) {
      String query = "";
      List<Object> params = new ArrayList<>();
      
      if ("businessUnit".equals(type)) {
        query = "SELECT DISTINCT business_unit FROM hr_data WHERE business_unit IS NOT NULL";
        if (parentValue != null && !parentValue.isEmpty() && !"전체".equals(parentValue)) {
          query += " AND department = ?";
          params.add(parentValue);
        }
        query += " ORDER BY business_unit";
      } else if ("team".equals(type)) {
        query = "SELECT DISTINCT team FROM hr_data WHERE team IS NOT NULL";
        if (parentValue != null && !parentValue.isEmpty() && !"전체".equals(parentValue)) {
          query += " AND business_unit = ?";
          params.add(parentValue);
        }
        query += " ORDER BY team";
      } else if ("part".equals(type)) {
        query = "SELECT DISTINCT part FROM hr_data WHERE part IS NOT NULL";
        if (parentValue != null && !parentValue.isEmpty() && !"전체".equals(parentValue)) {
          query += " AND team = ?";
          params.add(parentValue);
        }
        query += " ORDER BY part";
      } else if ("line".equals(type)) {
        query = "SELECT DISTINCT line FROM hr_data WHERE line IS NOT NULL";
        if (parentValue != null && !parentValue.isEmpty() && !"전체".equals(parentValue)) {
          query += " AND part = ?";
          params.add(parentValue);
        }
        query += " ORDER BY line";
      }
      
      if (!query.isEmpty()) {
        try (PreparedStatement ps = conn.prepareStatement(query)) {
          for (int i = 0; i < params.size(); i++) {
            ps.setObject(i + 1, params.get(i));
          }
          try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
              options.add(rs.getString(1));
            }
          }
        }
      }
    } catch (SQLException e) {
      System.err.println("계층적 필터 옵션 조회 중 오류: " + e.getMessage());
      e.printStackTrace();
    }
    
    return options;
  }
  
  /**
   * 직원 검색
   */
  public model.Employee searchEmployee(String searchTerm) {
    try (Connection conn = DBConnect.getConnection()) {
      String query = "SELECT * FROM employees WHERE (employee_id LIKE ? OR name LIKE ?) AND status = 'ACTIVE' LIMIT 1";
      try (PreparedStatement ps = conn.prepareStatement(query)) {
        String searchPattern = "%" + searchTerm + "%";
        ps.setString(1, searchPattern);
        ps.setString(2, searchPattern);
        try (ResultSet rs = ps.executeQuery()) {
          if (rs.next()) {
            return mapToEmployee(rs);
          }
        }
      }
    } catch (SQLException e) {
      System.err.println("직원 검색 중 오류: " + e.getMessage());
      e.printStackTrace();
    }
    return null;
  }
  
  private model.Employee mapToEmployee(ResultSet rs) throws SQLException {
    model.Employee emp = new model.Employee();
    emp.setId(rs.getInt("id"));
    emp.setEmployeeId(rs.getString("employee_id"));
    emp.setName(rs.getString("name"));
    emp.setDepartment(rs.getString("department"));
    emp.setBusinessUnit(rs.getString("business_unit"));
    emp.setTeam(rs.getString("team"));
    emp.setPart(rs.getString("part"));
    emp.setLine(rs.getString("line"));
    emp.setJobCategory(rs.getString("job_category"));
    emp.setPosition(rs.getString("position"));
    emp.setLocation(rs.getString("location"));
    emp.setPerformanceGrade(rs.getString("performance_grade"));
    emp.setSalaryGrade(rs.getString("salary_grade"));
    emp.setSalary(rs.getBigDecimal("salary"));
    emp.setJoinDate(rs.getTimestamp("join_date"));
    emp.setStatus(rs.getString("status"));
    emp.setCreatedAt(rs.getTimestamp("created_at"));
    emp.setUpdatedAt(rs.getTimestamp("updated_at"));
    return emp;
  }
  
  private HRData mapToHRData(ResultSet rs) throws SQLException {
    HRData hr = new HRData();
    hr.setId(rs.getInt("id"));
    hr.setDepartment(rs.getString("department"));
    hr.setDivision(rs.getString("division"));
    hr.setJobCategory(rs.getString("job_category"));
    hr.setQuota(rs.getInt("quota"));
    hr.setCurrentHeadcount(rs.getInt("current_headcount"));
    hr.setNewHires(rs.getInt("new_hires"));
    hr.setResignations(rs.getInt("resignations"));
    hr.setTransfers(rs.getInt("transfers"));
    hr.setVacancies(rs.getInt("vacancies"));
    hr.setOnLeave(rs.getInt("on_leave"));
    hr.setReturned(rs.getInt("returned"));
    hr.setLaborCost(rs.getBigDecimal("labor_cost"));
    hr.setAsOfDate(rs.getTimestamp("as_of_date"));
    hr.setDataQuality(rs.getString("data_quality"));
    hr.setCreatedAt(rs.getTimestamp("created_at"));
    hr.setUpdatedAt(rs.getTimestamp("updated_at"));
    return hr;
  }
}

