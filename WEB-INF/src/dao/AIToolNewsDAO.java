package dao;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import db.DBConnect;
import model.AIToolNews;

import java.lang.reflect.Type;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class AIToolNewsDAO {
    private final Gson gson = new Gson();
    private final Type listType = new TypeToken<List<String>>() {}.getType();

    public List<AIToolNews> findLatest(int limit) throws SQLException {
        List<AIToolNews> items = new ArrayList<>();
        String sql = "SELECT * FROM ai_tool_news WHERE is_active = 1 ORDER BY published_at DESC LIMIT ?";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    items.add(map(rs));
                }
            }
        }

        return items;
    }

    public List<AIToolNews> findFeatured(int limit) throws SQLException {
        List<AIToolNews> items = new ArrayList<>();
        String sql = "SELECT * FROM ai_tool_news WHERE is_active = 1 AND is_featured = 1 ORDER BY published_at DESC LIMIT ?";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    items.add(map(rs));
                }
            }
        }

        return items;
    }

    public AIToolNews findById(int id) throws SQLException {
        String sql = "SELECT * FROM ai_tool_news WHERE id = ? AND is_active = 1";

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

    public List<AIToolNews> findByType(String newsType, int limit) throws SQLException {
        List<AIToolNews> items = new ArrayList<>();
        String sql = "SELECT * FROM ai_tool_news WHERE news_type = ? AND is_active = 1 ORDER BY published_at DESC LIMIT ?";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newsType);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    items.add(map(rs));
                }
            }
        }

        return items;
    }

    public List<AIToolNews> findByToolId(int toolId, int limit) throws SQLException {
        List<AIToolNews> items = new ArrayList<>();
        String sql = "SELECT * FROM ai_tool_news WHERE tool_id = ? AND is_active = 1 ORDER BY published_at DESC LIMIT ?";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, toolId);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    items.add(map(rs));
                }
            }
        }

        return items;
    }

    public boolean create(AIToolNews news) throws SQLException {
        String sql = "INSERT INTO ai_tool_news (tool_id, title, summary, content, source_url, source_name, image_url, news_type, tags, is_featured, is_active) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setObject(1, news.getToolId());
            ps.setString(2, news.getTitle());
            ps.setString(3, news.getSummary());
            ps.setString(4, news.getContent());
            ps.setString(5, news.getSourceUrl());
            ps.setString(6, news.getSourceName());
            ps.setString(7, news.getImageUrl());
            ps.setString(8, news.getNewsType());
            ps.setString(9, news.getTags() != null ? gson.toJson(news.getTags()) : null);
            ps.setBoolean(10, news.isFeatured());
            ps.setBoolean(11, news.isActive());

            if (ps.executeUpdate() > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        news.setId(keys.getInt(1));
                    }
                }
                return true;
            }
        }

        return false;
    }

    private AIToolNews map(ResultSet rs) throws SQLException {
        AIToolNews item = new AIToolNews();
        item.setId(rs.getInt("id"));
        item.setToolId(rs.getObject("tool_id", Integer.class));
        item.setTitle(rs.getString("title"));
        item.setSummary(rs.getString("summary"));
        item.setContent(rs.getString("content"));
        item.setSourceUrl(rs.getString("source_url"));
        item.setSourceName(rs.getString("source_name"));
        item.setImageUrl(rs.getString("image_url"));
        item.setNewsType(rs.getString("news_type"));
        item.setTags(gson.fromJson(rs.getString("tags"), listType));
        item.setViewCount(rs.getInt("view_count"));
        item.setPublishedAt(rs.getTimestamp("published_at"));
        item.setFeatured(rs.getBoolean("is_featured"));
        item.setActive(rs.getBoolean("is_active"));
        item.setCreatedAt(rs.getTimestamp("created_at"));
        return item;
    }
}
