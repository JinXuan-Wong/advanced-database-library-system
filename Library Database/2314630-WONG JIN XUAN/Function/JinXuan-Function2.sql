CREATE OR REPLACE FUNCTION CalculateLoanProcessed (staff_id  IN VARCHAR2) 
RETURN NUMBER IS
    total_loans NUMBER := 0;
BEGIN
    SELECT COUNT(*)
    INTO total_loans
    FROM BookAudit ba
    WHERE ba.staffId = staff_id AND ba.actionType = 'Loaned'; -- staffId is now VARCHAR2
    
    RETURN total_loans;
END;
/
