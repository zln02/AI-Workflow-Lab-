package model;

import java.math.BigDecimal;

public class Plan {
  private int id;
  private String code;
  private String name;
  private int durationMonths;
  private BigDecimal priceUsd;
  private String description;
  private String features; // JSON string

  public Plan() {}

  public int getId() {
    return id;
  }

  public void setId(int id) {
    this.id = id;
  }

  public String getCode() {
    return code;
  }

  public void setCode(String code) {
    this.code = code;
  }

  public String getName() {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }

  public int getDurationMonths() {
    return durationMonths;
  }

  public void setDurationMonths(int durationMonths) {
    this.durationMonths = durationMonths;
  }

  public BigDecimal getPriceUsd() {
    return priceUsd;
  }

  public void setPriceUsd(BigDecimal priceUsd) {
    this.priceUsd = priceUsd;
  }

  public String getDescription() {
    return description;
  }

  public void setDescription(String description) {
    this.description = description;
  }

  public String getFeatures() {
    return features;
  }

  public void setFeatures(String features) {
    this.features = features;
  }
}



