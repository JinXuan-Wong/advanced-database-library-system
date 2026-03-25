-- SETUP SQLPLUS ENVIRONMENT
SET LINESIZE 120
SET PAGESIZE 50
SET WRAP OFF
SET TRIMSPOOL ON

-- FORMAT OUTPUT FOR SQLPLUS
COLUMN "Title" FORMAT A60
COLUMN "Total Reservations" FORMAT 9999

-- Header
PROMPT
PROMPT =========== High-Demand Books: Frequently Reserved but Unavailable ============
PROMPT

-- Main query
SELECT * FROM BooksDemandView
ORDER BY total_reservations DESC;