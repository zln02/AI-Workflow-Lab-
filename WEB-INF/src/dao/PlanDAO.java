package dao;

import db.DBConnect;
import model.Plan;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class PlanDAO {
    public Plan findByCode(String code) throws SQLException {
        if (code == null || code.trim().isEmpty()) {
            return null;
        }

        String normalized = normalizeCode(code);
        try (Connection conn = DBConnect.getConnection()) {
            String sql = "SELECT * FROM plans WHERE LOWER(plan_code) = ? AND is_active = 1 LIMIT 1";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, normalized);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return map(rs);
                    }
                }
            }
        } catch (SQLException e) {
            return fallbackPlan(normalized);
        }

        return fallbackPlan(normalized);
    }

    public List<Plan> findAllActive() throws SQLException {
        List<Plan> items = new ArrayList<>();
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT * FROM plans WHERE is_active = 1 ORDER BY display_order ASC, id ASC");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                items.add(map(rs));
            }
        } catch (SQLException e) {
            return fallbackPlans();
        }

        return items.isEmpty() ? fallbackPlans() : items;
    }

    private Plan map(ResultSet rs) throws SQLException {
        Plan plan = new Plan();
        plan.setId(rs.getInt("id"));
        plan.setPlanCode(rs.getString("plan_code"));
        plan.setName(rs.getString("plan_name"));
        plan.setNameKo(rs.getString("plan_name_ko"));
        plan.setPlanType(rs.getString("plan_type"));
        plan.setBillingCycle(rs.getString("billing_cycle"));
        plan.setPriceUsd(rs.getBigDecimal("price_monthly"));
        plan.setPriceYearly(rs.getBigDecimal("price_yearly"));
        plan.setCurrency(rs.getString("currency"));
        plan.setCreditsMonthly(rs.getInt("credits_monthly"));
        plan.setMaxApiCallsDaily(rs.getObject("max_api_calls_daily", Integer.class));
        plan.setMaxProjects(rs.getObject("max_projects", Integer.class));
        plan.setFeaturesJson(rs.getString("features"));
        plan.setPopular(rs.getBoolean("is_popular"));
        plan.setActive(rs.getBoolean("is_active"));
        plan.setDisplayOrder(rs.getInt("display_order"));
        plan.setDurationMonths(resolveDurationMonths(plan.getPlanCode(), plan.getBillingCycle()));
        return plan;
    }

    private String normalizeCode(String code) {
        String raw = code.trim().toLowerCase();
        if ("growth".equals(raw)) {
            return "pro";
        }
        return raw;
    }

    private int resolveDurationMonths(String planCode, String billingCycle) {
        if ("yearly".equalsIgnoreCase(billingCycle)) {
            return 12;
        }
        if ("enterprise".equalsIgnoreCase(planCode)) {
            return 12;
        }
        return 1;
    }

    private List<Plan> fallbackPlans() {
        return Arrays.asList(
                buildPlan(1, "free", "Free", "무료", "free", BigDecimal.ZERO, BigDecimal.ZERO, 50, 1, false),
                buildPlan(2, "starter", "Starter", "스타터", "starter", new BigDecimal("9900"), new BigDecimal("99000"), 500, 1, false),
                buildPlan(3, "pro", "Professional", "프로", "pro", new BigDecimal("29900"), new BigDecimal("299000"), 2000, 1, true),
                buildPlan(4, "enterprise", "Enterprise", "엔터프라이즈", "enterprise", new BigDecimal("99900"), new BigDecimal("999000"), 10000, 12, false)
        );
    }

    private Plan fallbackPlan(String normalized) {
        for (Plan item : fallbackPlans()) {
            if (item.getPlanCode().equalsIgnoreCase(normalized)) {
                return item;
            }
        }
        return null;
    }

    private Plan buildPlan(int id, String code, String name, String nameKo, String type,
                           BigDecimal monthly, BigDecimal yearly, int credits, int durationMonths, boolean popular) {
        Plan plan = new Plan();
        plan.setId(id);
        plan.setPlanCode(code);
        plan.setName(name);
        plan.setNameKo(nameKo);
        plan.setPlanType(type);
        plan.setBillingCycle(durationMonths >= 12 ? "yearly" : "monthly");
        plan.setPriceUsd(monthly);
        plan.setPriceYearly(yearly);
        plan.setCurrency("KRW");
        plan.setCreditsMonthly(credits);
        plan.setDurationMonths(durationMonths);
        plan.setPopular(popular);
        plan.setActive(true);
        return plan;
    }
}
