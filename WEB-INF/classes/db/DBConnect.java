package db;

import java.sql.Connection;
import java.sql.SQLException;
import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

public class DBConnect {
    private static HikariDataSource dataSource;
    
    static {
        try {
            // HikariCP 설정
            HikariConfig config = new HikariConfig();
            
            // 환경 변수에서 데이터베이스 설정 읽기
            String dbUrl = System.getenv("DB_URL");
            String dbUser = System.getenv("DB_USER");
            String dbPassword = System.getenv("DB_PASSWORD");
            
            // 환경 변수가 없으면 기본값 사용 (개발용)
            if (dbUrl == null) {
                dbUrl = "jdbc:mysql://localhost:3306/ai_navigator?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
            }
            if (dbUser == null) {
                dbUser = "root";
            }
            if (dbPassword == null) {
                dbPassword = "1234!"; // 개발 환경에서만 사용
            }
            
            config.setJdbcUrl(dbUrl);
            config.setUsername(dbUser);
            config.setPassword(dbPassword);
            
            // 커넥션 풀 설정
            config.setDriverClassName("com.mysql.cj.jdbc.Driver");
            config.setMaximumPoolSize(20);
            config.setMinimumIdle(5);
            config.setConnectionTimeout(30000);
            config.setIdleTimeout(600000);
            config.setMaxLifetime(1800000);
            config.setLeakDetectionThreshold(60000);
            
            // 보안 설정
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
    
    // 테스트용 메서드
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
    
    // 커넥션 풀 상태 정보
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
