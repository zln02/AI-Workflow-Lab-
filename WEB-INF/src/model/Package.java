package model;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.List;

public class Package {
    private int id;
    private String title;
    private String description;
    private BigDecimal price;
    private BigDecimal discountPrice;
    private boolean isActive;
    private boolean isFeatured;
    private int displayOrder;
    private List<Integer> modelIds;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    
    // 기본 생성자
    public Package() {}
    
    // Getters and Setters
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public String getTitle() {
        return title;
    }
    
    public void setTitle(String title) {
        this.title = title;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public BigDecimal getPrice() {
        return price;
    }
    
    public void setPrice(BigDecimal price) {
        this.price = price;
    }
    
    public BigDecimal getDiscountPrice() {
        return discountPrice;
    }
    
    public void setDiscountPrice(BigDecimal discountPrice) {
        this.discountPrice = discountPrice;
    }
    
    public boolean getIsActive() {
        return isActive;
    }
    
    public void setIsActive(boolean isActive) {
        this.isActive = isActive;
    }
    
    public boolean getIsFeatured() {
        return isFeatured;
    }
    
    public void setIsFeatured(boolean isFeatured) {
        this.isFeatured = isFeatured;
    }
    
    public int getDisplayOrder() {
        return displayOrder;
    }
    
    public void setDisplayOrder(int displayOrder) {
        this.displayOrder = displayOrder;
    }
    
    public List<Integer> getModelIds() {
        return modelIds;
    }
    
    public void setModelIds(List<Integer> modelIds) {
        this.modelIds = modelIds;
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
    public boolean hasDiscount() {
        return discountPrice != null && discountPrice.compareTo(BigDecimal.ZERO) > 0 && 
               discountPrice.compareTo(price) < 0;
    }
    
    public BigDecimal getCurrentPrice() {
        return hasDiscount() ? discountPrice : price;
    }
    
    public String getFormattedPrice() {
        if (price == null) return "0";
        return String.format("%,.0f", price);
    }
    
    public String getFormattedDiscountPrice() {
        if (discountPrice == null) return "";
        return String.format("%,.0f", discountPrice);
    }
    
    public String getFormattedCurrentPrice() {
        return String.format("%,.0f", getCurrentPrice());
    }
    
    public int getDiscountPercentage() {
        if (!hasDiscount()) return 0;
        return price.subtract(discountPrice)
                .multiply(BigDecimal.valueOf(100))
                .divide(price, 0, java.math.RoundingMode.HALF_UP)
                .intValue();
    }
    
    public int getModelCount() {
        return modelIds != null ? modelIds.size() : 0;
    }
}
