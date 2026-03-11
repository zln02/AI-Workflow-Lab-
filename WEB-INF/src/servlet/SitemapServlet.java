package servlet;

import db.DBConnect;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class SitemapServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/xml; charset=UTF-8");
        response.setCharacterEncoding("UTF-8");

        String baseUrl = request.getScheme() + "://" + request.getServerName();
        if (!((request.getScheme().equals("http") && request.getServerPort() == 80)
                || (request.getScheme().equals("https") && request.getServerPort() == 443))) {
            baseUrl += ":" + request.getServerPort();
        }

        List<UrlEntry> urls = new ArrayList<>();
        urls.add(new UrlEntry(baseUrl + "/AI/user/home.jsp", "daily", "1.0"));
        urls.add(new UrlEntry(baseUrl + "/AI/user/tools/navigator.jsp", "daily", "0.9"));
        urls.add(new UrlEntry(baseUrl + "/AI/user/tools/rankings.jsp", "daily", "0.9"));
        urls.add(new UrlEntry(baseUrl + "/AI/user/tools/compare.jsp", "weekly", "0.8"));
        urls.add(new UrlEntry(baseUrl + "/AI/user/news/index.jsp", "hourly", "0.8"));
        urls.add(new UrlEntry(baseUrl + "/AI/user/lab/index.jsp", "weekly", "0.7"));
        urls.add(new UrlEntry(baseUrl + "/AI/user/pricing.jsp", "weekly", "0.7"));

        try (Connection conn = DBConnect.getConnection()) {
            appendToolUrls(conn, baseUrl, urls);
            appendNewsUrls(conn, baseUrl, urls);
        } catch (Exception ignored) {
            // Return static routes even when DB access fails.
        }

        try (PrintWriter out = response.getWriter()) {
            out.println("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
            out.println("<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">");
            for (UrlEntry entry : urls) {
                out.println("  <url>");
                out.println("    <loc>" + escapeXml(entry.loc) + "</loc>");
                out.println("    <changefreq>" + entry.changefreq + "</changefreq>");
                out.println("    <priority>" + entry.priority + "</priority>");
                out.println("  </url>");
            }
            out.println("</urlset>");
        }
    }

    private void appendToolUrls(Connection conn, String baseUrl, List<UrlEntry> urls) throws Exception {
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT id FROM ai_tools WHERE is_active = 1 ORDER BY COALESCE(updated_at, created_at) DESC LIMIT 200");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                urls.add(new UrlEntry(baseUrl + "/AI/user/tools/detail.jsp?id=" + rs.getInt("id"), "weekly", "0.7"));
            }
        }
    }

    private void appendNewsUrls(Connection conn, String baseUrl, List<UrlEntry> urls) throws Exception {
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT id FROM ai_tool_news WHERE is_active = 1 ORDER BY published_at DESC LIMIT 100");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                urls.add(new UrlEntry(baseUrl + "/AI/user/news/detail.jsp?id=" + rs.getInt("id"), "daily", "0.6"));
            }
        }
    }

    private String escapeXml(String value) {
        if (value == null) {
            return "";
        }
        return value
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&apos;");
    }

    private static class UrlEntry {
        private final String loc;
        private final String changefreq;
        private final String priority;

        private UrlEntry(String loc, String changefreq, String priority) {
            this.loc = loc;
            this.changefreq = changefreq;
            this.priority = priority;
        }
    }
}
