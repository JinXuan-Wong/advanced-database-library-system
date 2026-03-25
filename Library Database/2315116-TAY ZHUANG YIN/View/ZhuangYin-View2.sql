CREATE OR REPLACE VIEW vw_member_fine_payments AS
SELECT 
    m.memberId AS member_id,
    m.memberName AS member_name,
    COUNT(f.fineId) AS total_fines,
    SUM(p.payAmount) AS total_payment
FROM 
    Members m
JOIN 
    Payments p ON m.memberId = p.memberId
JOIN 
    Fines f ON p.paymentId = f.paymentId
WHERE 
    f.fineStatus = 'Paid'
GROUP BY 
    m.memberId, m.memberName;