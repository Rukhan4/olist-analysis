-- ============================================
-- Step 1: One representative lat/lng per zip code prefix
-- (geolocation has many rows per zip — different exact addresses sharing a prefix)
-- ============================================
CREATE OR REPLACE VIEW zip_geoloc AS
SELECT
    geolocation_zip_code_prefix AS zip_code_prefix,
    AVG(geolocation_lat) AS lat,
    AVG(geolocation_lng) AS lng
FROM geolocation
GROUP BY geolocation_zip_code_prefix;
 
-- ============================================
-- Step 2: Item-level distance using the Haversine formula
-- (great-circle distance between two lat/lng points, accounting for Earth's curvature —
-- straight-line Pythagorean distance would be wrong at this geographic scale)
-- ============================================
CREATE OR REPLACE VIEW order_item_distance AS
SELECT
    oi.order_id,
    oi.order_item_id,
    CASE
        WHEN cz.lat IS NULL OR sz.lat IS NULL THEN NULL
        ELSE 6371 * acos(
            -- LEAST/GREATEST clamps the value to [-1, 1] — floating point rounding
            -- can occasionally push it just past 1, which would make acos() error out
            LEAST(1, GREATEST(-1,
                cos(radians(cz.lat)) * cos(radians(sz.lat)) * cos(radians(sz.lng) - radians(cz.lng))
                + sin(radians(cz.lat)) * sin(radians(sz.lat))
            ))
        )
    END AS distance_km
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN customers c ON o.customer_id = c.customer_id
JOIN sellers s ON oi.seller_id = s.seller_id
LEFT JOIN zip_geoloc cz ON c.customer_zip_code_prefix = cz.zip_code_prefix
LEFT JOIN zip_geoloc sz ON s.seller_zip_code_prefix = sz.zip_code_prefix;
 
-- ============================================
-- Step 3: Aggregate to order level
-- avg_distance_km: typical distance for this order's items
-- max_distance_km: worst-case leg, useful since one far-away seller can bottleneck
-- the whole order even if others are close
-- ============================================
CREATE OR REPLACE VIEW order_distance AS
SELECT
    order_id,
    ROUND(AVG(distance_km)::NUMERIC, 1) AS avg_distance_km,
    ROUND(MAX(distance_km)::NUMERIC, 1) AS max_distance_km
FROM order_item_distance
GROUP BY order_id;
 
-- ============================================
-- Sanity check: what % of orders end up with a NULL distance
-- (some zip prefixes may not exist in the geolocation table at all)
-- ============================================
SELECT
    COUNT(*) AS total_orders,
    COUNT(avg_distance_km) AS orders_with_distance,
    ROUND(100.0 * (COUNT(*) - COUNT(avg_distance_km)) / COUNT(*), 2) AS pct_missing_distance
FROM order_distance;