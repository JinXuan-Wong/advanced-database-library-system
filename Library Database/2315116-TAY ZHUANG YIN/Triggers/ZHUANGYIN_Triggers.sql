/*Trigger 1: UPDATE_FINE_AMOUNT*/

CREATE OR REPLACE TRIGGER TRG_CALCULATE_FINE_AMOUNT
BEFORE INSERT OR UPDATE ON Fines
FOR EACH ROW
WHEN (NEW.fineAmount IS NULL)
DECLARE
   v_price BookTitles.price%TYPE;
BEGIN
   IF :NEW.fineType IN ('Lost Book', 'Damage') THEN
      SELECT BT.price
      INTO v_price
      FROM BookTitles BT
      JOIN BookCopies BC ON BC.bookId = BT.bookId
      JOIN BorrowedBooks BB ON BB.copyId = BC.copyId
      WHERE BB.borrowId = :NEW.borrowId;

      IF :NEW.fineType = 'Lost Book' THEN
         :NEW.fineAmount := v_price + 20;
      ELSIF :NEW.fineType = 'Damage' THEN
         :NEW.fineAmount := v_price;
      END IF;

   ELSIF :NEW.fineType = 'Late Return' THEN
      :NEW.fineAmount := 30;
   END IF;
END;
/

/*Trigger 2: UPDATE_PAYMENT_AMOUNT*/

CREATE OR REPLACE TRIGGER TRG_CALCULATE_PAYMENT_AMOUNT
BEFORE INSERT OR UPDATE ON Payments
FOR EACH ROW
WHEN (NEW.payAmount IS NULL)
DECLARE
   v_total NUMBER;
BEGIN
   IF :NEW.paymentType = 'Fines' THEN
      SELECT SUM(fineAmount)
      INTO v_total
      FROM Fines
      WHERE paymentId = :NEW.paymentId;

      :NEW.payAmount := NVL(v_total, 0);

   ELSIF :NEW.paymentType = 'Membership Registration' THEN
      :NEW.payAmount := 50;
   END IF;
END;
/

/*Trigger 3: MANAGE_FINES*/

CREATE OR REPLACE TRIGGER TRG_MANAGE_FINES
BEFORE INSERT OR UPDATE ON Fines
FOR EACH ROW
BEGIN
   -- Validate fineType
   IF :NEW.fineType NOT IN ('Late Return', 'Lost Book', 'Damage') THEN
      RAISE_APPLICATION_ERROR(-20010, 'Invalid fine type. Allowed: Late Return, Lost Book, Damage.');
   END IF;

   -- Validate fineStatus
   IF :NEW.fineStatus NOT IN ('Unpaid', 'Paid') THEN
      RAISE_APPLICATION_ERROR(-20011, 'Invalid fine status. Allowed: Unpaid, Paid.');
   END IF;

-- Validate fineAmount (ensure non-negative value)
   IF :NEW.fineAmount <= 0 THEN
      RAISE_APPLICATION_ERROR(-20012, 'Fine amount cannot be negative.');
   END IF;
END;
/

/*Trigger 4: MANAGE_PAYMENTS*/

CREATE OR REPLACE TRIGGER TRG_MANAGE_PAYMENTS
AFTER INSERT OR UPDATE ON Payments
FOR EACH ROW
BEGIN
   -- Validate paymentMethod
   IF :NEW.paymentMethod NOT IN ('Tng', 'Cash', 'Duitnow') THEN
      RAISE_APPLICATION_ERROR(-20013, 'Invalid payment method. Allowed: Tng, Cash, Duitnow.');
   END IF;

   -- Validate paymentType
   IF :NEW.paymentType NOT IN ('Fines', 'Membership Registration') THEN
      RAISE_APPLICATION_ERROR(-20014, 'Invalid payment type. Allowed: Fines, Membership Registration.');
   END IF;

   -- Validate payAmount (ensure non-negative value)
   IF :NEW.payAmount <= 0 THEN
      RAISE_APPLICATION_ERROR(-20015, 'Payment amount cannot be negative.');
   END IF;

   -- Update fineStatus if payment is for a fine and has amount
   IF :NEW.paymentType = 'Fines' AND :NEW.payAmount IS NOT NULL THEN
      UPDATE Fines
      SET fineStatus = 'Paid'
      WHERE paymentId = :NEW.paymentId;
   END IF;
END;
/