package dao;

import db.DBConnect;
import model.Order;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class OrderDAO {
    public int insertOrder(Order order) throws SQLException {
        String sql = "INSERT INTO orders (customer_name, customer_email, customer_phone, payment_method, total_price, order_status) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, order.getCustomerName());
            ps.setString(2, order.getCustomerEmail());
            ps.setString(3, order.getCustomerPhone());
            ps.setString(4, order.getPaymentMethod());
            ps.setBigDecimal(5, order.getTotalPrice());
            ps.setString(6, order.getOrderStatus());
            ps.executeUpdate();

            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getInt(1);
                }
            }
        }
        return 0;
    }

    public boolean insertOrderItem(int orderId, String itemType, int itemId, int quantity, BigDecimal price) throws SQLException {
        String sql = "INSERT INTO order_items (order_id, item_type, item_id, quantity, price) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setString(2, itemType);
            ps.setInt(3, itemId);
            ps.setInt(4, quantity);
            ps.setBigDecimal(5, price);
            return ps.executeUpdate() > 0;
        }
    }

    public Order findById(int id) throws SQLException {
        String sql = "SELECT * FROM orders WHERE id = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return map(rs);
                }
            }
        }
        return null;
    }

    public List<Order> findAll() throws SQLException {
        List<Order> items = new ArrayList<>();
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT * FROM orders ORDER BY created_at DESC, id DESC");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                items.add(map(rs));
            }
        }
        return items;
    }

    public List<Order> findByEmail(String email) throws SQLException {
        List<Order> items = new ArrayList<>();
        String sql = "SELECT * FROM orders WHERE customer_email = ? ORDER BY created_at DESC, id DESC";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    items.add(map(rs));
                }
            }
        }
        return items;
    }

    public List<Map<String, Object>> findOrderItems(int orderId) throws SQLException {
        List<Map<String, Object>> items = new ArrayList<>();
        String sql = "SELECT * FROM order_items WHERE order_id = ? ORDER BY id ASC";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> item = new HashMap<>();
                    item.put("itemType", rs.getString("item_type"));
                    item.put("itemId", rs.getInt("item_id"));
                    item.put("quantity", rs.getInt("quantity"));
                    item.put("price", rs.getBigDecimal("price"));
                    items.add(item);
                }
            }
        } catch (SQLException e) {
            return items;
        }
        return items;
    }

    public boolean delete(int orderId) throws SQLException {
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement("DELETE FROM orders WHERE id = ?")) {
            ps.setInt(1, orderId);
            return ps.executeUpdate() > 0;
        }
    }

    public SalesStatistics getSalesStatistics() throws SQLException {
        String sql = "SELECT COUNT(*) AS total_orders, COALESCE(SUM(total_price), 0) AS total_revenue, COALESCE(AVG(total_price), 0) AS avg_order_value " +
                "FROM orders WHERE created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                SalesStatistics stats = new SalesStatistics();
                stats.setTotalOrders(rs.getInt("total_orders"));
                stats.setTotalRevenue(rs.getBigDecimal("total_revenue"));
                stats.setAvgOrderValue(rs.getBigDecimal("avg_order_value"));
                return stats;
            }
        }
        return new SalesStatistics();
    }

    private Order map(ResultSet rs) throws SQLException {
        Order order = new Order();
        order.setId(rs.getInt("id"));
        order.setCustomerName(rs.getString("customer_name"));
        order.setCustomerEmail(rs.getString("customer_email"));
        order.setCustomerPhone(rs.getString("customer_phone"));
        order.setPaymentMethod(rs.getString("payment_method"));
        order.setTotalPrice(rs.getBigDecimal("total_price"));
        order.setOrderStatus(rs.getString("order_status"));
        order.setCreatedAt(rs.getTimestamp("created_at") != null ? rs.getTimestamp("created_at").toString() : null);
        return order;
    }

    public static class SalesStatistics {
        private int totalOrders;
        private BigDecimal totalRevenue = BigDecimal.ZERO;
        private BigDecimal avgOrderValue = BigDecimal.ZERO;

        public int getTotalOrders() {
            return totalOrders;
        }

        public void setTotalOrders(int totalOrders) {
            this.totalOrders = totalOrders;
        }

        public BigDecimal getTotalRevenue() {
            return totalRevenue;
        }

        public void setTotalRevenue(BigDecimal totalRevenue) {
            this.totalRevenue = totalRevenue;
        }

        public BigDecimal getAvgOrderValue() {
            return avgOrderValue;
        }

        public void setAvgOrderValue(BigDecimal avgOrderValue) {
            this.avgOrderValue = avgOrderValue;
        }
    }
}
