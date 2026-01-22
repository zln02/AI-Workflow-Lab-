package dao;

import db.DBConnect;
import model.Order;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class OrderDAO {
  private static final String INSERT_ORDER_SQL =
      "INSERT INTO orders (customer_name, customer_email, customer_phone, payment_method, total_price, order_status) " +
      "VALUES (?, ?, ?, ?, ?, ?)";
  
  private static final String INSERT_ORDER_ITEM_SQL =
      "INSERT INTO order_items (order_id, item_type, item_id, quantity, price) " +
      "VALUES (?, ?, ?, ?, ?)";
  
  private static final String COUNT_RECENT_ORDERS_SQL =
      "SELECT COUNT(*) FROM orders WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)";
  
  private static final String FIND_ALL_ORDERS_SQL =
      "SELECT id, customer_name, customer_email, customer_phone, payment_method, total_price, order_status, created_at " +
      "FROM orders ORDER BY created_at DESC";
  
  private static final String FIND_RECENT_ORDERS_SQL =
      "SELECT id, customer_name, customer_email, customer_phone, payment_method, total_price, order_status, created_at " +
      "FROM orders ORDER BY created_at DESC LIMIT ?";
  
  private static final String FIND_BY_EMAIL_SQL =
      "SELECT id, customer_name, customer_email, customer_phone, payment_method, total_price, order_status, created_at " +
      "FROM orders WHERE customer_email = ? ORDER BY created_at DESC";
  
  private static final String FIND_BY_ID_SQL =
      "SELECT id, customer_name, customer_email, customer_phone, payment_method, total_price, order_status, created_at " +
      "FROM orders WHERE id = ?";
  
  private static final String FIND_ORDER_ITEMS_SQL =
      "SELECT id, order_id, item_type, item_id, quantity, price, created_at " +
      "FROM order_items WHERE order_id = ?";
  
  private static final String DELETE_ORDER_SQL =
      "DELETE FROM orders WHERE id = ?";

  public int insertOrder(Order order) {
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(INSERT_ORDER_SQL, PreparedStatement.RETURN_GENERATED_KEYS)) {
      ps.setString(1, order.getCustomerName());
      ps.setString(2, order.getCustomerEmail());
      ps.setString(3, order.getCustomerPhone());
      ps.setString(4, order.getPaymentMethod());
      ps.setBigDecimal(5, order.getTotalPrice());
      ps.setString(6, order.getOrderStatus());
      
      int result = ps.executeUpdate();
      if (result > 0) {
        try (ResultSet rs = ps.getGeneratedKeys()) {
          if (rs.next()) {
            return rs.getInt(1);
          }
        }
      }
    } catch (SQLException e) {
      throw new RuntimeException("주문 등록 중 오류가 발생했습니다.", e);
    }
    return -1;
  }

  public boolean insertOrderItem(int orderId, String itemType, int itemId, int quantity, BigDecimal price) {
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(INSERT_ORDER_ITEM_SQL)) {
      ps.setInt(1, orderId);
      ps.setString(2, itemType);
      ps.setInt(3, itemId);
      ps.setInt(4, quantity);
      ps.setBigDecimal(5, price);
      
      return ps.executeUpdate() > 0;
    } catch (SQLException e) {
      throw new RuntimeException("주문 아이템 등록 중 오류가 발생했습니다.", e);
    }
  }

  public int countRecentOrders() {
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(COUNT_RECENT_ORDERS_SQL);
         ResultSet rs = ps.executeQuery()) {
      if (rs.next()) {
        return rs.getInt(1);
      }
    } catch (SQLException e) {
      // 테이블이 없거나 오류 발생 시 0 반환
      return 0;
    }
    return 0;
  }

  public List<Order> findAll() {
    List<Order> orders = new ArrayList<>();
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(FIND_ALL_ORDERS_SQL);
         ResultSet rs = ps.executeQuery()) {
      while (rs.next()) {
        orders.add(mapToOrder(rs));
      }
    } catch (SQLException e) {
      throw new RuntimeException("주문 목록 조회 중 오류가 발생했습니다.", e);
    }
    return orders;
  }

  /**
   * 최근 주문 조회
   * @param limit 조회할 주문 수
   * @return 최근 주문 목록
   */
  public List<Order> findRecentOrders(int limit) {
    List<Order> orders = new ArrayList<>();
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(FIND_RECENT_ORDERS_SQL)) {
      ps.setInt(1, limit);
      try (ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
          orders.add(mapToOrder(rs));
        }
      }
    } catch (SQLException e) {
      throw new RuntimeException("최근 주문 조회 중 오류가 발생했습니다.", e);
    }
    return orders;
  }

  /**
   * 이메일로 주문 조회
   * @param email 고객 이메일
   * @return 주문 목록
   */
  public List<Order> findByEmail(String email) {
    List<Order> orders = new ArrayList<>();
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(FIND_BY_EMAIL_SQL)) {
      ps.setString(1, email);
      try (ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
          orders.add(mapToOrder(rs));
        }
      }
    } catch (SQLException e) {
      throw new RuntimeException("고객별 주문 조회 중 오류가 발생했습니다.", e);
    }
    return orders;
  }

  /**
   * ID로 주문 조회
   * @param id 주문 ID
   * @return 주문 또는 null
   */
  public Order findById(int id) {
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(FIND_BY_ID_SQL)) {
      ps.setInt(1, id);
      try (ResultSet rs = ps.executeQuery()) {
        if (rs.next()) {
          return mapToOrder(rs);
        }
      }
    } catch (SQLException e) {
      System.err.println("SQL Error in findById: " + e.getMessage());
      throw new RuntimeException("주문 조회 중 오류가 발생했습니다.", e);
    }
    return null;
  }

  /**
   * 주문 아이템 조회
   * @param orderId 주문 ID
   * @return 주문 아이템 목록 (Map 형태: itemType, itemId, quantity, price, itemName)
   */
  public List<java.util.Map<String, Object>> findOrderItems(int orderId) {
    List<java.util.Map<String, Object>> items = new ArrayList<>();
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(FIND_ORDER_ITEMS_SQL)) {
      ps.setInt(1, orderId);
      try (ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
          java.util.Map<String, Object> item = new java.util.HashMap<>();
          item.put("id", rs.getInt("id"));
          item.put("orderId", rs.getInt("order_id"));
          item.put("itemType", rs.getString("item_type"));
          item.put("itemId", rs.getInt("item_id"));
          item.put("quantity", rs.getInt("quantity"));
          item.put("price", rs.getBigDecimal("price"));
          items.add(item);
        }
      }
    } catch (SQLException e) {
      // 테이블이 없거나 오류 발생 시 빈 리스트 반환
      System.err.println("SQL Error in findOrderItems: " + e.getMessage());
      return new ArrayList<>();
    }
    return items;
  }

  private static final String GET_SALES_STATISTICS_SQL =
      "SELECT " +
      "  COUNT(*) as total_orders, " +
      "  COALESCE(SUM(total_price), 0) as total_revenue, " +
      "  COALESCE(AVG(total_price), 0) as avg_order_value " +
      "FROM orders " +
      "WHERE created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)";
  
  private static final String GET_TOP_SELLING_PACKAGES_SQL =
      "SELECT " +
      "  oi.item_id, " +
      "  p.title, " +
      "  SUM(oi.quantity) as total_quantity, " +
      "  COUNT(DISTINCT oi.order_id) as order_count, " +
      "  SUM(oi.price * oi.quantity) as total_revenue " +
      "FROM order_items oi " +
      "INNER JOIN orders o ON oi.order_id = o.id " +
      "INNER JOIN packages p ON oi.item_id = p.id " +
      "WHERE oi.item_type = 'PACKAGE' " +
      "  AND o.created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY) " +
      "GROUP BY oi.item_id, p.title " +
      "ORDER BY total_quantity DESC " +
      "LIMIT 10";
  
  private static final String GET_TOP_SELLING_MODELS_SQL =
      "SELECT " +
      "  oi.item_id, " +
      "  am.model_name, " +
      "  SUM(oi.quantity) as total_quantity, " +
      "  COUNT(DISTINCT oi.order_id) as order_count " +
      "FROM order_items oi " +
      "INNER JOIN orders o ON oi.order_id = o.id " +
      "INNER JOIN ai_models am ON oi.item_id = am.id " +
      "WHERE oi.item_type = 'MODEL' " +
      "  AND o.created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY) " +
      "GROUP BY oi.item_id, am.model_name " +
      "ORDER BY total_quantity DESC " +
      "LIMIT 10";

  public SalesStatistics getSalesStatistics() {
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(GET_SALES_STATISTICS_SQL);
         ResultSet rs = ps.executeQuery()) {
      if (rs.next()) {
        SalesStatistics stats = new SalesStatistics();
        stats.setTotalOrders(rs.getInt("total_orders"));
        stats.setTotalRevenue(rs.getBigDecimal("total_revenue"));
        stats.setAvgOrderValue(rs.getBigDecimal("avg_order_value"));
        return stats;
      }
    } catch (SQLException e) {
      // 테이블이 없거나 오류 발생 시 빈 통계 반환
      return new SalesStatistics();
    }
    return new SalesStatistics();
  }

  public List<TopSellingItem> getTopSellingPackages() {
    List<TopSellingItem> items = new ArrayList<>();
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(GET_TOP_SELLING_PACKAGES_SQL);
         ResultSet rs = ps.executeQuery()) {
      while (rs.next()) {
        TopSellingItem item = new TopSellingItem();
        item.setItemId(rs.getInt("item_id"));
        item.setItemName(rs.getString("title"));
        item.setTotalQuantity(rs.getInt("total_quantity"));
        item.setOrderCount(rs.getInt("order_count"));
        item.setTotalRevenue(rs.getBigDecimal("total_revenue"));
        items.add(item);
      }
    } catch (SQLException e) {
      // 테이블이 없거나 오류 발생 시 빈 리스트 반환
      return new ArrayList<>();
    }
    return items;
  }

  public List<TopSellingItem> getTopSellingModels() {
    List<TopSellingItem> items = new ArrayList<>();
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(GET_TOP_SELLING_MODELS_SQL);
         ResultSet rs = ps.executeQuery()) {
      while (rs.next()) {
        TopSellingItem item = new TopSellingItem();
        item.setItemId(rs.getInt("item_id"));
        item.setItemName(rs.getString("model_name"));
        item.setTotalQuantity(rs.getInt("total_quantity"));
        item.setOrderCount(rs.getInt("order_count"));
        items.add(item);
      }
    } catch (SQLException e) {
      // 테이블이 없거나 오류 발생 시 빈 리스트 반환
      return new ArrayList<>();
    }
    return items;
  }

  /**
   * 주문 삭제 (order_items는 CASCADE로 자동 삭제됨)
   * @param id 주문 ID
   * @return 삭제 성공 여부
   */
  public boolean delete(int id) {
    try (Connection conn = DBConnect.getConnection();
         PreparedStatement ps = conn.prepareStatement(DELETE_ORDER_SQL)) {
      ps.setInt(1, id);
      int result = ps.executeUpdate();
      return result > 0;
    } catch (SQLException e) {
      System.err.println("SQL Error in delete order " + id + ": " + e.getMessage());
      System.err.println("SQL State: " + e.getSQLState());
      System.err.println("Error Code: " + e.getErrorCode());
      e.printStackTrace();
      // SQL 오류를 RuntimeException으로 변환하되, 원본 예외를 포함
      throw new RuntimeException("주문 삭제 중 오류가 발생했습니다: " + e.getMessage(), e);
    }
  }

  private Order mapToOrder(ResultSet rs) throws SQLException {
    Order order = new Order();
    order.setId(rs.getInt("id"));
    order.setCustomerName(rs.getString("customer_name"));
    order.setCustomerEmail(rs.getString("customer_email"));
    order.setCustomerPhone(rs.getString("customer_phone"));
    order.setPaymentMethod(rs.getString("payment_method"));
    order.setTotalPrice(rs.getBigDecimal("total_price"));
    order.setOrderStatus(rs.getString("order_status"));
    order.setCreatedAt(rs.getString("created_at"));
    return order;
  }

  // 내부 클래스: 판매 통계
  public static class SalesStatistics {
    private int totalOrders;
    private BigDecimal totalRevenue;
    private BigDecimal avgOrderValue;

    public int getTotalOrders() { return totalOrders; }
    public void setTotalOrders(int totalOrders) { this.totalOrders = totalOrders; }
    public BigDecimal getTotalRevenue() { return totalRevenue; }
    public void setTotalRevenue(BigDecimal totalRevenue) { this.totalRevenue = totalRevenue; }
    public BigDecimal getAvgOrderValue() { return avgOrderValue; }
    public void setAvgOrderValue(BigDecimal avgOrderValue) { this.avgOrderValue = avgOrderValue; }
  }

  // 내부 클래스: 인기 상품
  public static class TopSellingItem {
    private int itemId;
    private String itemName;
    private int totalQuantity;
    private int orderCount;
    private BigDecimal totalRevenue;

    public int getItemId() { return itemId; }
    public void setItemId(int itemId) { this.itemId = itemId; }
    public String getItemName() { return itemName; }
    public void setItemName(String itemName) { this.itemName = itemName; }
    public int getTotalQuantity() { return totalQuantity; }
    public void setTotalQuantity(int totalQuantity) { this.totalQuantity = totalQuantity; }
    public int getOrderCount() { return orderCount; }
    public void setOrderCount(int orderCount) { this.orderCount = orderCount; }
    public BigDecimal getTotalRevenue() { return totalRevenue; }
    public void setTotalRevenue(BigDecimal totalRevenue) { this.totalRevenue = totalRevenue; }
  }
}

