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
 * 네이버 OAuth 2.0 로그인 처리 서블릿
 * GET /AI/oauth/naver          → 네이버 인증 페이지로 리다이렉트
 * GET /AI/oauth/naver/callback → 콜백 처리
 *
 * 필요 환경변수: NAVER_CLIENT_ID, NAVER_CLIENT_SECRET, NAVER_REDIRECT_URI
 */
public class NaverAuthServlet extends HttpServlet {

    private static final String NAVER_AUTH_URL  = "https://nid.naver.com/oauth2.0/authorize";
    private static final String NAVER_TOKEN_URL = "https://nid.naver.com/oauth2.0/token";
    private static final String NAVER_USER_URL  = "https://openapi.naver.com/v1/nid/me";

    private String getClientId()     { return System.getenv("NAVER_CLIENT_ID"); }
    private String getClientSecret() { return System.getenv("NAVER_CLIENT_SECRET"); }
    private String getRedirectUri()  {
        String env = System.getenv("NAVER_REDIRECT_URI");
        return (env != null && !env.isEmpty()) ? env : "http://localhost:8080/AI/oauth/naver/callback";
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
            response.sendRedirect("/AI/user/login.jsp?naver_error=not_configured");
            return;
        }

        byte[] stateBytes = new byte[16];
        new SecureRandom().nextBytes(stateBytes);
        String state = Base64.getUrlEncoder().withoutPadding().encodeToString(stateBytes);

        HttpSession session = request.getSession(true);
        session.setAttribute("naver_oauth_state", state);

        String redirect = request.getParameter("redirect");
        if (redirect != null && redirect.startsWith("/") && !redirect.startsWith("//")) {
            session.setAttribute("naver_oauth_redirect", redirect);
        }

        String authUrl = NAVER_AUTH_URL
                + "?client_id=" + URLEncoder.encode(clientId, "UTF-8")
                + "&redirect_uri=" + URLEncoder.encode(getRedirectUri(), "UTF-8")
                + "&response_type=code"
                + "&state=" + URLEncoder.encode(state, "UTF-8");

        response.sendRedirect(authUrl);
    }

    private void handleCallback(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        HttpSession session = request.getSession(false);

        String returnedState = request.getParameter("state");
        if (session == null || returnedState == null) {
            response.sendRedirect("/AI/user/login.jsp?naver_error=state_invalid");
            return;
        }
        String savedState = (String) session.getAttribute("naver_oauth_state");
        session.removeAttribute("naver_oauth_state");
        if (!returnedState.equals(savedState)) {
            response.sendRedirect("/AI/user/login.jsp?naver_error=state_mismatch");
            return;
        }

        if (request.getParameter("error") != null) {
            response.sendRedirect("/AI/user/login.jsp?naver_error=access_denied");
            return;
        }

        String code = request.getParameter("code");
        if (code == null || code.isEmpty()) {
            response.sendRedirect("/AI/user/login.jsp?naver_error=no_code");
            return;
        }

        String savedRedirect = (String) session.getAttribute("naver_oauth_redirect");

        String accessToken = exchangeCodeForToken(code, savedState != null ? savedState : returnedState);
        if (accessToken == null) {
            response.sendRedirect("/AI/user/login.jsp?naver_error=token_failed");
            return;
        }

        JsonObject userInfo = getNaverUserInfo(accessToken);
        if (userInfo == null) {
            response.sendRedirect("/AI/user/login.jsp?naver_error=userinfo_failed");
            return;
        }

        // 네이버는 response 객체 안에 실제 데이터가 있음
        JsonObject profile = userInfo.has("response") ? userInfo.getAsJsonObject("response") : null;
        if (profile == null) {
            response.sendRedirect("/AI/user/login.jsp?naver_error=userinfo_failed");
            return;
        }

        String naverId  = profile.has("id")            ? profile.get("id").getAsString()            : null;
        String email    = profile.has("email")          ? profile.get("email").getAsString()          : null;
        String name     = profile.has("name")           ? profile.get("name").getAsString()           : null;
        String picture  = profile.has("profile_image") ? profile.get("profile_image").getAsString()  : null;
        String gender   = profile.has("gender")         ? profile.get("gender").getAsString()         : null; // M/F/U
        String age      = profile.has("age")            ? profile.get("age").getAsString()            : null; // "20-29"
        String birthday = profile.has("birthday")       ? profile.get("birthday").getAsString()       : null; // "08-15"
        String birthyear= profile.has("birthyear")      ? profile.get("birthyear").getAsString()      : null;

        if (naverId == null) {
            response.sendRedirect("/AI/user/login.jsp?naver_error=userinfo_failed");
            return;
        }

        // 네이버 성별 코드 변환 (M→male, F→female)
        if ("M".equals(gender)) gender = "male";
        else if ("F".equals(gender)) gender = "female";
        else gender = null;

        // 네이버 생일 형식 변환 "08-15" → "0815"
        if (birthday != null) birthday = birthday.replace("-", "");

        // 네이버 연령대 "20-29" → "20~29"
        if (age != null) age = age.replace("-", "~");

        User user = null;
        try {
            UserDAO userDAO = new UserDAO();

            user = userDAO.findByNaverId(naverId);

            if (user == null && email != null) {
                user = userDAO.findByEmail(email);
                if (user != null) {
                    userDAO.linkNaverId(user.getId(), naverId);
                    if ((user.getProfileImageUrl() == null || user.getProfileImageUrl().isEmpty()) && picture != null) {
                        userDAO.updateProfileImage((int) user.getId(), picture);
                        user.setProfileImageUrl(picture);
                    }
                    userDAO.updateKakaoInfo(user.getId(), gender, age, birthyear, birthday);
                }
            }

            if (user == null) {
                User newUser = new User();
                newUser.setNaverId(naverId);
                newUser.setEmail(email);
                newUser.setFullName(name);
                newUser.setProfileImageUrl(picture);
                newUser.setGender(gender);
                newUser.setAgeRange(age);
                newUser.setBirthyear(birthyear);
                newUser.setBirthday(birthday);
                newUser.setActive(true);
                newUser.setEmailVerified(email != null);

                long newId = userDAO.createSocialUser(newUser);
                if (newId < 0) {
                    response.sendRedirect("/AI/user/login.jsp?naver_error=create_failed");
                    return;
                }
                user = userDAO.findById(newId);
            }

            if (user != null) userDAO.updateLastLogin(user.getId());

        } catch (Exception e) {
            getServletContext().log("네이버 로그인 처리 중 오류", e);
            response.sendRedirect("/AI/user/login.jsp?naver_error=server_error");
            return;
        }

        if (user == null || !user.isActive()) {
            response.sendRedirect("/AI/user/login.jsp?naver_error=account_inactive");
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

    private String exchangeCodeForToken(String code, String state) throws IOException {
        HttpURLConnection conn = (HttpURLConnection) new URL(NAVER_TOKEN_URL).openConnection();
        conn.setRequestMethod("POST");
        conn.setDoOutput(true);
        conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded;charset=UTF-8");
        conn.setConnectTimeout(5000);
        conn.setReadTimeout(10000);

        String body = "grant_type=authorization_code"
                + "&client_id=" + URLEncoder.encode(getClientId(), "UTF-8")
                + "&client_secret=" + URLEncoder.encode(getClientSecret(), "UTF-8")
                + "&code=" + URLEncoder.encode(code, "UTF-8")
                + "&state=" + URLEncoder.encode(state, "UTF-8");

        try (OutputStream os = conn.getOutputStream()) {
            os.write(body.getBytes(StandardCharsets.UTF_8));
        }

        if (conn.getResponseCode() != 200) return null;

        String json = readStream(conn.getInputStream());
        JsonObject obj = JsonParser.parseString(json).getAsJsonObject();
        return obj.has("access_token") ? obj.get("access_token").getAsString() : null;
    }

    private JsonObject getNaverUserInfo(String accessToken) throws IOException {
        HttpURLConnection conn = (HttpURLConnection) new URL(NAVER_USER_URL).openConnection();
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
