SET LINESIZE 180
SET PAGESIZE 70
CREATE OR REPLACE PROCEDURE rpt_late_attendance_report
IS
    -- Cursor to get distinct shifts
    CURSOR shift_cur IS
    SELECT DISTINCT ss.shiftId, s.shiftType, s.startTime, s.endTime, TRUNC(ss.shiftDate) AS att_date
    FROM ShiftSchedules ss
    JOIN Shift s ON ss.shiftId = s.shiftId
    JOIN StaffAttendance sa ON sa.scheduleId = ss.scheduleId
    WHERE sa.attendanceStatus = 'Late'
    ORDER BY TRUNC(ss.shiftDate), s.startTime;

    -- Cursor to get attendance details for each shift and date
    CURSOR late_attendance_details(p_shiftId IN VARCHAR2, p_date IN DATE) IS
        SELECT ss.staffId, s.staffName, sa.attendanceStatus, sa.actualStartTime, sa.actualEndTime
        FROM StaffAttendance sa
        JOIN ShiftSchedules ss ON sa.scheduleId = ss.scheduleId
        JOIN Staff s ON ss.staffId = s.staffId
        WHERE ss.shiftId = p_shiftId
        AND sa.attendanceStatus = 'Late'
        AND TRUNC(ss.shiftDate) = p_date
        ORDER BY s.staffName;

    v_has_late_entries BOOLEAN := FALSE;
    v_minutes_late NUMBER;
    v_late_count NUMBER := 0; 

BEGIN
    -- Report Header
    DBMS_OUTPUT.PUT_LINE(RPAD('=', 101, '='));
    DBMS_OUTPUT.PUT_LINE('LATE ATTENDANCE REPORT');
    DBMS_OUTPUT.PUT_LINE(RPAD('=', 101, '='));
    DBMS_OUTPUT.PUT_LINE('');

    FOR shift IN shift_cur LOOP
        DBMS_OUTPUT.PUT_LINE('Date: ' || TO_CHAR(shift.att_date, 'DD-MON-YYYY'));
        DBMS_OUTPUT.PUT_LINE(
            RPAD('Shift Type', 20) || ' ' ||
            RPAD('Staff Name', 20) || ' ' ||
            RPAD('Status', 8) || ' ' ||
            RPAD('Scheduled Start', 18) || ' ' ||
            RPAD('Actual Start', 15) || ' ' ||
            RPAD('Minutes Late', 12)
        );
        DBMS_OUTPUT.PUT_LINE(RPAD('-', 101, '-'));

        FOR attendance IN late_attendance_details(shift.shiftId, shift.att_date) LOOP
            BEGIN
                -- Calculate minutes late
                v_minutes_late := calculate_minutes_late(attendance.actualStartTime, shift.startTime);
                
                DBMS_OUTPUT.PUT_LINE(
                    RPAD(shift.shiftType, 20) || ' ' ||
                    RPAD(attendance.staffName, 20) || ' ' ||
                    RPAD('Late', 8) || ' ' ||
                    RPAD(TO_CHAR(shift.startTime, 'HH24:MI'), 18) || ' ' ||
                    RPAD(TO_CHAR(attendance.actualStartTime, 'HH24:MI'), 15) || ' ' ||
                    LPAD(v_minutes_late, 12)
                );
                v_has_late_entries := TRUE;
                v_late_count := v_late_count + 1;
            
            EXCEPTION
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('Error processing: ' || attendance.staffName || ' - ' || SQLERRM);
            END;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE(CHR(10));
    END LOOP;

    IF NOT v_has_late_entries THEN
        DBMS_OUTPUT.PUT_LINE('No late attendance records found.');
    END IF;

    DBMS_OUTPUT.PUT_LINE('Total Late Attendance Entries: ' || v_late_count);

    -- Print the footer for the report
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 101, '-'));
    DBMS_OUTPUT.PUT_LINE('Report generated on: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'));
    DBMS_OUTPUT.PUT_LINE(RPAD('=', 101, '='));
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in rpt_late_attendance_report: ' || SQLERRM);
END;
/

SET SERVEROUTPUT ON

-- Execute the procedure
EXEC rpt_late_attendance_report;