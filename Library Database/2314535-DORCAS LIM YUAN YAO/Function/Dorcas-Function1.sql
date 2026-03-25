CREATE OR REPLACE FUNCTION fn_borrowed_book_count(p_memberId IN VARCHAR2)
RETURN NUMBER
IS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM BorrowedBooks
    WHERE memberId = p_memberId;

    DBMS_OUTPUT.PUT_LINE('Books not yet returned:');
    FOR rec IN (
        SELECT copyId
        FROM BorrowedBooks
        WHERE memberId = p_memberId
          AND returnDate IS NULL
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(' - ' || rec.copyId);
    END LOOP;

    RETURN v_count;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
    WHEN OTHERS THEN
        RETURN -1;
END;
/
