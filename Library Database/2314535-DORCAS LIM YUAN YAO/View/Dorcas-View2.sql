CREATE OR REPLACE VIEW RecentMemberReservation AS
SELECT 
    m.memberId                            AS member_id,
    m.memberName                          AS member_name,
    TO_CHAR(MAX(r.reservationDate), 'YYYY-MM-DD') AS latest_reservation,
    COUNT(r.reservationId)               AS total_reservations,
    LISTAGG(bt.bookId, ', ') 
        WITHIN GROUP (ORDER BY bt.bookId) AS reserved_book_ids
FROM 
    Members m
JOIN 
    Reservation r ON r.memberId = m.memberId
JOIN 
    BookCopies bc ON r.copyId = bc.copyId
JOIN 
    BookTitles bt ON bc.bookId = bt.bookId
WHERE 
    r.reservationDate BETWEEN TO_DATE('01-APR-2024', 'DD-MON-YYYY') 
                          AND TO_DATE('30-JUN-2024', 'DD-MON-YYYY')
GROUP BY 
    m.memberId, m.memberName;
