CREATE OR REPLACE PROCEDURE rpt_fine_payment_trends_method
IS
  -- Cursor for distinct payment methods
  CURSOR c_payment_methods IS
    SELECT DISTINCT paymentMethod FROM Payments ORDER BY paymentMethod;

  -- Cursor for monthly payment trends per method
  CURSOR c_monthly_trends(v_method VARCHAR2) IS
    SELECT
      TO_CHAR(paymentDate, 'YYYY-MM') AS payment_month,
      SUM(payAmount) AS total_payments,
      SUM(CASE WHEN paymentType = 'Fines' THEN payAmount ELSE 0 END) AS paid_amount,
      COUNT(*) AS payment_count
    FROM Payments
    WHERE paymentMethod = v_method
      AND paymentDate BETWEEN TO_DATE('01-01-2024', 'DD-MM-YYYY') 
                          AND TO_DATE('30-06-2024', 'DD-MM-YYYY')
    GROUP BY TO_CHAR(paymentDate, 'YYYY-MM')
    ORDER BY payment_month;

  -- Cursor for yearly payment trends per method
  CURSOR c_yearly_trends(v_method VARCHAR2) IS
    SELECT
      TO_CHAR(paymentDate, 'YYYY') AS payment_year,
      SUM(payAmount) AS total_payments,
      SUM(CASE WHEN paymentType = 'Fines' THEN payAmount ELSE 0 END) AS paid_amount,
      COUNT(*) AS payment_count
    FROM Payments
    WHERE paymentMethod = v_method
      AND paymentDate BETWEEN TO_DATE('01-01-2024', 'DD-MM-YYYY') 
                          AND TO_DATE('30-06-2024', 'DD-MM-YYYY')
    GROUP BY TO_CHAR(paymentDate, 'YYYY')
    ORDER BY payment_year;

  -- Variable to hold total from function
  v_total_fines NUMBER;
BEGIN
  -- Report Header
  DBMS_OUTPUT.PUT_LINE(RPAD('=', 10, '=') || ' Fine Payment Trends Report (Jan to Jun 2024) ' || RPAD('=', 10, '='));

  -- Outer loop for each payment method
  FOR method_rec IN c_payment_methods LOOP
    DBMS_OUTPUT.PUT_LINE(CHR(10) || 'Payment Method: ' || method_rec.paymentMethod);
    
    -- Call the function and show total fines paid
    v_total_fines := get_paid_amount(method_rec.paymentMethod,
                                     TO_DATE('01-01-2024', 'DD-MM-YYYY'),
                                     TO_DATE('30-06-2024', 'DD-MM-YYYY'));
    DBMS_OUTPUT.PUT_LINE('>> Total Fines Paid (Using Function): RM ' || TO_CHAR(v_total_fines, '9999.99'));
    
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 66, '-'));
    DBMS_OUTPUT.PUT_LINE('|  Month  |  Total Payments (RM)  | Payment Count |  Paid (RM)   |');
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 66, '-'));

    -- Monthly trends loop
    FOR month_rec IN c_monthly_trends(method_rec.paymentMethod) LOOP
      DBMS_OUTPUT.PUT_LINE(
        RPAD('| ' || month_rec.payment_month, 10) ||
        RPAD('|      RM ' || TO_CHAR(month_rec.total_payments, '9999.99'), 24) ||
        RPAD('|   ' || TO_CHAR(month_rec.payment_count, '9999'), 16) ||
        RPAD('| RM ' || TO_CHAR(month_rec.paid_amount, '9999.99'), 14) || ' |'
      );
    END LOOP;
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 66, '-'));

    -- Yearly section
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 66, '-'));
    DBMS_OUTPUT.PUT_LINE('|  Year   |  Total Payments (RM)  | Payment Count |  Paid (RM)   |');
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 66, '-'));

    FOR year_rec IN c_yearly_trends(method_rec.paymentMethod) LOOP
      DBMS_OUTPUT.PUT_LINE(
        RPAD('|  ' || year_rec.payment_year, 10) ||
        RPAD('|      RM ' || TO_CHAR(year_rec.total_payments, '9999.99'), 24) ||
        RPAD('|   ' || TO_CHAR(year_rec.payment_count, '9999'), 16) ||
        RPAD('| RM ' || TO_CHAR(year_rec.paid_amount, '9999.99'), 14) || ' |'
      );
    END LOOP;
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 66, '-'));
  END LOOP;
END;
/

SET SERVEROUTPUT ON;

BEGIN
  rpt_fine_payment_trends_method;
END;
/ 