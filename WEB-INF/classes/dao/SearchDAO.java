package dao;

import db.DBConnect;
import model.AIModel;
import model.Package;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class SearchDAO {
  private static final String SEARCH_MODELS_SQL =
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
      "WHERE (m.model_name LIKE ? OR m.description LIKE ? OR m.purpose_summary LIKE ? " +
      "OR c.category_name LIKE ? OR p.provider_name LIKE ?) " +
      "ORDER BY m.id ASC LIMIT 50";
  
  private static final String SEARCH_PACKAGES_SQL =
      "SELECT DISTINCT p.id, p.title, p.description, p.price_usd, p.discount_usd, p.is_active, p.created_at, p.updated_at " +
      "FROM packages p " +
      "LEFT JOIN package_categories pc ON pc.package_id = p.id " +
      "LEFT JOIN categories c ON c.id = pc.category_id " +
      "WHERE p.is_active = 1 " +
      "AND (p.title LIKE ? OR p.description LIKE ? OR c.category_name LIKE ?) " +
      "ORDER BY p.created_at DESC LIMIT 20";
  
  private static final String SEARCH_BY_INTENT_SQL =
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
      "WHERE c.category_name LIKE ? " +
      "ORDER BY m.id ASC LIMIT 20";

  /**
   * 모델 검색
   * @param query 검색어
   * @return 모델 목록
   */
  public List<AIModel> searchModels(String query) {
    return searchModels(query, null);
  }

  /**
   * 모델 검색 (의도 포함)
   * @param query 검색어
   * @param intent 의도 (선택)
   * @return 모델 목록
   */
  public List<AIModel> searchModels(String query, String intent) {
    List<AIModel> models = new ArrayList<>();
    
    try (Connection conn = DBConnect.getConnection()) {
      PreparedStatement ps;
      
      if (intent != null && !intent.isEmpty() && !intent.equals("general")) {
        // 의도 기반 검색
        String intentPattern = getIntentPattern(intent);
        ps = conn.prepareStatement(SEARCH_BY_INTENT_SQL);
        ps.setString(1, "%" + intentPattern + "%");
      } else {
        // 일반 검색
        String searchPattern = "%" + query + "%";
        ps = conn.prepareStatement(SEARCH_MODELS_SQL);
        ps.setString(1, searchPattern);
        ps.setString(2, searchPattern);
        ps.setString(3, searchPattern);
        ps.setString(4, searchPattern);
        ps.setString(5, searchPattern);
      }
      
      try (ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
          // ResultSet에서 직접 매핑 (N+1 쿼리 문제 해결)
          AIModel model = mapToAIModel(rs);
          if (model != null) {
            models.add(model);
          }
        }
      }
    } catch (SQLException e) {
      System.err.println("SQL Error in searchModels: " + e.getMessage());
      throw new RuntimeException("모델 검색 중 오류가 발생했습니다.", e);
    }
    return models;
  }

  /**
   * 패키지 검색
   * @param query 검색어
   * @return 패키지 목록
   */
  public List<Package> searchPackages(String query) {
    return searchPackages(query, null);
  }

  /**
   * 패키지 검색 (의도 포함)
   * @param query 검색어
   * @param intent 의도 (선택)
   * @return 패키지 목록
   */
  public List<Package> searchPackages(String query, String intent) {
    List<Package> packages = new ArrayList<>();
    PackageDAO packageDAO = new PackageDAO();
    
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(SEARCH_PACKAGES_SQL)) {
      String searchPattern = "%" + query + "%";
      ps.setString(1, searchPattern);
      ps.setString(2, searchPattern);
      ps.setString(3, searchPattern);
      
      try (ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
          // PackageDAO의 findById를 사용
          int packageId = rs.getInt("id");
          Package pkg = packageDAO.findById(packageId);
          if (pkg != null) {
            packages.add(pkg);
          }
        }
      }
    } catch (SQLException e) {
      System.err.println("SQL Error in searchPackages: " + e.getMessage());
      throw new RuntimeException("패키지 검색 중 오류가 발생했습니다.", e);
    }
    return packages;
  }

  /**
   * 의도별 카테고리 이름 패턴 반환
   * @param intent 의도
   * @return 카테고리 이름 패턴
   */
  private String getIntentPattern(String intent) {
    switch (intent.toLowerCase()) {
      case "coding":
        return "코드";
      case "writing":
        return "요약";
      case "image":
        return "이미지";
      case "audio":
        return "음성";
      case "data":
        return "데이터";
      default:
        return "";
    }
  }

  /**
   * ResultSet을 AIModel로 매핑 (검색 속도 최적화)
   * @param rs ResultSet
   * @return AIModel
   * @throws SQLException
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

