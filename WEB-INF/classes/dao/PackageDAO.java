package dao;

import db.DBConnect;
import model.Package;
import model.PackageItem;
import model.AIModel;
import model.Category;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class PackageDAO {
  // 실제 DB 컬럼명 확인 및 캐싱
  private static String priceColumn = null;
  private static String discountPriceColumn = null;
  private static Boolean hasCategoryIdColumn = null;
  
  // 실제 DB 테이블 구조 확인
  private void detectColumnNames() {
    if (priceColumn != null) return; // 이미 확인됨
    
    try (Connection conn = DBConnect.getConnection()) {
      DatabaseMetaData metaData = conn.getMetaData();
      ResultSet columns = metaData.getColumns(null, null, "packages", null);
      Set<String> availableColumns = new HashSet<>();
      List<String> allColumnNames = new ArrayList<>();
      while (columns.next()) {
        String colName = columns.getString("COLUMN_NAME");
        availableColumns.add(colName.toLowerCase());
        allColumnNames.add(colName);
        System.out.println("Found column: " + colName);
      }
      
      // 실제 컬럼 목록 출력
      System.err.println("=== Available columns in packages table ===");
      for (String col : allColumnNames) {
        System.err.println("  - " + col);
      }
      System.err.println("=============================================");
      
      // 실제 DB 컬럼명: price_usd, discount_usd, is_active
      // price 컬럼 찾기
      if (availableColumns.contains("price_usd")) {
        priceColumn = "price_usd";
      } else if (availableColumns.contains("price")) {
        priceColumn = "price";
      } else {
        // 대안 시도
        for (String col : allColumnNames) {
          String colLower = col.toLowerCase();
          if (colLower.contains("price_usd") || colLower.equals("price")) {
            priceColumn = col;
            break;
          }
        }
        if (priceColumn == null) {
          System.err.println("ERROR: Could not find price column. Available columns: " + allColumnNames);
          priceColumn = "price_usd"; // 기본값
        }
      }
      System.out.println("Using price column: " + priceColumn);
      
      // discount_price 컬럼 찾기
      if (availableColumns.contains("discount_usd")) {
        discountPriceColumn = "discount_usd";
      } else if (availableColumns.contains("discount_price")) {
        discountPriceColumn = "discount_price";
      } else {
        // 대안 시도
        for (String col : allColumnNames) {
          String colLower = col.toLowerCase();
          if (colLower.contains("discount_usd") || colLower.contains("discount_price")) {
            discountPriceColumn = col;
            break;
          }
        }
      }
      if (discountPriceColumn != null) {
        System.out.println("Using discount_price column: " + discountPriceColumn);
      }
      
      // category_id 컬럼 존재 여부 확인
      hasCategoryIdColumn = availableColumns.contains("category_id");
      System.out.println("Has category_id column: " + hasCategoryIdColumn);
      
    } catch (SQLException e) {
      System.err.println("Error detecting table structure: " + e.getMessage());
      e.printStackTrace();
      // 기본값 사용
      priceColumn = "price";
      discountPriceColumn = "discount_price";
    }
  }
  
  private String getFindAllSQL() {
    detectColumnNames();
    String categoryIdPart = (hasCategoryIdColumn != null && hasCategoryIdColumn) ? ", category_id" : ", NULL as category_id";
    if (discountPriceColumn != null) {
      return "SELECT id, title, description, " + priceColumn + ", " + discountPriceColumn + 
             categoryIdPart + ", is_active, created_at, updated_at FROM packages ORDER BY id ASC";
    } else {
      return "SELECT id, title, description, " + priceColumn + 
             ", NULL as discount_usd" + categoryIdPart + ", is_active, created_at, updated_at FROM packages ORDER BY id ASC";
    }
  }
  
  private String getFindByIdSQL() {
    detectColumnNames();
    String categoryIdPart = (hasCategoryIdColumn != null && hasCategoryIdColumn) ? ", category_id" : ", NULL as category_id";
    if (discountPriceColumn != null) {
      return "SELECT id, title, description, " + priceColumn + ", " + discountPriceColumn + 
             categoryIdPart + ", is_active, created_at, updated_at FROM packages WHERE id = ?";
    } else {
      return "SELECT id, title, description, " + priceColumn + 
             ", NULL as discount_usd" + categoryIdPart + ", is_active, created_at, updated_at FROM packages WHERE id = ?";
    }
  }
  
  private String getFindByCategorySQL() {
    detectColumnNames();
    // Always use N:N join via package_categories for multi-category support
    String categoryIdPart = ", NULL as category_id";
    if (discountPriceColumn != null) {
      return "SELECT DISTINCT p.id, p.title, p.description, p." + priceColumn + ", p." + discountPriceColumn + 
             categoryIdPart + ", p.is_active, p.created_at, p.updated_at FROM packages p " +
             "INNER JOIN package_categories pc ON pc.package_id = p.id WHERE pc.category_id = ? AND p.is_active = 1 ORDER BY p.created_at DESC";
    } else {
      return "SELECT DISTINCT p.id, p.title, p.description, p." + priceColumn + 
             ", NULL as discount_usd" + categoryIdPart + ", p.is_active, p.created_at, p.updated_at FROM packages p " +
             "INNER JOIN package_categories pc ON pc.package_id = p.id WHERE pc.category_id = ? AND p.is_active = 1 ORDER BY p.created_at DESC";
    }
  }
  
  private String getInsertSQL() {
    detectColumnNames();
    String categoryIdPart = (hasCategoryIdColumn != null && hasCategoryIdColumn) ? ", category_id" : "";
    String categoryIdValue = (hasCategoryIdColumn != null && hasCategoryIdColumn) ? ", ?" : "";
    if (discountPriceColumn != null) {
      return "INSERT INTO packages (title, description, " + priceColumn + ", " + discountPriceColumn + categoryIdPart + ", is_active) VALUES (?, ?, ?, ?" + categoryIdValue + ", ?)";
    } else {
      return "INSERT INTO packages (title, description, " + priceColumn + categoryIdPart + ", is_active) VALUES (?, ?, ?" + categoryIdValue + ", ?)";
    }
  }
  
  private String getUpdateSQL() {
    detectColumnNames();
    String categoryIdPart = (hasCategoryIdColumn != null && hasCategoryIdColumn) ? ", category_id = ?" : "";
    if (discountPriceColumn != null) {
      return "UPDATE packages SET title = ?, description = ?, " + priceColumn + " = ?, " + discountPriceColumn + " = ?" + categoryIdPart + ", is_active = ? WHERE id = ?";
    } else {
      return "UPDATE packages SET title = ?, description = ?, " + priceColumn + " = ?" + categoryIdPart + ", is_active = ? WHERE id = ?";
    }
  }
  
  private static final String DELETE_SQL = "DELETE FROM packages WHERE id = ?";

  public List<Package> findAll() {
    List<Package> packages = new ArrayList<>();
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(getFindAllSQL());
         ResultSet rs = ps.executeQuery()) {
      while (rs.next()) {
        packages.add(mapToPackage(rs));
      }
    } catch (SQLException e) {
      System.err.println("SQL Error: " + e.getMessage());
      System.err.println("SQL State: " + e.getSQLState());
      System.err.println("Attempted SQL: " + getFindAllSQL());
      throw new RuntimeException("패키지 목록 조회 중 오류가 발생했습니다: " + e.getMessage(), e);
    }
    return packages;
  }

  /**
   * 홈페이지용 추천 패키지 조회 (제한된 수)
   * @param limit 조회할 패키지 수
   * @return 패키지 목록
   */
  public List<Package> findFeatured(int limit) {
    List<Package> packages = new ArrayList<>();
    detectColumnNames();
    String categoryIdPart = (hasCategoryIdColumn != null && hasCategoryIdColumn) ? ", category_id" : ", NULL as category_id";
    String sql;
    if (discountPriceColumn != null) {
      sql = "SELECT id, title, description, " + priceColumn + ", " + discountPriceColumn + 
            categoryIdPart + ", is_active, created_at, updated_at FROM packages WHERE is_active = 1 ORDER BY created_at DESC LIMIT ?";
    } else {
      sql = "SELECT id, title, description, " + priceColumn + 
            ", NULL as discount_usd" + categoryIdPart + ", is_active, created_at, updated_at FROM packages WHERE is_active = 1 ORDER BY created_at DESC LIMIT ?";
    }
    
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
      ps.setInt(1, limit);
      try (ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
          packages.add(mapToPackage(rs));
        }
      }
    } catch (SQLException e) {
      System.err.println("SQL Error in findFeatured: " + e.getMessage());
      throw new RuntimeException("추천 패키지 조회 중 오류가 발생했습니다.", e);
    }
    return packages;
  }

  /**
   * 여러 패키지의 카테고리를 한 번에 조회 (N+1 쿼리 문제 해결)
   * @param packageIds 패키지 ID 목록
   * @return 패키지 ID를 키로 하는 카테고리 맵
   */
  public java.util.Map<Integer, List<Category>> getCategoriesByPackageIds(java.util.List<Integer> packageIds) {
    java.util.Map<Integer, List<Category>> result = new java.util.HashMap<>();
    if (packageIds == null || packageIds.isEmpty()) {
      return result;
    }
    
    // IN 절을 위한 플레이스홀더 생성
    StringBuilder placeholders = new StringBuilder();
    for (int i = 0; i < packageIds.size(); i++) {
      if (i > 0) placeholders.append(",");
      placeholders.append("?");
    }
    
    String sql = "SELECT pc.package_id, c.id, c.category_name " +
                 "FROM package_categories pc " +
                 "JOIN categories c ON pc.category_id = c.id " +
                 "WHERE pc.package_id IN (" + placeholders.toString() + ") " +
                 "ORDER BY pc.package_id, c.category_name ASC";
    
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
      for (int i = 0; i < packageIds.size(); i++) {
        ps.setInt(i + 1, packageIds.get(i));
      }
      
      try (ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
          int packageId = rs.getInt("package_id");
          Category category = new Category();
          category.setId(rs.getInt("id"));
          category.setCategoryName(rs.getString("category_name"));
          
          result.computeIfAbsent(packageId, k -> new java.util.ArrayList<>()).add(category);
        }
      }
    } catch (SQLException e) {
      System.err.println("Error getting categories for packages: " + e.getMessage());
      throw new RuntimeException("패키지 카테고리 일괄 조회 중 오류가 발생했습니다.", e);
    }
    
    return result;
  }

  public Package findById(int id) {
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(getFindByIdSQL())) {
      ps.setInt(1, id);
      try (ResultSet rs = ps.executeQuery()) {
        if (rs.next()) {
          Package pkg = mapToPackage(rs);
          pkg.setItems(findItemsByPackageId(id));
          // 카테고리 정보도 함께 로딩
          List<Category> categories = getCategoriesByPackageId(id);
          pkg.setCategories(categories);
          return pkg;
        }
      }
    } catch (SQLException e) {
      System.err.println("SQL Error in findById: " + e.getMessage());
      throw new RuntimeException("패키지 조회 중 오류가 발생했습니다.", e);
    }
    return null;
  }

  public List<Package> findByCategory(int categoryId) {
    List<Package> packages = new ArrayList<>();
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(getFindByCategorySQL())) {
      ps.setInt(1, categoryId);
      try (ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
          packages.add(mapToPackage(rs));
        }
      }
    } catch (SQLException e) {
      System.err.println("SQL Error in findByCategory: " + e.getMessage());
      throw new RuntimeException("카테고리별 패키지 조회 중 오류가 발생했습니다.", e);
    }
    return packages;
  }

  /**
   * 모델 ID로 패키지 찾기 (package_items 테이블 사용)
   * @param modelId 모델 ID
   * @return 해당 모델이 포함된 패키지 목록
   */
  public List<Package> findByModelId(int modelId) {
    List<Package> packages = new ArrayList<>();
    detectColumnNames();
    String categoryIdPart = ", NULL as category_id";
    String sql;
    if (discountPriceColumn != null) {
      sql = "SELECT DISTINCT p.id, p.title, p.description, p." + priceColumn + ", p." + discountPriceColumn + 
            categoryIdPart + ", p.is_active, p.created_at, p.updated_at " +
            "FROM packages p " +
            "INNER JOIN package_items pi ON pi.package_id = p.id " +
            "WHERE pi.model_id = ? AND p.is_active = 1 " +
            "ORDER BY p.created_at DESC";
    } else {
      sql = "SELECT DISTINCT p.id, p.title, p.description, p." + priceColumn + 
            ", NULL as discount_usd" + categoryIdPart + ", p.is_active, p.created_at, p.updated_at " +
            "FROM packages p " +
            "INNER JOIN package_items pi ON pi.package_id = p.id " +
            "WHERE pi.model_id = ? AND p.is_active = 1 " +
            "ORDER BY p.created_at DESC";
    }
    
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
      ps.setInt(1, modelId);
      try (ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
          packages.add(mapToPackage(rs));
        }
      }
    } catch (SQLException e) {
      System.err.println("SQL Error in findByModelId: " + e.getMessage());
      throw new RuntimeException("모델별 패키지 조회 중 오류가 발생했습니다.", e);
    }
    return packages;
  }

  public int insert(Package pkg) {
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(getInsertSQL(), PreparedStatement.RETURN_GENERATED_KEYS)) {
      detectColumnNames();
      ps.setString(1, pkg.getTitle());
      ps.setString(2, pkg.getDescription());
      ps.setBigDecimal(3, pkg.getPrice());
      int paramIndex = 4;
      if (discountPriceColumn != null) {
        ps.setBigDecimal(paramIndex++, pkg.getDiscountPrice());
      }
      if (hasCategoryIdColumn != null && hasCategoryIdColumn) {
        ps.setObject(paramIndex++, pkg.getCategoryId());
      }
      ps.setBoolean(paramIndex++, pkg.isActive());
      
      int result = ps.executeUpdate();
      if (result > 0) {
        try (ResultSet rs = ps.getGeneratedKeys()) {
          if (rs.next()) {
            return rs.getInt(1);
          }
        }
      }
    } catch (SQLException e) {
      System.err.println("SQL Error in insert: " + e.getMessage());
      System.err.println("SQL: " + getInsertSQL());
      throw new RuntimeException("패키지 등록 중 오류가 발생했습니다.", e);
    }
    return -1;
  }

  public boolean update(Package pkg) {
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(getUpdateSQL())) {
      detectColumnNames();
      ps.setString(1, pkg.getTitle());
      ps.setString(2, pkg.getDescription());
      ps.setBigDecimal(3, pkg.getPrice());
      int paramIndex = 4;
      if (discountPriceColumn != null) {
        ps.setBigDecimal(paramIndex++, pkg.getDiscountPrice());
      }
      if (hasCategoryIdColumn != null && hasCategoryIdColumn) {
        ps.setObject(paramIndex++, pkg.getCategoryId());
      }
      ps.setBoolean(paramIndex++, pkg.isActive());
      ps.setInt(paramIndex++, pkg.getId());
      
      return ps.executeUpdate() > 0;
    } catch (SQLException e) {
      System.err.println("SQL Error in update: " + e.getMessage());
      System.err.println("SQL: " + getUpdateSQL());
      throw new RuntimeException("패키지 수정 중 오류가 발생했습니다.", e);
    }
  }

  public boolean delete(int id) {
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(DELETE_SQL)) {
      ps.setInt(1, id);
      return ps.executeUpdate() > 0;
    } catch (SQLException e) {
      throw new RuntimeException("패키지 삭제 중 오류가 발생했습니다.", e);
    }
  }

  private Package mapToPackage(ResultSet rs) throws SQLException {
    detectColumnNames();
    Package pkg = new Package();
    pkg.setId(rs.getInt("id"));
    pkg.setTitle(rs.getString("title"));
    pkg.setDescription(rs.getString("description"));
    
    // 동적 컬럼명 사용
    try {
      pkg.setPrice(rs.getBigDecimal(priceColumn));
    } catch (SQLException e) {
      System.err.println("Error reading price column: " + e.getMessage());
      throw e;
    }
    
    if (discountPriceColumn != null) {
      try {
        BigDecimal discountPrice = rs.getBigDecimal(discountPriceColumn);
        if (discountPrice != null) {
          pkg.setDiscountPrice(discountPrice);
        }
      } catch (SQLException e) {
        // discount_price 컬럼이 없을 수 있음
        System.err.println("Warning: discount_price column not found: " + e.getMessage());
      }
    } else {
      // discount_price 컬럼이 없는 경우 NULL로 처리
      try {
        BigDecimal discountPrice = rs.getBigDecimal("discount_price");
        if (discountPrice != null && !rs.wasNull()) {
          pkg.setDiscountPrice(discountPrice);
        }
      } catch (SQLException e) {
        // 무시
      }
    }
    
    // category_id 컬럼이 있으면 읽기, 없으면 NULL 처리
    if (hasCategoryIdColumn != null && hasCategoryIdColumn) {
      try {
        int categoryId = rs.getInt("category_id");
        if (!rs.wasNull()) {
          pkg.setCategoryId(categoryId);
        }
      } catch (SQLException e) {
        // category_id 컬럼이 없으면 무시
      }
    }
    // is_active 컬럼 사용 (active 대신)
    try {
      pkg.setActive(rs.getBoolean("is_active"));
    } catch (SQLException e) {
      // 하위 호환성: active 컬럼도 시도
      try {
        pkg.setActive(rs.getBoolean("active"));
      } catch (SQLException e2) {
        pkg.setActive(true); // 기본값
      }
    }
    pkg.setCreatedAt(rs.getString("created_at"));
    pkg.setUpdatedAt(rs.getString("updated_at"));
    return pkg;
  }

  private List<PackageItem> findItemsByPackageId(int packageId) {
    PackageItemDAO itemDAO = new PackageItemDAO();
    return itemDAO.findByPackageId(packageId);
  }

  // 패키지의 카테고리 목록 조회
  public List<Category> getCategoriesByPackageId(int packageId) {
    List<Category> categories = new ArrayList<>();
    String sql = "SELECT c.id, c.category_name " +
                 "FROM categories c " +
                 "JOIN package_categories pc ON pc.category_id = c.id " +
                 "WHERE pc.package_id = ? " +
                 "ORDER BY c.category_name ASC";
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
      ps.setInt(1, packageId);
      try (ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
          Category category = new Category();
          category.setId(rs.getInt("id"));
          category.setCategoryName(rs.getString("category_name"));
          categories.add(category);
        }
      }
    } catch (SQLException e) {
      System.err.println("Error getting categories for package: " + e.getMessage());
      throw new RuntimeException("패키지 카테고리 조회 중 오류가 발생했습니다.", e);
    }
    return categories;
  }

  // 패키지 카테고리 저장 (DELETE 후 INSERT)
  public void saveCategories(int packageId, List<Integer> categoryIds) {
    replaceCategories(packageId, categoryIds);
  }

  // 패키지 카테고리 교체 (DELETE 후 INSERT) - alias for saveCategories
  public void replaceCategories(int packageId, List<Integer> categoryIds) {
    String deleteSql = "DELETE FROM package_categories WHERE package_id = ?";
    String insertSql = "INSERT INTO package_categories (package_id, category_id, created_at) VALUES (?, ?, NOW())";
    
    try (Connection conn = DBConnect.getConnection()) {
      conn.setAutoCommit(false);
      
      try {
        // 기존 카테고리 삭제
        try (PreparedStatement deletePs = conn.prepareStatement(deleteSql)) {
          deletePs.setInt(1, packageId);
          deletePs.executeUpdate();
        }
        
        // 새 카테고리 추가
        if (categoryIds != null && !categoryIds.isEmpty()) {
          try (PreparedStatement insertPs = conn.prepareStatement(insertSql)) {
            for (Integer categoryId : categoryIds) {
              if (categoryId != null && categoryId > 0) {
                insertPs.setInt(1, packageId);
                insertPs.setInt(2, categoryId);
                insertPs.addBatch();
              }
            }
            insertPs.executeBatch();
          }
        }
        
        conn.commit();
      } catch (SQLException e) {
        conn.rollback();
        throw e;
      } finally {
        conn.setAutoCommit(true);
      }
    } catch (SQLException e) {
      System.err.println("Error replacing package categories: " + e.getMessage());
      throw new RuntimeException("패키지 카테고리 교체 중 오류가 발생했습니다.", e);
    }
  }
}

