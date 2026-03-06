package dto;

import java.util.Map;

/**
 * 통일된 API 응답 포맷
 */
public class ApiResponse<T> {
    private int status;
    private String message;
    private T data;
    private Map<String, Object> meta;
    
    public ApiResponse() {}
    
    public ApiResponse(int status, String message) {
        this.status = status;
        this.message = message;
    }
    
    public ApiResponse(int status, String message, T data) {
        this.status = status;
        this.message = message;
        this.data = data;
    }
    
    public static <T> ApiResponse<T> success(T data) {
        return new ApiResponse<>(200, "ok", data);
    }
    
    public static <T> ApiResponse<T> success(String message, T data) {
        return new ApiResponse<>(200, message, data);
    }
    
    public static <T> ApiResponse<T> error(String message) {
        return new ApiResponse<>(500, message);
    }
    
    public static <T> ApiResponse<T> error(int status, String message) {
        return new ApiResponse<>(status, message);
    }
    
    public static <T> ApiResponse<T> badRequest(String message) {
        return new ApiResponse<>(400, message);
    }
    
    public static <T> ApiResponse<T> unauthorized(String message) {
        return new ApiResponse<>(401, message);
    }
    
    public static <T> ApiResponse<T> forbidden(String message) {
        return new ApiResponse<>(403, message);
    }
    
    public static <T> ApiResponse<T> notFound(String message) {
        return new ApiResponse<>(404, message);
    }
    
    // Getters and Setters
    public int getStatus() { return status; }
    public void setStatus(int status) { this.status = status; }
    
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    
    public T getData() { return data; }
    public void setData(T data) { this.data = data; }
    
    public Map<String, Object> getMeta() { return meta; }
    public void setMeta(Map<String, Object> meta) { this.meta = meta; }
}
