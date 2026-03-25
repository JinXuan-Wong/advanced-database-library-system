CREATE OR REPLACE TRIGGER trg_borrow_limit_enforcement
BEFORE INSERT ON BorrowedBooks
FOR EACH ROW
DECLARE
    v_active_borrow_count NUMBER;
    v_member_status Members.memberStatus%TYPE;
BEGIN
    -- Get the current number of active borrowings (not returned or lost)
    SELECT COUNT(*)
    INTO v_active_borrow_count
    FROM BorrowedBooks
    WHERE memberId = :NEW.memberId
      AND returnStatus IN ('On Loan', 'Overdue');

    IF v_active_borrow_count >= 5 THEN
        RAISE_APPLICATION_ERROR(-20010, 'Borrowing limit reached: A member can borrow up to 5 books only.');
    END IF;

    -- Check if the member is active
    SELECT memberStatus INTO v_member_status
    FROM Members
    WHERE memberId = :NEW.memberId;

    IF v_member_status != 'active' THEN
        RAISE_APPLICATION_ERROR(-20011, 'Only active members can borrow books.');
    END IF;
END;
/


