---------------------- Trigger 2 - Automatic Book Status Update -------------------------
-- *Note: Must be separated into 3 triggers because bookStatus is referring to 3 separate tables to be updated

--------------------- TRIGGER 1 - Book Status from BorrowedBooks ------------------------
CREATE OR REPLACE TRIGGER TRG_MANAGE_BOOK_STATUS_BB
FOR INSERT OR UPDATE ON BorrowedBooks
COMPOUND TRIGGER

   -- Declare a collection to store affected copyIds
   TYPE CopyIdList IS TABLE OF BookCopies.copyId%TYPE;
   affected_copyIds CopyIdList := CopyIdList(); 

   -- BEFORE EACH ROW: Store affected copyIds
   BEFORE EACH ROW IS
   BEGIN
      affected_copyIds.EXTEND;
      affected_copyIds(affected_copyIds.LAST) := :NEW.copyId;
   END BEFORE EACH ROW;

   -- AFTER STATEMENT: Process all affected copyIds
   AFTER STATEMENT IS
   BEGIN
      FOR i IN 1..affected_copyIds.COUNT LOOP
         DECLARE
            v_copyId BookCopies.copyId%TYPE := affected_copyIds(i);
            v_new_status BookCopies.bookStatus%TYPE;
            v_current_status BookCopies.bookStatus%TYPE;
         BEGIN
            -- Get current book status
            SELECT bookStatus INTO v_current_status
            FROM BookCopies
            WHERE copyId = v_copyId;

            -- Determine new book status
            SELECT
               CASE 
                  -- 1. If book is borrowed, set to "Borrowed"
                  WHEN EXISTS (
                     SELECT 1 FROM BorrowedBooks 
                     WHERE copyId = v_copyId  
                     AND returnStatus = 'On loan'
                  ) THEN 'borrowed'

                  -- 2. If book is returned, check reservations
                  WHEN EXISTS (
                     SELECT 1 FROM BorrowedBooks 
                     WHERE copyId = v_copyId  
                     AND returnStatus = 'Returned'
                  ) 
                  THEN (
                     CASE 
                        WHEN EXISTS (
                           SELECT 1 FROM Reservation 
                           WHERE copyId = v_copyId 
                           AND reservationStatus = 'Pending'
                        ) THEN 'reserved'
                        ELSE 'available'
                     END
                  )

                  ELSE v_current_status
               END
            INTO v_new_status
            FROM dual;

            -- Update only if book status has changed
            IF v_new_status IS NOT NULL AND v_new_status <> v_current_status THEN
               UPDATE BookCopies
               SET bookStatus = v_new_status
               WHERE copyId = v_copyId;
            END IF;
         END;
      END LOOP;
   END AFTER STATEMENT;
END TRG_MANAGE_BOOK_STATUS_BB;
/

--------------------- TRIGGER 2 - Book Status from Reservation ----------------------
CREATE OR REPLACE TRIGGER TRG_MANAGE_BOOK_STATUS_RES
FOR INSERT OR UPDATE ON Reservation
COMPOUND TRIGGER 

   TYPE Reservation_Rec IS RECORD (
      copyId BookCopies.copyId%TYPE,
      reservationStatus Reservation.reservationStatus%TYPE
   );

   TYPE Reservation_Table IS TABLE OF Reservation_Rec;
   reservation_data Reservation_Table := Reservation_Table(); -- Initialize collection

   BEFORE EACH ROW IS
   BEGIN
      -- Store data for later processing
      reservation_data.EXTEND;
      reservation_data(reservation_data.LAST).copyId := :NEW.copyId;
      reservation_data(reservation_data.LAST).reservationStatus := :NEW.reservationStatus;
   END BEFORE EACH ROW;

   AFTER STATEMENT IS
   BEGIN
      FOR i IN 1..reservation_data.COUNT LOOP
         DECLARE
            v_current_status BookCopies.bookStatus%TYPE;
            v_new_status BookCopies.bookStatus%TYPE;
         BEGIN
            -- Get current book status
            SELECT bookStatus INTO v_current_status
            FROM BookCopies
            WHERE copyId = reservation_data(i).copyId;

            -- Determine new book status
            v_new_status := 
               CASE 
                  -- 3. If a reservation is made while book is available, set to "reserved"
                  WHEN reservation_data(i).reservationStatus = 'Pending'
                       AND v_current_status = 'available' 
                  THEN 'reserved'

                  -- 4. If a reservation is cancelled, book becomes "available"
                  WHEN reservation_data(i).reservationStatus = 'Cancelled' 
                  THEN 'available'

                  ELSE v_current_status
               END;

            -- Update only if book status has changed
            IF v_new_status IS NOT NULL AND v_new_status <> v_current_status THEN
               UPDATE BookCopies
               SET bookStatus = v_new_status
               WHERE copyId = reservation_data(i).copyId;
            END IF;
         END;
      END LOOP;
   END AFTER STATEMENT;

END TRG_MANAGE_BOOK_STATUS_RES;
/

--------------------- TRIGGER 3 - Book Status from BookAudit ------------------------
CREATE OR REPLACE TRIGGER TRG_MANAGE_BOOK_STATUS_AUDIT
FOR INSERT OR UPDATE ON BookAudit
COMPOUND TRIGGER 

   TYPE Audit_Rec IS RECORD (
      copyId BookCopies.copyId%TYPE,
      actionType BookAudit.actionType%TYPE
   );

   TYPE Audit_Table IS TABLE OF Audit_Rec;
   audit_data Audit_Table := Audit_Table(); -- Initialize

   BEFORE EACH ROW IS
      v_copyId BookCopies.copyId%TYPE;
   BEGIN
      -- Get the copyId from BorrowedBooks
      SELECT copyId INTO v_copyId
      FROM BorrowedBooks
      WHERE borrowId = :NEW.borrowId;

      -- Store data for later processing
      audit_data.EXTEND;
      audit_data(audit_data.LAST).copyId := v_copyId;
      audit_data(audit_data.LAST).actionType := :NEW.actionType;
   END BEFORE EACH ROW;

   AFTER STATEMENT IS
   BEGIN
      FOR i IN 1..audit_data.COUNT LOOP
         -- Update BookCopies status based on actionType
         -- 5. If book is lost set to "Unavailable"
         IF audit_data(i).actionType IN ('Lost') THEN
            UPDATE BookCopies
            SET bookStatus = 'unavailable'
            WHERE copyId = audit_data(i).copyId;
         END IF;
      END LOOP;
   END AFTER STATEMENT;

END TRG_MANAGE_BOOK_STATUS_AUDIT;
/
