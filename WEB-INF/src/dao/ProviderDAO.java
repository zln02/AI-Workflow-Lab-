package dao;

import db.DBConnect;
import model.Provider;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ProviderDAO {
    public List<Provider> findAll() throws SQLException {
        List<Provider> providers = new ArrayList<>();
        String sql = "SELECT * FROM providers ORDER BY provider_name ASC";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                providers.add(map(rs));
            }
        }

        return providers;
    }

    public Provider findById(int id) throws SQLException {
        String sql = "SELECT * FROM providers WHERE id = ?";

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

    public List<Provider> findByCountry(String country) throws SQLException {
        List<Provider> providers = new ArrayList<>();
        String sql = "SELECT * FROM providers WHERE country = ? ORDER BY provider_name ASC";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, country);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    providers.add(map(rs));
                }
            }
        }

        return providers;
    }

    private Provider map(ResultSet rs) throws SQLException {
        Provider provider = new Provider();
        provider.setId(rs.getInt("id"));
        provider.setProviderName(rs.getString("provider_name"));
        provider.setWebsite(rs.getString("website"));
        provider.setCountry(rs.getString("country"));
        provider.setLogoUrl(rs.getString("logo_url"));
        provider.setDescription(rs.getString("description"));
        provider.setHeadquartersCountry(rs.getString("headquarters_country"));
        provider.setFoundedYear(rs.getObject("founded_year", Integer.class));
        provider.setEmployeeCount(rs.getString("employee_count"));
        provider.setFundingTotal(rs.getString("funding_total"));
        provider.setPublic(rs.getBoolean("is_public"));
        provider.setStockTicker(rs.getString("stock_ticker"));
        provider.setSpecialization(rs.getString("specialization"));
        provider.setApiDocsUrl(rs.getString("api_docs_url"));
        provider.setStatus(rs.getString("status"));
        provider.setCreatedAt(rs.getTimestamp("created_at"));
        provider.setUpdatedAt(rs.getTimestamp("updated_at"));
        return provider;
    }
}
