package model;

import java.math.BigDecimal;

public class AIModel {
  private int id;
  private Integer providerId;
  private Integer categoryId;
  private String modelName;
  private String price;
  private java.math.BigDecimal priceUsd;
  private Integer priceKrw;
  private String description;
  private String purposeSummary;
  private String inputModalities;
  private String outputModalities;
  private String languages;
  private String benchmarks;
  private BigDecimal paramsBillion;
  private Integer latencyMs;
  private Integer rateLimitPerMin;
  private boolean apiAvailable;
  private boolean finetuneAvailable;
  private boolean onpremAvailable;
  private String hostingOptions;
  private String licenseType;
  private boolean commercialUseAllowed;
  private String dataRetention;
  private String privacyUrl;
  private String tosUrl;
  private String homepageUrl;
  private String docsUrl;
  private String playgroundUrl;
  private BigDecimal maxInputSizeMb;
  private String supportedFileTypes;
  private String createdAt;
  
  // 조인된 정보
  private String providerName;
  private String categoryName;

  public AIModel() {}

  public int getId() {
    return id;
  }

  public void setId(int id) {
    this.id = id;
  }

  public Integer getProviderId() {
    return providerId;
  }

  public void setProviderId(Integer providerId) {
    this.providerId = providerId;
  }

  public Integer getCategoryId() {
    return categoryId;
  }

  public void setCategoryId(Integer categoryId) {
    this.categoryId = categoryId;
  }

  public String getModelName() {
    return modelName;
  }

  public void setModelName(String modelName) {
    this.modelName = modelName;
  }

  public String getPrice() {
    return price;
  }

  public void setPrice(String price) {
    this.price = price;
  }

  public java.math.BigDecimal getPriceUsd() {
    return priceUsd;
  }

  public void setPriceUsd(java.math.BigDecimal priceUsd) {
    this.priceUsd = priceUsd;
  }

  public Integer getPriceKrw() {
    return priceKrw;
  }

  public void setPriceKrw(Integer priceKrw) {
    this.priceKrw = priceKrw;
  }

  public String getDescription() {
    return description;
  }

  public void setDescription(String description) {
    this.description = description;
  }

  public String getPurposeSummary() {
    return purposeSummary;
  }

  public void setPurposeSummary(String purposeSummary) {
    this.purposeSummary = purposeSummary;
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

  public String getLanguages() {
    return languages;
  }

  public void setLanguages(String languages) {
    this.languages = languages;
  }

  public String getBenchmarks() {
    return benchmarks;
  }

  public void setBenchmarks(String benchmarks) {
    this.benchmarks = benchmarks;
  }

  public BigDecimal getParamsBillion() {
    return paramsBillion;
  }

  public void setParamsBillion(BigDecimal paramsBillion) {
    this.paramsBillion = paramsBillion;
  }

  public Integer getLatencyMs() {
    return latencyMs;
  }

  public void setLatencyMs(Integer latencyMs) {
    this.latencyMs = latencyMs;
  }

  public Integer getRateLimitPerMin() {
    return rateLimitPerMin;
  }

  public void setRateLimitPerMin(Integer rateLimitPerMin) {
    this.rateLimitPerMin = rateLimitPerMin;
  }

  public boolean isApiAvailable() {
    return apiAvailable;
  }

  public void setApiAvailable(boolean apiAvailable) {
    this.apiAvailable = apiAvailable;
  }

  public boolean isFinetuneAvailable() {
    return finetuneAvailable;
  }

  public void setFinetuneAvailable(boolean finetuneAvailable) {
    this.finetuneAvailable = finetuneAvailable;
  }

  public boolean isOnpremAvailable() {
    return onpremAvailable;
  }

  public void setOnpremAvailable(boolean onpremAvailable) {
    this.onpremAvailable = onpremAvailable;
  }

  public String getHostingOptions() {
    return hostingOptions;
  }

  public void setHostingOptions(String hostingOptions) {
    this.hostingOptions = hostingOptions;
  }

  public String getLicenseType() {
    return licenseType;
  }

  public void setLicenseType(String licenseType) {
    this.licenseType = licenseType;
  }

  public boolean isCommercialUseAllowed() {
    return commercialUseAllowed;
  }

  public void setCommercialUseAllowed(boolean commercialUseAllowed) {
    this.commercialUseAllowed = commercialUseAllowed;
  }

  public String getDataRetention() {
    return dataRetention;
  }

  public void setDataRetention(String dataRetention) {
    this.dataRetention = dataRetention;
  }

  public String getPrivacyUrl() {
    return privacyUrl;
  }

  public void setPrivacyUrl(String privacyUrl) {
    this.privacyUrl = privacyUrl;
  }

  public String getTosUrl() {
    return tosUrl;
  }

  public void setTosUrl(String tosUrl) {
    this.tosUrl = tosUrl;
  }

  public String getHomepageUrl() {
    return homepageUrl;
  }

  public void setHomepageUrl(String homepageUrl) {
    this.homepageUrl = homepageUrl;
  }

  public String getDocsUrl() {
    return docsUrl;
  }

  public void setDocsUrl(String docsUrl) {
    this.docsUrl = docsUrl;
  }

  public String getPlaygroundUrl() {
    return playgroundUrl;
  }

  public void setPlaygroundUrl(String playgroundUrl) {
    this.playgroundUrl = playgroundUrl;
  }

  public BigDecimal getMaxInputSizeMb() {
    return maxInputSizeMb;
  }

  public void setMaxInputSizeMb(BigDecimal maxInputSizeMb) {
    this.maxInputSizeMb = maxInputSizeMb;
  }

  public String getSupportedFileTypes() {
    return supportedFileTypes;
  }

  public void setSupportedFileTypes(String supportedFileTypes) {
    this.supportedFileTypes = supportedFileTypes;
  }

  public String getCreatedAt() {
    return createdAt;
  }

  public void setCreatedAt(String createdAt) {
    this.createdAt = createdAt;
  }

  public String getProviderName() {
    return providerName;
  }

  public void setProviderName(String providerName) {
    this.providerName = providerName;
  }

  public String getCategoryName() {
    return categoryName;
  }

  public void setCategoryName(String categoryName) {
    this.categoryName = categoryName;
  }
}

