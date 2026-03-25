CREATE OR REPLACE FUNCTION calculate_minutes_late(
    p_actual_start IN DATE,
    p_scheduled_start IN DATE
) RETURN NUMBER
IS
    v_minutes NUMBER;
BEGIN
    -- Calculate time difference in minutes
    v_minutes := ROUND((p_actual_start - p_scheduled_start) * 24 * 60);
    RETURN v_minutes;
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END;
/
