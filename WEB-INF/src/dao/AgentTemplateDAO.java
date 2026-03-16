package dao;

import db.DBConnect;
import model.AgentTemplate;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class AgentTemplateDAO {
    public List<AgentTemplate> findActiveTemplates() throws SQLException {
        List<AgentTemplate> items = new ArrayList<>();
        String sql = "SELECT * FROM agent_templates WHERE is_active = 1 ORDER BY id ASC";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                items.add(map(rs));
            }
        }

        return items;
    }

    public AgentTemplate findById(int id) throws SQLException {
        String sql = "SELECT * FROM agent_templates WHERE id = ?";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return map(rs);
                }
            }
        }

        return null;
    }

    private AgentTemplate map(ResultSet rs) throws SQLException {
        AgentTemplate item = new AgentTemplate();
        item.setId(rs.getInt("id"));
        item.setCode(rs.getString("code"));
        item.setName(rs.getString("name"));
        item.setDescription(rs.getString("description"));
        item.setSystemPrompt(rs.getString("system_prompt"));
        item.setOutputSchemaJson(rs.getString("output_schema_json"));
        item.setBadgeLabel(rs.getString("badge_label"));
        item.setSuggestedGoal(rs.getString("suggested_goal"));
        item.setActive(rs.getBoolean("is_active"));
        item.setCreatedAt(rs.getTimestamp("created_at"));
        return item;
    }
}
