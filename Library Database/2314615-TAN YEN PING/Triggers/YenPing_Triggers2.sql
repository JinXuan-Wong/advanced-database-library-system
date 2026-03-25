CREATE OR REPLACE TRIGGER trg_borrowedbooks_actions
FOR INSERT OR UPDATE ON BorrowedBooks
COMPOUND TRIGGER

    TYPE t_audit_rec IS RECORD (
        borrowId    BorrowedBooks.borrowId%TYPE,
        actionType  BookAudit.actionType%TYPE
    );

    TYPE t_audit_tab IS TABLE OF t_audit_rec INDEX BY PLS_INTEGER;
    v_audits t_audit_tab;
    v_index  INTEGER := 0;

    -- BEFORE EACH ROW section
    BEFORE EACH ROW IS
    BEGIN
        -- INSERT CASE (loaned)
        IF INSERTING THEN
            v_index := v_index + 1;
            v_audits(v_index).borrowId   := :NEW.borrowId;
            v_audits(v_index).actionType := 'Loaned';

        -- UPDATE CASE (returnStatus changed to Returned/Lost)
        ELSIF UPDATING THEN
            IF :OLD.returnStatus IS NULL OR :OLD.returnStatus != :NEW.returnStatus THEN
                IF :NEW.returnStatus = 'Returned' THEN
                    v_index := v_index + 1;
                    v_audits(v_index).borrowId   := :NEW.borrowId;
                    v_audits(v_index).actionType := 'Returned';
                ELSIF :NEW.returnStatus = 'Lost' THEN
                    v_index := v_index + 1;
                    v_audits(v_index).borrowId   := :NEW.borrowId;
                    v_audits(v_index).actionType := 'Lost';
                END IF;
            END IF;
        END IF;
    END BEFORE EACH ROW;

    -- AFTER STATEMENT section
    AFTER STATEMENT IS
    BEGIN
        FOR i IN 1 .. v_index LOOP
            -- Check if the audit entry already exists before inserting
            DECLARE
                v_exists INTEGER;
            BEGIN
                -- Check if the audit record already exists for the same borrowId and actionType
                SELECT COUNT(*)
                INTO v_exists
                FROM BookAudit
                WHERE borrowId = v_audits(i).borrowId
                  AND actionType = v_audits(i).actionType;
                
                -- Only insert if no existing record is found
                IF v_exists = 0 THEN
                    INSERT INTO BookAudit (
                        auditId, borrowId, staffId, actionType, actionDate, notes
                    ) VALUES (
                        'BA' || LPAD(bookaudit_seq.NEXTVAL, 4, '0'),
                        v_audits(i).borrowId,
                        'S00' || TRUNC(DBMS_RANDOM.VALUE(2, 8)),  -- random S002 to S007
                        v_audits(i).actionType,
                        SYSDATE,
                        'Action Type recorded.'
                    );
                END IF;
            END;
        END LOOP;
    END AFTER STATEMENT;

END;
/

CREATE OR REPLACE TRIGGER trg_manage_loan_extension
FOR UPDATE OF extendStatus ON BorrowedBooks
COMPOUND TRIGGER

    TYPE t_ext IS RECORD (
        borrowId    BorrowedBooks.borrowId%TYPE,
        memberId  BorrowedBooks.memberId%TYPE,
        oldStatus   BorrowedBooks.extendStatus%TYPE,
        newStatus   BorrowedBooks.extendStatus%TYPE
    );

    TYPE t_ext_tab IS TABLE OF t_ext INDEX BY PLS_INTEGER;
    v_ext t_ext_tab;
    v_index INTEGER := 0;

    AFTER EACH ROW IS
    BEGIN
        v_index := v_index + 1;
        v_ext(v_index).borrowId   := :NEW.borrowId;
        v_ext(v_index).memberId := :NEW.memberId;
        v_ext(v_index).oldStatus  := :OLD.extendStatus;
        v_ext(v_index).newStatus  := :NEW.extendStatus;
    END AFTER EACH ROW;

    AFTER STATEMENT IS
    BEGIN
        FOR i IN 1 .. v_index LOOP
            IF v_ext(i).newStatus = 'Pending' THEN
                DECLARE
                    v_lost_count INTEGER;
                BEGIN
                    SELECT COUNT(*)
                    INTO v_lost_count
                    FROM BorrowedBooks
                    WHERE memberId = v_ext(i).memberId
                    AND returnStatus = 'Lost';

                    IF v_lost_count >= 3 THEN
                        UPDATE BorrowedBooks
                        SET extendStatus = 'Rejected'
                        WHERE borrowId = v_ext(i).borrowId;
                    ELSE
                        UPDATE BorrowedBooks
                        SET extendStatus = 'Approved',
                            dueDate = dueDate + 7
                        WHERE borrowId = v_ext(i).borrowId;
                    END IF;
                END;
            
            ELSIF v_ext(i).oldStatus = 'Approved' AND v_ext(i).newStatus = 'Canceled' THEN
                UPDATE BorrowedBooks
                SET dueDate = dueDate - 7
                WHERE borrowId = v_ext(i).borrowId;
            END IF;
        END LOOP;
    END AFTER STATEMENT;

END;
/
