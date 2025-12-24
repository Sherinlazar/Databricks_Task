DECLARE VARIABLE v_total DECIMAL(38,18);

BEGIN

BEGIN
SET v_total = (
SELECT
SUM(amount)
FROM orders);
  DBMS_OUTPUT.PUT_LINE('Total Amount: ' || v_total);
END;
