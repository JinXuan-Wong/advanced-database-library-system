-- Stored Procedure 2: Check Book Availability

CREATE OR REPLACE PROCEDURE CheckBookAvailability (
    p_bookId IN VARCHAR2
)
IS
    v_available_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_available_count
    FROM BookCopies bc
    WHERE bc.bookId = p_bookId
      AND NOT EXISTS (
          SELECT 1 FROM Reservation r
          WHERE r.copyId = bc.copyId AND r.reservationStatus = 'Reserved'
      );

    IF v_available_count > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Book ID ' || p_bookId || ' has ' || v_available_count || ' available copy/copies.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('No available copies for Book ID ' || p_bookId);
    END IF;
END;
/
