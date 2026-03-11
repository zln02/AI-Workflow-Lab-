package dao;

import db.DBConnect;
import java.sql.*;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

/**
 * lab 실습 진행 상황을 user_progress 테이블에 저장/조회
 */
public class UserProgressDAO {

    private static final Gson gson = new Gson();

    // ── 조회 ──────────────────────────────────────────────────────
    public Map<String, Object> findByUserAndProject(long userId, int projectId) throws SQLException {
        String sql = "SELECT * FROM user_progress WHERE user_id=? AND item_type='project' AND item_id=? LIMIT 1";
        try (Connection c = DBConnect.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ps.setInt(2, projectId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    // ── 진행 상황 업데이트 (upsert) ────────────────────────────────
    /**
     * @param userId
     * @param projectId
     * @param progressPct   0~100
     * @param completedSteps  JSON array string  e.g. "[0,1,3]"
     * @param stepNotes     JSON object string  e.g. {"0":"노트...","1":"노트..."}
     * @param timeMinutes
     * @param status        "Not Started" | "In Progress" | "Completed"
     */
    public void upsert(long userId, int projectId,
                       double progressPct, String completedSteps,
                       String stepNotes, int timeMinutes, String status) throws SQLException {

        String sel = "SELECT id FROM user_progress WHERE user_id=? AND item_type='project' AND item_id=? LIMIT 1";
        boolean exists = false;
        int existingId = 0;
        try (Connection c = DBConnect.getConnection();
             PreparedStatement ps = c.prepareStatement(sel)) {
            ps.setLong(1, userId); ps.setInt(2, projectId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) { exists = true; existingId = rs.getInt("id"); }
            }
        }

        if (exists) {
            String sql = "UPDATE user_progress SET progress_percentage=?, bookmarks=?, notes=?, " +
                         "time_spent_minutes=?, status=?, " +
                         "completed_at = CASE WHEN ?='Completed' THEN NOW() ELSE completed_at END, " +
                         "started_at = CASE WHEN started_at IS NULL THEN NOW() ELSE started_at END, " +
                         "updated_at=NOW() WHERE id=?";
            try (Connection c = DBConnect.getConnection();
                 PreparedStatement ps = c.prepareStatement(sql)) {
                ps.setDouble(1, progressPct);
                ps.setString(2, completedSteps);
                ps.setString(3, stepNotes);
                ps.setInt(4, timeMinutes);
                ps.setString(5, status);
                ps.setString(6, status);
                ps.setInt(7, existingId);
                ps.executeUpdate();
            }
        } else {
            String sql = "INSERT INTO user_progress (user_id, item_type, item_id, progress_percentage, bookmarks, notes, " +
                         "time_spent_minutes, status, started_at, updated_at) " +
                         "VALUES (?,?,?,?,?,?,?,?,NOW(),NOW())";
            try (Connection c = DBConnect.getConnection();
                 PreparedStatement ps = c.prepareStatement(sql)) {
                ps.setLong(1, userId);
                ps.setString(2, "project");
                ps.setInt(3, projectId);
                ps.setDouble(4, progressPct);
                ps.setString(5, completedSteps);
                ps.setString(6, stepNotes);
                ps.setInt(7, timeMinutes);
                ps.setString(8, status);
                ps.executeUpdate();
            }
        }
    }

    // ── 사용자 전체 진행 목록 ────────────────────────────────────
    public List<Map<String, Object>> findAllByUser(long userId) throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT * FROM user_progress WHERE user_id=? AND item_type='project' ORDER BY updated_at DESC";
        try (Connection c = DBConnect.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    private Map<String, Object> mapRow(ResultSet rs) throws SQLException {
        Map<String, Object> m = new HashMap<>();
        m.put("id",                  rs.getInt("id"));
        m.put("userId",              rs.getInt("user_id"));
        m.put("itemId",              rs.getInt("item_id"));
        m.put("status",              rs.getString("status"));
        m.put("progressPercentage",  rs.getDouble("progress_percentage"));
        m.put("notes",               rs.getString("notes"));
        m.put("bookmarks",           rs.getString("bookmarks"));
        m.put("timeSpentMinutes",    rs.getInt("time_spent_minutes"));
        m.put("startedAt",           rs.getTimestamp("started_at"));
        m.put("completedAt",         rs.getTimestamp("completed_at"));
        m.put("updatedAt",           rs.getTimestamp("updated_at"));
        return m;
    }

    // ── 완료 처리 ────────────────────────────────────────────────
    public void markCompleted(long userId, int projectId) throws SQLException {
        upsert(userId, projectId, 100.0, "[]", "{}", 0, "Completed");
    }
}
