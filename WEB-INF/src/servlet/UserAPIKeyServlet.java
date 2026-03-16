package servlet;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import model.User;
import util.CSRFUtil;
import util.EncryptionUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/api/user/api-keys/*")
public class UserAPIKeyServlet extends HttpServlet {
    private Gson gson;

    @Override
    public void init() throws ServletException {
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

            List<Map<String, Object>> items = new ArrayList<>();
            try (Connection conn = db.DBConnect.getConnection();
                 PreparedStatement ps = conn.prepareStatement(
                         "SELECT id, provider, api_key_enc, is_verified, last_used, created_at " +
                                 "FROM user_api_keys WHERE user_id = ? ORDER BY created_at DESC")) {
                ps.setLong(1, user.getId());
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> item = new HashMap<>();
                        item.put("id", rs.getInt("id"));
                        item.put("provider", rs.getString("provider"));
                        item.put("keyName", buildDefaultKeyName(rs.getString("provider")));
                        item.put("maskedKey", EncryptionUtil.mask(rs.getString("api_key_enc")));
                        item.put("verified", rs.getBoolean("is_verified"));
                        item.put("active", true);
                        item.put("lastUsedAt", rs.getTimestamp("last_used"));
                        item.put("usageCount", 0);
                        item.put("createdAt", rs.getTimestamp("created_at"));
                        items.add(item);
                    }
                }
            }

            out.print(gson.toJson(new SuccessResponse(items)));
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print(gson.toJson(new ErrorResponse("Internal Server Error", "API 키 목록을 불러오지 못했습니다.")));
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
            if (!validateCsrf(request, response, out)) {
                return;
            }

            String provider = normalizeProvider(request.getParameter("provider"));
            String keyName = defaultString(request.getParameter("keyName"), buildDefaultKeyName(provider));
            String apiKey = request.getParameter("apiKey");

            if (apiKey == null || apiKey.trim().length() < 10) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print(gson.toJson(new ErrorResponse("Bad Request", "유효한 API 키를 입력하세요.")));
                return;
            }
            apiKey = apiKey.trim();

            String keyFamily = detectKeyFamily(apiKey);
            if ("anthropic".equals(provider) && !"anthropic".equals(keyFamily)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print(gson.toJson(new ErrorResponse("Bad Request", "Anthropic 키를 입력하세요. OpenAI 키(sk-proj-, sk-...)는 실습 실행에 사용할 수 없습니다.")));
                return;
            }

            String encryptedKey = EncryptionUtil.encrypt(apiKey);
            if (encryptedKey == null || !encryptedKey.startsWith("enc:")) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print(gson.toJson(new ErrorResponse("Server Misconfigured", "서버 암호화 키가 설정되지 않아 API 키를 저장할 수 없습니다.")));
                return;
            }

            int insertedId = 0;
            try (Connection conn = db.DBConnect.getConnection();
                 PreparedStatement ps = conn.prepareStatement(
                         "INSERT INTO user_api_keys (user_id, provider, api_key_enc, is_verified, last_used, created_at, updated_at) " +
                                 "VALUES (?, ?, ?, 1, NULL, NOW(), NOW()) " +
                                 "ON DUPLICATE KEY UPDATE provider = VALUES(provider), api_key_enc = VALUES(api_key_enc), is_verified = 1, last_used = NULL, updated_at = NOW()",
                         Statement.RETURN_GENERATED_KEYS)) {
                ps.setLong(1, user.getId());
                ps.setString(2, provider);
                ps.setString(3, encryptedKey);
                ps.executeUpdate();
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        insertedId = keys.getInt(1);
                    }
                }
                if (insertedId == 0) {
                    try (PreparedStatement idPs = conn.prepareStatement("SELECT id FROM user_api_keys WHERE user_id = ?")) {
                        idPs.setLong(1, user.getId());
                        try (ResultSet rs = idPs.executeQuery()) {
                            if (rs.next()) {
                                insertedId = rs.getInt(1);
                            }
                        }
                    }
                }
            }

            Map<String, Object> data = new HashMap<>();
            data.put("id", insertedId);
            data.put("provider", provider);
            data.put("keyName", keyName);
            data.put("maskedKey", EncryptionUtil.mask(apiKey));
            out.print(gson.toJson(new SuccessResponse(data)));
        } catch (Exception e) {
            getServletContext().log("API 키 저장 실패", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print(gson.toJson(new ErrorResponse("Internal Server Error", "API 키를 저장하지 못했습니다.")));
        } finally {
            out.close();
        }
    }

    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        try {
            User user = requireUser(request, response, out);
            if (user == null) {
                return;
            }
            if (!validateCsrf(request, response, out)) {
                return;
            }

            Integer id = parseId(request.getPathInfo());
            if (id == null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print(gson.toJson(new ErrorResponse("Bad Request", "삭제할 키 ID가 필요합니다.")));
                return;
            }

            boolean deleted;
            try (Connection conn = db.DBConnect.getConnection();
                 PreparedStatement ps = conn.prepareStatement("DELETE FROM user_api_keys WHERE id = ? AND user_id = ?")) {
                ps.setInt(1, id);
                ps.setLong(2, user.getId());
                deleted = ps.executeUpdate() > 0;
            }

            out.print(gson.toJson(new SuccessResponse(deleted)));
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print(gson.toJson(new ErrorResponse("Internal Server Error", "API 키를 삭제하지 못했습니다.")));
        } finally {
            out.close();
        }
    }

    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        request.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        try {
            User user = requireUser(request, response, out);
            if (user == null) {
                return;
            }
            if (!validateCsrf(request, response, out)) {
                return;
            }

            Integer id = parseId(request.getPathInfo());
            if (id == null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print(gson.toJson(new ErrorResponse("Bad Request", "수정할 키 ID가 필요합니다.")));
                return;
            }

            String provider = request.getParameter("provider");

            StringBuilder sql = new StringBuilder("UPDATE user_api_keys SET ");
            List<Object> params = new ArrayList<>();
            boolean first = true;
            if (provider != null && !provider.trim().isEmpty()) {
                sql.append("provider = ?");
                params.add(normalizeProvider(provider));
                first = false;
            }
            if (first) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print(gson.toJson(new ErrorResponse("Bad Request", "수정할 항목이 없습니다.")));
                return;
            }
            sql.append(" WHERE id = ? AND user_id = ?");
            params.add(id);
            params.add(user.getId());

            try (Connection conn = db.DBConnect.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                for (int i = 0; i < params.size(); i++) {
                    ps.setObject(i + 1, params.get(i));
                }
                ps.executeUpdate();
            }

            out.print(gson.toJson(new SuccessResponse(true)));
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print(gson.toJson(new ErrorResponse("Internal Server Error", "API 키를 수정하지 못했습니다.")));
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

    private boolean validateCsrf(HttpServletRequest request, HttpServletResponse response, PrintWriter out) {
        String requestToken = request.getHeader("X-CSRF-Token");
        if (requestToken == null || requestToken.trim().isEmpty()) {
            requestToken = request.getParameter(CSRFUtil.getTokenParamName());
        }
        if (!CSRFUtil.validateToken(request, requestToken)) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            out.print(gson.toJson(new ErrorResponse("Forbidden", "보안 검증에 실패했습니다.")));
            return false;
        }
        return true;
    }

    private Integer parseId(String pathInfo) {
        if (pathInfo == null || pathInfo.length() <= 1) {
            return null;
        }
        try {
            return Integer.parseInt(pathInfo.substring(1));
        } catch (Exception ignored) {
            return null;
        }
    }

    private String defaultString(String value, String fallback) {
        return value == null || value.trim().isEmpty() ? fallback : value.trim();
    }

    private String normalizeProvider(String provider) {
        String normalized = defaultString(provider, "anthropic").toLowerCase();
        switch (normalized) {
            case "anthropic":
            case "openai":
            case "google":
            case "mistral":
                return normalized;
            default:
                return "anthropic";
        }
    }

    private String buildDefaultKeyName(String provider) {
        String normalized = normalizeProvider(provider);
        return Character.toUpperCase(normalized.charAt(0)) + normalized.substring(1) + " Key";
    }

    private String detectKeyFamily(String apiKey) {
        String value = apiKey == null ? "" : apiKey.trim().toLowerCase();
        if (value.startsWith("sk-ant-")) {
            return "anthropic";
        }
        if (value.startsWith("sk-proj-") || value.startsWith("sk-")) {
            return "openai";
        }
        if (value.startsWith("AIza".toLowerCase())) {
            return "google";
        }
        if (value.startsWith("mistral-")) {
            return "mistral";
        }
        return "unknown";
    }

    private static class SuccessResponse {
        private final boolean success = true;
        private final Object data;
        private SuccessResponse(Object data) { this.data = data; }
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
