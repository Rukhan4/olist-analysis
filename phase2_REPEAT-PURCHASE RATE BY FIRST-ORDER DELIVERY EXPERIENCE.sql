-- ============================================
-- PHASE 2: REPEAT-PURCHASE RATE BY FIRST-ORDER DELIVERY EXPERIENCE
-- ============================================

 
WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        of.order_id,
        of.order_purchase_timestamp,
        of.delivery_days,
        of.is_late,
        of.review_score,
        ROW_NUMBER() OVER (PARTITION BY c.customer_unique_id ORDER BY of.order_purchase_timestamp) AS order_rank
    FROM order_features of
    JOIN customers c ON of.customer_id = c.customer_id
    WHERE of.order_status NOT IN ('canceled', 'unavailable')
),
reference_date AS (
    SELECT MAX(order_purchase_timestamp) AS max_date FROM order_features
),
first_orders AS (
    SELECT co.*
    FROM customer_orders co
    CROSS JOIN reference_date rd
    WHERE co.order_rank = 1
      AND co.order_purchase_timestamp <= rd.max_date - INTERVAL '90 days'
),
cohort AS (
    SELECT
        f.customer_unique_id,
        f.is_late AS first_order_late,
        CASE
            WHEN f.delivery_days IS NULL THEN 'not delivered'
            WHEN f.delivery_days <= 7 THEN 'fast (0-7d)'
            WHEN f.delivery_days <= 14 THEN 'medium (8-14d)'
            ELSE 'slow (15+d)'
        END AS first_order_speed_bucket,
        (s.customer_unique_id IS NOT NULL) AS became_repeat_customer
    FROM first_orders f
    LEFT JOIN customer_orders s
        ON f.customer_unique_id = s.customer_unique_id
        AND s.order_rank = 2
)
SELECT
    first_order_speed_bucket,
    COUNT(*) AS num_customers,
    SUM(CASE WHEN became_repeat_customer THEN 1 ELSE 0 END) AS num_repeat,
    ROUND(100.0 * SUM(CASE WHEN became_repeat_customer THEN 1 ELSE 0 END) / COUNT(*), 2) AS repeat_rate_pct
FROM cohort
GROUP BY first_order_speed_bucket
ORDER BY
    CASE first_order_speed_bucket
        WHEN 'fast (0-7d)' THEN 1
        WHEN 'medium (8-14d)' THEN 2
        WHEN 'slow (15+d)' THEN 3
        ELSE 4
    END;
