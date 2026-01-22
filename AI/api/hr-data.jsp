<%@ page contentType="application/json; charset=UTF-8" %>
<%@ page import="dao.HRDAO" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="java.util.*" %>
<%
  // 관리자 인증 확인
  if (session.getAttribute("admin") == null) {
    response.setStatus(401);
    out.print("{\"error\":\"인증이 필요합니다.\"}");
    return;
  }

  response.setHeader("Access-Control-Allow-Origin", "*");
  response.setHeader("Access-Control-Allow-Methods", "GET");
  response.setHeader("Content-Type", "application/json; charset=UTF-8");

  String action = request.getParameter("action");
  HRDAO hrDAO = new HRDAO();
  Gson gson = new Gson();
  Map<String, Object> result = new HashMap<>();

  try {
    if ("summary".equals(action)) {
      // 요약 데이터 조회
      String department = request.getParameter("department");
      String division = request.getParameter("division");
      String jobCategory = request.getParameter("jobCategory");
      
      if (department == null) department = "전체";
      if (division == null) division = "전체";
      if (jobCategory == null) jobCategory = "전체";
      
      Map<String, Object> summary = hrDAO.getHRSummary(department, division, jobCategory);
      result.put("success", true);
      result.put("data", summary);
      
    } else if ("trend".equals(action)) {
      // 현원 추이 조회
      int weeks = 8;
      try {
        String weeksParam = request.getParameter("weeks");
        if (weeksParam != null) {
          weeks = Integer.parseInt(weeksParam);
        }
      } catch (NumberFormatException e) {
        // 기본값 사용
      }
      
      List<Map<String, Object>> trends = hrDAO.getHeadcountTrend(weeks);
      result.put("success", true);
      result.put("data", trends);
      
    } else if ("organization".equals(action)) {
      // 조직별 상세 정보 조회
      String department = request.getParameter("department");
      String division = request.getParameter("division");
      
      List<model.HRData> hrList = hrDAO.getHRByOrganization(department, division);
      
      // HRData를 Map으로 변환
      List<Map<String, Object>> hrDataList = new ArrayList<>();
      for (model.HRData hr : hrList) {
        Map<String, Object> hrMap = new HashMap<>();
        hrMap.put("id", hr.getId());
        hrMap.put("department", hr.getDepartment());
        hrMap.put("division", hr.getDivision());
        hrMap.put("jobCategory", hr.getJobCategory());
        hrMap.put("quota", hr.getQuota());
        hrMap.put("currentHeadcount", hr.getCurrentHeadcount());
        hrMap.put("newHires", hr.getNewHires());
        hrMap.put("resignations", hr.getResignations());
        hrMap.put("transfers", hr.getTransfers());
        hrMap.put("vacancies", hr.getVacancies());
        hrMap.put("onLeave", hr.getOnLeave());
        hrMap.put("returned", hr.getReturned());
        hrMap.put("laborCost", hr.getLaborCost());
        hrDataList.add(hrMap);
      }
      
      result.put("success", true);
      result.put("data", hrDataList);
      
    } else if ("filters".equals(action)) {
      // 필터 옵션 조회
      Map<String, List<String>> filterOptions = hrDAO.getFilterOptions();
      result.put("success", true);
      result.put("data", filterOptions);
      
    } else if ("filterOptions".equals(action)) {
      // 계층적 필터 옵션 조회
      String type = request.getParameter("type");
      String parentValue = request.getParameter("department");
      if (parentValue == null) parentValue = request.getParameter("businessUnit");
      if (parentValue == null) parentValue = request.getParameter("team");
      
      List<String> options = hrDAO.getFilterOptionsByType(type, parentValue);
      result.put("success", true);
      result.put("data", options);
      
    } else if ("searchEmployee".equals(action)) {
      // 직원 검색
      String searchTerm = request.getParameter("term");
      if (searchTerm == null || searchTerm.trim().isEmpty()) {
        result.put("success", false);
        result.put("error", "검색어를 입력해주세요.");
      } else {
        model.Employee employee = hrDAO.searchEmployee(searchTerm);
        if (employee != null) {
          Map<String, Object> empMap = new HashMap<>();
          empMap.put("id", employee.getId());
          empMap.put("employeeId", employee.getEmployeeId());
          empMap.put("name", employee.getName());
          empMap.put("department", employee.getDepartment());
          empMap.put("businessUnit", employee.getBusinessUnit());
          empMap.put("team", employee.getTeam());
          empMap.put("part", employee.getPart());
          empMap.put("line", employee.getLine());
          empMap.put("jobCategory", employee.getJobCategory());
          empMap.put("position", employee.getPosition());
          empMap.put("location", employee.getLocation());
          empMap.put("performanceGrade", employee.getPerformanceGrade());
          empMap.put("salaryGrade", employee.getSalaryGrade());
          empMap.put("salary", employee.getSalary());
          empMap.put("joinDate", employee.getJoinDate() != null ? employee.getJoinDate().toString() : null);
          empMap.put("status", employee.getStatus());
          
          result.put("success", true);
          result.put("data", empMap);
        } else {
          result.put("success", false);
          result.put("error", "검색 결과가 없습니다.");
        }
      }
      
    } else {
      result.put("success", false);
      result.put("error", "알 수 없는 액션입니다.");
    }
    
  } catch (Exception e) {
    e.printStackTrace();
    result.put("success", false);
    result.put("error", e.getMessage());
  }
  
  out.print(gson.toJson(result));
%>

