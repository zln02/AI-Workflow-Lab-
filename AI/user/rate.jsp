<%@ page contentType="application/json; charset=UTF-8" %>
<%
  // Exchange rate endpoint
  // Default rate: 1350 (USD to KRW)
  double defaultRate = 1350.0;
  
  // Allow override via query parameter for QA/testing
  String rateParam = request.getParameter("rate");
  double rate = defaultRate;
  
  if (rateParam != null) {
    try {
      rate = Double.parseDouble(rateParam);
      if (rate <= 0) rate = defaultRate;
    } catch (NumberFormatException e) {
      rate = defaultRate;
    }
  }
  
  response.setContentType("application/json");
  out.print("{\"rate\":" + rate + "}");
%>

