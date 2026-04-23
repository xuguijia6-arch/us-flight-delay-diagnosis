DROP TABLE IF EXISTS clean.flights_ontime_2025_01;

CREATE TABLE clean.flights_ontime_2025_01 AS
SELECT
    flight_date,  -- 航班日期
    reporting_airline,  -- 航司代码
    flight_number_reporting_airline,  -- 航班号
    origin,  -- 出发机场
    dest,  -- 到达机场
    crs_dep_time,  -- 计划出发时间
    dep_time,  -- 实际出发时间
    dep_delay,  -- 出发延误分钟数
    crs_arr_time,  -- 计划到达时间
    arr_time,  -- 实际到达时间
    arr_delay,  -- 到达延误分钟数
    cancelled,  -- 原始取消标记
    cancellation_code,  -- 取消原因代码
    diverted,  -- 原始备降标记
    carrier_delay,  -- 航司自身原因延误分钟数
    weather_delay,  -- 天气原因延误分钟数
    nas_delay,  -- NAS原因延误分钟数
    security_delay,  -- 安检/安全原因延误分钟数
    late_aircraft_delay,  -- 前序航班晚到原因延误分钟数

    CASE WHEN cancelled = 1 THEN 1 ELSE 0 END AS is_cancelled,  -- 是否取消
    CASE WHEN diverted = 1 THEN 1 ELSE 0 END AS is_diverted,  -- 是否备降
    CASE WHEN arr_delay > 0 THEN 1 ELSE 0 END AS is_arr_delayed,  -- 是否到达延误
    CASE WHEN arr_delay >= 15 THEN 1 ELSE 0 END AS is_arr_delayed_15_plus,  -- 是否到达严重延误
    CASE WHEN dep_delay > 0 THEN 1 ELSE 0 END AS is_dep_delayed,  -- 是否出发延误
    CASE WHEN dep_delay >= 15 THEN 1 ELSE 0 END AS is_dep_delayed_15_plus,  -- 是否出发严重延误

    CASE
        WHEN cancelled = 1 THEN 'cancelled'
        WHEN diverted = 1 THEN 'diverted'
        WHEN arr_delay >= 15 THEN 'arr_delay_15_plus'
        WHEN arr_delay > 0 THEN 'arr_delay_1_14'
        WHEN arr_delay <= 0 THEN 'on_time_or_early'
        ELSE 'unknown'
    END AS flight_status,  -- 航班状态标签

    COALESCE(carrier_delay, 0) AS carrier_delay_filled,  -- 补空后的航司自身原因延误
    COALESCE(weather_delay, 0) AS weather_delay_filled,  -- 补空后的天气原因延误
    COALESCE(nas_delay, 0) AS nas_delay_filled,  -- 补空后的NAS原因延误
    COALESCE(security_delay, 0) AS security_delay_filled,  -- 补空后的安检/安全原因延误
    COALESCE(late_aircraft_delay, 0) AS late_aircraft_delay_filled,  -- 补空后的前序晚到原因延误

    COALESCE(carrier_delay, 0)
    + COALESCE(weather_delay, 0)
    + COALESCE(nas_delay, 0)
    + COALESCE(security_delay, 0)
    + COALESCE(late_aircraft_delay, 0) AS total_reported_delay_minutes  -- 五类延误原因总分钟数
FROM raw.flights_ontime_2025_01;

CREATE INDEX IF NOT EXISTS idx_clean_flights_2025_01_flight_date
ON clean.flights_ontime_2025_01 (flight_date);

CREATE INDEX IF NOT EXISTS idx_clean_flights_2025_01_airline
ON clean.flights_ontime_2025_01 (reporting_airline);

CREATE INDEX IF NOT EXISTS idx_clean_flights_2025_01_origin
ON clean.flights_ontime_2025_01 (origin);

CREATE INDEX IF NOT EXISTS idx_clean_flights_2025_01_dest
ON clean.flights_ontime_2025_01 (dest);

CREATE INDEX IF NOT EXISTS idx_clean_flights_2025_01_route
ON clean.flights_ontime_2025_01 (origin, dest);