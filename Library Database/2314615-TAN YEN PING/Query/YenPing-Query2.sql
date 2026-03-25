-- SETUP SQLPLUS ENVIRONMENT
SET LINESIZE 200
SET PAGESIZE 50
SET WRAP OFF
SET TRIMSPOOL ON

-- FORMAT OUTPUT FOR SQLPLUS
COLUMN "BOOK TITLE" FORMAT A45
COLUMN "MEMBER ID" FORMAT A10
COLUMN "BORROW DATE" FORMAT A15
COLUMN "DUE DATE" FORMAT A15
COLUMN "RETURN STATUS" FORMAT A15
COLUMN "ACTION TYPE" FORMAT A15
COLUMN "STAFF ID" FORMAT A10
COLUMN "ACTION DATE" FORMAT A15

-- ASK USER TO ENTER MEMBER ID FILTER
ACCEPT member_filter CHAR PROMPT 'Enter Member ID to filter (leave empty for no filter): '

-- HEADER
PROMPT
PROMPT ========================================= BORROWING STATUS AND RETURN HISTORY ================================================
PROMPT

-- QUERY
SELECT 
    bt.title AS "BOOK TITLE",
    bb.memberId AS "MEMBER ID",
    bb.borrowDate AS "BORROW DATE",
    bb.dueDate AS "DUE DATE",
    bb.returnStatus AS "RETURN STATUS",
    ba.actionType AS "ACTION TYPE",
    ba.staffId AS "STAFF ID",
    ba.actionDate AS "ACTION DATE"
FROM 
    BorrowedBooks bb
JOIN 
    BookCopies bc ON bb.copyId = bc.copyId
JOIN 
    BookTitles bt ON bc.bookId = bt.bookId
JOIN 
    BookAudit ba ON bb.borrowId = ba.borrowId
WHERE 
    (bb.memberId = '&member_filter' OR '&member_filter' IS NULL)
ORDER BY 
    ba.actionDate DESC, bb.borrowDate DESC;
