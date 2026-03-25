-- For faster filtering/grouping by month
CREATE INDEX idx_borrow_month ON BorrowedBooks (TO_CHAR(borrowDate, 'MON-YYYY'));

-- For report sorting and ranking
CREATE INDEX idx_borrow_member_book ON BorrowedBooks (memberId, borrowDate)