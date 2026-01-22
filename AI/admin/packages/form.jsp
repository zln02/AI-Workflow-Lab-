<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.PackageDAO" %>
<%@ page import="dao.PackageItemDAO" %>
<%@ page import="dao.AIModelDAO" %>
<%@ page import="dao.CategoryDAO" %>
<%@ page import="model.Package" %>
<%@ page import="model.PackageItem" %>
<%@ page import="model.AIModel" %>
<%@ page import="model.Category" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.HashSet" %>
<%
  if (session.getAttribute("admin") == null) {
    response.sendRedirect("/AI/admin/auth/login.jsp");
    return;
  }
  PackageDAO packageDAO = new PackageDAO();
  AIModelDAO modelDAO = new AIModelDAO();
  CategoryDAO categoryDAO = new CategoryDAO();
  Package pkg = null;
  List<PackageItem> items = null;
  String idParam = request.getParameter("id");
  if (idParam != null && !idParam.trim().isEmpty()) {
    try {
      int id = Integer.parseInt(idParam);
      pkg = packageDAO.findById(id);
      if (pkg != null) {
        items = pkg.getItems();
      }
    } catch (NumberFormatException e) {}
  }
  List<AIModel> allModels = modelDAO.findAll();
  List<Category> categories = categoryDAO.findAll();
%>
<%@ include file="/AI/admin/layout/header.jspf" %>
<div class="admin-layout">
  <%@ include file="/AI/admin/layout/sidebar.jspf" %>
  <div class="admin-main-wrapper">
    <%@ include file="/AI/admin/layout/topbar.jspf" %>
    <main class="admin-content">
      <header class="admin-dashboard-header">
        <h1><%= pkg != null ? "패키지 수정" : "새 패키지 생성" %></h1>
        <a class="btn ghost" href="/AI/admin/packages/index.jsp">목록으로</a>
      </header>
      <section class="admin-form-section">
        <form method="POST" action="/AI/admin/packages/save.jsp" id="packageForm">
          <% if (pkg != null) { %><input type="hidden" name="id" value="<%= pkg.getId() %>"><% } %>
          
          <!-- Basic Info Section -->
          <div class="section-card">
            <div class="section-title">기본 정보</div>
            <div class="form-group">
              <label for="title">패키지명 *</label>
              <input type="text" id="title" name="title" required value="<%= pkg != null && pkg.getTitle() != null ? pkg.getTitle() : "" %>">
            </div>
            <div class="form-group">
              <label for="description">설명</label>
              <textarea id="description" name="description" rows="4"><%= pkg != null && pkg.getDescription() != null ? pkg.getDescription() : "" %></textarea>
            </div>
            <div class="form-group">
              <label><input type="checkbox" name="active" value="true" <%= pkg == null || pkg.isActive() ? "checked" : "" %>> 활성화</label>
            </div>
            <div class="form-group">
              <label>카테고리 (다중 선택 가능) *</label>
              <div class="category-checkboxes">
                <% 
                  // 기존 선택된 카테고리 ID 목록 가져오기 (package_categories 테이블에서)
                  java.util.Set<Integer> selectedCategoryIds = new java.util.HashSet<>();
                  if (pkg != null && pkg.getCategories() != null) {
                    for (Category cat : pkg.getCategories()) {
                      selectedCategoryIds.add(cat.getId());
                    }
                  }
                %>
                <% for (Category cat : categories) { %>
                  <label class="checkbox-label">
                    <input type="checkbox" name="category_ids[]" value="<%= cat.getId() %>" 
                      <%= selectedCategoryIds.contains(cat.getId()) ? "checked" : "" %>>
                    <span><%= cat.getCategoryName() %></span>
                  </label>
                <% } %>
              </div>
              <small class="helper-text">패키지에 적용할 카테고리를 하나 이상 선택하세요.</small>
            </div>
          </div>

          <!-- Price Section -->
          <div class="section-card">
            <div class="section-title">가격</div>
            <div class="form-row">
              <div class="form-group">
                <label for="price_usd">USD 가격 *</label>
                <input type="number" id="price_usd" name="price_usd" step="0.01" min="0" required 
                  value="<%= pkg != null && pkg.getPrice() != null ? pkg.getPrice() : "" %>" 
                  placeholder="0.00">
                <small class="helper-text">USD 기준 가격을 입력하세요 (숫자만)</small>
              </div>
              <div class="form-group">
                <label for="price_krw">KRW 가격 (자동 계산)</label>
                <input type="text" id="price_krw" readonly value="" placeholder="0원">
                <small class="helper-text">USD × 1350으로 자동 계산됩니다</small>
              </div>
            </div>
            <input type="hidden" id="price" name="price" value="<%= pkg != null && pkg.getPrice() != null ? pkg.getPrice() : "" %>">
          </div>

          <!-- Package Items Section (Accordion) -->
          <div class="section-card">
            <div class="accordion-header" id="packageItemsAccordion" onclick="toggleAccordion('packageItemsContent')">
              <div class="section-title" style="margin-bottom: 0;">패키지 구성 아이템</div>
              <span class="accordion-icon" id="packageItemsIcon">▼</span>
            </div>
            <div class="accordion-content" id="packageItemsContent" style="display: none;">
              <div class="model-search-container">
                <input type="text" id="modelSearchInput" class="model-search-input" placeholder="모델 검색..." autocomplete="off">
                <span class="search-icon">🔍</span>
              </div>
              <div class="package-items-header">
                <button type="button" class="btn btn-sm" onclick="addItem()">아이템 추가</button>
              </div>
              <div id="packageItems">
                <% if (items != null && !items.isEmpty()) { %>
                  <% for (PackageItem item : items) { %>
                    <div class="item-row package-item-row">
                      <select name="item_model_id[]" class="model-select" required>
                        <option value="">모델 선택</option>
                        <% for (AIModel model : allModels) { %>
                          <option value="<%= model.getId() %>" data-model-name="<%= model.getModelName() != null ? model.getModelName() : "" %>" <%= item.getModelId() == model.getId() ? "selected" : "" %>><%= model.getModelName() %></option>
                        <% } %>
                      </select>
                      <input type="number" name="item_quantity[]" class="model-qty" value="<%= item.getQuantity() %>" min="1" required placeholder="수량">
                      <button type="button" class="btn btn-sm btn-danger remove-btn" onclick="removeItem(this)">삭제</button>
                    </div>
                  <% } %>
                <% } else { %>
                  <div class="item-row package-item-row">
                    <select name="item_model_id[]" class="model-select" required>
                      <option value="">모델 선택</option>
                      <% for (AIModel model : allModels) { %>
                        <option value="<%= model.getId() %>" data-model-name="<%= model.getModelName() != null ? model.getModelName() : "" %>"><%= model.getModelName() %></option>
                      <% } %>
                    </select>
                    <input type="number" name="item_quantity[]" class="model-qty" value="1" min="1" required placeholder="수량">
                    <button type="button" class="btn btn-sm btn-danger remove-btn" onclick="removeItem(this)">삭제</button>
                  </div>
                <% } %>
              </div>
            </div>
          </div>

          <!-- Discount Section -->
          <div class="section-card">
            <div class="section-title">할인</div>
            <div class="form-group">
              <label for="discount">할인율 (%)</label>
              <input type="number" id="discount" min="0" max="100" step="1" value="0" placeholder="0~100">
              <small class="helper-text">할인율 입력 시 자동 계산됩니다</small>
            </div>
            <div class="form-row">
              <div class="form-group">
                <label for="discount_price_usd">USD 할인가 (자동 계산)</label>
                <input type="text" id="discount_price_usd" readonly value="" placeholder="0.00">
                <small class="helper-text">할인율 입력 시 자동 계산됩니다</small>
              </div>
              <div class="form-group">
                <label for="discount_price_krw">KRW 할인가 (자동 계산)</label>
                <input type="text" id="discount_price_krw" readonly value="" placeholder="0원">
                <small class="helper-text">USD 할인가 × 1350으로 자동 계산됩니다</small>
              </div>
            </div>
            <input type="hidden" id="discount_price" name="discount_price" value="<%= pkg != null && pkg.getDiscountPrice() != null ? pkg.getDiscountPrice() : "" %>">
          </div>

          <div class="form-actions">
            <button type="submit" class="btn primary">저장</button>
            <a href="/AI/admin/packages/index.jsp" class="btn ghost">취소</a>
          </div>
        </form>
      </section>
      <%
        // 모델 목록을 JSON 문자열로 생성
        StringBuilder modelsJson = new StringBuilder("[");
        if (allModels != null && !allModels.isEmpty()) {
          for (int i = 0; i < allModels.size(); i++) {
            AIModel model = allModels.get(i);
            String modelName = model.getModelName() != null ? model.getModelName() : "";
            // JavaScript 문자열 이스케이프: ", \, \n, \r, \t 처리
            modelName = modelName.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t");
            if (i > 0) modelsJson.append(",");
            modelsJson.append("{ id: ").append(model.getId()).append(", name: \"").append(modelName).append("\" }");
          }
        }
        modelsJson.append("]");
      %>
      <script>
      // 모델 목록 (서버에서 생성)
      const allModelsData = <%= modelsJson.toString() %>;

      // 모델 가격 테이블 (USD)
      const modelPrices = {
        "ChatGPT": 20,
        "Claude": 20,
        "Llama": 0,
        "GPT-4.1": 20,
        "Claude 3 Haiku": 10,
        "Gemini Pro": 15,
        "GitHub Copilot": 10,
        "Code Llama": 0,
        "Claude 3 Opus": 30,
        "Gemini Flash": 12,
        "DALL·E 3": 15,
        "Adobe Firefly": 15,
        "Midjourney": 20,
        "Runway Gen-2": 20,
        "Stable Video Diffusion": 0,
        "Runway Vision": 20,
        "Sora": 30,
        "Whisper": 8,
        "Google Speech": 8,
        "Deepgram": 8,
        "ElevenLabs": 12,
        "Google TTS": 8,
        "Azure Neural TTS": 10,
        "Gemini Vision": 18,
        "GPT-4.1 Vision": 18,
        "Perplexity AI": 20,
        "You.com AI": 15,
        "Cohere Embed": 5,
        "bge-large": 0,
        "text-embedding-3-large": 5,
        "GPT-4.1 Agents": 25,
        "Gemini Agents": 25,
        "AutoGPT": 0
      };

      // 환율 (기본값 1350원, 나중에 API로 업데이트 가능)
      let exchangeRate = 1350;

      // USD를 KRW로 환산
      function toKRW(usd) {
        return Math.round(usd * exchangeRate);
      }

      // 환율 업데이트 함수 (나중에 API로 호출 가능)
      function updateExchangeRate(rate) {
        exchangeRate = rate;
        calculatePackagePrice();
      }

      function formatUsd(value) {
        const rounded = Math.round(value * 100) / 100;
        const formatted = rounded % 1 === 0 ? rounded.toFixed(0) : rounded;
        return '$' + formatted + '/month';
      }

      function parseUsdValue(value) {
        if (!value) return NaN;
        const numeric = value.toString().replace(/[^0-9.]/g, '');
        return numeric ? parseFloat(numeric) : NaN;
      }

      function setPriceFields(usdAmount) {
        const priceUsdInput = document.getElementById('price_usd');
        const priceHiddenInput = document.getElementById('price');
        const priceKRWInput = document.getElementById('price_krw');
        
        if (priceUsdInput) {
          priceUsdInput.value = usdAmount > 0 ? usdAmount.toFixed(2) : '';
        }
        if (priceHiddenInput) {
          priceHiddenInput.value = usdAmount > 0 ? usdAmount.toFixed(2) : '';
        }
        if (priceKRWInput) {
          if (usdAmount > 0) {
            const krw = toKRW(usdAmount);
            priceKRWInput.value = krw.toLocaleString() + '원';
          } else {
            priceKRWInput.value = '';
          }
        }
      }

      function handleManualPriceInput() {
        const priceUsdInput = document.getElementById('price_usd');
        const priceHiddenInput = document.getElementById('price');
        const priceKRWInput = document.getElementById('price_krw');
        if (!priceUsdInput || !priceKRWInput) return;
        
        const usdValue = parseFloat(priceUsdInput.value) || 0;
        if (priceHiddenInput) {
          priceHiddenInput.value = usdValue > 0 ? usdValue.toFixed(2) : '';
        }
        if (usdValue > 0) {
          priceKRWInput.value = toKRW(usdValue).toLocaleString() + '원';
        } else {
          priceKRWInput.value = '';
        }
        updateDiscount();
      }

      function formatManualPriceOnBlur() {
        const priceInput = document.getElementById('price');
        if (!priceInput) return;
        const usdValue = parseUsdValue(priceInput.value);
        if (!isNaN(usdValue) && usdValue > 0) {
          priceInput.value = formatUsd(usdValue);
        }
      }

      // 패키지 가격 계산
      function calculatePackagePrice() {
        const rows = document.querySelectorAll('.package-item-row');
        let totalUSD = 0;

        rows.forEach(row => {
          const select = row.querySelector('.model-select');
          const qtyInput = row.querySelector('.model-qty');
          
          if (select && qtyInput) {
            const selectedOption = select.options[select.selectedIndex];
            const modelName = selectedOption ? selectedOption.getAttribute('data-model-name') : null;
            const quantity = parseInt(qtyInput.value) || 0;

            if (modelName && modelPrices[modelName] !== undefined) {
              const modelPrice = modelPrices[modelName];
              totalUSD += modelPrice * quantity;
            }
          }
        });

        setPriceFields(totalUSD);

        // 할인가 재계산
        updateDiscount();
      }

      // 할인가 계산
      function updateDiscount() {
        const discountInput = document.getElementById('discount');
        const discountPriceUsdInput = document.getElementById('discount_price_usd');
        const discountPriceHiddenInput = document.getElementById('discount_price');
        const discountPriceKRWInput = document.getElementById('discount_price_krw');
        const priceUsdInput = document.getElementById('price_usd');

        if (!discountInput || !discountPriceUsdInput || !priceUsdInput) return;

        const discountPercent = parseFloat(discountInput.value) || 0;
        const basePrice = parseFloat(priceUsdInput.value) || 0;

        if (discountPercent > 0 && basePrice > 0) {
          const discountedPrice = basePrice * (1 - discountPercent / 100);
          const roundedPrice = Math.round(discountedPrice * 100) / 100;
          
          discountPriceUsdInput.value = roundedPrice.toFixed(2);
          if (discountPriceHiddenInput) {
            discountPriceHiddenInput.value = roundedPrice.toFixed(2);
          }
          
          if (discountPriceKRWInput) {
            const krw = toKRW(roundedPrice);
            discountPriceKRWInput.value = krw.toLocaleString() + '원';
          }
        } else {
          discountPriceUsdInput.value = '';
          if (discountPriceHiddenInput) {
            discountPriceHiddenInput.value = '';
          }
          if (discountPriceKRWInput) {
            discountPriceKRWInput.value = '';
          }
        }
      }

      // 아코디언 토글
      function toggleAccordion(contentId) {
        const content = document.getElementById(contentId);
        const icon = document.getElementById(contentId.replace('Content', 'Icon'));
        if (content.style.display === 'none') {
          content.style.display = 'block';
          if (icon) icon.textContent = '▲';
        } else {
          content.style.display = 'none';
          if (icon) icon.textContent = '▼';
        }
      }

      // 아이템 추가
      function addItem() {
        const container = document.getElementById('packageItems');
        const row = document.createElement('div');
        row.className = 'item-row package-item-row';
        
        // 모델 선택 옵션 생성
        let optionsHtml = '<option value="">모델 선택</option>';
        allModelsData.forEach(function(model) {
          const modelName = model.name || '';
          // HTML 속성 이스케이프: &, ", <, > 처리
          const escapedName = modelName.replace(/&/g, '&amp;').replace(/"/g, '&quot;').replace(/'/g, '&#39;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
          // HTML 텍스트 이스케이프
          const escapedText = modelName.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
          optionsHtml += '<option value="' + model.id + '" data-model-name="' + escapedName + '">' + escapedText + '</option>';
        });
        
        row.innerHTML = 
          '<select name="item_model_id[]" class="model-select" required>' + optionsHtml + '</select>' +
          '<input type="number" name="item_quantity[]" class="model-qty" value="1" min="1" required placeholder="수량">' +
          '<button type="button" class="btn btn-sm btn-danger remove-btn" onclick="removeItem(this)">삭제</button>';
        
        container.appendChild(row);
        
        // 이벤트 리스너 추가
        const select = row.querySelector('.model-select');
        const qtyInput = row.querySelector('.model-qty');
        if (select) select.addEventListener('change', calculatePackagePrice);
        if (qtyInput) qtyInput.addEventListener('input', calculatePackagePrice);
        
        // 현재 검색어가 있으면 필터 적용
        const searchInput = document.getElementById('modelSearchInput');
        if (searchInput && searchInput.value) {
          filterModelOptions(searchInput.value);
        }
        
        // 초기 계산
        calculatePackagePrice();
      }

      // 아이템 삭제
      function removeItem(btn) {
        btn.closest('.package-item-row').remove();
        calculatePackagePrice();
      }

      // 모델 검색 기능
      function filterModelOptions(searchTerm) {
        const searchLower = searchTerm.toLowerCase().trim();
        const selects = document.querySelectorAll('.model-select');
        
        selects.forEach(select => {
          const options = select.querySelectorAll('option');
          let hasVisibleOptions = false;
          
          options.forEach(option => {
            if (option.value === '') {
              // "모델 선택" 옵션은 항상 표시
              option.style.display = '';
              hasVisibleOptions = true;
            } else {
              const modelName = option.textContent.toLowerCase();
              if (searchLower === '' || modelName.includes(searchLower)) {
                option.style.display = '';
                hasVisibleOptions = true;
              } else {
                option.style.display = 'none';
              }
            }
          });
          
          // 검색 결과가 없으면 선택된 값 유지
          if (!hasVisibleOptions && select.value) {
            const selectedOption = select.querySelector('option[value="' + select.value + '"]');
            if (selectedOption) {
              selectedOption.style.display = '';
            }
          }
        });
      }

      // 페이지 로드 시 이벤트 리스너 설정
      document.addEventListener('DOMContentLoaded', function() {
        // 기존 아이템에 이벤트 리스너 추가
        document.querySelectorAll('.model-select').forEach(select => {
          select.addEventListener('change', calculatePackagePrice);
        });
        
        document.querySelectorAll('.model-qty').forEach(input => {
          input.addEventListener('input', calculatePackagePrice);
        });

        // USD 가격 입력 이벤트
        const priceUsdInput = document.getElementById('price_usd');
        if (priceUsdInput) {
          priceUsdInput.addEventListener('input', handleManualPriceInput);
          // 기존 가격이 있으면 KRW 계산
          if (priceUsdInput.value) {
            handleManualPriceInput();
          }
        }

        // 할인율 입력 이벤트
        const discountInput = document.getElementById('discount');
        if (discountInput) {
          discountInput.addEventListener('input', updateDiscount);
          
          // 기존 할인가가 있으면 할인율 역산
          const discountPriceHiddenInput = document.getElementById('discount_price');
          const priceUsdInput = document.getElementById('price_usd');
          if (discountPriceHiddenInput && discountPriceHiddenInput.value && priceUsdInput && priceUsdInput.value) {
            const basePrice = parseFloat(priceUsdInput.value) || 0;
            const discountPrice = parseFloat(discountPriceHiddenInput.value) || 0;
            if (basePrice > 0 && discountPrice > 0) {
              const calculatedDiscount = ((basePrice - discountPrice) / basePrice) * 100;
              discountInput.value = Math.round(calculatedDiscount);
              updateDiscount();
            }
          }
        }

        // 모델 검색 이벤트
        const modelSearchInput = document.getElementById('modelSearchInput');
        if (modelSearchInput) {
          modelSearchInput.addEventListener('input', function(e) {
            filterModelOptions(e.target.value);
          });
          
          // 검색창 포커스 시 아코디언 자동 열기
          modelSearchInput.addEventListener('focus', function() {
            const content = document.getElementById('packageItemsContent');
            if (content && content.style.display === 'none') {
              toggleAccordion('packageItemsContent');
            }
          });
        }

        // 초기 계산
        calculatePackagePrice();
      });

      // 전역에서 접근 가능하도록 window에 함수 바인딩
      window.addItem = addItem;
      window.removeItem = removeItem;
      window.toggleAccordion = toggleAccordion;
      </script>
<%@ include file="/AI/admin/layout/footer.jspf" %>
