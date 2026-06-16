/*
 * 01_数据清洗.sql
 * 目标：对原始用户行为数据进行清洗，处理重复值、缺失值和异常值
 * 依赖：原始表 user_behavior_raw
 * 产出：清洗后的表 user_behavior_cleaned
 */

-- ============================================
-- Step 1: 创建清洗后的数据表
-- ============================================

-- 删除重复记录（基于user_id去重，保留第一条）
CREATE TABLE user_behavior_cleaned AS
SELECT 
    user_id,
    new_user,
    age,
    sex,
    market,
    device,
    operative_system,
    source,
    total_pages_visited,
    home_page,
    listing_page,
    product_page,
    payment_page,
    payment_confirmation_page
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY user_id) AS rn
    FROM user_behavior_raw
) t
WHERE rn = 1;

-- ============================================
-- Step 2: 检查缺失值情况
-- ============================================

-- 查看各字段缺失值数量
SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN user_id IS NULL THEN 1 ELSE 0 END) AS user_id_null,
    SUM(CASE WHEN age IS NULL THEN 1 ELSE 0 END) AS age_null,
    SUM(CASE WHEN sex IS NULL THEN 1 ELSE 0 END) AS sex_null,
    SUM(CASE WHEN source IS NULL THEN 1 ELSE 0 END) AS source_null,
    SUM(CASE WHEN device IS NULL THEN 1 ELSE 0 END) AS device_null
FROM user_behavior_cleaned;

-- ============================================
-- Step 3: 处理source字段缺失值
-- ============================================

-- 将source为NULL的记录标记为'Unknown'，便于后续分组分析
UPDATE user_behavior_cleaned
SET source = 'Unknown'
WHERE source IS NULL OR TRIM(source) = '';

-- ============================================
-- Step 4: 处理年龄异常值
-- ============================================

-- 查看年龄分布，识别异常值
SELECT 
    MIN(age) AS min_age,
    MAX(age) AS max_age,
    AVG(age) AS avg_age
FROM user_behavior_cleaned;

-- 剔除年龄不合理的数据（如年龄<10或>100）
DELETE FROM user_behavior_cleaned
WHERE age < 10 OR age > 100;

-- ============================================
-- Step 5: 验证清洗结果
-- ============================================

-- 确认清洗后数据量
SELECT COUNT(*) AS cleaned_rows FROM user_behavior_cleaned;

-- 确认无重复user_id
SELECT COUNT(*) AS total, COUNT(DISTINCT user_id) AS unique_users
FROM user_behavior_cleaned;

-- 确认页面浏览字段均为0/1
SELECT 
    SUM(CASE WHEN home_page NOT IN (0,1) THEN 1 ELSE 0 END) AS home_invalid,
    SUM(CASE WHEN listing_page NOT IN (0,1) THEN 1 ELSE 0 END) AS listing_invalid,
    SUM(CASE WHEN product_page NOT IN (0,1) THEN 1 ELSE 0 END) AS product_invalid,
    SUM(CASE WHEN payment_page NOT IN (0,1) THEN 1 ELSE 0 END) AS payment_invalid,
    SUM(CASE WHEN payment_confirmation_page NOT IN (0,1) THEN 1 ELSE 0 END) AS confirm_invalid
FROM user_behavior_cleaned;
