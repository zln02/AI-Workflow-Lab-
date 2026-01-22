package dao;

import db.DBConnect;
import model.User;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {
  private static final String INSERT_SQL = 
      "INSERT INTO users (email, password_hash, name, status) VALUES (?, ?, ?, 'ACTIVE')";
  
  private static final String FIND_BY_EMAIL_SQL = 
      "SELECT id, email, password_hash, name, status, created_at, last_login, updated_at " +
      "FROM users WHERE email = ?";
  
  private static final String FIND_BY_ID_SQL = 
      "SELECT id, email, password_hash, name, status, created_at, last_login, updated_at " +
      "FROM users WHERE id = ?";
  
  private static final String UPDATE_LAST_LOGIN_SQL = 
      "UPDATE users SET last_login = CURRENT_TIMESTAMP WHERE id = ?";
  
  private static final String UPDATE_STATUS_SQL = 
      "UPDATE users SET status = ? WHERE id = ?";
  
  private static final String UPDATE_PASSWORD_SQL = 
      "UPDATE users SET password_hash = ? WHERE id = ?";
  
  private static final String FIND_ALL_SQL = 
      "SELECT id, email, password_hash, name, status, created_at, last_login, updated_at " +
      "FROM users ORDER BY created_at DESC";
  
  private static final String UPDATE_USER_SQL = 
      "UPDATE users SET name = ?, status = ? WHERE id = ?";
  
  private static final String UPDATE_USER_WITH_EMAIL_SQL = 
      "UPDATE users SET name = ?, email = ?, status = ? WHERE id = ?";
  
  private static final String DELETE_USER_SQL = 
      "DELETE FROM users WHERE id = ?";

  /**
   * 사용자 생성
   * @param user 사용자 정보
   * @return 생성된 사용자 ID
   */
  public long createUser(User user) {
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(INSERT_SQL, PreparedStatement.RETURN_GENERATED_KEYS)) {
      ps.setString(1, user.getEmail());
      ps.setString(2, user.getPasswordHash());
      ps.setString(3, user.getName());
      
      int result = ps.executeUpdate();
      if (result > 0) {
        try (ResultSet rs = ps.getGeneratedKeys()) {
          if (rs.next()) {
            return rs.getLong(1);
          }
        }
      }
    } catch (SQLException e) {
      System.err.println("SQL Error in createUser: " + e.getMessage());
      throw new RuntimeException("사용자 등록 중 오류가 발생했습니다.", e);
    }
    return -1;
  }

  /**
   * 이메일로 사용자 조회
   * @param email 이메일
   * @return 사용자 또는 null
   */
  public User findByEmail(String email) {
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(FIND_BY_EMAIL_SQL)) {
      ps.setString(1, email);
      try (ResultSet rs = ps.executeQuery()) {
        if (rs.next()) {
          return mapToUser(rs);
        }
      }
    } catch (SQLException e) {
      System.err.println("SQL Error in findByEmail: " + e.getMessage());
      throw new RuntimeException("사용자 조회 중 오류가 발생했습니다.", e);
    }
    return null;
  }

  /**
   * ID로 사용자 조회
   * @param id 사용자 ID
   * @return 사용자 또는 null
   */
  public User findById(long id) {
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(FIND_BY_ID_SQL)) {
      ps.setLong(1, id);
      try (ResultSet rs = ps.executeQuery()) {
        if (rs.next()) {
          return mapToUser(rs);
        }
      }
    } catch (SQLException e) {
      System.err.println("SQL Error in findById: " + e.getMessage());
      throw new RuntimeException("사용자 조회 중 오류가 발생했습니다.", e);
    }
    return null;
  }

  /**
   * 마지막 로그인 시간 업데이트
   * @param userId 사용자 ID
   * @return 업데이트 성공 여부
   */
  public boolean updateLastLogin(long userId) {
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(UPDATE_LAST_LOGIN_SQL)) {
      ps.setLong(1, userId);
      return ps.executeUpdate() > 0;
    } catch (SQLException e) {
      System.err.println("SQL Error in updateLastLogin: " + e.getMessage());
      throw new RuntimeException("로그인 시간 업데이트 중 오류가 발생했습니다.", e);
    }
  }

  /**
   * 사용자 상태 업데이트
   * @param userId 사용자 ID
   * @param status 새 상태
   * @return 업데이트 성공 여부
   */
  public boolean updateStatus(long userId, String status) {
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(UPDATE_STATUS_SQL)) {
      ps.setString(1, status);
      ps.setLong(2, userId);
      return ps.executeUpdate() > 0;
    } catch (SQLException e) {
      System.err.println("SQL Error in updateStatus: " + e.getMessage());
      throw new RuntimeException("사용자 상태 업데이트 중 오류가 발생했습니다.", e);
    }
  }

  /**
   * 비밀번호 변경
   * @param userId 사용자 ID
   * @param passwordHash 해시된 새 비밀번호
   * @return 업데이트 성공 여부
   */
  public boolean updatePassword(long userId, String passwordHash) {
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(UPDATE_PASSWORD_SQL)) {
      ps.setString(1, passwordHash);
      ps.setLong(2, userId);
      return ps.executeUpdate() > 0;
    } catch (SQLException e) {
      System.err.println("SQL Error in updatePassword: " + e.getMessage());
      throw new RuntimeException("비밀번호 변경 중 오류가 발생했습니다.", e);
    }
  }

  /**
   * 모든 사용자 조회
   * @return 사용자 목록
   */
  public List<User> findAll() {
    List<User> users = new ArrayList<>();
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(FIND_ALL_SQL);
         ResultSet rs = ps.executeQuery()) {
      while (rs.next()) {
        users.add(mapToUser(rs));
      }
    } catch (SQLException e) {
      System.err.println("SQL Error in findAll: " + e.getMessage());
      throw new RuntimeException("사용자 목록 조회 중 오류가 발생했습니다.", e);
    }
    return users;
  }

  /**
   * 사용자 정보 업데이트
   * @param userId 사용자 ID
   * @param name 이름
   * @param status 상태
   * @return 업데이트 성공 여부
   */
  public boolean updateUser(long userId, String name, String status) {
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(UPDATE_USER_SQL)) {
      ps.setString(1, name);
      ps.setString(2, status);
      ps.setLong(3, userId);
      return ps.executeUpdate() > 0;
    } catch (SQLException e) {
      System.err.println("SQL Error in updateUser: " + e.getMessage());
      throw new RuntimeException("사용자 정보 업데이트 중 오류가 발생했습니다.", e);
    }
  }

  /**
   * 사용자 정보 업데이트 (이메일 포함)
   * @param userId 사용자 ID
   * @param name 이름
   * @param email 이메일
   * @param status 상태
   * @return 업데이트 성공 여부
   */
  public boolean updateUser(long userId, String name, String email, String status) {
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(UPDATE_USER_WITH_EMAIL_SQL)) {
      ps.setString(1, name);
      ps.setString(2, email);
      ps.setString(3, status);
      ps.setLong(4, userId);
      return ps.executeUpdate() > 0;
    } catch (SQLException e) {
      System.err.println("SQL Error in updateUser: " + e.getMessage());
      throw new RuntimeException("사용자 정보 업데이트 중 오류가 발생했습니다.", e);
    }
  }

  /**
   * 사용자 삭제
   * @param userId 사용자 ID
   * @return 삭제 성공 여부
   */
  public boolean deleteUser(long userId) {
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(DELETE_USER_SQL)) {
      ps.setLong(1, userId);
      return ps.executeUpdate() > 0;
    } catch (SQLException e) {
      System.err.println("SQL Error in deleteUser: " + e.getMessage());
      throw new RuntimeException("사용자 삭제 중 오류가 발생했습니다.", e);
    }
  }

  /**
   * ResultSet을 User 객체로 매핑
   */
  private User mapToUser(ResultSet rs) throws SQLException {
    User user = new User();
    user.setId(rs.getLong("id"));
    user.setEmail(rs.getString("email"));
    user.setPasswordHash(rs.getString("password_hash"));
    user.setName(rs.getString("name"));
    user.setStatus(rs.getString("status"));
    user.setCreatedAt(rs.getTimestamp("created_at"));
    user.setLastLogin(rs.getTimestamp("last_login"));
    user.setUpdatedAt(rs.getTimestamp("updated_at"));
    return user;
  }
}

