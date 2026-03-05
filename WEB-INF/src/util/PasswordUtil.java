package util;

import java.security.SecureRandom;
import java.util.Base64;
import at.favre.lib.crypto.bcrypt.BCrypt;

public class PasswordUtil {
    private static final int BCRYPT_COST = 12;
    private static final SecureRandom secureRandom = new SecureRandom();
    
    /**
     * 비밀번호를 BCrypt로 해싱
     * @param plainPassword 평문 비밀번호
     * @return 해싱된 비밀번호
     */
    public static String hashPassword(String plainPassword) {
        return BCrypt.withDefaults().hashToString(BCRYPT_COST, plainPassword.toCharArray());
    }
    
    /**
     * 비밀번호 검증
     * @param plainPassword 평문 비밀번호
     * @param hashedPassword 해싱된 비밀번호
     * @return 일치 여부
     */
    public static boolean verifyPassword(String plainPassword, String hashedPassword) {
        return BCrypt.verifyer().verify(plainPassword.toCharArray(), hashedPassword).verified;
    }
    
    /**
     * 안전한 임시 비밀번호 생성
     * @param length 생성할 비밀번호 길이
     * @return 생성된 임시 비밀번호
     */
    public static String generateSecurePassword(int length) {
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*";
        StringBuilder password = new StringBuilder();
        
        for (int i = 0; i < length; i++) {
            password.append(chars.charAt(secureRandom.nextInt(chars.length())));
        }
        
        return password.toString();
    }
    
    /**
     * API 키 생성
     * @return 생성된 API 키
     */
    public static String generateApiKey() {
        byte[] randomBytes = new byte[32];
        secureRandom.nextBytes(randomBytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(randomBytes);
    }
    
    /**
     * 세션 토큰 생성
     * @return 생성된 세션 토큰
     */
    public static String generateSessionToken() {
        byte[] randomBytes = new byte[64];
        secureRandom.nextBytes(randomBytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(randomBytes);
    }
    
    /**
     * 비밀번호 강도 체크
     * @param password 검사할 비밀번호
     * @return 강도 점수 (0-100)
     */
    public static int checkPasswordStrength(String password) {
        int score = 0;
        
        // 길이 체크
        if (password.length() >= 8) score += 20;
        if (password.length() >= 12) score += 10;
        
        // 문자 종류 체크
        boolean hasLower = password.matches(".*[a-z].*");
        boolean hasUpper = password.matches(".*[A-Z].*");
        boolean hasDigit = password.matches(".*\\d.*");
        boolean hasSpecial = password.matches(".*[!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>\\/?].*");
        
        if (hasLower) score += 15;
        if (hasUpper) score += 15;
        if (hasDigit) score += 15;
        if (hasSpecial) score += 15;
        
        // 연속 문자 체크
        if (!password.matches(".*(.)\\1\\1.*")) score += 10;
        
        return Math.min(score, 100);
    }
}
