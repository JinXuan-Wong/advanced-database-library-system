CREATE OR REPLACE VIEW BooksDemandView AS
SELECT
    bt.title AS title,
    COUNT(r.reservationId) AS total_reservations
FROM 
    BookTitles bt
JOIN 
    BookCopies bc ON bt.bookId = bc.bookId
JOIN 
    Reservation r ON bc.copyId = r.copyId
WHERE 
    bc.bookStatus != 'Available'
    AND r.reservationStatus = 'Pending'
GROUP BY 
    bt.title
HAVING 
    COUNT(r.reservationId) > 3;
