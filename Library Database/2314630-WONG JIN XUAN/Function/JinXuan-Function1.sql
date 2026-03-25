CREATE OR REPLACE FUNCTION CalculateTotalHoursWorked (staff_id  IN VARCHAR2) 
RETURN NUMBER IS
    total_hours NUMBER := 0;
BEGIN
    SELECT SUM(
        CASE
            WHEN sa.attendanceStatus = 'Present' THEN 
                (EXTRACT(DAY FROM (sa.actualEndTime - sa.actualStartTime)) * 24) +
                EXTRACT(HOUR FROM (sa.actualEndTime - sa.actualStartTime))
            ELSE 0
        END
    )
    INTO total_hours
    FROM ShiftSchedules ss
    JOIN StaffAttendance sa ON sa.scheduleId = ss.scheduleId
    WHERE ss.staffId = staff_id;
    
    RETURN total_hours;
END;
/
