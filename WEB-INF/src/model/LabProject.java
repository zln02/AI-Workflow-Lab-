package model;

import java.sql.Timestamp;
import java.util.List;

/**
 * 실습 랩 프로젝트 정보를 담는 모델 클래스
 * 실무 프로젝트 경험 제공
 */
public class LabProject {
    private int id;
    private String title;
    private String description;
    private String category;
    private String difficultyLevel;
    private String projectType;
    private String businessContext;
    private List<String> projectGoals;
    private List<String> requirements;
    private List<String> stepByStepGuide;
    private List<String> expectedOutcomes;
    private List<String> evaluationCriteria;
    private List<String> hints;
    private String solutionGuide;
    private List<String> toolsRequired;
    private Double estimatedDurationHours;
    private Integer maxParticipants;
    private Integer currentParticipants;
    private boolean isActive;
    private String createdBy;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    
    // 생성자
    public LabProject() {}
    
    public LabProject(int id, String title, String category, String difficultyLevel) {
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
    
    public String getProjectType() {
        return projectType;
    }
    
    public void setProjectType(String projectType) {
        this.projectType = projectType;
    }
    
    public String getBusinessContext() {
        return businessContext;
    }
    
    public void setBusinessContext(String businessContext) {
        this.businessContext = businessContext;
    }
    
    public List<String> getProjectGoals() {
        return projectGoals;
    }
    
    public void setProjectGoals(List<String> projectGoals) {
        this.projectGoals = projectGoals;
    }
    
    public List<String> getRequirements() {
        return requirements;
    }
    
    public void setRequirements(List<String> requirements) {
        this.requirements = requirements;
    }
    
    public List<String> getStepByStepGuide() {
        return stepByStepGuide;
    }
    
    public void setStepByStepGuide(List<String> stepByStepGuide) {
        this.stepByStepGuide = stepByStepGuide;
    }
    
    public List<String> getExpectedOutcomes() {
        return expectedOutcomes;
    }
    
    public void setExpectedOutcomes(List<String> expectedOutcomes) {
        this.expectedOutcomes = expectedOutcomes;
    }
    
    public List<String> getEvaluationCriteria() {
        return evaluationCriteria;
    }
    
    public void setEvaluationCriteria(List<String> evaluationCriteria) {
        this.evaluationCriteria = evaluationCriteria;
    }
    
    public List<String> getHints() {
        return hints;
    }
    
    public void setHints(List<String> hints) {
        this.hints = hints;
    }
    
    public String getSolutionGuide() {
        return solutionGuide;
    }
    
    public void setSolutionGuide(String solutionGuide) {
        this.solutionGuide = solutionGuide;
    }
    
    public List<String> getToolsRequired() {
        return toolsRequired;
    }
    
    public void setToolsRequired(List<String> toolsRequired) {
        this.toolsRequired = toolsRequired;
    }
    
    public Double getEstimatedDurationHours() {
        return estimatedDurationHours;
    }
    
    public void setEstimatedDurationHours(Double estimatedDurationHours) {
        this.estimatedDurationHours = estimatedDurationHours;
    }
    
    public Integer getMaxParticipants() {
        return maxParticipants;
    }
    
    public void setMaxParticipants(Integer maxParticipants) {
        this.maxParticipants = maxParticipants;
    }
    
    public Integer getCurrentParticipants() {
        return currentParticipants;
    }
    
    public void setCurrentParticipants(Integer currentParticipants) {
        this.currentParticipants = currentParticipants;
    }
    
    public boolean isActive() {
        return isActive;
    }
    
    public void setActive(boolean active) {
        isActive = active;
    }
    
    public String getCreatedBy() {
        return createdBy;
    }
    
    public void setCreatedBy(String createdBy) {
        this.createdBy = createdBy;
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
     * 프로젝트 타입에 따른 CSS 클래스 반환
     */
    public String getTypeBadgeClass() {
        if ("Tutorial".equals(projectType)) {
            return "badge-info";
        } else if ("Challenge".equals(projectType)) {
            return "badge-warning";
        } else if ("Real-world".equals(projectType)) {
            return "badge-primary";
        }
        return "badge-secondary";
    }
    
    /**
     * 참여 가능 여부 확인
     */
    public boolean hasAvailableSlot() {
        return maxParticipants == null || currentParticipants < maxParticipants;
    }
    
    /**
     * 남은 참여자 수
     */
    public int getRemainingSlots() {
        if (maxParticipants == null) {
            return -1; // 무제한
        }
        return Math.max(0, maxParticipants - currentParticipants);
    }
    
    /**
     * 참여율 계산
     */
    public double getParticipationRate() {
        if (maxParticipants == null || maxParticipants == 0) {
            return 0;
        }
        return (double) currentParticipants / maxParticipants * 100;
    }
    
    /**
     * 예상 소요 시간을 포맷팅
     */
    public String getFormattedDuration() {
        if (estimatedDurationHours == null) {
            return "시간 정보 없음";
        }
        
        if (estimatedDurationHours < 1) {
            int minutes = (int) (estimatedDurationHours * 60);
            return "약 " + minutes + "분";
        } else if (estimatedDurationHours == 1) {
            return "약 1시간";
        } else {
            return "약 " + estimatedDurationHours + "시간";
        }
    }
    
    /**
     * 단계 수 반환
     */
    public int getStepCount() {
        return stepByStepGuide != null ? stepByStepGuide.size() : 0;
    }
    
    /**
     * 힌트가 있는지 확인
     */
    public boolean hasHints() {
        return hints != null && !hints.isEmpty();
    }
    
    @Override
    public String toString() {
        return "LabProject{" +
                "id=" + id +
                ", title='" + title + '\'' +
                ", category='" + category + '\'' +
                ", difficultyLevel='" + difficultyLevel + '\'' +
                ", projectType='" + projectType + '\'' +
                ", participants=" + currentParticipants + "/" + maxParticipants +
                '}';
    }
}
