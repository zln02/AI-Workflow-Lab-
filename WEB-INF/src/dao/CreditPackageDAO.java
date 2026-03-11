package dao;

import db.DBConnect;
import model.CreditPackage;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class CreditPackageDAO {
    public List<CreditPackage> findAllActive() throws SQLException {
        List<CreditPackage> items = new ArrayList<>();
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT * FROM credit_packages WHERE is_active = 1 ORDER BY display_order ASC, id ASC");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                items.add(map(rs));
            }
        } catch (SQLException e) {
            return fallback();
        }
        return items.isEmpty() ? fallback() : items;
    }

    public CreditPackage findById(int id) throws SQLException {
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT * FROM credit_packages WHERE id = ? AND is_active = 1")) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return map(rs);
                }
            }
        } catch (SQLException e) {
            for (CreditPackage item : fallback()) {
                if (item.getId() == id) {
                    return item;
                }
            }
            throw e;
        }
        return null;
    }

    private CreditPackage map(ResultSet rs) throws SQLException {
        CreditPackage item = new CreditPackage();
        item.setId(rs.getInt("id"));
        item.setPackageName(rs.getString("package_name"));
        item.setCredits(rs.getInt("credits"));
        item.setPrice(rs.getBigDecimal("price"));
        item.setBonusCredits(rs.getInt("bonus_credits"));
        item.setActive(rs.getBoolean("is_active"));
        item.setDisplayOrder(rs.getInt("display_order"));
        return item;
    }

    private List<CreditPackage> fallback() {
        return Arrays.asList(
                build(1, "소량", 100, "3900", 0, 1),
                build(2, "기본", 500, "14900", 50, 2),
                build(3, "대량", 2000, "49900", 400, 3),
                build(4, "벌크", 10000, "199000", 3000, 4)
        );
    }

    private CreditPackage build(int id, String name, int credits, String price, int bonus, int order) {
        CreditPackage item = new CreditPackage();
        item.setId(id);
        item.setPackageName(name);
        item.setCredits(credits);
        item.setPrice(new BigDecimal(price));
        item.setBonusCredits(bonus);
        item.setActive(true);
        item.setDisplayOrder(order);
        return item;
    }
}
