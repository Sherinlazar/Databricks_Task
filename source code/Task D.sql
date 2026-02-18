
CREATE or REFRESH live table decisionminds.dlt.bronze_orders  AS
SELECT *
FROM read_files(
  'abfss://externallocation@bricksstorageaccount1.dfs.core.windows.net/source/raw_order',
  format => 'csv',
  header => true,
  inferSchema => true
);

CREATE or REFRESH live table decisionminds.dlt.bronze_customers  AS
SELECT *
FROM read_files(
  'abfss://externallocation@bricksstorageaccount1.dfs.core.windows.net/source/raw_customer',
  format => 'csv',
  header => true,
  inferSchema => true
);

CREATE OR REFRESH LIVE TABLE decisionminds.dlt.silver_orders


(CONSTRAINT order_id_not_null     EXPECT (order_id IS NOT NULL),
CONSTRAINT customer_id_not_null  EXPECT (customer_id IS NOT NULL),
CONSTRAINT order_date_not_null   EXPECT (order_date IS NOT NULL),
CONSTRAINT amount_not_null       EXPECT (amount IS NOT NULL),

CONSTRAINT positive_amount       EXPECT (amount >= 0),
CONSTRAINT reasonable_amount     EXPECT (amount <= 100000)
)
AS
SELECT
  CAST(regexp_replace(order_id, '[^0-9]', '') AS BIGINT)        AS order_id,
  CAST(regexp_extract(customer_id, '^([0-9]+)', 1) AS BIGINT)  AS customer_id,
  CAST(order_date AS DATE)                                     AS order_date,
  CAST(regexp_replace(amount, '[^0-9.]', '') AS DECIMAL(10,2)) AS amount
FROM decisionminds.dlt.bronze_orders;



CREATE OR REFRESH LIVE TABLE decisionminds.dlt.silver_customers
(
  CONSTRAINT customer_id_not_null    EXPECT (customer_id IS NOT NULL),
  CONSTRAINT first_name_not_null     EXPECT (first_name IS NOT NULL),
  CONSTRAINT last_name_not_null      EXPECT (last_name IS NOT NULL),
  CONSTRAINT email_not_null          EXPECT (email IS NOT NULL),
  CONSTRAINT phone_not_null          EXPECT (phone IS NOT NULL),
  CONSTRAINT valid_gender            EXPECT (gender IN ('Male', 'Female')),
  CONSTRAINT city_not_null           EXPECT (city IS NOT NULL),
  CONSTRAINT state_not_null          EXPECT (state IS NOT NULL),
  CONSTRAINT pincode_not_null        EXPECT (pincode IS NOT NULL),
  CONSTRAINT join_date_not_null      EXPECT (join_date IS NOT NULL),
  CONSTRAINT customer_status_not_null EXPECT (customer_status IS NOT NULL)
)
AS
SELECT
  CAST(TRIM(regexp_replace(customer_id, '[^0-9]', '')) AS BIGINT)  AS customer_id,
  INITCAP(TRIM(regexp_replace(first_name, '[^a-zA-Z]', '')))       AS first_name,
  INITCAP(TRIM(regexp_replace(last_name, '[^a-zA-Z]', '')))        AS last_name,
  LOWER(TRIM(regexp_replace(email, '[^a-zA-Z0-9@._-]', '')))       AS email,
  CAST(TRIM(regexp_replace(phone, '[^0-9]', '')) AS BIGINT)        AS phone,
  CASE
    WHEN LOWER(TRIM(gender)) IN ('m', 'male') THEN 'Male'
    WHEN LOWER(TRIM(gender)) IN ('f', 'female') THEN 'Female'
    ELSE NULL
  END                                                             AS gender,
  INITCAP(TRIM(regexp_replace(city, '[^a-zA-Z ]', '')))            AS city,
  INITCAP(TRIM(regexp_replace(state, '[^a-zA-Z ]', '')))           AS state,
  CAST(TRIM(regexp_replace(pincode, '[^0-9]', '')) AS BIGINT)      AS pincode,
  CAST(TRIM(regexp_replace(join_date, '[^0-9-]', '')) AS DATE)     AS join_date,
  INITCAP(TRIM(regexp_replace(customer_status, '[^a-zA-Z]', ''))) AS customer_status
FROM decisionminds.dlt.bronze_customers;


  
CREATE OR REFRESH LIVE TABLE decisionminds.dlt.gold_daily_sales_summary
(
  CONSTRAINT order_date_not_null     EXPECT (order_date IS NOT NULL),
  CONSTRAINT total_orders_positive   EXPECT (total_orders > 0),
  CONSTRAINT total_revenue_positive  EXPECT (total_revenue >= 0),
  CONSTRAINT unique_customers_valid  EXPECT (unique_customers > 0)
)
AS
SELECT
  o.order_date                                AS order_date,
  COUNT(DISTINCT o.order_id)                  AS total_orders,
  COUNT(DISTINCT o.customer_id)               AS unique_customers,
  ROUND(SUM(o.amount), 2)                     AS total_revenue,
  ROUND(AVG(o.amount), 2)                     AS avg_order_value
FROM decisionminds.dlt.silver_orders o
JOIN decisionminds.dlt.silver_customers c
  ON o.customer_id = c.customer_id
GROUP BY o.order_date;
