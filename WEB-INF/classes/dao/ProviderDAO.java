package dao;

import db.DBConnect;
import model.Provider;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ProviderDAO {
  private static final String FIND_ALL_SQL = 
      "SELECT id, provider_name, website, country, created_at FROM providers ORDER BY id ASC";
  private static final String FIND_BY_ID_SQL = 
      "SELECT id, provider_name, website, country, created_at FROM providers WHERE id = ?";
  private static final String INSERT_SQL = 
      "INSERT INTO providers (provider_name, website, country) VALUES (?, ?, ?)";
  private static final String UPDATE_SQL = 
      "UPDATE providers SET provider_name = ?, website = ?, country = ? WHERE id = ?";
  private static final String DELETE_SQL = "DELETE FROM providers WHERE id = ?";

  public List<Provider> findAll() {
    List<Provider> providers = new ArrayList<>();
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(FIND_ALL_SQL);
         ResultSet rs = ps.executeQuery()) {
      while (rs.next()) {
        providers.add(mapToProvider(rs));
      }
    } catch (SQLException e) {
      throw new RuntimeException("제공사 목록 조회 중 오류가 발생했습니다.", e);
    }
    return providers;
  }

  public Provider findById(int id) {
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(FIND_BY_ID_SQL)) {
      ps.setInt(1, id);
      try (ResultSet rs = ps.executeQuery()) {
        if (rs.next()) {
          return mapToProvider(rs);
        }
      }
    } catch (SQLException e) {
      throw new RuntimeException("제공사 조회 중 오류가 발생했습니다.", e);
    }
    return null;
  }

  public int insert(Provider provider) {
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(INSERT_SQL, PreparedStatement.RETURN_GENERATED_KEYS)) {
      ps.setString(1, provider.getProviderName());
      ps.setString(2, provider.getWebsite());
      ps.setString(3, provider.getCountry());
      
      int result = ps.executeUpdate();
      if (result > 0) {
        try (ResultSet rs = ps.getGeneratedKeys()) {
          if (rs.next()) {
            return rs.getInt(1);
          }
        }
      }
    } catch (SQLException e) {
      throw new RuntimeException("제공사 등록 중 오류가 발생했습니다.", e);
    }
    return -1;
  }

  public boolean update(Provider provider) {
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(UPDATE_SQL)) {
      ps.setString(1, provider.getProviderName());
      ps.setString(2, provider.getWebsite());
      ps.setString(3, provider.getCountry());
      ps.setInt(4, provider.getId());
      
      return ps.executeUpdate() > 0;
    } catch (SQLException e) {
      throw new RuntimeException("제공사 수정 중 오류가 발생했습니다.", e);
    }
  }

  public boolean delete(int id) {
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(DELETE_SQL)) {
      ps.setInt(1, id);
      return ps.executeUpdate() > 0;
    } catch (SQLException e) {
      throw new RuntimeException("제공사 삭제 중 오류가 발생했습니다.", e);
    }
  }

  private Provider mapToProvider(ResultSet rs) throws SQLException {
    Provider provider = new Provider();
    provider.setId(rs.getInt("id"));
    provider.setProviderName(rs.getString("provider_name"));
    provider.setWebsite(rs.getString("website"));
    provider.setCountry(rs.getString("country"));
    provider.setCreatedAt(rs.getString("created_at"));
    return provider;
  }
}

