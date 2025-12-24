-- Implement Data Quality Check Null data, data type mismatch, patterns, outliers 
create or replace live table decisionminds.dlt.silver_order as
select
  try_cast(regexp_replace(order_id, '[^0-9]', '') as bigint) as order_id,
  try_cast(regexp_extract(customer_id, '^([0-9]+)', 1) as bigint) as customer_id,
  to_date(order_date) as order_date,
  try_cast(regexp_replace(amount, '[^0-9.]', '') as decimal(10,2)) as amount
from decisionminds.dlt.bronze_orders
where
  try_cast(regexp_replace(order_id, '[^0-9]', '') as bigint) is not null
  and regexp_extract(customer_id, '^([0-9]+)', 1) <> ''
  and try_cast(regexp_extract(customer_id, '^([0-9]+)', 1) as bigint) is not null
  and regexp_replace(amount, '[^0-9.]', '') <> ''
  and try_cast(regexp_replace(amount, '[^0-9.]', '') as decimal(10,2)) is not null
  and try_cast(regexp_replace(amount, '[^0-9.]', '') as decimal(10,2)) >= 0;





create or replace live table decisionminds.dlt.silver_customer as
select
  try_cast(trim(regexp_replace(customer_id, '[^0-9]', '')) as bigint) as customer_id,
  trim(regexp_replace(first_name, '[^a-zA-Z]', '')) as first_name,
  trim(regexp_replace(last_name, '[^a-zA-Z]', '')) as last_name,
  trim(regexp_replace(email, '[^a-zA-Z0-9@._-]', '')) as email,
  try_cast(trim(regexp_replace(phone, '[^0-9]', '')) as bigint) as phone,
  CASE
    WHEN LOWER(TRIM(gender)) IN ('m', 'male') THEN 'Male'
    WHEN LOWER(TRIM(gender)) IN ('f', 'female') THEN 'Female'
    ELSE NULL
  END AS gender,
  initcap(trim(regexp_replace(city, '[^a-zA-Z ]', ''))) as city,
  initcap(trim(regexp_replace(state, '[^a-zA-Z ]', ''))) as state,
  try_cast(trim(regexp_replace(pincode, '[^0-9]', '')) as bigint) as pincode,
  try_cast(trim(regexp_replace(join_date, '[^0-9-]', '')) as date) as join_date,
  initcap(trim(regexp_replace(customer_status, '[^a-zA-Z]', ''))) as customer_status
from decisionminds.dlt.bronze_customers
where 
  try_cast(trim(regexp_replace(customer_id, '[^0-9]', '')) as bigint) is not null 
  and trim(regexp_replace(first_name, '[^a-zA-Z]', '')) <> ''
  and trim(regexp_replace(last_name, '[^a-zA-Z]', '')) <> ''
  and trim(regexp_replace(email, '[^a-zA-Z0-9@._-]', '')) <> ''
  and try_cast(trim(regexp_replace(phone, '[^0-9]', '')) as bigint) is not null
  and trim(regexp_replace(gender, '[^a-zA-Z]', '')) <> ''
  and trim(regexp_replace(city, '[^a-zA-Z ]', '')) <> ''
  and trim(regexp_replace(state, '[^a-zA-Z ]', '')) <> ''
  and try_cast(trim(regexp_replace(pincode, '[^0-9]', '')) as bigint) is not null
  and try_cast(trim(regexp_replace(join_date, '[^0-9-]', '')) as date) is not null
  and trim(regexp_replace(customer_status, '[^a-zA-Z]', '')) <> ''