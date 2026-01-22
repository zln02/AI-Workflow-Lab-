package dao;

import db.DBConnect;
import model.Category;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class CategoryDAO {
  private static final String FIND_ALL_SQL = "SELECT id, category_name FROM categories ORDER BY id ASC";
  private static final String FIND_BY_ID_SQL = "SELECT id, category_name FROM categories WHERE id = ?";

  public List<Category> findAll() {
    List<Category> categories = new ArrayList<>();
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(FIND_ALL_SQL);
         ResultSet rs = ps.executeQuery()) {
      while (rs.next()) {
        categories.add(mapToCategory(rs));
      }
    } catch (SQLException e) {
      throw new RuntimeException("카테고리 목록 조회 중 오류가 발생했습니다.", e);
    }
    return categories;
  }

  public Category findById(int id) {
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(FIND_BY_ID_SQL)) {
      ps.setInt(1, id);
      try (ResultSet rs = ps.executeQuery()) {
        if (rs.next()) {
          return mapToCategory(rs);
        }
      }
    } catch (SQLException e) {
      throw new RuntimeException("카테고리 조회 중 오류가 발생했습니다.", e);
    }
    return null;
  }

  private static final String INSERT_SQL = "INSERT INTO categories (category_name) VALUES (?)";
  private static final String UPDATE_SQL = "UPDATE categories SET category_name = ? WHERE id = ?";
  private static final String DELETE_SQL = "DELETE FROM categories WHERE id = ?";

  public int insert(Category category) {
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(INSERT_SQL, PreparedStatement.RETURN_GENERATED_KEYS)) {
      ps.setString(1, category.getCategoryName());
      
      int result = ps.executeUpdate();
      if (result > 0) {
        try (ResultSet rs = ps.getGeneratedKeys()) {
          if (rs.next()) {
            return rs.getInt(1);
          }
        }
      }
    } catch (SQLException e) {
      throw new RuntimeException("카테고리 등록 중 오류가 발생했습니다.", e);
    }
    return -1;
  }

  public boolean update(Category category) {
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(UPDATE_SQL)) {
      ps.setString(1, category.getCategoryName());
      ps.setInt(2, category.getId());
      
      return ps.executeUpdate() > 0;
    } catch (SQLException e) {
      throw new RuntimeException("카테고리 수정 중 오류가 발생했습니다.", e);
    }
  }

  public boolean delete(int id) {
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(DELETE_SQL)) {
      ps.setInt(1, id);
      return ps.executeUpdate() > 0;
    } catch (SQLException e) {
      throw new RuntimeException("카테고리 삭제 중 오류가 발생했습니다.", e);
    }
  }

  private Category mapToCategory(ResultSet rs) throws SQLException {
    Category category = new Category();
    category.setId(rs.getInt("id"));
    category.setCategoryName(rs.getString("category_name"));
    return category;
  }
}

