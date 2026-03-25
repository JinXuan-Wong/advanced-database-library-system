-- Stored Procedure 1: Add New Reservation

CREATE OR REPLACE PROCEDURE AddNewReservation (
    p_memberId         IN Reservation.memberId%TYPE,
    p_copyId           IN Reservation.copyId%TYPE,
    p_reservationDate  IN DATE,
    p_status           IN Reservation.reservationStatus%TYPE
)
AS
    v_exists NUMBER;
BEGIN
    -- Check if a reservation already exists for this member and copy on the same date
    SELECT COUNT(*) INTO v_exists
    FROM Reservation
    WHERE memberId = p_memberId
      AND copyId = p_copyId
      AND reservationDate = p_reservationDate;

    IF v_exists > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Reservation already exists for this book copy on the selected date.');
    ELSE
        INSERT INTO Reservation (
            reservationId, memberId, copyId, reservationDate, reservationStatus
        )
        VALUES (
            'R' || LPAD(Reservation_seq.NEXTVAL, 3, '0'),
            p_memberId,
            p_copyId,
            p_reservationDate,
            p_status
        );

        DBMS_OUTPUT.PUT_LINE('Reservation successfully added.');
    END IF;
END;
/
