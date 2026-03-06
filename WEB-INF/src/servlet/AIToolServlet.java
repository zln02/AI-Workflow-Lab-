package servlet;

import dao.AIToolDAO;
import model.AITool;
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

/**
 * AI 도구 API 서블릿
 * AI Workflow Lab의 도구 추천 및 검색 기능 제공
 */
@WebServlet("/api/ai-tools/*")
public class AIToolServlet extends HttpServlet {
    private AIToolDAO toolDAO;
    private Gson gson;
    
    @Override
    public void init() throws ServletException {
        toolDAO = new AIToolDAO();
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
                // 모든 도구 조회 또는 검색
                handleGetTools(request, out);
            } else if (pathInfo.matches("/\\d+")) {
                // ID로 특정 도구 조회
                int toolId = Integer.parseInt(pathInfo.substring(1));
                handleGetTool(toolId, out);
            } else if (pathInfo.equals("/popular")) {
                // 인기 도구 조회
                handleGetPopularTools(request, out);
            } else if (pathInfo.equals("/free")) {
                // 무료 플랜 도구 조회
                handleGetFreeTools(out);
            } else if (pathInfo.equals("/recommend")) {
                // 도구 추천
                handleRecommendTools(request, out);
            } else {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print(gson.toJson(new ErrorResponse("Not Found", "Invalid endpoint")));
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print(gson.toJson(new ErrorResponse("Internal Server Error", "서버 오류가 발생했습니다.")));
        }
    }
    
    /**
     * 모든 도구 조회 또는 키워드 검색
     */
    private void handleGetTools(HttpServletRequest request, PrintWriter out) throws Exception {
        String keyword = request.getParameter("keyword");
        String category = request.getParameter("category");
        String difficulty = request.getParameter("difficulty");
        List<AITool> tools;
        
        if (keyword != null && !keyword.trim().isEmpty()) {
            tools = toolDAO.searchByKeyword(keyword);
        } else if (category != null && !category.trim().isEmpty()) {
            tools = toolDAO.findByCategory(category);
        } else if (difficulty != null && !difficulty.trim().isEmpty()) {
            tools = toolDAO.findByDifficulty(difficulty);
        } else {
            tools = toolDAO.findAll();
        }
        
        out.print(gson.toJson(new SuccessResponse(tools)));
    }
    
    /**
     * ID로 특정 도구 조회
     */
    private void handleGetTool(int toolId, PrintWriter out) throws Exception {
        AITool tool = toolDAO.findById(toolId);
        
        if (tool != null) {
            out.print(gson.toJson(new SuccessResponse(tool)));
        } else {
            out.print(gson.toJson(new ErrorResponse("Not Found", "Tool not found")));
        }
    }
    
    /**
     * 인기 도구 조회
     */
    private void handleGetPopularTools(HttpServletRequest request, PrintWriter out) throws Exception {
        int limit = 10;
        String limitParam = request.getParameter("limit");
        if (limitParam != null) {
            limit = Math.min(50, Math.max(1, Integer.parseInt(limitParam)));
        }
        
        List<AITool> tools = toolDAO.findPopular(limit);
        out.print(gson.toJson(new SuccessResponse(tools)));
    }
    
    /**
     * 무료 플랜 도구 조회
     */
    private void handleGetFreeTools(PrintWriter out) throws Exception {
        List<AITool> tools = toolDAO.findFreeTierAvailable();
        out.print(gson.toJson(new SuccessResponse(tools)));
    }
    
    /**
     * 도구 추천
     */
    private void handleRecommendTools(HttpServletRequest request, PrintWriter out) throws Exception {
        String query = request.getParameter("q");
        String difficulty = request.getParameter("difficulty");
        String category = request.getParameter("category");
        
        if (query == null || query.trim().isEmpty()) {
            out.print(gson.toJson(new ErrorResponse("Bad Request", "Query parameter 'q' is required")));
            return;
        }
        
        List<AITool> tools = toolDAO.recommendTools(query, difficulty, category);
        out.print(gson.toJson(new SuccessResponse(tools)));
    }
    
    /**
     * 응답 클래스
     */
    private static class SuccessResponse {
        private boolean success = true;
        private Object data;
        
        public SuccessResponse(Object data) {
            this.data = data;
        }
        
        public boolean isSuccess() { return success; }
        public Object getData() { return data; }
    }
    
    private static class ErrorResponse {
        private boolean success = false;
        private String error;
        private String message;
        
        public ErrorResponse(String error, String message) {
            this.error = error;
            this.message = message;
        }
        
        public boolean isSuccess() { return success; }
        public String getError() { return error; }
        public String getMessage() { return message; }
    }
}
