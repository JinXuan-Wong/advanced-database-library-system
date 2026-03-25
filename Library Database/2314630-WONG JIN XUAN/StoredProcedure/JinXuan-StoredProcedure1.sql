CREATE OR REPLACE PROCEDURE GetBorrowHistoryByMember (
    p_memberId IN VARCHAR2
)
IS
    v_exists INTEGER;
BEGIN
    -- Validate: Check if memberId exists
    SELECT COUNT(*) INTO v_exists
    FROM Members
    WHERE memberId = p_memberId;

    IF v_exists = 0 THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: Member ID "' || p_memberId || '" does not exist.');
        RETURN;
    END IF;

    -- Validate: Check if member has borrow history
    SELECT COUNT(*) INTO v_exists
    FROM BorrowedBooks
    WHERE memberId = p_memberId;

    IF v_exists = 0 THEN
        DBMS_OUTPUT.PUT_LINE('! INFO: Member "' || p_memberId || '" has no borrow history.');
        RETURN;
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('==================================================================================================================================');
    DBMS_OUTPUT.PUT_LINE('|                                                   BORROW HISTORY FOR MEMBER                                                    |');
    DBMS_OUTPUT.PUT_LINE('==================================================================================================================================');

    DBMS_OUTPUT.PUT_LINE(RPAD('Borrow ID', 12) || RPAD('Title', 30) || RPAD('Borrow Date', 15) || RPAD('Due Date', 15) ||
                         RPAD('Return Date', 15) || RPAD('Return Status', 15) || RPAD('Audit Action', 15) || 'Handled By');
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------------------------------------------------------------------------------');

    FOR rec IN (
        SELECT 
            bb.borrowId,
            bt.title,
            TO_CHAR(bb.borrowDate, 'YYYY-MM-DD') AS borrowDate,
            TO_CHAR(bb.dueDate, 'YYYY-MM-DD') AS dueDate,
            TO_CHAR(bb.returnDate, 'YYYY-MM-DD') AS returnDate,
            bb.returnStatus,
            ba.actionType,
            s.staffName AS handledBy
        FROM BorrowedBooks bb
        JOIN BookCopies bc ON bb.copyId = bc.copyId
        JOIN BookTitles bt ON bc.bookId = bt.bookId
        LEFT JOIN BookAudit ba ON bb.borrowId = ba.borrowId
        LEFT JOIN Staff s ON ba.staffId = s.staffId
        WHERE bb.memberId = p_memberId
        ORDER BY bb.borrowDate DESC
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE(
            RPAD(rec.borrowId, 12) ||
            RPAD(SUBSTR(rec.title, 1, 28), 30) ||
            RPAD(NVL(rec.borrowDate, '-'), 15) ||
            RPAD(NVL(rec.dueDate, '-'), 15) ||
            RPAD(NVL(rec.returnDate, '-'), 15) ||
            RPAD(NVL(rec.returnStatus, '-'), 15) ||
            RPAD(NVL(rec.actionType, '-'), 15) ||
            NVL(rec.handledBy, '-')
        );
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('==================================================================================================================================');
END;
/

SET SERVEROUTPUT ON
SET PAGESIZE 1000
SET LINESIZE 200

-- Prompt the user for input
ACCEPT memberId CHAR PROMPT 'Enter Member ID : '

-- Call the procedure with user input
BEGIN
        GetBorrowHistoryByMember('&memberId');
END;
/
