CREATE OR REPLACE FUNCTION get_paid_fines_count(p_memberId VARCHAR2)
RETURN NUMBER
IS
  v_count NUMBER;
BEGIN
  SELECT COUNT(*)
  INTO v_count
  FROM BorrowedBooks bb
  JOIN Fines f ON bb.borrowId = f.borrowId
  WHERE bb.memberId = p_memberId
    AND f.fineStatus = 'Paid';

  RETURN v_count;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 0;
  WHEN OTHERS THEN
    RETURN -1;
END;
/