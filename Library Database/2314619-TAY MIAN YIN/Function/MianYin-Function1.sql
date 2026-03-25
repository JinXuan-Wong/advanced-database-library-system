CREATE OR REPLACE FUNCTION get_shift_duration(
    p_start_time IN DATE,
    p_end_time IN DATE
) RETURN VARCHAR2
IS
    v_minutes NUMBER;
    v_hours   NUMBER;
BEGIN
    v_minutes := ROUND((p_end_time - p_start_time) * 24 * 60);
    v_hours   := TRUNC(v_minutes / 60);
    v_minutes := MOD(v_minutes, 60);

    RETURN TO_CHAR(v_hours) || 'h ' || TO_CHAR(v_minutes) || 'm';
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'Invalid Time';
END;
/
