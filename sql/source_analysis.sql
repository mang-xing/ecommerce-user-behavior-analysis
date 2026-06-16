/*
 * 04_用户来源分析.sql
 * 目标：分析不同流量来源（SEO、Direct、Ads等）的用户规模和转化效果
 * 依赖：user_behavior_cleaned（01数据清洗的产出表）
 */

-- ============================================
-- 1. 各渠道用户规模与占比
-- ============================================

SELECT 
    source,
    COUNT(*)                   AS user_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM user_behavior_cleaned), 2) AS proportion
FROM user_behavior_cleaned
GROUP BY source
ORDER BY user_count DESC;

-- ============================================
-- 2. 各渠道转化漏斗（全链路对比）
-- ============================================

WITH source_funnel AS (
    SELECT 
        source,
        COUNT(*)                            AS total_users,
        SUM(home_page)                      AS home_users,
        SUM(listing_page)                   AS listing_users,
        SUM(product_page)                   AS product_users,
        SUM(payment_page)                   AS payment_users,
        SUM(payment_confirmation_page)      AS confirmed_users
    FROM user_behavior_cleaned
    GROUP BY source
)
SELECT 
    source,
    total_users,
    confirmed_users,
    ROUND(confirmed_users * 100.0 / total_users, 2)      AS overall_conversion_rate,
    ROUND(listing_users * 100.0 / home_users, 2)          AS home_to_listing_rate,
    ROUND(product_users * 100.0 / listing_users, 2)       AS listing_to_product_rate,
    ROUND(payment_users * 100.0 / product_users, 2)       AS product_to_payment_rate,
    ROUND(confirmed_users * 100.0 / payment_users, 2)     AS payment_to_confirm_rate
FROM source_funnel
ORDER BY overall_conversion_rate DESC;

-- ============================================
-- 3. 各渠道用户质量对比（人均浏览页数 + 转化率）
-- ============================================

SELECT 
    source,
    COUNT(*)                            AS user_count,
    ROUND(AVG(total_pages_visited), 2)  AS avg_pages_visited,
    SUM(payment_confirmation_page)      AS order_count,
    ROUND(SUM(payment_confirmation_page) * 100.0 / COUNT(*), 2) AS conversion_rate
FROM user_behavior_cleaned
GROUP BY source
ORDER BY conversion_rate DESC;

-- ============================================
-- 4. 各渠道新老用户结构
-- ============================================

SELECT 
    source,
    SUM(CASE WHEN new_user = 1 THEN 1 ELSE 0 END) AS new_user_count,
    SUM(CASE WHEN new_user = 0 THEN 1 ELSE 0 END) AS old_user_count,
    ROUND(SUM(CASE WHEN new_user = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS new_user_ratio
FROM user_behavior_cleaned
GROUP BY source
ORDER BY new_user_count DESC;

-- ============================================
-- 5. 各渠道 × 设备 交叉转化率
-- ============================================

SELECT 
    source,
    device,
    COUNT(*)                            AS user_count,
    SUM(payment_confirmation_page)      AS order_count,
    ROUND(SUM(payment_confirmation_page) * 100.0 / COUNT(*), 2) AS conversion_rate
FROM user_behavior_cleaned
GROUP BY source, device
ORDER BY conversion_rate DESC;
