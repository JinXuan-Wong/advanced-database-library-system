CREATE OR REPLACE TRIGGER trg_auto_expire_membership
BEFORE UPDATE ON Members
FOR EACH ROW
WHEN (NEW.expireDate <= SYSDATE AND OLD.memberStatus = 'active')
BEGIN
    -- Automatically update the member status to 'Expire'
    :NEW.memberStatus := 'Expire';

    -- Cancel all pending reservations for this member
    UPDATE Reservation
    SET reservationStatus = 'Cancelled'
    WHERE memberId = :OLD.memberId
      AND reservationStatus = 'Pending';
END;
/
