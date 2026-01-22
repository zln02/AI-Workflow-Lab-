package model;

import java.math.BigDecimal;
import java.util.List;

public class Package {
  private int id;
  private String title;
  private String description;
  private BigDecimal price;
  private BigDecimal discountPrice;
  private Integer categoryId;
  private boolean active;
  private String createdAt;
  private String updatedAt;
  private List<PackageItem> items; // 패키지 구성 아이템들
  private List<Category> categories; // 패키지 카테고리 목록 (다중)

  public Package() {}

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

  public Integer getCategoryId() {
    return categoryId;
  }

  public void setCategoryId(Integer categoryId) {
    this.categoryId = categoryId;
  }

  public boolean isActive() {
    return active;
  }

  public void setActive(boolean active) {
    this.active = active;
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

  public List<PackageItem> getItems() {
    return items;
  }

  public void setItems(List<PackageItem> items) {
    this.items = items;
  }

  public BigDecimal getFinalPrice() {
    return discountPrice != null && discountPrice.compareTo(BigDecimal.ZERO) > 0 
        ? discountPrice 
        : price;
  }

  public List<Category> getCategories() {
    return categories;
  }

  public void setCategories(List<Category> categories) {
    this.categories = categories;
  }
}

