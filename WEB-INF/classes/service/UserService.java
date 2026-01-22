package service;

import dao.UserDAO;
import model.User;
import security.PasswordUtils;

import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

/**
 * 사용자 관련 비즈니스 로직
 */
public class UserService {
  private UserDAO userDAO;
  
  // 이메일 정규식
  private static final Pattern EMAIL_PATTERN = 
      Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");
  
  // 비밀번호 최소 길이
  private static final int MIN_PASSWORD_LENGTH = 8;

  public UserService() {
    this.userDAO = new UserDAO();
  }

  /**
   * 회원가입 검증
   * @param email 이메일
   * @param password 비밀번호
   * @param passwordConfirm 비밀번호 확인
   * @param name 이름
   * @return 검증 오류 목록 (빈 리스트면 성공)
   */
  public List<String> validateSignup(String email, String password, String passwordConfirm, String name) {
    List<String> errors = new ArrayList<>();
    
    // 이메일 검증
    if (email == null || email.trim().isEmpty()) {
      errors.add("이메일을 입력해주세요.");
    } else if (!EMAIL_PATTERN.matcher(email.trim()).matches()) {
      errors.add("올바른 이메일 형식이 아닙니다.");
    } else if (userDAO.findByEmail(email.trim()) != null) {
      errors.add("이미 사용 중인 이메일입니다.");
    }
    
    // 비밀번호 검증
    if (password == null || password.isEmpty()) {
      errors.add("비밀번호를 입력해주세요.");
    } else if (password.length() < MIN_PASSWORD_LENGTH) {
      errors.add("비밀번호는 최소 8자 이상이어야 합니다.");
    }
    
    // 비밀번호 확인 검증
    if (passwordConfirm == null || passwordConfirm.isEmpty()) {
      errors.add("비밀번호 확인을 입력해주세요.");
    } else if (!password.equals(passwordConfirm)) {
      errors.add("비밀번호가 일치하지 않습니다.");
    }
    
    // 이름 검증
    if (name == null || name.trim().isEmpty()) {
      errors.add("이름을 입력해주세요.");
    } else if (name.trim().length() < 2) {
      errors.add("이름은 최소 2자 이상이어야 합니다.");
    } else if (name.trim().length() > 100) {
      errors.add("이름은 100자 이하여야 합니다.");
    }
    
    return errors;
  }

  /**
   * 비밀번호 해시 (BCrypt 사용)
   * @param password 평문 비밀번호
   * @return 해시된 비밀번호
   */
  public String hashPassword(String password) {
    try {
      // BCrypt 사용 (리플렉션으로 안전하게 호출)
      Class<?> bcryptClass = Class.forName("org.mindrot.jbcrypt.BCrypt");
      Method hashpwMethod = bcryptClass.getMethod("hashpw", String.class, String.class);
      Method gensaltMethod = bcryptClass.getMethod("gensalt");
      String salt = (String) gensaltMethod.invoke(null);
      return (String) hashpwMethod.invoke(null, password, salt);
    } catch (Exception e) {
      // BCrypt가 없는 경우 대체 방법 (개발용, 운영에서는 BCrypt 필수)
      System.err.println("BCrypt not available, using fallback: " + e.getMessage());
      // 간단한 해시 (운영 환경에서는 절대 사용 금지)
      return "fallback:" + String.valueOf(password.hashCode());
    }
  }

  /**
   * 비밀번호 검증
   * @param password 평문 비밀번호
   * @param hash 해시된 비밀번호
   * @return 일치 여부
   */
  public boolean verifyPassword(String password, String hash) {
    // 기존 PasswordUtils 사용 (BCrypt 검증)
    if (PasswordUtils.matches(password, hash)) {
      return true;
    }
    
    // BCrypt 직접 시도 (리플렉션)
    try {
      Class<?> bcryptClass = Class.forName("org.mindrot.jbcrypt.BCrypt");
      Method checkpwMethod = bcryptClass.getMethod("checkpw", String.class, String.class);
      return (Boolean) checkpwMethod.invoke(null, password, hash);
    } catch (Exception e) {
      // BCrypt가 없는 경우 대체 방법 (fallback 해시)
      if (hash.startsWith("fallback:")) {
        String fallbackHash = hash.substring(9);
        return fallbackHash.equals(String.valueOf(password.hashCode()));
      }
      return false;
    }
  }

  /**
   * 사용자 생성
   * @param email 이메일
   * @param password 비밀번호
   * @param name 이름
   * @return 생성된 사용자 또는 null
   */
  public User createUser(String email, String password, String name) {
    // 검증
    List<String> errors = validateSignup(email, password, password, name);
    if (!errors.isEmpty()) {
      return null;
    }
    
    // 사용자 생성
    User user = new User();
    user.setEmail(email.trim().toLowerCase());
    user.setPasswordHash(hashPassword(password));
    user.setName(name.trim());
    user.setStatus("ACTIVE");
    
    long userId = userDAO.createUser(user);
    if (userId > 0) {
      user.setId(userId);
      return user;
    }
    
    return null;
  }

  /**
   * 로그인 검증
   * @param email 이메일
   * @param password 비밀번호
   * @return 사용자 또는 null
   */
  public User authenticate(String email, String password) {
    if (email == null || email.trim().isEmpty() || password == null || password.isEmpty()) {
      return null;
    }
    
    User user = userDAO.findByEmail(email.trim().toLowerCase());
    if (user == null) {
      return null;
    }
    
    // 계정 상태 확인
    if (!user.isActive()) {
      return null;
    }
    
    // 비밀번호 검증
    if (!verifyPassword(password, user.getPasswordHash())) {
      return null;
    }
    
    // 마지막 로그인 시간 업데이트
    userDAO.updateLastLogin(user.getId());
    
    return user;
  }

  /**
   * 비밀번호 변경
   * @param userId 사용자 ID
   * @param currentPassword 현재 비밀번호
   * @param newPassword 새 비밀번호
   * @param newPasswordConfirm 새 비밀번호 확인
   * @return 오류 메시지 목록 (빈 리스트면 성공)
   */
  public List<String> changePassword(long userId, String currentPassword, String newPassword, String newPasswordConfirm) {
    List<String> errors = new ArrayList<>();
    
    // 현재 비밀번호 확인
    User user = userDAO.findById(userId);
    if (user == null) {
      errors.add("사용자를 찾을 수 없습니다.");
      return errors;
    }
    
    if (currentPassword == null || currentPassword.isEmpty()) {
      errors.add("현재 비밀번호를 입력해주세요.");
    } else if (!verifyPassword(currentPassword, user.getPasswordHash())) {
      errors.add("현재 비밀번호가 올바르지 않습니다.");
    }
    
    // 새 비밀번호 검증
    if (newPassword == null || newPassword.isEmpty()) {
      errors.add("새 비밀번호를 입력해주세요.");
    } else if (newPassword.length() < MIN_PASSWORD_LENGTH) {
      errors.add("새 비밀번호는 최소 8자 이상이어야 합니다.");
    }
    
    // 새 비밀번호 확인 검증
    if (newPasswordConfirm == null || newPasswordConfirm.isEmpty()) {
      errors.add("새 비밀번호 확인을 입력해주세요.");
    } else if (!newPassword.equals(newPasswordConfirm)) {
      errors.add("새 비밀번호가 일치하지 않습니다.");
    }
    
    // 현재 비밀번호와 새 비밀번호가 같은지 확인
    if (currentPassword != null && newPassword != null && 
        currentPassword.equals(newPassword)) {
      errors.add("새 비밀번호는 현재 비밀번호와 달라야 합니다.");
    }
    
    // 오류가 없으면 비밀번호 변경
    if (errors.isEmpty()) {
      String newPasswordHash = hashPassword(newPassword);
      if (!userDAO.updatePassword(userId, newPasswordHash)) {
        errors.add("비밀번호 변경 중 오류가 발생했습니다.");
      }
    }
    
    return errors;
  }
}

