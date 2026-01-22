<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.AIModelDAO" %>
<%@ page import="dao.ProviderDAO" %>
<%@ page import="dao.CategoryDAO" %>
<%@ page import="model.AIModel" %>
<%@ page import="model.Provider" %>
<%@ page import="model.Category" %>
<%@ page import="java.util.List" %>
<%
  if (session.getAttribute("admin") == null) {
    response.sendRedirect("/AI/admin/auth/login.jsp");
    return;
  }
  AIModelDAO modelDAO = new AIModelDAO();
  ProviderDAO providerDAO = new ProviderDAO();
  CategoryDAO categoryDAO = new CategoryDAO();
  AIModel model = null;
  String idParam = request.getParameter("id");
  if (idParam != null && !idParam.trim().isEmpty()) {
    try {
      int id = Integer.parseInt(idParam);
      model = modelDAO.findById(id);
    } catch (NumberFormatException e) {}
  }
  List<Provider> providers = providerDAO.findAll();
  List<Category> categories = categoryDAO.findAll();
%>
<%@ include file="/AI/admin/layout/header.jspf" %>
<div class="admin-layout">
  <%@ include file="/AI/admin/layout/sidebar.jspf" %>
  <div class="admin-main-wrapper">
    <%@ include file="/AI/admin/layout/topbar.jspf" %>
    <main class="admin-content">
      <header class="admin-dashboard-header">
        <h1><%= model != null ? "모델 수정" : "새 모델 생성" %></h1>
        <a class="btn ghost" href="/AI/admin/models/index.jsp">목록으로</a>
      </header>
      <section class="admin-form-section">
        <form method="POST" action="/AI/admin/models/save.jsp" id="modelForm">
          <% if (model != null) { %><input type="hidden" name="id" value="<%= model.getId() %>"><% } %>
          <div class="form-row">
            <div class="form-group">
              <label for="model_name">모델명 *</label>
              <input type="text" id="model_name" name="model_name" required value="<%= model != null && model.getModelName() != null ? model.getModelName() : "" %>">
            </div>
            <div class="form-group">
              <label for="provider_id">제공사</label>
              <select id="provider_id" name="provider_id">
                <option value="">선택 안함</option>
                <% for (Provider provider : providers) { %>
                  <option value="<%= provider.getId() %>" <%= model != null && model.getProviderId() != null && model.getProviderId() == provider.getId() ? "selected" : "" %>><%= provider.getProviderName() %></option>
                <% } %>
              </select>
            </div>
            <div class="form-group">
              <label for="category_id">카테고리</label>
              <select id="category_id" name="category_id">
                <option value="">선택 안함</option>
                <% for (Category category : categories) { %>
                  <option value="<%= category.getId() %>" <%= model != null && model.getCategoryId() != null && model.getCategoryId() == category.getId() ? "selected" : "" %>><%= category.getCategoryName() %></option>
                <% } %>
              </select>
            </div>
          </div>
          <div class="form-group">
            <label for="price">가격 정보</label>
            <input type="text" id="price" name="price" value="<%= model != null && model.getPrice() != null ? model.getPrice() : "" %>" placeholder="예: $0.002/1K tokens">
          </div>
          <div class="form-group">
            <label for="description">설명</label>
            <textarea id="description" name="description" rows="4"><%= model != null && model.getDescription() != null ? model.getDescription() : "" %></textarea>
          </div>
          <div class="form-group">
            <label for="purpose_summary">주요 용도 요약</label>
            <input type="text" id="purpose_summary" name="purpose_summary" value="<%= model != null && model.getPurposeSummary() != null ? model.getPurposeSummary() : "" %>">
          </div>
          <div class="form-row">
            <div class="form-group">
              <label><input type="checkbox" name="api_available" value="true" <%= model == null || model.isApiAvailable() ? "checked" : "" %>> API 제공</label>
            </div>
            <div class="form-group">
              <label><input type="checkbox" name="finetune_available" value="true" <%= model != null && model.isFinetuneAvailable() ? "checked" : "" %>> 파인튜닝 가능</label>
            </div>
            <div class="form-group">
              <label><input type="checkbox" name="onprem_available" value="true" <%= model != null && model.isOnpremAvailable() ? "checked" : "" %>> 온프레미스 가능</label>
            </div>
            <div class="form-group">
              <label><input type="checkbox" name="commercial_use_allowed" value="true" <%= model == null || model.isCommercialUseAllowed() ? "checked" : "" %>> 상업적 사용 허용</label>
            </div>
          </div>
          <div class="form-actions">
            <button type="submit" class="btn primary">저장</button>
            <a href="/AI/admin/models/index.jsp" class="btn ghost">취소</a>
          </div>
        </form>
      </section>
<%@ include file="/AI/admin/layout/footer.jspf" %>
