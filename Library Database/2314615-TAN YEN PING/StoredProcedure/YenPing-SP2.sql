CREATE OR REPLACE PROCEDURE Get_Book_Status(
    p_month IN VARCHAR2,  -- Prompt for month input in format 'MON-YYYY'
    p_status_filter IN VARCHAR2 DEFAULT NULL  -- Optional filter like 'BORROWED', 'RETURNED', 'OVERDUE'
) IS
    CURSOR status_cursor IS
        SELECT DISTINCT
            TO_CHAR(ba.actionDate, 'MON-YYYY') AS month_group,
            bt.title AS book_title,
            bc.copyId AS copy_id,
            bb.returnStatus AS current_status,
            st.staffName AS sign_by,  -- Replacing actionType with staffName as 'sign by'
            ba.actionDate AS action_date,
            ba.staffId AS staff_id,
            bb.memberId AS member_id
        FROM 
            BookTitles bt
        JOIN 
            BookCopies bc ON bt.bookId = bc.bookId
        JOIN 
            BorrowedBooks bb ON bc.copyId = bb.copyId
        JOIN 
            BookAudit ba ON bb.borrowId = ba.borrowId
        JOIN 
            Staff st ON ba.staffId = st.staffId  -- Join with Staff table to get staff name
        WHERE 
            (p_status_filter IS NULL OR UPPER(bb.returnStatus) = UPPER(p_status_filter))
            AND TO_CHAR(ba.actionDate, 'MON-YYYY') = UPPER(p_month)
        ORDER BY 
            ba.actionDate DESC;

    -- Variables to hold values
    v_month_group    VARCHAR2(15);
    v_book_title     VARCHAR2(100);
    v_copy_id        VARCHAR2(10);
    v_current_status VARCHAR2(15);
    v_sign_by        VARCHAR2(100);  -- Variable for staff name
    v_action_date    DATE;
    v_staff_id       VARCHAR2(10);
    v_member_id      VARCHAR2(10);
BEGIN
    DBMS_OUTPUT.PUT_LINE('================================================================================================================================');
    DBMS_OUTPUT.PUT_LINE('|                                       BOOK CURRENT STATUS FOR ' || p_month || ' AND STATUS ' || p_status_filter || '                                    |');
    DBMS_OUTPUT.PUT_LINE('================================================================================================================================');
    DBMS_OUTPUT.PUT_LINE(RPAD('TITLE', 55) || RPAD('COPY ID', 10) || RPAD('STATUS', 12) || 
                         RPAD('SIGNED BY', 18) || RPAD('DATE', 15) || RPAD('STAFFID', 10) || RPAD('MEMBERID', 10));
    DBMS_OUTPUT.PUT_LINE('---------------------------------------------------------------------------------------------------------------------------------');

    OPEN status_cursor;
    LOOP
        FETCH status_cursor INTO v_month_group, v_book_title, v_copy_id, v_current_status, 
                                v_sign_by, v_action_date, v_staff_id, v_member_id;
        EXIT WHEN status_cursor%NOTFOUND;

        -- Print each entry for the specified month and status
        DBMS_OUTPUT.PUT_LINE(RPAD(SUBSTR(v_book_title, 1, 55), 55) || 
                             RPAD(v_copy_id, 10) || 
                             RPAD(v_current_status, 12) || 
                             RPAD(v_sign_by, 18) || 
                             RPAD(TO_CHAR(v_action_date, 'DD-MON-YYYY'), 15) || 
                             RPAD(v_staff_id, 10) || 
                             RPAD(v_member_id, 10));
    END LOOP;
    CLOSE status_cursor;

    DBMS_OUTPUT.PUT_LINE('==============================================================================================================================');
    
EXCEPTION
    -- Handling errors when no records are found
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No records found for the specified month: ' || p_month || ' and status: ' || p_status_filter || '.');
    
    -- Handling invalid month format or any other input-related issues
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Invalid input provided. Please check the format of the month or status.');
    
    -- Handling any other unexpected errors
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An unexpected error occurred: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('Please check your input or the system configuration.');
END;
/

SET SERVEROUTPUT ON;
ACCEPT month_input CHAR PROMPT 'Enter Month (e.g., JUN-2024): '
ACCEPT status_input CHAR PROMPT 'Enter Status (e.g., BORROWED, RETURNED, OVERDUE): '

BEGIN
    Get_Book_Status(p_month => '&month_input', p_status_filter => '&status_input');
END;
/
