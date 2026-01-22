package model;

import java.sql.Timestamp;

/**
 * 휴직/복직 정보 모델
 */
public class LeaveInfo {
  private int id;
  private int employeeId;
  private String employeeName;
  private String leaveType; // 휴직 유형 (출산, 육아, 병가, 기타)
  private Timestamp leaveStartDate; // 휴직 시작일
  private Timestamp expectedReturnDate; // 예상 복직일
  private Timestamp actualReturnDate; // 실제 복직일
  private int remainingDays; // 잔여 휴직일
  private String position; // 직급
  private String location; // 연고지
  private String salaryGrade; // 연봉 등급
  private String status; // 상태 (ON_LEAVE, RETURNED)
  private Timestamp createdAt;
  private Timestamp updatedAt;

  // Getters and Setters
  public int getId() { return id; }
  public void setId(int id) { this.id = id; }

  public int getEmployeeId() { return employeeId; }
  public void setEmployeeId(int employeeId) { this.employeeId = employeeId; }

  public String getEmployeeName() { return employeeName; }
  public void setEmployeeName(String employeeName) { this.employeeName = employeeName; }

  public String getLeaveType() { return leaveType; }
  public void setLeaveType(String leaveType) { this.leaveType = leaveType; }

  public Timestamp getLeaveStartDate() { return leaveStartDate; }
  public void setLeaveStartDate(Timestamp leaveStartDate) { this.leaveStartDate = leaveStartDate; }

  public Timestamp getExpectedReturnDate() { return expectedReturnDate; }
  public void setExpectedReturnDate(Timestamp expectedReturnDate) { this.expectedReturnDate = expectedReturnDate; }

  public Timestamp getActualReturnDate() { return actualReturnDate; }
  public void setActualReturnDate(Timestamp actualReturnDate) { this.actualReturnDate = actualReturnDate; }

  public int getRemainingDays() { return remainingDays; }
  public void setRemainingDays(int remainingDays) { this.remainingDays = remainingDays; }

  public String getPosition() { return position; }
  public void setPosition(String position) { this.position = position; }

  public String getLocation() { return location; }
  public void setLocation(String location) { this.location = location; }

  public String getSalaryGrade() { return salaryGrade; }
  public void setSalaryGrade(String salaryGrade) { this.salaryGrade = salaryGrade; }

  public String getStatus() { return status; }
  public void setStatus(String status) { this.status = status; }

  public Timestamp getCreatedAt() { return createdAt; }
  public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

  public Timestamp getUpdatedAt() { return updatedAt; }
  public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}


