-- SETUP SQLPLUS ENVIRONMENT
SET LINESIZE 200
SET PAGESIZE 50
SET WRAP OFF
SET TRIMSPOOL ON

-- Ask user to input the start and end dates
ACCEPT month_start CHAR PROMPT 'Enter the start Date (DD-MON-YYYY): '
ACCEPT month_end CHAR PROMPT 'Enter the end Date (DD-MON-YYYY): '

-- Display the entered values
PROMPT Start Date: &&month_start
PROMPT End Date: &&month_end

-- FORMAT OUTPUT FOR SQLPLUS
COLUMN "DATE" FORMAT A20
COLUMN "MEMBER ID" FORMAT A15
COLUMN "MEMBER NAME" FORMAT A25
COLUMN "TOTAL BORROWS" FORMAT 9999
COLUMN "TOTAL BOOKS BORROWED" FORMAT 9999
COLUMN "TOTAL RETURNED" FORMAT 9999

-- HEADER
PROMPT
PROMPT ================================= BORROWING AND MEMBER RETURN RATE TRACKING ====================================

-- Query to fetch the borrowing and return data
SELECT
    TO_CHAR(bb.borrowDate, 'DD-MON-YYYY') AS "DATE",
    m.memberId AS "MEMBER ID",
    m.memberName AS "MEMBER NAME",
    COUNT(bb.borrowId) AS "TOTAL BORROWS", -- Total borrow transactions
    COUNT(DISTINCT bb.copyId) AS "TOTAL BOOKS BORROWED", -- Distinct books borrowed
    SUM(CASE WHEN bb.returnStatus = 'Returned' THEN 1 ELSE 0 END) AS "TOTAL RETURNED" -- Books returned
FROM 
    BorrowedBooks bb
JOIN 
    Members m ON bb.memberId = m.memberId
JOIN 
    BookCopies bc ON bb.copyId = bc.copyId
JOIN 
    BookTitles bt ON bc.bookId = bt.bookId
WHERE 
    bb.borrowDate BETWEEN TO_DATE('&&month_start', 'DD-MON-YYYY') 
                      AND TO_DATE('&&month_end', 'DD-MON-YYYY')
GROUP BY 
    bb.borrowDate, m.memberId, m.memberName
ORDER BY 
    bb.borrowDate DESC, m.memberId;
