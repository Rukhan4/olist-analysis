-- Step 1: Patch the two categories missing an English translation,
-- so the foreign key below doesn't reject valid products.
 
INSERT INTO product_category_name_translation (product_category_name, product_category_name_english)
VALUES
    ('portateis_cozinha_e_preparadores_de_alimentos', 'portateis_cozinha_e_preparadores_de_alimentos'),
    ('pc_gamer', 'pc_gamer');
 
-- Step 2: Add foreign key constraints now that data is validated clean.
-- NULLs are allowed through FKs by default in Postgres (e.g. products.product_category_name
-- can still be null for the 610 uncategorized products) — only non-null mismatches get rejected.
 
ALTER TABLE orders
    ADD CONSTRAINT fk_orders_customer
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id);
 
ALTER TABLE order_items
    ADD CONSTRAINT fk_items_order
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    ADD CONSTRAINT fk_items_product
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    ADD CONSTRAINT fk_items_seller
    FOREIGN KEY (seller_id) REFERENCES sellers(seller_id);
 
ALTER TABLE order_payments
    ADD CONSTRAINT fk_payments_order
    FOREIGN KEY (order_id) REFERENCES orders(order_id);
 
ALTER TABLE order_reviews
    ADD CONSTRAINT fk_reviews_order
    FOREIGN KEY (order_id) REFERENCES orders(order_id);
 
ALTER TABLE products
    ADD CONSTRAINT fk_products_category
    FOREIGN KEY (product_category_name) REFERENCES product_category_name_translation(product_category_name);
 
-- Step 3: Confirm all constraints were added successfully
SELECT conname AS constraint_name, conrelid::regclass AS table_name
FROM pg_constraint
WHERE contype = 'f'
ORDER BY table_name;