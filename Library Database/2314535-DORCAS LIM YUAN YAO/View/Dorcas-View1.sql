CREATE OR REPLACE VIEW vw_staffreservationperformance AS
SELECT 
    s.staffId AS "STAFF_ID",
    s.staffName AS "STAFF_NAME",
    sh.shiftId AS "SHIFT_ID",
    sh.shiftType AS "SHIFT_TYPE",
    TO_CHAR(sh.startTime, 'HH24:MI') AS "START_TIME",
    TO_CHAR(sh.endTime, 'HH24:MI') AS "END_TIME",
    COUNT(DISTINCT r.reservationId) AS "TOTAL_RESERVATIONS"
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