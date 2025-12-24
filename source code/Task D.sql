
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