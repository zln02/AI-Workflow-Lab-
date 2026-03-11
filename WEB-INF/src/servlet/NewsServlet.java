package servlet;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import dao.AIToolNewsDAO;
import model.AIToolNews;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@WebServlet("/api/news/*")
public class NewsServlet extends HttpServlet {
    private static final Set<String> ALLOWED_TYPES = new HashSet<>(Arrays.asList(
            "update", "launch", "funding", "comparison", "tutorial", "industry"
    ));

    private AIToolNewsDAO newsDAO;
    private Gson gson;

    @Override
    public void init() throws ServletException {
        newsDAO = new AIToolNewsDAO();
        gson = new GsonBuilder().setDateFormat("yyyy-MM-dd HH:mm:ss").create();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        PrintWriter out = response.getWriter();
        try {
            String pathInfo = request.getPathInfo();

            if (pathInfo == null || "/".equals(pathInfo)) {
                handleList(request, response, out);
                return;
            }

            if (pathInfo.matches("/\\d+")) {
                handleDetail(Integer.parseInt(pathInfo.substring(1)), response, out);
                return;
            }

            if (pathInfo.matches("/tool/\\d+")) {
                String[] parts = pathInfo.split("/");
                handleToolNews(Integer.parseInt(parts[2]), request, out);
                return;
            }

            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            out.print(gson.toJson(new ErrorResponse("Not Found", "Invalid news endpoint")));
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print(gson.toJson(new ErrorResponse("Internal Server Error", "뉴스 데이터를 불러오지 못했습니다.")));
        } finally {
            out.close();
        }
    }

    private void handleList(HttpServletRequest request, HttpServletResponse response, PrintWriter out) throws Exception {
        int limit = clampLimit(request.getParameter("limit"), 10, 1, 50);
        String type = trim(request.getParameter("type"));
        boolean featuredOnly = Boolean.parseBoolean(request.getParameter("featured"));

        List<AIToolNews> items;
        if (featuredOnly) {
            items = newsDAO.findFeatured(limit);
        } else if (!type.isEmpty()) {
            if (!ALLOWED_TYPES.contains(type)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print(gson.toJson(new ErrorResponse("Bad Request", "Unsupported news type")));
                return;
            }
            items = newsDAO.findByType(type, limit);
        } else {
            items = newsDAO.findLatest(limit);
        }

        out.print(gson.toJson(new SuccessResponse(items)));
    }

    private void handleDetail(int newsId, HttpServletResponse response, PrintWriter out) throws Exception {
        AIToolNews item = newsDAO.findById(newsId);
        if (item == null) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            out.print(gson.toJson(new ErrorResponse("Not Found", "News not found")));
            return;
        }

        out.print(gson.toJson(new SuccessResponse(item)));
    }

    private void handleToolNews(int toolId, HttpServletRequest request, PrintWriter out) throws Exception {
        int limit = clampLimit(request.getParameter("limit"), 10, 1, 50);
        out.print(gson.toJson(new SuccessResponse(newsDAO.findByToolId(toolId, limit))));
    }

    private int clampLimit(String value, int defaultValue, int min, int max) {
        try {
            int parsed = Integer.parseInt(value);
            return Math.max(min, Math.min(max, parsed));
        } catch (Exception ignored) {
            return defaultValue;
        }
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }

    private static class SuccessResponse {
        private final boolean success = true;
        private final Object data;

        private SuccessResponse(Object data) {
            this.data = data;
        }
    }

    private static class ErrorResponse {
        private final boolean success = false;
        private final String error;
        private final String message;

        private ErrorResponse(String error, String message) {
            this.error = error;
            this.message = message;
        }
    }
}
