-- Index 1: For genre reports 
-- (rpt_genre_author_report, rpt_genre_ranking)
CREATE INDEX idx_genre_bookid ON BookTitles(LOWER(genre), bookId);

-- Index 2: For book status report
-- (rpt_bookstat_borrowduration)
CREATE INDEX idx_status_bookcopy ON BookCopies(bookStatus, bookId, copyId);