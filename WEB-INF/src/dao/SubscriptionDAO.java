package dao;

import db.DBConnect;
import model.Subscription;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class SubscriptionDAO {
    public long insert(Subscription subscription) throws SQLException {
        String sql = "INSERT INTO subscriptions (" +
                "user_id, plan_id, plan_code, start_date, end_date, status, payment_method, transaction_id, " +
                "billing_cycle, next_billing_date, cancel_at_period_end, portone_customer_uid, last_payment_id" +
                ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setLong(1, subscription.getUserId());
            if (subscription.getPlanId() != null) {
                ps.setInt(2, subscription.getPlanId());
            } else {
                ps.setNull(2, java.sql.Types.INTEGER);
            }
            ps.setString(3, subscription.getPlanCode());
            ps.setDate(4, subscription.getStartDate() != null ? Date.valueOf(subscription.getStartDate()) : null);
            ps.setDate(5, subscription.getEndDate() != null ? Date.valueOf(subscription.getEndDate()) : null);
            ps.setString(6, subscription.getStatus());
            ps.setString(7, subscription.getPaymentMethod());
            ps.setString(8, subscription.getTransactionId());
            ps.setString(9, subscription.getBillingCycle());
            ps.setDate(10, subscription.getNextBillingDate() != null ? Date.valueOf(subscription.getNextBillingDate()) : null);
            ps.setBoolean(11, subscription.isCancelAtPeriodEnd());
            ps.setString(12, subscription.getPortoneCustomerUid());
            if (subscription.getLastPaymentId() != null) {
                ps.setInt(13, subscription.getLastPaymentId());
            } else {
                ps.setNull(13, java.sql.Types.INTEGER);
            }
            ps.executeUpdate();

            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    subscription.setId(keys.getLong(1));
                }
            }
        }

        return subscription.getId();
    }

    public Subscription findActiveByUserId(long userId) throws SQLException {
        String sql = "SELECT * FROM subscriptions WHERE user_id = ? AND status = 'ACTIVE' ORDER BY start_date DESC, id DESC LIMIT 1";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return map(rs);
                }
            }
        }
        return null;
    }

    public List<Subscription> findAllByUserId(long userId) throws SQLException {
        List<Subscription> items = new ArrayList<>();
        String sql = "SELECT * FROM subscriptions WHERE user_id = ? ORDER BY start_date DESC, id DESC";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    items.add(map(rs));
                }
            }
        }
        return items;
    }

    public boolean cancelActiveByUserId(long userId) throws SQLException {
        String sql = "UPDATE subscriptions SET status = 'CANCELED', cancel_at_period_end = 1 WHERE user_id = ? AND status = 'ACTIVE'";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean changePlan(long userId, int planId, String planCode, String billingCycle) throws SQLException {
        String sql = "UPDATE subscriptions SET plan_id = ?, plan_code = ?, billing_cycle = ?, next_billing_date = ?, updated_at = NOW() " +
                "WHERE user_id = ? AND status = 'ACTIVE'";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, planId);
            ps.setString(2, planCode);
            ps.setString(3, billingCycle);
            ps.setDate(4, Date.valueOf(java.time.LocalDate.now().plusMonths("yearly".equalsIgnoreCase(billingCycle) ? 12 : 1)));
            ps.setLong(5, userId);
            return ps.executeUpdate() > 0;
        }
    }

    private Subscription map(ResultSet rs) throws SQLException {
        Subscription subscription = new Subscription();
        subscription.setId(rs.getLong("id"));
        subscription.setUserId(rs.getLong("user_id"));
        try {
            subscription.setPlanId(rs.getObject("plan_id", Integer.class));
        } catch (SQLException ignored) {
            subscription.setPlanId(null);
        }
        subscription.setPlanCode(readString(rs, "plan_code"));
        Date startDate = rs.getDate("start_date");
        if (startDate != null) {
            subscription.setStartDate(startDate.toLocalDate());
        }
        Date endDate = rs.getDate("end_date");
        if (endDate != null) {
            subscription.setEndDate(endDate.toLocalDate());
        }
        subscription.setStatus(readString(rs, "status"));
        subscription.setPaymentMethod(readString(rs, "payment_method"));
        subscription.setTransactionId(readString(rs, "transaction_id"));
        subscription.setBillingCycle(readString(rs, "billing_cycle"));
        try {
            Date nextBillingDate = rs.getDate("next_billing_date");
            if (nextBillingDate != null) {
                subscription.setNextBillingDate(nextBillingDate.toLocalDate());
            }
        } catch (SQLException ignored) {}
        try {
            subscription.setCancelAtPeriodEnd(rs.getBoolean("cancel_at_period_end"));
            subscription.setPortoneCustomerUid(readString(rs, "portone_customer_uid"));
            subscription.setLastPaymentId(rs.getObject("last_payment_id", Integer.class));
        } catch (SQLException ignored) {}
        return subscription;
    }

    private String readString(ResultSet rs, String column) {
        try {
            return rs.getString(column);
        } catch (SQLException ignored) {
            return null;
        }
    }
}
