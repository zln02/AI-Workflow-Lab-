package model;

import java.math.BigDecimal;
import java.sql.Timestamp;

/**
 * 개인 인사 정보 모델
 */
public class Employee {
  private int id;
  private String employeeId; // 사번
  private String name; // 이름
  private String department; // 본부
  private String businessUnit; // 사업부문
  private String team; // 팀
  private String part; // 파트
  private String line; // 라인(조)
  private String jobCategory; // 직군
  private String position; // 직급
  private String location; // 연고지
  private String performanceGrade; // 고과
  private String salaryGrade; // 연봉 등급
  private BigDecimal salary; // 연봉
  private Timestamp joinDate; // 입사일
  private String status; // 상태 (ACTIVE, ON_LEAVE, RESIGNED)
  private Timestamp createdAt;
  private Timestamp updatedAt;

  // Getters and Setters
  public int getId() { return id; }
  public void setId(int id) { this.id = id; }

  public String getEmployeeId() { return employeeId; }
  public void setEmployeeId(String employeeId) { this.employeeId = employeeId; }

  public String getName() { return name; }
  public void setName(String name) { this.name = name; }

  public String getDepartment() { return department; }
  public void setDepartment(String department) { this.department = department; }

  public String getBusinessUnit() { return businessUnit; }
  public void setBusinessUnit(String businessUnit) { this.businessUnit = businessUnit; }

  public String getTeam() { return team; }
  public void setTeam(String team) { this.team = team; }

  public String getPart() { return part; }
  public void setPart(String part) { this.part = part; }

  public String getLine() { return line; }
  public void setLine(String line) { this.line = line; }

  public String getJobCategory() { return jobCategory; }
  public void setJobCategory(String jobCategory) { this.jobCategory = jobCategory; }

  public String getPosition() { return position; }
  public void setPosition(String position) { this.position = position; }

  public String getLocation() { return location; }
  public void setLocation(String location) { this.location = location; }

  public String getPerformanceGrade() { return performanceGrade; }
  public void setPerformanceGrade(String performanceGrade) { this.performanceGrade = performanceGrade; }

  public String getSalaryGrade() { return salaryGrade; }
  public void setSalaryGrade(String salaryGrade) { this.salaryGrade = salaryGrade; }

  public BigDecimal getSalary() { return salary; }
  public void setSalary(BigDecimal salary) { this.salary = salary; }

  public Timestamp getJoinDate() { return joinDate; }
  public void setJoinDate(Timestamp joinDate) { this.joinDate = joinDate; }

  public String getStatus() { return status; }
  public void setStatus(String status) { this.status = status; }

  public Timestamp getCreatedAt() { return createdAt; }
  public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

  public Timestamp getUpdatedAt() { return updatedAt; }
  public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}


