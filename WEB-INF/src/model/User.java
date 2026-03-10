package model;

import java.sql.Timestamp;
import java.util.List;

/**
 * 사용자 정보를 담는 모델 클래스
 * AI Workflow Lab 플랫폼의 사용자
 */
public class User {
    private long id;
    private String username;
    private String email;
    private String passwordHash;
    private String fullName;
    private String profileImageUrl;
    private String bio;
    private String company;
    private String jobTitle;
    private List<String> skills;
    private List<String> interests;
    private String experienceLevel;
    private Long kakaoId;
    private String googleId;
    private String naverId;
    private String gender;
    private String ageRange;
    private String birthyear;
    private String birthday;
    private boolean emailVerified;
    private boolean isActive;
    private Timestamp lastLogin;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    
    // 생성자
    public User() {}
    
    public User(long id, String username, String email) {
        this.id = id;
        this.username = username;
        this.email = email;
    }
    
    // Getters and Setters
    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    /** Convenience int overload for DAOs using rs.getInt() */
    public void setId(int id) {
        this.id = (long) id;
    }
    
    public String getUsername() {
        return username;
    }
    
    public void setUsername(String username) {
        this.username = username;
    }
    
    public String getEmail() {
        return email;
    }
    
    public void setEmail(String email) {
        this.email = email;
    }
    
    public String getPasswordHash() {
        return passwordHash;
    }
    
    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }
    
    public String getFullName() {
        return fullName;
    }
    
    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    /** Alias for setFullName - required by UserService */
    public void setName(String name) {
        this.fullName = name;
    }

    public String getName() {
        return this.fullName;
    }

    /** Required by UserService */
    public void setStatus(String status) {
        this.isActive = "ACTIVE".equalsIgnoreCase(status) || "active".equalsIgnoreCase(status);
    }

    public String getStatus() {
        return isActive ? "ACTIVE" : "INACTIVE";
    }
    
    public String getProfileImageUrl() {
        return profileImageUrl;
    }
    
    public void setProfileImageUrl(String profileImageUrl) {
        this.profileImageUrl = profileImageUrl;
    }
    
    public String getBio() {
        return bio;
    }
    
    public void setBio(String bio) {
        this.bio = bio;
    }
    
    public String getCompany() {
        return company;
    }
    
    public void setCompany(String company) {
        this.company = company;
    }
    
    public String getJobTitle() {
        return jobTitle;
    }
    
    public void setJobTitle(String jobTitle) {
        this.jobTitle = jobTitle;
    }
    
    public List<String> getSkills() {
        return skills;
    }
    
    public void setSkills(List<String> skills) {
        this.skills = skills;
    }
    
    public List<String> getInterests() {
        return interests;
    }
    
    public void setInterests(List<String> interests) {
        this.interests = interests;
    }
    
    public String getExperienceLevel() {
        return experienceLevel;
    }
    
    public void setExperienceLevel(String experienceLevel) {
        this.experienceLevel = experienceLevel;
    }
    
    public Long getKakaoId() {
        return kakaoId;
    }

    public void setKakaoId(Long kakaoId) {
        this.kakaoId = kakaoId;
    }

    public String getGoogleId() { return googleId; }
    public void setGoogleId(String googleId) { this.googleId = googleId; }

    public String getNaverId() { return naverId; }
    public void setNaverId(String naverId) { this.naverId = naverId; }

    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }

    public String getAgeRange() { return ageRange; }
    public void setAgeRange(String ageRange) { this.ageRange = ageRange; }

    public String getBirthyear() { return birthyear; }
    public void setBirthyear(String birthyear) { this.birthyear = birthyear; }

    public String getBirthday() { return birthday; }
    public void setBirthday(String birthday) { this.birthday = birthday; }

    public boolean isEmailVerified() {
        return emailVerified;
    }
    
    public void setEmailVerified(boolean emailVerified) {
        this.emailVerified = emailVerified;
    }
    
    public boolean isActive() {
        return isActive;
    }
    
    public void setActive(boolean active) {
        isActive = active;
    }
    
    public Timestamp getLastLogin() {
        return lastLogin;
    }
    
    public void setLastLogin(Timestamp lastLogin) {
        this.lastLogin = lastLogin;
    }
    
    public Timestamp getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
    
    public Timestamp getUpdatedAt() {
        return updatedAt;
    }
    
    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }
    
    /**
     * 표시 이름 반환 (fullName이 없으면 username 사용)
     */
    public String getDisplayName() {
        return fullName != null && !fullName.trim().isEmpty() ? fullName : username;
    }
    
    /**
     * 경험 수준에 따른 CSS 클래스 반환
     */
    public String getExperienceBadgeClass() {
        if ("Beginner".equals(experienceLevel)) {
            return "badge-success";
        } else if ("Intermediate".equals(experienceLevel)) {
            return "badge-warning";
        } else if ("Advanced".equals(experienceLevel)) {
            return "badge-danger";
        }
        return "badge-secondary";
    }
    
    /**
     * 프로필 이미지 URL 반환 (없으면 기본 이미지)
     */
    public String getProfileImage() {
        if (profileImageUrl != null && !profileImageUrl.trim().isEmpty()) {
            return profileImageUrl;
        }
        return "/AI/assets/img/default-profile.png";
    }
    
    /**
     * 기본 정보가 있는지 확인
     */
    public boolean hasProfileInfo() {
        return (fullName != null && !fullName.trim().isEmpty()) ||
               (company != null && !company.trim().isEmpty()) ||
               (jobTitle != null && !jobTitle.trim().isEmpty());
    }
    
    /**
     * 스킬이 있는지 확인
     */
    public boolean hasSkills() {
        return skills != null && !skills.isEmpty();
    }
    
    /**
     * 관심사가 있는지 확인
     */
    public boolean hasInterests() {
        return interests != null && !interests.isEmpty();
    }
    
    @Override
    public String toString() {
        return "User{" +
                "id=" + id +
                ", username='" + username + '\'' +
                ", email='" + email + '\'' +
                ", fullName='" + fullName + '\'' +
                ", experienceLevel='" + experienceLevel + '\'' +
                '}';
    }
}
