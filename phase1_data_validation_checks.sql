-- ============================================
-- 1. ORPHANED FOREIGN KEYS
-- (rows referencing an ID that doesn't exist in the parent table)
-- ============================================
 
-- orders.customer_id should always exist in customers
SELECT COUNT(*) AS orphaned_order_customers
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;
 
-- order_items.order_id should always exist in orders
SELECT COUNT(*) AS orphaned_items_orders
FROM order_items oi
LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;
 
-- order_items.product_id should always exist in products
SELECT COUNT(*) AS orphaned_items_products
FROM order_items oi
LEFT JOIN products p ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;
 
-- order_items.seller_id should always exist in sellers
SELECT COUNT(*) AS orphaned_items_sellers
FROM order_items oi
LEFT JOIN sellers s ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;
 
-- order_payments.order_id should always exist in orders
SELECT COUNT(*) AS orphaned_payments_orders
FROM order_payments op
LEFT JOIN orders o ON op.order_id = o.order_id
WHERE o.order_id IS NULL;
 
-- order_reviews.order_id should always exist in orders
SELECT COUNT(*) AS orphaned_reviews_orders
FROM order_reviews r
LEFT JOIN orders o ON r.order_id = o.order_id
WHERE o.order_id IS NULL;

-- ============================================
-- 2. DUPLICATE IDS (where we didn't enforce a primary key)
-- ============================================
 
-- order_reviews: known in the raw dataset to sometimes have duplicate review_ids
SELECT review_id, COUNT(*) AS cnt
FROM order_reviews
GROUP BY review_id
HAVING COUNT(*) > 1
ORDER BY cnt DESC
LIMIT 10;

SELECT COUNT(*) AS total_duplicate_review_ids FROM (
    SELECT review_id FROM order_reviews GROUP BY review_id HAVING COUNT(*) > 1
) sub;

-- ============================================
-- 3. UNEXPECTED NULLS IN CRITICAL COLUMNS
-- ============================================
 
SELECT COUNT(*) AS null_purchase_ts FROM orders WHERE order_purchase_timestamp IS NULL;
SELECT COUNT(*) AS null_customer_id FROM orders WHERE customer_id IS NULL;
SELECT COUNT(*) AS null_review_score FROM order_reviews WHERE review_score IS NULL;
SELECT COUNT(*) AS null_price FROM order_items WHERE price IS NULL;
 
-- Delivered dates: expected to be null ONLY for orders not yet delivered
SELECT order_status, COUNT(*) AS cnt
FROM orders
WHERE order_delivered_customer_date IS NULL
GROUP BY order_status
ORDER BY cnt DESC;

-- ============================================
-- 4. CATEGORY TRANSLATION COVERAGE
-- ============================================
 
SELECT DISTINCT p.product_category_name
FROM products p
LEFT JOIN product_category_name_translation t
    ON p.product_category_name = t.product_category_name
WHERE t.product_category_name IS NULL
    AND p.product_category_name IS NOT NULL;
 
-- How many products have a NULL category at all?
SELECT COUNT(*) AS null_category_products FROM products WHERE product_category_name IS NULL;