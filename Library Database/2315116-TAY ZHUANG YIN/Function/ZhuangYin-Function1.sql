CREATE OR REPLACE FUNCTION get_paid_amount(
  p_method     IN VARCHAR2,
  p_start_date IN DATE,
  p_end_date   IN DATE
) RETURN NUMBER
IS
  v_total_paid NUMBER := 0;
BEGIN
  SELECT NVL(SUM(payAmount), 0)
  INTO v_total_paid
  FROM Payments
  WHERE paymentMethod = p_method
    AND paymentType = 'Fines'
    AND paymentDate BETWEEN p_start_date AND p_end_date;

  RETURN v_total_paid;
EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;
END;
/