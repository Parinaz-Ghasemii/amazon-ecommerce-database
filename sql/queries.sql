-- ============================================================
-- AmazonDB — example queries (MySQL 8.0+)
-- Run schema.sql and seed.sql first.
-- Sections go from basic lookups to analytics (CTEs, window
-- functions, self-joins).
-- ============================================================
USE AmazonDB;

-- ============================================================
-- A. BASICS
-- ============================================================

-- A1. All customers
SELECT * FROM Customer;

-- A2. Names and emails only
SELECT name, email FROM Customer;

-- A3. Customers who live in Chicago
SELECT name, address
FROM Customer
WHERE address LIKE '%Chicago%';

-- A4. Seller listings, most expensive first
SELECT * FROM ProductSeller ORDER BY price DESC;

-- A5. How many products are in the catalog
SELECT COUNT(*) AS total_products FROM Product;

-- A6. Each product with its category
SELECT p.name AS product_name, c.category_name
FROM Product p
JOIN Category c ON p.category_id = c.category_id;

-- ============================================================
-- B. SALES AND CUSTOMERS
-- ============================================================

-- B1. Revenue per order
SELECT
    order_id,
    SUM(quantity * unit_price) AS total_order_amount
FROM OrderItem
GROUP BY order_id;

-- B2. Top customers: total spend above $500
SELECT
    c.customer_id,
    c.name AS customer_name,
    SUM(oi.quantity * oi.unit_price) AS total_spent
FROM Customer c
JOIN `Order` o   ON c.customer_id = o.customer_id
JOIN OrderItem oi ON o.order_id   = oi.order_id
GROUP BY c.customer_id, c.name
HAVING total_spent > 500.00
ORDER BY total_spent DESC;

-- B3. Fraud / abuse check: customers placing more than one order on the same day
SELECT
    c.customer_id,
    c.name AS customer_name,
    o.order_date,
    COUNT(o.order_id) AS orders_placed_that_day
FROM `Order` o
JOIN Customer c ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.name, o.order_date
HAVING orders_placed_that_day > 1;

-- B4. Customer behaviour summary (two CTEs, then stitched together).
--     Customers with no orders or reviews still appear (LEFT JOIN + COALESCE).
WITH CustomerSalesSummary AS (
    SELECT
        o.customer_id,
        COUNT(DISTINCT o.order_id)       AS total_orders,
        SUM(oi.quantity * oi.unit_price) AS total_spent
    FROM `Order` o
    JOIN OrderItem oi ON o.order_id = oi.order_id
    GROUP BY o.customer_id
),
CustomerReviewSummary AS (
    SELECT
        customer_id,
        MAX(rating) AS highest_given_rating
    FROM Review
    GROUP BY customer_id
)
SELECT
    c.customer_id,
    c.name AS customer_name,
    COALESCE(s.total_orders, 0)    AS lifetime_orders,
    COALESCE(s.total_spent, 0.00)  AS lifetime_spend,
    COALESCE(CAST(r.highest_given_rating AS CHAR), 'No Reviews Given') AS top_rating
FROM Customer c
LEFT JOIN CustomerSalesSummary s ON c.customer_id = s.customer_id
LEFT JOIN CustomerReviewSummary r ON c.customer_id = r.customer_id;

-- B5. Order fulfilment overview: order, payment and shipment status side by side
SELECT
    o.order_id,
    c.name       AS customer_name,
    o.status     AS order_status,
    p.status     AS payment_status,
    COALESCE(s.status, 'Not assigned') AS shipment_status,
    t.order_total
FROM `Order` o
JOIN Customer c ON o.customer_id = c.customer_id
JOIN Payment  p ON o.order_id    = p.order_id
JOIN (
    SELECT order_id, SUM(quantity * unit_price) AS order_total
    FROM OrderItem
    GROUP BY order_id
) t ON o.order_id = t.order_id
LEFT JOIN (
    SELECT DISTINCT oi.order_id, sh.status
    FROM OrderItem oi
    JOIN Shipment sh ON oi.shipment_id = sh.shipment_id
) s ON o.order_id = s.order_id
ORDER BY o.order_id;

-- ============================================================
-- C. PRODUCTS, REVIEWS AND SELLERS
-- ============================================================

-- C1. Underperforming products: average rating below 4 stars
SELECT
    p.product_id,
    p.name AS product_name,
    AVG(r.rating)      AS average_rating,
    COUNT(r.review_id) AS total_reviews
FROM Product p
JOIN Review r ON p.product_id = r.product_id
GROUP BY p.product_id, p.name
HAVING average_rating < 4.0
ORDER BY average_rating ASC;

-- C2. Review sentiment buckets (CASE)
SELECT
    p.name AS product_name,
    r.rating,
    CASE
        WHEN r.rating >= 4 THEN 'Positive Sentiment'
        WHEN r.rating = 3  THEN 'Neutral Sentiment'
        ELSE 'Negative Sentiment'
    END AS review_sentiment,
    r.comment
FROM Review r
JOIN Product p ON r.product_id = p.product_id;

-- C3. Seller leaderboard by gross merchandise value
SELECT
    s.seller_id,
    s.store_name,
    COUNT(DISTINCT oi.order_id)      AS unique_orders_handled,
    SUM(oi.quantity)                 AS total_items_sold,
    SUM(oi.quantity * oi.unit_price) AS gross_merchandise_value
FROM Seller s
JOIN OrderItem oi ON s.seller_id = oi.seller_id
GROUP BY s.seller_id, s.store_name
ORDER BY gross_merchandise_value DESC;

-- C4. Market basket: pairs of products bought in the same order.
--     The < comparison keeps each pair once and never pairs a product with itself.
SELECT
    p1.name AS product_a,
    p2.name AS product_b,
    COUNT(*) AS times_bought_together
FROM OrderItem oi1
JOIN OrderItem oi2 ON oi1.order_id = oi2.order_id
                  AND oi1.product_id < oi2.product_id
JOIN Product p1 ON oi1.product_id = p1.product_id
JOIN Product p2 ON oi2.product_id = p2.product_id
GROUP BY p1.name, p2.name
ORDER BY times_bought_together DESC;

-- ============================================================
-- D. WAREHOUSES AND INVENTORY
-- ============================================================

-- D1. Stock by warehouse, product and seller
SELECT
    w.location AS warehouse_location,
    p.name     AS product_name,
    s.store_name AS merchant_name,
    inv.quantity AS stock_on_hand
FROM Inventory inv
JOIN Warehouse w ON inv.warehouse_id = w.warehouse_id
JOIN Product   p ON inv.product_id   = p.product_id
JOIN Seller    s ON inv.seller_id    = s.seller_id
ORDER BY w.location, inv.quantity DESC;

-- D2. Dead stock: inventory of listings that have never been ordered
SELECT
    w.location AS warehouse_location,
    p.name     AS product_name,
    s.store_name AS merchant_name,
    inv.quantity AS sitting_stock
FROM Inventory inv
JOIN Warehouse w ON inv.warehouse_id = w.warehouse_id
JOIN Product   p ON inv.product_id   = p.product_id
JOIN Seller    s ON inv.seller_id    = s.seller_id
LEFT JOIN OrderItem oi ON inv.product_id = oi.product_id
                      AND inv.seller_id  = oi.seller_id
WHERE oi.order_id IS NULL;

-- D3. Warehouse manager audit
SELECT
    w.warehouse_id,
    w.location AS facility_address,
    w.capacity AS storage_units_max,
    e.name     AS manager_name,
    e.salary   AS manager_annual_compensation
FROM Warehouse w
JOIN Worker e ON w.manager_id = e.worker_id
ORDER BY w.capacity DESC;

-- D4. Workers earning more than the company average (subquery)
SELECT worker_id, name AS worker_name, role, salary
FROM Worker
WHERE salary > (SELECT AVG(salary) FROM Worker)
ORDER BY salary DESC;

-- ============================================================
-- E. WINDOW FUNCTIONS
-- ============================================================

-- E1. Rank products by revenue inside their own category (cancelled orders excluded)
SELECT
    c.category_name,
    p.name AS product_name,
    SUM(oi.quantity * oi.unit_price) AS revenue,
    RANK() OVER (
        PARTITION BY c.category_id
        ORDER BY SUM(oi.quantity * oi.unit_price) DESC
    ) AS rank_in_category
FROM OrderItem oi
JOIN `Order`  o ON oi.order_id   = o.order_id
JOIN Product  p ON oi.product_id = p.product_id
JOIN Category c ON p.category_id = c.category_id
WHERE o.status <> 'Cancelled'
GROUP BY c.category_id, c.category_name, p.product_id, p.name
ORDER BY c.category_name, rank_in_category;

-- E2. Daily revenue with a running total (cancelled orders excluded)
SELECT
    order_date,
    daily_revenue,
    SUM(daily_revenue) OVER (ORDER BY order_date) AS cumulative_revenue
FROM (
    SELECT o.order_date, SUM(oi.quantity * oi.unit_price) AS daily_revenue
    FROM `Order` o
    JOIN OrderItem oi ON o.order_id = oi.order_id
    WHERE o.status <> 'Cancelled'
    GROUP BY o.order_date
) d
ORDER BY order_date;
