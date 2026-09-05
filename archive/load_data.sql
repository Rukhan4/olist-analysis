-- Run this from inside the folder containing your 9 CSV files.
-- Truncate first, in case the earlier stuck import partially inserted rows.

TRUNCATE customers, geolocation, sellers, products, product_category_name_translation,
         orders, order_items, order_payments, order_reviews;

\copy customers FROM 'olist_customers_dataset.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');
\copy geolocation FROM 'olist_geolocation_dataset.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');
\copy sellers FROM 'olist_sellers_dataset.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');
\copy products FROM 'olist_products_dataset.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');
\copy product_category_name_translation FROM 'product_category_name_translation.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');
\copy orders FROM 'olist_orders_dataset.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');
\copy order_items FROM 'olist_order_items_dataset.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');
\copy order_payments FROM 'olist_order_payments_dataset.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');
\copy order_reviews FROM 'olist_order_reviews_dataset.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

-- Sanity check row counts
SELECT 'customers' AS table_name, COUNT(*) FROM customers
UNION ALL SELECT 'geolocation', COUNT(*) FROM geolocation
UNION ALL SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'product_category_name_translation', COUNT(*) FROM product_category_name_translation
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'order_payments', COUNT(*) FROM order_payments
UNION ALL SELECT 'order_reviews', COUNT(*) FROM order_reviews;
