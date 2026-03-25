SET DEFINE OFF

CREATE OR REPLACE PROCEDURE AddFine (
    p_borrowId     IN BorrowedBooks.borrowId%TYPE,
    p_memberId     IN Members.memberId%TYPE,
    p_copyId       IN BookCopies.copyId%TYPE,
    p_fineType     IN Fines.fineType%TYPE  
)
IS
    v_fineAmount     NUMBER(8,2);
    v_bookPrice      BookTitles.price%TYPE;
    v_fineIdNum      NUMBER;
    v_fineId         VARCHAR2(4);
    v_returnStatus   BorrowedBooks.returnStatus%TYPE;
    v_bookStatus     BookCopies.bookStatus%TYPE;
    v_fineExists     NUMBER := 0;
BEGIN
    -- Validate borrow record
    BEGIN
        SELECT returnStatus INTO v_returnStatus
        FROM BorrowedBooks
        WHERE borrowId = p_borrowId AND memberId = p_memberId;

        IF v_returnStatus NOT IN ('Overdue', 'Lost') THEN
            RAISE_APPLICATION_ERROR(-20010, 'Error: Cannot apply fine. Invalid return status.');
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20011, 'Error: Borrow record not found for this member.');
    END;

    -- Prevent duplicate fine
    SELECT COUNT(*) INTO v_fineExists
    FROM Fines
    WHERE borrowId = p_borrowId AND fineType = p_fineType;

    IF v_fineExists > 0 THEN
        RAISE_APPLICATION_ERROR(-20012, 'Error: A fine of this type already exists for this borrow record.');
    END IF;

    -- Fine logic based on type
    IF p_fineType = 'Lost Book' THEN
        -- Get book price & status
        BEGIN
            SELECT bt.price, bc.bookStatus INTO v_bookPrice, v_bookStatus
            FROM BookTitles bt
            JOIN BookCopies bc ON bt.bookId = bc.bookId
            WHERE bc.copyId = p_copyId;

            IF v_bookStatus = 'unavailable' THEN
                RAISE_APPLICATION_ERROR(-20013, 'Error: Book is already marked as lost/unavailable.');
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20014, 'Error: Book copy not found.');
        END;

        v_fineAmount := v_bookPrice + 20;

        -- Mark book as unavailable
        UPDATE BookCopies
        SET bookStatus = 'unavailable'
        WHERE copyId = p_copyId;

    ELSIF p_fineType = 'Late Return' THEN
        -- Flat rate fine for late return
        v_fineAmount := 30;

    ELSE
        RAISE_APPLICATION_ERROR(-20016, 'Error: Invalid fine type.');
    END IF;

    -- Generate Fine ID using sequence and convert to VARCHAR2(4)
    SELECT fines_seq.NEXTVAL INTO v_fineIdNum FROM DUAL;
    v_fineId := 'F' || TO_CHAR(v_fineIdNum);

    -- Insert fine record
    INSERT INTO Fines (fineId, borrowId, fineType, fineAmount, fineDate, fineStatus)
    VALUES (v_fineId, p_borrowId, p_fineType, v_fineAmount, SYSDATE, 'Unpaid');

    DBMS_OUTPUT.PUT_LINE(p_fineType || ' fine added successfully.');
    DBMS_OUTPUT.PUT_LINE('Fine ID: ' || v_fineId || ' | Amount: RM' || v_fineAmount);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || SQLERRM);
END;
/

SET SERVEROUTPUT ON;

-- Accept information from user
ACCEPT borrow_id CHAR PROMPT 'Enter Borrow ID: '
ACCEPT member_id CHAR PROMPT 'Enter Member ID: '
ACCEPT copy_id CHAR PROMPT 'Enter Copy ID: '
ACCEPT fine_type CHAR PROMPT 'Enter Fine Type (Lost Book / Late Return): '

-- Running the procedure with the inputs
BEGIN
    AddFine(
        p_borrowId => '&borrow_id', 
        p_memberId => '&member_id', 
        p_copyId => '&copy_id', 
        p_fineType => '&fine_type'
    );
END;
/