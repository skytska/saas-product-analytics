-----------------------------------------------------------------------------------------------------------------------------------
-- 3. CAC --
-----------------------------------------------------------------------------------------------------------------------------------

-- GOAL:
-- prepare a standardized monthly CAC table in order to:
-- - join with revenue
-- - calculate payback
-- - do channel analysis
-----------------------------------------------------------------------------------------------------------------------------------


-- Drop table if exists
DROP TABLE IF EXISTS analytics.fact_cac;

-- Create CAC fact table
CREATE TABLE analytics.fact_cac AS

SELECT
    date AS month,

    channel,

    spend::numeric(12,2),

    new_users,

    CASE
        WHEN new_users > 0
        THEN ROUND(cac::numeric, 2)
        ELSE NULL
    END AS cac

FROM raw.cac_table;