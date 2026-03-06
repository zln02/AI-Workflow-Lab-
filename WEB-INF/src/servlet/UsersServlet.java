package servlet;

import dao.UserDAO;
import model.User;
import dto.ApiResponse;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

/**
 * 사용자 API 서블릿
 * /api/users/* 경로로 들어오는 요청 처리
 */
@WebServlet("/api/users/*")
public class UsersServlet extends HttpServlet {
    private UserDAO userDAO;
    private Gson gson;
    
    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
        gson = new GsonBuilder().setDateFormat("yyyy-MM-dd HH:mm:ss").create();
    }
    
    private boolean isAdmin(HttpServletRequest request) {
        javax.servlet.http.HttpSession s = request.getSession(false);
        return s != null && s.getAttribute("admin") != null;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        if (!isAdmin(request)) {
            ApiResponse<Object> apiResponse = ApiResponse.error("관리자 권한이 필요합니다.");
            response.setStatus(403);
            out.print(gson.toJson(apiResponse));
            return;
        }

        try {
            String pathInfo = request.getPathInfo();
            
            if (pathInfo == null || pathInfo.equals("/")) {
                // 전체 사용자 목록 (관리자용)
                List<User> users = userDAO.findAll();
                ApiResponse<List<User>> apiResponse = ApiResponse.success(users);
                out.print(gson.toJson(apiResponse));
                
            } else if (pathInfo.startsWith("/")) {
                // 특정 사용자 정보
                try {
                    int userId = Integer.parseInt(pathInfo.substring(1));
                    User user = userDAO.findById(userId);
                    
                    if (user != null) {
                        // 비밀번호 해시는 제외하고 응답
                        user.setPasswordHash(null);
                        ApiResponse<User> apiResponse = ApiResponse.success(user);
                        out.print(gson.toJson(apiResponse));
                    } else {
                        ApiResponse<Object> apiResponse = ApiResponse.notFound("사용자를 찾을 수 없습니다.");
                        response.setStatus(404);
                        out.print(gson.toJson(apiResponse));
                    }
                } catch (NumberFormatException e) {
                    ApiResponse<Object> apiResponse = ApiResponse.badRequest("잘못된 사용자 ID 형식입니다.");
                    response.setStatus(400);
                    out.print(gson.toJson(apiResponse));
                }
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            ApiResponse<Object> apiResponse = ApiResponse.error("서버 오류가 발생했습니다.");
            response.setStatus(500);
            out.print(gson.toJson(apiResponse));
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        if (!isAdmin(request)) {
            ApiResponse<Object> apiResponse = ApiResponse.error("관리자 권한이 필요합니다.");
            response.setStatus(403);
            out.print(gson.toJson(apiResponse));
            return;
        }

        try {
            // 사용자 생성 로직
            String email = request.getParameter("email");
            String password = request.getParameter("password");
            String name = request.getParameter("name");
            
            if (email == null || password == null || name == null) {
                ApiResponse<Object> apiResponse = ApiResponse.badRequest("필수 파라미터가 누락되었습니다.");
                response.setStatus(400);
                out.print(gson.toJson(apiResponse));
                return;
            }
            
            // 이메일 중복 확인
            User existingUser = userDAO.findByEmail(email);
            if (existingUser != null) {
                ApiResponse<Object> apiResponse = ApiResponse.badRequest("이미 사용 중인 이메일입니다.");
                response.setStatus(400);
                out.print(gson.toJson(apiResponse));
                return;
            }
            
            // 사용자 생성
            User newUser = new User();
            newUser.setEmail(email);
            newUser.setPasswordHash(password); // Service에서 해싱 처리
            newUser.setFullName(name);
            newUser.setActive(true);
            
            boolean created = userDAO.create(newUser);
            
            if (created) {
                newUser.setPasswordHash(null); // 응답에서 비밀번호 제거
                ApiResponse<User> apiResponse = ApiResponse.success("사용자가 생성되었습니다.", newUser);
                response.setStatus(201);
                out.print(gson.toJson(apiResponse));
            } else {
                ApiResponse<Object> apiResponse = ApiResponse.error("사용자 생성에 실패했습니다.");
                response.setStatus(500);
                out.print(gson.toJson(apiResponse));
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            ApiResponse<Object> apiResponse = ApiResponse.error("서버 오류가 발생했습니다.");
            response.setStatus(500);
            out.print(gson.toJson(apiResponse));
        }
    }
    
    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        if (!isAdmin(request)) {
            ApiResponse<Object> apiResponse = ApiResponse.error("관리자 권한이 필요합니다.");
            response.setStatus(403);
            out.print(gson.toJson(apiResponse));
            return;
        }

        try {
            String pathInfo = request.getPathInfo();

            if (pathInfo == null || !pathInfo.startsWith("/")) {
                ApiResponse<Object> apiResponse = ApiResponse.badRequest("잘못된 요청 경로입니다.");
                response.setStatus(400);
                out.print(gson.toJson(apiResponse));
                return;
            }
            
            int userId = Integer.parseInt(pathInfo.substring(1));
            User user = userDAO.findById(userId);
            
            if (user == null) {
                ApiResponse<Object> apiResponse = ApiResponse.notFound("사용자를 찾을 수 없습니다.");
                response.setStatus(404);
                out.print(gson.toJson(apiResponse));
                return;
            }
            
            // 사용자 정보 업데이트
            String name = request.getParameter("name");
            String email = request.getParameter("email");
            String status = request.getParameter("status");
            
            if (name != null) user.setFullName(name);
            if (email != null) user.setEmail(email);
            if (status != null) user.setActive("active".equalsIgnoreCase(status));
            
            boolean updated = userDAO.update(user);
            
            if (updated) {
                user.setPasswordHash(null); // 응답에서 비밀번호 제거
                ApiResponse<User> apiResponse = ApiResponse.success("사용자 정보가 업데이트되었습니다.", user);
                out.print(gson.toJson(apiResponse));
            } else {
                ApiResponse<Object> apiResponse = ApiResponse.error("사용자 정보 업데이트에 실패했습니다.");
                response.setStatus(500);
                out.print(gson.toJson(apiResponse));
            }
            
        } catch (NumberFormatException e) {
            ApiResponse<Object> apiResponse = ApiResponse.badRequest("잘못된 사용자 ID 형식입니다.");
            response.setStatus(400);
            out.print(gson.toJson(apiResponse));
        } catch (Exception e) {
            e.printStackTrace();
            ApiResponse<Object> apiResponse = ApiResponse.error("서버 오류가 발생했습니다.");
            response.setStatus(500);
            out.print(gson.toJson(apiResponse));
        }
    }
    
    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        if (!isAdmin(request)) {
            ApiResponse<Object> apiResponse = ApiResponse.error("관리자 권한이 필요합니다.");
            response.setStatus(403);
            out.print(gson.toJson(apiResponse));
            return;
        }

        try {
            String pathInfo = request.getPathInfo();

            if (pathInfo == null || !pathInfo.startsWith("/")) {
                ApiResponse<Object> apiResponse = ApiResponse.badRequest("잘못된 요청 경로입니다.");
                response.setStatus(400);
                out.print(gson.toJson(apiResponse));
                return;
            }
            
            int userId = Integer.parseInt(pathInfo.substring(1));
            User user = userDAO.findById(userId);
            
            if (user == null) {
                ApiResponse<Object> apiResponse = ApiResponse.notFound("사용자를 찾을 수 없습니다.");
                response.setStatus(404);
                out.print(gson.toJson(apiResponse));
                return;
            }
            
            boolean deleted = userDAO.deactivate(userId);
            
            if (deleted) {
                ApiResponse<Object> apiResponse = ApiResponse.success("사용자가 삭제되었습니다.", null);
                out.print(gson.toJson(apiResponse));
            } else {
                ApiResponse<Object> apiResponse = ApiResponse.error("사용자 삭제에 실패했습니다.");
                response.setStatus(500);
                out.print(gson.toJson(apiResponse));
            }
            
        } catch (NumberFormatException e) {
            ApiResponse<Object> apiResponse = ApiResponse.badRequest("잘못된 사용자 ID 형식입니다.");
            response.setStatus(400);
            out.print(gson.toJson(apiResponse));
        } catch (Exception e) {
            e.printStackTrace();
            ApiResponse<Object> apiResponse = ApiResponse.error("서버 오류가 발생했습니다.");
            response.setStatus(500);
            out.print(gson.toJson(apiResponse));
        }
    }
}
