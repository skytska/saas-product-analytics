
-- =========================================================
-- 06_feature_engagement.sql
-- =========================================================
-- Goal:
-- Prepare a product engagement layer for behavioral analysis.
--
-- This table aggregates feature usage activity at the
-- subscription level and combines it with churn and revenue
-- information to analyze the relationship between engagement,
-- monetization, and retention.
-- =========================================================

DROP TABLE IF EXISTS analytics.feature_engagement;

CREATE TABLE analytics.feature_engagement AS

WITH usage_agg AS (

    SELECT
        DATE_TRUNC('month', fu.usage_date)::date AS usage_month,

        fu.subscription_id,

        COUNT(*) AS usage_events,

        SUM(fu.usage_count) AS total_usage_count,

        SUM(fu.usage_duration_secs) AS total_usage_duration_secs,

        AVG(fu.usage_duration_secs) AS avg_usage_duration_secs,

        SUM(fu.error_count) AS total_error_count,

        COUNT(DISTINCT fu.feature_name) AS unique_features_used,

        MAX(
            CASE
                WHEN fu.is_beta_feature = TRUE THEN 1
                ELSE 0
            END
        ) AS used_beta_feature

    FROM raw.feature_usage_clean fu

    GROUP BY 1,2
),

base_table AS (

    SELECT
        ua.usage_month,

        fs.subscription_id,
        fs.account_id,

        fs.plan_tier,
        fs.channel,
        fs.billing_frequency,
        fs.is_trial,

        -- Revenue metrics
        COALESCE(fs.mrr_amount, 0) AS mrr_amount,

        CASE
    	WHEN fs.churn_flag = TRUE THEN 'Churned'
    	ELSE 'Active'
		END AS customer_status,

        -- Usage metrics
        ua.usage_events,
        ua.total_usage_count,
        ua.total_usage_duration_secs,
        ua.avg_usage_duration_secs,

        ua.total_error_count,
        ua.unique_features_used,

        ua.used_beta_feature,

        -- Retention
        fs.churn_flag,

        -- Engagement score
        ROUND(
            (
                COALESCE(ua.total_usage_count, 0) * 0.5
                +
                COALESCE(ua.unique_features_used, 0) * 10
                +
                COALESCE(ua.total_usage_duration_secs, 0) / 1000.0
            )::numeric,
            2
        ) AS engagement_score

    FROM usage_agg ua

    LEFT JOIN analytics.fact_subscriptions fs
        ON ua.subscription_id = fs.subscription_id
),

engagement_ranked AS (

    SELECT
        bt.*,

        NTILE(3) OVER (
            ORDER BY bt.engagement_score
        ) AS engagement_tier

    FROM base_table bt
)

SELECT
    *,

    CASE
        WHEN engagement_tier = 3 THEN 'High Engagement'
        WHEN engagement_tier = 2 THEN 'Medium Engagement'
        ELSE 'Low Engagement'
    END AS engagement_segment

FROM engagement_ranked;