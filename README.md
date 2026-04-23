# US Flight Delay Diagnosis & Attribution Analysis System

基于 PostgreSQL 和 BTS 官方美国航班数据的延误诊断与归因分析项目。

## 项目简介

本项目使用美国 BTS（Bureau of Transportation Statistics）官方航班准点数据，在 PostgreSQL 中完成原始数据导入、数据清洗、指标构建和多维分析。

项目重点不是简单做一个展示型仪表盘，而是通过 raw-clean-mart 三层建模，对航司、机场、航线和延误原因进行诊断分析，识别高风险对象，并给出更有解释力的分析结果。

## 数据来源

- 数据来源：BTS（Bureau of Transportation Statistics）美国官方航班准点数据
- 数据范围：2025 年 1 月
- 最终导入数据量：539,747 条航班记录

项目中主要使用了以下字段：
- `FlightDate`：航班日期
- `Reporting_Airline`：航司代码
- `Origin` / `Dest`：出发机场 / 到达机场
- `CRSDepTime` / `DepTime`：计划出发时间 / 实际出发时间
- `CRSArrTime` / `ArrTime`：计划到达时间 / 实际到达时间
- `DepDelay` / `ArrDelay`：出发 / 到达延误分钟数
- `Cancelled` / `Diverted`：取消 / 备降标记
- `CarrierDelay` / `WeatherDelay` / `NASDelay` / `SecurityDelay` / `LateAircraftDelay`：延误原因分钟数

## 技术栈

- PostgreSQL 17
- pgAdmin 4
- PowerShell
- SQL

## 项目分层

本项目采用 raw-clean-mart 三层结构：

- `raw`：原始导入数据
- `clean`：清洗后数据和衍生字段
- `mart`：面向分析的汇总表

主要表包括：

### raw 层
- `raw.flights_ontime_2025_01`

### clean 层
- `clean.flights_ontime_2025_01`

### mart 层
- `mart.airline_kpi_2025_01`
- `mart.airport_kpi_2025_01`
- `mart.delay_cause_by_airline_2025_01`
- `mart.delay_cause_share_by_airline_2025_01`
- `mart.airline_risk_profile_2025_01`
- `mart.airport_risk_profile_2025_01`
- `mart.route_kpi_2025_01`
- `mart.route_risk_profile_2025_01`

## 做了什么

本项目主要完成了以下工作：

1. 下载并整理 BTS 官方航班准点数据，选取 2025 年 1 月作为分析样本  
2. 在 PostgreSQL 中完成数据库、schema 和数据表创建  
3. 将原始宽表裁剪为核心分析字段，并导入 raw 层  
4. 在 clean 层完成空值处理、字段标准化和分析标签构建  
5. 在 mart 层构建航司、机场、航线、延误原因和风险分类汇总表  
6. 使用 SQL 完成航司、机场、航线和延误原因的多维诊断分析

## 解决了什么问题

在项目过程中，处理了多种真实数据分析中常见的问题：

- 原始 BTS 文件字段很多，不适合直接分析，因此先裁剪为核心字段
- 导入过程中遇到编码问题，处理了 UTF-8 / 本地环境不一致的情况
- 原始数据中的空字符串无法直接导入 numeric 字段，因此在导入和 clean 层分别处理了空值
- 使用 `psql \copy` 解决了 PostgreSQL 服务端直接读取本地文件的权限问题
- 通过 raw-clean-mart 分层，把原始明细数据整理成更适合分析和诊断的结构

## 主要分析结论

基于 2025 年 1 月航班数据，项目得到了一些初步结论：

- 总航班量为 539,747 条
- 取消率约为 3.02%
- 备降率约为 0.22%
- 到达延误率约为 31.89%
- 到达严重延误率（15 分钟及以上）约为 18.18%

进一步分析发现：

- 不同航司的延误表现存在明显差异
- 不同机场的风险类型也不同，可分为双高风险、取消型风险、延误型风险和相对稳定几类
- 多数航司的主要延误驱动因素是前序航班晚到传导（late aircraft delay）
- 少数航司更偏航司自身运营原因或 NAS 系统性原因
- 在航线层面，也识别出了一批高频且高延误、高取消的重点航线

## 项目价值

这个项目不仅展示了 SQL 查询能力，更完整体现了真实数据分析项目中的全流程能力，包括：

- 官方数据获取与整理
- PostgreSQL 数据库实践
- 数据清洗与问题排查
- raw-clean-mart 分层建模
- 多维度指标分析
- 延误归因与风险分类

## 项目目录结构

```text
flight_delay_lab/
├── README.md
├── sql/
│   ├── 01_setup.sql
│   ├── 02_raw_layer.sql
│   ├── 03_clean_layer.sql
│   ├── 04_mart_layer.sql
│   └── 05_analysis_queries.sql
├── data/
│   └── README_data_note.txt
└── outputs/
    └── screenshots/

