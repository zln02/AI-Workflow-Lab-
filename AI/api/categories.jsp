<%@ page contentType="application/json; charset=UTF-8" buffer="32kb" autoFlush="true" %>
<%@ page import="dao.CategoryDAO" %>
<%@ page import="java.util.*" %>
<%
  response.setHeader("Access-Control-Allow-Origin", "*");
  response.setHeader("Access-Control-Allow-Methods", "GET");
  response.setHeader("Content-Type", "application/json; charset=UTF-8");
  
  try {
    CategoryDAO categoryDAO = new CategoryDAO();
    var categories = categoryDAO.findAll();
    
    StringBuilder json = new StringBuilder("[");
    boolean first = true;
    for (var cat : categories) {
      if (!first) json.append(",");
      json.append("{");
      json.append("\"id\":").append(cat.getId()).append(",");
      json.append("\"name\":\"").append(escapeJson(cat.getCategoryName())).append("\"");
      json.append("}");
      first = false;
    }
    json.append("]");
    out.print(json.toString());
    
  } catch (Exception e) {
    response.setStatus(500);
    out.print("{\"error\":\"카테고리 조회 중 오류가 발생했습니다: " + escapeJson(e.getMessage()) + "\"}");
  }
%>
<%!
  private String escapeJson(String str) {
    if (str == null) return "";
    return str.replace("\\", "\\\\")
              .replace("\"", "\\\"")
              .replace("\n", "\\n")
              .replace("\r", "\\r")
              .replace("\t", "\\t");
  }
%>

