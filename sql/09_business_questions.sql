/* =========================================================
   BUSINESS QUESTIONS & PRODUCT INSIGHTS
   Project: SaaS Product Analytics / Unit Economics
   Goal: Evaluate whether the subscription model is sustainable
========================================================= */


-- =========================================================
-- 1. Revenue Trend Over Time
-- =========================================================

SELECT
    month,
    ROUND(SUM(total_revenue)::numeric, 2) AS total_revenue,
    SUM(active_users) AS active_users,
    ROUND(AVG(arpu)::numeric, 2) AS avg_arpu

FROM analytics.monthly_metrics
GROUP BY 1
ORDER BY 1;

-- Business Question:
-- Is the business growing over time?
-- Are revenue and active users increasing consistently?

-- Insight:
-- The business demonstrates strong and consistent growth across the entire period.
-- Total revenue increased from $4.7K in January 2023 to $10.7M in December 2024,
-- while the number of active users grew steadily from 2 to 500 customers.

-- ARPU also increased significantly over time ($2.3K → $21.4K),
-- suggesting that revenue growth is driven not only by customer acquisition
-- but also by higher customer value and subscription expansion.

-- Overall, the trend indicates healthy SaaS scaling dynamics
-- with both user growth and monetization improving simultaneously.



-- =========================================================
-- 2. Revenue by Acquisition Channel
-- =========================================================

SELECT
    channel,

    ROUND(SUM(total_revenue)::numeric, 2) AS total_revenue,

    ROUND(AVG(arpu)::numeric, 2) AS avg_arpu,

    ROUND(AVG(cac)::numeric, 2) AS avg_cac,

    ROUND(AVG(ltv)::numeric, 2) AS avg_ltv,

    ROUND(AVG(ltv / NULLIF(cac,0))::numeric, 2) AS ltv_cac_ratio

FROM analytics.monthly_metrics
GROUP BY 1
ORDER BY total_revenue DESC;

-- Business Question:
-- Which acquisition channels generate the highest value?

-- Insight:
-- Organic acquisition demonstrates the strongest unit economics performance.
-- Despite generating slightly lower total revenue than paid channels,
-- it has by far the lowest CAC and the highest LTV/CAC ratio (446.6),
-- making it the most efficient and scalable acquisition source.

-- Paid Ads generate high total revenue but also have the highest CAC,
-- resulting in significantly weaker acquisition efficiency.

-- Overall, all channels maintain LTV > CAC,
-- indicating that the subscription model remains economically sustainable across acquisition sources.


-- =========================================================
-- 3. Channel Performance Trend
-- =========================================================

SELECT
    month,
    channel,

    ROUND(SUM(total_revenue)::numeric, 2) AS total_revenue,

    ROUND(AVG(cac)::numeric, 2) AS avg_cac,

    ROUND(AVG(ltv)::numeric, 2) AS avg_ltv

FROM analytics.monthly_metrics
GROUP BY 1,2
ORDER BY 1,2;

-- Business Question:
-- How does channel performance change over time?

-- Insight:
-- Revenue grows consistently across all acquisition channels throughout the analysis period,
-- indicating stable business expansion rather than dependence on a single source of growth.

-- Organic traffic demonstrates the most efficient acquisition dynamics over time:
-- despite relatively low CAC, it scales revenue rapidly and consistently.

-- Paid Ads generate strong revenue growth but with significantly higher and more volatile CAC,
-- suggesting that scaling paid acquisition may become increasingly expensive.

-- Several channels show periods of rising CAC without proportional LTV growth,
-- which may indicate declining acquisition efficiency in later stages of scaling.

-- Overall, channel diversification appears healthy,
-- reducing dependency risk on a single acquisition source.



-- =========================================================
-- 4. Churn Trend Analysis
-- =========================================================

SELECT
    month,

    SUM(churned_users) AS churned_users,

    ROUND(AVG(churn_rate)::numeric, 4) AS avg_churn_rate

FROM analytics.monthly_metrics
GROUP BY 1
ORDER BY 1;

-- Business Question:
-- Is churn improving or worsening over time?

-- Insight:
-- Churn remained relatively low and stable throughout most of the analysis period,
-- generally below 5%, indicating healthy early-stage retention dynamics.

-- However, churn accelerated significantly during the second half of 2024,
-- reaching nearly 29% in December 2024.

-- The sharp increase in churn may indicate:
-- - customer retention issues,
-- - market saturation,
-- - lower acquisition quality at scale,
-- - or cohort aging effects.

-- This trend represents the main potential risk to long-term subscription sustainability
-- and should become a key focus area for further product and retention analysis.


-- =========================================================
-- 5. Churn by Acquisition Channel
-- =========================================================

SELECT
    channel,

    ROUND(AVG(churn_rate)::numeric, 4) AS avg_churn_rate,

    ROUND(AVG(ltv)::numeric, 2) AS avg_ltv,

    ROUND(AVG(cac)::numeric, 2) AS avg_cac

FROM analytics.monthly_metrics
GROUP BY 1
ORDER BY avg_churn_rate DESC;

-- Business Question:
-- Which acquisition channels have the weakest retention?

-- Insight:
-- Churn rates remain relatively close across acquisition channels,
-- suggesting that no single channel demonstrates critically poor retention quality.

-- Organic traffic combines comparatively low churn with the lowest CAC,
-- reinforcing its position as the most efficient acquisition source.

-- Paid Ads and Events show the highest churn rates together with elevated CAC,
-- indicating weaker acquisition efficiency and potentially lower-quality users.

-- The "other" channel demonstrates the lowest churn and the highest average LTV,
-- which may suggest the presence of valuable customers acquired through mixed or untracked sources.


-- =========================================================
-- 6. Revenue Concentration by Plan
-- =========================================================

SELECT
    plan_tier,

    COUNT(DISTINCT account_id) AS customers,

    ROUND(SUM(mrr_amount)::numeric, 2) AS total_mrr,

    ROUND(AVG(mrr_amount)::numeric, 2) AS avg_mrr

FROM analytics.fact_subscriptions
GROUP BY 1
ORDER BY total_mrr DESC;

-- Business Question:
-- Which subscription plans generate the most revenue?

-- Insight:
-- Enterprise subscriptions generate the vast majority of total revenue,
-- despite a customer count similar to other plan tiers.

-- Average MRR for Enterprise customers ($4.9K) is significantly higher
-- than Pro ($1.3K) and Basic ($475),
-- indicating strong revenue concentration among high-value accounts.

-- The business appears heavily dependent on Enterprise customers,
-- making enterprise retention and expansion critical for long-term revenue stability.



-- =========================================================
-- 7. Billing Frequency Analysis
-- =========================================================

SELECT
    billing_frequency,

    COUNT(DISTINCT account_id) AS customers,

    ROUND(AVG(mrr_amount)::numeric, 2) AS avg_mrr,

    ROUND(AVG(churn_flag::int)::numeric, 4) AS churn_rate

FROM analytics.fact_subscriptions
GROUP BY 1;

-- Business Question:
-- Are annual subscriptions healthier than monthly plans?

-- Insight:
-- Monthly and annual subscriptions demonstrate very similar monetization patterns,
-- with nearly identical average MRR levels.

-- Churn rates are also relatively close across billing frequencies,
-- suggesting that annual billing does not currently provide a strong retention advantage.

-- This may indicate that customer retention is driven more by product value
-- and engagement than by billing structure alone.



-- =========================================================
-- 8. Unit Economics Sustainability
-- =========================================================

SELECT
    channel,

    ROUND(AVG(cac)::numeric, 2) AS avg_cac,

    ROUND(AVG(ltv)::numeric, 2) AS avg_ltv,

    ROUND(AVG(ltv / NULLIF(cac,0))::numeric, 2) AS ltv_cac_ratio,

    ROUND(AVG(payback_period)::numeric, 2) AS avg_payback_period

FROM analytics.monthly_metrics
GROUP BY 1
ORDER BY ltv_cac_ratio DESC;

-- Business Question:
-- Is the subscription business economically sustainable?

-- Insight:
-- All acquisition channels demonstrate positive unit economics,
-- with LTV significantly exceeding CAC across the board.

-- Organic acquisition is by far the most efficient channel:
-- it has the lowest CAC, the highest LTV/CAC ratio,
-- and the fastest payback period (~0.25 months).

-- Paid Ads show the weakest efficiency metrics,
-- with the highest CAC and the slowest payback period (2.17 months),
-- suggesting that aggressive paid scaling may reduce profitability over time.

-- Overall, the subscription model appears economically sustainable,
-- particularly when growth is driven by lower-cost acquisition channels.



-- =========================================================
-- 9. Best and Worst Performing Months
-- =========================================================

SELECT
    month,

    ROUND(SUM(total_revenue)::numeric, 2) AS revenue,

    ROUND(AVG(churn_rate)::numeric, 4) AS churn_rate,

    ROUND(AVG(ltv / NULLIF(cac,0))::numeric, 2) AS ltv_cac_ratio

FROM analytics.monthly_metrics
GROUP BY 1
ORDER BY revenue DESC;

-- Business Question:
-- Which periods demonstrate the strongest business performance?

-- Insight:
-- The business achieved strong and accelerating revenue growth throughout the analysis period,
-- reaching peak revenue levels in late 2024.

-- However, higher revenue in the final months is accompanied by rapidly increasing churn,
-- particularly in Q4 2024, where churn rose to nearly 30%.

-- At the same time, LTV/CAC efficiency became more volatile,
-- with a noticeable decline in December 2024 compared to earlier peak periods.

-- This suggests that while the company is scaling aggressively,
-- growth quality may be deteriorating due to weaker retention
-- and potentially more expensive or lower-quality customer acquisition.


-- =========================================================
-- 10. Executive Summary Dataset
-- =========================================================

SELECT
    ROUND(SUM(total_revenue)::numeric, 2) AS total_revenue,

    SUM(active_users) AS total_active_users,

    ROUND(AVG(arpu)::numeric, 2) AS avg_arpu,

    ROUND(AVG(churn_rate)::numeric, 4) AS avg_churn_rate,

    ROUND(AVG(cac)::numeric, 2) AS avg_cac,

    ROUND(AVG(ltv)::numeric, 2) AS avg_ltv,

    ROUND(AVG(ltv / NULLIF(cac,0))::numeric, 2) AS avg_ltv_cac_ratio,

    ROUND(AVG(payback_period)::numeric, 2) AS avg_payback_period

FROM analytics.monthly_metrics;

-- Business Question:
-- What is the overall health of the SaaS business?

-- Insight:
-- Overall business performance indicates strong subscription economics and rapid scaling dynamics.

-- The company generated more than $63M in total revenue
-- with an average ARPU of ~$8.5K and relatively moderate average churn (~4.9%).

-- Average LTV substantially exceeds CAC across the business,
-- resulting in a strong average LTV/CAC ratio (143x)
-- and a payback period below one month.

-- Overall, the subscription model appears highly profitable and economically sustainable,
-- although the recent increase in churn should be monitored closely as the business scales.