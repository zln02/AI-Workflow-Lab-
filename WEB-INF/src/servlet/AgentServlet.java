package servlet;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import dao.AgentRunDAO;
import dao.AgentTemplateDAO;
import model.AgentRun;
import model.AgentTemplate;
import model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/api/agents/*")
public class AgentServlet extends HttpServlet {
    private AgentTemplateDAO agentTemplateDAO;
    private AgentRunDAO agentRunDAO;
    private Gson gson;

    @Override
    public void init() throws ServletException {
        agentTemplateDAO = new AgentTemplateDAO();
        agentRunDAO = new AgentRunDAO();
        gson = new GsonBuilder().setDateFormat("yyyy-MM-dd HH:mm:ss").create();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            String pathInfo = request.getPathInfo();
            if (pathInfo == null || "/".equals(pathInfo) || "/templates".equals(pathInfo)) {
                try {
                    List<AgentTemplate> templates = agentTemplateDAO.findActiveTemplates();
                    out.print(gson.toJson(new SuccessResponse(templates)));
                } catch (Exception e) {
                    if (isMissingSchemaError(e)) {
                        out.print(gson.toJson(new SuccessResponseWithMeta(new java.util.ArrayList<>(), true, "agent workspace migration required")));
                    } else {
                        throw e;
                    }
                }
                return;
            }

            User user = requireUser(request, response, out);
            if (user == null) {
                return;
            }

            if ("/runs".equals(pathInfo)) {
                int limit = clampLimit(request.getParameter("limit"), 12, 1, 50);
                try {
                    out.print(gson.toJson(new SuccessResponse(agentRunDAO.findRecentByUser(user.getId(), limit))));
                } catch (Exception e) {
                    if (isMissingSchemaError(e)) {
                        out.print(gson.toJson(new SuccessResponseWithMeta(new java.util.ArrayList<>(), true, "agent workspace migration required")));
                    } else {
                        throw e;
                    }
                }
                return;
            }

            if (pathInfo.startsWith("/runs/")) {
                Integer runId = parseInt(pathInfo.substring("/runs/".length()));
                if (runId == null) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    out.print(gson.toJson(new ErrorResponse("Bad Request", "유효한 실행 ID가 필요합니다.")));
                    return;
                }
                AgentRun run = agentRunDAO.findByIdAndUser(runId, user.getId());
                if (run == null) {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    out.print(gson.toJson(new ErrorResponse("Not Found", "실행 기록을 찾을 수 없습니다.")));
                    return;
                }
                out.print(gson.toJson(new SuccessResponse(run)));
                return;
            }

            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            out.print(gson.toJson(new ErrorResponse("Not Found", "Invalid agent endpoint")));
        } catch (Exception e) {
            getServletContext().log("에이전트 조회 실패", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print(gson.toJson(new ErrorResponse("Internal Server Error", "에이전트 데이터를 불러오지 못했습니다.")));
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

            String pathInfo = request.getPathInfo();
            if (pathInfo == null || !"/runs".equals(pathInfo)) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print(gson.toJson(new ErrorResponse("Not Found", "실행 저장 경로가 올바르지 않습니다.")));
                return;
            }

            Integer templateId = parseInt(request.getParameter("templateId"));
            String userGoal = defaultString(request.getParameter("userGoal"), "");
            String title = defaultString(request.getParameter("title"), "에이전트 실행");
            String finalOutputJson = request.getParameter("finalOutputJson");
            if (templateId == null || userGoal.isEmpty() || finalOutputJson == null || finalOutputJson.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print(gson.toJson(new ErrorResponse("Bad Request", "templateId, userGoal, finalOutputJson이 필요합니다.")));
                return;
            }

            AgentRun run = new AgentRun();
            run.setUserId(user.getId());
            run.setTemplateId(templateId);
            run.setTitle(title);
            run.setUserGoal(userGoal);
            run.setStatus(defaultString(request.getParameter("status"), "completed"));
            run.setModelUsed(defaultString(request.getParameter("modelUsed"), ""));
            run.setPromptTokens(parseInt(request.getParameter("promptTokens")) != null ? parseInt(request.getParameter("promptTokens")) : 0);
            run.setOutputTokens(parseInt(request.getParameter("outputTokens")) != null ? parseInt(request.getParameter("outputTokens")) : 0);
            run.setCreditsUsed(parseDouble(request.getParameter("creditsUsed")));
            run.setFinalOutputJson(finalOutputJson.trim());

            out.print(gson.toJson(new SuccessResponse(agentRunDAO.create(run))));
        } catch (Exception e) {
            getServletContext().log("에이전트 실행 저장 실패", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print(gson.toJson(new ErrorResponse("Internal Server Error", "에이전트 실행을 저장하지 못했습니다.")));
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

    private boolean isMissingSchemaError(Exception e) {
        String message = e.getMessage();
        if (message == null) {
            return false;
        }
        String lower = message.toLowerCase();
        return lower.contains("agent_templates") || lower.contains("agent_runs") || lower.contains("doesn't exist");
    }

    private static class SuccessResponse {
        private final boolean success = true;
        private final Object data;

        private SuccessResponse(Object data) {
            this.data = data;
        }
    }

    private static class SuccessResponseWithMeta {
        private final boolean success = true;
        private final Object data;
        private final boolean migrationRequired;
        private final String message;

        private SuccessResponseWithMeta(Object data, boolean migrationRequired, String message) {
            this.data = data;
            this.migrationRequired = migrationRequired;
            this.message = message;
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
