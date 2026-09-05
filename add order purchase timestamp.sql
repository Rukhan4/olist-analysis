-- Adds order_purchase_timestamp to the modeling dataset view, needed for the
-- Tableau time-trend chart. CREATE OR REPLACE keeps everything else identical.
 
CREATE OR REPLACE VIEW order_modeling_dataset AS
SELECT
    of.order_id,
    of.review_score,
    of.delivery_days,
    of.handling_days,
    of.transit_days,
    of.is_late,
    of.order_value,
    of.freight_value,
    of.item_count,
    od.avg_distance_km,
    od.max_distance_km,
    c.customer_state,
    pc.primary_category,
    of.order_status,
    of.order_purchase_timestamp AS order_date
FROM order_features of
JOIN customers c ON of.customer_id = c.customer_id
LEFT JOIN order_distance od ON of.order_id = od.order_id
LEFT JOIN order_primary_category pc ON of.order_id = pc.order_id;