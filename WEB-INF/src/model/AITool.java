package model;

import java.sql.Timestamp;
import java.util.List;

/**
 * AI 도구 정보를 담는 모델 클래스
 * AI Workflow Lab 플랫폼의 핵심 도구 정보
 */
public class AITool {
    private int id;
    private String toolName;
    private String providerName;
    private String category;
    private String subcategory;
    private String description;
    private String purposeSummary;
    private List<String> useCases;
    private List<String> features;
    private String pricingModel;
    private String pricingDetails;
    private boolean apiAvailable;
    private boolean freeTierAvailable;
    private String websiteUrl;
    private String docsUrl;
    private String playgroundUrl;
    private List<String> supportedLanguages;
    private String inputModalities;
    private String outputModalities;
    private Double maxFileSizeMb;
    private Integer rateLimitPerMin;
    private boolean commercialUseAllowed;
    private boolean onpremAvailable;
    private String licenseType;
    private String difficultyLevel;
    private List<String> tags;
    private Double rating;
    private Integer reviewCount;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    
    // 생성자
    public AITool() {}
    
    public AITool(int id, String toolName, String providerName, String category) {
        this.id = id;
        this.toolName = toolName;
        this.providerName = providerName;
        this.category = category;
    }
    
    // Getters and Setters
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public String getToolName() {
        return toolName;
    }
    
    public void setToolName(String toolName) {
        this.toolName = toolName;
    }
    
    public String getProviderName() {
        return providerName;
    }
    
    public void setProviderName(String providerName) {
        this.providerName = providerName;
    }
    
    public String getCategory() {
        return category;
    }
    
    public void setCategory(String category) {
        this.category = category;
    }
    
    public String getSubcategory() {
        return subcategory;
    }
    
    public void setSubcategory(String subcategory) {
        this.subcategory = subcategory;
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
    
    public List<String> getUseCases() {
        return useCases;
    }
    
    public void setUseCases(List<String> useCases) {
        this.useCases = useCases;
    }
    
    public List<String> getFeatures() {
        return features;
    }
    
    public void setFeatures(List<String> features) {
        this.features = features;
    }
    
    public String getPricingModel() {
        return pricingModel;
    }
    
    public void setPricingModel(String pricingModel) {
        this.pricingModel = pricingModel;
    }
    
    public String getPricingDetails() {
        return pricingDetails;
    }
    
    public void setPricingDetails(String pricingDetails) {
        this.pricingDetails = pricingDetails;
    }
    
    public boolean isApiAvailable() {
        return apiAvailable;
    }
    
    public void setApiAvailable(boolean apiAvailable) {
        this.apiAvailable = apiAvailable;
    }
    
    public boolean isFreeTierAvailable() {
        return freeTierAvailable;
    }
    
    public void setFreeTierAvailable(boolean freeTierAvailable) {
        this.freeTierAvailable = freeTierAvailable;
    }
    
    public String getWebsiteUrl() {
        return websiteUrl;
    }
    
    public void setWebsiteUrl(String websiteUrl) {
        this.websiteUrl = websiteUrl;
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
    
    public List<String> getSupportedLanguages() {
        return supportedLanguages;
    }
    
    public void setSupportedLanguages(List<String> supportedLanguages) {
        this.supportedLanguages = supportedLanguages;
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
    
    public Double getMaxFileSizeMb() {
        return maxFileSizeMb;
    }
    
    public void setMaxFileSizeMb(Double maxFileSizeMb) {
        this.maxFileSizeMb = maxFileSizeMb;
    }
    
    public Integer getRateLimitPerMin() {
        return rateLimitPerMin;
    }
    
    public void setRateLimitPerMin(Integer rateLimitPerMin) {
        this.rateLimitPerMin = rateLimitPerMin;
    }
    
    public boolean isCommercialUseAllowed() {
        return commercialUseAllowed;
    }
    
    public void setCommercialUseAllowed(boolean commercialUseAllowed) {
        this.commercialUseAllowed = commercialUseAllowed;
    }
    
    public boolean isOnpremAvailable() {
        return onpremAvailable;
    }
    
    public void setOnpremAvailable(boolean onpremAvailable) {
        this.onpremAvailable = onpremAvailable;
    }
    
    public String getLicenseType() {
        return licenseType;
    }
    
    public void setLicenseType(String licenseType) {
        this.licenseType = licenseType;
    }
    
    public String getDifficultyLevel() {
        return difficultyLevel;
    }
    
    public void setDifficultyLevel(String difficultyLevel) {
        this.difficultyLevel = difficultyLevel;
    }
    
    public List<String> getTags() {
        return tags;
    }
    
    public void setTags(List<String> tags) {
        this.tags = tags;
    }
    
    public Double getRating() {
        return rating;
    }
    
    public void setRating(Double rating) {
        this.rating = rating;
    }
    
    public Integer getReviewCount() {
        return reviewCount;
    }
    
    public void setReviewCount(Integer reviewCount) {
        this.reviewCount = reviewCount;
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
    
    /**
     * 난이도에 따른 CSS 클래스 반환
     */
    public String getDifficultyBadgeClass() {
        if ("Beginner".equals(difficultyLevel)) {
            return "badge-success";
        } else if ("Intermediate".equals(difficultyLevel)) {
            return "badge-warning";
        } else if ("Advanced".equals(difficultyLevel)) {
            return "badge-danger";
        }
        return "badge-secondary";
    }
    
    /**
     * 평점을 별점으로 변환
     */
    public String getStarRating() {
        if (rating == null) return "☆☆☆☆☆";
        
        StringBuilder stars = new StringBuilder();
        int fullStars = (int) Math.floor(rating);
        
        for (int i = 0; i < fullStars; i++) {
            stars.append("★");
        }
        for (int i = fullStars; i < 5; i++) {
            stars.append("☆");
        }
        
        return stars.toString();
    }
    
    /**
     * 무료 티어 여부에 따른 가격 표시
     */
    public String getPricingDisplay() {
        if (freeTierAvailable) {
            return "무료 플랜 있음";
        }
        return pricingModel != null ? pricingModel : "유료";
    }
    
    @Override
    public String toString() {
        return "AITool{" +
                "id=" + id +
                ", toolName='" + toolName + '\'' +
                ", providerName='" + providerName + '\'' +
                ", category='" + category + '\'' +
                ", rating=" + rating +
                '}';
    }
}
