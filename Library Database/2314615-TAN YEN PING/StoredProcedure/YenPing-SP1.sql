CREATE OR REPLACE PROCEDURE Add_Borrowed_Book (
    p_member_id IN VARCHAR2,
    p_copy_id IN VARCHAR2,
    p_borrow_date IN DATE,
    p_due_date IN DATE
) IS
    v_count_books      INTEGER;
    v_member_exists    INTEGER;
    v_copy_available   INTEGER;
    v_borrow_seq_val   NUMBER;
    v_borrow_id        VARCHAR2(10);
BEGIN
    -- Check if the member exists
    SELECT COUNT(*) INTO v_member_exists
    FROM Members
    WHERE memberId = p_member_id;

    IF v_member_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Member does not exist.');
    END IF;

    -- Check if the book copy is available for borrowing
    SELECT COUNT(*) INTO v_copy_available
    FROM BorrowedBooks
    WHERE copyId = p_copy_id
    AND returnStatus IN ('On loan', 'Overdue');

    IF v_copy_available > 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'The book copy is already borrowed or overdue.');
    END IF;

    -- Get the next sequence value and generate Borrow ID
    SELECT borrow_seq.NEXTVAL INTO v_borrow_seq_val FROM dual;
    v_borrow_id := 'BB' || TO_CHAR(v_borrow_seq_val);

    -- Insert the record using the generated borrow ID
    INSERT INTO BorrowedBooks (
        borrowId, memberId, copyId, borrowDate, dueDate, returnStatus
    ) VALUES (
        v_borrow_id, p_member_id, p_copy_id, p_borrow_date, p_due_date, 'On loan'
    );

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Book borrowed successfully for member: ' || p_member_id);
    DBMS_OUTPUT.PUT_LINE('Generated Borrow ID: ' || v_borrow_id);

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

SET SERVEROUTPUT ON;

-- Accept input from the user
ACCEPT member_id CHAR PROMPT 'Enter Member ID: '
ACCEPT copy_id CHAR PROMPT 'Enter Copy ID: '
ACCEPT borrow_date DATE PROMPT 'Enter Borrow Date (DD-MON-YYYY): '
ACCEPT due_date DATE PROMPT 'Enter Due Date (DD-MON-YYYY): '

-- Begin calling the procedure with the inputs
BEGIN
    Add_Borrowed_Book(
        p_member_id => '&member_id', 
        p_copy_id => '&copy_id', 
        p_borrow_date => TO_DATE('&borrow_date', 'DD-MON-YYYY'),
        p_due_date => TO_DATE('&due_date', 'DD-MON-YYYY')
    );
END;
/
