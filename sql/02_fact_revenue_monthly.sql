
-----------------------------------------------------------------------------------------------------------------------------------
-- 2. Revenue Monthly --
-----------------------------------------------------------------------------------------------------------------------------------

-- GOAL:
-- convert subscription (one row) to time series (monthly revenue)
-----------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS analytics.fact_revenue_monthly;

CREATE TABLE analytics.fact_revenue_monthly AS

WITH max_date AS (
    SELECT MAX(
        COALESCE(end_date, start_date)
    ) AS max_date
    FROM analytics.fact_subscriptions
),

expanded AS (
    SELECT
        fs.subscription_id,
        fs.account_id,
        fs.channel,
        fs.start_date,
        fs.end_date,
        fs.mrr_amount,

        generate_series(
            DATE_TRUNC('month', fs.start_date),
            DATE_TRUNC(
                'month',
                COALESCE(fs.end_date, md.max_date)
            ),
            INTERVAL '1 month'
        ) AS revenue_month

    FROM analytics.fact_subscriptions fs
    CROSS JOIN max_date md
)

SELECT
    subscription_id,
    account_id,
    channel,
    revenue_month::date AS month,
    mrr_amount AS revenue

FROM expanded;