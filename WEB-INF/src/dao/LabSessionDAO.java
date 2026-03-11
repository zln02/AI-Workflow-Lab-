package dao;

import db.DBConnect;
import model.LabSession;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class LabSessionDAO {
    public LabSession create(LabSession session) throws SQLException {
        String sql = "INSERT INTO lab_sessions (" +
                "user_id, project_id, session_type, title, code_content, result_content, model_used, " +
                "tokens_used, credits_used, execution_time_ms, status, metadata" +
                ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setLong(1, session.getUserId());
            if (session.getProjectId() != null) {
                ps.setInt(2, session.getProjectId());
            } else {
                ps.setNull(2, java.sql.Types.INTEGER);
            }
            ps.setString(3, session.getSessionType());
            ps.setString(4, session.getTitle());
            ps.setString(5, session.getCodeContent());
            ps.setString(6, session.getResultContent());
            ps.setString(7, session.getModelUsed());
            ps.setInt(8, session.getTokensUsed());
            ps.setDouble(9, session.getCreditsUsed());
            if (session.getExecutionTimeMs() != null) {
                ps.setInt(10, session.getExecutionTimeMs());
            } else {
                ps.setNull(10, java.sql.Types.INTEGER);
            }
            ps.setString(11, session.getStatus());
            ps.setString(12, session.getMetadata());
            ps.executeUpdate();

            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    session.setId(keys.getInt(1));
                }
            }
        }

        return session;
    }

    public List<LabSession> findRecentByUser(long userId, int limit) throws SQLException {
        List<LabSession> items = new ArrayList<>();
        String sql = "SELECT * FROM lab_sessions WHERE user_id = ? ORDER BY created_at DESC LIMIT ?";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    items.add(map(rs));
                }
            }
        }

        return items;
    }

    public List<LabSession> findRecentByUserAndProject(long userId, int projectId, int limit) throws SQLException {
        List<LabSession> items = new ArrayList<>();
        String sql = "SELECT * FROM lab_sessions WHERE user_id = ? AND project_id = ? ORDER BY created_at DESC LIMIT ?";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ps.setInt(2, projectId);
            ps.setInt(3, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    items.add(map(rs));
                }
            }
        }

        return items;
    }

    public LabSession findLatestByUserAndProject(long userId, int projectId) throws SQLException {
        String sql = "SELECT * FROM lab_sessions WHERE user_id = ? AND project_id = ? ORDER BY created_at DESC LIMIT 1";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ps.setInt(2, projectId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return map(rs);
                }
            }
        }

        return null;
    }

    private LabSession map(ResultSet rs) throws SQLException {
        LabSession session = new LabSession();
        session.setId(rs.getInt("id"));
        session.setUserId(rs.getLong("user_id"));
        session.setProjectId(rs.getObject("project_id", Integer.class));
        session.setSessionType(rs.getString("session_type"));
        session.setTitle(rs.getString("title"));
        session.setCodeContent(rs.getString("code_content"));
        session.setResultContent(rs.getString("result_content"));
        session.setModelUsed(rs.getString("model_used"));
        session.setTokensUsed(rs.getInt("tokens_used"));
        session.setCreditsUsed(rs.getDouble("credits_used"));
        session.setExecutionTimeMs(rs.getObject("execution_time_ms", Integer.class));
        session.setStatus(rs.getString("status"));
        session.setMetadata(rs.getString("metadata"));
        session.setCreatedAt(rs.getTimestamp("created_at"));
        session.setUpdatedAt(rs.getTimestamp("updated_at"));
        return session;
    }
}
