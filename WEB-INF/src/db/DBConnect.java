package db;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

import java.sql.Connection;
import java.sql.SQLException;

public class DBConnect {
    private static HikariDataSource dataSource;

    static {
        try {
            HikariConfig config = new HikariConfig();

            String dbUrl = System.getenv("DB_URL");
            String dbUser = System.getenv("DB_USER");
            String dbPassword = System.getenv("DB_PASSWORD");

            String environment = System.getenv("ENVIRONMENT");
            boolean isDev = "dev".equalsIgnoreCase(environment) || "development".equalsIgnoreCase(environment);

            if (dbUrl == null) {
                if (!isDev) {
                    throw new IllegalStateException("[FATAL] DB_URL 환경 변수가 설정되지 않았습니다. 프로덕션에서는 DB_URL, DB_USER, DB_PASSWORD를 반드시 설정하세요.");
                }
                dbUrl = "jdbc:mysql://localhost:3306/ai_navigator?useSSL=true&serverTimezone=UTC&requireSSL=false&verifyServerCertificate=false";
                System.err.println("[DEV MODE] DB_URL 기본값 사용");
            }
            if (dbUser == null) {
                if (!isDev) {
                    throw new IllegalStateException("[FATAL] DB_USER 환경 변수가 설정되지 않았습니다.");
                }
                dbUser = "root";
                System.err.println("[DEV MODE] DB_USER 기본값 사용");
            }
            if (dbPassword == null) {
                if (!isDev) {
                    throw new IllegalStateException("[FATAL] DB_PASSWORD 환경 변수가 설정되지 않았습니다.");
                }
                dbPassword = System.getenv("DB_DEV_PASSWORD");
                if (dbPassword == null) {
                    throw new IllegalStateException("[FATAL] 개발 환경에서도 DB_DEV_PASSWORD 환경 변수를 설정해야 합니다.");
                }
                System.err.println("[DEV MODE] DB_DEV_PASSWORD 환경 변수 사용");
            }

            config.setJdbcUrl(dbUrl);
            config.setUsername(dbUser);
            config.setPassword(dbPassword);

            config.setDriverClassName("com.mysql.cj.jdbc.Driver");
            config.setMaximumPoolSize(20);
            config.setMinimumIdle(5);
            config.setConnectionTimeout(30000);
            config.setIdleTimeout(600000);
            config.setMaxLifetime(1800000);
            config.setLeakDetectionThreshold(60000);

            config.addDataSourceProperty("cachePrepStmts", "true");
            config.addDataSourceProperty("prepStmtCacheSize", "250");
            config.addDataSourceProperty("prepStmtCacheSqlLimit", "2048");
            config.addDataSourceProperty("useServerPrepStmts", "true");
            config.addDataSourceProperty("useLocalSessionState", "true");
            config.addDataSourceProperty("rewriteBatchedStatements", "true");
            config.addDataSourceProperty("cacheResultSetMetadata", "true");
            config.addDataSourceProperty("cacheServerConfiguration", "true");
            config.addDataSourceProperty("elideSetAutoCommits", "true");
            config.addDataSourceProperty("maintainTimeStats", "false");

            dataSource = new HikariDataSource(config);
            System.out.println("HikariCP connection pool initialized successfully");
        } catch (Exception e) {
            System.err.println("Failed to initialize connection pool: " + e.getMessage());
            e.printStackTrace();
        }
    }

    public static Connection getConnection() throws SQLException {
        if (dataSource == null) {
            throw new SQLException("Connection pool not initialized");
        }
        return dataSource.getConnection();
    }

    public static void closeConnection() {
        if (dataSource != null) {
            dataSource.close();
            System.out.println("Connection pool closed");
        }
    }

    public static boolean testConnection() {
        try (Connection conn = getConnection()) {
            if (conn != null && !conn.isClosed()) {
                conn.createStatement().execute("SELECT 1");
                return true;
            }
        } catch (SQLException e) {
            System.err.println("Connection test failed: " + e.getMessage());
        }
        return false;
    }

    public static String getPoolStatus() {
        if (dataSource == null) {
            return "Pool not initialized";
        }
        return String.format(
            "Active: %d, Idle: %d, Total: %d, Waiting: %d",
            dataSource.getHikariPoolMXBean().getActiveConnections(),
            dataSource.getHikariPoolMXBean().getIdleConnections(),
            dataSource.getHikariPoolMXBean().getTotalConnections(),
            dataSource.getHikariPoolMXBean().getThreadsAwaitingConnection()
        );
    }
}
