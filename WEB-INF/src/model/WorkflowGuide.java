package model;

import java.sql.Timestamp;
import java.util.List;

/**
 * 워크플로우 가이드 정보를 담는 모델 클래스
 * AI 도구 사용법을 단계별로 안내
 */
public class WorkflowGuide {
    private int id;
    private String title;
    private String description;
    private String category;
    private String difficultyLevel;
    private Integer estimatedDurationMinutes;
    private List<String> prerequisites;
    private List<String> learningObjectives;
    private List<String> steps;
    private List<String> toolsRequired;
    private List<String> samplePrompts;
    private String tipsTricks;
    private List<String> commonMistakes;
    private String createdBy;
    private Integer viewCount;
    private Integer likeCount;
    private boolean isPublished;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    
    // 생성자
    public WorkflowGuide() {}
    
    public WorkflowGuide(int id, String title, String category, String difficultyLevel) {
        this.id = id;
        this.title = title;
        this.category = category;
        this.difficultyLevel = difficultyLevel;
    }
    
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
    
    public String getCategory() {
        return category;
    }
    
    public void setCategory(String category) {
        this.category = category;
    }
    
    public String getDifficultyLevel() {
        return difficultyLevel;
    }
    
    public void setDifficultyLevel(String difficultyLevel) {
        this.difficultyLevel = difficultyLevel;
    }
    
    public Integer getEstimatedDurationMinutes() {
        return estimatedDurationMinutes;
    }
    
    public void setEstimatedDurationMinutes(Integer estimatedDurationMinutes) {
        this.estimatedDurationMinutes = estimatedDurationMinutes;
    }
    
    public List<String> getPrerequisites() {
        return prerequisites;
    }
    
    public void setPrerequisites(List<String> prerequisites) {
        this.prerequisites = prerequisites;
    }
    
    public List<String> getLearningObjectives() {
        return learningObjectives;
    }
    
    public void setLearningObjectives(List<String> learningObjectives) {
        this.learningObjectives = learningObjectives;
    }
    
    public List<String> getSteps() {
        return steps;
    }
    
    public void setSteps(List<String> steps) {
        this.steps = steps;
    }
    
    public List<String> getToolsRequired() {
        return toolsRequired;
    }
    
    public void setToolsRequired(List<String> toolsRequired) {
        this.toolsRequired = toolsRequired;
    }
    
    public List<String> getSamplePrompts() {
        return samplePrompts;
    }
    
    public void setSamplePrompts(List<String> samplePrompts) {
        this.samplePrompts = samplePrompts;
    }
    
    public String getTipsTricks() {
        return tipsTricks;
    }
    
    public void setTipsTricks(String tipsTricks) {
        this.tipsTricks = tipsTricks;
    }
    
    public List<String> getCommonMistakes() {
        return commonMistakes;
    }
    
    public void setCommonMistakes(List<String> commonMistakes) {
        this.commonMistakes = commonMistakes;
    }
    
    public String getCreatedBy() {
        return createdBy;
    }
    
    public void setCreatedBy(String createdBy) {
        this.createdBy = createdBy;
    }
    
    public Integer getViewCount() {
        return viewCount;
    }
    
    public void setViewCount(Integer viewCount) {
        this.viewCount = viewCount;
    }
    
    public Integer getLikeCount() {
        return likeCount;
    }
    
    public void setLikeCount(Integer likeCount) {
        this.likeCount = likeCount;
    }
    
    public boolean isPublished() {
        return isPublished;
    }
    
    public void setPublished(boolean published) {
        isPublished = published;
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
     * 예상 소요 시간을 포맷팅
     */
    public String getFormattedDuration() {
        if (estimatedDurationMinutes == null) {
            return "시간 정보 없음";
        }
        
        int hours = estimatedDurationMinutes / 60;
        int minutes = estimatedDurationMinutes % 60;
        
        if (hours > 0) {
            return hours + "시간 " + minutes + "분";
        } else {
            return minutes + "분";
        }
    }
    
    /**
     * 선행 조건이 있는지 확인
     */
    public boolean hasPrerequisites() {
        return prerequisites != null && !prerequisites.isEmpty();
    }
    
    /**
     * 필요한 도구가 있는지 확인
     */
    public boolean hasRequiredTools() {
        return toolsRequired != null && !toolsRequired.isEmpty();
    }
    
    /**
     * 단계 수 반환
     */
    public int getStepCount() {
        return steps != null ? steps.size() : 0;
    }
    
    @Override
    public String toString() {
        return "WorkflowGuide{" +
                "id=" + id +
                ", title='" + title + '\'' +
                ", category='" + category + '\'' +
                ", difficultyLevel='" + difficultyLevel + '\'' +
                ", duration=" + estimatedDurationMinutes +
                '}';
    }
}
