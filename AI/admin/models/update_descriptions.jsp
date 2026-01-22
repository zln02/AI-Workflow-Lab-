<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.AIModelDAO" %>
<%@ page import="model.AIModel" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%
  // 관리자 권한 확인
  String adminRole = (String) session.getAttribute("adminRole");
  if (adminRole == null || adminRole.isEmpty()) {
    response.sendRedirect("/AI/admin/auth/login.jsp");
    return;
  }
  
  AIModelDAO modelDAO = new AIModelDAO();
  List<AIModel> allModels = modelDAO.findAll();
  
  // 모델별 설명 및 사양 정보 맵
  Map<String, Map<String, String>> modelInfo = new HashMap<>();
  
  // GPT-4
  Map<String, String> gpt4 = new HashMap<>();
  gpt4.put("description", "GPT-4는 OpenAI에서 개발한 최신 대규모 언어 모델입니다. 이전 버전인 GPT-3.5보다 훨씬 향상된 성능을 제공하며, 더 복잡한 추론, 창의적 작업, 그리고 세밀한 지시사항 이해가 가능합니다. 멀티모달 기능을 지원하여 텍스트뿐만 아니라 이미지 입력도 처리할 수 있습니다. 실제 업무에서 코드 작성, 창의적 글쓰기, 기술적 문서 작성, 번역, 요약 등 다양한 작업에 활용됩니다.");
  gpt4.put("params", "1800");
  gpt4.put("input", "TEXT,IMAGE");
  gpt4.put("latency", "500");
  modelInfo.put("GPT-4", gpt4);
  modelInfo.put("gpt-4", gpt4);
  
  // GPT-3.5
  Map<String, String> gpt35 = new HashMap<>();
  gpt35.put("description", "GPT-3.5 Turbo는 OpenAI의 고성능이면서도 비용 효율적인 언어 모델입니다. GPT-4보다 빠른 응답 속도와 낮은 비용을 제공하며, 대부분의 텍스트 기반 작업에서 우수한 성능을 보입니다. 대화형 챗봇, 콘텐츠 생성, 코드 작성, 번역, 요약 등 다양한 용도로 활용 가능합니다. 특히 빠른 응답이 필요한 실시간 애플리케이션에 적합합니다.");
  gpt35.put("params", "175");
  gpt35.put("input", "TEXT");
  gpt35.put("latency", "300");
  modelInfo.put("GPT-3.5", gpt35);
  modelInfo.put("GPT-3.5 Turbo", gpt35);
  modelInfo.put("gpt-3.5", gpt35);
  
  // Gemini
  Map<String, String> gemini = new HashMap<>();
  gemini.put("description", "Gemini Pro는 Google DeepMind에서 개발한 차세대 멀티모달 AI 모델입니다. 텍스트, 이미지, 오디오, 비디오를 동시에 이해하고 처리할 수 있는 혁신적인 모델로, 다양한 입력을 통합하여 더 정확하고 맥락에 맞는 응답을 제공합니다. 복잡한 다단계 추론, 코드 생성, 과학적 문제 해결 등에 탁월한 성능을 보이며, 특히 한국어 처리에 최적화되어 있습니다.");
  gemini.put("params", "540");
  gemini.put("input", "TEXT,IMAGE,AUDIO,VIDEO");
  gemini.put("latency", "600");
  modelInfo.put("Gemini", gemini);
  modelInfo.put("gemini", gemini);
  
  // Claude
  Map<String, String> claude = new HashMap<>();
  claude.put("description", "Claude는 Anthropic에서 개발한 안전하고 도움이 되는 AI 어시스턴트입니다. 긴 문서 분석, 복잡한 추론, 창의적 글쓰기, 코드 리뷰 등 다양한 작업에 활용됩니다. 특히 긴 컨텍스트(최대 200K 토큰)를 처리할 수 있어 긴 문서 전체를 한 번에 분석하거나, 전체 코드베이스를 이해하는 작업에 적합합니다. 안전성과 유용성을 최우선으로 설계되어 기업 환경에서도 신뢰할 수 있습니다.");
  claude.put("params", "520");
  claude.put("input", "TEXT,IMAGE");
  claude.put("latency", "800");
  modelInfo.put("Claude", claude);
  claude.put("claude", claude);
  
  // DALL-E
  Map<String, String> dalle = new HashMap<>();
  dalle.put("description", "DALL-E는 OpenAI에서 개발한 텍스트-이미지 생성 AI 모델입니다. 자연어 설명만으로 고품질의 이미지를 생성할 수 있으며, 다양한 스타일과 개념을 이해하고 시각화합니다. 창의적인 일러스트레이션, 디자인 초안, 마케팅 이미지, 콘텐츠 이미지 생성 등에 활용됩니다. 다양한 해상도와 종횡비를 지원하며, 특정 스타일이나 기존 이미지를 참조한 생성도 가능합니다.");
  dalle.put("params", "12");
  dalle.put("input", "TEXT");
  dalle.put("latency", "5000");
  modelInfo.put("DALL-E", dalle);
  modelInfo.put("DALL-E 3", dalle);
  modelInfo.put("dalle", dalle);
  
  // Whisper
  Map<String, String> whisper = new HashMap<>();
  whisper.put("description", "Whisper는 OpenAI에서 개발한 자동 음성 인식(ASR) 시스템입니다. 다양한 언어와 방언을 지원하며, 배경 소음과 다양한 음성 스타일에 강건합니다. 음성-텍스트 변환, 실시간 자막 생성, 음성 명령 인식, 다국어 번역 등에 활용됩니다. 오픈소스로 공개되어 있어 온프레미스 환경에서도 사용할 수 있으며, 데이터 프라이버시가 중요한 환경에 적합합니다.");
  whisper.put("params", "1.55");
  whisper.put("input", "AUDIO");
  whisper.put("latency", "2000");
  modelInfo.put("Whisper", whisper);
  modelInfo.put("whisper", whisper);
  
  String action = request.getParameter("action");
  if ("update".equals(action)) {
    String modelId = request.getParameter("modelId");
    String description = request.getParameter("description");
    
    if (modelId != null && description != null) {
      try {
        int id = Integer.parseInt(modelId);
        AIModel model = modelDAO.findById(id);
        if (model != null) {
          model.setDescription(description);
          modelDAO.update(model);
        }
      } catch (Exception e) {
        e.printStackTrace();
      }
    }
    response.sendRedirect("update_descriptions.jsp?success=1");
    return;
  }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>모델 설명 업데이트</title>
</head>
<body>
  <h1>모델 설명 및 사양 업데이트</h1>
  <p>현재 데이터베이스에 있는 모델 목록:</p>
  <table border="1">
    <tr>
      <th>ID</th>
      <th>모델명</th>
      <th>제공업체</th>
      <th>카테고리</th>
      <th>현재 설명</th>
      <th>작업</th>
    </tr>
    <% for (AIModel model : allModels) { %>
      <tr>
        <td><%= model.getId() %></td>
        <td><%= model.getModelName() != null ? model.getModelName() : "N/A" %></td>
        <td><%= model.getProviderName() != null ? model.getProviderName() : "N/A" %></td>
        <td><%= model.getCategoryName() != null ? model.getCategoryName() : "N/A" %></td>
        <td><%= model.getDescription() != null && !model.getDescription().isEmpty() 
            ? (model.getDescription().length() > 100 ? model.getDescription().substring(0, 100) + "..." : model.getDescription())
            : "설명 없음" %></td>
        <td>
          <% 
            String modelName = model.getModelName() != null ? model.getModelName() : "";
            Map<String, String> info = null;
            for (String key : modelInfo.keySet()) {
              if (modelName.contains(key)) {
                info = modelInfo.get(key);
                break;
              }
            }
          %>
          <% if (info != null) { %>
            <form method="POST" action="update_descriptions.jsp">
              <input type="hidden" name="action" value="update">
              <input type="hidden" name="modelId" value="<%= model.getId() %>">
              <input type="hidden" name="description" value="<%= info.get("description") %>">
              <button type="submit">자동 업데이트</button>
            </form>
          <% } else { %>
            <button onclick="alert('이 모델에 대한 자동 업데이트 정보가 없습니다. 수동으로 관리자 페이지에서 업데이트해주세요.')">수동 업데이트 필요</button>
          <% } %>
        </td>
      </tr>
    <% } %>
  </table>
  
  <% if ("1".equals(request.getParameter("success"))) { %>
    <p style="color: green;">업데이트가 완료되었습니다!</p>
  <% } %>
  
  <p><a href="/AI/admin/models/index.jsp">모델 관리로 돌아가기</a></p>
</body>
</html>


