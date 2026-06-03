-----------------------------------------------------------------------------------------------------------------------------------
-- 5. Data Mart --
-----------------------------------------------------------------------------------------------------------------------------------

-- GOAL:
-- final aggregation, formatting, derived KPIs, business segmentation
-----------------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS analytics.mart_unit_economics;

CREATE TABLE analytics.mart_unit_economics AS

SELECT
    month,
    channel,

    active_users,
    churned_users,

    total_revenue,

    arpu,
    churn_rate,

    cac,
    ltv,

    ROUND(
        ltv / NULLIF(cac,0),
        2
    ) AS ltv_cac_ratio,

    payback_period

FROM analytics.monthly_metrics;