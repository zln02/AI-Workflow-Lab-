package dao;

import db.DBConnect;
import model.Plan;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class PlanDAO {
  private static final String FIND_ALL_SQL = "SELECT id, code, name, duration_months, price_usd, description, features FROM plans ORDER BY duration_months ASC";
  private static final String FIND_BY_CODE_SQL = "SELECT id, code, name, duration_months, price_usd, description, features FROM plans WHERE code = ?";
  private static final String FIND_BY_ID_SQL = "SELECT id, code, name, duration_months, price_usd, description, features FROM plans WHERE id = ?";

  public List<Plan> findAll() {
    List<Plan> plans = new ArrayList<>();
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(FIND_ALL_SQL);
         ResultSet rs = ps.executeQuery()) {
      while (rs.next()) {
        plans.add(mapToPlan(rs));
      }
    } catch (SQLException e) {
      System.err.println("SQL Error in findAll: " + e.getMessage());
      throw new RuntimeException("요금제 목록 조회 중 오류가 발생했습니다.", e);
    }
    return plans;
  }

  public Plan findByCode(String code) {
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(FIND_BY_CODE_SQL)) {
      ps.setString(1, code);
      try (ResultSet rs = ps.executeQuery()) {
        if (rs.next()) {
          return mapToPlan(rs);
        }
      }
    } catch (SQLException e) {
      System.err.println("SQL Error in findByCode: " + e.getMessage());
      throw new RuntimeException("요금제 조회 중 오류가 발생했습니다.", e);
    }
    return null;
  }

  public Plan findById(int id) {
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(FIND_BY_ID_SQL)) {
      ps.setInt(1, id);
      try (ResultSet rs = ps.executeQuery()) {
        if (rs.next()) {
          return mapToPlan(rs);
        }
      }
    } catch (SQLException e) {
      System.err.println("SQL Error in findById: " + e.getMessage());
      throw new RuntimeException("요금제 조회 중 오류가 발생했습니다.", e);
    }
    return null;
  }

  private Plan mapToPlan(ResultSet rs) throws SQLException {
    Plan plan = new Plan();
    plan.setId(rs.getInt("id"));
    plan.setCode(rs.getString("code"));
    plan.setName(rs.getString("name"));
    plan.setDurationMonths(rs.getInt("duration_months"));
    
    BigDecimal price = rs.getBigDecimal("price_usd");
    if (rs.wasNull()) {
      price = BigDecimal.ZERO;
    }
    plan.setPriceUsd(price);
    
    plan.setDescription(rs.getString("description"));
    plan.setFeatures(rs.getString("features"));
    return plan;
  }
}



