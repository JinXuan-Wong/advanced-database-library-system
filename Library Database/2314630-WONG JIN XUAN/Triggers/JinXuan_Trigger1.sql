---------------------- TRIGGER 1 - Manage Book Details Validation -----------------------
CREATE OR REPLACE TRIGGER TRG_MANAGE_BOOK_DETAILS
BEFORE INSERT OR UPDATE ON BookTitles
FOR EACH ROW
DECLARE
   v_count NUMBER;
BEGIN
   -- Ensure ISBN is unique
   SELECT COUNT(*) INTO v_count FROM BookTitles WHERE isbn = :NEW.isbn AND bookId <> :NEW.bookId;
   IF v_count > 0 THEN
      RAISE_APPLICATION_ERROR(-20001, 'Error: ISBN must be unique.');
   END IF; 

   -- Ensure publication year is valid
   IF :NEW.publicationYear > EXTRACT(YEAR FROM SYSDATE) THEN
      RAISE_APPLICATION_ERROR(-20002, 'Error: Publication year cannot be in the future.');
   END IF;

   -- Ensure price is positive
   IF :NEW.price < 0 THEN
      RAISE_APPLICATION_ERROR(-20003, 'Error: Price must be zero or greater.');
   END IF;

   -- Ensure popularity is within the range 1.0 - 5.0
   IF :NEW.popularity < 1.0 OR :NEW.popularity > 5.0 THEN
      RAISE_APPLICATION_ERROR(-20004, 'Error: Popularity must be between 1.0 and 5.0.');
   END IF;
END;
/

/*         TEST SAMPLE OUTPUT OF ERROR FROM TRIGGER

-- Insert a book with same existing ISBN from B001 (should trigger error)
INSERT INTO BookTitles (bookId, title, author, genre, publicationYear, isbn, price, popularity)
VALUES ('B998', 'Test Book 1', 'Author A', 'Mystery', 2023, '1649374178', 20.00, 3.5);

-- Attempt to insert a book with a future publication year (e.g., 2026)
INSERT INTO BookTitles (bookId, title, author, genre, publicationYear, isbn, price, popularity)
VALUES ('B997', 'Future Book', 'Author C', 'Sci-Fi', 2026, '9876543210', 30.00, 4.5);

-- Attempt to insert a book with a negative price
INSERT INTO BookTitles (bookId, title, author, genre, publicationYear, isbn, price, popularity)
VALUES ('B996', 'Free Book?', 'Author D', 'Education', 2022, '1111111111', -10.00, 3.0);

-- Attempt to insert a book with popularity outside the valid range (e.g., 5.5)
INSERT INTO BookTitles (bookId, title, author, genre, publicationYear, isbn, price, popularity)
VALUES ('B995', 'Overrated Book', 'Author E', 'Drama', 2021, '2222222222', 18.00, 5.5);

*/
