-- Implement Data Quality Check Null data, data type mismatch, patterns, outliers 
CREATE OR REPLACE LIVE TABLE decisionminds.dlt.silver_order
COMMENT "Cleaned silver orders with strict data quality checks"
TBLPROPERTIES ("quality" = "silver")
AS
SELECT
  CAST(regexp_replace(order_id, '[^0-9]', '') AS BIGINT)        AS order_id,
  CAST(regexp_extract(customer_id, '^([0-9]+)', 1) AS BIGINT)  AS customer_id,
  CAST(order_date AS DATE)                                     AS order_date,
  CAST(regexp_replace(amount, '[^0-9.]', '') AS DECIMAL(10,2)) AS amount
FROM decisionminds.dlt.bronze_orders
WHERE
  -- NULL & TYPE CHECKS
  order_id IS NOT NULL
  AND customer_id IS NOT NULL
  AND order_date IS NOT NULL
  AND amount IS NOT NULL

  -- PATTERN VALIDATION
  AND regexp_replace(order_id, '[^0-9]', '') RLIKE '^[0-9]+$'
  AND regexp_extract(customer_id, '^([0-9]+)', 1) <> ''

  -- BUSINESS RULES
  AND CAST(regexp_replace(amount, '[^0-9.]', '') AS DECIMAL(10,2)) >= 0

  -- OUTLIER CONTROL (BUSINESS THRESHOLD)
  AND CAST(regexp_replace(amount, '[^0-9.]', '') AS DECIMAL(10,2)) <= 100000;





CREATE OR REPLACE LIVE TABLE decisionminds.dlt.silver_customer
COMMENT "Cleaned silver customers with strict data quality checks"
TBLPROPERTIES ("quality" = "silver")
AS
SELECT
  CAST(regexp_replace(customer_id, '[^0-9]', '') AS BIGINT) AS customer_id,

  initcap(trim(regexp_replace(first_name, '[^a-zA-Z]', ''))) AS first_name,
  initcap(trim(regexp_replace(last_name, '[^a-zA-Z]', '')))  AS last_name,

  lower(trim(email)) AS email,

  CAST(regexp_replace(phone, '[^0-9]', '') AS BIGINT) AS phone,

  CASE
    WHEN lower(trim(gender)) IN ('m','male') THEN 'Male'
    WHEN lower(trim(gender)) IN ('f','female') THEN 'Female'
    ELSE NULL
  END AS gender,

  initcap(trim(regexp_replace(city, '[^a-zA-Z ]', '')))  AS city,
  initcap(trim(regexp_replace(state, '[^a-zA-Z ]', ''))) AS state,

  CAST(regexp_replace(pincode, '[^0-9]', '') AS BIGINT) AS pincode,
  CAST(join_date AS DATE) AS join_date,

  initcap(trim(regexp_replace(customer_status, '[^a-zA-Z]', ''))) AS customer_status
FROM decisionminds.dlt.bronze_customers
WHERE
  -- NULL & TYPE CHECKS
  customer_id IS NOT NULL
  AND first_name IS NOT NULL
  AND last_name IS NOT NULL
  AND email IS NOT NULL
  AND phone IS NOT NULL
  AND gender IS NOT NULL
  AND city IS NOT NULL
  AND state IS NOT NULL
  AND pincode IS NOT NULL
  AND join_date IS NOT NULL
  AND customer_status IS NOT NULL

  -- PATTERN VALIDATION
  AND email RLIKE '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$'
  AND length(regexp_replace(phone, '[^0-9]', '')) = 10
  AND length(regexp_replace(pincode, '[^0-9]', '')) = 6

  -- DATE RANGE CHECK
  AND join_date <= current_date();
