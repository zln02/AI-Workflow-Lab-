package dao;

import db.DBConnect;
import model.PackageItem;
import model.AIModel;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class PackageItemDAO {
  private static final String FIND_BY_PACKAGE_ID_SQL =
      "SELECT pi.id, pi.package_id, pi.model_id, pi.quantity, pi.created_at, " +
      "am.id as model_id_full, am.model_name, am.price as model_price, am.description as model_description, " +
      "am.category_id, am.provider_id " +
      "FROM package_items pi " +
      "LEFT JOIN ai_models am ON pi.model_id = am.id " +
      "WHERE pi.package_id = ? ORDER BY pi.id";
  
  private static final String INSERT_SQL =
      "INSERT INTO package_items (package_id, model_id, quantity) VALUES (?, ?, ?)";
  
  private static final String UPDATE_SQL =
      "UPDATE package_items SET model_id = ?, quantity = ? WHERE id = ?";
  
  private static final String DELETE_SQL = "DELETE FROM package_items WHERE id = ?";
  
  private static final String DELETE_BY_PACKAGE_ID_SQL = "DELETE FROM package_items WHERE package_id = ?";

  public List<PackageItem> findByPackageId(int packageId) {
    List<PackageItem> items = new ArrayList<>();
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(FIND_BY_PACKAGE_ID_SQL)) {
      ps.setInt(1, packageId);
      try (ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
          items.add(mapToPackageItem(rs));
        }
      }
    } catch (SQLException e) {
      throw new RuntimeException("패키지 아이템 조회 중 오류가 발생했습니다.", e);
    }
    return items;
  }

  public boolean insert(PackageItem item) {
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(INSERT_SQL)) {
      ps.setInt(1, item.getPackageId());
      ps.setInt(2, item.getModelId());
      ps.setInt(3, item.getQuantity());
      
      return ps.executeUpdate() > 0;
    } catch (SQLException e) {
      throw new RuntimeException("패키지 아이템 등록 중 오류가 발생했습니다.", e);
    }
  }

  public boolean update(PackageItem item) {
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(UPDATE_SQL)) {
      ps.setInt(1, item.getModelId());
      ps.setInt(2, item.getQuantity());
      ps.setInt(3, item.getId());
      
      return ps.executeUpdate() > 0;
    } catch (SQLException e) {
      throw new RuntimeException("패키지 아이템 수정 중 오류가 발생했습니다.", e);
    }
  }

  public boolean delete(int id) {
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(DELETE_SQL)) {
      ps.setInt(1, id);
      return ps.executeUpdate() > 0;
    } catch (SQLException e) {
      throw new RuntimeException("패키지 아이템 삭제 중 오류가 발생했습니다.", e);
    }
  }

  public boolean deleteByPackageId(int packageId) {
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(DELETE_BY_PACKAGE_ID_SQL)) {
      ps.setInt(1, packageId);
      return ps.executeUpdate() > 0;
    } catch (SQLException e) {
      throw new RuntimeException("패키지 아이템 일괄 삭제 중 오류가 발생했습니다.", e);
    }
  }

  private PackageItem mapToPackageItem(ResultSet rs) throws SQLException {
    PackageItem item = new PackageItem();
    item.setId(rs.getInt("id"));
    item.setPackageId(rs.getInt("package_id"));
    item.setModelId(rs.getInt("model_id"));
    item.setQuantity(rs.getInt("quantity"));
    item.setCreatedAt(rs.getString("created_at"));
    
    // AI 모델 정보 매핑
    try {
      AIModel model = new AIModel();
      model.setId(rs.getInt("model_id_full"));
      model.setModelName(rs.getString("model_name"));
      model.setPrice(rs.getString("model_price"));
      model.setDescription(rs.getString("model_description"));
      int categoryId = rs.getInt("category_id");
      if (!rs.wasNull()) {
        model.setCategoryId(categoryId);
      }
      int providerId = rs.getInt("provider_id");
      if (!rs.wasNull()) {
        model.setProviderId(providerId);
      }
      item.setModel(model);
    } catch (SQLException e) {
      // 모델 정보가 없어도 계속 진행
    }
    
    return item;
  }
}

