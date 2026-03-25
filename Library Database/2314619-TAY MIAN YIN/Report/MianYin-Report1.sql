-- On-Demand Detailed Attendance Report by Shift Date
SET LINESIZE 120;
SET PAGESIZE 50;
CREATE OR REPLACE PROCEDURE rpt_attend_detail_by_date(
    p_shiftDate IN DATE
)
IS
    -- Outer cursor to get shift schedules for the given date
    CURSOR shift_cur IS
        SELECT ss.scheduleId, ss.shiftId, s.shiftType, 
               s.startTime, s.endTime
        FROM ShiftSchedules ss
        JOIN Shift s ON ss.shiftId = s.shiftId
        WHERE TRUNC(ss.shiftDate) = TRUNC(p_shiftDate)
        ORDER BY s.startTime;

    -- Nested cursor to get staff attendance for each schedule
    CURSOR staff_attendance_cur(p_scheduleId VARCHAR2) IS
        SELECT st.staffName, st.role, sa.attendanceStatus, 
               sa.actualStartTime, sa.actualEndTime
        FROM StaffAttendance sa
        JOIN ShiftSchedules ss ON sa.scheduleId = ss.scheduleId
        JOIN Staff st ON ss.staffId = st.staffId
        WHERE sa.scheduleId = p_scheduleId
        ORDER BY st.staffName;

    v_shift_rec shift_cur%ROWTYPE;
    v_staff_count NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE(RPAD('=', 62, '='));
    DBMS_OUTPUT.PUT_LINE('Attendance Report for ' || TO_CHAR(p_shiftDate, 'DD-MON-YYYY'));
    DBMS_OUTPUT.PUT_LINE(RPAD('=', 62, '='));
    
    OPEN shift_cur;
    LOOP
        FETCH shift_cur INTO v_shift_rec;
        EXIT WHEN shift_cur%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE('Shift ID: ' || v_shift_rec.shiftId ||  '       | Type: ' || v_shift_rec.shiftType);
        DBMS_OUTPUT.PUT_LINE('Time: ' || TO_CHAR(v_shift_rec.startTime, 'HH24:MI') ||  ' - ' || TO_CHAR(v_shift_rec.endTime, 'HH24:MI') || ' (' || get_shift_duration(v_shift_rec.startTime, v_shift_rec.endTime) || ')');
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------');

        v_staff_count := 0;
        
        FOR att_rec IN staff_attendance_cur(v_shift_rec.scheduleId) LOOP
            DBMS_OUTPUT.PUT_LINE(RPAD(att_rec.staffName, 20) || 
                                 RPAD(att_rec.role, 15) || 
                                 RPAD(att_rec.attendanceStatus, 12) || 
                                 RPAD(NVL(TO_CHAR(att_rec.actualStartTime, 'HH24:MI'), 'N/A'), 10) || 
                                 RPAD(NVL(TO_CHAR(att_rec.actualEndTime, 'HH24:MI'), 'N/A'), 10));
            v_staff_count := v_staff_count + 1;
        END LOOP;

        IF v_staff_count = 0 THEN
            DBMS_OUTPUT.PUT_LINE('No staff assigned to this shift');
        END IF;
        
        DBMS_OUTPUT.PUT_LINE(CHR(10));
    END LOOP;

    IF shift_cur%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No shifts scheduled for this date');
    END IF;
    
    CLOSE shift_cur;

    -- Print the footer for the report
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 62, '-'));
    DBMS_OUTPUT.PUT_LINE('Report generated on: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'));
    DBMS_OUTPUT.PUT_LINE(RPAD('=', 62, '='));
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error generating attendance detail report: ' || SQLERRM);
        IF shift_cur%ISOPEN THEN
            CLOSE shift_cur;
        END IF;
END;
/

SET SERVEROUTPUT ON

-- Prompt user for date input
ACCEPT v_date CHAR PROMPT 'Enter report date (DD-MON-YYYY): '

-- Execute the procedure with user input
EXEC rpt_attend_detail_by_date('&v_date');

-- INPUT: 01-MAY-2024