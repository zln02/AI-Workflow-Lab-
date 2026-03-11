package servlet;

import dao.LabProjectDAO;
import model.LabProject;
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
import java.util.HashMap;
import java.util.Map;

/**
 * 실습 랩 API 서블릿
 * /api/labs/* 경로로 들어오는 요청 처리
 */
@WebServlet("/api/labs/*")
public class LabsServlet extends HttpServlet {
    private LabProjectDAO labDAO;
    private Gson gson;
    
    @Override
    public void init() throws ServletException {
        labDAO = new LabProjectDAO();
        gson = new GsonBuilder().setDateFormat("yyyy-MM-dd HH:mm:ss").create();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            String pathInfo = request.getPathInfo();
            
            if (pathInfo == null || pathInfo.equals("/")) {
                // 전체 랩 프로젝트 목록
                List<LabProject> labs = labDAO.findAll();
                ApiResponse<List<LabProject>> apiResponse = ApiResponse.success(labs);
                out.print(gson.toJson(apiResponse));
                
            } else if (pathInfo.startsWith("/")) {
                // 특정 랩 프로젝트 정보
                try {
                    int labId = Integer.parseInt(pathInfo.substring(1));
                    LabProject lab = labDAO.findById(labId);
                    
                    if (lab != null) {
                        ApiResponse<LabProject> apiResponse = ApiResponse.success(lab);
                        out.print(gson.toJson(apiResponse));
                    } else {
                        ApiResponse<Object> apiResponse = ApiResponse.notFound("랩 프로젝트를 찾을 수 없습니다.");
                        response.setStatus(404);
                        out.print(gson.toJson(apiResponse));
                    }
                } catch (NumberFormatException e) {
                    ApiResponse<Object> apiResponse = ApiResponse.badRequest("잘못된 랩 ID 형식입니다.");
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
        
        try {
            // 랩 프로젝트 생성 로직
            String title = request.getParameter("title");
            String description = request.getParameter("description");
            String difficulty = request.getParameter("difficulty");
            String category = request.getParameter("category");
            Integer duration = null;
            
            try {
                String durationStr = request.getParameter("duration");
                if (durationStr != null) {
                    duration = Integer.parseInt(durationStr);
                }
            } catch (NumberFormatException e) {
                // duration은 선택적 파라미터
            }
            
            if (title == null || description == null || difficulty == null || category == null) {
                ApiResponse<Object> apiResponse = ApiResponse.badRequest("필수 파라미터가 누락되었습니다.");
                response.setStatus(400);
                out.print(gson.toJson(apiResponse));
                return;
            }
            
            // 랩 프로젝트 생성
            LabProject newLab = new LabProject();
            newLab.setTitle(title);
            newLab.setDescription(description);
            newLab.setDifficultyLevel(difficulty);
            newLab.setCategory(category);
            newLab.setEstimatedDurationHours(duration != null ? duration.doubleValue() : null);
            newLab.setActive(true);

            boolean created = labDAO.create(newLab);
            
            if (created) {
                ApiResponse<LabProject> apiResponse = ApiResponse.success("랩 프로젝트가 생성되었습니다.", newLab);
                response.setStatus(201);
                out.print(gson.toJson(apiResponse));
            } else {
                ApiResponse<Object> apiResponse = ApiResponse.error("랩 프로젝트 생성에 실패했습니다.");
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
        
        try {
            String pathInfo = request.getPathInfo();
            
            if (pathInfo == null || !pathInfo.startsWith("/")) {
                ApiResponse<Object> apiResponse = ApiResponse.badRequest("잘못된 요청 경로입니다.");
                response.setStatus(400);
                out.print(gson.toJson(apiResponse));
                return;
            }
            
            int labId = Integer.parseInt(pathInfo.substring(1));
            LabProject lab = labDAO.findById(labId);

            if (lab == null) {
                ApiResponse<Object> apiResponse = ApiResponse.notFound("랩 프로젝트를 찾을 수 없습니다.");
                response.setStatus(404);
                out.print(gson.toJson(apiResponse));
                return;
            }

            // 랩 프로젝트 정보 업데이트
            String title = request.getParameter("title");
            String description = request.getParameter("description");
            String difficulty = request.getParameter("difficulty");
            String category = request.getParameter("category");
            String status = request.getParameter("status");

            if (title != null) lab.setTitle(title);
            if (description != null) lab.setDescription(description);
            if (difficulty != null) lab.setDifficultyLevel(difficulty);
            if (category != null) lab.setCategory(category);
            if (status != null) lab.setActive("active".equalsIgnoreCase(status));

            try {
                String durationStr = request.getParameter("duration");
                if (durationStr != null) {
                    lab.setEstimatedDurationHours(Double.parseDouble(durationStr));
                }
            } catch (NumberFormatException e) {
                // duration은 선택적 파라미터
            }

            boolean updated = labDAO.update(lab);
            
            if (updated) {
                ApiResponse<LabProject> apiResponse = ApiResponse.success("랩 프로젝트 정보가 업데이트되었습니다.", lab);
                out.print(gson.toJson(apiResponse));
            } else {
                ApiResponse<Object> apiResponse = ApiResponse.error("랩 프로젝트 정보 업데이트에 실패했습니다.");
                response.setStatus(500);
                out.print(gson.toJson(apiResponse));
            }
            
        } catch (NumberFormatException e) {
            ApiResponse<Object> apiResponse = ApiResponse.badRequest("잘못된 랩 ID 형식입니다.");
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
        
        try {
            String pathInfo = request.getPathInfo();
            
            if (pathInfo == null || !pathInfo.startsWith("/")) {
                ApiResponse<Object> apiResponse = ApiResponse.badRequest("잘못된 요청 경로입니다.");
                response.setStatus(400);
                out.print(gson.toJson(apiResponse));
                return;
            }
            
            int labId = Integer.parseInt(pathInfo.substring(1));
            LabProject lab = labDAO.findById(labId);

            if (lab == null) {
                ApiResponse<Object> apiResponse = ApiResponse.notFound("랩 프로젝트를 찾을 수 없습니다.");
                response.setStatus(404);
                out.print(gson.toJson(apiResponse));
                return;
            }

            boolean deleted = labDAO.delete(labId);
            
            if (deleted) {
                ApiResponse<Object> apiResponse = ApiResponse.success("랩 프로젝트가 삭제되었습니다.", null);
                out.print(gson.toJson(apiResponse));
            } else {
                ApiResponse<Object> apiResponse = ApiResponse.error("랩 프로젝트 삭제에 실패했습니다.");
                response.setStatus(500);
                out.print(gson.toJson(apiResponse));
            }
            
        } catch (NumberFormatException e) {
            ApiResponse<Object> apiResponse = ApiResponse.badRequest("잘못된 랩 ID 형식입니다.");
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
