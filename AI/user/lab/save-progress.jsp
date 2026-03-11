<%@ page contentType="application/json; charset=UTF-8" %>
<%@ page import="dao.UserProgressDAO" %>
<%@ page import="model.User" %>
<%
  response.setHeader("Cache-Control","no-store");
  User user = (User) session.getAttribute("user");
  if (user == null) { out.print("{\"ok\":false,\"msg\":\"auth\"}"); return; }

  String projectIdStr = request.getParameter("projectId");
  String bookmarks    = request.getParameter("bookmarks");
  String notes        = request.getParameter("notes");
  String pctStr       = request.getParameter("pct");
  String status       = request.getParameter("status");
  String minsStr      = request.getParameter("minutes");

  int projectId = 0;
  try { projectId = Integer.parseInt(projectIdStr); } catch(Exception e) {}
  double pct = 0; try { pct = Double.parseDouble(pctStr); } catch(Exception e) {}
  int minutes = 0; try { minutes = Integer.parseInt(minsStr); } catch(Exception e) {}

  if (projectId <= 0) { out.print("{\"ok\":false,\"msg\":\"invalid id\"}"); return; }
  if (bookmarks == null) bookmarks = "[]";
  if (notes == null) notes = "{}";
  if (status == null || status.isEmpty()) status = "In Progress";

  try {
    UserProgressDAO dao = new UserProgressDAO();
    dao.upsert(user.getId(), projectId, pct, bookmarks, notes, minutes, status);
    out.print("{\"ok\":true}");
  } catch(Exception e) {
    out.print("{\"ok\":false,\"msg\":\"" + e.getMessage().replace("\"","'") + "\"}");
  }
%>
