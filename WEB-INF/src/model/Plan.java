package model;

import java.math.BigDecimal;

public class Plan {
    private int id;
    private String planCode;
    private String name;
    private String nameKo;
    private String planType;
    private String billingCycle;
    private BigDecimal priceUsd;
    private BigDecimal priceYearly;
    private String currency;
    private int creditsMonthly;
    private Integer maxApiCallsDaily;
    private Integer maxProjects;
    private String featuresJson;
    private boolean popular;
    private boolean active;
    private int displayOrder;
    private int durationMonths;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getPlanCode() {
        return planCode;
    }

    public void setPlanCode(String planCode) {
        this.planCode = planCode;
    }

    public String getName() {
        return name != null ? name : nameKo;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getNameKo() {
        return nameKo;
    }

    public void setNameKo(String nameKo) {
        this.nameKo = nameKo;
    }

    public String getPlanType() {
        return planType;
    }

    public void setPlanType(String planType) {
        this.planType = planType;
    }

    public String getBillingCycle() {
        return billingCycle;
    }

    public void setBillingCycle(String billingCycle) {
        this.billingCycle = billingCycle;
    }

    public BigDecimal getPriceUsd() {
        return priceUsd != null ? priceUsd : BigDecimal.ZERO;
    }

    public void setPriceUsd(BigDecimal priceUsd) {
        this.priceUsd = priceUsd;
    }

    public BigDecimal getPriceYearly() {
        return priceYearly;
    }

    public void setPriceYearly(BigDecimal priceYearly) {
        this.priceYearly = priceYearly;
    }

    public String getCurrency() {
        return currency;
    }

    public void setCurrency(String currency) {
        this.currency = currency;
    }

    public int getCreditsMonthly() {
        return creditsMonthly;
    }

    public void setCreditsMonthly(int creditsMonthly) {
        this.creditsMonthly = creditsMonthly;
    }

    public Integer getMaxApiCallsDaily() {
        return maxApiCallsDaily;
    }

    public void setMaxApiCallsDaily(Integer maxApiCallsDaily) {
        this.maxApiCallsDaily = maxApiCallsDaily;
    }

    public Integer getMaxProjects() {
        return maxProjects;
    }

    public void setMaxProjects(Integer maxProjects) {
        this.maxProjects = maxProjects;
    }

    public String getFeaturesJson() {
        return featuresJson;
    }

    public void setFeaturesJson(String featuresJson) {
        this.featuresJson = featuresJson;
    }

    public boolean isPopular() {
        return popular;
    }

    public void setPopular(boolean popular) {
        this.popular = popular;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public int getDisplayOrder() {
        return displayOrder;
    }

    public void setDisplayOrder(int displayOrder) {
        this.displayOrder = displayOrder;
    }

    public int getDurationMonths() {
        return durationMonths;
    }

    public void setDurationMonths(int durationMonths) {
        this.durationMonths = durationMonths;
    }
}
