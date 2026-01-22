-- ============================================
-- 주문 및 구독 데이터 확인 스크립트
-- ============================================

-- 1. orders 테이블 확인
SELECT 
    id,
    customer_name,
    customer_email,
    customer_phone,
    payment_method,
    total_price,
    order_status,
    created_at,
    DATE_FORMAT(created_at, '%Y-%m-%d %H:%i:%s') as formatted_date
FROM orders
ORDER BY created_at DESC
LIMIT 10;

-- 2. order_items 테이블 확인
SELECT 
    id,
    order_id,
    item_type,
    item_id,
    quantity,
    price,
    created_at,
    DATE_FORMAT(created_at, '%Y-%m-%d %H:%i:%s') as formatted_date
FROM order_items
ORDER BY created_at DESC
LIMIT 10;

-- 3. subscriptions 테이블 확인
SELECT 
    id,
    user_id,
    plan_code,
    start_date,
    end_date,
    status,
    payment_method,
    transaction_id,
    created_at,
    updated_at,
    DATE_FORMAT(created_at, '%Y-%m-%d %H:%i:%s') as formatted_created_at
FROM subscriptions
ORDER BY created_at DESC
LIMIT 10;

-- 4. 테이블 존재 여부 확인
SELECT 
    TABLE_NAME,
    TABLE_ROWS,
    CREATE_TIME,
    UPDATE_TIME
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = DATABASE()
AND TABLE_NAME IN ('orders', 'order_items', 'subscriptions');

-- 5. 최근 주문 및 구독 통계
SELECT 
    'orders' as table_name,
    COUNT(*) as total_count,
    MAX(created_at) as latest_record
FROM orders
UNION ALL
SELECT 
    'order_items' as table_name,
    COUNT(*) as total_count,
    MAX(created_at) as latest_record
FROM order_items
UNION ALL
SELECT 
    'subscriptions' as table_name,
    COUNT(*) as total_count,
    MAX(created_at) as latest_record
FROM subscriptions;


