package dao;

import db.DBConnect;
import model.AgentRun;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class AgentRunDAO {
    public AgentRun create(AgentRun run) throws SQLException {
        String sql = "INSERT INTO agent_runs (" +
                "user_id, template_id, title, user_goal, status, model_used, prompt_tokens, output_tokens, credits_used, final_output_json" +
                ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setLong(1, run.getUserId());
            if (run.getTemplateId() != null) {
                ps.setInt(2, run.getTemplateId());
            } else {
                ps.setNull(2, java.sql.Types.INTEGER);
            }
            ps.setString(3, run.getTitle());
            ps.setString(4, run.getUserGoal());
            ps.setString(5, run.getStatus());
            ps.setString(6, run.getModelUsed());
            ps.setInt(7, run.getPromptTokens());
            ps.setInt(8, run.getOutputTokens());
            ps.setDouble(9, run.getCreditsUsed());
            ps.setString(10, run.getFinalOutputJson());
            ps.executeUpdate();

            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    run.setId(keys.getInt(1));
                }
            }
        }

        return findByIdAndUser(run.getId(), run.getUserId());
    }

    public List<AgentRun> findRecentByUser(long userId, int limit) throws SQLException {
        List<AgentRun> items = new ArrayList<>();
        String sql = "SELECT ar.*, at.code AS template_code, at.name AS template_name " +
                "FROM agent_runs ar " +
                "LEFT JOIN agent_templates at ON at.id = ar.template_id " +
                "WHERE ar.user_id = ? ORDER BY ar.created_at DESC LIMIT ?";

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

    public AgentRun findByIdAndUser(int id, long userId) throws SQLException {
        String sql = "SELECT ar.*, at.code AS template_code, at.name AS template_name " +
                "FROM agent_runs ar " +
                "LEFT JOIN agent_templates at ON at.id = ar.template_id " +
                "WHERE ar.id = ? AND ar.user_id = ?";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setLong(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return map(rs);
                }
            }
        }

        return null;
    }

    private AgentRun map(ResultSet rs) throws SQLException {
        AgentRun item = new AgentRun();
        item.setId(rs.getInt("id"));
        item.setUserId(rs.getLong("user_id"));
        item.setTemplateId(rs.getObject("template_id", Integer.class));
        item.setTemplateCode(rs.getString("template_code"));
        item.setTemplateName(rs.getString("template_name"));
        item.setTitle(rs.getString("title"));
        item.setUserGoal(rs.getString("user_goal"));
        item.setStatus(rs.getString("status"));
        item.setModelUsed(rs.getString("model_used"));
        item.setPromptTokens(rs.getInt("prompt_tokens"));
        item.setOutputTokens(rs.getInt("output_tokens"));
        item.setCreditsUsed(rs.getDouble("credits_used"));
        item.setFinalOutputJson(rs.getString("final_output_json"));
        item.setCreatedAt(rs.getTimestamp("created_at"));
        item.setUpdatedAt(rs.getTimestamp("updated_at"));
        return item;
    }
}
