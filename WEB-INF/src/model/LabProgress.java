package model;

import java.sql.Timestamp;

/**
 * 랩 진행률 모델
 */
public class LabProgress {
    private int id;
    private int userId;
    private int labId;
    private int currentStep;
    private int totalSteps;
    private double completionPercentage;
    private String status; // 'not_started', 'in_progress', 'completed', 'paused'
    private Timestamp startedAt;
    private Timestamp lastAccessedAt;
    private Timestamp completedAt;
    private long timeSpentMinutes; // 총 소요 시간 (분)
    private String notes; // 사용자 메모
    
    // 생성자
    public LabProgress() {}
    
    public LabProgress(int userId, int labId, int totalSteps) {
        this.userId = userId;
        this.labId = labId;
        this.totalSteps = totalSteps;
        this.currentStep = 0;
        this.completionPercentage = 0.0;
        this.status = "not_started";
        this.startedAt = new Timestamp(System.currentTimeMillis());
        this.lastAccessedAt = new Timestamp(System.currentTimeMillis());
        this.timeSpentMinutes = 0;
    }
    
    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    
    public int getLabId() { return labId; }
    public void setLabId(int labId) { this.labId = labId; }
    
    public int getCurrentStep() { return currentStep; }
    public void setCurrentStep(int currentStep) { 
        this.currentStep = currentStep;
        updateCompletionPercentage();
    }
    
    public int getTotalSteps() { return totalSteps; }
    public void setTotalSteps(int totalSteps) { 
        this.totalSteps = totalSteps;
        updateCompletionPercentage();
    }
    
    public double getCompletionPercentage() { return completionPercentage; }
    private void updateCompletionPercentage() {
        if (totalSteps > 0) {
            this.completionPercentage = (double) currentStep / totalSteps * 100;
            if (completionPercentage >= 100) {
                this.status = "completed";
                this.completedAt = new Timestamp(System.currentTimeMillis());
            } else if (currentStep > 0) {
                this.status = "in_progress";
            }
        }
    }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    public Timestamp getStartedAt() { return startedAt; }
    public void setStartedAt(Timestamp startedAt) { this.startedAt = startedAt; }
    
    public Timestamp getLastAccessedAt() { return lastAccessedAt; }
    public void setLastAccessedAt(Timestamp lastAccessedAt) { this.lastAccessedAt = lastAccessedAt; }
    
    public Timestamp getCompletedAt() { return completedAt; }
    public void setCompletedAt(Timestamp completedAt) { this.completedAt = completedAt; }
    
    public long getTimeSpentMinutes() { return timeSpentMinutes; }
    public void setTimeSpentMinutes(long timeSpentMinutes) { this.timeSpentMinutes = timeSpentMinutes; }
    
    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
    
    // 비즈니스 메서드
    public void nextStep() {
        if (currentStep < totalSteps) {
            currentStep++;
            updateCompletionPercentage();
            lastAccessedAt = new Timestamp(System.currentTimeMillis());
        }
    }
    
    public void previousStep() {
        if (currentStep > 0) {
            currentStep--;
            updateCompletionPercentage();
            lastAccessedAt = new Timestamp(System.currentTimeMillis());
        }
    }
    
    public void pause() {
        this.status = "paused";
        this.lastAccessedAt = new Timestamp(System.currentTimeMillis());
    }
    
    public void resume() {
        this.status = "in_progress";
        this.lastAccessedAt = new Timestamp(System.currentTimeMillis());
    }
    
    public void complete() {
        this.currentStep = totalSteps;
        this.status = "completed";
        this.completedAt = new Timestamp(System.currentTimeMillis());
        this.completionPercentage = 100.0;
    }
    
    public boolean isCompleted() {
        return "completed".equals(status);
    }
    
    public boolean isInProgress() {
        return "in_progress".equals(status);
    }
    
    public boolean isNotStarted() {
        return "not_started".equals(status);
    }
    
    public boolean isPaused() {
        return "paused".equals(status);
    }
    
    @Override
    public String toString() {
        return "LabProgress{" +
                "id=" + id +
                ", userId=" + userId +
                ", labId=" + labId +
                ", currentStep=" + currentStep +
                ", totalSteps=" + totalSteps +
                ", completionPercentage=" + completionPercentage +
                ", status='" + status + '\'' +
                ", startedAt=" + startedAt +
                ", lastAccessedAt=" + lastAccessedAt +
                ", completedAt=" + completedAt +
                ", timeSpentMinutes=" + timeSpentMinutes +
                ", notes='" + notes + '\'' +
                '}';
    }
}
