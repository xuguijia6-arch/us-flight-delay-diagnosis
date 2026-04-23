-- mart layer: aggregated diagnostic tables
-- includes airline / airport / delay cause / risk profile / route level tables

-- mart layer: aggregated diagnostic tables
-- includes airline / airport / delay cause / risk profile / route level tables


-- =========================================================
-- 1. 航司 KPI 汇总表
-- =========================================================
DROP TABLE IF EXISTS mart.airline_kpi_2025_01;

CREATE TABLE mart.airline_kpi_2025_01 AS
SELECT
    reporting_airline,                               -- 航司代码
    COUNT(*) AS flight_cnt,                          -- 航班总量
    ROUND(AVG(arr_delay), 2) AS avg_arr_delay,       -- 平均到达延误分钟数
    ROUND(AVG(dep_delay), 2) AS avg_dep_delay,       -- 平均出发延误分钟数
    ROUND(AVG(is_cancelled::numeric), 4) AS cancel_rate,              -- 取消率
    ROUND(AVG(is_diverted::numeric), 4) AS diverted_rate,             -- 备降率
    ROUND(AVG(is_arr_delayed::numeric), 4) AS arr_delay_rate,         -- 到达延误占比（>0分钟）
    ROUND(AVG(is_arr_delayed_15_plus::numeric), 4) AS arr_delay_15_plus_rate, -- 到达严重延误占比（>=15分钟）
    ROUND(AVG(is_dep_delayed::numeric), 4) AS dep_delay_rate,         -- 出发延误占比（>0分钟）
    ROUND(AVG(is_dep_delayed_15_plus::numeric), 4) AS dep_delay_15_plus_rate, -- 出发严重延误占比（>=15分钟）
    ROUND(AVG(total_reported_delay_minutes), 2) AS avg_reported_delay_minutes  -- 平均每班五类延误原因分钟数之和
FROM clean.flights_ontime_2025_01
GROUP BY reporting_airline;


-- =========================================================
-- 2. 出发机场 KPI 汇总表
-- =========================================================
DROP TABLE IF EXISTS mart.airport_kpi_2025_01;

CREATE TABLE mart.airport_kpi_2025_01 AS
SELECT
    origin,                                          -- 出发机场三字码
    COUNT(*) AS flight_cnt,                          -- 该机场出发航班量
    ROUND(AVG(arr_delay), 2) AS avg_arr_delay,       -- 平均到达延误分钟数
    ROUND(AVG(dep_delay), 2) AS avg_dep_delay,       -- 平均出发延误分钟数
    ROUND(AVG(is_cancelled::numeric), 4) AS cancel_rate,              -- 取消率
    ROUND(AVG(is_diverted::numeric), 4) AS diverted_rate,             -- 备降率
    ROUND(AVG(is_arr_delayed::numeric), 4) AS arr_delay_rate,         -- 到达延误占比
    ROUND(AVG(is_arr_delayed_15_plus::numeric), 4) AS arr_delay_15_plus_rate -- 到达严重延误占比
FROM clean.flights_ontime_2025_01
GROUP BY origin;


-- =========================================================
-- 3. 航司延误原因总量表
-- =========================================================
DROP TABLE IF EXISTS mart.delay_cause_by_airline_2025_01;

CREATE TABLE mart.delay_cause_by_airline_2025_01 AS
SELECT
    reporting_airline,                               -- 航司代码
    COUNT(*) AS flight_cnt,                          -- 非取消航班量
    ROUND(SUM(carrier_delay_filled), 2) AS carrier_delay_total,       -- 航司自身原因延误总分钟数
    ROUND(SUM(weather_delay_filled), 2) AS weather_delay_total,       -- 天气原因延误总分钟数
    ROUND(SUM(nas_delay_filled), 2) AS nas_delay_total,               -- NAS原因延误总分钟数
    ROUND(SUM(security_delay_filled), 2) AS security_delay_total,     -- 安检/安全原因延误总分钟数
    ROUND(SUM(late_aircraft_delay_filled), 2) AS late_aircraft_delay_total, -- 前序航班晚到原因延误总分钟数
    ROUND(AVG(carrier_delay_filled), 2) AS carrier_delay_avg,         -- 平均每班航司自身原因延误分钟数
    ROUND(AVG(weather_delay_filled), 2) AS weather_delay_avg,         -- 平均每班天气原因延误分钟数
    ROUND(AVG(nas_delay_filled), 2) AS nas_delay_avg,                 -- 平均每班NAS原因延误分钟数
    ROUND(AVG(security_delay_filled), 2) AS security_delay_avg,       -- 平均每班安检/安全原因延误分钟数
    ROUND(AVG(late_aircraft_delay_filled), 2) AS late_aircraft_delay_avg -- 平均每班前序晚到原因延误分钟数
FROM clean.flights_ontime_2025_01
WHERE is_cancelled = 0                               -- 取消航班不参与延误原因统计
GROUP BY reporting_airline;


-- =========================================================
-- 4. 航司延误原因占比表
-- =========================================================
DROP TABLE IF EXISTS mart.delay_cause_share_by_airline_2025_01;

CREATE TABLE mart.delay_cause_share_by_airline_2025_01 AS
SELECT
    reporting_airline,  -- 航司代码
    COUNT(*) AS flight_cnt,  -- 非取消航班量

    ROUND(SUM(carrier_delay_filled), 2) AS carrier_delay_total,  -- 航司自身原因延误总分钟数
    ROUND(SUM(weather_delay_filled), 2) AS weather_delay_total,  -- 天气原因延误总分钟数
    ROUND(SUM(nas_delay_filled), 2) AS nas_delay_total,  -- NAS原因延误总分钟数
    ROUND(SUM(security_delay_filled), 2) AS security_delay_total,  -- 安检/安全原因延误总分钟数
    ROUND(SUM(late_aircraft_delay_filled), 2) AS late_aircraft_delay_total,  -- 前序航班晚到原因延误总分钟数

    ROUND(
        SUM(carrier_delay_filled)
      + SUM(weather_delay_filled)
      + SUM(nas_delay_filled)
      + SUM(security_delay_filled)
      + SUM(late_aircraft_delay_filled)
    , 2) AS total_delay_cause_minutes,  -- 五类原因延误分钟数总和

    ROUND(
        SUM(carrier_delay_filled) /
        NULLIF(
            SUM(carrier_delay_filled)
          + SUM(weather_delay_filled)
          + SUM(nas_delay_filled)
          + SUM(security_delay_filled)
          + SUM(late_aircraft_delay_filled)
        , 0)
    , 4) AS carrier_delay_share,  -- 航司自身原因占比

    ROUND(
        SUM(weather_delay_filled) /
        NULLIF(
            SUM(carrier_delay_filled)
          + SUM(weather_delay_filled)
          + SUM(nas_delay_filled)
          + SUM(security_delay_filled)
          + SUM(late_aircraft_delay_filled)
        , 0)
    , 4) AS weather_delay_share,  -- 天气原因占比

    ROUND(
        SUM(nas_delay_filled) /
        NULLIF(
            SUM(carrier_delay_filled)
          + SUM(weather_delay_filled)
          + SUM(nas_delay_filled)
          + SUM(security_delay_filled)
          + SUM(late_aircraft_delay_filled)
        , 0)
    , 4) AS nas_delay_share,  -- NAS原因占比

    ROUND(
        SUM(security_delay_filled) /
        NULLIF(
            SUM(carrier_delay_filled)
          + SUM(weather_delay_filled)
          + SUM(nas_delay_filled)
          + SUM(security_delay_filled)
          + SUM(late_aircraft_delay_filled)
        , 0)
    , 4) AS security_delay_share,  -- 安检/安全原因占比

    ROUND(
        SUM(late_aircraft_delay_filled) /
        NULLIF(
            SUM(carrier_delay_filled)
          + SUM(weather_delay_filled)
          + SUM(nas_delay_filled)
          + SUM(security_delay_filled)
          + SUM(late_aircraft_delay_filled)
        , 0)
    , 4) AS late_aircraft_delay_share  -- 前序航班晚到原因占比
FROM clean.flights_ontime_2025_01
WHERE is_cancelled = 0  -- 取消航班不参与延误原因分钟占比统计
GROUP BY reporting_airline;


-- =========================================================
-- 5. 航司风险分类表
-- =========================================================
DROP TABLE IF EXISTS mart.airline_risk_profile_2025_01;

CREATE TABLE mart.airline_risk_profile_2025_01 AS
SELECT
    reporting_airline,  -- 航司代码
    flight_cnt,  -- 航班量
    avg_arr_delay,  -- 平均到达延误分钟数
    avg_dep_delay,  -- 平均出发延误分钟数
    cancel_rate,  -- 取消率
    diverted_rate,  -- 备降率
    arr_delay_rate,  -- 到达延误占比
    arr_delay_15_plus_rate,  -- 到达严重延误占比（>=15分钟）
    dep_delay_rate,  -- 出发延误占比
    dep_delay_15_plus_rate,  -- 出发严重延误占比（>=15分钟）

    CASE
        WHEN cancel_rate >= 0.05 AND arr_delay_15_plus_rate >= 0.20
            THEN 'dual_high_risk'      -- 取消率高 + 严重延误率高
        WHEN cancel_rate >= 0.05
            THEN 'cancel_risk'         -- 取消型风险
        WHEN arr_delay_15_plus_rate >= 0.20
            THEN 'delay_risk'          -- 延误型风险
        ELSE 'relatively_stable'       -- 相对稳定
    END AS risk_type  -- 风险类型标签

FROM mart.airline_kpi_2025_01;


-- =========================================================
-- 6. 机场风险分类表
-- =========================================================
DROP TABLE IF EXISTS mart.airport_risk_profile_2025_01;

CREATE TABLE mart.airport_risk_profile_2025_01 AS
SELECT
    origin,  -- 出发机场三字码
    flight_cnt,  -- 航班量
    avg_arr_delay,  -- 平均到达延误分钟数
    avg_dep_delay,  -- 平均出发延误分钟数
    cancel_rate,  -- 取消率
    diverted_rate,  -- 备降率
    arr_delay_rate,  -- 到达延误占比
    arr_delay_15_plus_rate,  -- 到达严重延误占比

    CASE
        WHEN flight_cnt < 3000
            THEN 'small_sample'        -- 样本量较小，单独标记
        WHEN cancel_rate >= 0.03 AND arr_delay_15_plus_rate >= 0.20
            THEN 'dual_high_risk'      -- 取消率高 + 严重延误率高
        WHEN cancel_rate >= 0.03
            THEN 'cancel_risk'         -- 取消型风险
        WHEN arr_delay_15_plus_rate >= 0.20
            THEN 'delay_risk'          -- 延误型风险
        ELSE 'relatively_stable'       -- 相对稳定
    END AS risk_type  -- 风险类型标签

FROM mart.airport_kpi_2025_01;


-- =========================================================
-- 7. 航线 KPI 表
-- =========================================================
DROP TABLE IF EXISTS mart.route_kpi_2025_01;

CREATE TABLE mart.route_kpi_2025_01 AS
SELECT
    origin,  -- 出发机场三字码
    dest,  -- 到达机场三字码
    COUNT(*) AS flight_cnt,  -- 该航线航班量
    ROUND(AVG(arr_delay), 2) AS avg_arr_delay,  -- 平均到达延误分钟数
    ROUND(AVG(dep_delay), 2) AS avg_dep_delay,  -- 平均出发延误分钟数
    ROUND(AVG(is_cancelled::numeric), 4) AS cancel_rate,  -- 取消率
    ROUND(AVG(is_diverted::numeric), 4) AS diverted_rate,  -- 备降率
    ROUND(AVG(is_arr_delayed::numeric), 4) AS arr_delay_rate,  -- 到达延误占比
    ROUND(AVG(is_arr_delayed_15_plus::numeric), 4) AS arr_delay_15_plus_rate,  -- 到达严重延误占比
    ROUND(AVG(is_dep_delayed::numeric), 4) AS dep_delay_rate,  -- 出发延误占比
    ROUND(AVG(is_dep_delayed_15_plus::numeric), 4) AS dep_delay_15_plus_rate  -- 出发严重延误占比
FROM clean.flights_ontime_2025_01
GROUP BY origin, dest;


-- =========================================================
-- 8. 航线风险分类表
-- =========================================================
DROP TABLE IF EXISTS mart.route_risk_profile_2025_01;

CREATE TABLE mart.route_risk_profile_2025_01 AS
SELECT
    origin,  -- 出发机场
    dest,  -- 到达机场
    flight_cnt,  -- 航班量
    avg_arr_delay,  -- 平均到达延误分钟数
    avg_dep_delay,  -- 平均出发延误分钟数
    cancel_rate,  -- 取消率
    diverted_rate,  -- 备降率
    arr_delay_rate,  -- 到达延误占比
    arr_delay_15_plus_rate,  -- 到达严重延误占比
    dep_delay_rate,  -- 出发延误占比
    dep_delay_15_plus_rate,  -- 出发严重延误占比

    CASE
        WHEN flight_cnt < 200
            THEN 'small_sample'        -- 样本量较小，单独标记
        WHEN cancel_rate >= 0.03 AND arr_delay_15_plus_rate >= 0.20
            THEN 'dual_high_risk'      -- 高取消 + 高严重延误
        WHEN cancel_rate >= 0.03
            THEN 'cancel_risk'         -- 取消型风险
        WHEN arr_delay_15_plus_rate >= 0.20
            THEN 'delay_risk'          -- 延误型风险
        ELSE 'relatively_stable'       -- 相对稳定
    END AS risk_type  -- 航线风险类型标签

FROM mart.route_kpi_2025_01;