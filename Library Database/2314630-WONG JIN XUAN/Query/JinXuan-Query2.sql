-- SQL*Plus: Set up display
SET SERVEROUTPUT ON
SET LINESIZE 150
SET PAGESIZE 50
SET WRAP ON
SET TRIMSPOOL ON
SET DEFINE OFF

-- Column formatting 
COLUMN "STAFF ID" FORMAT A10
COLUMN "STAFF NAME" FORMAT A20
COLUMN "STAFF ROLE" FORMAT A10
COLUMN "TOTAL SHIFTS WORKED" FORMAT 9999
COLUMN "TOTAL HOURS WORKED" FORMAT 9999
COLUMN "LOAN PROCESSED" FORMAT 9999
COLUMN "EFFICIENCY SCORE" FORMAT 0.99
COLUMN "PERFORMANCE SCORE" FORMAT 9999.99

PROMPT ====================================================================================================================================
PROMPT
PROMPT EFFICIENCY SCORE: This score shows the staff efficiency in processing loans. It is calculated by dividing:
PROMPT    - The number of loans processed by the total hours worked.
PROMPT EFFICIENCY SCORE = Loans Processed / Total Hours Worked (Librarians & Assistants only)
PROMPT 
PROMPT PERFORMANCE SCORE: This score represents attendance and performance during shifts. It is calculated based on:
PROMPT    - The total hours worked divided by the number of shifts.
PROMPT    - The attendance score (Present 1.0, Late 0.5, Absent 0) is used to adjust the performance for each shift worked.
PROMPT PERFORMANCE SCORE = (Hours Worked / Shifts) * Attendance Factor
PROMPT
PROMPT ====================================================================================================================================
PROMPT ================================================    STAFF PERFORMANCE QUERY    =====================================================
PROMPT ====================================================================================================================================

SELECT 
    sbv.staffId AS "STAFF ID",
    sbv.staffName AS "STAFF NAME",
    s.role AS "STAFF ROLE",
    sbv.shiftsWorked AS "TOTAL SHIFTS WORKED",
    CalculateTotalHoursWorked(sbv.staffId) AS "TOTAL HOURS WORKED",
    ROUND(
        (
            CalculateTotalHoursWorked(sbv.staffId) / sbv.shiftsWorked
        ) * 
        (
            SUM(
                CASE
                    WHEN sa.attendanceStatus = 'Present' THEN 1
                    WHEN sa.attendanceStatus = 'Late' THEN 0.5
                    WHEN sa.attendanceStatus = 'Absent' THEN 0
                    ELSE 0
                END
            ) / sbv.shiftsWorked
        ),
        2
    ) AS "PERFORMANCE SCORE", 
    CASE
        WHEN s.role IN ('librarian', 'assistant') THEN
            CalculateLoanProcessed(sbv.staffId)
        ELSE NULL
    END AS "LOAN PROCESSED",  
    CASE 
        WHEN s.role IN ('librarian', 'assistant') THEN
            ROUND(
                (
                    CalculateLoanProcessed(sbv.staffId)
                ) / 
                CASE WHEN CalculateTotalHoursWorked(sbv.staffId) > 0 THEN CalculateTotalHoursWorked(sbv.staffId) ELSE 1 END,
                2
            )
        ELSE NULL 
    END AS "EFFICIENCY SCORE"  
FROM 
    staff_basic_view sbv 
JOIN 
    ShiftSchedules ss ON ss.staffId = sbv.staffId
LEFT JOIN 
    StaffAttendance sa ON sa.scheduleId = ss.scheduleId
LEFT JOIN 
    Shift sh ON sh.shiftId = ss.shiftId
JOIN
    Staff s ON s.staffId = sbv.staffId
GROUP BY 
    sbv.staffId, sbv.staffName, s.role, sbv.shiftsWorked
ORDER BY
    CASE 
        WHEN s.role IN ('librarian', 'assistant') THEN 1
        ELSE 2
    END,
    "STAFF ROLE",
    "PERFORMANCE SCORE" DESC;
