package dao;

import db.DBConnect;
import model.AIModel;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * AI 모델 데이터 접근 객체
 * AI 모델의 CRUD 작업을 담당하는 DAO 클래스
 */
public class AIModelDAO {
  private static final String FIND_ALL_SQL =
      "SELECT m.id, m.provider_id, m.category_id, m.model_name, m.price, m.price_usd, m.price_krw, m.description, " +
      "m.purpose_summary, m.input_modalities, m.output_modalities, m.languages, m.benchmarks, " +
      "m.params_billion, m.latency_ms, m.rate_limit_per_min, m.api_available, m.finetune_available, " +
      "m.onprem_available, m.hosting_options, m.license_type, m.commercial_use_allowed, " +
      "m.data_retention, m.privacy_url, m.tos_url, m.homepage_url, m.docs_url, m.playground_url, " +
      "m.max_input_size_mb, m.supported_file_types, m.created_at, " +
      "p.provider_name, c.category_name " +
      "FROM ai_models m " +
      "LEFT JOIN providers p ON m.provider_id = p.id " +
      "LEFT JOIN categories c ON m.category_id = c.id " +
      "ORDER BY m.id ASC";
  
  private static final String FIND_FEATURED_SQL =
      "SELECT m.id, m.provider_id, m.category_id, m.model_name, m.price, m.price_usd, m.price_krw, m.description, " +
      "m.purpose_summary, m.input_modalities, m.output_modalities, m.languages, m.benchmarks, " +
      "m.params_billion, m.latency_ms, m.rate_limit_per_min, m.api_available, m.finetune_available, " +
      "m.onprem_available, m.hosting_options, m.license_type, m.commercial_use_allowed, " +
      "m.data_retention, m.privacy_url, m.tos_url, m.homepage_url, m.docs_url, m.playground_url, " +
      "m.max_input_size_mb, m.supported_file_types, m.created_at, " +
      "p.provider_name, c.category_name " +
      "FROM ai_models m " +
      "LEFT JOIN providers p ON m.provider_id = p.id " +
      "LEFT JOIN categories c ON m.category_id = c.id " +
      "ORDER BY m.created_at DESC, m.id DESC " +
      "LIMIT ?";
  
  private static final String FIND_BY_ID_SQL =
      "SELECT m.id, m.provider_id, m.category_id, m.model_name, m.price, m.price_usd, m.price_krw, m.description, " +
      "m.purpose_summary, m.input_modalities, m.output_modalities, m.languages, m.benchmarks, " +
      "m.params_billion, m.latency_ms, m.rate_limit_per_min, m.api_available, m.finetune_available, " +
      "m.onprem_available, m.hosting_options, m.license_type, m.commercial_use_allowed, " +
      "m.data_retention, m.privacy_url, m.tos_url, m.homepage_url, m.docs_url, m.playground_url, " +
      "m.max_input_size_mb, m.supported_file_types, m.created_at, " +
      "p.provider_name, c.category_name " +
      "FROM ai_models m " +
      "LEFT JOIN providers p ON m.provider_id = p.id " +
      "LEFT JOIN categories c ON m.category_id = c.id " +
      "WHERE m.id = ?";
  
  private static final String FIND_BY_CATEGORY_SQL =
      "SELECT id, provider_id, category_id, model_name, price, description, " +
      "purpose_summary, input_modalities, output_modalities, languages, benchmarks, " +
      "params_billion, latency_ms, rate_limit_per_min, api_available, finetune_available, " +
      "onprem_available, hosting_options, license_type, commercial_use_allowed, " +
      "data_retention, privacy_url, tos_url, homepage_url, docs_url, playground_url, " +
      "max_input_size_mb, supported_file_types, created_at " +
      "FROM ai_models WHERE category_id = ? ORDER BY created_at DESC";

  /**
   * 모든 AI 모델 조회
   * @return AI 모델 목록
   */
  public List<AIModel> findAll() {
    List<AIModel> models = new ArrayList<>();
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(FIND_ALL_SQL);
         ResultSet rs = ps.executeQuery()) {
      while (rs.next()) {
        models.add(mapToAIModel(rs));
      }
    } catch (SQLException e) {
      throw new RuntimeException("AI 모델 목록 조회 중 오류가 발생했습니다.", e);
    }
    return models;
  }

  /**
   * ID로 AI 모델 조회
   * @param id 모델 ID
   * @return AI 모델 객체 (없으면 null)
   */
  public AIModel findById(int id) {
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(FIND_BY_ID_SQL)) {
      ps.setInt(1, id);
      try (ResultSet rs = ps.executeQuery()) {
        if (rs.next()) {
          return mapToAIModel(rs);
        }
      }
    } catch (SQLException e) {
      throw new RuntimeException("AI 모델 조회 중 오류가 발생했습니다: ID=" + id, e);
    }
    return null;
  }

  /**
   * 카테고리별 AI 모델 조회
   * @param categoryId 카테고리 ID
   * @return 해당 카테고리의 AI 모델 목록
   */
  public List<AIModel> findByCategory(int categoryId) {
    List<AIModel> models = new ArrayList<>();
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(FIND_BY_CATEGORY_SQL)) {
      ps.setInt(1, categoryId);
      try (ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
          models.add(mapToAIModel(rs));
        }
      }
    } catch (SQLException e) {
      throw new RuntimeException("카테고리별 AI 모델 조회 중 오류가 발생했습니다: CategoryID=" + categoryId, e);
    }
    return models;
  }

  /**
   * 홈페이지용 추천 모델 조회 (제한된 수)
   * @param limit 조회할 모델 수
   * @return 모델 목록
   */
  public List<AIModel> findFeatured(int limit) {
    List<AIModel> models = new ArrayList<>();
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(FIND_FEATURED_SQL)) {
      ps.setInt(1, limit);
      try (ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
          models.add(mapToAIModel(rs));
        }
      }
    } catch (SQLException e) {
      throw new RuntimeException("추천 AI 모델 조회 중 오류가 발생했습니다.", e);
    }
    return models;
  }

  private static final String INSERT_SQL =
      "INSERT INTO ai_models (provider_id, category_id, model_name, price, price_usd, price_krw, description, " +
      "purpose_summary, input_modalities, output_modalities, languages, benchmarks, " +
      "params_billion, latency_ms, rate_limit_per_min, api_available, finetune_available, " +
      "onprem_available, hosting_options, license_type, commercial_use_allowed, " +
      "data_retention, privacy_url, tos_url, homepage_url, docs_url, playground_url, " +
      "max_input_size_mb, supported_file_types) " +
      "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
  
  private static final String UPDATE_SQL =
      "UPDATE ai_models SET provider_id = ?, category_id = ?, model_name = ?, price = ?, price_usd = ?, price_krw = ?, description = ?, " +
      "purpose_summary = ?, input_modalities = ?, output_modalities = ?, languages = ?, benchmarks = ?, " +
      "params_billion = ?, latency_ms = ?, rate_limit_per_min = ?, api_available = ?, finetune_available = ?, " +
      "onprem_available = ?, hosting_options = ?, license_type = ?, commercial_use_allowed = ?, " +
      "data_retention = ?, privacy_url = ?, tos_url = ?, homepage_url = ?, docs_url = ?, playground_url = ?, " +
      "max_input_size_mb = ?, supported_file_types = ? WHERE id = ?";
  
  private static final String DELETE_SQL = "DELETE FROM ai_models WHERE id = ?";

  /**
   * AI 모델 등록
   * @param model 등록할 AI 모델 객체
   * @return 생성된 모델 ID (실패 시 -1)
   */
  public int insert(AIModel model) {
    if (model == null) {
      throw new IllegalArgumentException("모델 객체가 null입니다.");
    }
    
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(INSERT_SQL, PreparedStatement.RETURN_GENERATED_KEYS)) {
      setModelParameters(ps, model, false);
      
      int result = ps.executeUpdate();
      if (result > 0) {
        try (ResultSet rs = ps.getGeneratedKeys()) {
          if (rs.next()) {
            return rs.getInt(1);
          }
        }
      }
    } catch (SQLException e) {
      throw new RuntimeException("AI 모델 등록 중 오류가 발생했습니다.", e);
    }
    return -1;
  }

  /**
   * AI 모델 수정
   * @param model 수정할 AI 모델 객체
   * @return 수정 성공 여부
   */
  public boolean update(AIModel model) {
    if (model == null || model.getId() <= 0) {
      throw new IllegalArgumentException("유효하지 않은 모델 객체입니다.");
    }
    
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(UPDATE_SQL)) {
      setModelParameters(ps, model, true);
      ps.setInt(30, model.getId()); // Updated index due to added price_usd and price_krw
      
      return ps.executeUpdate() > 0;
    } catch (SQLException e) {
      throw new RuntimeException("AI 모델 수정 중 오류가 발생했습니다: ID=" + model.getId(), e);
    }
  }

  /**
   * AI 모델 삭제
   * @param id 삭제할 모델 ID
   * @return 삭제 성공 여부
   */
  public boolean delete(int id) {
    if (id <= 0) {
      throw new IllegalArgumentException("유효하지 않은 모델 ID입니다: " + id);
    }
    
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(DELETE_SQL)) {
      ps.setInt(1, id);
      return ps.executeUpdate() > 0;
    } catch (SQLException e) {
      throw new RuntimeException("AI 모델 삭제 중 오류가 발생했습니다: ID=" + id, e);
    }
  }

  /**
   * PreparedStatement에 모델 파라미터 설정
   * @param ps PreparedStatement 객체
   * @param model AI 모델 객체
   * @param isUpdate 업데이트 여부
   * @throws SQLException SQL 예외
   */
  private void setModelParameters(PreparedStatement ps, AIModel model, boolean isUpdate) throws SQLException {
    int paramIndex = 1;
    ps.setObject(paramIndex++, model.getProviderId());
    ps.setObject(paramIndex++, model.getCategoryId());
    ps.setString(paramIndex++, model.getModelName());
    ps.setString(paramIndex++, model.getPrice());
    ps.setObject(paramIndex++, model.getPriceUsd());
    ps.setObject(paramIndex++, model.getPriceKrw());
    ps.setString(paramIndex++, model.getDescription());
    ps.setString(paramIndex++, model.getPurposeSummary());
    ps.setString(paramIndex++, model.getInputModalities());
    ps.setString(paramIndex++, model.getOutputModalities());
    ps.setString(paramIndex++, model.getLanguages());
    ps.setString(paramIndex++, model.getBenchmarks());
    ps.setObject(paramIndex++, model.getParamsBillion());
    ps.setObject(paramIndex++, model.getLatencyMs());
    ps.setObject(paramIndex++, model.getRateLimitPerMin());
    ps.setBoolean(paramIndex++, model.isApiAvailable());
    ps.setBoolean(paramIndex++, model.isFinetuneAvailable());
    ps.setBoolean(paramIndex++, model.isOnpremAvailable());
    ps.setString(paramIndex++, model.getHostingOptions());
    ps.setString(paramIndex++, model.getLicenseType());
    ps.setBoolean(paramIndex++, model.isCommercialUseAllowed());
    ps.setString(paramIndex++, model.getDataRetention());
    ps.setString(paramIndex++, model.getPrivacyUrl());
    ps.setString(paramIndex++, model.getTosUrl());
    ps.setString(paramIndex++, model.getHomepageUrl());
    ps.setString(paramIndex++, model.getDocsUrl());
    ps.setString(paramIndex++, model.getPlaygroundUrl());
    ps.setObject(paramIndex++, model.getMaxInputSizeMb());
    ps.setString(paramIndex++, model.getSupportedFileTypes());
  }

  /**
   * ResultSet을 AIModel 객체로 변환
   * @param rs ResultSet 객체
   * @return AIModel 객체
   * @throws SQLException SQL 예외
   */
  private AIModel mapToAIModel(ResultSet rs) throws SQLException {
    AIModel model = new AIModel();
    model.setId(rs.getInt("id"));
    
    int providerId = rs.getInt("provider_id");
    if (!rs.wasNull()) {
      model.setProviderId(providerId);
    }
    
    int categoryId = rs.getInt("category_id");
    if (!rs.wasNull()) {
      model.setCategoryId(categoryId);
    }
    
    model.setModelName(rs.getString("model_name"));
    model.setPrice(rs.getString("price"));
    
    // price_usd and price_krw columns (nullable)
    try {
      java.math.BigDecimal priceUsd = rs.getBigDecimal("price_usd");
      if (!rs.wasNull() && priceUsd != null) {
        model.setPriceUsd(priceUsd);
      }
    } catch (SQLException e) {
      // Column may not exist, ignore
    }
    try {
      Integer priceKrw = rs.getInt("price_krw");
      if (!rs.wasNull() && priceKrw != null) {
        model.setPriceKrw(priceKrw);
      }
    } catch (SQLException e) {
      // Column may not exist, ignore
    }
    
    model.setDescription(rs.getString("description"));
    model.setPurposeSummary(rs.getString("purpose_summary"));
    model.setInputModalities(rs.getString("input_modalities"));
    model.setOutputModalities(rs.getString("output_modalities"));
    model.setLanguages(rs.getString("languages"));
    model.setBenchmarks(rs.getString("benchmarks"));
    
    java.math.BigDecimal paramsBillion = rs.getBigDecimal("params_billion");
    if (paramsBillion != null) {
      model.setParamsBillion(paramsBillion);
    }
    
    int latencyMs = rs.getInt("latency_ms");
    if (!rs.wasNull()) {
      model.setLatencyMs(latencyMs);
    }
    
    int rateLimit = rs.getInt("rate_limit_per_min");
    if (!rs.wasNull()) {
      model.setRateLimitPerMin(rateLimit);
    }
    
    model.setApiAvailable(rs.getBoolean("api_available"));
    model.setFinetuneAvailable(rs.getBoolean("finetune_available"));
    model.setOnpremAvailable(rs.getBoolean("onprem_available"));
    model.setHostingOptions(rs.getString("hosting_options"));
    model.setLicenseType(rs.getString("license_type"));
    model.setCommercialUseAllowed(rs.getBoolean("commercial_use_allowed"));
    model.setDataRetention(rs.getString("data_retention"));
    model.setPrivacyUrl(rs.getString("privacy_url"));
    model.setTosUrl(rs.getString("tos_url"));
    model.setHomepageUrl(rs.getString("homepage_url"));
    model.setDocsUrl(rs.getString("docs_url"));
    model.setPlaygroundUrl(rs.getString("playground_url"));
    
    java.math.BigDecimal maxInputSize = rs.getBigDecimal("max_input_size_mb");
    if (maxInputSize != null) {
      model.setMaxInputSizeMb(maxInputSize);
    }
    
    model.setSupportedFileTypes(rs.getString("supported_file_types"));
    model.setCreatedAt(rs.getString("created_at"));
    
    // 조인된 제공사 이름과 카테고리 이름 설정
    try {
      model.setProviderName(rs.getString("provider_name"));
    } catch (SQLException e) {
      // provider_name 컬럼이 없을 수 있음 (기존 쿼리 호환성)
    }
    try {
      model.setCategoryName(rs.getString("category_name"));
    } catch (SQLException e) {
      // category_name 컬럼이 없을 수 있음 (기존 쿼리 호환성)
    }
    
    return model;
  }
}

