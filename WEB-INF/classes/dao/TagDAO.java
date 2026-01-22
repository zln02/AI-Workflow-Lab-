package dao;

import db.DBConnect;
import model.Tag;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class TagDAO {
  private static final String FIND_ALL_SQL = "SELECT id, tag_name FROM tags ORDER BY id ASC";
  private static final String FIND_BY_ID_SQL = "SELECT id, tag_name FROM tags WHERE id = ?";
  private static final String INSERT_SQL = "INSERT INTO tags (tag_name) VALUES (?)";
  private static final String UPDATE_SQL = "UPDATE tags SET tag_name = ? WHERE id = ?";
  private static final String DELETE_SQL = "DELETE FROM tags WHERE id = ?";

  public List<Tag> findAll() {
    List<Tag> tags = new ArrayList<>();
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(FIND_ALL_SQL);
         ResultSet rs = ps.executeQuery()) {
      while (rs.next()) {
        tags.add(mapToTag(rs));
      }
    } catch (SQLException e) {
      throw new RuntimeException("태그 목록 조회 중 오류가 발생했습니다.", e);
    }
    return tags;
  }

  public Tag findById(int id) {
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(FIND_BY_ID_SQL)) {
      ps.setInt(1, id);
      try (ResultSet rs = ps.executeQuery()) {
        if (rs.next()) {
          return mapToTag(rs);
        }
      }
    } catch (SQLException e) {
      throw new RuntimeException("태그 조회 중 오류가 발생했습니다.", e);
    }
    return null;
  }

  public int insert(Tag tag) {
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(INSERT_SQL, PreparedStatement.RETURN_GENERATED_KEYS)) {
      ps.setString(1, tag.getTagName());
      
      int result = ps.executeUpdate();
      if (result > 0) {
        try (ResultSet rs = ps.getGeneratedKeys()) {
          if (rs.next()) {
            return rs.getInt(1);
          }
        }
      }
    } catch (SQLException e) {
      throw new RuntimeException("태그 등록 중 오류가 발생했습니다.", e);
    }
    return -1;
  }

  public boolean update(Tag tag) {
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(UPDATE_SQL)) {
      ps.setString(1, tag.getTagName());
      ps.setInt(2, tag.getId());
      
      return ps.executeUpdate() > 0;
    } catch (SQLException e) {
      throw new RuntimeException("태그 수정 중 오류가 발생했습니다.", e);
    }
  }

  public boolean delete(int id) {
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(DELETE_SQL)) {
      ps.setInt(1, id);
      return ps.executeUpdate() > 0;
    } catch (SQLException e) {
      throw new RuntimeException("태그 삭제 중 오류가 발생했습니다.", e);
    }
  }

  private Tag mapToTag(ResultSet rs) throws SQLException {
    Tag tag = new Tag();
    tag.setId(rs.getInt("id"));
    tag.setTagName(rs.getString("tag_name"));
    return tag;
  }
}

