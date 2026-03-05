package dao;

import model.AITool;
import db.DBConnect;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.sql.*;
import java.util.*;
import java.lang.reflect.Type;

/**
 * AI 도구 데이터 접근 객체
 * AI Workflow Lab의 핵심 도구 정보 관리
 */
public class AIToolDAO {
    private Gson gson = new Gson();
    
    /**
     * 모든 AI 도구 조회
     */
    public List<AITool> findAll() throws SQLException {
        List<AITool> tools = new ArrayList<>();
        String sql = "SELECT * FROM ai_tools ORDER BY rating DESC, review_count DESC";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                tools.add(mapResultSetToAITool(rs));
            }
        }
        return tools;
    }
    
    /**
     * ID로 AI 도구 조회
     */
    public AITool findById(int id) throws SQLException {
        String sql = "SELECT * FROM ai_tools WHERE id = ?";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToAITool(rs);
                }
            }
        }
        return null;
    }
    
    /**
     * 카테고리별 AI 도구 조회
     */
    public List<AITool> findByCategory(String category) throws SQLException {
        List<AITool> tools = new ArrayList<>();
        String sql = "SELECT * FROM ai_tools WHERE category = ? ORDER BY rating DESC";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, category);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    tools.add(mapResultSetToAITool(rs));
                }
            }
        }
        return tools;
    }
    
    /**
     * 난이도별 AI 도구 조회
     */
    public List<AITool> findByDifficulty(String difficultyLevel) throws SQLException {
        List<AITool> tools = new ArrayList<>();
        String sql = "SELECT * FROM ai_tools WHERE difficulty_level = ? ORDER BY rating DESC";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, difficultyLevel);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    tools.add(mapResultSetToAITool(rs));
                }
            }
        }
        return tools;
    }
    
    /**
     * 인기 AI 도구 조회 (상위 N개)
     */
    public List<AITool> findPopular(int limit) throws SQLException {
        List<AITool> tools = new ArrayList<>();
        String sql = "SELECT * FROM ai_tools WHERE rating > 0 ORDER BY rating DESC, review_count DESC LIMIT ?";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    tools.add(mapResultSetToAITool(rs));
                }
            }
        }
        return tools;
    }
    
    /**
     * 무료 플랜이 있는 AI 도구 조회
     */
    public List<AITool> findFreeTierAvailable() throws SQLException {
        List<AITool> tools = new ArrayList<>();
        String sql = "SELECT * FROM ai_tools WHERE free_tier_available = true ORDER BY rating DESC";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                tools.add(mapResultSetToAITool(rs));
            }
        }
        return tools;
    }
    
    /**
     * 키워드로 AI 도구 검색
     */
    public List<AITool> searchByKeyword(String keyword) throws SQLException {
        List<AITool> tools = new ArrayList<>();
        String sql = "SELECT * FROM ai_tools WHERE " +
                    "MATCH(tool_name, description, purpose_summary) AGAINST(? IN NATURAL LANGUAGE MODE) " +
                    "ORDER BY rating DESC, review_count DESC";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, keyword);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    tools.add(mapResultSetToAITool(rs));
                }
            }
        }
        
        // Full-text search가 없는 경우를 대비한 LIKE 검색
        if (tools.isEmpty()) {
            sql = "SELECT * FROM ai_tools WHERE " +
                  "tool_name LIKE ? OR description LIKE ? OR purpose_summary LIKE ? " +
                  "ORDER BY rating DESC, review_count DESC";
            
            try (Connection conn = DBConnect.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                
                String searchPattern = "%" + keyword + "%";
                ps.setString(1, searchPattern);
                ps.setString(2, searchPattern);
                ps.setString(3, searchPattern);
                
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        tools.add(mapResultSetToAITool(rs));
                    }
                }
            }
        }
        
        return tools;
    }
    
    /**
     * AI 도구 추천 (사용자 쿼리 기반)
     */
    public List<AITool> recommendTools(String query, String difficultyLevel, String category) throws SQLException {
        List<AITool> tools = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT *, " +
            "(CASE WHEN tool_name LIKE ? THEN 10 ELSE 0 END + " +
            " CASE WHEN description LIKE ? THEN 5 ELSE 0 END + " +
            " CASE WHEN purpose_summary LIKE ? THEN 3 ELSE 0 END + " +
            " CASE WHEN category = ? THEN 2 ELSE 0 END + " +
            " CASE WHEN difficulty_level = ? THEN 1 ELSE 0 END) as relevance_score " +
            "FROM ai_tools WHERE api_available = true "
        );
        
        List<String> params = new ArrayList<>();
        String searchPattern = "%" + query + "%";
        params.add(searchPattern);
        params.add(searchPattern);
        params.add(searchPattern);
        params.add(category != null ? category : "");
        params.add(difficultyLevel != null ? difficultyLevel : "");
        
        if (difficultyLevel != null && !difficultyLevel.isEmpty()) {
            sql.append("AND difficulty_level = ? ");
            params.add(difficultyLevel);
        }
        
        if (category != null && !category.isEmpty()) {
            sql.append("AND category = ? ");
            params.add(category);
        }
        
        sql.append("ORDER BY relevance_score DESC, rating DESC LIMIT 10");
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            for (int i = 0; i < params.size(); i++) {
                ps.setString(i + 1, params.get(i));
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    tools.add(mapResultSetToAITool(rs));
                }
            }
        }
        
        return tools;
    }
    
    /**
     * AI 도구 등록
     */
    public boolean create(AITool tool) throws SQLException {
        String sql = "INSERT INTO ai_tools (" +
                    "tool_name, provider_name, category, subcategory, description, " +
                    "purpose_summary, use_cases, features, pricing_model, pricing_details, " +
                    "api_available, free_tier_available, website_url, docs_url, " +
                    "playground_url, supported_languages, input_modalities, output_modalities, " +
                    "max_file_size_mb, rate_limit_per_min, commercial_use_allowed, " +
                    "onprem_available, license_type, difficulty_level, tags, rating, review_count" +
                    ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setString(1, tool.getToolName());
            ps.setString(2, tool.getProviderName());
            ps.setString(3, tool.getCategory());
            ps.setString(4, tool.getSubcategory());
            ps.setString(5, tool.getDescription());
            ps.setString(6, tool.getPurposeSummary());
            ps.setString(7, tool.getUseCases() != null ? gson.toJson(tool.getUseCases()) : null);
            ps.setString(8, tool.getFeatures() != null ? gson.toJson(tool.getFeatures()) : null);
            ps.setString(9, tool.getPricingModel());
            ps.setString(10, tool.getPricingDetails());
            ps.setBoolean(11, tool.isApiAvailable());
            ps.setBoolean(12, tool.isFreeTierAvailable());
            ps.setString(13, tool.getWebsiteUrl());
            ps.setString(14, tool.getDocsUrl());
            ps.setString(15, tool.getPlaygroundUrl());
            ps.setString(16, tool.getSupportedLanguages() != null ? gson.toJson(tool.getSupportedLanguages()) : null);
            ps.setString(17, tool.getInputModalities());
            ps.setString(18, tool.getOutputModalities());
            ps.setObject(19, tool.getMaxFileSizeMb());
            ps.setObject(20, tool.getRateLimitPerMin());
            ps.setBoolean(21, tool.isCommercialUseAllowed());
            ps.setBoolean(22, tool.isOnpremAvailable());
            ps.setString(23, tool.getLicenseType());
            ps.setString(24, tool.getDifficultyLevel());
            ps.setString(25, tool.getTags() != null ? gson.toJson(tool.getTags()) : null);
            ps.setObject(26, tool.getRating());
            ps.setObject(27, tool.getReviewCount());
            
            int result = ps.executeUpdate();
            
            if (result > 0) {
                try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        tool.setId(generatedKeys.getInt(1));
                    }
                }
                return true;
            }
        }
        return false;
    }
    
    /**
     * AI 도구 정보 수정
     */
    public boolean update(AITool tool) throws SQLException {
        String sql = "UPDATE ai_tools SET " +
                    "tool_name = ?, provider_name = ?, category = ?, subcategory = ?, " +
                    "description = ?, purpose_summary = ?, use_cases = ?, features = ?, " +
                    "pricing_model = ?, pricing_details = ?, api_available = ?, " +
                    "free_tier_available = ?, website_url = ?, docs_url = ?, " +
                    "playground_url = ?, supported_languages = ?, input_modalities = ?, " +
                    "output_modalities = ?, max_file_size_mb = ?, rate_limit_per_min = ?, " +
                    "commercial_use_allowed = ?, onprem_available = ?, license_type = ?, " +
                    "difficulty_level = ?, tags = ?, rating = ?, review_count = ?, " +
                    "updated_at = CURRENT_TIMESTAMP " +
                    "WHERE id = ?";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, tool.getToolName());
            ps.setString(2, tool.getProviderName());
            ps.setString(3, tool.getCategory());
            ps.setString(4, tool.getSubcategory());
            ps.setString(5, tool.getDescription());
            ps.setString(6, tool.getPurposeSummary());
            ps.setString(7, tool.getUseCases() != null ? gson.toJson(tool.getUseCases()) : null);
            ps.setString(8, tool.getFeatures() != null ? gson.toJson(tool.getFeatures()) : null);
            ps.setString(9, tool.getPricingModel());
            ps.setString(10, tool.getPricingDetails());
            ps.setBoolean(11, tool.isApiAvailable());
            ps.setBoolean(12, tool.isFreeTierAvailable());
            ps.setString(13, tool.getWebsiteUrl());
            ps.setString(14, tool.getDocsUrl());
            ps.setString(15, tool.getPlaygroundUrl());
            ps.setString(16, tool.getSupportedLanguages() != null ? gson.toJson(tool.getSupportedLanguages()) : null);
            ps.setString(17, tool.getInputModalities());
            ps.setString(18, tool.getOutputModalities());
            ps.setObject(19, tool.getMaxFileSizeMb());
            ps.setObject(20, tool.getRateLimitPerMin());
            ps.setBoolean(21, tool.isCommercialUseAllowed());
            ps.setBoolean(22, tool.isOnpremAvailable());
            ps.setString(23, tool.getLicenseType());
            ps.setString(24, tool.getDifficultyLevel());
            ps.setString(25, tool.getTags() != null ? gson.toJson(tool.getTags()) : null);
            ps.setObject(26, tool.getRating());
            ps.setObject(27, tool.getReviewCount());
            ps.setInt(28, tool.getId());
            
            return ps.executeUpdate() > 0;
        }
    }
    
    /**
     * AI 도구 삭제
     */
    public boolean delete(int id) throws SQLException {
        String sql = "DELETE FROM ai_tools WHERE id = ?";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }
    
    /**
     * 평점 업데이트
     */
    public boolean updateRating(int toolId, double newRating) throws SQLException {
        String sql = "UPDATE ai_tools SET rating = ?, review_count = review_count + 1 WHERE id = ?";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setDouble(1, newRating);
            ps.setInt(2, toolId);
            return ps.executeUpdate() > 0;
        }
    }
    
    /**
     * ResultSet을 AITool 객체로 매핑
     */
    private AITool mapResultSetToAITool(ResultSet rs) throws SQLException {
        AITool tool = new AITool();
        
        tool.setId(rs.getInt("id"));
        tool.setToolName(rs.getString("tool_name"));
        tool.setProviderName(rs.getString("provider_name"));
        tool.setCategory(rs.getString("category"));
        tool.setSubcategory(rs.getString("subcategory"));
        tool.setDescription(rs.getString("description"));
        tool.setPurposeSummary(rs.getString("purpose_summary"));
        
        // JSON 필드 파싱
        Type listType = new TypeToken<List<String>>(){}.getType();
        tool.setUseCases(gson.fromJson(rs.getString("use_cases"), listType));
        tool.setFeatures(gson.fromJson(rs.getString("features"), listType));
        tool.setSupportedLanguages(gson.fromJson(rs.getString("supported_languages"), listType));
        tool.setTags(gson.fromJson(rs.getString("tags"), listType));
        
        tool.setPricingModel(rs.getString("pricing_model"));
        tool.setPricingDetails(rs.getString("pricing_details"));
        tool.setApiAvailable(rs.getBoolean("api_available"));
        tool.setFreeTierAvailable(rs.getBoolean("free_tier_available"));
        tool.setWebsiteUrl(rs.getString("website_url"));
        tool.setDocsUrl(rs.getString("docs_url"));
        tool.setPlaygroundUrl(rs.getString("playground_url"));
        tool.setInputModalities(rs.getString("input_modalities"));
        tool.setOutputModalities(rs.getString("output_modalities"));
        tool.setMaxFileSizeMb(rs.getObject("max_file_size_mb", Double.class));
        tool.setRateLimitPerMin(rs.getObject("rate_limit_per_min", Integer.class));
        tool.setCommercialUseAllowed(rs.getBoolean("commercial_use_allowed"));
        tool.setOnpremAvailable(rs.getBoolean("onprem_available"));
        tool.setLicenseType(rs.getString("license_type"));
        tool.setDifficultyLevel(rs.getString("difficulty_level"));
        tool.setRating(rs.getObject("rating", Double.class));
        tool.setReviewCount(rs.getObject("review_count", Integer.class));
        tool.setCreatedAt(rs.getTimestamp("created_at"));
        tool.setUpdatedAt(rs.getTimestamp("updated_at"));
        
        return tool;
    }
}
