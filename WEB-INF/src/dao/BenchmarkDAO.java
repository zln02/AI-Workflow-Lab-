package dao;

import db.DBConnect;
import model.Benchmark;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class BenchmarkDAO {
    public List<Benchmark> findByToolId(int toolId) throws SQLException {
        List<Benchmark> benchmarks = new ArrayList<>();
        String sql = "SELECT * FROM ai_tool_benchmarks WHERE tool_id = ? ORDER BY test_date DESC, created_at DESC";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, toolId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    benchmarks.add(map(rs));
                }
            }
        }

        return benchmarks;
    }

    public List<Benchmark> findByBenchmarkName(String benchmarkName) throws SQLException {
        List<Benchmark> benchmarks = new ArrayList<>();
        String sql = "SELECT * FROM ai_tool_benchmarks WHERE benchmark_name = ? ORDER BY score DESC";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, benchmarkName);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    benchmarks.add(map(rs));
                }
            }
        }

        return benchmarks;
    }

    public boolean create(Benchmark benchmark) throws SQLException {
        String sql = "INSERT INTO ai_tool_benchmarks (tool_id, benchmark_name, score, max_score, test_date, source, notes) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, benchmark.getToolId());
            ps.setString(2, benchmark.getBenchmarkName());
            ps.setBigDecimal(3, benchmark.getScore());
            ps.setBigDecimal(4, benchmark.getMaxScore());
            ps.setDate(5, benchmark.getTestDate());
            ps.setString(6, benchmark.getSource());
            ps.setString(7, benchmark.getNotes());

            if (ps.executeUpdate() > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        benchmark.setId(keys.getInt(1));
                    }
                }
                return true;
            }
        }

        return false;
    }

    private Benchmark map(ResultSet rs) throws SQLException {
        Benchmark benchmark = new Benchmark();
        benchmark.setId(rs.getInt("id"));
        benchmark.setToolId(rs.getInt("tool_id"));
        benchmark.setBenchmarkName(rs.getString("benchmark_name"));
        benchmark.setScore(rs.getBigDecimal("score"));
        benchmark.setMaxScore(rs.getBigDecimal("max_score"));
        benchmark.setTestDate(rs.getDate("test_date"));
        benchmark.setSource(rs.getString("source"));
        benchmark.setNotes(rs.getString("notes"));
        benchmark.setCreatedAt(rs.getTimestamp("created_at"));
        return benchmark;
    }
}
