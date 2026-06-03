
-----------------------------------------------------------------------------------------------------------------------------------
-- 1. Fact Subscriptions --
-----------------------------------------------------------------------------------------------------------------------------------

-- GOAL:
-- combine subscriptions (facts: revenue, lifecycle) with accounts (dimension: user, channel, signup) 
-- to get a single table for analyzing revenue, churn, LTV
-----------------------------------------------------------------------------------------------------------------------------------


-- Create schema for analytics layer (if not exists)
CREATE SCHEMA IF NOT EXISTS analytics;

-- Drop table if exists (for reruns)
DROP TABLE IF EXISTS analytics.fact_subscriptions;

-- Create fact table
CREATE TABLE analytics.fact_subscriptions AS

SELECT
    s.subscription_id,
    s.account_id,

    -- Dates
    s.start_date,
    s.end_date,

    -- Active flag
    CASE 
        WHEN s.end_date IS NULL THEN 1
        ELSE 0
    END AS is_active,

    -- Subscription attributes
    s.plan_tier,
    s.billing_frequency,
    s.seats,

    -- Revenue
    s.mrr_amount,
    s.arr_amount,

    -- Lifecycle flags
    s.is_trial,
    s.upgrade_flag,
    s.downgrade_flag,
    s.churn_flag,

    -- Account info
    a.signup_date,
    a.country,
    a.industry,

    -- Marketing
    a.channel

FROM raw.subscriptions_clean s
LEFT JOIN raw.accounts_clean a
    ON s.account_id = a.account_id;