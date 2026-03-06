package servlet;

import dao.UserDAO;
import model.User;
import util.FileUploadUtil;
import util.LoggerUtil;
import constants.AppConstants;
import com.google.gson.Gson;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;

/**
 * 프로필 이미지 업로드 서블릿
 */
@WebServlet("/api/user/profile-image")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024, // 1 MB
    maxFileSize = 10 * 1024 * 1024, // 10 MB
    maxRequestSize = 11 * 1024 * 1024 // 11 MB
)
public class ProfileImageUploadServlet extends HttpServlet {
    private UserDAO userDAO;
    private Gson gson;
    
    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
        gson = new Gson();
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            // 사용자 인증 확인
            User currentUser = (User) request.getSession().getAttribute(AppConstants.SESSION_USER_KEY);
            if (currentUser == null || !currentUser.isActive()) {
                Map<String, Object> errorResponse = new HashMap<>();
                errorResponse.put("success", false);
                errorResponse.put("message", AppConstants.Messages.UNAUTHORIZED);
                response.setStatus(AppConstants.HTTP_UNAUTHORIZED);
                out.print(gson.toJson(errorResponse));
                return;
            }
            
            // 파일 파트 가져오기
            Part filePart = request.getPart("profileImage");
            if (filePart == null) {
                Map<String, Object> errorResponse = new HashMap<>();
                errorResponse.put("success", false);
                errorResponse.put("message", "파일을 선택해주세요.");
                response.setStatus(AppConstants.HTTP_BAD_REQUEST);
                out.print(gson.toJson(errorResponse));
                return;
            }
            
            // 파일 유효성 검사
            if (!FileUploadUtil.isImageFile(filePart)) {
                Map<String, Object> errorResponse = new HashMap<>();
                errorResponse.put("success", false);
                errorResponse.put("message", "이미지 파일만 업로드할 수 있습니다.");
                response.setStatus(AppConstants.HTTP_BAD_REQUEST);
                out.print(gson.toJson(errorResponse));
                return;
            }
            
            if (!FileUploadUtil.isFileSizeAllowed(filePart)) {
                Map<String, Object> errorResponse = new HashMap<>();
                errorResponse.put("success", false);
                errorResponse.put("message", "파일 크기는 10MB 이하여야 합니다.");
                response.setStatus(AppConstants.HTTP_BAD_REQUEST);
                out.print(gson.toJson(errorResponse));
                return;
            }
            
            // 기존 프로필 이미지 삭제
            String oldImageName = currentUser.getProfileImageUrl();
            if (oldImageName != null && !oldImageName.isEmpty()) {
                FileUploadUtil.deleteProfileImage(oldImageName);
            }
            
            // 새 이미지 업로드
            String newImageName = FileUploadUtil.uploadProfileImage(filePart, currentUser.getId());
            if (newImageName == null) {
                Map<String, Object> errorResponse = new HashMap<>();
                errorResponse.put("success", false);
                errorResponse.put("message", "이미지 업로드에 실패했습니다.");
                response.setStatus(AppConstants.HTTP_INTERNAL_ERROR);
                out.print(gson.toJson(errorResponse));
                return;
            }
            
            // 사용자 정보 업데이트
            currentUser.setProfileImageUrl(newImageName);
            boolean updated = userDAO.updateProfileImage(currentUser.getId(), newImageName);
            
            if (updated) {
                // 세션 정보 업데이트
                request.getSession().setAttribute(AppConstants.SESSION_USER_KEY, currentUser);
                
                Map<String, Object> successResponse = new HashMap<>();
                successResponse.put("success", true);
                successResponse.put("message", "프로필 이미지가 업로드되었습니다.");
                successResponse.put("imageUrl", FileUploadUtil.getProfileImageUrl(newImageName));
                out.print(gson.toJson(successResponse));
                
                LoggerUtil.logInfo(LoggerUtil.getLogger(getClass()), 
                    "Profile image uploaded for user ID: " + currentUser.getId());
            } else {
                Map<String, Object> errorResponse = new HashMap<>();
                errorResponse.put("success", false);
                errorResponse.put("message", "프로필 정보 업데이트에 실패했습니다.");
                response.setStatus(AppConstants.HTTP_INTERNAL_ERROR);
                out.print(gson.toJson(errorResponse));
            }
            
        } catch (Exception e) {
            LoggerUtil.logError(LoggerUtil.getLogger(getClass()), 
                "Error uploading profile image", e);
            
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", AppConstants.Messages.SERVER_ERROR);
            response.setStatus(AppConstants.HTTP_INTERNAL_ERROR);
            out.print(gson.toJson(errorResponse));
        }
    }
    
    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            // 사용자 인증 확인
            User currentUser = (User) request.getSession().getAttribute(AppConstants.SESSION_USER_KEY);
            if (currentUser == null || !currentUser.isActive()) {
                Map<String, Object> errorResponse = new HashMap<>();
                errorResponse.put("success", false);
                errorResponse.put("message", AppConstants.Messages.UNAUTHORIZED);
                response.setStatus(AppConstants.HTTP_UNAUTHORIZED);
                out.print(gson.toJson(errorResponse));
                return;
            }
            
            // 기존 프로필 이미지 삭제
            String oldImageName = currentUser.getProfileImageUrl();
            if (oldImageName != null && !oldImageName.isEmpty()) {
                FileUploadUtil.deleteProfileImage(oldImageName);
                
                // 사용자 정보 업데이트
                currentUser.setProfileImageUrl(null);
                boolean updated = userDAO.updateProfileImage(currentUser.getId(), null);
                
                if (updated) {
                    // 세션 정보 업데이트
                    request.getSession().setAttribute(AppConstants.SESSION_USER_KEY, currentUser);
                    
                    Map<String, Object> successResponse = new HashMap<>();
                    successResponse.put("success", true);
                    successResponse.put("message", "프로필 이미지가 삭제되었습니다.");
                    successResponse.put("imageUrl", FileUploadUtil.getProfileImageUrl(null));
                    out.print(gson.toJson(successResponse));
                    
                    LoggerUtil.logInfo(LoggerUtil.getLogger(getClass()), 
                        "Profile image deleted for user ID: " + currentUser.getId());
                } else {
                    Map<String, Object> errorResponse = new HashMap<>();
                    errorResponse.put("success", false);
                    errorResponse.put("message", "프로필 정보 업데이트에 실패했습니다.");
                    response.setStatus(AppConstants.HTTP_INTERNAL_ERROR);
                    out.print(gson.toJson(errorResponse));
                }
            } else {
                Map<String, Object> errorResponse = new HashMap<>();
                errorResponse.put("success", false);
                errorResponse.put("message", "삭제할 프로필 이미지가 없습니다.");
                response.setStatus(AppConstants.HTTP_BAD_REQUEST);
                out.print(gson.toJson(errorResponse));
            }
            
        } catch (Exception e) {
            LoggerUtil.logError(LoggerUtil.getLogger(getClass()), 
                "Error deleting profile image", e);
            
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", AppConstants.Messages.SERVER_ERROR);
            response.setStatus(AppConstants.HTTP_INTERNAL_ERROR);
            out.print(gson.toJson(errorResponse));
        }
    }
}
