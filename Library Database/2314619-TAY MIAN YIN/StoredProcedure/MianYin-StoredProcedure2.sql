-- Stored Procedure 2: Get Staff Attendance Summary
CREATE OR REPLACE PROCEDURE proc_staff_attendance_summary (
    p_staffId IN VARCHAR2
)
IS
    v_present   NUMBER := 0;
    v_absent    NUMBER := 0;
    v_late      NUMBER := 0;
    
    -- Custom exception for table/view not found
    table_missing EXCEPTION;
    PRAGMA EXCEPTION_INIT(table_missing, -00942);

BEGIN
    -- Check if the staffId has any schedule records
    DECLARE
        v_check NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_check
        FROM ShiftSchedules
        WHERE staffId = p_staffId;

        IF v_check = 0 THEN
            RAISE_APPLICATION_ERROR(-20031, 'No shift schedules found for the given staff ID.');
        END IF;
    END;

    -- Count Present attendance
    SELECT COUNT(*) INTO v_present
    FROM StaffAttendance sa
    JOIN ShiftSchedules ss ON sa.scheduleId = ss.scheduleId
    WHERE ss.staffId = p_staffId AND sa.attendanceStatus = 'Present';

    -- Count Absent attendance
    SELECT COUNT(*) INTO v_absent
    FROM StaffAttendance sa
    JOIN ShiftSchedules ss ON sa.scheduleId = ss.scheduleId
    WHERE ss.staffId = p_staffId AND sa.attendanceStatus = 'Absent';

    -- Count Late attendance
    SELECT COUNT(*) INTO v_late
    FROM StaffAttendance sa
    JOIN ShiftSchedules ss ON sa.scheduleId = ss.scheduleId
    WHERE ss.staffId = p_staffId AND sa.attendanceStatus = 'Late';

    -- Output summary
    DBMS_OUTPUT.PUT_LINE('==============================================');
    DBMS_OUTPUT.PUT_LINE('          Staff Attendance Summary            ');
    DBMS_OUTPUT.PUT_LINE('==============================================');
    DBMS_OUTPUT.PUT_LINE(' Staff ID        : ' || p_staffId);
    DBMS_OUTPUT.PUT_LINE(' Present Days    : ' || v_present);
    DBMS_OUTPUT.PUT_LINE(' Absent Days     : ' || v_absent);
    DBMS_OUTPUT.PUT_LINE(' Late Days       : ' || v_late);
    DBMS_OUTPUT.PUT_LINE('==============================================');

EXCEPTION
    WHEN table_missing THEN
        DBMS_OUTPUT.PUT_LINE('Error: Missing required table/view. Please check StaffAttendance or ShiftSchedules.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error generating summary: ' || SQLERRM);
END;
/

SET SERVEROUTPUT ON

-- Prompt user for staff ID input
ACCEPT v_staffId CHAR PROMPT 'Enter staff ID: '

-- Execute the procedure with user input
EXEC proc_staff_attendance_summary('&v_staffId');