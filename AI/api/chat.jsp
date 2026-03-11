<%@ page contentType="application/json; charset=UTF-8" trimDirectiveWhitespaces="true" %>
<%@ page import="dao.CreditDAO, dao.UserProgressDAO" %>
<%@ page import="model.User" %>
<%@ page import="java.net.*, java.io.*, java.nio.charset.StandardCharsets" %>
<%@ page import="com.google.gson.*" %>
<%@ page import="util.EncryptionUtil" %>
<%
  response.setHeader("Cache-Control","no-store");
  request.setCharacterEncoding("UTF-8");

  User user = (User) session.getAttribute("user");
  if (user == null) {
    out.print("{\"error\":\"auth\",\"message\":\"로그인이 필요합니다.\"}");
    return;
  }

  String userMessage   = request.getParameter("message");
  String systemPrompt  = request.getParameter("system");
  String projectIdStr  = request.getParameter("projectId");
  String feature       = request.getParameter("feature");
  if (feature == null) feature = "lab_assistant";
  if (userMessage == null || userMessage.trim().isEmpty()) {
    out.print("{\"error\":\"empty\",\"message\":\"메시지를 입력하세요.\"}");
    return;
  }
  userMessage = userMessage.trim();
  if (userMessage.length() > 4000) userMessage = userMessage.substring(0, 4000);

  Integer projectId = null;
  try { projectId = Integer.parseInt(projectIdStr); } catch(Exception e) {}

  // ── API 키 결정 (BYOK > 플랫폼 키) ─────────────────────────────
  String apiKey = null;
  String keyProvider = null;
  // 1. 사용자 자체 API 키 확인
  try {
    java.sql.Connection dbConn = db.DBConnect.getConnection();
    java.sql.PreparedStatement ps = dbConn.prepareStatement(
      "SELECT provider, api_key_enc FROM user_api_keys WHERE user_id=? AND is_verified=1 LIMIT 1");
    ps.setLong(1, user.getId());
    java.sql.ResultSet rs = ps.executeQuery();
    if (rs.next()) {
      keyProvider = rs.getString(1);
      apiKey = EncryptionUtil.decrypt(rs.getString(2));
    }
    rs.close(); ps.close(); dbConn.close();
  } catch(Exception e) { /* ignore */ }

  // 2. 플랫폼 API 키 (환경 변수)
  boolean usingPlatformKey = false;
  if (apiKey == null) {
    apiKey = System.getenv("ANTHROPIC_API_KEY");
    keyProvider = "anthropic";
    if (apiKey != null) usingPlatformKey = true;
  }

  if (apiKey == null) {
    out.print("{\"error\":\"no_key\",\"message\":\"AI 기능을 사용하려면 API 키를 등록하거나 플랜을 구독하세요.\",\"action\":\"setup\"}");
    return;
  }
  apiKey = apiKey.trim();
  String detectedProvider = null;
  if (apiKey.startsWith("sk-ant-")) {
    detectedProvider = "anthropic";
  } else if (apiKey.startsWith("sk-proj-") || apiKey.startsWith("sk-")) {
    detectedProvider = "openai";
  } else if ("anthropic".equalsIgnoreCase(keyProvider) || "openai".equalsIgnoreCase(keyProvider)) {
    detectedProvider = keyProvider.toLowerCase();
  }
  if (!usingPlatformKey) {
    if (detectedProvider == null) {
      out.print("{\"error\":\"unsupported_key\",\"message\":\"현재 저장된 키 형식을 인식할 수 없습니다. Anthropic(sk-ant-...) 또는 OpenAI(sk-proj-, sk-...) 키를 등록하세요.\",\"action\":\"setup\"}");
      return;
    }
    keyProvider = detectedProvider;
  }
  if (!usingPlatformKey) {
    keyProvider = detectedProvider;
  }

  // ── 크레딧 확인 (플랫폼 키 사용 시만 차감) ──────────────────────
  int CREDIT_COST = 1;
  CreditDAO creditDao = new CreditDAO();
  if (usingPlatformKey) {
    int balance = creditDao.getBalance(user.getId());
    if (balance < CREDIT_COST) {
      out.print("{\"error\":\"no_credits\",\"message\":\"크레딧이 부족합니다. 플랜을 업그레이드하세요.\",\"balance\":" + balance + ",\"action\":\"upgrade\"}");
      return;
    }
  }

  // ── AI API 호출 ────────────────────────────────────────────────
  String model = "claude-haiku-4-5-20251001";
  if (systemPrompt == null || systemPrompt.trim().isEmpty()) {
    systemPrompt = "당신은 AI Workflow Lab의 실습 도우미입니다. 사용자가 AI 도구 활용 실습을 진행할 때 단계별로 명확하고 실용적인 도움을 제공합니다. 답변은 한국어로, 간결하고 실용적으로 작성하세요. 코드나 프롬프트 예시가 필요하면 반드시 포함하세요.";
  }

  Gson gson = new Gson();
  String responseText = null;
  int promptTokens = 0, outputTokens = 0;
  String errorMsg = null;

  try {
    if ("openai".equalsIgnoreCase(keyProvider)) {
      model = "gpt-4.1-mini";
      JsonObject body = new JsonObject();
      body.addProperty("model", model);
      body.addProperty("max_tokens", 1024);

      JsonArray messages = new JsonArray();
      JsonObject sysMsg = new JsonObject();
      sysMsg.addProperty("role", "system");
      sysMsg.addProperty("content", systemPrompt);
      messages.add(sysMsg);

      JsonObject userMsg = new JsonObject();
      userMsg.addProperty("role", "user");
      userMsg.addProperty("content", userMessage);
      messages.add(userMsg);
      body.add("messages", messages);

      HttpURLConnection conn = (HttpURLConnection) new URL("https://api.openai.com/v1/chat/completions").openConnection();
      conn.setRequestMethod("POST");
      conn.setConnectTimeout(15000);
      conn.setReadTimeout(30000);
      conn.setDoOutput(true);
      conn.setRequestProperty("Content-Type", "application/json");
      conn.setRequestProperty("Authorization", "Bearer " + apiKey);

      try (OutputStream os = conn.getOutputStream()) {
        os.write(gson.toJson(body).getBytes(StandardCharsets.UTF_8));
      }

      int status = conn.getResponseCode();
      InputStream is = status < 400 ? conn.getInputStream() : conn.getErrorStream();
      StringBuilder sb = new StringBuilder();
      try (BufferedReader br = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
        String line;
        while ((line = br.readLine()) != null) sb.append(line);
      }

      if (status == 200) {
        JsonObject resp = gson.fromJson(sb.toString(), JsonObject.class);
        JsonArray choices = resp.getAsJsonArray("choices");
        if (choices != null && choices.size() > 0) {
          JsonObject messageObj = choices.get(0).getAsJsonObject().getAsJsonObject("message");
          if (messageObj != null && messageObj.has("content") && !messageObj.get("content").isJsonNull()) {
            responseText = messageObj.get("content").getAsString();
          }
        }
        JsonObject usage = resp.getAsJsonObject("usage");
        if (usage != null) {
          promptTokens = usage.has("prompt_tokens") ? usage.get("prompt_tokens").getAsInt() : 0;
          outputTokens = usage.has("completion_tokens") ? usage.get("completion_tokens").getAsInt() : 0;
        }
      } else {
        JsonObject errResp = gson.fromJson(sb.toString(), JsonObject.class);
        errorMsg = errResp.has("error") ?
          errResp.getAsJsonObject("error").get("message").getAsString() : "API 오류 " + status;
      }
    } else {
      JsonObject body = new JsonObject();
      body.addProperty("model", model);
      body.addProperty("max_tokens", 1024);

      JsonArray systemArr = new JsonArray();
      JsonObject sysBlock = new JsonObject();
      sysBlock.addProperty("type", "text");
      sysBlock.addProperty("text", systemPrompt);
      systemArr.add(sysBlock);
      body.add("system", systemArr);

      JsonArray messages = new JsonArray();
      JsonObject userMsg = new JsonObject();
      userMsg.addProperty("role", "user");
      userMsg.addProperty("content", userMessage);
      messages.add(userMsg);
      body.add("messages", messages);

      HttpURLConnection conn = (HttpURLConnection) new URL("https://api.anthropic.com/v1/messages").openConnection();
      conn.setRequestMethod("POST");
      conn.setConnectTimeout(15000);
      conn.setReadTimeout(30000);
      conn.setDoOutput(true);
      conn.setRequestProperty("Content-Type", "application/json");
      conn.setRequestProperty("x-api-key", apiKey);
      conn.setRequestProperty("anthropic-version", "2023-06-01");

      try (OutputStream os = conn.getOutputStream()) {
        os.write(gson.toJson(body).getBytes(StandardCharsets.UTF_8));
      }

      int status = conn.getResponseCode();
      InputStream is = status < 400 ? conn.getInputStream() : conn.getErrorStream();
      StringBuilder sb = new StringBuilder();
      try (BufferedReader br = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
        String line;
        while ((line = br.readLine()) != null) sb.append(line);
      }

      if (status == 200) {
        JsonObject resp = gson.fromJson(sb.toString(), JsonObject.class);
        JsonArray content = resp.getAsJsonArray("content");
        if (content != null && content.size() > 0) {
          responseText = content.get(0).getAsJsonObject().get("text").getAsString();
        }
        JsonObject usage = resp.getAsJsonObject("usage");
        if (usage != null) {
          promptTokens = usage.has("input_tokens") ? usage.get("input_tokens").getAsInt() : 0;
          outputTokens = usage.has("output_tokens") ? usage.get("output_tokens").getAsInt() : 0;
        }
      } else {
        JsonObject errResp = gson.fromJson(sb.toString(), JsonObject.class);
        errorMsg = errResp.has("error") ?
          errResp.getAsJsonObject("error").get("message").getAsString() : "API 오류 " + status;
      }
    }
  } catch (Exception e) {
    errorMsg = "연결 오류: " + e.getMessage();
  }

  if (errorMsg != null) {
    JsonObject errOut = new JsonObject();
    errOut.addProperty("error", "api_error");
    errOut.addProperty("message", errorMsg);
    out.print(gson.toJson(errOut));
    return;
  }

  // ── 크레딧 차감 ────────────────────────────────────────────────
  if (usingPlatformKey) {
    String summary = userMessage.length() > 100 ? userMessage.substring(0,100) : userMessage;
    creditDao.deduct(user.getId(), CREDIT_COST, model,
                     promptTokens, outputTokens, feature, projectId, summary);
  }

  // ── 응답 ───────────────────────────────────────────────────────
  int newBalance = usingPlatformKey ? creditDao.getBalance(user.getId()) : -1;
  JsonObject out2 = new JsonObject();
  out2.addProperty("ok", true);
  out2.addProperty("message", responseText);
  out2.addProperty("model", model);
  out2.addProperty("promptTokens", promptTokens);
  out2.addProperty("outputTokens", outputTokens);
  out2.addProperty("creditsUsed", usingPlatformKey ? CREDIT_COST : 0);
  out2.addProperty("balance", newBalance);
  out2.addProperty("byok", !usingPlatformKey);
  out.print(gson.toJson(out2));
%>
