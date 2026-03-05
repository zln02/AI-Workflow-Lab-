package dao;

import model.LabProject;
import db.DBConnect;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.sql.*;
import java.util.*;
import java.lang.reflect.Type;

/**
 * 실습 랩 프로젝트 데이터 접근 객체
 * 실무 프로젝트 경험 관리
 */
public class LabProjectDAO {
    private Gson gson = new Gson();
    
    /**
     * 모든 프로젝트 조회
     */
    public List<LabProject> findAll() throws SQLException {
        List<LabProject> projects = new ArrayList<>();
        String sql = "SELECT * FROM lab_projects WHERE is_active = true ORDER BY created_at DESC";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                projects.add(mapResultSetToLabProject(rs));
            }
        }
        return projects;
    }
    
    /**
     * ID로 프로젝트 조회
     */
    public LabProject findById(int id) throws SQLException {
        String sql = "SELECT * FROM lab_projects WHERE id = ?";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToLabProject(rs);
                }
            }
        }
        return null;
    }
    
    /**
     * 카테고리별 프로젝트 조회
     */
    public List<LabProject> findByCategory(String category) throws SQLException {
        List<LabProject> projects = new ArrayList<>();
        String sql = "SELECT * FROM lab_projects WHERE category = ? AND is_active = true ORDER BY created_at DESC";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, category);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    projects.add(mapResultSetToLabProject(rs));
                }
            }
        }
        return projects;
    }
    
    /**
     * 난이도별 프로젝트 조회
     */
    public List<LabProject> findByDifficulty(String difficultyLevel) throws SQLException {
        List<LabProject> projects = new ArrayList<>();
        String sql = "SELECT * FROM lab_projects WHERE difficulty_level = ? AND is_active = true ORDER BY created_at DESC";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, difficultyLevel);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    projects.add(mapResultSetToLabProject(rs));
                }
            }
        }
        return projects;
    }
    
    /**
     * 프로젝트 타입별 조회
     */
    public List<LabProject> findByType(String projectType) throws SQLException {
        List<LabProject> projects = new ArrayList<>();
        String sql = "SELECT * FROM lab_projects WHERE project_type = ? AND is_active = true ORDER BY created_at DESC";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, projectType);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    projects.add(mapResultSetToLabProject(rs));
                }
            }
        }
        return projects;
    }
    
    /**
     * 인기 프로젝트 조회 (참여자 수 기준)
     */
    public List<LabProject> findPopular(int limit) throws SQLException {
        List<LabProject> projects = new ArrayList<>();
        String sql = "SELECT * FROM lab_projects WHERE is_active = true " +
                    "ORDER BY current_participants DESC, created_at DESC LIMIT ?";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    projects.add(mapResultSetToLabProject(rs));
                }
            }
        }
        return projects;
    }
    
    /**
     * 키워드로 프로젝트 검색
     */
    public List<LabProject> searchByKeyword(String keyword) throws SQLException {
        List<LabProject> projects = new ArrayList<>();
        String sql = "SELECT * FROM lab_projects WHERE " +
                    "is_active = true AND " +
                    "(title LIKE ? OR description LIKE ? OR category LIKE ? OR business_context LIKE ?) " +
                    "ORDER BY current_participants DESC, created_at DESC";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            String searchPattern = "%" + keyword + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);
            ps.setString(4, searchPattern);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    projects.add(mapResultSetToLabProject(rs));
                }
            }
        }
        return projects;
    }
    
    /**
     * 프로젝트 등록
     */
    public boolean create(LabProject project) throws SQLException {
        String sql = "INSERT INTO lab_projects (" +
                    "title, description, category, difficulty_level, project_type, business_context, " +
                    "project_goals, requirements, step_by_step_guide, expected_outcomes, " +
                    "evaluation_criteria, hints, solution_guide, tools_required, " +
                    "estimated_duration_hours, max_participants, current_participants, " +
                    "is_active, created_by" +
                    ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setString(1, project.getTitle());
            ps.setString(2, project.getDescription());
            ps.setString(3, project.getCategory());
            ps.setString(4, project.getDifficultyLevel());
            ps.setString(5, project.getProjectType());
            ps.setString(6, project.getBusinessContext());
            ps.setString(7, project.getProjectGoals() != null ? gson.toJson(project.getProjectGoals()) : null);
            ps.setString(8, project.getRequirements() != null ? gson.toJson(project.getRequirements()) : null);
            ps.setString(9, project.getStepByStepGuide() != null ? gson.toJson(project.getStepByStepGuide()) : null);
            ps.setString(10, project.getExpectedOutcomes() != null ? gson.toJson(project.getExpectedOutcomes()) : null);
            ps.setString(11, project.getEvaluationCriteria() != null ? gson.toJson(project.getEvaluationCriteria()) : null);
            ps.setString(12, project.getHints() != null ? gson.toJson(project.getHints()) : null);
            ps.setString(13, project.getSolutionGuide());
            ps.setString(14, project.getToolsRequired() != null ? gson.toJson(project.getToolsRequired()) : null);
            ps.setObject(15, project.getEstimatedDurationHours());
            ps.setObject(16, project.getMaxParticipants());
            ps.setObject(17, project.getCurrentParticipants());
            ps.setBoolean(18, project.isActive());
            ps.setString(19, project.getCreatedBy());
            
            int result = ps.executeUpdate();
            
            if (result > 0) {
                try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        project.setId(generatedKeys.getInt(1));
                    }
                }
                return true;
            }
        }
        return false;
    }
    
    /**
     * 프로젝트 정보 수정
     */
    public boolean update(LabProject project) throws SQLException {
        String sql = "UPDATE lab_projects SET " +
                    "title = ?, description = ?, category = ?, difficulty_level = ?, " +
                    "project_type = ?, business_context = ?, project_goals = ?, " +
                    "requirements = ?, step_by_step_guide = ?, expected_outcomes = ?, " +
                    "evaluation_criteria = ?, hints = ?, solution_guide = ?, " +
                    "tools_required = ?, estimated_duration_hours = ?, max_participants = ?, " +
                    "is_active = ?, updated_at = CURRENT_TIMESTAMP " +
                    "WHERE id = ?";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, project.getTitle());
            ps.setString(2, project.getDescription());
            ps.setString(3, project.getCategory());
            ps.setString(4, project.getDifficultyLevel());
            ps.setString(5, project.getProjectType());
            ps.setString(6, project.getBusinessContext());
            ps.setString(7, project.getProjectGoals() != null ? gson.toJson(project.getProjectGoals()) : null);
            ps.setString(8, project.getRequirements() != null ? gson.toJson(project.getRequirements()) : null);
            ps.setString(9, project.getStepByStepGuide() != null ? gson.toJson(project.getStepByStepGuide()) : null);
            ps.setString(10, project.getExpectedOutcomes() != null ? gson.toJson(project.getExpectedOutcomes()) : null);
            ps.setString(11, project.getEvaluationCriteria() != null ? gson.toJson(project.getEvaluationCriteria()) : null);
            ps.setString(12, project.getHints() != null ? gson.toJson(project.getHints()) : null);
            ps.setString(13, project.getSolutionGuide());
            ps.setString(14, project.getToolsRequired() != null ? gson.toJson(project.getToolsRequired()) : null);
            ps.setObject(15, project.getEstimatedDurationHours());
            ps.setObject(16, project.getMaxParticipants());
            ps.setBoolean(17, project.isActive());
            ps.setInt(18, project.getId());
            
            return ps.executeUpdate() > 0;
        }
    }
    
    /**
     * 프로젝트 삭제
     */
    public boolean delete(int id) throws SQLException {
        String sql = "DELETE FROM lab_projects WHERE id = ?";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }
    
    /**
     * 참여자 수 증가
     */
    public boolean incrementParticipantCount(int id) throws SQLException {
        String sql = "UPDATE lab_projects SET current_participants = current_participants + 1 WHERE id = ? " +
                    "AND (max_participants IS NULL OR current_participants < max_participants)";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }
    
    /**
     * 참여자 수 감소
     */
    public boolean decrementParticipantCount(int id) throws SQLException {
        String sql = "UPDATE lab_projects SET current_participants = GREATEST(0, current_participants - 1) WHERE id = ?";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }
    
    /**
     * ResultSet을 LabProject 객체로 매핑
     */
    private LabProject mapResultSetToLabProject(ResultSet rs) throws SQLException {
        LabProject project = new LabProject();
        
        project.setId(rs.getInt("id"));
        project.setTitle(rs.getString("title"));
        project.setDescription(rs.getString("description"));
        project.setCategory(rs.getString("category"));
        project.setDifficultyLevel(rs.getString("difficulty_level"));
        project.setProjectType(rs.getString("project_type"));
        project.setBusinessContext(rs.getString("business_context"));
        
        // JSON 필드 파싱
        Type listType = new TypeToken<List<String>>(){}.getType();
        project.setProjectGoals(gson.fromJson(rs.getString("project_goals"), listType));
        project.setRequirements(gson.fromJson(rs.getString("requirements"), listType));
        project.setStepByStepGuide(gson.fromJson(rs.getString("step_by_step_guide"), listType));
        project.setExpectedOutcomes(gson.fromJson(rs.getString("expected_outcomes"), listType));
        project.setEvaluationCriteria(gson.fromJson(rs.getString("evaluation_criteria"), listType));
        project.setHints(gson.fromJson(rs.getString("hints"), listType));
        project.setToolsRequired(gson.fromJson(rs.getString("tools_required"), listType));
        
        project.setSolutionGuide(rs.getString("solution_guide"));
        project.setEstimatedDurationHours(rs.getObject("estimated_duration_hours", Double.class));
        project.setMaxParticipants(rs.getObject("max_participants", Integer.class));
        project.setCurrentParticipants(rs.getObject("current_participants", Integer.class));
        project.setActive(rs.getBoolean("is_active"));
        project.setCreatedBy(rs.getString("created_by"));
        project.setCreatedAt(rs.getTimestamp("created_at"));
        project.setUpdatedAt(rs.getTimestamp("updated_at"));
        
        return project;
    }
}
