package dao;

import model.WorkflowGuide;
import db.DBConnect;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.sql.*;
import java.util.*;
import java.lang.reflect.Type;

/**
 * 워크플로우 가이드 데이터 접근 객체
 * AI 도구 사용법 가이드 관리
 */
public class WorkflowGuideDAO {
    private Gson gson = new Gson();
    
    /**
     * 모든 가이드 조회
     */
    public List<WorkflowGuide> findAll() throws SQLException {
        List<WorkflowGuide> guides = new ArrayList<>();
        String sql = "SELECT * FROM workflow_guides WHERE is_published = true ORDER BY created_at DESC";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                guides.add(mapResultSetToWorkflowGuide(rs));
            }
        }
        return guides;
    }
    
    /**
     * ID로 가이드 조회
     */
    public WorkflowGuide findById(int id) throws SQLException {
        String sql = "SELECT * FROM workflow_guides WHERE id = ?";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToWorkflowGuide(rs);
                }
            }
        }
        return null;
    }
    
    /**
     * 카테고리별 가이드 조회
     */
    public List<WorkflowGuide> findByCategory(String category) throws SQLException {
        List<WorkflowGuide> guides = new ArrayList<>();
        String sql = "SELECT * FROM workflow_guides WHERE category = ? AND is_published = true ORDER BY created_at DESC";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, category);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    guides.add(mapResultSetToWorkflowGuide(rs));
                }
            }
        }
        return guides;
    }
    
    /**
     * 난이도별 가이드 조회
     */
    public List<WorkflowGuide> findByDifficulty(String difficultyLevel) throws SQLException {
        List<WorkflowGuide> guides = new ArrayList<>();
        String sql = "SELECT * FROM workflow_guides WHERE difficulty_level = ? AND is_published = true ORDER BY created_at DESC";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, difficultyLevel);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    guides.add(mapResultSetToWorkflowGuide(rs));
                }
            }
        }
        return guides;
    }
    
    /**
     * 인기 가이드 조회 (조회수/좋아요 기준)
     */
    public List<WorkflowGuide> findPopular(int limit) throws SQLException {
        List<WorkflowGuide> guides = new ArrayList<>();
        String sql = "SELECT *, (view_count + like_count * 2) as popularity_score " +
                    "FROM workflow_guides WHERE is_published = true " +
                    "ORDER BY popularity_score DESC, created_at DESC LIMIT ?";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    guides.add(mapResultSetToWorkflowGuide(rs));
                }
            }
        }
        return guides;
    }
    
    /**
     * 키워드로 가이드 검색
     */
    public List<WorkflowGuide> searchByKeyword(String keyword) throws SQLException {
        List<WorkflowGuide> guides = new ArrayList<>();
        String sql = "SELECT * FROM workflow_guides WHERE " +
                    "is_published = true AND " +
                    "(title LIKE ? OR description LIKE ? OR category LIKE ?) " +
                    "ORDER BY view_count DESC, created_at DESC";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            String searchPattern = "%" + keyword + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    guides.add(mapResultSetToWorkflowGuide(rs));
                }
            }
        }
        return guides;
    }
    
    /**
     * 가이드 등록
     */
    public boolean create(WorkflowGuide guide) throws SQLException {
        String sql = "INSERT INTO workflow_guides (" +
                    "title, description, category, difficulty_level, estimated_duration_minutes, " +
                    "prerequisites, learning_objectives, steps, tools_required, sample_prompts, " +
                    "tips_tricks, common_mistakes, created_by, is_published" +
                    ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setString(1, guide.getTitle());
            ps.setString(2, guide.getDescription());
            ps.setString(3, guide.getCategory());
            ps.setString(4, guide.getDifficultyLevel());
            ps.setObject(5, guide.getEstimatedDurationMinutes());
            ps.setString(6, guide.getPrerequisites() != null ? gson.toJson(guide.getPrerequisites()) : null);
            ps.setString(7, guide.getLearningObjectives() != null ? gson.toJson(guide.getLearningObjectives()) : null);
            ps.setString(8, guide.getSteps() != null ? gson.toJson(guide.getSteps()) : null);
            ps.setString(9, guide.getToolsRequired() != null ? gson.toJson(guide.getToolsRequired()) : null);
            ps.setString(10, guide.getSamplePrompts() != null ? gson.toJson(guide.getSamplePrompts()) : null);
            ps.setString(11, guide.getTipsTricks());
            ps.setString(12, guide.getCommonMistakes() != null ? gson.toJson(guide.getCommonMistakes()) : null);
            ps.setString(13, guide.getCreatedBy());
            ps.setBoolean(14, guide.isPublished());
            
            int result = ps.executeUpdate();
            
            if (result > 0) {
                try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        guide.setId(generatedKeys.getInt(1));
                    }
                }
                return true;
            }
        }
        return false;
    }
    
    /**
     * 가이드 정보 수정
     */
    public boolean update(WorkflowGuide guide) throws SQLException {
        String sql = "UPDATE workflow_guides SET " +
                    "title = ?, description = ?, category = ?, difficulty_level = ?, " +
                    "estimated_duration_minutes = ?, prerequisites = ?, learning_objectives = ?, " +
                    "steps = ?, tools_required = ?, sample_prompts = ?, tips_tricks = ?, " +
                    "common_mistakes = ?, is_published = ?, updated_at = CURRENT_TIMESTAMP " +
                    "WHERE id = ?";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, guide.getTitle());
            ps.setString(2, guide.getDescription());
            ps.setString(3, guide.getCategory());
            ps.setString(4, guide.getDifficultyLevel());
            ps.setObject(5, guide.getEstimatedDurationMinutes());
            ps.setString(6, guide.getPrerequisites() != null ? gson.toJson(guide.getPrerequisites()) : null);
            ps.setString(7, guide.getLearningObjectives() != null ? gson.toJson(guide.getLearningObjectives()) : null);
            ps.setString(8, guide.getSteps() != null ? gson.toJson(guide.getSteps()) : null);
            ps.setString(9, guide.getToolsRequired() != null ? gson.toJson(guide.getToolsRequired()) : null);
            ps.setString(10, guide.getSamplePrompts() != null ? gson.toJson(guide.getSamplePrompts()) : null);
            ps.setString(11, guide.getTipsTricks());
            ps.setString(12, guide.getCommonMistakes() != null ? gson.toJson(guide.getCommonMistakes()) : null);
            ps.setBoolean(13, guide.isPublished());
            ps.setInt(14, guide.getId());
            
            return ps.executeUpdate() > 0;
        }
    }
    
    /**
     * 가이드 삭제
     */
    public boolean delete(int id) throws SQLException {
        String sql = "DELETE FROM workflow_guides WHERE id = ?";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }
    
    /**
     * 조회수 증가
     */
    public boolean incrementViewCount(int id) throws SQLException {
        String sql = "UPDATE workflow_guides SET view_count = view_count + 1 WHERE id = ?";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }
    
    /**
     * 좋아요 증가
     */
    public boolean incrementLikeCount(int id) throws SQLException {
        String sql = "UPDATE workflow_guides SET like_count = like_count + 1 WHERE id = ?";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }
    
    /**
     * ResultSet을 WorkflowGuide 객체로 매핑
     */
    private WorkflowGuide mapResultSetToWorkflowGuide(ResultSet rs) throws SQLException {
        WorkflowGuide guide = new WorkflowGuide();
        
        guide.setId(rs.getInt("id"));
        guide.setTitle(rs.getString("title"));
        guide.setDescription(rs.getString("description"));
        guide.setCategory(rs.getString("category"));
        guide.setDifficultyLevel(rs.getString("difficulty_level"));
        guide.setEstimatedDurationMinutes(rs.getObject("estimated_duration_minutes", Integer.class));
        
        // JSON 필드 파싱
        Type listType = new TypeToken<List<String>>(){}.getType();
        guide.setPrerequisites(gson.fromJson(rs.getString("prerequisites"), listType));
        guide.setLearningObjectives(gson.fromJson(rs.getString("learning_objectives"), listType));
        guide.setSteps(gson.fromJson(rs.getString("steps"), listType));
        guide.setToolsRequired(gson.fromJson(rs.getString("tools_required"), listType));
        guide.setSamplePrompts(gson.fromJson(rs.getString("sample_prompts"), listType));
        guide.setCommonMistakes(gson.fromJson(rs.getString("common_mistakes"), listType));
        
        guide.setTipsTricks(rs.getString("tips_tricks"));
        guide.setCreatedBy(rs.getString("created_by"));
        guide.setViewCount(rs.getObject("view_count", Integer.class));
        guide.setLikeCount(rs.getObject("like_count", Integer.class));
        guide.setPublished(rs.getBoolean("is_published"));
        guide.setCreatedAt(rs.getTimestamp("created_at"));
        guide.setUpdatedAt(rs.getTimestamp("updated_at"));
        
        return guide;
    }
}
