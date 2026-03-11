package servlet;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import dao.LabSessionDAO;
import model.LabSession;
import model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/api/lab-sessions/*")
public class LabSessionServlet extends HttpServlet {
    private LabSessionDAO labSessionDAO;
    private Gson gson;

    @Override
    public void init() throws ServletException {
        labSessionDAO = new LabSessionDAO();
        gson = new GsonBuilder().setDateFormat("yyyy-MM-dd HH:mm:ss").create();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            User user = requireUser(request, response, out);
            if (user == null) {
                return;
            }

            String pathInfo = request.getPathInfo();
            int limit = clampLimit(request.getParameter("limit"), 10, 1, 50);
            Integer projectId = parseInt(request.getParameter("projectId"));

            if (pathInfo == null || "/".equals(pathInfo) || "/history".equals(pathInfo)) {
                List<LabSession> items = projectId != null
                        ? labSessionDAO.findRecentByUserAndProject(user.getId(), projectId, limit)
                        : labSessionDAO.findRecentByUser(user.getId(), limit);
                out.print(gson.toJson(new SuccessResponse(items)));
                return;
            }

            if ("/latest".equals(pathInfo)) {
                if (projectId == null) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    out.print(gson.toJson(new ErrorResponse("Bad Request", "projectId is required")));
                    return;
                }
                out.print(gson.toJson(new SuccessResponse(labSessionDAO.findLatestByUserAndProject(user.getId(), projectId))));
                return;
            }

            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            out.print(gson.toJson(new ErrorResponse("Not Found", "Invalid lab session endpoint")));
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print(gson.toJson(new ErrorResponse("Internal Server Error", "실습 세션을 불러오지 못했습니다.")));
        } finally {
            out.close();
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        request.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            User user = requireUser(request, response, out);
            if (user == null) {
                return;
            }

            LabSession session = new LabSession();
            session.setUserId(user.getId());
            session.setProjectId(parseInt(request.getParameter("projectId")));
            session.setSessionType(defaultString(request.getParameter("sessionType"), "playground"));
            session.setTitle(defaultString(request.getParameter("title"), "실습 실행"));
            session.setCodeContent(request.getParameter("codeContent"));
            session.setResultContent(request.getParameter("resultContent"));
            session.setModelUsed(request.getParameter("modelUsed"));
            session.setTokensUsed(parseInt(request.getParameter("tokensUsed")) != null ? parseInt(request.getParameter("tokensUsed")) : 0);
            session.setCreditsUsed(parseDouble(request.getParameter("creditsUsed")));
            session.setExecutionTimeMs(parseInt(request.getParameter("executionTimeMs")));
            session.setStatus(defaultString(request.getParameter("status"), "completed"));
            session.setMetadata(request.getParameter("metadata"));

            out.print(gson.toJson(new SuccessResponse(labSessionDAO.create(session))));
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print(gson.toJson(new ErrorResponse("Internal Server Error", "실습 세션을 저장하지 못했습니다.")));
        } finally {
            out.close();
        }
    }

    private User requireUser(HttpServletRequest request, HttpServletResponse response, PrintWriter out) {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print(gson.toJson(new ErrorResponse("Unauthorized", "로그인이 필요합니다.")));
            return null;
        }
        return user;
    }

    private Integer parseInt(String value) {
        try {
            return value == null || value.trim().isEmpty() ? null : Integer.parseInt(value.trim());
        } catch (Exception ignored) {
            return null;
        }
    }

    private double parseDouble(String value) {
        try {
            return value == null || value.trim().isEmpty() ? 0 : Double.parseDouble(value.trim());
        } catch (Exception ignored) {
            return 0;
        }
    }

    private int clampLimit(String value, int defaultValue, int min, int max) {
        try {
            int parsed = Integer.parseInt(value);
            return Math.max(min, Math.min(max, parsed));
        } catch (Exception ignored) {
            return defaultValue;
        }
    }

    private String defaultString(String value, String fallback) {
        return value == null || value.trim().isEmpty() ? fallback : value.trim();
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
