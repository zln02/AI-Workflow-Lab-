package model;

import java.math.BigDecimal;
import java.sql.Timestamp;

/**
 * HR 현황 데이터 모델
 */
public class HRData {
  private int id;
  private String department; // 본부/사업부
  private String division; // 조직
  private String jobCategory; // 직군
  private int quota; // 정원
  private int currentHeadcount; // 현원
  private int newHires; // 입사
  private int resignations; // 퇴사
  private int transfers; // 이동
  private int vacancies; // 공석
  private int onLeave; // 휴직
  private int returned; // 복귀
  private BigDecimal laborCost; // 인력비용
  private Timestamp asOfDate; // 기준일시
  private String dataQuality; // 데이터 품질 (NORMAL, WARNING)
  private Timestamp createdAt;
  private Timestamp updatedAt;

  // Getters and Setters
  public int getId() {
    return id;
  }

  public void setId(int id) {
    this.id = id;
  }

  public String getDepartment() {
    return department;
  }

  public void setDepartment(String department) {
    this.department = department;
  }

  public String getDivision() {
    return division;
  }

  public void setDivision(String division) {
    this.division = division;
  }

  public String getJobCategory() {
    return jobCategory;
  }

  public void setJobCategory(String jobCategory) {
    this.jobCategory = jobCategory;
  }

  public int getQuota() {
    return quota;
  }

  public void setQuota(int quota) {
    this.quota = quota;
  }

  public int getCurrentHeadcount() {
    return currentHeadcount;
  }

  public void setCurrentHeadcount(int currentHeadcount) {
    this.currentHeadcount = currentHeadcount;
  }

  public int getNewHires() {
    return newHires;
  }

  public void setNewHires(int newHires) {
    this.newHires = newHires;
  }

  public int getResignations() {
    return resignations;
  }

  public void setResignations(int resignations) {
    this.resignations = resignations;
  }

  public int getTransfers() {
    return transfers;
  }

  public void setTransfers(int transfers) {
    this.transfers = transfers;
  }

  public int getVacancies() {
    return vacancies;
  }

  public void setVacancies(int vacancies) {
    this.vacancies = vacancies;
  }

  public int getOnLeave() {
    return onLeave;
  }

  public void setOnLeave(int onLeave) {
    this.onLeave = onLeave;
  }

  public int getReturned() {
    return returned;
  }

  public void setReturned(int returned) {
    this.returned = returned;
  }

  public BigDecimal getLaborCost() {
    return laborCost;
  }

  public void setLaborCost(BigDecimal laborCost) {
    this.laborCost = laborCost;
  }

  public Timestamp getAsOfDate() {
    return asOfDate;
  }

  public void setAsOfDate(Timestamp asOfDate) {
    this.asOfDate = asOfDate;
  }

  public String getDataQuality() {
    return dataQuality;
  }

  public void setDataQuality(String dataQuality) {
    this.dataQuality = dataQuality;
  }

  public Timestamp getCreatedAt() {
    return createdAt;
  }

  public void setCreatedAt(Timestamp createdAt) {
    this.createdAt = createdAt;
  }

  public Timestamp getUpdatedAt() {
    return updatedAt;
  }

  public void setUpdatedAt(Timestamp updatedAt) {
    this.updatedAt = updatedAt;
  }
}


