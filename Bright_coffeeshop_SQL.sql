SELECT
    *
FROM
    BRIGHT_COFFEE_SHOP.SALES.TRANSACTIONS --which products generated the most value, according to their store location?
SELECT
    DISTINCT product_category,
    transaction_qty * unit_price AS total_amount_sold,
    store_location
FROM
    BRIGHT_COFFEE_SHOP.SALES.TRANSACTIONS
ORDER BY
    total_amount_sold DESC;
--more details on the top 3 products
SELECT
    DISTINCT product_category,
    transaction_qty * unit_price AS total_amount_sold,
    store_location,
    product_detail
FROM
    BRIGHT_COFFEE_SHOP.SALES.TRANSACTIONS
ORDER BY
    total_amount_sold DESC;

    --which products generate the most revenue?
SELECT
    product_category,
    product_detail,
    SUM(transaction_qty * unit_price) as total_revenue,
    COUNT(*) as total_transactions,
    SUM(transaction_qty) as total_units_sold
FROM
    BRIGHT_COFFEE_SHOP.SALES.TRANSACTIONS
GROUP BY
    product_category,
    product_detail
ORDER BY
    total_revenue DESC
LIMIT
    3;
--PRODUCT WITH MOST REVENUE PER MONTH
SELECT
    YEAR(transaction_date) as year,
    MONTH(transaction_date) as month,
    MONTHNAME(transaction_date) as month_name,
    product_category,
    product_detail,
    SUM(transaction_qty * unit_price) as total_revenue,
    COUNT(*) as total_transactions,
    SUM(transaction_qty) as total_units_sold
FROM
    BRIGHT_COFFEE_SHOP.SALES.TRANSACTIONS
GROUP BY
    YEAR(transaction_date),
    MONTH(transaction_date),
    MONTHNAME(transaction_date),
    product_category,
    product_detail
ORDER BY
    year,
    month,
    total_revenue DESC
LIMIT
    3;
    --or
    WITH monthly_top_products AS (
        SELECT
            YEAR(transaction_date) as year,
            MONTH(transaction_date) as month,
            MONTHNAME(transaction_date) as month_name,
            product_category,
            product_detail,
            SUM(transaction_qty * unit_price) as total_revenue,
            COUNT(*) as total_transactions,
            SUM(transaction_qty) as total_units_sold,
            ROW_NUMBER() OVER (
                PARTITION BY YEAR(transaction_date),
                MONTH(transaction_date)
                ORDER BY
                    SUM(transaction_qty * unit_price) DESC
            ) as rank
        FROM
            bright_coffee_shop.sales.transactions
        GROUP BY
            YEAR(transaction_date),
            MONTH(transaction_date),
            MONTHNAME(transaction_date),
            product_category,
            product_detail
    )
SELECT
    year,
    month,
    month_name,
    product_category,
    product_detail,
    total_revenue,
    total_transactions,
    total_units_sold
FROM
    monthly_top_products
WHERE
    rank = 1
ORDER BY
    year,
    month;
--when was the last transaction?
SELECT
    TRANSACTION_DATE,
    STORE_ID
FROM
    BRIGHT_COFFEE_SHOP.SALES.TRANSACTIONS
ORDER BY
    TRANSACTION_DATE ASC;
--monthly bucket
SELECT
    YEAR(transaction_date) as year,
    MONTHNAME(transaction_date) as month_name,
    SUM(transaction_qty * unit_price) as total_revenue
FROM
    BRIGHT_COFFEE_SHOP.SALES.TRANSACTIONS
GROUP BY
    YEAR(transaction_date),
    MONTHNAME(transaction_date),
    MONTH(transaction_date)
ORDER BY
    year,
    MONTH(transaction_date);
--How many stores are there?
SELECT
    DISTINCT Store_id,
    store_location
FROM
    BRIGHT_COFFEE_SHOP.SALES.TRANSACTIONS --which store has sold the most PRODUCTS?
SELECT
    store_id,
    store_location,
    SUM(transaction_qty * unit_price) as total_revenue,
    COUNT(*) as total_transactions,
    AVG(transaction_qty * unit_price) as avg_transaction_value
FROM
    BRIGHT_COFFEE_SHOP.SALES.TRANSACTIONS
GROUP BY
    store_id,
    store_location
ORDER BY
    total_revenue DESC;
--what is Astoria's most sold product?
SELECT
    store_location,
    product_detail,
    product_category,
    transaction_qty * unit_price AS total_amount_sold
FROM
    BRIGHT_COFFEE_SHOP.SALES.TRANSACTIONS
HAVING
    store_location = 'Astoria'
ORDER BY
    total_amount_sold DESC --WHAT TIME DOES EACH STORE OPEN?
SELECT
    STORE_LOCATION,
    MIN(TRANSACTION_TIME) AS OPENNING_TIME
FROM
    BRIGHT_COFFEE_SHOP.SALES.TRANSACTIONS
GROUP BY
    STORE_LOCATION --WHEN DOES EACH STORE CLOSE?
SELECT
    STORE_LOCATION,
    MAX(TRANSACTION_TIME) AS OPENNING_TIME
FROM
    BRIGHT_COFFEE_SHOP.SALES.TRANSACTIONS
GROUP BY
    STORE_LOCATION --TIME BUCKET
SELECT
    store_id,
    store_location,
    CASE
        WHEN HOUR(transaction_time) BETWEEN 6
        AND 11 THEN 'Morning'
        WHEN HOUR(transaction_time) BETWEEN 12
        AND 17 THEN 'Afternoon'
        WHEN HOUR(transaction_time) BETWEEN 18
        AND 23 THEN 'Evening'
        ELSE 'Night'
    END as time_bucket,
    COUNT(*) as total_transactions,
    SUM(transaction_qty * unit_price) as total_revenue,
    AVG(transaction_qty * unit_price) as avg_transaction_value
FROM
    bright_coffee_shop.sales.transactions
GROUP BY
    store_id,
    store_location,
    CASE
        WHEN HOUR(transaction_time) BETWEEN 6
        AND 11 THEN 'Morning'
        WHEN HOUR(transaction_time) BETWEEN 12
        AND 17 THEN 'Afternoon'
        WHEN HOUR(transaction_time) BETWEEN 18
        AND 23 THEN 'Evening'
        ELSE 'Night'
    END
ORDER BY
    store_id,
    total_revenue DESC;
--WHAT SORT OF PRODUCTS DO THESE STORES SELL?
SELECT
    DISTINCT PRODUCT_CATEGORY,
    store_location
FROM
    BRIGHT_COFFEE_SHOP.SALES.TRANSACTIONS --what time is has the most transactions, on average?
SELECT
    HOUR(transaction_time) as hour_of_day,
    COUNT(TRANSACTION_ID) as total_transactions,
    COUNT(transaction_date) as avg_transactions_per_day
FROM
    BRIGHT_COFFEE_SHOP.SALES.TRANSACTIONS
GROUP BY
    HOUR(transaction_time)
ORDER BY
    avg_transactions_per_day DESC;
--best performance time for each store
    WITH hourly_transactions AS (
        SELECT
            HOUR(transaction_time) as hour_of_day,
            COUNT(*) as transaction_count
        FROM
            BRIGHT_COFFEE_SHOP.SALES.TRANSACTIONS
        GROUP BY
            HOUR(transaction_time)
    ),
    peak_hours AS (
        SELECT
            hour_of_day,
            transaction_count,
            RANK() OVER (
                ORDER BY
                    transaction_count DESC
            ) as rank
        FROM
            hourly_transactions
    )
SELECT
    hour_of_day,
    CASE
        WHEN hour_of_day = 0 THEN '12:00 AM'
        WHEN hour_of_day < 12 THEN CONCAT(hour_of_day, ':00 AM')
        WHEN hour_of_day = 12 THEN '12:00 PM'
        ELSE CONCAT(hour_of_day - 12, ':00 PM')
    END as peak_time,
    transaction_count as total_transactions,
    ROUND(
        transaction_count * 100.0 / (
            SELECT
                SUM(transaction_count)
            FROM
                hourly_transactions
        ),
        2
    ) as percentage_of_total
FROM
    peak_hours
WHERE
    rank = 1;
--which products sell more within which time?
SELECT
    PRODUCT_CATEGORY,
    HOUR(transaction_time) as hour_of_day,
    COUNT(TRANSACTION_ID) as total_transactions,
    COUNT(transaction_date) as avg_transactions_per_day
FROM
    BRIGHT_COFFEE_SHOP.SALES.TRANSACTIONS
GROUP BY
    HOUR(transaction_time),
    PRODUCT_CATEGORY
ORDER BY
    avg_transactions_per_day DESC
LIMIT
    10;
--both peak and lull hours
SELECT
    HOUR(transaction_time) as hour_of_day,
    CASE
        WHEN HOUR(transaction_time) = 6 THEN '6:00 AM'
        WHEN HOUR(transaction_time) < 12 THEN CONCAT(HOUR(transaction_time), ':00 AM')
        WHEN HOUR(transaction_time) = 12 THEN '12:00 PM'
        ELSE CONCAT(HOUR(transaction_time) - 12, ':00 PM')
    END as time_period,
    COUNT(*) as total_transactions,
    COUNT(DISTINCT transaction_date) as days_with_data,
    ROUND(
        COUNT(*) * 1.0 / COUNT(DISTINCT transaction_date),
        2
    ) as avg_transactions_per_day,
    ROUND(
        COUNT(*) * 100.0 / (
            SELECT
                COUNT(*)
            FROM
                bright_coffee_shop.sales.transactions
            WHERE
                HOUR(transaction_time) BETWEEN 6
                AND 21
        ),
        2
    ) as percentage_of_business_hours
FROM
    bright_coffee_shop.sales.transactions
WHERE
    HOUR(transaction_time) BETWEEN 6
    AND 21
GROUP BY
    HOUR(transaction_time)
ORDER BY
    hour_of_day;
--WHICH PRODUCTS SELL LESS IN TIME INTERVALS
SELECT
    PRODUCT_CATEGORY,
    HOUR(transaction_time) as hour_of_day,
    COUNT(TRANSACTION_ID) as total_transactions,
    COUNT(transaction_date) as avg_transactions_per_day
FROM
    BRIGHT_COFFEE_SHOP.SALES.TRANSACTIONS
GROUP BY
    HOUR(transaction_time),
    PRODUCT_CATEGORY
ORDER BY
    avg_transactions_per_day ASC;
--WHICH PRODUCTS MAKE LESS MONEY
SELECT
    PRODUCT_CATEGORY,
    SUM(UNIT_PRICE) AS TOTAL_AMOUNT_SOLD
FROM
    BRIGHT_COFFEE_SHOP.SALES.TRANSACTIONS
GROUP BY
    PRODUCT_CATEGORY
ORDER BY
    TOTAL_AMOUNT_SOLD ASC;
--WHICH PRODUCTS MAKE MORE MONEY
SELECT
    PRODUCT_CATEGORY,
    PRODUCT_DETAIL,
    SUM(UNIT_PRICE) AS TOTAL_AMOUNT_SOLD
FROM
    BRIGHT_COFFEE_SHOP.SALES.TRANSACTIONS
GROUP BY
    PRODUCT_CATEGORY,
    PRODUCT_DETAIL
ORDER BY
    TOTAL_AMOUNT_SOLD DESC;
--quantity of products sold
SELECT
    product_category,
    SUM(transaction_qty) as total_quantity_sold,
    COUNT(*) as total_transactions,
    ROUND(AVG(transaction_qty), 2) as avg_quantity_per_transaction,
    ROUND(
        SUM(transaction_qty) * 100.0 / (
            SELECT
                SUM(transaction_qty)
            FROM
                BRIGHT_COFFEE_SHOP.SALES.TRANSACTIONS
        ),
        2
    ) as percentage_of_total_quantity
FROM
    BRIGHT_COFFEE_SHOP.SALES.TRANSACTIONS
GROUP BY
    product_category
ORDER BY
    total_quantity_sold DESC;