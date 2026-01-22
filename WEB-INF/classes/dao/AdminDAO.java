package dao;

import db.DBConnect;
import model.Admin;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

public class AdminDAO {
  private static final String FIND_BY_USERNAME_SQL =
      "SELECT id, username, password, name, email, role, status, created_at, last_login FROM admins WHERE username = ?";
  
  private static final String FIND_ALL_SQL =
      "SELECT id, username, password, name, email, role, status, created_at, last_login FROM admins ORDER BY id ASC";
  
  private static final String FIND_BY_ID_SQL =
      "SELECT id, username, password, name, email, role, status, created_at, last_login FROM admins WHERE id = ?";
  
  private static final String INSERT_SQL =
      "INSERT INTO admins (username, password, name, email, role, status) VALUES (?, ?, ?, ?, ?, ?)";
  
  private static final String UPDATE_SQL =
      "UPDATE admins SET name = ?, email = ?, role = ?, status = ? WHERE id = ?";
  
  private static final String UPDATE_PASSWORD_SQL =
      "UPDATE admins SET password = ? WHERE id = ?";
  
  private static final String DELETE_SQL = "DELETE FROM admins WHERE id = ?";
  
  private static final String UPDATE_LAST_LOGIN_SQL =
      "UPDATE admins SET last_login = ? WHERE id = ?";

  public Admin findByUsername(String username) {
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(FIND_BY_USERNAME_SQL)) {
      ps.setString(1, username);
      try (ResultSet rs = ps.executeQuery()) {
        if (rs.next()) {
          return mapToAdmin(rs);
        }
      }
    } catch (SQLException e) {
      throw new RuntimeException("관리자 정보를 조회하는 동안 오류가 발생했습니다.", e);
    }
    return null;
  }

  public Admin findById(int id) {
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(FIND_BY_ID_SQL)) {
      ps.setInt(1, id);
      try (ResultSet rs = ps.executeQuery()) {
        if (rs.next()) {
          return mapToAdmin(rs);
        }
      }
    } catch (SQLException e) {
      throw new RuntimeException("관리자 정보를 조회하는 동안 오류가 발생했습니다.", e);
    }
    return null;
  }

  public List<Admin> findAll() {
    List<Admin> admins = new ArrayList<>();
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(FIND_ALL_SQL);
         ResultSet rs = ps.executeQuery()) {
      while (rs.next()) {
        admins.add(mapToAdmin(rs));
      }
    } catch (SQLException e) {
      throw new RuntimeException("관리자 목록 조회 중 오류가 발생했습니다.", e);
    }
    return admins;
  }

  public int insert(Admin admin) {
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(INSERT_SQL, PreparedStatement.RETURN_GENERATED_KEYS)) {
      ps.setString(1, admin.getUsername());
      ps.setString(2, admin.getPassword());
      ps.setString(3, admin.getName());
      ps.setString(4, admin.getEmail());
      ps.setString(5, admin.getRole());
      ps.setString(6, admin.getStatus());
      
      int result = ps.executeUpdate();
      if (result > 0) {
        try (ResultSet rs = ps.getGeneratedKeys()) {
          if (rs.next()) {
            return rs.getInt(1);
          }
        }
      }
    } catch (SQLException e) {
      throw new RuntimeException("관리자 등록 중 오류가 발생했습니다.", e);
    }
    return -1;
  }

  public boolean update(Admin admin) {
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(UPDATE_SQL)) {
      ps.setString(1, admin.getName());
      ps.setString(2, admin.getEmail());
      ps.setString(3, admin.getRole());
      ps.setString(4, admin.getStatus());
      ps.setInt(5, admin.getId());
      
      return ps.executeUpdate() > 0;
    } catch (SQLException e) {
      throw new RuntimeException("관리자 수정 중 오류가 발생했습니다.", e);
    }
  }

  public boolean updatePassword(int id, String password) {
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(UPDATE_PASSWORD_SQL)) {
      ps.setString(1, password);
      ps.setInt(2, id);
      
      return ps.executeUpdate() > 0;
    } catch (SQLException e) {
      throw new RuntimeException("비밀번호 변경 중 오류가 발생했습니다.", e);
    }
  }

  public boolean delete(int id) {
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(DELETE_SQL)) {
      ps.setInt(1, id);
      return ps.executeUpdate() > 0;
    } catch (SQLException e) {
      throw new RuntimeException("관리자 삭제 중 오류가 발생했습니다.", e);
    }
  }

  public void updateLastLogin(int id) {
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(UPDATE_LAST_LOGIN_SQL)) {
      // 한국 시간대(Asia/Seoul, UTC+9)로 현재 시간 가져오기
      ZonedDateTime koreaTime = ZonedDateTime.now(ZoneId.of("Asia/Seoul"));
      Timestamp koreaTimestamp = Timestamp.from(koreaTime.toInstant());
      
      // 한국 시간을 직접 설정
      ps.setTimestamp(1, koreaTimestamp);
      ps.setInt(2, id);
      ps.executeUpdate();
    } catch (SQLException e) {
      // 로그인 시간 업데이트 실패는 무시
      e.printStackTrace();
    }
  }

  private Admin mapToAdmin(ResultSet rs) throws SQLException {
    Admin admin = new Admin();
    admin.setId(rs.getInt("id"));
    admin.setUsername(rs.getString("username"));
    admin.setPassword(rs.getString("password"));
    admin.setName(rs.getString("name"));
    admin.setEmail(rs.getString("email"));
    admin.setRole(rs.getString("role"));
    admin.setStatus(rs.getString("status"));
    admin.setCreatedAt(rs.getString("created_at"));
    admin.setLastLogin(rs.getString("last_login"));
    return admin;
  }
}
