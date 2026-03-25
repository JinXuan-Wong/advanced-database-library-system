CREATE OR REPLACE VIEW staff_basic_view AS
SELECT 
    s.staffId,
    s.staffName,
    COUNT(DISTINCT ss.scheduleId) AS shiftsWorked
FROM 
    Staff s
LEFT JOIN 
    ShiftSchedules ss ON ss.staffId = s.staffId
GROUP BY 
    s.staffId, s.staffName
HAVING 
    COUNT(DISTINCT ss.scheduleId) > 10;

-- SELECT * FROM staff_basic_view;