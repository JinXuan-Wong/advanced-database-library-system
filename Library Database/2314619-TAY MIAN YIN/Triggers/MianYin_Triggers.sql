-- Trigger 1: Auto-mark Staff as 'Late' Based on Shift Start Time
CREATE OR REPLACE TRIGGER trg_auto_mark_late
BEFORE INSERT OR UPDATE ON StaffAttendance
FOR EACH ROW
DECLARE
    v_shiftStart TIMESTAMP;
BEGIN
    SELECT s.startTime INTO v_shiftStart
    FROM ShiftSchedules ss
    JOIN Shift s ON ss.shiftId = s.shiftId
    WHERE ss.scheduleId = :NEW.scheduleId;

    IF :NEW.actualStartTime IS NOT NULL THEN
        IF :NEW.actualStartTime > v_shiftStart THEN
            :NEW.attendanceStatus := 'Late';
        ELSE
            :NEW.attendanceStatus := 'Present';
        END IF;
    END IF;
END;
/

-- Trigger 2: Enforce 40-Hour Weekly Limit for Staff
CREATE OR REPLACE TRIGGER trg_check_weekly_hours
BEFORE INSERT OR UPDATE ON StaffAttendance
FOR EACH ROW
DECLARE
    v_staffId ShiftSchedules.staffId%TYPE;
    v_shiftDate DATE;
    v_weekStart DATE;
    v_totalHours NUMBER := 0;
    v_newHours NUMBER := 0;
BEGIN
    SELECT staffId, shiftDate INTO v_staffId, v_shiftDate
    FROM ShiftSchedules
    WHERE scheduleId = :NEW.scheduleId;

    v_weekStart := TRUNC(v_shiftDate, 'IW');

    SELECT NVL(SUM(
        EXTRACT(DAY FROM (actualEndTime - actualStartTime)) * 24 + EXTRACT(HOUR FROM (actualEndTime - actualStartTime))
    ), 0)
    INTO v_totalHours
    FROM StaffAttendance sa
    JOIN ShiftSchedules ss ON sa.scheduleId = ss.scheduleId
    WHERE ss.staffId = v_staffId
      AND TRUNC(ss.shiftDate, 'IW') = v_weekStart;
      
    IF :NEW.actualStartTime IS NOT NULL AND :NEW.actualEndTime IS NOT NULL THEN
        v_newHours := (EXTRACT(DAY FROM (:NEW.actualEndTime - :NEW.actualStartTime)) * 24) + EXTRACT(HOUR FROM (:NEW.actualEndTime - :NEW.actualStartTime));
    END IF;

    IF (v_totalHours + v_newHours) > 40 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Total working hours for this staff in the week would exceed 40 hours.');
    END IF;
END;
/
 