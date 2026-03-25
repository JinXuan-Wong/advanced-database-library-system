-- SETUP SQLPLUS ENVIRONMENT
SET LINESIZE 200
SET PAGESIZE 30
SET WRAP OFF
SET TRIMSPOOL ON

-- FORMAT OUTPUT FOR SQLPLUS
COLUMN "MEMBER ID"           FORMAT A10
COLUMN "MEMBER NAME"         FORMAT A25
COLUMN "LATEST RESERVATION"  FORMAT A19
COLUMN "TOTAL RESERVATIONS"  FORMAT 9999
COLUMN "RESERVED BOOK ID(S)" FORMAT A30

-- HEADER
PROMPT
PROMPT =========================== RECENT MEMBERS RESERVATION ACTIVITY (APR-JUN 2024) ===========================
PROMPT

-- QUERY
SELECT 
    m.memberId                            AS "MEMBER ID",
    m.memberName                          AS "MEMBER NAME",
    TO_CHAR(MAX(r.reservationDate), 'YYYY-MM-DD') AS "LATEST RESERVATION",
    COUNT(r.reservationId)               AS "TOTAL RESERVATIONS",
    LISTAGG(bt.bookId, ', ') 
        WITHIN GROUP (ORDER BY bt.bookId) AS "RESERVED BOOK ID(S)"
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
    m.memberId, m.memberName
ORDER BY 
    "LATEST RESERVATION" DESC, m.memberId;
