package servlet;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import dao.UserDAO;
import model.User;

import javax.servlet.ServletException;
import javax.servlet.http.Cookie;
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
 * 카카오 OAuth 2.0 로그인 처리 서블릿
 *
 * GET /AI/oauth/kakao          → 카카오 인증 페이지로 리다이렉트
 * GET /AI/oauth/kakao/callback → 인가 코드 수신 후 로그인 처리
 *
 * 필요한 환경 변수 (Tomcat context.xml 또는 setenv.sh):
 *   KAKAO_REST_API_KEY   — 카카오 앱의 REST API 키
 *   KAKAO_REDIRECT_URI   — 카카오 앱에 등록한 Redirect URI
 */
public class KakaoAuthServlet extends HttpServlet {

    private static final String KAKAO_AUTH_URL  = "https://kauth.kakao.com/oauth/authorize";
    private static final String KAKAO_TOKEN_URL = "https://kauth.kakao.com/oauth/token";
    private static final String KAKAO_USER_URL  = "https://kapi.kakao.com/v2/user/me";
    private static final String STATE_COOKIE_NAME = "kakao_oauth_state";
    private static final String REDIRECT_COOKIE_NAME = "kakao_oauth_redirect";
    private static final int OAUTH_COOKIE_MAX_AGE = 600;

    private String getRestApiKey() {
        return System.getenv("KAKAO_REST_API_KEY");
    }

    private String getRedirectUri() {
        String env = System.getenv("KAKAO_REDIRECT_URI");
        return (env != null && !env.isEmpty()) ? env : "http://localhost:8080/AI/oauth/kakao/callback";
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

    // ────────────────────────────────────────────────────────────────────────
    // 1단계: 카카오 인증 페이지로 리다이렉트
    // ────────────────────────────────────────────────────────────────────────
    private void handleInitiate(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String apiKey = getRestApiKey();
        if (apiKey == null || apiKey.isEmpty()) {
            response.sendRedirect("/AI/user/login.jsp?kakao_error=not_configured");
            return;
        }

        // CSRF 방지용 state 생성
        byte[] stateBytes = new byte[16];
        new SecureRandom().nextBytes(stateBytes);
        String state = Base64.getUrlEncoder().withoutPadding().encodeToString(stateBytes);

        HttpSession session = request.getSession(true);
        session.setAttribute("kakao_oauth_state", state);
        addCookie(request, response, STATE_COOKIE_NAME, state, OAUTH_COOKIE_MAX_AGE);

        // 로그인 후 돌아갈 URL 저장 (Open Redirect 방지: 상대경로만)
        String redirect = request.getParameter("redirect");
        if (redirect != null && redirect.startsWith("/") && !redirect.startsWith("//")) {
            session.setAttribute("kakao_oauth_redirect", redirect);
            addCookie(request, response, REDIRECT_COOKIE_NAME, encodeCookieValue(redirect), OAUTH_COOKIE_MAX_AGE);
        } else {
            clearCookie(request, response, REDIRECT_COOKIE_NAME);
        }

        String authUrl = KAKAO_AUTH_URL
                + "?client_id=" + URLEncoder.encode(apiKey, "UTF-8")
                + "&redirect_uri=" + URLEncoder.encode(getRedirectUri(), "UTF-8")
                + "&response_type=code"
                + "&state=" + URLEncoder.encode(state, "UTF-8")
                + "&scope=profile_nickname,profile_image,account_email";

        response.sendRedirect(authUrl);
    }

    // ────────────────────────────────────────────────────────────────────────
    // 2단계: 카카오 콜백 처리 (토큰 교환 → 유저 정보 → 세션)
    // ────────────────────────────────────────────────────────────────────────
    private void handleCallback(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        HttpSession session = request.getSession(false);

        // state 검증
        String returnedState = request.getParameter("state");
        String cookieState = getCookieValue(request, STATE_COOKIE_NAME);
        if (returnedState == null || ((session == null || session.getAttribute("kakao_oauth_state") == null)
                && (cookieState == null || cookieState.isEmpty()))) {
            clearCookie(request, response, STATE_COOKIE_NAME);
            clearCookie(request, response, REDIRECT_COOKIE_NAME);
            response.sendRedirect("/AI/user/login.jsp?kakao_error=state_invalid");
            return;
        }
        String savedState = session != null ? (String) session.getAttribute("kakao_oauth_state") : null;
        if (session != null) {
            session.removeAttribute("kakao_oauth_state");
        }
        clearCookie(request, response, STATE_COOKIE_NAME);

        boolean stateMatches = returnedState.equals(savedState) || returnedState.equals(cookieState);
        if (!stateMatches) {
            getServletContext().log("카카오 state mismatch: returned=" + returnedState
                    + ", session=" + savedState + ", cookie=" + cookieState);
            clearCookie(request, response, REDIRECT_COOKIE_NAME);
            response.sendRedirect("/AI/user/login.jsp?kakao_error=state_mismatch");
            return;
        }

        // 카카오가 에러를 반환한 경우 (사용자 취소 등)
        if (request.getParameter("error") != null) {
            response.sendRedirect("/AI/user/login.jsp?kakao_error=access_denied");
            return;
        }

        String code = request.getParameter("code");
        if (code == null || code.isEmpty()) {
            response.sendRedirect("/AI/user/login.jsp?kakao_error=no_code");
            return;
        }

        // 저장된 리다이렉트 URL (session 무효화 전에 미리 읽기)
        String savedRedirect = session != null ? (String) session.getAttribute("kakao_oauth_redirect") : null;
        if (session != null) {
            session.removeAttribute("kakao_oauth_redirect");
        }
        if (savedRedirect == null || savedRedirect.isEmpty()) {
            savedRedirect = decodeCookieValue(getCookieValue(request, REDIRECT_COOKIE_NAME));
        }
        clearCookie(request, response, REDIRECT_COOKIE_NAME);

        // 토큰 교환
        String accessToken = exchangeCodeForToken(code);
        if (accessToken == null) {
            response.sendRedirect("/AI/user/login.jsp?kakao_error=token_failed");
            return;
        }

        // 카카오 사용자 정보 조회
        JsonObject userInfo = getKakaoUserInfo(accessToken);
        if (userInfo == null) {
            response.sendRedirect("/AI/user/login.jsp?kakao_error=userinfo_failed");
            return;
        }

        // 사용자 정보 파싱
        long kakaoId = userInfo.get("id").getAsLong();
        String email = null;
        String nickname = null;
        String profileImageUrl = null;
        String gender = null;
        String ageRange = null;
        String birthyear = null;
        String birthday = null;

        if (userInfo.has("kakao_account")) {
            JsonObject account = userInfo.getAsJsonObject("kakao_account");
            if (account.has("email") && !account.get("email").isJsonNull()) {
                email = account.get("email").getAsString();
            }
            if (account.has("gender") && !account.get("gender").isJsonNull()) {
                gender = account.get("gender").getAsString(); // "male" or "female"
            }
            if (account.has("age_range") && !account.get("age_range").isJsonNull()) {
                ageRange = account.get("age_range").getAsString(); // "20~29" etc.
            }
            if (account.has("birthyear") && !account.get("birthyear").isJsonNull()) {
                birthyear = account.get("birthyear").getAsString(); // "1995"
            }
            if (account.has("birthday") && !account.get("birthday").isJsonNull()) {
                birthday = account.get("birthday").getAsString(); // "0815" (MMDD)
            }
            if (account.has("profile") && !account.get("profile").isJsonNull()) {
                JsonObject profile = account.getAsJsonObject("profile");
                if (profile.has("nickname") && !profile.get("nickname").isJsonNull()) {
                    nickname = profile.get("nickname").getAsString();
                }
                if (profile.has("profile_image_url") && !profile.get("profile_image_url").isJsonNull()) {
                    profileImageUrl = profile.get("profile_image_url").getAsString();
                }
            }
        }

        // 사용자 조회 or 생성
        User user = null;
        try {
            UserDAO userDAO = new UserDAO();

            // 1) 카카오 ID로 기존 사용자 검색
            user = userDAO.findByKakaoId(kakaoId);

            if (user == null && email != null) {
                // 2) 이메일로 기존 가입 계정 검색 → 카카오 연결
                user = userDAO.findByEmail(email);
                if (user != null) {
                    userDAO.linkKakaoId(user.getId(), kakaoId);
                    if ((user.getProfileImageUrl() == null || user.getProfileImageUrl().isEmpty())
                            && profileImageUrl != null) {
                        userDAO.updateProfileImage((int) user.getId(), profileImageUrl);
                        user.setProfileImageUrl(profileImageUrl);
                    }
                    userDAO.updateKakaoInfo(user.getId(), gender, ageRange, birthyear, birthday);
                }
            }

            if (user == null) {
                // 3) 신규 사용자 생성
                User newUser = new User();
                newUser.setKakaoId(kakaoId);
                newUser.setEmail(email);
                newUser.setFullName(nickname);
                newUser.setProfileImageUrl(profileImageUrl);
                newUser.setGender(gender);
                newUser.setAgeRange(ageRange);
                newUser.setBirthyear(birthyear);
                newUser.setBirthday(birthday);
                newUser.setActive(true);
                newUser.setEmailVerified(email != null);

                long newId = userDAO.createSocialUser(newUser);
                if (newId < 0) {
                    response.sendRedirect("/AI/user/login.jsp?kakao_error=create_failed");
                    return;
                }
                user = userDAO.findById(newId);
            }

            if (user != null) {
                userDAO.updateLastLogin(user.getId());
            }

        } catch (Exception e) {
            getServletContext().log("카카오 로그인 처리 중 오류", e);
            response.sendRedirect("/AI/user/login.jsp?kakao_error=server_error");
            return;
        }

        if (user == null || !user.isActive()) {
            response.sendRedirect("/AI/user/login.jsp?kakao_error=account_inactive");
            return;
        }

        // 세션 재생성 (session fixation 방지)
        if (session != null) {
            session.invalidate();
        }
        HttpSession newSession = request.getSession(true);
        newSession.setAttribute("user", user);

        // 리다이렉트
        if (savedRedirect != null && savedRedirect.startsWith("/") && !savedRedirect.startsWith("//")) {
            response.sendRedirect(savedRedirect);
        } else {
            response.sendRedirect("/AI/user/home.jsp");
        }
    }

    // ────────────────────────────────────────────────────────────────────────
    // 인가 코드 → 액세스 토큰 교환
    // ────────────────────────────────────────────────────────────────────────
    private String exchangeCodeForToken(String code) throws IOException {
        HttpURLConnection conn = (HttpURLConnection) new URL(KAKAO_TOKEN_URL).openConnection();
        conn.setRequestMethod("POST");
        conn.setDoOutput(true);
        conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded;charset=UTF-8");
        conn.setConnectTimeout(5000);
        conn.setReadTimeout(10000);

        String body = "grant_type=authorization_code"
                + "&client_id=" + URLEncoder.encode(getRestApiKey(), "UTF-8")
                + "&redirect_uri=" + URLEncoder.encode(getRedirectUri(), "UTF-8")
                + "&code=" + URLEncoder.encode(code, "UTF-8");

        try (OutputStream os = conn.getOutputStream()) {
            os.write(body.getBytes(StandardCharsets.UTF_8));
        }

        if (conn.getResponseCode() != 200) {
            // 오류 응답 로깅용
            readStream(conn.getErrorStream());
            return null;
        }

        String json = readStream(conn.getInputStream());
        JsonObject obj = JsonParser.parseString(json).getAsJsonObject();
        return obj.has("access_token") ? obj.get("access_token").getAsString() : null;
    }

    // ────────────────────────────────────────────────────────────────────────
    // 액세스 토큰으로 카카오 사용자 정보 조회
    // ────────────────────────────────────────────────────────────────────────
    private JsonObject getKakaoUserInfo(String accessToken) throws IOException {
        HttpURLConnection conn = (HttpURLConnection) new URL(KAKAO_USER_URL).openConnection();
        conn.setRequestMethod("GET");
        conn.setRequestProperty("Authorization", "Bearer " + accessToken);
        conn.setConnectTimeout(5000);
        conn.setReadTimeout(10000);

        if (conn.getResponseCode() != 200) return null;

        String json = readStream(conn.getInputStream());
        return JsonParser.parseString(json).getAsJsonObject();
    }

    private String readStream(InputStream is) throws IOException {
        if (is == null) return "";
        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(is, StandardCharsets.UTF_8))) {
            String line;
            while ((line = reader.readLine()) != null) sb.append(line);
        }
        return sb.toString();
    }

    private String getCookieValue(HttpServletRequest request, String name) {
        Cookie[] cookies = request.getCookies();
        if (cookies == null) return null;
        for (Cookie cookie : cookies) {
            if (name.equals(cookie.getName())) {
                return cookie.getValue();
            }
        }
        return null;
    }

    private void addCookie(HttpServletRequest request, HttpServletResponse response,
                           String name, String value, int maxAge) {
        StringBuilder cookie = new StringBuilder();
        cookie.append(name).append("=").append(value == null ? "" : value)
                .append("; Max-Age=").append(maxAge)
                .append("; Path=/")
                .append("; HttpOnly")
                .append("; SameSite=Lax");
        if (isSecureRequest(request)) {
            cookie.append("; Secure");
        }
        response.addHeader("Set-Cookie", cookie.toString());
    }

    private void clearCookie(HttpServletRequest request, HttpServletResponse response, String name) {
        addCookie(request, response, name, "", 0);
    }

    private boolean isSecureRequest(HttpServletRequest request) {
        if (request.isSecure()) return true;
        String forwardedProto = request.getHeader("X-Forwarded-Proto");
        return forwardedProto != null && forwardedProto.toLowerCase().contains("https");
    }

    private String encodeCookieValue(String value) {
        if (value == null || value.isEmpty()) return "";
        return Base64.getUrlEncoder().withoutPadding()
                .encodeToString(value.getBytes(StandardCharsets.UTF_8));
    }

    private String decodeCookieValue(String value) {
        if (value == null || value.isEmpty()) return null;
        try {
            return new String(Base64.getUrlDecoder().decode(value), StandardCharsets.UTF_8);
        } catch (IllegalArgumentException e) {
            getServletContext().log("카카오 OAuth redirect cookie decode 실패", e);
            return null;
        }
    }
}
