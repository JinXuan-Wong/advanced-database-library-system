CREATE OR REPLACE VIEW Book_Borrow_Return_History AS
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
    BookAudit ba ON bb.borrowId = ba.borrowId;
