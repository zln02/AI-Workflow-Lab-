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
    private final Gson gson = new Gson();
    private final Type listType = new TypeToken<List<String>>(){}.getType();
    
    /**
     * 모든 AI 도구 조회
     */
    public List<AITool> findAll() throws SQLException {
        return findFiltered(null, null, null, null, false, false, "default", null, null);
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
        return findFiltered(null, category, null, null, false, false, "default", null, null);
    }
    
    /**
     * 난이도별 AI 도구 조회
     */
    public List<AITool> findByDifficulty(String difficultyLevel) throws SQLException {
        return findFiltered(null, null, difficultyLevel, null, false, false, "default", null, null);
    }
    
    /**
     * 인기 AI 도구 조회 (상위 N개)
     */
    public List<AITool> findPopular(int limit) throws SQLException {
        return findFiltered(null, null, null, null, false, false, "rating", limit, 0);
    }
    
    /**
     * 무료 플랜이 있는 AI 도구 조회
     */
    public List<AITool> findFreeTierAvailable() throws SQLException {
        return findFiltered(null, null, null, null, true, false, "default", null, null);
    }
    
    /**
     * 키워드로 AI 도구 검색
     */
    public List<AITool> searchByKeyword(String keyword) throws SQLException {
        return findFiltered(keyword, null, null, null, false, false, "default", null, null);
    }

    public List<AITool> findFiltered(String keyword, String category, String difficultyLevel,
                                     String country, boolean freeOnly, boolean apiOnly,
                                     String sort, Integer limit, Integer offset) throws SQLException {
        List<AITool> tools = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM ai_tools WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            String searchPattern = "%" + keyword.trim() + "%";
            sql.append(" AND (tool_name LIKE ? OR description LIKE ? OR purpose_summary LIKE ? OR provider_name LIKE ? OR tags LIKE ?)");
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
        }

        if (category != null && !category.trim().isEmpty()) {
            sql.append(" AND category = ?");
            params.add(category.trim());
        }

        if (difficultyLevel != null && !difficultyLevel.trim().isEmpty()) {
            sql.append(" AND difficulty_level = ?");
            params.add(difficultyLevel.trim());
        }

        if (country != null && !country.trim().isEmpty()) {
            sql.append(" AND provider_country = ?");
            params.add(country.trim());
        }

        if (freeOnly) {
            sql.append(" AND free_tier_available = TRUE");
        }

        if (apiOnly) {
            sql.append(" AND api_available = TRUE");
        }

        sql.append(" ORDER BY ").append(resolveSortClause(sort));

        if (limit != null && limit > 0) {
            sql.append(" LIMIT ?");
            params.add(limit);
            if (offset != null && offset >= 0) {
                sql.append(" OFFSET ?");
                params.add(offset);
            }
        }

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            bindParams(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    tools.add(mapResultSetToAITool(rs));
                }
            }
        }

        return tools;
    }

    public List<AITool> findByIds(List<Integer> ids) throws SQLException {
        List<AITool> tools = new ArrayList<>();
        if (ids == null || ids.isEmpty()) {
            return tools;
        }

        StringBuilder sql = new StringBuilder("SELECT * FROM ai_tools WHERE id IN (");
        for (int i = 0; i < ids.size(); i++) {
            if (i > 0) {
                sql.append(", ");
            }
            sql.append("?");
        }
        sql.append(")");

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            bindParams(ps, new ArrayList<Object>(ids));
            try (ResultSet rs = ps.executeQuery()) {
                Map<Integer, AITool> toolMap = new HashMap<>();
                while (rs.next()) {
                    AITool tool = mapResultSetToAITool(rs);
                    toolMap.put(tool.getId(), tool);
                }

                for (Integer id : ids) {
                    AITool tool = toolMap.get(id);
                    if (tool != null) {
                        tools.add(tool);
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
        
        sql.append("ORDER BY relevance_score DESC, trend_score DESC, rating DESC LIMIT 10");
        
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
                    "tool_name, provider_name, provider_country, category, subcategory, description, " +
                    "purpose_summary, use_cases, features, pricing_model, pricing_details, " +
                    "api_available, free_tier_available, website_url, docs_url, " +
                    "playground_url, supported_languages, supported_platforms, input_modalities, output_modalities, " +
                    "max_file_size_mb, rate_limit_per_min, monthly_active_users, launch_date, last_major_update, " +
                    "global_rank, category_rank, trend_score, growth_rate, pros, cons, alternatives, integrations, " +
                    "data_privacy_score, enterprise_ready, open_source, github_url, github_stars, monthly_visits, " +
                    "commercial_use_allowed, onprem_available, license_type, difficulty_level, tags, rating, review_count" +
                    ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setString(1, tool.getToolName());
            ps.setString(2, tool.getProviderName());
            ps.setString(3, tool.getProviderCountry());
            ps.setString(4, tool.getCategory());
            ps.setString(5, tool.getSubcategory());
            ps.setString(6, tool.getDescription());
            ps.setString(7, tool.getPurposeSummary());
            ps.setString(8, toJson(tool.getUseCases()));
            ps.setString(9, toJson(tool.getFeatures()));
            ps.setString(10, tool.getPricingModel());
            ps.setString(11, tool.getPricingDetails());
            ps.setBoolean(12, tool.isApiAvailable());
            ps.setBoolean(13, tool.isFreeTierAvailable());
            ps.setString(14, tool.getWebsiteUrl());
            ps.setString(15, tool.getDocsUrl());
            ps.setString(16, tool.getPlaygroundUrl());
            ps.setString(17, toJson(tool.getSupportedLanguages()));
            ps.setString(18, toJson(tool.getSupportedPlatforms()));
            ps.setString(19, tool.getInputModalities());
            ps.setString(20, tool.getOutputModalities());
            ps.setObject(21, tool.getMaxFileSizeMb());
            ps.setObject(22, tool.getRateLimitPerMin());
            ps.setObject(23, tool.getMonthlyActiveUsers());
            ps.setDate(24, tool.getLaunchDate());
            ps.setDate(25, tool.getLastMajorUpdate());
            ps.setObject(26, tool.getGlobalRank());
            ps.setObject(27, tool.getCategoryRank());
            ps.setObject(28, tool.getTrendScore());
            ps.setObject(29, tool.getGrowthRate());
            ps.setString(30, toJson(tool.getPros()));
            ps.setString(31, toJson(tool.getCons()));
            ps.setString(32, toJson(tool.getAlternatives()));
            ps.setString(33, toJson(tool.getIntegrations()));
            ps.setObject(34, tool.getDataPrivacyScore());
            ps.setBoolean(35, tool.isEnterpriseReady());
            ps.setBoolean(36, tool.isOpenSource());
            ps.setString(37, tool.getGithubUrl());
            ps.setObject(38, tool.getGithubStars());
            ps.setObject(39, tool.getMonthlyVisits());
            ps.setBoolean(40, tool.isCommercialUseAllowed());
            ps.setBoolean(41, tool.isOnpremAvailable());
            ps.setString(42, tool.getLicenseType());
            ps.setString(43, tool.getDifficultyLevel());
            ps.setString(44, toJson(tool.getTags()));
            ps.setObject(45, tool.getRating());
            ps.setObject(46, tool.getReviewCount());
            
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
                    "tool_name = ?, provider_name = ?, provider_country = ?, category = ?, subcategory = ?, " +
                    "description = ?, purpose_summary = ?, use_cases = ?, features = ?, " +
                    "pricing_model = ?, pricing_details = ?, api_available = ?, " +
                    "free_tier_available = ?, website_url = ?, docs_url = ?, " +
                    "playground_url = ?, supported_languages = ?, supported_platforms = ?, input_modalities = ?, " +
                    "output_modalities = ?, max_file_size_mb = ?, rate_limit_per_min = ?, monthly_active_users = ?, " +
                    "launch_date = ?, last_major_update = ?, global_rank = ?, category_rank = ?, trend_score = ?, growth_rate = ?, " +
                    "pros = ?, cons = ?, alternatives = ?, integrations = ?, data_privacy_score = ?, " +
                    "enterprise_ready = ?, open_source = ?, github_url = ?, github_stars = ?, monthly_visits = ?, " +
                    "commercial_use_allowed = ?, onprem_available = ?, license_type = ?, " +
                    "difficulty_level = ?, tags = ?, rating = ?, review_count = ?, " +
                    "updated_at = CURRENT_TIMESTAMP " +
                    "WHERE id = ?";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, tool.getToolName());
            ps.setString(2, tool.getProviderName());
            ps.setString(3, tool.getProviderCountry());
            ps.setString(4, tool.getCategory());
            ps.setString(5, tool.getSubcategory());
            ps.setString(6, tool.getDescription());
            ps.setString(7, tool.getPurposeSummary());
            ps.setString(8, toJson(tool.getUseCases()));
            ps.setString(9, toJson(tool.getFeatures()));
            ps.setString(10, tool.getPricingModel());
            ps.setString(11, tool.getPricingDetails());
            ps.setBoolean(12, tool.isApiAvailable());
            ps.setBoolean(13, tool.isFreeTierAvailable());
            ps.setString(14, tool.getWebsiteUrl());
            ps.setString(15, tool.getDocsUrl());
            ps.setString(16, tool.getPlaygroundUrl());
            ps.setString(17, toJson(tool.getSupportedLanguages()));
            ps.setString(18, toJson(tool.getSupportedPlatforms()));
            ps.setString(19, tool.getInputModalities());
            ps.setString(20, tool.getOutputModalities());
            ps.setObject(21, tool.getMaxFileSizeMb());
            ps.setObject(22, tool.getRateLimitPerMin());
            ps.setObject(23, tool.getMonthlyActiveUsers());
            ps.setDate(24, tool.getLaunchDate());
            ps.setDate(25, tool.getLastMajorUpdate());
            ps.setObject(26, tool.getGlobalRank());
            ps.setObject(27, tool.getCategoryRank());
            ps.setObject(28, tool.getTrendScore());
            ps.setObject(29, tool.getGrowthRate());
            ps.setString(30, toJson(tool.getPros()));
            ps.setString(31, toJson(tool.getCons()));
            ps.setString(32, toJson(tool.getAlternatives()));
            ps.setString(33, toJson(tool.getIntegrations()));
            ps.setObject(34, tool.getDataPrivacyScore());
            ps.setBoolean(35, tool.isEnterpriseReady());
            ps.setBoolean(36, tool.isOpenSource());
            ps.setString(37, tool.getGithubUrl());
            ps.setObject(38, tool.getGithubStars());
            ps.setObject(39, tool.getMonthlyVisits());
            ps.setBoolean(40, tool.isCommercialUseAllowed());
            ps.setBoolean(41, tool.isOnpremAvailable());
            ps.setString(42, tool.getLicenseType());
            ps.setString(43, tool.getDifficultyLevel());
            ps.setString(44, toJson(tool.getTags()));
            ps.setObject(45, tool.getRating());
            ps.setObject(46, tool.getReviewCount());
            ps.setInt(47, tool.getId());
            
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
        tool.setProviderCountry(rs.getString("provider_country"));
        tool.setCategory(rs.getString("category"));
        tool.setSubcategory(rs.getString("subcategory"));
        tool.setDescription(rs.getString("description"));
        tool.setPurposeSummary(rs.getString("purpose_summary"));
        
        tool.setUseCases(fromJsonList(rs.getString("use_cases")));
        tool.setFeatures(fromJsonList(rs.getString("features")));
        tool.setSupportedLanguages(fromJsonList(rs.getString("supported_languages")));
        tool.setSupportedPlatforms(fromJsonList(rs.getString("supported_platforms")));
        tool.setPros(fromJsonList(rs.getString("pros")));
        tool.setCons(fromJsonList(rs.getString("cons")));
        tool.setAlternatives(fromJsonList(rs.getString("alternatives")));
        tool.setIntegrations(fromJsonList(rs.getString("integrations")));
        tool.setTags(fromJsonList(rs.getString("tags")));
        
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
        tool.setMonthlyActiveUsers(rs.getObject("monthly_active_users", Long.class));
        tool.setLaunchDate(rs.getDate("launch_date"));
        tool.setLastMajorUpdate(rs.getDate("last_major_update"));
        tool.setGlobalRank(rs.getObject("global_rank", Integer.class));
        tool.setCategoryRank(rs.getObject("category_rank", Integer.class));
        tool.setTrendScore(rs.getObject("trend_score", Double.class));
        tool.setGrowthRate(rs.getObject("growth_rate", Double.class));
        tool.setDataPrivacyScore(rs.getObject("data_privacy_score", Integer.class));
        tool.setEnterpriseReady(rs.getBoolean("enterprise_ready"));
        tool.setOpenSource(rs.getBoolean("open_source"));
        tool.setGithubUrl(rs.getString("github_url"));
        tool.setGithubStars(rs.getObject("github_stars", Integer.class));
        tool.setMonthlyVisits(rs.getObject("monthly_visits", Long.class));
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

    private void bindParams(PreparedStatement ps, List<Object> params) throws SQLException {
        for (int i = 0; i < params.size(); i++) {
            ps.setObject(i + 1, params.get(i));
        }
    }

    private String resolveSortClause(String sort) {
        if ("rating".equalsIgnoreCase(sort)) {
            return "COALESCE(rating, 0) DESC, COALESCE(review_count, 0) DESC, tool_name ASC";
        }
        if ("reviews".equalsIgnoreCase(sort) || "popular".equalsIgnoreCase(sort)) {
            return "COALESCE(monthly_active_users, 0) DESC, COALESCE(review_count, 0) DESC, tool_name ASC";
        }
        if ("trend".equalsIgnoreCase(sort)) {
            return "COALESCE(trend_score, 0) DESC, COALESCE(growth_rate, 0) DESC, tool_name ASC";
        }
        if ("visits".equalsIgnoreCase(sort)) {
            return "COALESCE(monthly_visits, 0) DESC, COALESCE(trend_score, 0) DESC, tool_name ASC";
        }
        if ("growth".equalsIgnoreCase(sort) || "rising".equalsIgnoreCase(sort)) {
            return "COALESCE(growth_rate, 0) DESC, COALESCE(trend_score, 0) DESC, tool_name ASC";
        }
        if ("github".equalsIgnoreCase(sort)) {
            return "COALESCE(github_stars, 0) DESC, COALESCE(trend_score, 0) DESC, tool_name ASC";
        }
        if ("newest".equalsIgnoreCase(sort)) {
            return "COALESCE(last_major_update, created_at) DESC, id DESC";
        }
        if ("rank".equalsIgnoreCase(sort)) {
            return "CASE WHEN global_rank IS NULL THEN 1 ELSE 0 END ASC, global_rank ASC, COALESCE(trend_score, 0) DESC";
        }
        return "CASE WHEN global_rank IS NULL THEN 1 ELSE 0 END ASC, global_rank ASC, COALESCE(trend_score, 0) DESC, COALESCE(rating, 0) DESC, tool_name ASC";
    }

    private List<String> fromJsonList(String json) {
        if (json == null || json.trim().isEmpty()) {
            return null;
        }
        return gson.fromJson(json, listType);
    }

    private String toJson(List<String> values) {
        return values != null ? gson.toJson(values) : null;
    }
}
