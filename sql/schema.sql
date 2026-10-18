-- ============================================================
-- AmazonDB — schema (MySQL 8.0.16+)
-- 13 tables, normalized to 3NF.
--
-- WARNING: running this script drops and recreates AmazonDB.
-- ============================================================
DROP DATABASE IF EXISTS AmazonDB;
CREATE DATABASE AmazonDB;
USE AmazonDB;

-- ------------------------------------------------------------
-- Level 0: tables with no foreign keys
-- ------------------------------------------------------------

CREATE TABLE Customer (
    customer_id   INT           NOT NULL,
    name          VARCHAR(255)  NOT NULL,
    email         VARCHAR(255)  NOT NULL,
    address       TEXT,
    phone         VARCHAR(50),
    date_of_birth DATE,
    PRIMARY KEY (customer_id),
    CONSTRAINT uq_customer_email UNIQUE (email)
);

CREATE TABLE Seller (
    seller_id   INT          NOT NULL,
    store_name  VARCHAR(255),
    contact_num VARCHAR(50),
    PRIMARY KEY (seller_id)
);

CREATE TABLE Category (
    category_id   INT          NOT NULL,
    category_name VARCHAR(255) NOT NULL,
    PRIMARY KEY (category_id),
    CONSTRAINT uq_category_name UNIQUE (category_name)
);

CREATE TABLE Worker (
    worker_id     INT           NOT NULL,
    name          VARCHAR(255)  NOT NULL,
    phone_num     VARCHAR(50),
    hire_date     DATE,
    date_of_birth DATE,
    salary        DECIMAL(10,2),
    role          VARCHAR(100),
    PRIMARY KEY (worker_id),
    CONSTRAINT chk_worker_salary CHECK (salary IS NULL OR salary >= 0),
    CONSTRAINT chk_worker_dates  CHECK (hire_date IS NULL OR date_of_birth IS NULL OR hire_date > date_of_birth)
);

-- ------------------------------------------------------------
-- Level 1: depend on level-0 tables
-- ------------------------------------------------------------

CREATE TABLE Product (
    product_id  INT          NOT NULL,
    name        VARCHAR(255) NOT NULL,
    category_id INT          NOT NULL,
    description TEXT,
    PRIMARY KEY (product_id),
    CONSTRAINT fk_product_category FOREIGN KEY (category_id)
        REFERENCES Category (category_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE Warehouse (
    warehouse_id INT NOT NULL,
    manager_id   INT,                    -- NULL = position currently vacant
    location     VARCHAR(255),
    capacity     INT,
    PRIMARY KEY (warehouse_id),
    CONSTRAINT fk_warehouse_manager FOREIGN KEY (manager_id)
        REFERENCES Worker (worker_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT chk_warehouse_capacity CHECK (capacity IS NULL OR capacity > 0)
);

-- `Order` is a reserved word in MySQL, hence the backticks everywhere.
CREATE TABLE `Order` (
    order_id    INT         NOT NULL,
    customer_id INT         NOT NULL,
    order_date  DATE,
    status      ENUM('Pending','Processing','Shipped','Delivered','Cancelled')
                NOT NULL DEFAULT 'Pending',
    PRIMARY KEY (order_id),
    CONSTRAINT fk_order_customer FOREIGN KEY (customer_id)
        REFERENCES Customer (customer_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ------------------------------------------------------------
-- Level 2
-- ------------------------------------------------------------

-- Which seller offers which product, and at what price (M:N resolution).
CREATE TABLE ProductSeller (
    product_id INT           NOT NULL,
    seller_id  INT           NOT NULL,
    price      DECIMAL(10,2),
    PRIMARY KEY (product_id, seller_id),
    CONSTRAINT fk_ps_product FOREIGN KEY (product_id)
        REFERENCES Product (product_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_ps_seller FOREIGN KEY (seller_id)
        REFERENCES Seller (seller_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_ps_price CHECK (price IS NULL OR price > 0)
);

-- delivery_date is the ACTUAL delivery date, so it is NULL until delivered.
CREATE TABLE Shipment (
    shipment_id      INT  NOT NULL,
    warehouse_id     INT  NOT NULL,
    delivery_date    DATE,
    shipping_address TEXT,
    status           ENUM('Pending','Processing','In Transit','Out for Delivery','Delivered','Cancelled')
                     NOT NULL DEFAULT 'Pending',
    PRIMARY KEY (shipment_id),
    CONSTRAINT fk_shipment_warehouse FOREIGN KEY (warehouse_id)
        REFERENCES Warehouse (warehouse_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_shipment_delivered CHECK (status <> 'Delivered' OR delivery_date IS NOT NULL)
);

CREATE TABLE Review (
    review_id   INT     NOT NULL,
    product_id  INT     NOT NULL,
    customer_id INT     NOT NULL,
    rating      TINYINT NOT NULL,
    comment     TEXT,
    review_date DATE,
    PRIMARY KEY (review_id),
    CONSTRAINT uq_review_product_customer UNIQUE (product_id, customer_id),
    CONSTRAINT fk_review_product FOREIGN KEY (product_id)
        REFERENCES Product (product_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_review_customer FOREIGN KEY (customer_id)
        REFERENCES Customer (customer_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_review_rating CHECK (rating BETWEEN 1 AND 5)
);

CREATE TABLE Payment (
    payment_id     INT           NOT NULL,
    order_id       INT           NOT NULL,
    payment_method VARCHAR(100),
    amount         DECIMAL(10,2),
    payment_date   DATE,
    status         ENUM('Pending','Completed','Refunded') NOT NULL DEFAULT 'Pending',
    PRIMARY KEY (payment_id),
    CONSTRAINT fk_payment_order FOREIGN KEY (order_id)
        REFERENCES `Order` (order_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_payment_amount CHECK (amount IS NULL OR amount >= 0)
);

-- ------------------------------------------------------------
-- Level 3: composite-key tables
-- ------------------------------------------------------------

-- Physical stock of a seller's listing in a given warehouse.
CREATE TABLE Inventory (
    warehouse_id INT NOT NULL,
    product_id   INT NOT NULL,
    seller_id    INT NOT NULL,
    quantity     INT NOT NULL DEFAULT 0,
    PRIMARY KEY (warehouse_id, product_id, seller_id),
    CONSTRAINT fk_inv_warehouse FOREIGN KEY (warehouse_id)
        REFERENCES Warehouse (warehouse_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_inv_listing FOREIGN KEY (product_id, seller_id)
        REFERENCES ProductSeller (product_id, seller_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_inv_quantity CHECK (quantity >= 0)
);

-- One row per (order, seller's listing). unit_price is the price paid at
-- purchase time, so later price changes in ProductSeller don't rewrite history.
CREATE TABLE OrderItem (
    order_id    INT           NOT NULL,
    product_id  INT           NOT NULL,
    seller_id   INT           NOT NULL,
    quantity    INT           NOT NULL,
    unit_price  DECIMAL(10,2) NOT NULL,
    shipment_id INT,                     -- NULL until the item is assigned to a shipment
    PRIMARY KEY (order_id, product_id, seller_id),
    CONSTRAINT fk_oi_order FOREIGN KEY (order_id)
        REFERENCES `Order` (order_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_oi_listing FOREIGN KEY (product_id, seller_id)
        REFERENCES ProductSeller (product_id, seller_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_oi_shipment FOREIGN KEY (shipment_id)
        REFERENCES Shipment (shipment_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT chk_oi_quantity CHECK (quantity > 0),
    CONSTRAINT chk_oi_price    CHECK (unit_price >= 0)
);

-- ------------------------------------------------------------
-- Indexes beyond those MySQL creates automatically for PKs/FKs
-- ------------------------------------------------------------
CREATE INDEX idx_order_customer_date ON `Order` (customer_id, order_date);
CREATE INDEX idx_shipment_status     ON Shipment (status);
