package servlet;

import dao.UserFavoriteDAO;
import dao.AIToolDAO;
import dao.LabProjectDAO;
import dao.PackageDAO;
import model.User;
import model.UserFavorite;
import model.AITool;
import model.LabProject;
import model.Package;
import dto.ApiResponse;
import util.LoggerUtil;
import constants.AppConstants;
import com.google.gson.Gson;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 즐겨찾기 API 서블릿
 */
@WebServlet("/api/favorites/*")
public class FavoritesServlet extends HttpServlet {
    private UserFavoriteDAO favoriteDAO;
    private AIToolDAO toolDAO;
    private LabProjectDAO labDAO;
    private PackageDAO packageDAO;
    private Gson gson;
    
    @Override
    public void init() throws ServletException {
        favoriteDAO = new UserFavoriteDAO();
        toolDAO = new AIToolDAO();
        labDAO = new LabProjectDAO();
        packageDAO = new PackageDAO();
        gson = new Gson();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            // 사용자 인증 확인
            User currentUser = (User) request.getSession().getAttribute(AppConstants.SESSION_USER_KEY);
            if (currentUser == null || !currentUser.isActive()) {
                ApiResponse<Object> apiResponse = ApiResponse.unauthorized(AppConstants.Messages.UNAUTHORIZED);
                response.setStatus(AppConstants.HTTP_UNAUTHORIZED);
                out.print(gson.toJson(apiResponse));
                return;
            }
            
            String pathInfo = request.getPathInfo();
            String category = request.getParameter("category");
            
            if (pathInfo == null || pathInfo.equals("/")) {
                // 전체 즐겨찾기 목록
                List<UserFavorite> favorites = favoriteDAO.getUserFavorites(currentUser.getId());
                List<Map<String, Object>> favoriteDetails = new ArrayList<>();
                
                for (UserFavorite fav : favorites) {
                    Map<String, Object> detail = new HashMap<>();
                    detail.put("favorite", fav);
                    
                    // 해당 카테고리의 아이템 정보 가져오기
                    switch (fav.getCategory()) {
                        case "tool":
                            AITool tool = toolDAO.getToolById(fav.getToolId());
                            detail.put("item", tool);
                            break;
                        case "lab":
                            LabProject lab = labDAO.getLabProjectById(fav.getToolId());
                            detail.put("item", lab);
                            break;
                        case "package":
                            Package pkg = packageDAO.getPackageById(fav.getToolId());
                            detail.put("item", pkg);
                            break;
                    }
                    
                    favoriteDetails.add(detail);
                }
                
                ApiResponse<List<Map<String, Object>>> apiResponse = ApiResponse.success(favoriteDetails);
                out.print(gson.toJson(apiResponse));
                
            } else if (category != null) {
                // 특정 카테고리의 즐겨찾기
                List<UserFavorite> favorites = favoriteDAO.getUserFavoritesByCategory(currentUser.getId(), category);
                ApiResponse<List<UserFavorite>> apiResponse = ApiResponse.success(favorites);
                out.print(gson.toJson(apiResponse));
                
            } else {
                ApiResponse<Object> apiResponse = ApiResponse.badRequest("category 파라미터가 필요합니다.");
                response.setStatus(AppConstants.HTTP_BAD_REQUEST);
                out.print(gson.toJson(apiResponse));
            }
            
        } catch (Exception e) {
            LoggerUtil.logError(LoggerUtil.getLogger(getClass()), "Error retrieving favorites", e);
            ApiResponse<Object> apiResponse = ApiResponse.error(AppConstants.Messages.SERVER_ERROR);
            response.setStatus(AppConstants.HTTP_INTERNAL_ERROR);
            out.print(gson.toJson(apiResponse));
        }
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
                ApiResponse<Object> apiResponse = ApiResponse.unauthorized(AppConstants.Messages.UNAUTHORIZED);
                response.setStatus(AppConstants.HTTP_UNAUTHORIZED);
                out.print(gson.toJson(apiResponse));
                return;
            }
            
            String itemIdStr = request.getParameter("itemId");
            String category = request.getParameter("category");
            
            if (itemIdStr == null || category == null) {
                ApiResponse<Object> apiResponse = ApiResponse.badRequest("itemId와 category 파라미터가 필요합니다.");
                response.setStatus(AppConstants.HTTP_BAD_REQUEST);
                out.print(gson.toJson(apiResponse));
                return;
            }
            
            int itemId;
            try {
                itemId = Integer.parseInt(itemIdStr);
            } catch (NumberFormatException e) {
                ApiResponse<Object> apiResponse = ApiResponse.badRequest("잘못된 itemId 형식입니다.");
                response.setStatus(AppConstants.HTTP_BAD_REQUEST);
                out.print(gson.toJson(apiResponse));
                return;
            }
            
            // 카테고리 유효성 확인
            if (!"tool".equals(category) && !"lab".equals(category) && !"package".equals(category)) {
                ApiResponse<Object> apiResponse = ApiResponse.badRequest("유효하지 않은 카테고리입니다.");
                response.setStatus(AppConstants.HTTP_BAD_REQUEST);
                out.print(gson.toJson(apiResponse));
                return;
            }
            
            // 즐겨찾기 추가
            UserFavorite favorite = new UserFavorite(currentUser.getId(), itemId, category);
            boolean added = favoriteDAO.addFavorite(favorite);
            
            if (added) {
                ApiResponse<UserFavorite> apiResponse = ApiResponse.success("즐겨찾기에 추가되었습니다.", favorite);
                response.setStatus(AppConstants.HTTP_CREATED);
                out.print(gson.toJson(apiResponse));
                
                LoggerUtil.logInfo(LoggerUtil.getLogger(getClass()), 
                    "Favorite added: user=" + currentUser.getId() + ", item=" + itemId + ", category=" + category);
            } else {
                ApiResponse<Object> apiResponse = ApiResponse.error("즐겨찾기 추가에 실패했습니다.");
                response.setStatus(AppConstants.HTTP_INTERNAL_ERROR);
                out.print(gson.toJson(apiResponse));
            }
            
        } catch (Exception e) {
            LoggerUtil.logError(LoggerUtil.getLogger(getClass()), "Error adding favorite", e);
            ApiResponse<Object> apiResponse = ApiResponse.error(AppConstants.Messages.SERVER_ERROR);
            response.setStatus(AppConstants.HTTP_INTERNAL_ERROR);
            out.print(gson.toJson(apiResponse));
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
                ApiResponse<Object> apiResponse = ApiResponse.unauthorized(AppConstants.Messages.UNAUTHORIZED);
                response.setStatus(AppConstants.HTTP_UNAUTHORIZED);
                out.print(gson.toJson(apiResponse));
                return;
            }
            
            String pathInfo = request.getPathInfo();
            String category = request.getParameter("category");
            
            if (pathInfo == null || !pathInfo.startsWith("/")) {
                ApiResponse<Object> apiResponse = ApiResponse.badRequest("잘못된 요청 경로입니다.");
                response.setStatus(AppConstants.HTTP_BAD_REQUEST);
                out.print(gson.toJson(apiResponse));
                return;
            }
            
            int itemId;
            try {
                itemId = Integer.parseInt(pathInfo.substring(1));
            } catch (NumberFormatException e) {
                ApiResponse<Object> apiResponse = ApiResponse.badRequest("잘못된 itemId 형식입니다.");
                response.setStatus(AppConstants.HTTP_BAD_REQUEST);
                out.print(gson.toJson(apiResponse));
                return;
            }
            
            if (category == null) {
                ApiResponse<Object> apiResponse = ApiResponse.badRequest("category 파라미터가 필요합니다.");
                response.setStatus(AppConstants.HTTP_BAD_REQUEST);
                out.print(gson.toJson(apiResponse));
                return;
            }
            
            // 즐겨찾기 삭제
            boolean removed = favoriteDAO.removeFavorite(currentUser.getId(), itemId, category);
            
            if (removed) {
                ApiResponse<Object> apiResponse = ApiResponse.success("즐겨찾기에서 제거되었습니다.", null);
                out.print(gson.toJson(apiResponse));
                
                LoggerUtil.logInfo(LoggerUtil.getLogger(getClass()), 
                    "Favorite removed: user=" + currentUser.getId() + ", item=" + itemId + ", category=" + category);
            } else {
                ApiResponse<Object> apiResponse = ApiResponse.error("즐겨찾기 제거에 실패했습니다.");
                response.setStatus(AppConstants.HTTP_INTERNAL_ERROR);
                out.print(gson.toJson(apiResponse));
            }
            
        } catch (Exception e) {
            LoggerUtil.logError(LoggerUtil.getLogger(getClass()), "Error removing favorite", e);
            ApiResponse<Object> apiResponse = ApiResponse.error(AppConstants.Messages.SERVER_ERROR);
            response.setStatus(AppConstants.HTTP_INTERNAL_ERROR);
            out.print(gson.toJson(apiResponse));
        }
    }
    
    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            // 사용자 인증 확인
            User currentUser = (User) request.getSession().getAttribute(AppConstants.SESSION_USER_KEY);
            if (currentUser == null || !currentUser.isActive()) {
                ApiResponse<Object> apiResponse = ApiResponse.unauthorized(AppConstants.Messages.UNAUTHORIZED);
                response.setStatus(AppConstants.HTTP_UNAUTHORIZED);
                out.print(gson.toJson(apiResponse));
                return;
            }
            
            String itemIdStr = request.getParameter("itemId");
            String category = request.getParameter("category");
            
            if (itemIdStr == null || category == null) {
                ApiResponse<Object> apiResponse = ApiResponse.badRequest("itemId와 category 파라미터가 필요합니다.");
                response.setStatus(AppConstants.HTTP_BAD_REQUEST);
                out.print(gson.toJson(apiResponse));
                return;
            }
            
            int itemId;
            try {
                itemId = Integer.parseInt(itemIdStr);
            } catch (NumberFormatException e) {
                ApiResponse<Object> apiResponse = ApiResponse.badRequest("잘못된 itemId 형식입니다.");
                response.setStatus(AppConstants.HTTP_BAD_REQUEST);
                out.print(gson.toJson(apiResponse));
                return;
            }
            
            // 즐겨찾기 토글
            boolean toggled = favoriteDAO.toggleFavorite(currentUser.getId(), itemId, category);
            boolean isFavorite = favoriteDAO.isFavorite(currentUser.getId(), itemId, category);
            
            Map<String, Object> result = new HashMap<>();
            result.put("toggled", toggled);
            result.put("isFavorite", isFavorite);
            
            if (toggled) {
                String message = isFavorite ? "즐겨찾기에 추가되었습니다." : "즐겨찾기에서 제거되었습니다.";
                ApiResponse<Map<String, Object>> apiResponse = ApiResponse.success(message, result);
                out.print(gson.toJson(apiResponse));
                
                LoggerUtil.logInfo(LoggerUtil.getLogger(getClass()), 
                    "Favorite toggled: user=" + currentUser.getId() + ", item=" + itemId + ", category=" + category + ", isFavorite=" + isFavorite);
            } else {
                ApiResponse<Object> apiResponse = ApiResponse.error("즐겨찾기 토글에 실패했습니다.");
                response.setStatus(AppConstants.HTTP_INTERNAL_ERROR);
                out.print(gson.toJson(apiResponse));
            }
            
        } catch (Exception e) {
            LoggerUtil.logError(LoggerUtil.getLogger(getClass()), "Error toggling favorite", e);
            ApiResponse<Object> apiResponse = ApiResponse.error(AppConstants.Messages.SERVER_ERROR);
            response.setStatus(AppConstants.HTTP_INTERNAL_ERROR);
            out.print(gson.toJson(apiResponse));
        }
    }
}
