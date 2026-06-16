/*
 * 02_基础指标.sql
 * 目标：计算平台流量规模、用户基础和访问深度等核心指标
 * 依赖：user_behavior_cleaned（01数据清洗的产出表）
 */

-- ============================================
-- 1. 流量与用户基础指标总览
-- ============================================

SELECT 
    COUNT(*)                          AS total_visits,        -- 总访问量
    COUNT(DISTINCT user_id)           AS unique_users,        -- 独立用户数
    SUM(payment_confirmation_page)    AS total_orders,        -- 总下单人数
    ROUND(AVG(total_pages_visited), 2) AS avg_pages_visited,  -- 人均浏览页数
    ROUND(SUM(payment_confirmation_page) * 100.0 / COUNT(*), 2) AS overall_conversion_rate  -- 整体转化率(%)
FROM user_behavior_cleaned;

-- ============================================
-- 2. 用户画像：性别分布
-- ============================================

SELECT 
    sex,
    COUNT(*)                   AS user_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM user_behavior_cleaned), 2) AS proportion
FROM user_behavior_cleaned
GROUP BY sex
ORDER BY user_count DESC;

-- ============================================
-- 3. 用户画像：市场级别分布
-- ============================================

SELECT 
    market,
    COUNT(*)                   AS user_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM user_behavior_cleaned), 2) AS proportion
FROM user_behavior_cleaned
GROUP BY market
ORDER BY user_count DESC;

-- ============================================
-- 4. 用户画像：设备类型分布
-- ============================================

SELECT 
    device,
    COUNT(*)                   AS user_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM user_behavior_cleaned), 2) AS proportion
FROM user_behavior_cleaned
GROUP BY device
ORDER BY user_count DESC;

-- ============================================
-- 5. 用户画像：操作系统分布
-- ============================================

SELECT 
    operative_system,
    COUNT(*)                   AS user_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM user_behavior_cleaned), 2) AS proportion
FROM user_behavior_cleaned
GROUP BY operative_system
ORDER BY user_count DESC;

-- ============================================
-- 6. 年龄分布统计
-- ============================================

SELECT 
    MIN(age) AS min_age,
    MAX(age) AS max_age,
    ROUND(AVG(age), 1) AS avg_age,
    -- 年龄段分布
    SUM(CASE WHEN age < 20 THEN 1 ELSE 0 END) AS age_below_20,
    SUM(CASE WHEN age BETWEEN 20 AND 29 THEN 1 ELSE 0 END) AS age_20_29,
    SUM(CASE WHEN age BETWEEN 30 AND 39 THEN 1 ELSE 0 END) AS age_30_39,
    SUM(CASE WHEN age BETWEEN 40 AND 49 THEN 1 ELSE 0 END) AS age_40_49,
    SUM(CASE WHEN age >= 50 THEN 1 ELSE 0 END) AS age_50_plus
FROM user_behavior_cleaned;
