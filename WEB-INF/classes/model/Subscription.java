package model;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

public class Subscription {
  private long id;
  private long userId;
  private String planCode;
  private LocalDate startDate;
  private LocalDate endDate;
  private String status; // ACTIVE, EXPIRED, CANCELLED
  private String paymentMethod;
  private String transactionId;
  private String createdAt;
  private String updatedAt;

  public Subscription() {}

  public long getId() {
    return id;
  }

  public void setId(long id) {
    this.id = id;
  }

  public long getUserId() {
    return userId;
  }

  public void setUserId(long userId) {
    this.userId = userId;
  }

  public String getPlanCode() {
    return planCode;
  }

  public void setPlanCode(String planCode) {
    this.planCode = planCode;
  }

  public LocalDate getStartDate() {
    return startDate;
  }

  public void setStartDate(LocalDate startDate) {
    this.startDate = startDate;
  }

  public void setStartDate(String startDate) {
    if (startDate != null && !startDate.isEmpty()) {
      this.startDate = LocalDate.parse(startDate);
    }
  }

  public LocalDate getEndDate() {
    return endDate;
  }

  public void setEndDate(LocalDate endDate) {
    this.endDate = endDate;
  }

  public void setEndDate(String endDate) {
    if (endDate != null && !endDate.isEmpty()) {
      this.endDate = LocalDate.parse(endDate);
    }
  }

  public String getStatus() {
    return status;
  }

  public void setStatus(String status) {
    this.status = status;
  }

  public String getPaymentMethod() {
    return paymentMethod;
  }

  public void setPaymentMethod(String paymentMethod) {
    this.paymentMethod = paymentMethod;
  }

  public String getTransactionId() {
    return transactionId;
  }

  public void setTransactionId(String transactionId) {
    this.transactionId = transactionId;
  }

  public String getCreatedAt() {
    return createdAt;
  }

  public void setCreatedAt(String createdAt) {
    this.createdAt = createdAt;
  }

  public String getUpdatedAt() {
    return updatedAt;
  }

  public void setUpdatedAt(String updatedAt) {
    this.updatedAt = updatedAt;
  }

  /**
   * 구독이 현재 활성화되어 있는지 확인
   * @return 활성화 여부
   */
  public boolean isActiveNow() {
    if (status == null || !status.equals("ACTIVE")) {
      return false;
    }
    LocalDate today = LocalDate.now();
    return !today.isBefore(startDate) && !today.isAfter(endDate);
  }

  /**
   * 구독 기간이 남았는지 확인
   * @return 남은 일수 (음수면 만료)
   */
  public long getDaysRemaining() {
    if (endDate == null) {
      return 0;
    }
    return java.time.temporal.ChronoUnit.DAYS.between(LocalDate.now(), endDate);
  }
}



