package constants;

/**
 * 애플리케이션 상수 정의
 */
public class AppConstants {
    
    // HTTP 상태 코드
    public static final int HTTP_OK = 200;
    public static final int HTTP_CREATED = 201;
    public static final int HTTP_BAD_REQUEST = 400;
    public static final int HTTP_UNAUTHORIZED = 401;
    public static final int HTTP_FORBIDDEN = 403;
    public static final int HTTP_NOT_FOUND = 404;
    public static final int HTTP_INTERNAL_ERROR = 500;
    
    // 세션 관련
    public static final int SESSION_TIMEOUT_MINUTES = 30;
    public static final String SESSION_USER_KEY = "user";
    public static final String CSRF_TOKEN_KEY = "csrf_token";
    public static final String CSRF_TOKEN_PARAM = "csrf_token";
    
    // 데이터베이스 관련
    public static final int DEFAULT_PAGE_SIZE = 20;
    public static final int MAX_PAGE_SIZE = 100;
    public static final String DB_DATE_FORMAT = "yyyy-MM-dd HH:mm:ss";
    
    // 사용자 관련
    public static final int PASSWORD_MIN_LENGTH = 8;
    public static final String EMAIL_REGEX = "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}";
    
    // 파일 관련
    public static final long MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB
    public static final String[] ALLOWED_IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".gif"};
    
    // API 관련
    public static final String API_CONTENT_TYPE = "application/json";
    public static final String API_CHARSET = "UTF-8";
    
    // 보안 관련
    public static final int BCRYPT_COST = 12;
    public static final int TOKEN_LENGTH_BYTES = 32;
    
    // 메시지 상수
    public static final class Messages {
        public static final String SUCCESS = "ok";
        public static final String CREATED = "생성되었습니다.";
        public static final String UPDATED = "업데이트되었습니다.";
        public static final String DELETED = "삭제되었습니다.";
        public static final String NOT_FOUND = "찾을 수 없습니다.";
        public static final String BAD_REQUEST = "잘못된 요청입니다.";
        public static final String UNAUTHORIZED = "인증이 필요합니다.";
        public static final String FORBIDDEN = "접근 권한이 없습니다.";
        public static final String SERVER_ERROR = "서버 오류가 발생했습니다.";
        public static final String CSRF_ERROR = "보안 검증에 실패했습니다. 다시 시도해주세요.";
        
        // 사용자 관련 메시지
        public static final String USER_NOT_FOUND = "사용자를 찾을 수 없습니다.";
        public static final String USER_CREATED = "사용자가 생성되었습니다.";
        public static final String USER_UPDATED = "사용자 정보가 업데이트되었습니다.";
        public static final String USER_DELETED = "사용자가 삭제되었습니다.";
        public static final String EMAIL_EXISTS = "이미 사용 중인 이메일입니다.";
        public static final String INVALID_CREDENTIALS = "이메일 또는 비밀번호가 올바르지 않습니다.";
        
        // AI 도구 관련 메시지
        public static final String TOOL_NOT_FOUND = "AI 도구를 찾을 수 없습니다.";
        public static final String TOOL_CREATED = "AI 도구가 생성되었습니다.";
        public static final String TOOL_UPDATED = "AI 도구 정보가 업데이트되었습니다.";
        public static final String TOOL_DELETED = "AI 도구가 삭제되었습니다.";
        
        // 랩 관련 메시지
        public static final String LAB_NOT_FOUND = "랩 프로젝트를 찾을 수 없습니다.";
        public static final String LAB_CREATED = "랩 프로젝트가 생성되었습니다.";
        public static final String LAB_UPDATED = "랩 프로젝트 정보가 업데이트되었습니다.";
        public static final String LAB_DELETED = "랩 프로젝트가 삭제되었습니다.";
        
        // 패키지 관련 메시지
        public static final String PACKAGE_NOT_FOUND = "패키지를 찾을 수 없습니다.";
        public static final String PACKAGE_CREATED = "패키지가 생성되었습니다.";
        public static final String PACKAGE_UPDATED = "패키지 정보가 업데이트되었습니다.";
        public static final String PACKAGE_DELETED = "패키지가 삭제되었습니다.";
        
        // 카테고리 관련 메시지
        public static final String CATEGORY_NOT_FOUND = "카테고리를 찾을 수 없습니다.";
        public static final String CATEGORY_CREATED = "카테고리가 생성되었습니다.";
        public static final String CATEGORY_UPDATED = "카테고리 정보가 업데이트되었습니다.";
        public static final String CATEGORY_DELETED = "카테고리가 삭제되었습니다.";
    }
    
    // SQL 쿼리 상수
    public static final class Queries {
        // 사용자 관련
        public static final String USER_SELECT_ALL = "SELECT * FROM users WHERE is_active = 1 ORDER BY created_at DESC";
        public static final String USER_SELECT_BY_ID = "SELECT * FROM users WHERE id = ?";
        public static final String USER_SELECT_BY_EMAIL = "SELECT * FROM users WHERE email = ?";
        public static final String USER_INSERT = "INSERT INTO users (email, password_hash, full_name, is_active) VALUES (?, ?, ?, ?)";
        public static final String USER_UPDATE = "UPDATE users SET email = ?, full_name = ?, is_active = ?, updated_at = NOW() WHERE id = ?";
        public static final String USER_DELETE = "UPDATE users SET is_active = 0 WHERE id = ?";
        
        // AI 도구 관련
        public static final String TOOL_SELECT_ALL = "SELECT * FROM ai_tools WHERE is_active = 1 ORDER BY created_at DESC";
        public static final String TOOL_SELECT_BY_ID = "SELECT * FROM ai_tools WHERE id = ?";
        public static final String TOOL_SEARCH = "SELECT * FROM ai_tools WHERE tool_name LIKE ? OR description LIKE ? OR purpose_summary LIKE ?";
        
        // 카테고리 관련
        public static final String CATEGORY_SELECT_ALL = "SELECT * FROM categories ORDER BY display_order ASC, category_name ASC";
        public static final String CATEGORY_SELECT_ACTIVE = "SELECT * FROM categories WHERE is_active = 1 ORDER BY display_order ASC, category_name ASC";
        public static final String CATEGORY_SELECT_BY_ID = "SELECT * FROM categories WHERE id = ?";
        public static final String CATEGORY_MAX_ORDER = "SELECT MAX(display_order) FROM categories";
    }
}
