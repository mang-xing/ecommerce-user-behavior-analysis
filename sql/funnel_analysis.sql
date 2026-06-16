/*
 * 03_转化漏斗分析.sql
 * 目标：分析用户从主页→列表页→详情页→支付页→确认支付的全链路转化情况
 * 依赖：user_behavior_cleaned（01数据清洗的产出表）
 */

-- ============================================
-- 1. 各环节用户数量（漏斗基础数据）
-- ============================================

SELECT 
    SUM(home_page)               AS step1_home,          -- 主页浏览人数
    SUM(listing_page)            AS step2_listing,        -- 列表页浏览人数
    SUM(product_page)            AS step3_product,        -- 产品详情页浏览人数
    SUM(payment_page)            AS step4_payment,        -- 支付页浏览人数
    SUM(payment_confirmation_page) AS step5_confirmation  -- 确认支付人数
FROM user_behavior_cleaned;

-- ============================================
-- 2. 环节间转化率（相邻环节转化率）
-- ============================================

WITH funnel AS (
    SELECT 
        SUM(home_page)               AS step1_home,
        SUM(listing_page)            AS step2_listing,
        SUM(product_page)            AS step3_product,
        SUM(payment_page)            AS step4_payment,
        SUM(payment_confirmation_page) AS step5_confirmation
    FROM user_behavior_cleaned
)
SELECT 
    ROUND(step2_listing * 100.0 / step1_home, 2)        AS home_to_listing_rate,       -- 主页→列表页
    ROUND(step3_product * 100.0 / step2_listing, 2)      AS listing_to_product_rate,    -- 列表页→详情页
    ROUND(step4_payment * 100.0 / step3_product, 2)      AS product_to_payment_rate,    -- 详情页→支付页
    ROUND(step5_confirmation * 100.0 / step4_payment, 2) AS payment_to_confirm_rate,    -- 支付页→确认支付
    ROUND(step5_confirmation * 100.0 / step1_home, 2)    AS overall_conversion_rate     -- 整体转化率
FROM funnel;

-- ============================================
-- 3. 各环节流失率（定位关键流失环节）
-- ============================================

WITH funnel AS (
    SELECT 
        SUM(home_page)               AS step1_home,
        SUM(listing_page)            AS step2_listing,
        SUM(product_page)            AS step3_product,
        SUM(payment_page)            AS step4_payment,
        SUM(payment_confirmation_page) AS step5_confirmation
    FROM user_behavior_cleaned
)
SELECT 
    ROUND((1 - step2_listing * 1.0 / step1_home) * 100, 2)      AS home_loss_rate,         -- 主页流失率
    ROUND((1 - step3_product * 1.0 / step2_listing) * 100, 2)    AS listing_loss_rate,      -- 列表页流失率
    ROUND((1 - step4_payment * 1.0 / step3_product) * 100, 2)    AS product_loss_rate,      -- 详情页流失率
    ROUND((1 - step5_confirmation * 1.0 / step4_payment) * 100, 2) AS payment_loss_rate     -- 支付页流失率
FROM funnel;

-- ============================================
-- 4. 按设备拆分漏斗（PC vs Mobile）
-- ============================================

WITH funnel_by_device AS (
    SELECT 
        device,
        SUM(home_page)               AS step1_home,
        SUM(listing_page)            AS step2_listing,
        SUM(product_page)            AS step3_product,
        SUM(payment_page)            AS step4_payment,
        SUM(payment_confirmation_page) AS step5_confirmation
    FROM user_behavior_cleaned
    GROUP BY device
)
SELECT 
    device,
    step1_home                          AS home_users,
    step2_listing                       AS listing_users,
    step3_product                       AS product_users,
    step4_payment                       AS payment_users,
    step5_confirmation                  AS confirmed_users,
    ROUND(step2_listing * 100.0 / step1_home, 2)        AS home_to_listing_rate,
    ROUND(step3_product * 100.0 / step2_listing, 2)      AS listing_to_product_rate,
    ROUND(step4_payment * 100.0 / step3_product, 2)      AS product_to_payment_rate,
    ROUND(step5_confirmation * 100.0 / step4_payment, 2) AS payment_to_confirm_rate,
    ROUND(step5_confirmation * 100.0 / step1_home, 2)    AS overall_conversion_rate
FROM funnel_by_device
ORDER BY overall_conversion_rate DESC;

-- ============================================
-- 5. 按性别拆分漏斗
-- ============================================

WITH funnel_by_sex AS (
    SELECT 
        sex,
        SUM(home_page)               AS step1_home,
        SUM(listing_page)            AS step2_listing,
        SUM(product_page)            AS step3_product,
        SUM(payment_page)            AS step4_payment,
        SUM(payment_confirmation_page) AS step5_confirmation
    FROM user_behavior_cleaned
    GROUP BY sex
)
SELECT 
    sex,
    step1_home                          AS home_users,
    step5_confirmation                  AS confirmed_users,
    ROUND(step2_listing * 100.0 / step1_home, 2)        AS home_to_listing_rate,
    ROUND(step3_product * 100.0 / step2_listing, 2)      AS listing_to_product_rate,
    ROUND(step4_payment * 100.0 / step3_product, 2)      AS product_to_payment_rate,
    ROUND(step5_confirmation * 100.0 / step4_payment, 2) AS payment_to_confirm_rate,
    ROUND(step5_confirmation * 100.0 / step1_home, 2)    AS overall_conversion_rate
FROM funnel_by_sex
ORDER BY overall_conversion_rate DESC;
