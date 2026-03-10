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
        return findById((long) id);
    }

    /** Required by UserService */
    public User findById(long id) throws SQLException {
        String sql = "SELECT * FROM users WHERE id = ?";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, id);
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
        return createUser(user) > 0;
    }

    /** Required by UserService - returns generated ID as long, or -1 on failure */
    public long createUser(User user) throws SQLException {
        // Auto-generate username from email if not set
        if (user.getUsername() == null || user.getUsername().trim().isEmpty()) {
            String emailBase = user.getEmail() != null
                ? user.getEmail().replaceAll("@.*", "").replaceAll("[^a-zA-Z0-9_]", "_")
                : "user";
            // Ensure uniqueness by appending a short random suffix
            String candidate = emailBase;
            int suffix = (int)(System.currentTimeMillis() % 10000);
            try (Connection connCheck = DBConnect.getConnection();
                 PreparedStatement psCheck = connCheck.prepareStatement(
                     "SELECT COUNT(*) FROM users WHERE username=?")) {
                psCheck.setString(1, candidate);
                try (ResultSet rs = psCheck.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        candidate = emailBase + "_" + suffix;
                    }
                }
            }
            user.setUsername(candidate);
        }

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
                        long id = generatedKeys.getLong(1);
                        user.setId(id);
                        return id;
                    }
                }
            }
        }
        return -1L;
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
            ps.setLong(12, user.getId());

            return ps.executeUpdate() > 0;
        }
    }
    
    /**
     * 비밀번호 수정
     */
    public boolean updatePassword(int userId, String newPasswordHash) throws SQLException {
        return updatePassword((long) userId, newPasswordHash);
    }

    /** Required by UserService */
    public boolean updatePassword(long userId, String newPasswordHash) throws SQLException {
        String sql = "UPDATE users SET password_hash = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, newPasswordHash);
            ps.setLong(2, userId);
            return ps.executeUpdate() > 0;
        }
    }
    
    /**
     * 최종 로그인 시간 업데이트
     */
    public boolean updateLastLogin(int userId) throws SQLException {
        return updateLastLogin((long) userId);
    }

    /** Required by UserService */
    public boolean updateLastLogin(long userId) throws SQLException {
        String sql = "UPDATE users SET last_login = CURRENT_TIMESTAMP WHERE id = ?";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, userId);
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
        long kakaoId = rs.getLong("kakao_id");
        if (!rs.wasNull()) user.setKakaoId(kakaoId);
        user.setGoogleId(rs.getString("google_id"));
        user.setNaverId(rs.getString("naver_id"));
        user.setGender(rs.getString("gender"));
        user.setAgeRange(rs.getString("age_range"));
        user.setBirthyear(rs.getString("birthyear"));
        user.setBirthday(rs.getString("birthday"));
        user.setEmailVerified(rs.getBoolean("email_verified"));
        user.setActive(rs.getBoolean("is_active"));
        user.setLastLogin(rs.getTimestamp("last_login"));
        user.setCreatedAt(rs.getTimestamp("created_at"));
        user.setUpdatedAt(rs.getTimestamp("updated_at"));
        
        return user;
    }
    
    /**
     * 카카오 ID로 사용자 조회
     */
    public User findByKakaoId(long kakaoId) throws SQLException {
        String sql = "SELECT * FROM users WHERE kakao_id = ? AND is_active = true";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, kakaoId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapResultSetToUser(rs);
            }
        }
        return null;
    }

    /**
     * 기존 계정에 카카오 ID 연결
     */
    public boolean linkKakaoId(long userId, long kakaoId) throws SQLException {
        String sql = "UPDATE users SET kakao_id = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, kakaoId);
            ps.setLong(2, userId);
            return ps.executeUpdate() > 0;
        }
    }

    /** 구글 ID로 사용자 조회 */
    public User findByGoogleId(String googleId) throws SQLException {
        String sql = "SELECT * FROM users WHERE google_id = ? AND is_active = true";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, googleId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapResultSetToUser(rs);
            }
        }
        return null;
    }

    /** 네이버 ID로 사용자 조회 */
    public User findByNaverId(String naverId) throws SQLException {
        String sql = "SELECT * FROM users WHERE naver_id = ? AND is_active = true";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, naverId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapResultSetToUser(rs);
            }
        }
        return null;
    }

    /** 기존 계정에 구글 ID 연결 */
    public boolean linkGoogleId(long userId, String googleId) throws SQLException {
        String sql = "UPDATE users SET google_id=?, updated_at=CURRENT_TIMESTAMP WHERE id=?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, googleId);
            ps.setLong(2, userId);
            return ps.executeUpdate() > 0;
        }
    }

    /** 기존 계정에 네이버 ID 연결 */
    public boolean linkNaverId(long userId, String naverId) throws SQLException {
        String sql = "UPDATE users SET naver_id=?, updated_at=CURRENT_TIMESTAMP WHERE id=?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, naverId);
            ps.setLong(2, userId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * 소셜 로그인 공통 신규 사용자 생성 (kakao/google/naver)
     */
    public long createSocialUser(User user) throws SQLException {
        // username: 닉네임 그대로, 없으면 소셜 ID 기반
        String baseUsername = (user.getFullName() != null && !user.getFullName().trim().isEmpty())
                ? user.getFullName().trim()
                : (user.getKakaoId() != null ? "kakao_" + user.getKakaoId()
                : user.getGoogleId() != null ? "google_" + user.getGoogleId().substring(0, 8)
                : "naver_" + (user.getNaverId() != null ? user.getNaverId().substring(0, 8) : "user"));
        String username = baseUsername;
        int suffix = 2;
        while (isUsernameTaken(username)) {
            username = baseUsername + suffix++;
        }
        user.setUsername(username);

        if (user.getEmail() == null || user.getEmail().trim().isEmpty()) {
            String idBase = user.getKakaoId() != null ? "kakao_" + user.getKakaoId()
                    : user.getGoogleId() != null ? "google_" + user.getGoogleId().substring(0, 8)
                    : "naver_" + (user.getNaverId() != null ? user.getNaverId().substring(0, 8) : "user");
            user.setEmail(idBase + "@social.local");
        }

        String sql = "INSERT INTO users (username, email, password_hash, full_name, profile_image_url, " +
                "email_verified, is_active, kakao_id, google_id, naver_id, gender, age_range, birthyear, birthday) " +
                "VALUES (?, ?, NULL, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, user.getUsername());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getFullName());
            ps.setString(4, user.getProfileImageUrl());
            ps.setBoolean(5, user.isEmailVerified());
            ps.setBoolean(6, user.isActive());
            if (user.getKakaoId() != null) ps.setLong(7, user.getKakaoId()); else ps.setNull(7, java.sql.Types.BIGINT);
            ps.setString(8, user.getGoogleId());
            ps.setString(9, user.getNaverId());
            ps.setString(10, user.getGender());
            ps.setString(11, user.getAgeRange());
            ps.setString(12, user.getBirthyear());
            ps.setString(13, user.getBirthday());

            int result = ps.executeUpdate();
            if (result > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        long id = keys.getLong(1);
                        user.setId(id);
                        return id;
                    }
                }
            }
        }
        return -1L;
    }

    /**
     * 카카오 소셜 로그인 신규 사용자 생성 (password 없음)
     */
    public long createKakaoUser(User user) throws SQLException {
        // 사용자명 생성: 카카오 닉네임 그대로, 없으면 kakao_{id}
        String baseUsername = (user.getFullName() != null && !user.getFullName().trim().isEmpty())
                ? user.getFullName().trim()
                : "kakao_" + user.getKakaoId();
        String username = baseUsername;
        int suffix = 2;
        while (isUsernameTaken(username)) {
            username = baseUsername + suffix++;
        }
        user.setUsername(username);

        // 이메일이 없으면 플레이스홀더 사용 (NOT NULL 방어)
        String email = user.getEmail();
        if (email == null || email.trim().isEmpty()) {
            email = "kakao_" + user.getKakaoId() + "@kakao.local";
        }
        user.setEmail(email);

        String sql = "INSERT INTO users " +
                "(username, email, password_hash, full_name, profile_image_url, " +
                "email_verified, is_active, kakao_id, gender, age_range, birthyear, birthday) " +
                "VALUES (?, ?, NULL, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, user.getUsername());
            ps.setString(2, email);
            ps.setString(3, user.getFullName());
            ps.setString(4, user.getProfileImageUrl());
            ps.setBoolean(5, user.isEmailVerified());
            ps.setBoolean(6, user.isActive());
            ps.setLong(7, user.getKakaoId());
            ps.setString(8, user.getGender());
            ps.setString(9, user.getAgeRange());
            ps.setString(10, user.getBirthyear());
            ps.setString(11, user.getBirthday());

            int result = ps.executeUpdate();
            if (result > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        long id = keys.getLong(1);
                        user.setId(id);
                        return id;
                    }
                }
            }
        }
        return -1L;
    }

    /**
     * 카카오 로그인 시 추가 정보 업데이트
     */
    public boolean updateKakaoInfo(long userId, String gender, String ageRange, String birthyear, String birthday) throws SQLException {
        String sql = "UPDATE users SET gender=?, age_range=?, birthyear=?, birthday=?, updated_at=CURRENT_TIMESTAMP WHERE id=?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, gender);
            ps.setString(2, ageRange);
            ps.setString(3, birthyear);
            ps.setString(4, birthday);
            ps.setLong(5, userId);
            return ps.executeUpdate() > 0;
        }
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
