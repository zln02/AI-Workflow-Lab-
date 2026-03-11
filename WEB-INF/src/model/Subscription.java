package model;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

public class Subscription {
    private long id;
    private long userId;
    private Integer planId;
    private String planCode;
    private LocalDate startDate;
    private LocalDate endDate;
    private String status;
    private String paymentMethod;
    private String transactionId;
    private String billingCycle;
    private LocalDate nextBillingDate;
    private boolean cancelAtPeriodEnd;
    private String portoneCustomerUid;
    private Integer lastPaymentId;

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

    public Integer getPlanId() {
        return planId;
    }

    public void setPlanId(Integer planId) {
        this.planId = planId;
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

    public LocalDate getEndDate() {
        return endDate;
    }

    public void setEndDate(LocalDate endDate) {
        this.endDate = endDate;
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

    public String getBillingCycle() {
        return billingCycle;
    }

    public void setBillingCycle(String billingCycle) {
        this.billingCycle = billingCycle;
    }

    public LocalDate getNextBillingDate() {
        return nextBillingDate;
    }

    public void setNextBillingDate(LocalDate nextBillingDate) {
        this.nextBillingDate = nextBillingDate;
    }

    public boolean isCancelAtPeriodEnd() {
        return cancelAtPeriodEnd;
    }

    public void setCancelAtPeriodEnd(boolean cancelAtPeriodEnd) {
        this.cancelAtPeriodEnd = cancelAtPeriodEnd;
    }

    public String getPortoneCustomerUid() {
        return portoneCustomerUid;
    }

    public void setPortoneCustomerUid(String portoneCustomerUid) {
        this.portoneCustomerUid = portoneCustomerUid;
    }

    public Integer getLastPaymentId() {
        return lastPaymentId;
    }

    public void setLastPaymentId(Integer lastPaymentId) {
        this.lastPaymentId = lastPaymentId;
    }

    public boolean isActiveNow() {
        return "ACTIVE".equalsIgnoreCase(status)
                && endDate != null
                && !endDate.isBefore(LocalDate.now());
    }

    public long getDaysRemaining() {
        if (endDate == null) {
            return 0;
        }
        long days = ChronoUnit.DAYS.between(LocalDate.now(), endDate);
        return Math.max(0, days);
    }
}
