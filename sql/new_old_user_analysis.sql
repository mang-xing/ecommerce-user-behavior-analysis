/*
 * 05_新老用户分析.sql
 * 目标：对比新老用户在访问深度、转化率上的差异，分析用户生命周期价值
 * 依赖：user_behavior_cleaned（01数据清洗的产出表）
 */

-- ============================================
-- 1. 新老用户基础对比
-- ============================================

SELECT 
    CASE WHEN new_user = 1 THEN '新用户' ELSE '老用户' END AS user_type,
    COUNT(*)                            AS user_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM user_behavior_cleaned), 2) AS proportion,
    ROUND(AVG(total_pages_visited), 2)  AS avg_pages_visited,
    SUM(payment_confirmation_page)      AS order_count,
    ROUND(SUM(payment_confirmation_page) * 100.0 / COUNT(*), 2) AS conversion_rate
FROM user_behavior_cleaned
GROUP BY new_user
ORDER BY conversion_rate DESC;

-- ============================================
-- 2. 新老用户转化漏斗对比
-- ============================================

WITH user_funnel AS (
    SELECT 
        new_user,
        SUM(home_page)                      AS home_users,
        SUM(listing_page)                   AS listing_users,
        SUM(product_page)                   AS product_users,
        SUM(payment_page)                   AS payment_users,
        SUM(payment_confirmation_page)      AS confirmed_users
    FROM user_behavior_cleaned
    GROUP BY new_user
)
SELECT 
    CASE WHEN new_user = 1 THEN '新用户' ELSE '老用户' END AS user_type,
    home_users,
    listing_users,
    product_users,
    payment_users,
    confirmed_users,
    ROUND(listing_users * 100.0 / home_users, 2)        AS home_to_listing_rate,
    ROUND(product_users * 100.0 / listing_users, 2)      AS listing_to_product_rate,
    ROUND(payment_users * 100.0 / product_users, 2)      AS product_to_payment_rate,
    ROUND(confirmed_users * 100.0 / payment_users, 2)    AS payment_to_confirm_rate,
    ROUND(confirmed_users * 100.0 / home_users, 2)      AS overall_conversion_rate
FROM user_funnel
ORDER BY overall_conversion_rate DESC;

-- ============================================
-- 3. 新老用户 × 来源渠道交叉分析
-- ============================================

SELECT 
    CASE WHEN new_user = 1 THEN '新用户' ELSE '老用户' END AS user_type,
    source,
    COUNT(*)                            AS user_count,
    SUM(payment_confirmation_page)      AS order_count,
    ROUND(SUM(payment_confirmation_page) * 100.0 / COUNT(*), 2) AS conversion_rate
FROM user_behavior_cleaned
GROUP BY new_user, source
ORDER BY user_type, conversion_rate DESC;

-- ============================================
-- 4. 新老用户 × 设备交叉分析
-- ============================================

SELECT 
    CASE WHEN new_user = 1 THEN '新用户' ELSE '老用户' END AS user_type,
    device,
    COUNT(*)                            AS user_count,
    ROUND(AVG(total_pages_visited), 2)  AS avg_pages_visited,
    SUM(payment_confirmation_page)      AS order_count,
    ROUND(SUM(payment_confirmation_page) * 100.0 / COUNT(*), 2) AS conversion_rate
FROM user_behavior_cleaned
GROUP BY new_user, device
ORDER BY user_type, conversion_rate DESC;

-- ============================================
-- 5. 老用户下单人数与占比（验证忠诚度）
-- ============================================

SELECT 
    SUM(CASE WHEN new_user = 0 AND payment_confirmation_page = 1 THEN 1 ELSE 0 END) AS old_user_orders,
    SUM(CASE WHEN new_user = 1 AND payment_confirmation_page = 1 THEN 1 ELSE 0 END) AS new_user_orders,
    SUM(payment_confirmation_page) AS total_orders,
    ROUND(SUM(CASE WHEN new_user = 0 AND payment_confirmation_page = 1 THEN 1 ELSE 0 END) 
          * 100.0 / SUM(payment_confirmation_page), 2) AS old_user_order_ratio
FROM user_behavior_cleaned;

-- ============================================
-- 6. 新老用户各年龄段转化率对比
-- ============================================

SELECT 
    CASE WHEN new_user = 1 THEN '新用户' ELSE '老用户' END AS user_type,
    CASE 
        WHEN age < 20 THEN '20岁以下'
        WHEN age BETWEEN 20 AND 29 THEN '20-29岁'
        WHEN age BETWEEN 30 AND 39 THEN '30-39岁'
        WHEN age BETWEEN 40 AND 49 THEN '40-49岁'
        ELSE '50岁及以上'
    END AS age_group,
    COUNT(*) AS user_count,
    SUM(payment_confirmation_page) AS order_count,
    ROUND(SUM(payment_confirmation_page) * 100.0 / COUNT(*), 2) AS conversion_rate
FROM user_behavior_cleaned
GROUP BY new_user, age_group
ORDER BY user_type, conversion_rate DESC;
