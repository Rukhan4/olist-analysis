-- PHASE 2: CORE FEATURE VIEWS
 
-- ============================================
-- VIEW 1: order_features (one row per order)
-- ============================================
 
CREATE OR REPLACE VIEW order_features AS
WITH order_value AS (
    -- Aggregate order_items UP to order level: one order can have many items
    SELECT
        order_id,
        SUM(price) AS order_value,
        SUM(freight_value) AS freight_value,
        COUNT(*) AS item_count
    FROM order_items
    GROUP BY order_id
),
dedup_reviews AS (
    -- DISTINCT ON keeps only the first row per order_id after sorting.
    -- Sorting by review_answer_timestamp DESC means we keep the MOST RECENT
    -- review per order, collapsing any duplicates we found in Phase 1.
    SELECT DISTINCT ON (order_id)
        order_id,
        review_score
    FROM order_reviews
    ORDER BY order_id, review_answer_timestamp DESC
)
SELECT
    o.order_id,
    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    ov.order_value,
    ov.freight_value,
    ov.item_count,
    dr.review_score,
 
    -- Total delivery time: purchase to customer's door
    -- CASE WHEN guards against the 8 "delivered" orders with a null date (Phase 1 finding)
    CASE
        WHEN o.order_delivered_customer_date IS NOT NULL
        THEN EXTRACT(DAY FROM o.order_delivered_customer_date - o.order_purchase_timestamp)
    END AS delivery_days,
 
    -- Handling time: purchase to carrier pickup (seller-controlled)
    CASE
        WHEN o.order_delivered_carrier_date IS NOT NULL
        THEN EXTRACT(DAY FROM o.order_delivered_carrier_date - o.order_purchase_timestamp)
    END AS handling_days,
 
    -- Transit time: carrier pickup to customer door (carrier-controlled)
    CASE
        WHEN o.order_delivered_carrier_date IS NOT NULL AND o.order_delivered_customer_date IS NOT NULL
        THEN EXTRACT(DAY FROM o.order_delivered_customer_date - o.order_delivered_carrier_date)
    END AS transit_days,
 
    -- Was it late relative to what Olist promised the customer?
    CASE
        WHEN o.order_delivered_customer_date IS NOT NULL
        THEN o.order_delivered_customer_date > o.order_estimated_delivery_date
    END AS is_late
 
FROM orders o
LEFT JOIN order_value ov ON o.order_id = ov.order_id
LEFT JOIN dedup_reviews dr ON o.order_id = dr.order_id;
 
 
-- ============================================
-- VIEW 2: order_items_enriched (one row per item, with category)
-- ============================================
 
CREATE OR REPLACE VIEW order_items_enriched AS
SELECT
    oi.order_id,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,
    oi.price,
    oi.freight_value,
    -- COALESCE: if category is null OR has no translation, fall back gracefully
    -- rather than losing the row
    COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS category
FROM order_items oi
LEFT JOIN products p ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation t ON p.product_category_name = t.product_category_name;

 