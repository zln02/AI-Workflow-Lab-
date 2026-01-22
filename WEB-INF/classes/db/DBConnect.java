package db;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.stream.Stream;

/**
 * 데이터베이스 연결 관리 클래스
 * 환경 변수를 통한 설정 관리 및 연결 풀 최적화
 */
public final class DBConnect {
  // 환경 변수에서 설정 읽기 (필수)
  // 주의: 모든 데이터베이스 연결 정보는 환경 변수로 설정해야 합니다
  private static final String DB_HOST = getRequiredEnv("DB_HOST");
  private static final String DB_PORT = getRequiredEnv("DB_PORT");
  private static final String DB_NAME = getRequiredEnv("DB_NAME");
  private static final String DB_USER = getRequiredEnv("DB_USER");
  private static final String DB_PASSWORD = getRequiredEnv("DB_PASSWORD");
  
  // JDBC URL 최적화: PreparedStatement 캐싱 및 성능 파라미터 추가
  private static final String URL = String.format(
      "jdbc:mysql://%s:%s/%s?" +
      "useSSL=false&" +
      "serverTimezone=Asia/Seoul&" +
      "allowPublicKeyRetrieval=true&" +
      "useUnicode=true&" +
      "characterEncoding=UTF-8&" +
      "cachePrepStmts=true&" +
      "prepStmtCacheSize=250&" +
      "prepStmtCacheSqlLimit=2048&" +
      "rewriteBatchedStatements=true&" +
      "useServerPrepStmts=true&" +
      "cacheResultSetMetadata=true&" +
      "cacheServerConfiguration=true&" +
      "maintainTimeStats=false&" +
      "connectTimeout=5000&" +
      "socketTimeout=10000&" +
      "autoReconnect=true&" +
      "maxReconnects=3",
      DB_HOST, DB_PORT, DB_NAME
  );
  
  /**
   * 환경 변수에서 값을 읽거나 기본값 반환
   * @param envName 환경 변수 이름
   * @param defaultValue 기본값
   * @return 환경 변수 값 또는 기본값
   */
  private static String getEnvOrDefault(String envName, String defaultValue) {
    String value = System.getenv(envName);
    if (value != null && !value.trim().isEmpty()) {
      return value.trim();
    }
    // 시스템 프로퍼티에서도 확인
    value = System.getProperty(envName);
    if (value != null && !value.trim().isEmpty()) {
      return value.trim();
    }
    return defaultValue;
  }

  /**
   * 환경 변수에서 필수 값을 읽기 (없으면 예외 발생)
   * @param envName 환경 변수 이름
   * @return 환경 변수 값
   * @throws IllegalStateException 환경 변수가 설정되지 않은 경우
   */
  private static String getRequiredEnv(String envName) {
    String value = System.getenv(envName);
    if (value != null && !value.trim().isEmpty()) {
      return value.trim();
    }
    // 시스템 프로퍼티에서도 확인
    value = System.getProperty(envName);
    if (value != null && !value.trim().isEmpty()) {
      return value.trim();
    }
    throw new IllegalStateException(
        String.format("필수 환경 변수 '%s'가 설정되지 않았습니다. 환경 변수를 설정해주세요.", envName));
  }

  static {
    try {
      Class.forName("com.mysql.cj.jdbc.Driver");
      initializeSchema();
    } catch (ClassNotFoundException e) {
      throw new ExceptionInInitializerError(e);
    }
  }

  private DBConnect() {}

  /**
   * 데이터베이스 연결 가져오기 (재시도 로직 포함)
   * @return 데이터베이스 연결 객체
   * @throws SQLException 연결 실패 시
   */
  public static Connection getConnection() throws SQLException {
    int maxRetries = 3;
    int retryDelay = 1000; // 1초
    
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        return DriverManager.getConnection(URL, DB_USER, DB_PASSWORD);
      } catch (SQLException e) {
        if (attempt == maxRetries) {
          // 마지막 시도에서도 실패하면 예외를 다시 던짐
          throw new SQLException("데이터베이스 연결 실패 (시도: " + attempt + "/" + maxRetries + ")", e);
        }
        // 연결 실패 시 재시도 전 대기
        try {
          Thread.sleep(retryDelay);
        } catch (InterruptedException ie) {
          Thread.currentThread().interrupt();
          throw new SQLException("연결 재시도 중 인터럽트 발생", ie);
        }
      }
    }
    
    // 이 코드는 실행되지 않지만 컴파일러를 만족시키기 위해 필요
    throw new SQLException("데이터베이스 연결에 실패했습니다");
  }

  private static void initializeSchema() {
    Path script =
        Path.of(
            System.getProperty("catalina.base"),
            "webapps",
            "AI",
            "database",
            "schema.sql");
    if (!Files.exists(script)) {
      return;
    }
    try {
      String sql = Files.readString(script, StandardCharsets.UTF_8);
      try (Connection conn = DriverManager.getConnection(URL, DB_USER, DB_PASSWORD);
          Statement stmt = conn.createStatement()) {
        Stream.of(sql.split(";"))
            .map(String::trim)
            .filter(line -> !line.isEmpty())
            .forEach(
                statement -> {
                  try {
                    stmt.execute(statement);
                  } catch (SQLException ignored) {
                    // ignore statements that already exist
                  }
                });
      }
    } catch (Exception ignored) {
      // schema initialization should not crash the application
    }
  }
}
