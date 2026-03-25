-- Function 2: Get Borrow Duration
CREATE OR REPLACE FUNCTION Get_Borrow_Duration(
    p_borrow_date IN DATE,
    p_return_date IN DATE
) RETURN NUMBER IS
BEGIN
    IF p_return_date IS NULL THEN
        RETURN 0;
    ELSIF p_return_date < p_borrow_date THEN
        RETURN 0;
    ELSE
        RETURN TRUNC(p_return_date - p_borrow_date);
    END IF;
END;
/

-- Function 3: Get Member Since (in days)
CREATE OR REPLACE FUNCTION Get_Member_Since_Days(
    p_registration_date IN DATE
) RETURN NUMBER IS
    v_today DATE := TO_DATE('10-JUL-2024', 'DD-MON-YYYY');
BEGIN
    RETURN TRUNC(v_today - p_registration_date);
END;
/