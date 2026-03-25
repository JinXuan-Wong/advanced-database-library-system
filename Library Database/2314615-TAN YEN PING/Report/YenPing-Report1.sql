-- ==========================================
-- Procedure: rpt_Top_Members - Top 10 Members with Most Borrowed Books Per Month
-- Prepared By: Manager - 'John Tan' (StaffID: S001)
-- Date Generated: 10-JUL-2024
-- ==========================================
SET SERVEROUTPUT ON;
SET PAGESIZE 1000;
SET LINESIZE 300;

CREATE OR REPLACE PROCEDURE rpt_Top_Members (p_month IN VARCHAR2) IS
    CURSOR top_members_cursor IS
        SELECT *
        FROM (
            SELECT 
                RANK() OVER (ORDER BY COUNT(bb.borrowId) DESC) AS rank_no,
                bb.memberId,
                m.memberName,
                m.memberTel,
                COUNT(bb.borrowId) AS total_borrowed,
                SUM(Get_Borrow_Duration(bb.borrowDate, bb.returnDate)) AS total_duration_days,
                Get_Member_Since_Days(m.registrationDate) AS member_since_days
            FROM 
                BorrowedBooks bb
                JOIN Members m ON bb.memberId = m.memberId
            WHERE 
                TO_CHAR(bb.borrowDate, 'MON-YYYY') = UPPER(p_month)
            GROUP BY 
                bb.memberId, m.memberName, m.memberTel, m.registrationDate
        )
        WHERE rank_no <= 5
        ORDER BY rank_no;

    CURSOR book_details_cursor(p_memberId VARCHAR2) IS
        SELECT 
            bb.borrowId,
            bt.title,
            bb.borrowDate,
            bb.returnDate,
            NVL(
                CASE 
                    WHEN bb.returnDate IS NOT NULL THEN 
                        bb.returnDate - bb.borrowDate
                    ELSE 
                        0
                END, 0
            ) AS borrow_duration
        FROM 
            BorrowedBooks bb
            JOIN BookCopies bc ON bb.copyId = bc.copyId
            JOIN BookTitles bt ON bc.bookId = bt.bookId
        WHERE 
            bb.memberId = p_memberId
            AND TO_CHAR(bb.borrowDate, 'MON-YYYY') = UPPER(p_month);

    -- Variables
    v_rank_no NUMBER;
    v_memberId Members.memberId%TYPE;
    v_memberName Members.memberName%TYPE;
    v_memberTel Members.memberTel%TYPE;
    v_total_borrowed NUMBER;
    v_total_duration_days NUMBER;
    v_member_since_days NUMBER;
    v_staffName VARCHAR2(100);

    v_borrowId BorrowedBooks.borrowId%TYPE;
    v_title BookTitles.title%TYPE;
    v_borrowDate DATE;
    v_returnDate DATE;
    v_days_borrowed NUMBER;

BEGIN

    -- Get the staff name of the report preparer
    SELECT staffName INTO v_staffName FROM Staff WHERE staffId = 'S001';

    -- Start report output
    DBMS_OUTPUT.PUT_LINE('==============================================================================================');
    DBMS_OUTPUT.PUT_LINE('======================= TOP 5 MEMBERS WHO BORROWED BOOKS IN ' || UPPER(p_month) || ' =========================');
    DBMS_OUTPUT.PUT_LINE('==============================================================================================');
    DBMS_OUTPUT.PUT_LINE('Report Prepared By Manager : Mr.' || v_staffName);
    DBMS_OUTPUT.PUT_LINE('Report Generated On: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY'));

    OPEN top_members_cursor;
    LOOP
        FETCH top_members_cursor INTO 
            v_rank_no, v_memberId, v_memberName, v_memberTel, 
            v_total_borrowed, v_total_duration_days, v_member_since_days;
        EXIT WHEN top_members_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('Rank          : #' || v_rank_no);
        DBMS_OUTPUT.PUT_LINE('Member ID     : ' || v_memberId);
        DBMS_OUTPUT.PUT_LINE('Name          : ' || v_memberName);
        DBMS_OUTPUT.PUT_LINE('Telephone     : ' || v_memberTel);
        DBMS_OUTPUT.PUT_LINE('Books Borrowed: ' || v_total_borrowed);
        DBMS_OUTPUT.PUT_LINE('Total Days    : ' || v_total_duration_days || ' day(s)');
        DBMS_OUTPUT.PUT_LINE('Joined For    : ' || v_member_since_days || ' day(s)');
        DBMS_OUTPUT.PUT_LINE('Book Details:');
        DBMS_OUTPUT.PUT_LINE(RPAD('     BorrowID', 22) || RPAD('Title', 40) || RPAD('Borrow Date', 15) || RPAD('Return Date', 15) || 'Days');

        OPEN book_details_cursor(v_memberId);
        LOOP
            FETCH book_details_cursor INTO v_borrowId, v_title, v_borrowDate, v_returnDate, v_days_borrowed;
            EXIT WHEN book_details_cursor%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE(RPAD('      -> ', 10) || RPAD(v_borrowId, 13) || RPAD(SUBSTR(v_title, 1, 38), 40) || 
                                 RPAD(TO_CHAR(v_borrowDate, 'DD-MON-YY'), 15) ||
                                 RPAD(NVL(TO_CHAR(v_returnDate, 'DD-MON-YY'), 'NOT RETURNED'), 15) ||
                                 v_days_borrowed);
        END LOOP;
        CLOSE book_details_cursor;
    END LOOP;
    CLOSE top_members_cursor;

    DBMS_OUTPUT.PUT_LINE('==============================================================================================');
END;
/


SET SERVEROUTPUT ON;

ACCEPT p_month CHAR PROMPT 'Enter Month (e.g., JUN-2024): '

EXEC rpt_Top_Members('&p_month');