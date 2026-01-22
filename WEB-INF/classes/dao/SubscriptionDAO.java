package dao;

import db.DBConnect;
import model.Subscription;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class SubscriptionDAO {
  private static final String FIND_BY_USER_SQL = 
      "SELECT id, user_id, plan_code, start_date, end_date, status, payment_method, transaction_id, created_at, updated_at " +
      "FROM subscriptions WHERE user_id = ? AND status = 'ACTIVE' ORDER BY end_date DESC LIMIT 1";
  
  private static final String FIND_ACTIVE_BY_USER_SQL = 
      "SELECT id, user_id, plan_code, start_date, end_date, status, payment_method, transaction_id, created_at, updated_at " +
      "FROM subscriptions WHERE user_id = ? AND status = 'ACTIVE' " +
      "AND start_date <= CURDATE() AND end_date >= CURDATE() ORDER BY end_date DESC LIMIT 1";
  
  private static final String INSERT_SQL = 
      "INSERT INTO subscriptions (user_id, plan_code, start_date, end_date, status, payment_method, transaction_id) " +
      "VALUES (?, ?, ?, ?, 'ACTIVE', ?, ?)";
  
  private static final String UPDATE_STATUS_SQL = 
      "UPDATE subscriptions SET status = ? WHERE id = ?";
  
  private static final String DELETE_SQL = 
      "DELETE FROM subscriptions WHERE id = ?";
  
  private static final String FIND_ALL_BY_USER_SQL = 
      "SELECT id, user_id, plan_code, start_date, end_date, status, payment_method, transaction_id, created_at, updated_at " +
      "FROM subscriptions WHERE user_id = ? ORDER BY created_at DESC";

  /**
   * 사용자의 활성 구독 조회
   * @param userId 사용자 ID
   * @return 활성 구독 또는 null
   */
  public Subscription findActiveByUserId(long userId) {
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(FIND_ACTIVE_BY_USER_SQL)) {
      ps.setLong(1, userId);
      try (ResultSet rs = ps.executeQuery()) {
        if (rs.next()) {
          return mapToSubscription(rs);
        }
      }
    } catch (SQLException e) {
      System.err.println("SQL Error in findActiveByUserId: " + e.getMessage());
      throw new RuntimeException("구독 조회 중 오류가 발생했습니다.", e);
    }
    return null;
  }

  /**
   * 사용자의 최신 구독 조회 (상태 무관)
   * @param userId 사용자 ID
   * @return 구독 또는 null
   */
  public Subscription findByUserId(long userId) {
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(FIND_BY_USER_SQL)) {
      ps.setLong(1, userId);
      try (ResultSet rs = ps.executeQuery()) {
        if (rs.next()) {
          return mapToSubscription(rs);
        }
      }
    } catch (SQLException e) {
      System.err.println("SQL Error in findByUserId: " + e.getMessage());
      throw new RuntimeException("구독 조회 중 오류가 발생했습니다.", e);
    }
    return null;
  }

  /**
   * 구독 생성
   * @param subscription 구독 정보
   * @return 생성된 구독 ID
   */
  public long insert(Subscription subscription) {
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(INSERT_SQL, PreparedStatement.RETURN_GENERATED_KEYS)) {
      ps.setLong(1, subscription.getUserId());
      ps.setString(2, subscription.getPlanCode());
      ps.setDate(3, java.sql.Date.valueOf(subscription.getStartDate()));
      ps.setDate(4, java.sql.Date.valueOf(subscription.getEndDate()));
      ps.setString(5, subscription.getPaymentMethod());
      ps.setString(6, subscription.getTransactionId());
      
      int result = ps.executeUpdate();
      if (result > 0) {
        try (ResultSet rs = ps.getGeneratedKeys()) {
          if (rs.next()) {
            return rs.getLong(1);
          }
        }
      }
    } catch (SQLException e) {
      System.err.println("SQL Error in insert: " + e.getMessage());
      throw new RuntimeException("구독 생성 중 오류가 발생했습니다.", e);
    }
    return -1;
  }

  /**
   * 사용자의 모든 구독 내역 조회
   * @param userId 사용자 ID
   * @return 구독 목록
   */
  public List<Subscription> findAllByUserId(long userId) {
    List<Subscription> subscriptions = new ArrayList<>();
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(FIND_ALL_BY_USER_SQL)) {
      ps.setLong(1, userId);
      try (ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
          subscriptions.add(mapToSubscription(rs));
        }
      }
    } catch (SQLException e) {
      System.err.println("SQL Error in findAllByUserId: " + e.getMessage());
      throw new RuntimeException("구독 내역 조회 중 오류가 발생했습니다.", e);
    }
    return subscriptions;
  }

  /**
   * 구독 상태 업데이트
   * @param id 구독 ID
   * @param status 새 상태
   * @return 업데이트 성공 여부
   */
  public boolean updateStatus(long id, String status) {
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(UPDATE_STATUS_SQL)) {
      ps.setString(1, status);
      ps.setLong(2, id);
      return ps.executeUpdate() > 0;
    } catch (SQLException e) {
      System.err.println("SQL Error in updateStatus: " + e.getMessage());
      throw new RuntimeException("구독 상태 업데이트 중 오류가 발생했습니다.", e);
    }
  }

  /**
   * 구독 삭제
   * @param id 구독 ID
   * @return 삭제 성공 여부
   */
  public boolean delete(long id) {
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(DELETE_SQL)) {
      ps.setLong(1, id);
      return ps.executeUpdate() > 0;
    } catch (SQLException e) {
      System.err.println("SQL Error in delete: " + e.getMessage());
      throw new RuntimeException("구독 삭제 중 오류가 발생했습니다.", e);
    }
  }

  private Subscription mapToSubscription(ResultSet rs) throws SQLException {
    Subscription sub = new Subscription();
    sub.setId(rs.getLong("id"));
    sub.setUserId(rs.getLong("user_id"));
    sub.setPlanCode(rs.getString("plan_code"));
    
    java.sql.Date startDate = rs.getDate("start_date");
    if (startDate != null) {
      sub.setStartDate(startDate.toLocalDate());
    }
    
    java.sql.Date endDate = rs.getDate("end_date");
    if (endDate != null) {
      sub.setEndDate(endDate.toLocalDate());
    }
    
    sub.setStatus(rs.getString("status"));
    sub.setPaymentMethod(rs.getString("payment_method"));
    sub.setTransactionId(rs.getString("transaction_id"));
    sub.setCreatedAt(rs.getString("created_at"));
    sub.setUpdatedAt(rs.getString("updated_at"));
    return sub;
  }
}



