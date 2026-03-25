-- NOTE: Implemented in stored procedure 
--      "add_book_title_with_copies" (JinXuan-StoredProcedure2.sql)
-------- Sequence 1: BookTitles bookID ---------
-- Latest Key Value: B150
CREATE SEQUENCE book_id_seq
    START WITH 151
    INCREMENT BY 1
    NOCACHE;

-------- Sequence 2: BookCopies copyID ---------
-- Latest Key Value: C350
CREATE SEQUENCE copy_id_seq
    START WITH 351
    INCREMENT BY 1
    NOCACHE;
