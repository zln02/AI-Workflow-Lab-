package model;

import java.sql.Timestamp;

/**
 * 사용자 즐겨찾기 모델
 */
public class UserFavorite {
    private int id;
    private int userId;
    private int toolId;
    private String category; // 'tool', 'lab', 'package'
    private Timestamp createdAt;
    
    // 생성자
    public UserFavorite() {}
    
    public UserFavorite(int userId, int toolId, String category) {
        this.userId = userId;
        this.toolId = toolId;
        this.category = category;
        this.createdAt = new Timestamp(System.currentTimeMillis());
    }
    
    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    
    public int getToolId() { return toolId; }
    public void setToolId(int toolId) { this.toolId = toolId; }
    
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    
    @Override
    public String toString() {
        return "UserFavorite{" +
                "id=" + id +
                ", userId=" + userId +
                ", toolId=" + toolId +
                ", category='" + category + '\'' +
                ", createdAt=" + createdAt +
                '}';
    }
}
