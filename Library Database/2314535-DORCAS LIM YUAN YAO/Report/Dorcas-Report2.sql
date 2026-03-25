SET SERVEROUTPUT ON;
SET LINESIZE 220;
SET PAGESIZE 1000;

CREATE OR REPLACE PROCEDURE rpt_overdue_books
IS
    CURSOR cur_overdue IS
        SELECT bb.borrowId, bb.memberId, bb.copyId, bb.borrowDate, bb.dueDate
        FROM BorrowedBooks bb
        WHERE bb.returnDate IS NULL
        AND bb.dueDate < SYSDATE
        ORDER BY bb.dueDate;

    CURSOR cur_details(p_memberId VARCHAR2, p_copyId VARCHAR2) IS
        SELECT m.memberName, bt.title, bt.genre
        FROM Members m
        JOIN BookCopies bc ON bc.copyId = p_copyId
        JOIN BookTitles bt ON bt.bookId = bc.bookId
        WHERE m.memberId = p_memberId;

    v_row_num NUMBER := 0;
    v_total_overdue NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE(RPAD('=', 150, '='));
    DBMS_OUTPUT.PUT_LINE('||       Overdue Books Report' || RPAD(' ', 119) || '||');
    DBMS_OUTPUT.PUT_LINE('||       Generated On: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') || RPAD(' ', 105) || '||');
    DBMS_OUTPUT.PUT_LINE(RPAD('=', 150, '='));

    DBMS_OUTPUT.PUT_LINE(
        RPAD('No.', 5) ||
        RPAD('Borrow ID', 12) ||
        RPAD('Member ID', 12) ||
        RPAD('Member Name', 25) ||
        RPAD('Book Title', 50) ||  
        RPAD('Genre', 15) ||
        RPAD('Due Date', 15) ||
        RPAD('Days Overdue', 15)
    );

    DBMS_OUTPUT.PUT_LINE(RPAD('-', 150, '-'));

    FOR rec IN cur_overdue LOOP
        v_row_num := v_row_num + 1;
        v_total_overdue := v_total_overdue + 1;

        FOR det IN cur_details(rec.memberId, rec.copyId) LOOP
            DBMS_OUTPUT.PUT_LINE(
                RPAD(v_row_num, 5) ||
                RPAD(rec.borrowId, 12) ||
                RPAD(rec.memberId, 12) ||
                RPAD(det.memberName, 25) ||
                RPAD(SUBSTR(det.title, 1, 49), 50) ||  -- match padding
                RPAD(det.genre, 15) ||
                RPAD(TO_CHAR(rec.dueDate, 'DD-MON-YYYY'), 15) ||
                RPAD(TRUNC(SYSDATE - rec.dueDate), 15)
            );
        END LOOP;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE(RPAD('-', 150, '-'));

    IF v_total_overdue > 0 THEN
        DBMS_OUTPUT.PUT_LINE('||  Total Overdue Books: ' || v_total_overdue || RPAD(' ', 125 - LENGTH(TO_CHAR(v_total_overdue))) || '||');
    ELSE
        DBMS_OUTPUT.PUT_LINE('||  No overdue books found. ' || RPAD(' ', 128) || '||');
    END IF;

    DBMS_OUTPUT.PUT_LINE(RPAD('=', 150, '='));
END;
/

BEGIN
    rpt_overdue_books;
END;
/
