-- =========================================================
-- 08_calendar.sql
-- =========================================================
-- Goal:
-- Create a centralized calendar dimension table
-- to support consistent date filtering, time-based analysis,
-- and Tableau relationship modeling across all analytics marts.
--
-- This table provides a shared monthly date spine for
-- revenue, acquisition, retention, and product engagement
-- dashboards.
-- =========================================================

DROP TABLE IF EXISTS analytics.calendar;

CREATE TABLE analytics.calendar AS

SELECT
    generate_series(
        DATE '2023-01-01',
        DATE '2024-12-01',
        INTERVAL '1 month'
    )::date AS month;