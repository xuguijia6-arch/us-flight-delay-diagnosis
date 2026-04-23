-- sample 表：用于最小导入测试
DROP TABLE IF EXISTS raw.flights_sample;

CREATE TABLE raw.flights_sample (
    flight_date DATE,                    -- 航班日期
    carrier TEXT,                        -- 航司代码
    flight_num INTEGER,                  -- 航班号
    origin TEXT,                         -- 出发机场
    dest TEXT,                           -- 到达机场
    crs_dep_time INTEGER,                -- 计划出发时间
    dep_time INTEGER,                    -- 实际出发时间
    dep_delay NUMERIC,                   -- 出发延误分钟数
    crs_arr_time INTEGER,                -- 计划到达时间
    arr_time INTEGER,                    -- 实际到达时间
    arr_delay NUMERIC,                   -- 到达延误分钟数
    cancelled INTEGER,                   -- 是否取消
    cancellation_code TEXT,              -- 取消原因代码
    diverted INTEGER,                    -- 是否备降
    carrier_delay NUMERIC,               -- 航司自身原因延误
    weather_delay NUMERIC,               -- 天气原因延误
    nas_delay NUMERIC,                   -- NAS原因延误
    security_delay NUMERIC,              -- 安检/安全原因延误
    late_aircraft_delay NUMERIC          -- 前序航班晚到原因延误
);

-- 正式 raw 表：2025-01 航班数据
DROP TABLE IF EXISTS raw.flights_ontime_2025_01;

CREATE TABLE raw.flights_ontime_2025_01 (
    flight_date DATE,                           -- 航班日期
    reporting_airline TEXT,                     -- 航司代码
    flight_number_reporting_airline INTEGER,    -- 航班号
    origin TEXT,                                -- 出发机场
    dest TEXT,                                  -- 到达机场
    crs_dep_time INTEGER,                       -- 计划出发时间
    dep_time INTEGER,                           -- 实际出发时间
    dep_delay NUMERIC,                          -- 出发延误分钟数
    crs_arr_time INTEGER,                       -- 计划到达时间
    arr_time INTEGER,                           -- 实际到达时间
    arr_delay NUMERIC,                          -- 到达延误分钟数
    cancelled NUMERIC,                          -- 是否取消
    cancellation_code TEXT,                     -- 取消原因代码
    diverted NUMERIC,                           -- 是否备降
    carrier_delay NUMERIC,                      -- 航司自身原因延误分钟数
    weather_delay NUMERIC,                      -- 天气原因延误分钟数
    nas_delay NUMERIC,                          -- NAS原因延误分钟数
    security_delay NUMERIC,                     -- 安检/安全原因延误分钟数
    late_aircraft_delay NUMERIC                 -- 前序航班晚到原因延误分钟数
);

-- 正式数据导入使用 psql \copy，在 PowerShell 中执行，不在 pgAdmin 中执行
-- \copy raw.flights_ontime_2025_01
-- FROM 'C:\Users\18217\flight_delay_lab\data\flights_ontime_2025_01_trimmed_ansi.csv'
-- WITH (FORMAT csv, HEADER true, DELIMITER ',', NULL '', FORCE_NULL (dep_time, dep_delay, arr_time, arr_delay, cancellation_code, carrier_delay, weather_delay, nas_delay, security_delay, late_aircraft_delay));