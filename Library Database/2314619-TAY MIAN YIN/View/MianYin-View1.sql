CREATE OR REPLACE VIEW MonthlyReservationsOverview AS
SELECT
    TO_CHAR(r.reservationDate, 'YYYY-MM') AS month,
    COUNT(r.reservationId) AS total_reservations,
    COUNT(DISTINCT r.memberId) AS unique_reservers,
    SUM(CASE WHEN r.reservationStatus = 'Available' THEN 1 ELSE 0 END) AS fulfilled_reservations,
    SUM(CASE WHEN r.reservationStatus = 'Pending' THEN 1 ELSE 0 END) AS pending_reservations,
    SUM(CASE WHEN r.reservationStatus = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_reservations,
    COUNT(DISTINCT bc.bookId) AS distinct_books_reserved,
    TO_CHAR(MAX(r.reservationDate), 'YYYY-MM-DD') AS latest_reservation
FROM
    Reservation r
JOIN
    BookCopies bc ON r.copyId = bc.copyId
JOIN
    BookTitles bt ON bc.bookId = bt.bookId
WHERE
    r.reservationDate IS NOT NULL
GROUP BY
    TO_CHAR(r.reservationDate, 'YYYY-MM');
