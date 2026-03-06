package dao;

import model.AIModel;
import util.DBConnect;
import java.util.ArrayList;
import java.util.List;

public class AIModelDAO {
    private java.sql.Connection conn;
    
    public AIModelDAO() {
        this.conn = DBConnect.getConnection();
    }
    
    // 모든 AI 모델 가져오기 (페이징)
    public List<AIModel> getAllModels(int page, int pageSize) {
        List<AIModel> models = new ArrayList<>();
        String sql = "SELECT * FROM ai_models WHERE is_active = 1 ORDER BY created_at DESC LIMIT ? OFFSET ?";
        
        try (java.sql.Connection conn = DBConnect.getConnection();
             java.sql.PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, pageSize);
            pstmt.setInt(2, (page - 1) * pageSize);
            
            try (java.sql.ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    AIModel model = new AIModel();
                    model.setId(rs.getInt("id"));
                    model.setModelName(rs.getString("model_name"));
                    model.setProviderName(rs.getString("provider_name"));
                    model.setPurposeSummary(rs.getString("purpose_summary"));
                    model.setPrice(rs.getString("price"));
                    model.setParamsBillion(rs.getString("params_billion"));
                    model.setLatencyMs(rs.getInt("latency_ms"));
                    model.setInputModalities(rs.getString("input_modalities"));
                    model.setOutputModalities(rs.getString("output_modalities"));
                    model.setCategoryId(rs.getInt("category_id"));
                    model.setIsActive(rs.getBoolean("is_active"));
                    model.setCreatedAt(rs.getTimestamp("created_at"));
                    model.setUpdatedAt(rs.getTimestamp("updated_at"));
                    models.add(model);
                }
            }
        } catch (java.sql.SQLException e) {
            e.printStackTrace();
        }
        
        return models;
    }
    
    // 카테고리별 AI 모델 가져오기
    public List<AIModel> getModelsByCategory(int categoryId, int limit) {
        List<AIModel> models = new ArrayList<>();
        String sql = "SELECT * FROM ai_models WHERE category_id = ? AND is_active = 1 ORDER BY created_at DESC LIMIT ?";
        
        try (java.sql.Connection conn = DBConnect.getConnection();
             java.sql.PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, categoryId);
            pstmt.setInt(2, limit);
            
            try (java.sql.ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    AIModel model = new AIModel();
                    model.setId(rs.getInt("id"));
                    model.setModelName(rs.getString("model_name"));
                    model.setProviderName(rs.getString("provider_name"));
                    model.setPurposeSummary(rs.getString("purpose_summary"));
                    model.setPrice(rs.getString("price"));
                    model.setParamsBillion(rs.getString("params_billion"));
                    model.setLatencyMs(rs.getInt("latency_ms"));
                    model.setInputModalities(rs.getString("input_modalities"));
                    model.setOutputModalities(rs.getString("output_modalities"));
                    model.setCategoryId(rs.getInt("category_id"));
                    model.setIsActive(rs.getBoolean("is_active"));
                    model.setCreatedAt(rs.getTimestamp("created_at"));
                    model.setUpdatedAt(rs.getTimestamp("updated_at"));
                    models.add(model);
                }
            }
        } catch (java.sql.SQLException e) {
            e.printStackTrace();
        }
        
        return models;
    }
    
    // 검색 기능
    public List<AIModel> searchModels(String keyword, int categoryId, String provider, int limit) {
        List<AIModel> models = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM ai_models WHERE is_active = 1");
        List<Object> params = new ArrayList<>();
        
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (model_name LIKE ? OR purpose_summary LIKE ? OR provider_name LIKE ?)");
            String searchPattern = "%" + keyword.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
        }
        
        if (categoryId > 0) {
            sql.append(" AND category_id = ?");
            params.add(categoryId);
        }
        
        if (provider != null && !provider.trim().isEmpty()) {
            sql.append(" AND provider_name = ?");
            params.add(provider);
        }
        
        sql.append(" ORDER BY created_at DESC LIMIT ?");
        params.add(limit);
        
        try (java.sql.Connection conn = DBConnect.getConnection();
             java.sql.PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {
            
            for (int i = 0; i < params.size(); i++) {
                pstmt.setObject(i + 1, params.get(i));
            }
            
            try (java.sql.ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    AIModel model = new AIModel();
                    model.setId(rs.getInt("id"));
                    model.setModelName(rs.getString("model_name"));
                    model.setProviderName(rs.getString("provider_name"));
                    model.setPurposeSummary(rs.getString("purpose_summary"));
                    model.setPrice(rs.getString("price"));
                    model.setParamsBillion(rs.getString("params_billion"));
                    model.setLatencyMs(rs.getInt("latency_ms"));
                    model.setInputModalities(rs.getString("input_modalities"));
                    model.setOutputModalities(rs.getString("output_modalities"));
                    model.setCategoryId(rs.getInt("category_id"));
                    model.setIsActive(rs.getBoolean("is_active"));
                    model.setCreatedAt(rs.getTimestamp("created_at"));
                    model.setUpdatedAt(rs.getTimestamp("updated_at"));
                    models.add(model);
                }
            }
        } catch (java.sql.SQLException e) {
            e.printStackTrace();
        }
        
        return models;
    }
    
    // 모델 상세 정보 가져오기
    public AIModel getModelById(int id) {
        String sql = "SELECT * FROM ai_models WHERE id = ?";
        
        try (java.sql.Connection conn = DBConnect.getConnection();
             java.sql.PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, id);
            
            try (java.sql.ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    AIModel model = new AIModel();
                    model.setId(rs.getInt("id"));
                    model.setModelName(rs.getString("model_name"));
                    model.setProviderName(rs.getString("provider_name"));
                    model.setPurposeSummary(rs.getString("purpose_summary"));
                    model.setPrice(rs.getString("price"));
                    model.setParamsBillion(rs.getString("params_billion"));
                    model.setLatencyMs(rs.getInt("latency_ms"));
                    model.setInputModalities(rs.getString("input_modalities"));
                    model.setOutputModalities(rs.getString("output_modalities"));
                    model.setCategoryId(rs.getInt("category_id"));
                    model.setIsActive(rs.getBoolean("is_active"));
                    model.setCreatedAt(rs.getTimestamp("created_at"));
                    model.setUpdatedAt(rs.getTimestamp("updated_at"));
                    return model;
                }
            }
        } catch (java.sql.SQLException e) {
            e.printStackTrace();
        }
        
        return null;
    }
    
    // 모델 추가
    public boolean addModel(AIModel model) {
        String sql = "INSERT INTO ai_models (model_name, provider_name, purpose_summary, price, params_billion, " +
                    "latency_ms, input_modalities, output_modalities, category_id, is_active) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (java.sql.Connection conn = DBConnect.getConnection();
             java.sql.PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, model.getModelName());
            pstmt.setString(2, model.getProviderName());
            pstmt.setString(3, model.getPurposeSummary());
            pstmt.setString(4, model.getPrice());
            pstmt.setString(5, model.getParamsBillion());
            pstmt.setInt(6, model.getLatencyMs());
            pstmt.setString(7, model.getInputModalities());
            pstmt.setString(8, model.getOutputModalities());
            pstmt.setInt(9, model.getCategoryId());
            pstmt.setBoolean(10, model.isActive());
            
            int result = pstmt.executeUpdate();
            return result > 0;
            
        } catch (java.sql.SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    // 모델 업데이트
    public boolean updateModel(AIModel model) {
        String sql = "UPDATE ai_models SET model_name = ?, provider_name = ?, purpose_summary = ?, " +
                    "price = ?, params_billion = ?, latency_ms = ?, input_modalities = ?, " +
                    "output_modalities = ?, category_id = ?, is_active = ?, updated_at = CURRENT_TIMESTAMP " +
                    "WHERE id = ?";
        
        try (java.sql.Connection conn = DBConnect.getConnection();
             java.sql.PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, model.getModelName());
            pstmt.setString(2, model.getProviderName());
            pstmt.setString(3, model.getPurposeSummary());
            pstmt.setString(4, model.getPrice());
            pstmt.setString(5, model.getParamsBillion());
            pstmt.setInt(6, model.getLatencyMs());
            pstmt.setString(7, model.getInputModalities());
            pstmt.setString(8, model.getOutputModalities());
            pstmt.setInt(9, model.getCategoryId());
            pstmt.setBoolean(10, model.isActive());
            pstmt.setInt(11, model.getId());
            
            int result = pstmt.executeUpdate();
            return result > 0;
            
        } catch (java.sql.SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    // 모델 삭제 (비활성화)
    public boolean deleteModel(int id) {
        String sql = "UPDATE ai_models SET is_active = 0 WHERE id = ?";
        
        try (java.sql.Connection conn = DBConnect.getConnection();
             java.sql.PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, id);
            
            int result = pstmt.executeUpdate();
            return result > 0;
            
        } catch (java.sql.SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    // 전체 모델 수 가져오기
    public int getTotalModelCount() {
        String sql = "SELECT COUNT(*) FROM ai_models WHERE is_active = 1";
        
        try (java.sql.Connection conn = DBConnect.getConnection();
             java.sql.PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            try (java.sql.ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (java.sql.SQLException e) {
            e.printStackTrace();
        }
        
        return 0;
    }
    
    // 카테고리별 모델 수 가져오기
    public int getModelCountByCategory(int categoryId) {
        String sql = "SELECT COUNT(*) FROM ai_models WHERE category_id = ? AND is_active = 1";
        
        try (java.sql.Connection conn = DBConnect.getConnection();
             java.sql.PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, categoryId);
            
            try (java.sql.ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (java.sql.SQLException e) {
            e.printStackTrace();
        }
        
        return 0;
    }
}
