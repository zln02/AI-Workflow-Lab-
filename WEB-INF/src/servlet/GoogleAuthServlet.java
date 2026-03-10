package servlet;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import dao.UserDAO;
import model.User;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.util.Base64;

/**
 * 구글 OAuth 2.0 로그인 처리 서블릿
 * GET /AI/oauth/google          → 구글 인증 페이지로 리다이렉트
 * GET /AI/oauth/google/callback → 콜백 처리
 *
 * 필요 환경변수: GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, GOOGLE_REDIRECT_URI
 */
public class GoogleAuthServlet extends HttpServlet {

    private static final String GOOGLE_AUTH_URL  = "https://accounts.google.com/o/oauth2/v2/auth";
    private static final String GOOGLE_TOKEN_URL = "https://oauth2.googleapis.com/token";
    private static final String GOOGLE_USER_URL  = "https://www.googleapis.com/oauth2/v2/userinfo";

    private String getClientId()     { return System.getenv("GOOGLE_CLIENT_ID"); }
    private String getClientSecret() { return System.getenv("GOOGLE_CLIENT_SECRET"); }
    private String getRedirectUri()  {
        String env = System.getenv("GOOGLE_REDIRECT_URI");
        return (env != null && !env.isEmpty()) ? env : "http://localhost:8080/AI/oauth/google/callback";
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String uri = request.getRequestURI();
        if (uri.endsWith("/callback")) {
            handleCallback(request, response);
        } else {
            handleInitiate(request, response);
        }
    }

    private void handleInitiate(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String clientId = getClientId();
        if (clientId == null || clientId.isEmpty()) {
            response.sendRedirect("/AI/user/login.jsp?google_error=not_configured");
            return;
        }

        byte[] stateBytes = new byte[16];
        new SecureRandom().nextBytes(stateBytes);
        String state = Base64.getUrlEncoder().withoutPadding().encodeToString(stateBytes);

        HttpSession session = request.getSession(true);
        session.setAttribute("google_oauth_state", state);

        String redirect = request.getParameter("redirect");
        if (redirect != null && redirect.startsWith("/") && !redirect.startsWith("//")) {
            session.setAttribute("google_oauth_redirect", redirect);
        }

        String authUrl = GOOGLE_AUTH_URL
                + "?client_id=" + URLEncoder.encode(clientId, "UTF-8")
                + "&redirect_uri=" + URLEncoder.encode(getRedirectUri(), "UTF-8")
                + "&response_type=code"
                + "&scope=" + URLEncoder.encode("openid email profile", "UTF-8")
                + "&state=" + URLEncoder.encode(state, "UTF-8")
                + "&access_type=online";

        response.sendRedirect(authUrl);
    }

    private void handleCallback(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        HttpSession session = request.getSession(false);

        String returnedState = request.getParameter("state");
        if (session == null || returnedState == null) {
            response.sendRedirect("/AI/user/login.jsp?google_error=state_invalid");
            return;
        }
        String savedState = (String) session.getAttribute("google_oauth_state");
        session.removeAttribute("google_oauth_state");
        if (!returnedState.equals(savedState)) {
            response.sendRedirect("/AI/user/login.jsp?google_error=state_mismatch");
            return;
        }

        if (request.getParameter("error") != null) {
            response.sendRedirect("/AI/user/login.jsp?google_error=access_denied");
            return;
        }

        String code = request.getParameter("code");
        if (code == null || code.isEmpty()) {
            response.sendRedirect("/AI/user/login.jsp?google_error=no_code");
            return;
        }

        String savedRedirect = (String) session.getAttribute("google_oauth_redirect");

        String accessToken = exchangeCodeForToken(code);
        if (accessToken == null) {
            response.sendRedirect("/AI/user/login.jsp?google_error=token_failed");
            return;
        }

        JsonObject userInfo = getGoogleUserInfo(accessToken);
        if (userInfo == null) {
            response.sendRedirect("/AI/user/login.jsp?google_error=userinfo_failed");
            return;
        }

        String googleId = userInfo.has("id") ? userInfo.get("id").getAsString() : null;
        String email    = userInfo.has("email") ? userInfo.get("email").getAsString() : null;
        String name     = userInfo.has("name") ? userInfo.get("name").getAsString() : null;
        String picture  = userInfo.has("picture") ? userInfo.get("picture").getAsString() : null;
        boolean emailVerified = userInfo.has("verified_email") && userInfo.get("verified_email").getAsBoolean();

        if (googleId == null) {
            response.sendRedirect("/AI/user/login.jsp?google_error=userinfo_failed");
            return;
        }

        User user = null;
        try {
            UserDAO userDAO = new UserDAO();

            user = userDAO.findByGoogleId(googleId);

            if (user == null && email != null) {
                user = userDAO.findByEmail(email);
                if (user != null) {
                    userDAO.linkGoogleId(user.getId(), googleId);
                    if ((user.getProfileImageUrl() == null || user.getProfileImageUrl().isEmpty()) && picture != null) {
                        userDAO.updateProfileImage((int) user.getId(), picture);
                        user.setProfileImageUrl(picture);
                    }
                }
            }

            if (user == null) {
                User newUser = new User();
                newUser.setGoogleId(googleId);
                newUser.setEmail(email);
                newUser.setFullName(name);
                newUser.setProfileImageUrl(picture);
                newUser.setActive(true);
                newUser.setEmailVerified(emailVerified);

                long newId = userDAO.createSocialUser(newUser);
                if (newId < 0) {
                    response.sendRedirect("/AI/user/login.jsp?google_error=create_failed");
                    return;
                }
                user = userDAO.findById(newId);
            }

            if (user != null) userDAO.updateLastLogin(user.getId());

        } catch (Exception e) {
            getServletContext().log("구글 로그인 처리 중 오류", e);
            response.sendRedirect("/AI/user/login.jsp?google_error=server_error");
            return;
        }

        if (user == null || !user.isActive()) {
            response.sendRedirect("/AI/user/login.jsp?google_error=account_inactive");
            return;
        }

        session.invalidate();
        HttpSession newSession = request.getSession(true);
        newSession.setAttribute("user", user);

        if (savedRedirect != null && savedRedirect.startsWith("/") && !savedRedirect.startsWith("//")) {
            response.sendRedirect(savedRedirect);
        } else {
            response.sendRedirect("/AI/user/home.jsp");
        }
    }

    private String exchangeCodeForToken(String code) throws IOException {
        HttpURLConnection conn = (HttpURLConnection) new URL(GOOGLE_TOKEN_URL).openConnection();
        conn.setRequestMethod("POST");
        conn.setDoOutput(true);
        conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
        conn.setConnectTimeout(5000);
        conn.setReadTimeout(10000);

        String body = "grant_type=authorization_code"
                + "&code=" + URLEncoder.encode(code, "UTF-8")
                + "&client_id=" + URLEncoder.encode(getClientId(), "UTF-8")
                + "&client_secret=" + URLEncoder.encode(getClientSecret(), "UTF-8")
                + "&redirect_uri=" + URLEncoder.encode(getRedirectUri(), "UTF-8");

        try (OutputStream os = conn.getOutputStream()) {
            os.write(body.getBytes(StandardCharsets.UTF_8));
        }

        if (conn.getResponseCode() != 200) return null;

        String json = readStream(conn.getInputStream());
        JsonObject obj = JsonParser.parseString(json).getAsJsonObject();
        return obj.has("access_token") ? obj.get("access_token").getAsString() : null;
    }

    private JsonObject getGoogleUserInfo(String accessToken) throws IOException {
        HttpURLConnection conn = (HttpURLConnection) new URL(GOOGLE_USER_URL).openConnection();
        conn.setRequestMethod("GET");
        conn.setRequestProperty("Authorization", "Bearer " + accessToken);
        conn.setConnectTimeout(5000);
        conn.setReadTimeout(10000);
        if (conn.getResponseCode() != 200) return null;
        return JsonParser.parseString(readStream(conn.getInputStream())).getAsJsonObject();
    }

    private String readStream(InputStream is) throws IOException {
        if (is == null) return "";
        StringBuilder sb = new StringBuilder();
        try (BufferedReader r = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
            String line; while ((line = r.readLine()) != null) sb.append(line);
        }
        return sb.toString();
    }
}
