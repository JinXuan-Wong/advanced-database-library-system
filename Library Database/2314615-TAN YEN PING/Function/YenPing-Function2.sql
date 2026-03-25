CREATE OR REPLACE FUNCTION Get_Extension_Percent(
    p_member_id IN VARCHAR2,
    p_month IN VARCHAR2
) RETURN NUMBER IS
    v_total_extensions NUMBER;
    v_member_extensions NUMBER;
BEGIN
    -- Calculate total loan extensions in the given month
    SELECT COUNT(*)
    INTO v_total_extensions
    FROM BorrowedBooks
    WHERE TO_CHAR(returnDate, 'MON-YYYY') = UPPER(p_month)
      AND extendStatus = 'Approved';

    -- Calculate the number of extensions for the specific member in the given month
    SELECT COUNT(*)
    INTO v_member_extensions
    FROM BorrowedBooks
    WHERE memberId = p_member_id
      AND TO_CHAR(returnDate, 'MON-YYYY') = UPPER(p_month)
      AND extendStatus = 'Approved';

    -- Calculate the percentage contribution
    IF v_total_extensions > 0 THEN
        RETURN (v_member_extensions / v_total_extensions) * 100;
    ELSE
        RETURN 0;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
END;
/
