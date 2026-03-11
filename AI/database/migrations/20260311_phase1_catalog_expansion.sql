-- Phase 1 catalog expansion for AI Workflow Lab
-- Strategy reference: STRATEGY.md Phase 1

DROP PROCEDURE IF EXISTS add_column_if_missing;
DELIMITER $$
CREATE PROCEDURE add_column_if_missing(
    IN p_schema VARCHAR(64),
    IN p_table VARCHAR(64),
    IN p_column VARCHAR(64),
    IN p_definition TEXT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = p_schema
          AND table_name = p_table
          AND column_name = p_column
    ) THEN
        SET @ddl = CONCAT('ALTER TABLE `', p_schema, '`.`', p_table, '` ADD COLUMN `', p_column, '` ', p_definition);
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS add_index_if_missing;
DELIMITER $$
CREATE PROCEDURE add_index_if_missing(
    IN p_schema VARCHAR(64),
    IN p_table VARCHAR(64),
    IN p_index VARCHAR(64),
    IN p_definition TEXT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.statistics
        WHERE table_schema = p_schema
          AND table_name = p_table
          AND index_name = p_index
    ) THEN
        SET @ddl = CONCAT('ALTER TABLE `', p_schema, '`.`', p_table, '` ADD ', p_definition);
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$
DELIMITER ;

SET @schema_name = DATABASE();

CALL add_column_if_missing(@schema_name, 'providers', 'logo_url', 'VARCHAR(500) DEFAULT NULL AFTER website');
CALL add_column_if_missing(@schema_name, 'providers', 'description', 'TEXT DEFAULT NULL AFTER logo_url');
CALL add_column_if_missing(@schema_name, 'providers', 'headquarters_country', 'VARCHAR(100) DEFAULT NULL AFTER country');
CALL add_column_if_missing(@schema_name, 'providers', 'founded_year', 'INT DEFAULT NULL AFTER headquarters_country');
CALL add_column_if_missing(@schema_name, 'providers', 'employee_count', 'VARCHAR(50) DEFAULT NULL AFTER founded_year');
CALL add_column_if_missing(@schema_name, 'providers', 'funding_total', 'VARCHAR(100) DEFAULT NULL AFTER employee_count');
CALL add_column_if_missing(@schema_name, 'providers', 'is_public', 'TINYINT(1) DEFAULT 0 AFTER funding_total');
CALL add_column_if_missing(@schema_name, 'providers', 'stock_ticker', 'VARCHAR(20) DEFAULT NULL AFTER is_public');
CALL add_column_if_missing(@schema_name, 'providers', 'specialization', 'VARCHAR(255) DEFAULT NULL AFTER stock_ticker');
CALL add_column_if_missing(@schema_name, 'providers', 'api_docs_url', 'VARCHAR(500) DEFAULT NULL AFTER specialization');
CALL add_column_if_missing(@schema_name, 'providers', 'status', 'ENUM(''active'',''acquired'',''shutdown'') DEFAULT ''active'' AFTER api_docs_url');
CALL add_column_if_missing(@schema_name, 'providers', 'updated_at', 'TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP AFTER created_at');

CALL add_column_if_missing(@schema_name, 'ai_tools', 'provider_country', 'VARCHAR(100) DEFAULT NULL AFTER provider_name');
CALL add_column_if_missing(@schema_name, 'ai_tools', 'monthly_active_users', 'BIGINT DEFAULT NULL AFTER provider_country');
CALL add_column_if_missing(@schema_name, 'ai_tools', 'launch_date', 'DATE DEFAULT NULL AFTER monthly_active_users');
CALL add_column_if_missing(@schema_name, 'ai_tools', 'last_major_update', 'DATE DEFAULT NULL AFTER launch_date');
CALL add_column_if_missing(@schema_name, 'ai_tools', 'global_rank', 'INT DEFAULT NULL AFTER last_major_update');
CALL add_column_if_missing(@schema_name, 'ai_tools', 'category_rank', 'INT DEFAULT NULL AFTER global_rank');
CALL add_column_if_missing(@schema_name, 'ai_tools', 'trend_score', 'DECIMAL(5,2) DEFAULT 0.00 AFTER category_rank');
CALL add_column_if_missing(@schema_name, 'ai_tools', 'growth_rate', 'DECIMAL(5,2) DEFAULT 0.00 AFTER trend_score');
CALL add_column_if_missing(@schema_name, 'ai_tools', 'pros', 'JSON DEFAULT NULL AFTER growth_rate');
CALL add_column_if_missing(@schema_name, 'ai_tools', 'cons', 'JSON DEFAULT NULL AFTER pros');
CALL add_column_if_missing(@schema_name, 'ai_tools', 'alternatives', 'JSON DEFAULT NULL AFTER cons');
CALL add_column_if_missing(@schema_name, 'ai_tools', 'integrations', 'JSON DEFAULT NULL AFTER alternatives');
CALL add_column_if_missing(@schema_name, 'ai_tools', 'supported_platforms', 'JSON DEFAULT NULL AFTER integrations');
CALL add_column_if_missing(@schema_name, 'ai_tools', 'data_privacy_score', 'INT DEFAULT NULL AFTER supported_platforms');
CALL add_column_if_missing(@schema_name, 'ai_tools', 'enterprise_ready', 'TINYINT(1) DEFAULT 0 AFTER data_privacy_score');
CALL add_column_if_missing(@schema_name, 'ai_tools', 'open_source', 'TINYINT(1) DEFAULT 0 AFTER enterprise_ready');
CALL add_column_if_missing(@schema_name, 'ai_tools', 'github_url', 'VARCHAR(500) DEFAULT NULL AFTER open_source');
CALL add_column_if_missing(@schema_name, 'ai_tools', 'github_stars', 'INT DEFAULT NULL AFTER github_url');
CALL add_column_if_missing(@schema_name, 'ai_tools', 'monthly_visits', 'BIGINT DEFAULT NULL AFTER github_stars');

CALL add_index_if_missing(@schema_name, 'ai_tools', 'idx_tools_country', 'INDEX `idx_tools_country` (`provider_country`)');
CALL add_index_if_missing(@schema_name, 'ai_tools', 'idx_tools_global_rank', 'INDEX `idx_tools_global_rank` (`global_rank`)');
CALL add_index_if_missing(@schema_name, 'ai_tools', 'idx_tools_trend', 'INDEX `idx_tools_trend` (`trend_score`)');
CALL add_index_if_missing(@schema_name, 'ai_tools', 'idx_tools_mau', 'INDEX `idx_tools_mau` (`monthly_active_users`)');

CREATE TABLE IF NOT EXISTS countries (
    code VARCHAR(10) PRIMARY KEY,
    name_ko VARCHAR(100) NOT NULL,
    name_en VARCHAR(100) NOT NULL,
    flag_emoji VARCHAR(10) DEFAULT NULL,
    region VARCHAR(50) DEFAULT NULL,
    tool_count INT DEFAULT 0,
    display_order INT DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ai_tool_news (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tool_id INT DEFAULT NULL,
    title VARCHAR(500) NOT NULL,
    summary TEXT NOT NULL,
    content LONGTEXT DEFAULT NULL,
    source_url VARCHAR(500) DEFAULT NULL,
    source_name VARCHAR(200) DEFAULT NULL,
    image_url VARCHAR(500) DEFAULT NULL,
    news_type ENUM('update','launch','funding','comparison','tutorial','industry') DEFAULT 'update',
    tags JSON DEFAULT NULL,
    view_count INT DEFAULT 0,
    published_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_featured TINYINT(1) DEFAULT 0,
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_ai_tool_news_tool FOREIGN KEY (tool_id) REFERENCES ai_tools(id) ON DELETE SET NULL,
    INDEX idx_news_type (news_type),
    INDEX idx_news_featured (is_featured, published_at),
    INDEX idx_news_published (published_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ai_tool_benchmarks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tool_id INT NOT NULL,
    benchmark_name VARCHAR(200) NOT NULL,
    score DECIMAL(8,3) NOT NULL,
    max_score DECIMAL(8,3) DEFAULT NULL,
    test_date DATE DEFAULT NULL,
    source VARCHAR(200) DEFAULT NULL,
    notes TEXT DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_ai_tool_benchmarks_tool FOREIGN KEY (tool_id) REFERENCES ai_tools(id) ON DELETE CASCADE,
    INDEX idx_bench_tool (tool_id),
    INDEX idx_bench_name (benchmark_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ai_model_comparisons (
    id INT AUTO_INCREMENT PRIMARY KEY,
    model_a_id INT NOT NULL,
    model_b_id INT NOT NULL,
    comparison_data JSON NOT NULL,
    winner_id INT DEFAULT NULL,
    summary TEXT DEFAULT NULL,
    view_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_comp_models (model_a_id, model_b_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP PROCEDURE IF EXISTS add_column_if_missing;
DROP PROCEDURE IF EXISTS add_index_if_missing;
