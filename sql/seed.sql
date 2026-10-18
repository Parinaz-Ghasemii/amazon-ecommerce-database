-- ============================================================
-- AmazonDB — sample data (hand-written, small on purpose)
-- Run after schema.sql. Existing rows are cleared first, so this
-- script can be re-run safely. Rows are inserted parent-first so
-- every foreign key resolves.
--
-- Consistency rules the sample data follows:
--   * Payment amounts equal the order totals (sum of OrderItem).
--   * A shipment is 'Delivered' if and only if it has a delivery_date.
--   * Every review was written by a customer whose order containing
--     that product was delivered, and after the delivery date.
-- ============================================================
USE AmazonDB;

-- ------------------------------------------------------------
-- Clear existing rows (children first is not needed because
-- foreign key checks are switched off while truncating)
-- ------------------------------------------------------------
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE OrderItem;
TRUNCATE TABLE Inventory;
TRUNCATE TABLE Payment;
TRUNCATE TABLE Review;
TRUNCATE TABLE Shipment;
TRUNCATE TABLE ProductSeller;
TRUNCATE TABLE `Order`;
TRUNCATE TABLE Warehouse;
TRUNCATE TABLE Product;
TRUNCATE TABLE Worker;
TRUNCATE TABLE Category;
TRUNCATE TABLE Seller;
TRUNCATE TABLE Customer;
SET FOREIGN_KEY_CHECKS = 1;

-- ------------------------------------------------------------
-- Customer (12)
-- ------------------------------------------------------------
INSERT INTO Customer (customer_id, name, email, address, phone, date_of_birth) VALUES
(101, 'Alice Smith',     'alice.smith@gmail.com',  '123 Maple St, New York, NY',       '555-0101', '1990-05-12'),
(102, 'Bob Jones',       'bob.jones@yahoo.com',    '456 Oak Rd, Los Angeles, CA',      '555-0102', '1985-11-23'),
(103, 'Charlie Brown',   'charlie.b@gmail.com',    '789 Pine Ave, Chicago, IL',        '555-0103', '1993-02-28'),
(104, 'Diana Prince',    'diana.p@amazon.com',     '101 Wonder Way, Boston, MA',       '555-0104', '1988-07-15'),
(105, 'Evan Wright',     'evan.w@outlook.com',     '202 Cedar Blvd, Austin, TX',       '555-0105', '1995-09-05'),
(106, 'Fiona Gallagher', 'fiona.g@gmail.com',      '303 Elm St, Chicago, IL',          '555-0106', '1991-04-20'),
(107, 'George Clark',    'george.c@icloud.com',    '404 Birch Ln, Seattle, WA',        '555-0107', '1979-12-01'),
(108, 'Hannah Abbott',   'hannah.a@gmail.com',     '505 Willow Dr, Miami, FL',         '555-0108', '1997-01-18'),
(109, 'Ian Malcolm',     'dino.ian@gmail.com',     '606 Spruce Ct, Denver, CO',        '555-0109', '1965-10-31'),
(110, 'Julia Roberts',   'julia.r@yahoo.com',      '707 Walnut Rd, San Francisco, CA', '555-0110', '1982-08-14'),
(111, 'Silent Shopper',  'silent@gmail.com',       '111 Quiet Way, Phoenix, AZ',       '555-0111', '1994-03-12'),
(112, 'Frequent Buyer',  'frequent@yahoo.com',     '222 Express Ln, Las Vegas, NV',    '555-0112', '1992-07-22');

-- ------------------------------------------------------------
-- Seller (10)
-- ------------------------------------------------------------
INSERT INTO Seller (seller_id, store_name, contact_num) VALUES
(201, 'TechGalaxy Official',  '800-555-201'),
(202, 'BookWorm Central',     '800-555-202'),
(203, 'Apparel Zone',         '800-555-203'),
(204, 'HomeEssentials Co',    '800-555-204'),
(205, 'SportsOutfitter',      '800-555-205'),
(206, 'Cosmic Beauty Direct', '800-555-206'),
(207, 'KitchenMaster',        '800-555-207'),
(208, 'GadgetWorld',          '800-555-208'),
(209, 'GreenThumb Garden',    '800-555-209'),
(210, 'ToyKingdom',           '800-555-210');

-- ------------------------------------------------------------
-- Category (10)
-- ------------------------------------------------------------
INSERT INTO Category (category_id, category_name) VALUES
(1,  'Electronics'),
(2,  'Books'),
(3,  'Clothing'),
(4,  'Home & Kitchen'),
(5,  'Sports & Outdoors'),
(6,  'Beauty & Personal Care'),
(7,  'Garden & Outdoor'),
(8,  'Toys & Games'),
(9,  'Automotive'),
(10, 'Office Products');

-- ------------------------------------------------------------
-- Worker (10)
-- ------------------------------------------------------------
INSERT INTO Worker (worker_id, name, phone_num, hire_date, date_of_birth, salary, role) VALUES
(501, 'John Doe',        '555-5011', '2015-03-15', '1980-01-10', 85000.00, 'Warehouse Manager'),
(502, 'Jane Smith',      '555-5022', '2017-06-20', '1985-05-22', 82000.00, 'Warehouse Manager'),
(503, 'Robert Johnson',  '555-5033', '2018-11-01', '1988-09-14', 79000.00, 'Warehouse Manager'),
(504, 'Emily Davis',     '555-5044', '2019-02-10', '1991-12-03', 45000.00, 'Logistics Associate'),
(505, 'Michael Wilson',  '555-5055', '2020-08-25', '1993-07-19', 46000.00, 'Logistics Associate'),
(506, 'Sarah Miller',    '555-5066', '2021-01-15', '1995-04-02', 80000.00, 'Warehouse Manager'),
(507, 'David Anderson',  '555-5077', '2021-05-18', '1990-06-25', 78000.00, 'Warehouse Manager'),
(508, 'Jessica Taylor',  '555-5088', '2022-03-01', '1994-11-08', 43000.00, 'Quality Inspector'),
(509, 'James Thomas',    '555-5099', '2022-09-10', '1992-03-30', 44000.00, 'Forklift Operator'),
(510, 'Karen Jackson',   '555-5100', '2023-01-22', '1996-08-12', 42000.00, 'Receiving Clerk');

-- ------------------------------------------------------------
-- Product (10)
-- ------------------------------------------------------------
INSERT INTO Product (product_id, name, category_id, description) VALUES
(1001, 'iPhone 15 Pro',               1,  'Apple iPhone 15 Pro 256GB Titanium'),
(1002, 'Sony WH-1000XM4',             1,  'Wireless Noise Canceling Overhead Headphones'),
(1003, 'SQL Database Design Book',    2,  'Learn relational database modeling principles'),
(1004, 'Running Shoes Alpha',         5,  'Lightweight breathable running shoes'),
(1005, 'Ergonomic Office Chair',      10, 'High-back mesh chair with lumbar support'),
(1006, 'Stainless Steel Coffee Maker',4,  '12-Cup programmable drip coffee maker'),
(1007, 'Organic Face Moisturizer',    6,  'Hydrating aloe vera moisturizer formula'),
(1008, 'LED Desk Lamp',               10, 'Dimmable office lamp with USB charging port'),
(1009, 'Leather Wallet Classic',      3,  'Genuine leather bi-fold structural wallet'),
(1010, 'Mechanical Keyboard RGB',     1,  'Tactile blue switch mechanical gaming keyboard');

-- ------------------------------------------------------------
-- Warehouse (10)
-- ------------------------------------------------------------
INSERT INTO Warehouse (warehouse_id, manager_id, location, capacity) VALUES
(1,  501, 'Fulfillment Center NY-1, Queens, NY',        50000),
(2,  502, 'Fulfillment Center CA-2, San Bernardino, CA',75000),
(3,  503, 'Logistics Hub IL-1, Chicago, IL',            60000),
(4,  506, 'Regional Warehouse TX-5, Dallas, TX',        45000),
(5,  507, 'Coastal Depot FL-3, Miami, FL',              30000),
(6,  501, 'Fulfillment Center NY-2, Brooklyn, NY',      25000),
(7,  502, 'Logistics Hub CA-3, Tracy, CA',              80000),
(8,  503, 'Fulfillment Center Hub OH-1, Columbus, OH',  55000),
(9,  506, 'Pacific Northwest Depot WA-1, Seattle, WA',  40000),
(10, 507, 'Mountain Hub CO-2, Denver, CO',              35000);

-- ------------------------------------------------------------
-- ProductSeller (12): some products are sold by several sellers
-- to model marketplace competition.
-- ------------------------------------------------------------
INSERT INTO ProductSeller (product_id, seller_id, price) VALUES
(1001, 201, 999.99),  -- TechGalaxy sells the iPhone
(1001, 208, 989.50),  -- GadgetWorld undercuts it
(1002, 201, 348.00),  -- TechGalaxy sells the Sony headphones
(1002, 208, 345.00),  -- GadgetWorld sells them for less
(1003, 202,  45.00),
(1004, 205, 120.00),
(1005, 204, 189.99),
(1006, 207,  59.99),
(1007, 206,  24.50),
(1008, 208,  29.99),
(1009, 203,  45.00),
(1010, 208,  79.99);

-- ------------------------------------------------------------
-- Order (16)
-- ------------------------------------------------------------
INSERT INTO `Order` (order_id, customer_id, order_date, status) VALUES
(5001, 101, '2026-05-01', 'Delivered'),
(5002, 102, '2026-05-02', 'Delivered'),
(5003, 103, '2026-05-05', 'Delivered'),
(5004, 104, '2026-05-06', 'Processing'),
(5005, 105, '2026-05-10', 'Delivered'),
(5006, 101, '2026-05-12', 'Delivered'),
(5007, 106, '2026-05-14', 'Pending'),
(5008, 107, '2026-05-15', 'Delivered'),
(5009, 108, '2026-05-18', 'Cancelled'),
(5010, 110, '2026-05-20', 'Processing'),
(5011, 112, '2026-06-01', 'Delivered'),
(5012, 112, '2026-06-01', 'Delivered'),   -- same-day orders: used by the fraud-check query
(5013, 112, '2026-06-01', 'Processing'),
(5014, 111, '2026-06-02', 'Shipped'),
(5015, 108, '2026-05-19', 'Delivered'),   -- Hannah re-orders after cancelling 5009
(5016, 106, '2026-05-20', 'Delivered');

-- ------------------------------------------------------------
-- Shipment (15)
-- delivery_date = actual delivery date, so NULL until delivered.
-- ------------------------------------------------------------
INSERT INTO Shipment (shipment_id, warehouse_id, delivery_date, shipping_address, status) VALUES
(6001, 1,  '2026-05-04', '123 Maple St, New York, NY',       'Delivered'),
(6002, 2,  '2026-05-05', '456 Oak Rd, Los Angeles, CA',      'Delivered'),
(6003, 3,  '2026-05-09', '789 Pine Ave, Chicago, IL',        'Delivered'),
(6004, 4,  '2026-05-13', '202 Cedar Blvd, Austin, TX',       'Delivered'),
(6005, 1,  '2026-05-16', '123 Maple St, New York, NY',       'Delivered'),
(6006, 4,  '2026-05-23', '303 Elm St, Chicago, IL',          'Delivered'),
(6007, 9,  '2026-05-18', '404 Birch Ln, Seattle, WA',        'Delivered'),
(6008, 2,  NULL,         '101 Wonder Way, Boston, MA',       'Pending'),
(6009, 10, NULL,         '707 Walnut Rd, San Francisco, CA', 'Processing'),
(6010, 5,  NULL,         '505 Willow Dr, Miami, FL',         'Cancelled'),
(6011, 1,  '2026-06-03', '222 Express Ln, Las Vegas, NV',    'Delivered'),
(6012, 2,  '2026-06-04', '222 Express Ln, Las Vegas, NV',    'Delivered'),
(6013, 3,  NULL,         '222 Express Ln, Las Vegas, NV',    'Processing'),
(6014, 1,  NULL,         '111 Quiet Way, Phoenix, AZ',       'In Transit'),
(6015, 5,  '2026-05-21', '505 Willow Dr, Miami, FL',         'Delivered');

-- ------------------------------------------------------------
-- OrderItem (18)
-- ------------------------------------------------------------
INSERT INTO OrderItem (order_id, product_id, seller_id, quantity, unit_price, shipment_id) VALUES
(5001, 1001, 201, 1, 999.99, 6001),   -- iPhone from TechGalaxy
(5002, 1002, 208, 1, 345.00, 6002),   -- headphones from GadgetWorld
(5003, 1003, 202, 1,  45.00, 6003),   -- SQL book
(5004, 1001, 208, 1, 989.50, 6008),   -- iPhone from the cheaper rival seller
(5005, 1005, 204, 1, 189.99, 6004),   -- office chair
(5006, 1002, 201, 1, 348.00, 6005),   -- headphones from TechGalaxy
(5007, 1007, 206, 1,  24.50, NULL),   -- pending order, no shipment yet
(5008, 1006, 207, 1,  59.99, 6007),   -- coffee maker
(5009, 1004, 205, 1, 120.00, 6010),   -- cancelled order, cancelled shipment
(5010, 1010, 208, 1,  79.99, 6009),   -- keyboard
(5011, 1001, 201, 1, 999.99, 6011),
(5011, 1002, 201, 1, 348.00, 6011),
(5012, 1001, 208, 1, 989.50, 6012),
(5012, 1010, 208, 1,  79.99, 6012),
(5013, 1003, 202, 1,  45.00, 6013),
(5014, 1002, 201, 1, 348.00, 6014),
(5015, 1007, 206, 1,  24.50, 6015),
(5016, 1004, 205, 1, 120.00, 6006);

-- ------------------------------------------------------------
-- Payment (16)
-- ------------------------------------------------------------
INSERT INTO Payment (payment_id, order_id, payment_method, amount, payment_date, status) VALUES
(8001, 5001, 'Credit Card',    999.99,  '2026-05-01', 'Completed'),
(8002, 5002, 'PayPal',         345.00,  '2026-05-02', 'Completed'),
(8003, 5003, 'Credit Card',     45.00,  '2026-05-05', 'Completed'),
(8004, 5004, 'Amazon Balance', 989.50,  '2026-05-06', 'Completed'),
(8005, 5005, 'Debit Card',     189.99,  '2026-05-10', 'Completed'),
(8006, 5006, 'Credit Card',    348.00,  '2026-05-12', 'Completed'),
(8007, 5007, 'PayPal',          24.50,  '2026-05-14', 'Pending'),
(8008, 5008, 'Credit Card',     59.99,  '2026-05-15', 'Completed'),
(8009, 5009, 'Debit Card',     120.00,  '2026-05-18', 'Refunded'),
(8010, 5010, 'Amazon Balance',  79.99,  '2026-05-20', 'Completed'),
(8011, 5011, 'Credit Card',   1347.99,  '2026-06-01', 'Completed'),
(8012, 5012, 'Credit Card',   1069.49,  '2026-06-01', 'Completed'),
(8013, 5013, 'PayPal',          45.00,  '2026-06-01', 'Completed'),
(8014, 5014, 'Debit Card',     348.00,  '2026-06-02', 'Completed'),
(8015, 5015, 'PayPal',          24.50,  '2026-05-19', 'Completed'),
(8016, 5016, 'Credit Card',    120.00,  '2026-05-20', 'Completed');

-- ------------------------------------------------------------
-- Review (10): each by a customer whose order with that product
-- was delivered before the review date.
-- ------------------------------------------------------------
INSERT INTO Review (review_id, product_id, customer_id, rating, comment, review_date) VALUES
(7001, 1001, 101, 5, 'Phenomenal device. Titanium builds feel lightweight.',                       '2026-05-05'),
(7002, 1002, 102, 4, 'Excellent noise canceling, but ears get hot after hours of usage.',          '2026-05-06'),
(7003, 1003, 103, 5, 'Perfect layout patterns. Cleared my university SQL exam easily.',            '2026-05-10'),
(7004, 1005, 105, 2, 'Mesh tore within 3 days. Return setup initiated.',                           '2026-05-17'),
(7005, 1001, 112, 5, 'Pricey but definitely worth upgrading from an older generation.',           '2026-06-08'),
(7006, 1006, 107, 4, 'Brews fast and coffee is scalding hot. Satisfied.',                          '2026-05-20'),
(7007, 1007, 108, 5, 'Very soothing on sensitive dry skin surfaces.',                              '2026-05-22'),
(7008, 1004, 106, 3, 'Good grip arc but missing cushion support zones.',                           '2026-05-25'),
(7009, 1010, 112, 4, 'Clicks loud and positive. Great dynamic color range profile panels.',        '2026-06-07'),
(7010, 1002, 101, 5, 'Best travel headphones around hands down.',                                  '2026-05-27');

-- ------------------------------------------------------------
-- Inventory (12): maps a seller's listing (ProductSeller) to a
-- physical warehouse.
-- ------------------------------------------------------------
INSERT INTO Inventory (warehouse_id, product_id, seller_id, quantity) VALUES
(1,  1001, 201,  150),  -- Warehouse 1 holds TechGalaxy iPhones
(1,  1002, 201,  300),  -- Warehouse 1 holds TechGalaxy headphones
(2,  1001, 208,  200),  -- Warehouse 2 holds GadgetWorld iPhones
(2,  1002, 208,  400),  -- Warehouse 2 holds GadgetWorld headphones
(3,  1003, 202, 1200),  -- Warehouse 3 holds BookWorm SQL textbooks
(4,  1004, 205,  500),  -- Warehouse 4 holds SportsOutfitter shoes
(4,  1005, 204,   80),  -- Warehouse 4 holds HomeEssentials chairs
(5,  1007, 206,  600),  -- Warehouse 5 holds Cosmic Beauty moisturizer
(8,  1006, 207,  250),  -- Warehouse 8 holds KitchenMaster coffee makers
(10, 1010, 208,  180),  -- Warehouse 10 holds GadgetWorld keyboards
(6,  1008, 208,  750),  -- stocked but never ordered (shows up in the dead-stock query)
(7,  1009, 203,  420);  -- stocked but never ordered (shows up in the dead-stock query)
