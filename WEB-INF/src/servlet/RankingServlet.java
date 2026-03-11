package servlet;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import dao.AIToolDAO;
import dao.BenchmarkDAO;
import model.AITool;
import model.Benchmark;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/api/rankings/*")
public class RankingServlet extends HttpServlet {
    private AIToolDAO toolDAO;
    private BenchmarkDAO benchmarkDAO;
    private Gson gson;

    @Override
    public void init() throws ServletException {
        toolDAO = new AIToolDAO();
        benchmarkDAO = new BenchmarkDAO();
        gson = new GsonBuilder().setDateFormat("yyyy-MM-dd HH:mm:ss").create();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        PrintWriter out = response.getWriter();
        try {
            String pathInfo = request.getPathInfo();

            if (pathInfo == null || "/".equals(pathInfo) || "/global".equals(pathInfo)) {
                handleGlobal(request, out);
                return;
            }

            if (pathInfo.startsWith("/category/")) {
                handleCategory(pathInfo.substring("/category/".length()), request, out);
                return;
            }

            if (pathInfo.startsWith("/country/")) {
                handleCountry(pathInfo.substring("/country/".length()), request, out);
                return;
            }

            if ("/rising".equals(pathInfo)) {
                handleRising(request, out);
                return;
            }

            if ("/benchmarks".equals(pathInfo)) {
                handleBenchmarks(request, response, out);
                return;
            }

            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            out.print(gson.toJson(new ErrorResponse("Not Found", "Invalid rankings endpoint")));
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print(gson.toJson(new ErrorResponse("Internal Server Error", "랭킹 데이터를 불러오지 못했습니다.")));
        } finally {
            out.close();
        }
    }

    private void handleGlobal(HttpServletRequest request, PrintWriter out) throws Exception {
        int limit = clampLimit(request.getParameter("limit"), 100, 1, 200);
        out.print(gson.toJson(new SuccessResponse(toolDAO.findFiltered(null, null, null, null, false, false, "rank", limit, 0))));
    }

    private void handleCategory(String category, HttpServletRequest request, PrintWriter out) throws Exception {
        int limit = clampLimit(request.getParameter("limit"), 50, 1, 100);
        out.print(gson.toJson(new SuccessResponse(toolDAO.findFiltered(null, decodeSegment(category), null, null, false, false, "rank", limit, 0))));
    }

    private void handleCountry(String countryCode, HttpServletRequest request, PrintWriter out) throws Exception {
        int limit = clampLimit(request.getParameter("limit"), 50, 1, 100);
        out.print(gson.toJson(new SuccessResponse(toolDAO.findFiltered(null, null, null, decodeSegment(countryCode).toUpperCase(), false, false, "rank", limit, 0))));
    }

    private void handleRising(HttpServletRequest request, PrintWriter out) throws Exception {
        int limit = clampLimit(request.getParameter("limit"), 20, 1, 100);
        out.print(gson.toJson(new SuccessResponse(toolDAO.findFiltered(null, null, null, null, false, false, "growth", limit, 0))));
    }

    private void handleBenchmarks(HttpServletRequest request, HttpServletResponse response, PrintWriter out) throws Exception {
        String benchmarkName = trim(request.getParameter("name"));
        if (benchmarkName.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print(gson.toJson(new ErrorResponse("Bad Request", "Benchmark name is required")));
            return;
        }

        List<Benchmark> benchmarks = benchmarkDAO.findByBenchmarkName(benchmarkName);
        List<Integer> ids = new ArrayList<>();
        for (Benchmark benchmark : benchmarks) {
            ids.add(benchmark.getToolId());
        }

        List<AITool> tools = toolDAO.findByIds(ids);
        List<BenchmarkRankingItem> items = new ArrayList<>();
        for (int i = 0; i < benchmarks.size(); i++) {
            Benchmark benchmark = benchmarks.get(i);
            AITool tool = i < tools.size() ? tools.get(i) : null;
            items.add(new BenchmarkRankingItem(benchmark, tool));
        }

        out.print(gson.toJson(new SuccessResponse(items)));
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

    private String decodeSegment(String value) {
        if (value == null) {
            return "";
        }
        return URLDecoder.decode(value, StandardCharsets.UTF_8).trim();
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

    private static class BenchmarkRankingItem {
        private final Benchmark benchmark;
        private final AITool tool;

        private BenchmarkRankingItem(Benchmark benchmark, AITool tool) {
            this.benchmark = benchmark;
            this.tool = tool;
        }
    }
}
