package dao;

import db.DBConnect;
import model.Country;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class CountryDAO {
    public List<Country> findAll() throws SQLException {
        List<Country> countries = new ArrayList<>();
        String sql = "SELECT * FROM countries ORDER BY display_order ASC, name_en ASC";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                countries.add(map(rs));
            }
        }

        return countries;
    }

    public Country findByCode(String code) throws SQLException {
        String sql = "SELECT * FROM countries WHERE code = ?";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return map(rs);
                }
            }
        }

        return null;
    }

    public List<Country> findByRegion(String region) throws SQLException {
        List<Country> countries = new ArrayList<>();
        String sql = "SELECT * FROM countries WHERE region = ? ORDER BY display_order ASC, name_en ASC";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, region);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    countries.add(map(rs));
                }
            }
        }

        return countries;
    }

    private Country map(ResultSet rs) throws SQLException {
        Country country = new Country();
        country.setCode(rs.getString("code"));
        country.setNameKo(rs.getString("name_ko"));
        country.setNameEn(rs.getString("name_en"));
        country.setFlagEmoji(rs.getString("flag_emoji"));
        country.setRegion(rs.getString("region"));
        country.setToolCount(rs.getInt("tool_count"));
        country.setDisplayOrder(rs.getInt("display_order"));
        return country;
    }
}
