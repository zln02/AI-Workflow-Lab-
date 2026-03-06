<%@ page contentType="application/json; charset=UTF-8" %>
<%@ page import="dao.OrderDAO" %>
<%@ page import="dao.OrderDAO.SalesStatistics" %>
<%@ page import="model.Order" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="java.util.*" %>
<%
  // 관리자 인증 확인
  if (session.getAttribute("admin") == null) {
    response.setStatus(401);
    out.print("{\"error\":\"인증이 필요합니다.\"}");
    return;
  }

  response.setHeader("Access-Control-Allow-Origin", "http://localhost:8080");
  response.setHeader("Access-Control-Allow-Methods", "GET");
  response.setHeader("Content-Type", "application/json; charset=UTF-8");

  try {
    OrderDAO orderDAO = new OrderDAO();
    
    // 최근 30일간 통계 조회
    SalesStatistics stats = orderDAO.getSalesStatistics();
    
    // 전체 통계도 조회 (기간 제한 없음)
    List<Order> allOrders = orderDAO.findAll();
    int totalAllOrders = allOrders.size();
    double totalAllRevenue = 0.0;
    double avgAllOrderValue = 0.0;
    
    if (totalAllOrders > 0) {
      for (Order order : allOrders) {
        if (order.getTotalPrice() != null) {
          totalAllRevenue += order.getTotalPrice().doubleValue();
        }
      }
      avgAllOrderValue = totalAllOrders > 0 ? totalAllRevenue / totalAllOrders : 0.0;
    }
    
    // JSON 응답
    Map<String, Object> result = new HashMap<>();
    result.put("success", true);
    
    // 최근 30일간 통계
    Map<String, Object> recent30Days = new HashMap<>();
    recent30Days.put("totalOrders", stats.getTotalOrders());
    recent30Days.put("totalRevenue", stats.getTotalRevenue() != null ? stats.getTotalRevenue().doubleValue() : 0.0);
    recent30Days.put("avgOrderValue", stats.getAvgOrderValue() != null ? stats.getAvgOrderValue().doubleValue() : 0.0);
    result.put("recent30Days", recent30Days);
    
    // 전체 통계
    Map<String, Object> allTime = new HashMap<>();
    allTime.put("totalOrders", totalAllOrders);
    allTime.put("totalRevenue", totalAllRevenue);
    allTime.put("avgOrderValue", avgAllOrderValue);
    result.put("allTime", allTime);
    
    Gson gson = new Gson();
    out.print(gson.toJson(result));
    
  } catch (Exception e) {
    response.setStatus(500);
    e.printStackTrace();
    Map<String, Object> error = new HashMap<>();
    error.put("success", false);
    error.put("error", "통계 조회 중 오류가 발생했습니다.");
    
    Gson gson = new Gson();
    out.print(gson.toJson(error));
  }
%>

