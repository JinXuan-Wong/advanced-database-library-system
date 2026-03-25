CREATE OR REPLACE VIEW vw_member_borrow_status AS
SELECT 
    m.memberId         AS member_id,
    m.memberName       AS member_name,
    COUNT(bb.borrowId) AS total_borrowed,
    SUM(CASE WHEN bb.extendStatus IN ('Pending', 'Approved') THEN 1 ELSE 0 END) AS total_extensions,
    SUM(CASE WHEN bb.returnStatus = 'Overdue' THEN 1 ELSE 0 END) AS overdue_count
FROM 
    Members m
JOIN 
    BorrowedBooks bb ON m.memberId = bb.memberId
JOIN 
    BookCopies bc ON bb.copyId = bc.copyId
WHERE 
    m.memberStatus = 'active'
GROUP BY 
    m.memberId, m.memberName;