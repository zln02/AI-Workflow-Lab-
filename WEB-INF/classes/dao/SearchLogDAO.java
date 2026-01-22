package dao;

import db.DBConnect;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class SearchLogDAO {
  private static final String INSERT_LOG_SQL =
      "INSERT INTO search_logs (keyword, results) VALUES (?, ?)";

  public void logSearch(String keyword, int results) {
    // Null-safe and sanitized logging
    if (keyword == null || keyword.trim().isEmpty()) {
      return;
    }
    
    // Sanitize keyword: trim and limit length (max 255 chars for VARCHAR)
    String sanitizedKeyword = keyword.trim();
    if (sanitizedKeyword.length() > 255) {
      sanitizedKeyword = sanitizedKeyword.substring(0, 255);
    }
    
    // Ensure results is non-negative
    if (results < 0) {
      results = 0;
    }
    
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(INSERT_LOG_SQL)) {
      ps.setString(1, sanitizedKeyword);
      ps.setInt(2, results);
      ps.executeUpdate();
    } catch (SQLException e) {
      // 검색 로그 기록 실패는 무시 (시스템 안정성 유지)
      // Log to console for debugging in development
      System.err.println("SearchLogDAO: Failed to log search - " + e.getMessage());
    }
  }
}

