package util;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;
import javax.servlet.http.Part;

/**
 * 파일 업로드 유틸리티
 */
public class FileUploadUtil {
    
    private static final String UPLOAD_DIR = "/var/lib/tomcat9/webapps/ROOT/uploads";
    private static final String PROFILE_IMAGE_DIR = "profile-images";
    private static final long MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB
    private static final String[] ALLOWED_EXTENSIONS = {".jpg", ".jpeg", ".png", ".gif"};
    
    /**
     * 프로필 이미지 업로드
     * @param filePart 업로드된 파일
     * @param userId 사용자 ID
     * @return 저장된 파일명 또는 null (실패 시)
     */
    public static String uploadProfileImage(Part filePart, int userId) {
        if (filePart == null || filePart.getSize() == 0) {
            return null;
        }
        
        try {
            // 파일 크기 확인
            if (filePart.getSize() > MAX_FILE_SIZE) {
                return null;
            }
            
            // 파일 확장자 확인
            String fileName = filePart.getSubmittedFileName();
            String fileExtension = getFileExtension(fileName);
            
            if (!isAllowedExtension(fileExtension)) {
                return null;
            }
            
            // 업로드 디렉토리 생성
            Path uploadPath = Paths.get(UPLOAD_DIR, PROFILE_IMAGE_DIR);
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }
            
            // 고유 파일명 생성
            String uniqueFileName = generateUniqueFileName(userId, fileExtension);
            Path filePath = uploadPath.resolve(uniqueFileName);
            
            // 파일 저장
            Files.copy(filePart.getInputStream(), filePath);
            
            return uniqueFileName;
            
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * 기존 프로필 이미지 삭제
     * @param fileName 삭제할 파일명
     */
    public static void deleteProfileImage(String fileName) {
        if (fileName == null || fileName.trim().isEmpty()) {
            return;
        }
        
        try {
            Path filePath = Paths.get(UPLOAD_DIR, PROFILE_IMAGE_DIR, fileName);
            Files.deleteIfExists(filePath);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
    
    /**
     * 프로필 이미지 URL 가져오기
     * @param fileName 파일명
     * @return 이미지 URL
     */
    public static String getProfileImageUrl(String fileName) {
        if (fileName == null || fileName.trim().isEmpty()) {
            return "/AI/assets/images/default-profile.png";
        }
        
        return "/uploads/profile-images/" + fileName;
    }
    
    /**
     * 파일 확장자 추출
     * @param fileName 파일명
     * @return 확장자 (소문자)
     */
    private static String getFileExtension(String fileName) {
        if (fileName == null || fileName.lastIndexOf('.') == -1) {
            return "";
        }
        
        return fileName.substring(fileName.lastIndexOf('.')).toLowerCase();
    }
    
    /**
     * 허용된 확장자인지 확인
     * @param extension 확장자
     * @return 허용 여부
     */
    private static boolean isAllowedExtension(String extension) {
        if (extension == null || extension.isEmpty()) {
            return false;
        }
        
        for (String allowedExt : ALLOWED_EXTENSIONS) {
            if (allowedExt.equals(extension)) {
                return true;
            }
        }
        
        return false;
    }
    
    /**
     * 고유 파일명 생성
     * @param userId 사용자 ID
     * @param extension 파일 확장자
     * @return 고유 파일명
     */
    private static String generateUniqueFileName(int userId, String extension) {
        String timestamp = String.valueOf(System.currentTimeMillis());
        String uuid = UUID.randomUUID().toString().substring(0, 8);
        return "user_" + userId + "_" + timestamp + "_" + uuid + extension;
    }
    
    /**
     * 파일이 이미지인지 확인
     * @param filePart 파일 파트
     * @return 이미지 여부
     */
    public static boolean isImageFile(Part filePart) {
        if (filePart == null) {
            return false;
        }
        
        String contentType = filePart.getContentType();
        return contentType != null && contentType.startsWith("image/");
    }
    
    /**
     * 파일 크기가 허용 범위 내인지 확인
     * @param filePart 파일 파트
     * @return 허용 여부
     */
    public static boolean isFileSizeAllowed(Part filePart) {
        if (filePart == null) {
            return false;
        }
        
        return filePart.getSize() <= MAX_FILE_SIZE;
    }
}
