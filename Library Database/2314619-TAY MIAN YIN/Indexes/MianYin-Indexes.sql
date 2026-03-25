-- Index 1: For Detailed Attendance Report by Shift Date
CREATE INDEX idx_shiftdate ON ShiftSchedules(TRUNC(shiftDate));

-- Index 2: For Late Attendance Report
CREATE INDEX idx_sa_status_sched ON StaffAttendance(attendanceStatus, scheduleId);