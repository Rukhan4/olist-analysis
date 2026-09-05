-- PHASE 7: EXPORT DATA FOR TABLEAU PUBLIC
-- Run via psql (not pgAdmin's GUI export, for consistency with how we loaded data).
-- \copy runs on your local machine, so these CSVs land wherever you run this from.

-- File 1: order-level data — powers KPI cards, map, category heatmap, time trend
\copy (SELECT order_id, order_purchase_timestamp::date AS order_date, customer_state, primary_category, review_score, delivery_days, is_late, order_value, freight_value, item_count, avg_distance_km FROM order_modeling_dataset WHERE review_score IS NOT NULL AND delivery_days IS NOT NULL) TO 'orders_export.csv' WITH (FORMAT csv, HEADER true);

-- File 2: seller-level data — powers the seller-risk view
\copy (WITH seller_stats AS (SELECT s.seller_id, s.seller_state, COUNT(DISTINCT oie.order_id) AS num_orders, ROUND(SUM(oie.price)::NUMERIC,2) AS total_revenue, ROUND(AVG(of.review_score),2) AS avg_review_score, ROUND(100.0*AVG(CASE WHEN of.is_late THEN 1.0 ELSE 0.0 END),1) AS pct_late FROM order_items_enriched oie JOIN sellers s ON oie.seller_id = s.seller_id JOIN order_features of ON oie.order_id = of.order_id WHERE of.review_score IS NOT NULL GROUP BY s.seller_id, s.seller_state HAVING COUNT(DISTINCT oie.order_id) >= 20) SELECT *, RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank FROM seller_stats ORDER BY revenue_rank) TO 'sellers_export.csv' WITH (FORMAT csv, HEADER true);
