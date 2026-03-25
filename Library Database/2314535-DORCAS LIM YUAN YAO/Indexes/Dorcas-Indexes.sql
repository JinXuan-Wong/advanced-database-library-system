-- Index 1: Reservation Report by Status and Month
-- rpt_reservation_by_statusmonth
CREATE INDEX idx_reservation_statusmonth
ON Reservation (LOWER(TRIM(reservationStatus)),TO_CHAR(reservationDate, 'MM'));

-- Index 2: Overdue Books Report
-- rpt_overdue_books
CREATE INDEX idx_due_return ON BorrowedBooks (returnDate, dueDate);

