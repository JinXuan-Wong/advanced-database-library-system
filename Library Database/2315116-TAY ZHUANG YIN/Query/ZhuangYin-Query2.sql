-- SETUP SQLPLUS ENVIRONMENT
SET linesize 120
SET pagesize 50
SET WRAP ON
SET TRIMSPOOL ON

ACCEPT n NUMBER PROMPT 'Enter the value of n to display the top n members with the most fine payments:'

-- FORMAT OUTPUT FOR SQLPLUS
COLUMN "MEMBER ID"     FORMAT A10
COLUMN "MEMBER NAME"   FORMAT A20
COLUMN "TOTAL FINES"   FORMAT 9999
COLUMN "TOTAL PAYMENT" FORMAT 9999.99

-- HEADER
PROMPT
PROMPT ========== Top Members with Most Fine Payments ==========
PROMPT

SELECT * FROM (
    SELECT 
        member_id AS "MEMBER ID",
        member_name AS "MEMBER NAME",
        total_fines AS "TOTAL FINES",
        total_payment AS "TOTAL PAYMENT"
    FROM 
        vw_member_fine_payments
    ORDER BY
        total_payment DESC
)
WHERE ROWNUM <= &n;
