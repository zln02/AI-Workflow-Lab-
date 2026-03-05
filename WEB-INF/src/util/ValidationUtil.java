package util;

import java.util.regex.Pattern;
import javax.servlet.http.HttpServletRequest;

public class ValidationUtil {
    
    // 이메일 정규식
    private static final Pattern EMAIL_PATTERN = Pattern.compile(
        "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
    );
    
    // 비밀번호 정규식 (최소 8자, 대소문자, 숫자, 특수문자 포함)
    private static final Pattern PASSWORD_PATTERN = Pattern.compile(
        "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>\\/?]).{8,}$"
    );
    
    // 사용자명 정규식 (알파벳, 숫자, 밑줄, 하이픈, 3-20자)
    private static final Pattern USERNAME_PATTERN = Pattern.compile(
        "^[a-zA-Z0-9_-]{3,20}$"
    );
    
    // SQL 인젝션 패턴
    private static final Pattern[] SQL_INJECTION_PATTERNS = {
        Pattern.compile("(?i)(union|select|insert|update|delete|drop|create|alter|exec|execute)"),
        Pattern.compile("(?i)(script|javascript|vbscript|onload|onerror)"),
        Pattern.compile("(?i)(('|(\\-\\-)|(;)|(\\|)|(\\*)|(%7C))"),
        Pattern.compile("(?i)(or|and)(\\s+)(\\d+\\s*=\\s*\\d+)")
    };
    
    /**
     * 이메일 유효성 검사
     */
    public static boolean isValidEmail(String email) {
        return email != null && EMAIL_PATTERN.matcher(email).matches();
    }
    
    /**
     * 비밀번호 유효성 검사
     */
    public static boolean isValidPassword(String password) {
        return password != null && PASSWORD_PATTERN.matcher(password).matches();
    }
    
    /**
     * 사용자명 유효성 검사
     */
    public static boolean isValidUsername(String username) {
        return username != null && USERNAME_PATTERN.matcher(username).matches();
    }
    
    /**
     * SQL 인젝션 가능성 체크
     */
    public static boolean containsSqlInjection(String input) {
        if (input == null) return false;
        
        for (Pattern pattern : SQL_INJECTION_PATTERNS) {
            if (pattern.matcher(input).find()) {
                return true;
            }
        }
        return false;
    }
    
    /**
     * XSS 방지를 위한 입력값 정화
     */
    public static String sanitizeInput(String input) {
        if (input == null) return "";
        
        return input
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#x27;")
            .replace("/", "&#x2F;")
            .replace("(", "&#40;")
            .replace(")", "&#41;")
            .trim();
    }
    
    /**
     * 문자열 길이 검증
     */
    public static boolean isValidLength(String input, int minLength, int maxLength) {
        if (input == null) return false;
        return input.length() >= minLength && input.length() <= maxLength;
    }
    
    /**
     * 숫자인지 검증
     */
    public static boolean isNumeric(String input) {
        if (input == null) return false;
        return input.matches("\\d+");
    }
    
    /**
     * 요청 파라미터에서 안전한 문자열 추출
     */
    public static String getSafeParameter(HttpServletRequest request, String paramName, int maxLength) {
        String value = request.getParameter(paramName);
        if (value == null) return "";
        
        // 길이 제한
        if (value.length() > maxLength) {
            value = value.substring(0, maxLength);
        }
        
        // SQL 인젝션 체크
        if (containsSqlInjection(value)) {
            throw new SecurityException("Potential SQL injection detected");
        }
        
        return sanitizeInput(value);
    }
    
    /**
     * 요청 파라미터에서 안전한 숫자 추출
     */
    public static int getSafeIntParameter(HttpServletRequest request, String paramName, int defaultValue) {
        String value = request.getParameter(paramName);
        if (value == null || !isNumeric(value)) {
            return defaultValue;
        }
        
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }
    
    /**
     * CSRF 토큰 검증
     */
    public static boolean validateCsrfToken(HttpServletRequest request, String token) {
        String sessionToken = (String) request.getSession().getAttribute("CSRF_TOKEN");
        return sessionToken != null && sessionToken.equals(token);
    }
    
    /**
     * 파일 업로드 확장자 검증
     */
    public static boolean isValidFileExtension(String filename, String[] allowedExtensions) {
        if (filename == null) return false;
        
        String extension = filename.substring(filename.lastIndexOf(".") + 1).toLowerCase();
        for (String allowed : allowedExtensions) {
            if (allowed.equalsIgnoreCase(extension)) {
                return true;
            }
        }
        return false;
    }
}
