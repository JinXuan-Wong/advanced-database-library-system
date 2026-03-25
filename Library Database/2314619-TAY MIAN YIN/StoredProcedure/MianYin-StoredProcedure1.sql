-- Stored Procedure 1: Check Shift Overlap
CREATE OR REPLACE PROCEDURE proc_check_shift_overlap (
    p_staffId   IN VARCHAR2,
    p_shiftDate IN DATE
)
IS
    v_count NUMBER;

    -- Custom exception for invalid table or column access (ORA-00942: table or view does not exist)
    table_missing EXCEPTION;
    PRAGMA EXCEPTION_INIT(table_missing, -00942);  
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM ShiftSchedules
    WHERE staffId = p_staffId AND shiftDate = p_shiftDate;

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20023, 'Staff already scheduled for this date.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('No overlapping shift.');
    END IF;

EXCEPTION
    WHEN table_missing THEN
        DBMS_OUTPUT.PUT_LINE('Error: Required table or view does not exist. Please check ShiftSchedules table.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error checking shift overlap: ' || SQLERRM);
END;
/

SET SERVEROUTPUT ON

-- Prompt user for staff ID & date input
ACCEPT v_staffId CHAR PROMPT 'Enter staff ID: '
ACCEPT v_shiftDate CHAR PROMPT 'Enter shift date (DD-MON-YYYY): '

-- Execute the procedure with user input
EXEC proc_check_shift_overlap('&v_staffId','&v_shiftDate');
