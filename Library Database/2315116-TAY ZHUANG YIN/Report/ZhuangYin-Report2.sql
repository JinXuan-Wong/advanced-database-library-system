CREATE OR REPLACE PROCEDURE rpt_unpaid_fine_analytics
IS
  -- Cursor for members with at least one unpaid fine
  CURSOR c_members IS
    SELECT DISTINCT m.memberId, m.memberName, m.memberTel, m.memberEmail
    FROM Members m
    JOIN BorrowedBooks b ON m.memberId = b.memberId
    JOIN Fines f ON f.borrowId = b.borrowId
    WHERE f.fineStatus = 'Unpaid';

  -- Nested cursor: Unpaid fine details per member
  CURSOR c_fine_details(p_memberId VARCHAR2) IS
    SELECT f.fineId,
           f.fineType,
           f.fineAmount,
           f.fineDate,
           f.fineStatus,
           b.dueDate,
           NVL(TO_CHAR(TRUNC(SYSDATE - b.dueDate)), '0') AS daysOverdue,
           bt.title
    FROM Fines f
    JOIN BorrowedBooks b ON f.borrowId = b.borrowId
    JOIN BookCopies bc ON b.copyId = bc.copyId
    JOIN BookTitles bt ON bc.bookId = bt.bookId
    WHERE b.memberId = p_memberId AND f.fineStatus = 'Unpaid';

  -- Cursor to check last payment info
  CURSOR c_last_payment(p_memberId VARCHAR2) IS
    SELECT MAX(paymentDate) AS lastPaymentDate
    FROM Payments
    WHERE memberId = p_memberId;

  v_totalUnpaid     NUMBER := 0;
  v_countUnpaid     NUMBER := 0;
  v_earliestFine    DATE;
  v_latestFine      DATE;
  v_paidFinesCount  NUMBER := 0;
  v_lastPaymentDate DATE;
  v_gapFromLastPayment NUMBER;

BEGIN
  DBMS_OUTPUT.PUT_LINE(RPAD('=', 33, '=') || ' UNPAID FINE OVERVIEW ' || RPAD('=', 33, '='));
  DBMS_OUTPUT.PUT_LINE(CHR(5));

  FOR r_mem IN c_members LOOP
    -- Reset per member
    v_totalUnpaid := 0;
    v_countUnpaid := 0;
    v_earliestFine := NULL;
    v_latestFine := NULL;
    v_paidFinesCount := 0;
    v_lastPaymentDate := NULL;
    v_gapFromLastPayment := NULL;

    -- Last payment information
    OPEN c_last_payment(r_mem.memberId);
    FETCH c_last_payment INTO v_lastPaymentDate;
    CLOSE c_last_payment;

    -- Use function to get paid fine count
    v_paidFinesCount := get_paid_fines_count(r_mem.memberId);

    -- Summary calculations for unpaid fines
    SELECT COUNT(*), SUM(f.fineAmount),
           MIN(f.fineDate), MAX(f.fineDate)
    INTO v_countUnpaid, v_totalUnpaid, v_earliestFine, v_latestFine
    FROM BorrowedBooks bb
    JOIN Fines f ON bb.borrowId = f.borrowId
    WHERE bb.memberId = r_mem.memberId
      AND f.fineStatus = 'Unpaid';

    IF v_lastPaymentDate IS NOT NULL THEN
      v_gapFromLastPayment := TRUNC(SYSDATE - v_lastPaymentDate);
    END IF;

    -- Output Member Header
    DBMS_OUTPUT.PUT_LINE(RPAD('=', 88, '='));
    DBMS_OUTPUT.PUT_LINE('MEMBER ID     : ' || r_mem.memberId);
    DBMS_OUTPUT.PUT_LINE('NAME          : ' || r_mem.memberName);
    DBMS_OUTPUT.PUT_LINE('EMAIL         : ' || r_mem.memberEmail);
    DBMS_OUTPUT.PUT_LINE('PHONE         : ' || r_mem.memberTel);
    DBMS_OUTPUT.PUT_LINE('UNPAID COUNT  : ' || v_countUnpaid);
    DBMS_OUTPUT.PUT_LINE('PAID FINES    : ' || v_paidFinesCount);
    DBMS_OUTPUT.PUT_LINE('TOTAL UNPAID  : RM ' || TO_CHAR(v_totalUnpaid, '9999.00'));
    DBMS_OUTPUT.PUT_LINE('EARLIEST FINE : ' || TO_CHAR(v_earliestFine, 'DD-MON-YYYY'));
    DBMS_OUTPUT.PUT_LINE('LATEST FINE   : ' || TO_CHAR(v_latestFine, 'DD-MON-YYYY'));
    DBMS_OUTPUT.PUT_LINE('LAST PAYMENT  : ' || NVL(TO_CHAR(v_lastPaymentDate, 'DD-MON-YYYY'), 'N/A'));
    DBMS_OUTPUT.PUT_LINE('GAP SINCE LAST PAYMENT: ' || NVL(v_gapFromLastPayment, 0) || ' DAY(S)');
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 88, '-'));
    DBMS_OUTPUT.PUT_LINE('FineID |                Book Title                |    Type    |  Amount  | Overdue Days');
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 88, '-'));

    -- Print unpaid fine
    FOR r_fine IN c_fine_details(r_mem.memberId) LOOP
      DBMS_OUTPUT.PUT_LINE(
        LPAD(r_fine.fineId, 6) || '   | ' ||
        RPAD(SUBSTR(r_fine.title, 1, 40), 40) || ' | ' || 
        RPAD(r_fine.fineType, 10) || ' | ' ||
        LPAD(TO_CHAR(r_fine.fineAmount, '9990.00'), 8) || ' |   ' ||
        LPAD(r_fine.daysOverdue, 5)
      );
    END LOOP;

    DBMS_OUTPUT.PUT_LINE(RPAD('=', 88, '='));
    DBMS_OUTPUT.PUT_LINE(CHR(10));
  END LOOP;
END;
/

SET SERVEROUTPUT ON;

BEGIN
  rpt_unpaid_fine_analytics;
END;
/ 