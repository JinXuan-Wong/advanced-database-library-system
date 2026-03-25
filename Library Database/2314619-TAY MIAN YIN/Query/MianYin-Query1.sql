-- SETUP SQLPLUS ENVIRONMENT
SET LINESIZE 200
SET PAGESIZE 100
SET TRIMSPOOL ON
SET TAB OFF
SET FEEDBACK ON
SET VERIFY OFF

-- FORMAT OUTPUT FOR SQLPLUS
COLUMN "Month"                   FORMAT A15
COLUMN "Total Reservations"      FORMAT 9999
COLUMN "Unique Reservers"        FORMAT 9999
COLUMN "Fulfilled Reservations"  FORMAT 9999
COLUMN "Pending Reservations"    FORMAT 9999
COLUMN "Cancelled Reservations"  FORMAT 9999
COLUMN "Distinct Books Reserved" FORMAT 9999
COLUMN "Latest Reservation"      FORMAT A20

-- HEADER
PROMPT
PROMPT ================================================================== Monthly Reservations Overview ==================================================================
PROMPT

-- MAIN QUERY
SELECT
    month AS "Month",
    total_reservations AS "Total Reservations",
    unique_reservers AS "Unique Reservers",
    fulfilled_reservations AS "Fulfilled Reservations",
    pending_reservations AS "Pending Reservations",
    cancelled_reservations AS "Cancelled Reservations",
    distinct_books_reserved AS "Distinct Books Reserved",
    latest_reservation AS "Latest Reservation"
FROM
    MonthlyReservationsOverview
ORDER BY
    month DESC;