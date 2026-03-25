SET SERVEROUTPUT ON;
SET PAGESIZE 1000;
SET LINESIZE 300;

CREATE OR REPLACE PROCEDURE rpt_loanExtend(p_month IN VARCHAR2) IS
    CURSOR member_cur(p_month VARCHAR2) IS
        SELECT DISTINCT bb.memberId, m.memberName, m.memberTel
        FROM BorrowedBooks bb
        JOIN Members m ON bb.memberId = m.memberId
        WHERE TO_CHAR(bb.returnDate, 'MON-YYYY') = UPPER(p_month)
          AND bb.extendStatus = 'Approved';

    CURSOR extension_cur(p_member_id VARCHAR2, p_month VARCHAR2) IS
        SELECT bb.borrowId, b.Title, bb.borrowDate, bb.dueDate,
               bb.returnDate,
               ( bb.dueDate - bb.borrowDate) AS extension_days
        FROM BorrowedBooks bb
        JOIN BookCopies bc ON bb.copyId = bc.copyId
        JOIN BookTitles b ON bc.bookId = b.bookId
        WHERE bb.memberId = p_member_id
          AND TO_CHAR(bb.returnDate, 'MON-YYYY') = UPPER(p_month)
          AND bb.extendStatus = 'Approved';

    v_month       VARCHAR2(20) := UPPER(p_month);
    v_total_count NUMBER;
    v_percentage  NUMBER;
    v_staffName   VARCHAR2(100);
BEGIN
    -- Get staff name
    SELECT staffName INTO v_staffName FROM Staff WHERE staffId = 'S001';

    -- Get total extensions in month
    SELECT COUNT(*) INTO v_total_count
    FROM BorrowedBooks
    WHERE TO_CHAR(returnDate, 'MON-YYYY') = v_month
      AND extendStatus = 'Approved';

    -- Header
    DBMS_OUTPUT.PUT_LINE('==================================================================================================');
    DBMS_OUTPUT.PUT_LINE('=========================== Loan Extension Summary Report IN ' || v_month || ' ============================');
    DBMS_OUTPUT.PUT_LINE('==================================================================================================');
    DBMS_OUTPUT.PUT_LINE('Report Prepared By: Manager - ' || v_staffName);
    DBMS_OUTPUT.PUT_LINE('Generated On: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY'));
    DBMS_OUTPUT.PUT_LINE('Report Month: ' || v_month);
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 98, '-'));

    -- Loop members
    FOR mrec IN member_cur(v_month) LOOP
        v_percentage := Get_Extension_Percent(mrec.memberId, v_month);

        DBMS_OUTPUT.PUT_LINE('Member ID: ' || mrec.memberId || 
                             ', Name: ' || mrec.memberName || 
                             ', Tel: ' || mrec.memberTel);
        DBMS_OUTPUT.PUT_LINE('Contribution to Total Extensions: ' || ROUND(v_percentage, 2) || '%');
        DBMS_OUTPUT.PUT_LINE('   Borrow ID   Book Title                        Borrow Date  Due Date    Return Date  Extension Days');
        DBMS_OUTPUT.PUT_LINE(RPAD('-', 98, '-'));

        -- Nested loop: borrowings for member
        FOR erec IN extension_cur(mrec.memberId, v_month) LOOP
            DBMS_OUTPUT.PUT_LINE(RPAD('-> ', 4) ||
                                 RPAD(erec.borrowId, 8) || 
                                 RPAD(erec.Title, 34) || 
                                 RPAD(TO_CHAR(erec.borrowDate, 'DD-MON'),13) || 
                                 RPAD(TO_CHAR(erec.dueDate, 'DD-MON'),13) || 
                                 RPAD(TO_CHAR(erec.returnDate, 'DD-MON'),13)|| 
                                 erec.extension_days);
        END LOOP;

        DBMS_OUTPUT.PUT_LINE('==================================================================================================');
        DBMS_OUTPUT.PUT_LINE(RPAD('-', 98, '-'));
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Total Loan Extensions in ' || v_month || ': ' || v_total_count);
END;
/

SET SERVEROUTPUT ON;

ACCEPT p_month CHAR PROMPT 'Enter report month (e.g., JUN-2024): '

EXEC rpt_loanExtend('&p_month');
