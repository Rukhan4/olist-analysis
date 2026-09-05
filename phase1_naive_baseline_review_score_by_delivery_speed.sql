-- NAIVE BASELINE: review score by delivery speed bucket
-- This is the UNADJUSTED answer — we haven't controlled for anything yet.
-- We'll come back to this exact question in Phase 4 with confounders controlled,
-- and compare the two answers side by side.
 WITH bucketed AS (
    SELECT
        CASE
            WHEN delivery_days IS NULL THEN 'not delivered'
            WHEN delivery_days <= 3 THEN '0-3 days'
            WHEN delivery_days <= 7 THEN '4-7 days'
            WHEN delivery_days <= 14 THEN '8-14 days'
            WHEN delivery_days <= 21 THEN '15-21 days'
            ELSE '22+ days'
        END AS delivery_bucket,
        CASE
            WHEN delivery_days IS NULL THEN 6
            WHEN delivery_days <= 3 THEN 1
            WHEN delivery_days <= 7 THEN 2
            WHEN delivery_days <= 14 THEN 3
            WHEN delivery_days <= 21 THEN 4
            ELSE 5
        END AS bucket_sort,
        review_score,
        is_late
    FROM order_features
    WHERE review_score IS NOT NULL
)
SELECT
    delivery_bucket,
    COUNT(*) AS num_orders,
    ROUND(AVG(review_score), 2) AS avg_review_score,
    ROUND(AVG(CASE WHEN is_late THEN 1.0 ELSE 0.0 END) * 100, 1) AS pct_late
FROM bucketed
GROUP BY delivery_bucket, bucket_sort
ORDER BY bucket_sort;