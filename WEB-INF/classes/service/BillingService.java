package service;

import dao.SubscriptionDAO;
import model.Subscription;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * 결제 및 구독 관련 비즈니스 로직
 */
public class BillingService {
  private SubscriptionDAO subscriptionDAO;
  
  public BillingService() {
    this.subscriptionDAO = new SubscriptionDAO();
  }
  
  /**
   * 장바구니 요약 (구독 커버 적용)
   * @param cartItems 장바구니 아이템 목록
   * @param userId 사용자 ID
   * @return 장바구니 요약
   */
  public CartSummary summarize(List<Map<String, Object>> cartItems, long userId) {
    Subscription subscription = subscriptionDAO.findActiveByUserId(userId);
    boolean hasActiveSubscription = subscription != null && subscription.isActiveNow();
    
    BigDecimal total = BigDecimal.ZERO;
    List<ItemSummary> items = new ArrayList<>();
    
    for (Map<String, Object> item : cartItems) {
      String type = (String) item.get("type");
      String name = (String) item.get("title");
      BigDecimal price = (BigDecimal) item.get("price");
      int quantity = (Integer) item.getOrDefault("quantity", 1);
      
      if (price == null) {
        price = BigDecimal.ZERO;
      }
      
      boolean covered = hasActiveSubscription;
      BigDecimal itemPrice = covered ? BigDecimal.ZERO : price.multiply(new BigDecimal(quantity));
      
      items.add(new ItemSummary(type, name, itemPrice, covered));
      total = total.add(itemPrice);
    }
    
    String coverLabel = hasActiveSubscription 
        ? "구독 적용 중 (" + subscription.getPlanCode() + ")" 
        : "구독 없음";
    
    return new CartSummary(items, total, coverLabel, hasActiveSubscription);
  }
  
  /**
   * 아이템 요약
   */
  public static class ItemSummary {
    private String type;
    private String name;
    private BigDecimal price;
    private boolean covered;
    
    public ItemSummary(String type, String name, BigDecimal price, boolean covered) {
      this.type = type;
      this.name = name;
      this.price = price;
      this.covered = covered;
    }
    
    public String getType() { return type; }
    public String getName() { return name; }
    public BigDecimal getPrice() { return price; }
    public boolean isCovered() { return covered; }
  }
  
  /**
   * 장바구니 요약
   */
  public static class CartSummary {
    private List<ItemSummary> items;
    private BigDecimal total;
    private String coverLabel;
    private boolean hasActiveSubscription;
    
    public CartSummary(List<ItemSummary> items, BigDecimal total, String coverLabel, boolean hasActiveSubscription) {
      this.items = items;
      this.total = total;
      this.coverLabel = coverLabel;
      this.hasActiveSubscription = hasActiveSubscription;
    }
    
    public List<ItemSummary> getItems() { return items; }
    public BigDecimal getTotal() { return total; }
    public String getCoverLabel() { return coverLabel; }
    public boolean hasActiveSubscription() { return hasActiveSubscription; }
  }
}



