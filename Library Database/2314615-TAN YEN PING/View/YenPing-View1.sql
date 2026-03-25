/* 
        Create this view in terminal
            Month Start: 3
            Month End: 4
*/

CREATE VIEW BorrowingReturnTracking AS
SELECT
    TO_CHAR(bb.borrowDate, 'DD-MON-YYYY') AS "DATE",
    m.memberId AS "MEMBER ID",
    m.memberName AS "MEMBER NAME",
    COUNT(bb.borrowId) AS "TOTAL BORROWS",
    COUNT(DISTINCT bb.copyId) AS "TOTAL BOOKS BORROWED",
    SUM(CASE WHEN bb.returnStatus = 'Returned' THEN 1 ELSE 0 END) AS "TOTAL RETURNED"
FROM 
    BorrowedBooks bb
JOIN 
    Members m ON bb.memberId = m.memberId
JOIN 
    BookCopies bc ON bb.copyId = bc.copyId
JOIN 
    BookTitles bt ON bc.bookId = bt.bookId
GROUP BY 
    bb.borrowDate, m.memberId, m.memberName;

