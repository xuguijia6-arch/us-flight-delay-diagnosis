-- analysis queries
-- used for result checking, screenshots, and business conclusion extraction


-- =========================================================
-- 1. 总体诊断指标
-- =========================================================
SELECT
    COUNT(*) AS total_flights,  -- 总航班量
    ROUND(AVG(is_cancelled::numeric), 4) AS cancel_rate,  -- 取消率
    ROUND(AVG(is_diverted::numeric), 4) AS diverted_rate,  -- 备降率
    ROUND(AVG(is_arr_delayed::numeric), 4) AS arr_delay_rate,  -- 到达延误占比（>0分钟）
    ROUND(AVG(is_arr_delayed_15_plus::numeric), 4) AS arr_delay_15_plus_rate  -- 到达严重延误占比（>=15分钟）
FROM clean.flights_ontime_2025_01;


-- =========================================================
-- 2. 航司 KPI 排名
-- =========================================================
SELECT
    reporting_airline,           -- 航司代码
    flight_cnt,                  -- 航班量
    avg_arr_delay,               -- 平均到达延误分钟数
    avg_dep_delay,               -- 平均出发延误分钟数
    cancel_rate,                 -- 取消率
    diverted_rate,               -- 备降率
    arr_delay_rate,              -- 到达延误占比
    arr_delay_15_plus_rate,      -- 到达严重延误占比
    dep_delay_rate,              -- 出发延误占比
    dep_delay_15_plus_rate       -- 出发严重延误占比
FROM mart.airline_kpi_2025_01
ORDER BY arr_delay_15_plus_rate DESC, avg_arr_delay DESC;


-- =========================================================
-- 3. 高延误机场（样本量较大）
-- =========================================================
SELECT
    origin,                      -- 出发机场三字码
    flight_cnt,                  -- 航班量
    avg_arr_delay,               -- 平均到达延误分钟数
    avg_dep_delay,               -- 平均出发延误分钟数
    cancel_rate,                 -- 取消率
    diverted_rate,               -- 备降率
    arr_delay_rate,              -- 到达延误占比
    arr_delay_15_plus_rate       -- 到达严重延误占比
FROM mart.airport_kpi_2025_01
WHERE flight_cnt >= 3000         -- 只看航班量较大的机场，避免小样本波动过大
ORDER BY arr_delay_15_plus_rate DESC, avg_arr_delay DESC
LIMIT 20;


-- =========================================================
-- 4. 航司延误原因总量排名
-- =========================================================
SELECT
    reporting_airline,           -- 航司代码
    flight_cnt,                  -- 非取消航班量
    carrier_delay_total,         -- 航司自身原因延误总分钟数
    weather_delay_total,         -- 天气原因延误总分钟数
    nas_delay_total,             -- NAS原因延误总分钟数
    security_delay_total,        -- 安检/安全原因延误总分钟数
    late_aircraft_delay_total,   -- 前序航班晚到原因延误总分钟数
    carrier_delay_avg,           -- 平均每班航司自身原因延误分钟数
    weather_delay_avg,           -- 平均每班天气原因延误分钟数
    nas_delay_avg,               -- 平均每班NAS原因延误分钟数
    security_delay_avg,          -- 平均每班安检/安全原因延误分钟数
    late_aircraft_delay_avg      -- 平均每班前序晚到原因延误分钟数
FROM mart.delay_cause_by_airline_2025_01
ORDER BY late_aircraft_delay_total DESC;


-- =========================================================
-- 5. 航司延误原因占比
-- =========================================================
SELECT
    reporting_airline,           -- 航司代码
    flight_cnt,                  -- 非取消航班量
    total_delay_cause_minutes,   -- 五类延误原因总分钟数
    carrier_delay_share,         -- 航司自身原因占比
    weather_delay_share,         -- 天气原因占比
    nas_delay_share,             -- NAS原因占比
    security_delay_share,        -- 安检/安全原因占比
    late_aircraft_delay_share    -- 前序航班晚到原因占比
FROM mart.delay_cause_share_by_airline_2025_01
ORDER BY late_aircraft_delay_share DESC, carrier_delay_share DESC;


-- =========================================================
-- 6. 航司主导延误原因标签
-- =========================================================
SELECT
    reporting_airline,           -- 航司代码
    flight_cnt,                  -- 非取消航班量
    carrier_delay_share,         -- 航司自身原因占比
    weather_delay_share,         -- 天气原因占比
    nas_delay_share,             -- NAS原因占比
    security_delay_share,        -- 安检/安全原因占比
    late_aircraft_delay_share,   -- 前序航班晚到原因占比
    CASE
        WHEN late_aircraft_delay_share >= carrier_delay_share
         AND late_aircraft_delay_share >= weather_delay_share
         AND late_aircraft_delay_share >= nas_delay_share
         AND late_aircraft_delay_share >= security_delay_share
            THEN 'late_aircraft_dominant'
        WHEN carrier_delay_share >= weather_delay_share
         AND carrier_delay_share >= nas_delay_share
         AND carrier_delay_share >= security_delay_share
            THEN 'carrier_dominant'
        WHEN nas_delay_share >= weather_delay_share
         AND nas_delay_share >= security_delay_share
            THEN 'nas_dominant'
        WHEN weather_delay_share >= security_delay_share
            THEN 'weather_dominant'
        ELSE 'security_dominant'
    END AS dominant_delay_cause  -- 该航司最主要的延误驱动类型
FROM mart.delay_cause_share_by_airline_2025_01
ORDER BY reporting_airline;


-- =========================================================
-- 7. 航司风险分类结果
-- =========================================================
SELECT
    reporting_airline,           -- 航司代码
    flight_cnt,                  -- 航班量
    cancel_rate,                 -- 取消率
    arr_delay_15_plus_rate,      -- 到达严重延误占比
    risk_type                    -- 风险类型
FROM mart.airline_risk_profile_2025_01
ORDER BY
    CASE risk_type
        WHEN 'dual_high_risk' THEN 1
        WHEN 'cancel_risk' THEN 2
        WHEN 'delay_risk' THEN 3
        ELSE 4
    END,
    cancel_rate DESC,
    arr_delay_15_plus_rate DESC;


-- =========================================================
-- 8. 机场风险分类结果
-- =========================================================
SELECT
    origin,                      -- 出发机场三字码
    flight_cnt,                  -- 航班量
    cancel_rate,                 -- 取消率
    arr_delay_15_plus_rate,      -- 到达严重延误占比
    risk_type                    -- 风险类型
FROM mart.airport_risk_profile_2025_01
WHERE flight_cnt >= 3000         -- 只看样本量足够的机场
ORDER BY
    CASE risk_type
        WHEN 'dual_high_risk' THEN 1
        WHEN 'cancel_risk' THEN 2
        WHEN 'delay_risk' THEN 3
        ELSE 4
    END,
    cancel_rate DESC,
    arr_delay_15_plus_rate DESC
LIMIT 30;


-- =========================================================
-- 9. 高频航线
-- =========================================================
SELECT
    origin,                      -- 出发机场
    dest,                        -- 到达机场
    flight_cnt,                  -- 航班量
    avg_arr_delay,               -- 平均到达延误分钟数
    cancel_rate,                 -- 取消率
    arr_delay_15_plus_rate       -- 到达严重延误占比
FROM mart.route_kpi_2025_01
ORDER BY flight_cnt DESC
LIMIT 30;


-- =========================================================
-- 10. 高风险航线
-- =========================================================
SELECT
    origin,                      -- 出发机场
    dest,                        -- 到达机场
    flight_cnt,                  -- 航班量
    cancel_rate,                 -- 取消率
    arr_delay_15_plus_rate,      -- 到达严重延误占比
    risk_type                    -- 航线风险类型
FROM mart.route_risk_profile_2025_01
WHERE flight_cnt >= 200          -- 只看样本量足够的航线
ORDER BY
    CASE risk_type
        WHEN 'dual_high_risk' THEN 1
        WHEN 'cancel_risk' THEN 2
        WHEN 'delay_risk' THEN 3
        ELSE 4
    END,
    cancel_rate DESC,
    arr_delay_15_plus_rate DESC
LIMIT 50;


-- =========================================================
-- 11. 高频且高延误航线
-- =========================================================
SELECT
    origin,                      -- 出发机场
    dest,                        -- 到达机场
    flight_cnt,                  -- 航班量
    avg_arr_delay,               -- 平均到达延误分钟数
    cancel_rate,                 -- 取消率
    arr_delay_15_plus_rate       -- 到达严重延误占比
FROM mart.route_kpi_2025_01
WHERE flight_cnt >= 500          -- 高频航线门槛
ORDER BY arr_delay_15_plus_rate DESC, avg_arr_delay DESC
LIMIT 30;


-- =========================================================
-- 12. 数据库状态检查
-- =========================================================
SELECT current_database();  -- 当前数据库名

SELECT COUNT(*) AS raw_row_count
FROM raw.flights_ontime_2025_01;

SELECT COUNT(*) AS clean_row_count
FROM clean.flights_ontime_2025_01;

SELECT COUNT(*) AS airline_kpi_row_count
FROM mart.airline_kpi_2025_01;

SELECT COUNT(*) AS airport_kpi_row_count
FROM mart.airport_kpi_2025_01;

SELECT COUNT(*) AS delay_cause_row_count
FROM mart.delay_cause_by_airline_2025_01;

SELECT COUNT(*) AS delay_cause_share_row_count
FROM mart.delay_cause_share_by_airline_2025_01;

SELECT COUNT(*) AS airline_risk_row_count
FROM mart.airline_risk_profile_2025_01;

SELECT COUNT(*) AS airport_risk_row_count
FROM mart.airport_risk_profile_2025_01;

SELECT COUNT(*) AS route_kpi_row_count
FROM mart.route_kpi_2025_01;

SELECT COUNT(*) AS route_risk_row_count
FROM mart.route_risk_profile_2025_01;