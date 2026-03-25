SET SERVEROUTPUT ON;
SET PAGESIZE 1000;
SET LINESIZE 300;

CREATE OR REPLACE PROCEDURE rpt_bookstat_borrowduration(p_status IN VARCHAR2)
IS
    -- Cursor to fetch books by status
    CURSOR cur_books IS
        SELECT bt.bookId, bt.title, bt.genre, bc.bookStatus, COUNT(bb.borrowId) AS borrow_count
        FROM BookTitles bt
        JOIN BookCopies bc ON bt.bookId = bc.bookId
        LEFT JOIN BorrowedBooks bb ON bb.copyId = bc.copyId AND bb.returnStatus IN ('On loan', 'Overdue')
        WHERE bc.bookStatus = p_status
        GROUP BY bt.bookId, bt.title, bt.genre, bc.bookStatus
        ORDER BY bt.title;

    -- Cursor to calculate average borrowing duration
    CURSOR cur_avg_borrow_duration(p_bookId VARCHAR2) IS
        SELECT AVG(bb.dueDate - bb.borrowDate) AS avg_duration
        FROM BorrowedBooks bb
        JOIN BookCopies bc ON bb.copyId = bc.copyId
        WHERE bc.bookId = p_bookId AND bb.returnStatus = 'Returned';

    -- Cursor to get borrowing details per book
    CURSOR cur_borrow_details(p_bookId VARCHAR2) IS
        SELECT bb.borrowId, m.memberName AS member_name, (bb.dueDate - bb.borrowDate) AS duration
        FROM BorrowedBooks bb
        JOIN BookCopies bc ON bb.copyId = bc.copyId
        JOIN Members m ON bb.memberId = m.memberId
        WHERE bc.bookId = p_bookId AND bb.returnStatus = 'Returned';

    -- Variables
    v_avg_borrow_duration NUMBER := 0;
    v_total_books         NUMBER := 0;
    v_total_borrows       NUMBER := 0;
    v_total_duration      NUMBER := 0;
    v_row_num             NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE(RPAD('=', 130, '=')); 
    DBMS_OUTPUT.PUT_LINE(RPAD('||', 100));
    DBMS_OUTPUT.PUT_LINE('||       ' || RPAD('Book Availability and Borrowing Duration Report', 118) || ' ||');
    DBMS_OUTPUT.PUT_LINE('||       Generated On: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') || RPAD(' ', 85) || '||');
    DBMS_OUTPUT.PUT_LINE(RPAD('||', 100));
    DBMS_OUTPUT.PUT_LINE(RPAD('=', 130, '=')); 
    DBMS_OUTPUT.PUT_LINE(RPAD('|', 100));
    -- Column headers
    DBMS_OUTPUT.PUT_LINE(
        RPAD('No.', 5) ||
        RPAD('Book ID', 12) ||
        RPAD('Title', 40) ||
        RPAD('Genre', 20) ||
        RPAD('Status', 18) ||
        RPAD('Borrows', 10) ||
        RPAD('Avg Duration (Days)', 25)
    );
    DBMS_OUTPUT.PUT_LINE(RPAD('=', 130, '='));

    FOR book_rec IN cur_books LOOP
        v_row_num := v_row_num + 1;
        v_avg_borrow_duration := 0;

        BEGIN
            FOR rec IN cur_avg_borrow_duration(book_rec.bookId) LOOP
                v_avg_borrow_duration := NVL(rec.avg_duration, 0);
            END LOOP;
        EXCEPTION
            WHEN OTHERS THEN
                v_avg_borrow_duration := 0;
        END;

        v_total_books := v_total_books + 1;
        v_total_borrows := v_total_borrows + book_rec.borrow_count;
        v_total_duration := v_total_duration + v_avg_borrow_duration;

        -- Print book row 
        DBMS_OUTPUT.PUT_LINE(
            RPAD(v_row_num, 5) ||
            RPAD(book_rec.bookId, 12) ||
            RPAD(SUBSTR(book_rec.title, 1, 39), 40) ||
            RPAD(book_rec.genre, 20) ||
            RPAD(book_rec.bookStatus, 18) ||
            RPAD(book_rec.borrow_count, 10) ||
            RPAD(TO_CHAR(v_avg_borrow_duration, '990.00'), 15) 
        );
        DBMS_OUTPUT.PUT_LINE(RPAD('|', 100));

        -- Borrow details neatly formatted
        FOR borrow_rec IN cur_borrow_details(book_rec.bookId) LOOP
            DBMS_OUTPUT.PUT_LINE(
                RPAD('|      -> ', 10) ||
                RPAD('Borrow ID:', 12) || RPAD(borrow_rec.borrowId, 12) || 
                RPAD('Member:', 10) || RPAD(SUBSTR(borrow_rec.member_name, 1, 20), 22) ||
                RPAD('Duration:', 12) || RPAD(borrow_rec.duration, 4) || ' days'
            );
        END LOOP;

        DBMS_OUTPUT.PUT_LINE(RPAD('|', 100));
        DBMS_OUTPUT.PUT_LINE(RPAD('-', 130, '-'));
    END LOOP;

    -- Summary Section
    IF v_total_books > 0 THEN
        DBMS_OUTPUT.PUT_LINE(RPAD('|', 100)); 
        DBMS_OUTPUT.PUT_LINE(RPAD('=', 130, '=')); 
        DBMS_OUTPUT.PUT_LINE(RPAD('||', 100));
        DBMS_OUTPUT.PUT_LINE('||         ******************** Summary of Report ********************' || RPAD(' ', 58) || '||');
        DBMS_OUTPUT.PUT_LINE('||           Total Books: ' || RPAD(v_total_books, 25) || RPAD(' ', 77) || '||');
        DBMS_OUTPUT.PUT_LINE('||           Total Borrows: ' || RPAD(v_total_borrows, 23) || RPAD(' ', 77) || '||');
        DBMS_OUTPUT.PUT_LINE('||           Average Borrow Duration for All Books: ' ||
            TO_CHAR(v_total_duration / v_total_books, '990.00') || ' days' || RPAD(' ', 64) || '||');
        DBMS_OUTPUT.PUT_LINE(RPAD('||', 100)); 
        DBMS_OUTPUT.PUT_LINE(RPAD('=', 130, '='));

    ELSE
        DBMS_OUTPUT.PUT_LINE('No books available for the selected status.');
    END IF;
END;
/

SET SERVEROUTPUT ON;

-- Prompt the user for input
ACCEPT v_status CHAR PROMPT 'Enter book status to view (available / borrowed / reserved): '

-- Execute the procedure with user input
EXEC rpt_bookstat_borrowduration('&v_status');