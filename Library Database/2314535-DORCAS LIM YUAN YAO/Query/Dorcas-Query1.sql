-- SETUP SQLPLUS ENVIRONMENT
SET LINESIZE 200
SET PAGESIZE 50
SET WRAP OFF
SET TRIMSPOOL ON

-- FORMAT OUTPUT FOR SQLPLUS
COLUMN "STAFF ID"        FORMAT A10
COLUMN "STAFF NAME"      FORMAT A25
COLUMN "SHIFT ID"        FORMAT A10
COLUMN "SHIFT TYPE"      FORMAT A20
COLUMN "START TIME"      FORMAT A10
COLUMN "END TIME"        FORMAT A10
COLUMN "TOTAL RESERVATIONS" FORMAT 9999

-- HEADER
PROMPT
PROMPT ======================== TOTAL RESERVATIONS HANDLED BY EACH STAFF PER SHIFT (RANKED) ========================
PROMPT

SELECT 
    s.staffId AS "STAFF ID",
    s.staffName AS "STAFF NAME",
    sh.shiftId AS "SHIFT ID",
    sh.shiftType AS "SHIFT TYPE",
    TO_CHAR(sh.startTime, 'HH24:MI') AS "START TIME",
    TO_CHAR(sh.endTime, 'HH24:MI') AS "END TIME",
    COUNT(DISTINCT r.reservationId) AS "TOTAL RESERVATIONS"
FROM 
    Staff s
JOIN 
    ShiftSchedules ss ON s.staffId = ss.staffId
JOIN 
    Shift sh ON ss.shiftId = sh.shiftId
LEFT JOIN 
    BookAudit ba ON ba.staffId = s.staffId
    AND ba.actionType IN ('Loaned', 'Returned')
LEFT JOIN 
    BorrowedBooks bb ON ba.borrowId = bb.borrowId
LEFT JOIN 
    Reservation r ON (r.copyId = bb.copyId OR r.memberId = bb.memberId)
    AND r.reservationStatus = 'Available'
WHERE 
    s.role IN ('librarian', 'assistant')
GROUP BY 
    s.staffId, s.staffName, sh.shiftId, sh.shiftType, sh.startTime, sh.endTime
ORDER BY 
    COUNT(DISTINCT r.reservationId) DESC,
    sh.shiftType,
    s.staffId;