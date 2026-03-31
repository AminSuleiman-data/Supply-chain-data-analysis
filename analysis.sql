-- =========================
-- DATA UNDERSTANDING
-- =========================

SELECT *
FROM raw_supply_chain
LIMIT 100;


SELECT COUNT(*) AS total_rows
FROM raw_supply_chain;
-- =========================
-- CREATE CLEAN TABLE
-- =========================

CREATE OR REPLACE TABLE clean_supply_chain AS

SELECT
    ORDER_ID,
    CUSTOMER_ID,
    ORDER_STATUS,
    DELIVERY_STATUS,
    LATE_DELIVERY_RISK,
    CATEGORY_NAME,
    PRODUCT_NAME,
    SALES,
    ORDER_ITEM_TOTAL,
    ORDER_ITEM_QUANTITY,
    ORDER_ITEM_DISCOUNT,
    ORDER_ITEM_PROFIT_RATIO,
    "Days for shipping (real)" AS shipping_days_real,
    "Days for shipment (scheduled)" AS shipping_days_scheduled,
    CUSTOMER_CITY,
    CUSTOMER_STATE,
    CUSTOMER_COUNTRY,
    MARKET,
    ORDER_REGION
FROM raw_supply_chain;
SELECT *
FROM clean_supply_chain
LIMIT 10;
-- =========================
-- SECTION 2: DATA CLEANING
-- =========================


-- 1️⃣ CHECK NULL VALUES
SELECT
    COUNT(*) AS total_rows,
    COUNT(ORDER_ID) AS order_id_not_null,
    COUNT(CUSTOMER_ID) AS customer_id_not_null,
    COUNT(SALES) AS sales_not_null,
    COUNT(ORDER_ITEM_TOTAL) AS total_not_null
FROM clean_supply_chain;

-- =========================


-- 3️⃣ CHECK DUPLICATES
SELECT ORDER_ID, COUNT(*) AS duplicate_count
FROM clean_supply_chain
GROUP BY ORDER_ID
HAVING COUNT(*) > 1;


-- ==================
-- 5️⃣ REMOVE NEGATIVE VALUES
DELETE FROM clean_supply_chain
WHERE SALES < 0
   OR ORDER_ITEM_TOTAL < 0;


-- =========================
-- SECTION 3: DATA ANALYSIS
-- =========================

-- 2️⃣ TOTAL UNIQUE ORDERS
SELECT COUNT(DISTINCT ORDER_ID) AS total_orders
FROM clean_supply_chain;


-- =========================

-- 3️⃣ DELIVERY STATUS (ORDERS)
SELECT
    DELIVERY_STATUS,
    COUNT(DISTINCT ORDER_ID) AS total_orders
FROM clean_supply_chain
GROUP BY DELIVERY_STATUS
ORDER BY total_orders DESC;


-- =========================

-- 4️⃣ LATE DELIVERY RISK
SELECT
    LATE_DELIVERY_RISK,
    COUNT(DISTINCT ORDER_ID) AS total_orders
FROM clean_supply_chain
GROUP BY LATE_DELIVERY_RISK;
-- =========================
-- PROFIT vs DELIVERY STATUS
-- =========================

SELECT
    DELIVERY_STATUS,
    ROUND(SUM(ORDER_ITEM_TOTAL), 2) AS total_revenue,
    ROUND(AVG(ORDER_ITEM_PROFIT_RATIO), 2) AS avg_profit_ratio
FROM clean_supply_chain
GROUP BY DELIVERY_STATUS
ORDER BY total_revenue DESC;


-- =========================
-- PROFIT vs LATE DELIVERY
-- =========================

SELECT
    LATE_DELIVERY_RISK,
    ROUND(SUM(ORDER_ITEM_TOTAL), 2) AS total_revenue,
    ROUND(AVG(ORDER_ITEM_PROFIT_RATIO), 2) AS avg_profit_ratio
FROM clean_supply_chain
GROUP BY LATE_DELIVERY_RISK;
-- =========================
-- LATE DELIVERY RATE BY REGION
-- =========================

SELECT
    ORDER_REGION,
    COUNT(DISTINCT ORDER_ID) AS total_orders,

    COUNT(DISTINCT CASE 
        WHEN LATE_DELIVERY_RISK = 1 THEN ORDER_ID 
    END) AS late_orders,

    ROUND(
        COUNT(DISTINCT CASE 
            WHEN LATE_DELIVERY_RISK = 1 THEN ORDER_ID 
        END)
        / COUNT(DISTINCT ORDER_ID),
        2
    ) AS late_rate

FROM raw_supply_chain
GROUP BY ORDER_REGION
ORDER BY late_rate DESC;

-- =========================
-- LATE DELIVERY BY SHIPPING MODE
-- =========================
SELECT
    SHIPPING_MODE,
    COUNT(DISTINCT ORDER_ID) AS total_orders,

    COUNT(DISTINCT CASE 
        WHEN LATE_DELIVERY_RISK = 1 THEN ORDER_ID 
    END) AS late_orders,

    ROUND(
        COUNT(DISTINCT CASE 
            WHEN LATE_DELIVERY_RISK = 1 THEN ORDER_ID 
        END)
        / COUNT(DISTINCT ORDER_ID),
        2
    ) AS late_rate

FROM raw_supply_chain
GROUP BY SHIPPING_MODE
ORDER BY late_rate DESC;
-- =========================
-- TOP SHIPPING MODE + REGION ISSUES
-- =========================

SELECT
    ORDER_REGION,
    SHIPPING_MODE,

    COUNT(DISTINCT ORDER_ID) AS total_orders,

    COUNT(DISTINCT CASE 
        WHEN LATE_DELIVERY_RISK = 1 THEN ORDER_ID 
    END) AS late_orders,

    ROUND(
        COUNT(DISTINCT CASE 
            WHEN LATE_DELIVERY_RISK = 1 THEN ORDER_ID 
        END)
        / COUNT(DISTINCT ORDER_ID),
        2
    ) AS late_rate

FROM raw_supply_chain

GROUP BY ORDER_REGION, SHIPPING_MODE

HAVING COUNT(DISTINCT ORDER_ID) > 1000  
ORDER BY late_rate DESC

LIMIT 10;
-- =========================
-- PROFIT IMPACT OF LATE DELIVERY
-- =========================

SELECT
    LATE_DELIVERY_RISK,

    COUNT(DISTINCT ORDER_ID) AS total_orders,

    ROUND(SUM(ORDER_ITEM_TOTAL), 2) AS total_revenue,

    ROUND(AVG(ORDER_ITEM_PROFIT_RATIO), 2) AS avg_profit_ratio

FROM raw_supply_chain

GROUP BY LATE_DELIVERY_RISK;
SELECT *
FROM raw_supply_chain;

