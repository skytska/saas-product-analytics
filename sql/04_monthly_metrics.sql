-----------------------------------------------------------------------------------------------------------------------------------
-- 4. Monthly Metrics --
-----------------------------------------------------------------------------------------------------------------------------------

-- GOAL:
-- calculate monthly revenue, active users, ARPU, churn rate, LTV, CAC, payback period
-----------------------------------------------------------------------------------------------------------------------------------


-- Drop table if exists
DROP TABLE IF EXISTS analytics.monthly_metrics;

-- Create metrics table
CREATE TABLE analytics.monthly_metrics AS

WITH revenue AS (

    -- Monthly revenue by channel
    SELECT
        month,
        channel,

        COUNT(DISTINCT account_id) AS active_users,

        SUM(revenue) AS total_revenue

    FROM analytics.fact_revenue_monthly
    GROUP BY 1,2
),

churned AS (

    -- Churned users by month and channel
    SELECT
        DATE_TRUNC('month', end_date)::date AS month,
        channel,

        COUNT(DISTINCT account_id) AS churned_users

    FROM analytics.fact_subscriptions
    WHERE end_date IS NOT NULL
    GROUP BY 1,2
),

metrics AS (

    SELECT
        r.month,
        r.channel,

        r.active_users,
        r.total_revenue,

        COALESCE(c.churned_users, 0) AS churned_users,

        fc.cac,

        -- ARPU
        ROUND(
            r.total_revenue::numeric / NULLIF(r.active_users, 0),
            2
        ) AS arpu,

        -- Churn rate
        ROUND(
            COALESCE(c.churned_users, 0)::numeric
            / NULLIF(r.active_users, 0),
            4
        ) AS churn_rate

    FROM revenue r

    LEFT JOIN churned c
        ON r.month = c.month
        AND r.channel = c.channel

    LEFT JOIN analytics.fact_cac fc
        ON r.month = fc.month
        AND r.channel = fc.channel
)

SELECT
    month,
    channel,

    active_users,
    churned_users,

    ROUND(total_revenue::numeric, 2) AS total_revenue,

    arpu,
    churn_rate,

    cac,

    -- LTV
    ROUND(
        arpu / NULLIF(churn_rate, 0),
        2
    ) AS ltv,

    -- Payback period
    ROUND(
        cac / NULLIF(arpu, 0),
        2
    ) AS payback_period

FROM metrics;