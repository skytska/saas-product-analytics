-- =========================================================
-- 07_mart_plan_revenue.sql
-- =========================================================
-- Goal:
-- Prepare a monthly revenue layer by subscription plan
-- to support analysis of revenue concentration,
-- customer distribution, and business dependency
-- across pricing tiers.
--
-- This mart expands recurring subscription revenue
-- into monthly periods and preserves account-level
-- granularity in order to support dynamic customer
-- and revenue calculations in Tableau dashboards.
-- =========================================================

DROP TABLE IF EXISTS analytics.mart_plan_revenue; 

CREATE TABLE analytics.mart_plan_revenue AS

SELECT
    fr.month,
    fs.plan_tier,

    fr.revenue,
    fr.account_id 

FROM analytics.fact_revenue_monthly fr

LEFT JOIN analytics.fact_subscriptions fs
    ON fr.subscription_id = fs.subscription_id;
