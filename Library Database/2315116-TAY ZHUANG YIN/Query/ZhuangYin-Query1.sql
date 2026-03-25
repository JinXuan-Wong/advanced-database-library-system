-- SETUP SQLPLUS ENVIRONMENT
SET linesize 120
SET pagesize 50
SET WRAP ON
SET TRIMSPOOL ON

-- FORMAT OUTPUT FOR SQLPLUS
COLUMN "MEMBER ID"        FORMAT A10
COLUMN "MEMBER NAME"      FORMAT A20
COLUMN "TOTAL BORROWED"   FORMAT 9999
COLUMN "TOTAL EXTENSIONS" FORMAT 9999
COLUMN "OVERDUE COUNT"    FORMAT 9999

-- HEADER
PROMPT
PROMPT ==== Analysis of Active Members with High Extensions and Overdue Activity ====
PROMPT

-- QUERY
SELECT 
    member_id       AS "MEMBER ID",
    member_name     AS "MEMBER NAME",
    total_borrowed  AS "TOTAL BORROWED",
    total_extensions AS "TOTAL EXTENSIONS",
    overdue_count   AS "OVERDUE COUNT"
FROM 
    vw_member_borrow_status
WHERE 
    total_extensions > 2 
    OR overdue_count > 2
ORDER BY 
    total_extensions DESC, overdue_count DESC;