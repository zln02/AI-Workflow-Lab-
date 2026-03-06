package dao;

import model.User;
import db.DBConnect;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.sql.*;
import java.util.*;
import java.lang.reflect.Type;

/**
 * 사용자 데이터 접근 객체
 * AI Workflow Lab 플랫폼 사용자 관리
 */
public class UserDAO {
    private Gson gson = new Gson();
    
    /**
     * 모든 사용자 조회
     */
    public List<User> findAll() throws SQLException {
        List<User> users = new ArrayList<>();
        String sql = "SELECT * FROM users WHERE is_active = true ORDER BY created_at DESC";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                users.add(mapResultSetToUser(rs));
            }
        }
        return users;
    }
    
    /**
     * ID로 사용자 조회
     */
    public User findById(int id) throws SQLException {
        String sql = "SELECT * FROM users WHERE id = ?";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToUser(rs);
                }
            }
        }
        return null;
    }
    
    /**
     * 사용자명으로 사용자 조회
     */
    public User findByUsername(String username) throws SQLException {
        String sql = "SELECT * FROM users WHERE username = ?";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToUser(rs);
                }
            }
        }
        return null;
    }
    
    /**
     * 이메일로 사용자 조회
     */
    public User findByEmail(String email) throws SQLException {
        String sql = "SELECT * FROM users WHERE email = ?";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToUser(rs);
                }
            }
        }
        return null;
    }
    
    /**
     * 사용자명 또는 이메일로 조회 (로그인용)
     */
    public User findByUsernameOrEmail(String identifier) throws SQLException {
        String sql = "SELECT * FROM users WHERE (username = ? OR email = ?) AND is_active = true";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, identifier);
            ps.setString(2, identifier);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToUser(rs);
                }
            }
        }
        return null;
    }
    
    /**
     * 경험 수준별 사용자 조회
     */
    public List<User> findByExperienceLevel(String experienceLevel) throws SQLException {
        List<User> users = new ArrayList<>();
        String sql = "SELECT * FROM users WHERE experience_level = ? AND is_active = true ORDER BY created_at DESC";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, experienceLevel);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    users.add(mapResultSetToUser(rs));
                }
            }
        }
        return users;
    }
    
    /**
     * 키워드로 사용자 검색
     */
    public List<User> searchByKeyword(String keyword) throws SQLException {
        List<User> users = new ArrayList<>();
        String sql = "SELECT * FROM users WHERE " +
                    "is_active = true AND " +
                    "(username LIKE ? OR full_name LIKE ? OR email LIKE ? OR " +
                    "company LIKE ? OR job_title LIKE ?) " +
                    "ORDER BY created_at DESC";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            String searchPattern = "%" + keyword + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);
            ps.setString(4, searchPattern);
            ps.setString(5, searchPattern);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    users.add(mapResultSetToUser(rs));
                }
            }
        }
        return users;
    }
    
    /**
     * 사용자 등록
     */
    public boolean create(User user) throws SQLException {
        String sql = "INSERT INTO users (" +
                    "username, email, password_hash, full_name, profile_image_url, " +
                    "bio, company, job_title, skills, interests, experience_level, " +
                    "email_verified, is_active" +
                    ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setString(1, user.getUsername());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPasswordHash());
            ps.setString(4, user.getFullName());
            ps.setString(5, user.getProfileImageUrl());
            ps.setString(6, user.getBio());
            ps.setString(7, user.getCompany());
            ps.setString(8, user.getJobTitle());
            ps.setString(9, user.getSkills() != null ? gson.toJson(user.getSkills()) : null);
            ps.setString(10, user.getInterests() != null ? gson.toJson(user.getInterests()) : null);
            ps.setString(11, user.getExperienceLevel());
            ps.setBoolean(12, user.isEmailVerified());
            ps.setBoolean(13, user.isActive());
            
            int result = ps.executeUpdate();
            
            if (result > 0) {
                try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        user.setId(generatedKeys.getInt(1));
                    }
                }
                return true;
            }
        }
        return false;
    }
    
    /**
     * 사용자 정보 수정
     */
    public boolean update(User user) throws SQLException {
        String sql = "UPDATE users SET " +
                    "username = ?, email = ?, full_name = ?, profile_image_url = ?, " +
                    "bio = ?, company = ?, job_title = ?, skills = ?, interests = ?, " +
                    "experience_level = ?, email_verified = ?, updated_at = CURRENT_TIMESTAMP " +
                    "WHERE id = ?";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, user.getUsername());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getFullName());
            ps.setString(4, user.getProfileImageUrl());
            ps.setString(5, user.getBio());
            ps.setString(6, user.getCompany());
            ps.setString(7, user.getJobTitle());
            ps.setString(8, user.getSkills() != null ? gson.toJson(user.getSkills()) : null);
            ps.setString(9, user.getInterests() != null ? gson.toJson(user.getInterests()) : null);
            ps.setString(10, user.getExperienceLevel());
            ps.setBoolean(11, user.isEmailVerified());
            ps.setInt(12, user.getId());
            
            return ps.executeUpdate() > 0;
        }
    }
    
    /**
     * 비밀번호 수정
     */
    public boolean updatePassword(int userId, String newPasswordHash) throws SQLException {
        String sql = "UPDATE users SET password_hash = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, newPasswordHash);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        }
    }
    
    /**
     * 최종 로그인 시간 업데이트
     */
    public boolean updateLastLogin(int userId) throws SQLException {
        String sql = "UPDATE users SET last_login = CURRENT_TIMESTAMP WHERE id = ?";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        }
    }
    
    /**
     * 사용자 비활성화 (소프트 삭제)
     */
    public boolean deactivate(int userId) throws SQLException {
        String sql = "UPDATE users SET is_active = false, updated_at = CURRENT_TIMESTAMP WHERE id = ?";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        }
    }
    
    /**
     * 이메일 인증 상태 업데이트
     */
    public boolean verifyEmail(int userId) throws SQLException {
        String sql = "UPDATE users SET email_verified = true, updated_at = CURRENT_TIMESTAMP WHERE id = ?";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        }
    }
    
    /**
     * 사용자명 중복 확인
     */
    public boolean isUsernameTaken(String username) throws SQLException {
        String sql = "SELECT COUNT(*) FROM users WHERE username = ?";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }
    
    /**
     * 이메일 중복 확인
     */
    public boolean isEmailTaken(String email) throws SQLException {
        String sql = "SELECT COUNT(*) FROM users WHERE email = ?";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }
    
    /**
     * ResultSet을 User 객체로 매핑
     */
    private User mapResultSetToUser(ResultSet rs) throws SQLException {
        User user = new User();
        
        user.setId(rs.getInt("id"));
        user.setUsername(rs.getString("username"));
        user.setEmail(rs.getString("email"));
        user.setPasswordHash(rs.getString("password_hash"));
        user.setFullName(rs.getString("full_name"));
        user.setProfileImageUrl(rs.getString("profile_image_url"));
        user.setBio(rs.getString("bio"));
        user.setCompany(rs.getString("company"));
        user.setJobTitle(rs.getString("job_title"));
        
        // JSON 필드 파싱
        Type listType = new TypeToken<List<String>>(){}.getType();
        user.setSkills(gson.fromJson(rs.getString("skills"), listType));
        user.setInterests(gson.fromJson(rs.getString("interests"), listType));
        
        user.setExperienceLevel(rs.getString("experience_level"));
        user.setEmailVerified(rs.getBoolean("email_verified"));
        user.setActive(rs.getBoolean("is_active"));
        user.setLastLogin(rs.getTimestamp("last_login"));
        user.setCreatedAt(rs.getTimestamp("created_at"));
        user.setUpdatedAt(rs.getTimestamp("updated_at"));
        
        return user;
    }
    
    /**
     * 프로필 이미지만 업데이트
     */
    public boolean updateProfileImage(int userId, String profileImageUrl) {
        String sql = "UPDATE users SET profile_image_url = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, profileImageUrl);
            ps.setInt(2, userId);
            
            int result = ps.executeUpdate();
            return result > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
}
