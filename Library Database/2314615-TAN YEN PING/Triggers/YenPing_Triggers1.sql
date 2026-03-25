----------generate_id if id is null
CREATE OR REPLACE TRIGGER trg_generate_audit_id
BEFORE INSERT ON BookAudit
FOR EACH ROW
BEGIN
    IF :NEW.auditId IS NULL THEN
        SELECT 'BA' || LPAD(bookaudit_seq.NEXTVAL, 4, '0') INTO :NEW.auditId FROM dual;
    END IF;
END;
/

----------check for invalid_Action
CREATE OR REPLACE TRIGGER trg_prevent_invalid_action
BEFORE INSERT ON BookAudit
FOR EACH ROW
DECLARE
    v_returnStatus VARCHAR2(10);
BEGIN
    -- Get the returnStatus from BorrowedBooks
    SELECT returnStatus INTO v_returnStatus
    FROM BorrowedBooks
    WHERE borrowId = :NEW.borrowId;

    -- Validation rules
    IF :NEW.actionType = 'Returned' AND v_returnStatus != 'Returned' THEN
        RAISE_APPLICATION_ERROR(-20001, 'Book must be marked as Returned in BorrowedBooks to log a Returned action.');
    ELSIF :NEW.actionType = 'Lost' AND v_returnStatus != 'Lost' THEN
        RAISE_APPLICATION_ERROR(-20002, 'Book must be marked as Lost in BorrowedBooks to log a Lost action.');
    END IF;
END;
/
