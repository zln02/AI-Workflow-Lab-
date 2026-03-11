package dao;

import db.DBConnect;
import java.sql.*;

/**
 * 사용자 크레딧 관리 DAO
 * - 요금제 구독 시 크레딧 지급
 * - AI API 호출 시 크레딧 차감
 * - 잔고 조회
 */
public class CreditDAO {

    // ── 잔고 조회 ──────────────────────────────────────────────────
    public int getBalance(long userId) throws SQLException {
        String sql = "SELECT total_granted - total_used FROM user_credits WHERE user_id=?";
        try (Connection c = DBConnect.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return Math.max(0, rs.getInt(1));
            }
        }
        return 0;
    }

    public int getTotalGranted(long userId) throws SQLException {
        String sql = "SELECT total_granted FROM user_credits WHERE user_id=?";
        try (Connection c = DBConnect.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    public int getTotalUsed(long userId) throws SQLException {
        String sql = "SELECT total_used FROM user_credits WHERE user_id=?";
        try (Connection c = DBConnect.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    // ── 크레딧 지급 (구독 시) ─────────────────────────────────────
    public void grant(long userId, int amount, String planCode) throws SQLException {
        String sql = "INSERT INTO user_credits (user_id, total_granted, total_used, plan_code, reset_date) " +
                     "VALUES (?, ?, 0, ?, DATE_ADD(CURDATE(), INTERVAL 1 MONTH)) " +
                     "ON DUPLICATE KEY UPDATE " +
                     "total_granted = total_granted + ?, plan_code = ?, " +
                     "reset_date = DATE_ADD(CURDATE(), INTERVAL 1 MONTH), " +
                     "updated_at = NOW()";
        try (Connection c = DBConnect.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ps.setInt(2, amount);
            ps.setString(3, planCode);
            ps.setInt(4, amount);
            ps.setString(5, planCode);
            ps.executeUpdate();
        }
    }

    // ── 크레딧 차감 (AI 호출 시) ──────────────────────────────────
    /**
     * @return true if deducted, false if insufficient balance
     */
    public boolean deduct(long userId, int amount, String model,
                          int promptTokens, int outputTokens,
                          String feature, Integer projectId,
                          String requestSummary) throws SQLException {
        // Check balance
        if (getBalance(userId) < amount) return false;

        String updateSql = "UPDATE user_credits SET total_used = total_used + ? WHERE user_id=? " +
                           "AND (total_granted - total_used) >= ?";
        try (Connection c = DBConnect.getConnection();
             PreparedStatement ps = c.prepareStatement(updateSql)) {
            ps.setInt(1, amount);
            ps.setLong(2, userId);
            ps.setInt(3, amount);
            int rows = ps.executeUpdate();
            if (rows == 0) return false;
        }

        // Log usage
        String logSql = "INSERT INTO credit_usage_logs " +
                        "(user_id, credits_used, model_used, prompt_tokens, output_tokens, feature, project_id, request_summary) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection c = DBConnect.getConnection();
             PreparedStatement ps = c.prepareStatement(logSql)) {
            ps.setLong(1, userId);
            ps.setInt(2, amount);
            ps.setString(3, model);
            ps.setInt(4, promptTokens);
            ps.setInt(5, outputTokens);
            ps.setString(6, feature);
            if (projectId != null) ps.setInt(7, projectId); else ps.setNull(7, Types.INTEGER);
            ps.setString(8, requestSummary != null && requestSummary.length() > 200
                            ? requestSummary.substring(0, 200) : requestSummary);
            ps.executeUpdate();
        }
        return true;
    }

    // ── 사용 내역 조회 ────────────────────────────────────────────
    public java.util.List<java.util.Map<String, Object>> getUsageLogs(long userId, int limit) throws SQLException {
        java.util.List<java.util.Map<String, Object>> list = new java.util.ArrayList<>();
        String sql = "SELECT * FROM credit_usage_logs WHERE user_id=? ORDER BY created_at DESC LIMIT ?";
        try (Connection c = DBConnect.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String, Object> row = new java.util.HashMap<>();
                    row.put("id",             rs.getLong("id"));
                    row.put("creditsUsed",    rs.getInt("credits_used"));
                    row.put("modelUsed",      rs.getString("model_used"));
                    row.put("promptTokens",   rs.getInt("prompt_tokens"));
                    row.put("outputTokens",   rs.getInt("output_tokens"));
                    row.put("feature",        rs.getString("feature"));
                    row.put("projectId",      rs.getObject("project_id"));
                    row.put("requestSummary", rs.getString("request_summary"));
                    row.put("createdAt",      rs.getTimestamp("created_at"));
                    list.add(row);
                }
            }
        }
        return list;
    }
}
