<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.PackageDAO" %>
<%@ page import="model.Package" %>
<%@ page import="model.Category" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="util.CSRFUtil" %>
<%
  if (session.getAttribute("admin") == null) {
    response.sendRedirect("/AI/admin/auth/login.jsp");
    return;
  }
  PackageDAO packageDAO = new PackageDAO();
  List<Package> packages = packageDAO.findAll();
  // 각 패키지의 카테고리 정보 로딩
  for (Package pkg : packages) {
    List<Category> categories = packageDAO.getCategoriesByPackageId(pkg.getId());
    pkg.setCategories(categories);
  }
%>
<%@ include file="/AI/admin/layout/header.jspf" %>
<div class="admin-layout">
  <%@ include file="/AI/admin/layout/sidebar.jspf" %>
  <div class="admin-main-wrapper">
    <%@ include file="/AI/admin/layout/topbar.jspf" %>
    <main class="admin-content">
      <header class="admin-dashboard-header">
        <h1>패키지 관리</h1>
        <p>AI 모델 패키지를 생성하고 관리합니다.</p>
        <a class="btn primary" href="/AI/admin/packages/form.jsp">새 패키지 생성</a>
      </header>
      <section class="admin-table-section">
        <table class="admin-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>패키지명</th>
              <th>설명</th>
              <th>가격</th>
              <th>할인가</th>
              <th>카테고리</th>
              <th>상태</th>
              <th>생성일</th>
              <th>액션</th>
            </tr>
          </thead>
          <tbody>
            <% if (packages.isEmpty()) { %>
              <tr><td colspan="9" style="text-align: center; padding: 40px;">등록된 패키지가 없습니다.</td></tr>
            <% } else { %>
              <% for (Package pkg : packages) { %>
                <tr>
                  <td><%= pkg.getId() %></td>
                  <td><strong><%= pkg.getTitle() != null ? pkg.getTitle() : "-" %></strong></td>
                  <td style="max-width: 300px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;"><%= pkg.getDescription() != null ? pkg.getDescription() : "-" %></td>
                  <td>
                    <% 
                      if (pkg.getPrice() != null) {
                        double priceUsd = pkg.getPrice().doubleValue();
                        long priceKrw = Math.round(priceUsd * 1350);
                    %>
                      <div style="font-size: 0.9em;">
                        <strong>USD:</strong> $<%= String.format("%.0f", priceUsd) %>/month<br>
                        <strong>KRW:</strong> <%= String.format("%,d", priceKrw) %>원
                      </div>
                    <% } else { %>
                      -
                    <% } %>
                  </td>
                  <td>
                    <% 
                      if (pkg.getDiscountPrice() != null && pkg.getDiscountPrice().compareTo(java.math.BigDecimal.ZERO) > 0) {
                        double discountUsd = pkg.getDiscountPrice().doubleValue();
                        long discountKrw = Math.round(discountUsd * 1350);
                    %>
                      <div style="color: #e74c3c; font-size: 0.9em;">
                        <strong>USD:</strong> $<%= String.format("%.0f", discountUsd) %>/month<br>
                        <strong>KRW:</strong> <%= String.format("%,d", discountKrw) %>원
                      </div>
                    <% } else { %>
                      -
                    <% } %>
                  </td>
                  <td>
                    <% 
                      if (pkg.getCategories() != null && !pkg.getCategories().isEmpty()) {
                        StringBuilder categoryNames = new StringBuilder();
                        for (int i = 0; i < pkg.getCategories().size(); i++) {
                          if (i > 0) categoryNames.append(", ");
                          categoryNames.append(pkg.getCategories().get(i).getCategoryName());
                        }
                    %>
                      <%= categoryNames.toString() %>
                    <% } else { %>
                      -
                    <% } %>
                  </td>
                  <td><span class="badge <%= pkg.isActive() ? "badge-success" : "badge-secondary" %>"><%= pkg.isActive() ? "활성" : "비활성" %></span></td>
                  <td><%= pkg.getCreatedAt() != null ? pkg.getCreatedAt().substring(0, 10) : "-" %></td>
                  <td>
                    <a href="/AI/admin/packages/form.jsp?id=<%= pkg.getId() %>" class="btn btn-sm">수정</a>
                    <form method="POST" action="/AI/admin/packages/delete.jsp" style="display:inline;" onsubmit="return confirm('정말 삭제하시겠습니까?');">
                      <input type="hidden" name="id" value="<%= pkg.getId() %>">
                      <%= CSRFUtil.getHiddenFieldHtml(request) %>
                      <button type="submit" class="btn btn-sm btn-danger">삭제</button>
                    </form>
                  </td>
                </tr>
              <% } %>
            <% } %>
          </tbody>
        </table>
      </section>
<%@ include file="/AI/admin/layout/footer.jspf" %>
