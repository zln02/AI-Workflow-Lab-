package model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class AIModel {
    private int id;
    private String modelName;
    private String providerName;
    private String purposeSummary;
    private String description;
    private String price;
    private String paramsBillion;
    private int latencyMs;
    private String inputModalities;
    private String outputModalities;
    private int categoryId;
    private String categoryName;
    private boolean isActive;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    
    // 기본 생성자
    public AIModel() {}
    
    // Getters and Setters
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public String getModelName() {
        return modelName;
    }
    
    public void setModelName(String modelName) {
        this.modelName = modelName;
    }
    
    public String getProviderName() {
        return providerName;
    }
    
    public void setProviderName(String providerName) {
        this.providerName = providerName;
    }
    
    public String getPurposeSummary() {
        return purposeSummary;
    }
    
    public void setPurposeSummary(String purposeSummary) {
        this.purposeSummary = purposeSummary;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public String getPrice() {
        return price;
    }
    
    public void setPrice(String price) {
        this.price = price;
    }
    
    public String getParamsBillion() {
        return paramsBillion;
    }
    
    public void setParamsBillion(String paramsBillion) {
        this.paramsBillion = paramsBillion;
    }
    
    public int getLatencyMs() {
        return latencyMs;
    }
    
    public void setLatencyMs(int latencyMs) {
        this.latencyMs = latencyMs;
    }
    
    public String getInputModalities() {
        return inputModalities;
    }
    
    public void setInputModalities(String inputModalities) {
        this.inputModalities = inputModalities;
    }
    
    public String getOutputModalities() {
        return outputModalities;
    }
    
    public void setOutputModalities(String outputModalities) {
        this.outputModalities = outputModalities;
    }
    
    public int getCategoryId() {
        return categoryId;
    }
    
    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }
    
    public String getCategoryName() {
        return categoryName;
    }
    
    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }
    
    public boolean getIsActive() {
        return isActive;
    }
    
    public void setIsActive(boolean isActive) {
        this.isActive = isActive;
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
    
    // 유틸리티 메서드
    public boolean isFree() {
        return "0".equals(price) || price == null || price.trim().isEmpty();
    }
    
    public String getFormattedPrice() {
        if (isFree()) {
            return "무료";
        }
        return price;
    }
    
    public String getDisplayParams() {
        if (paramsBillion == null || paramsBillion.trim().isEmpty()) {
            return "-";
        }
        return paramsBillion + "B";
    }
    
    public String getDisplayLatency() {
        if (latencyMs <= 0) {
            return "-";
        }
        return latencyMs + "ms";
    }
}
