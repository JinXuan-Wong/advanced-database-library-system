-- SETUP SQLPLUS ENVIRONMENT
SET LINESIZE 200
SET PAGESIZE 50
SET WRAP OFF
SET TRIMSPOOL ON

-- ASK USER TO ENTER VALUE FOR TOP N
ACCEPT n NUMBER PROMPT 'Enter the number of top popular books to display: '

-- FORMAT OUTPUT FOR SQLPLUS
COLUMN "RANK"     FORMAT 99
COLUMN "TITLE"    FORMAT A45   
COLUMN "AUTHOR"   FORMAT A25   
COLUMN "GENRE"    FORMAT A15  
COLUMN "YEAR"     FORMAT 9999
COLUMN "TIMES BORROWED" FORMAT 9999
COLUMN "PRICE ($)" FORMAT 99990.00 
COLUMN "POPULARITY RATING" FORMAT 9.0

-- HEADER
PROMPT
PROMPT ========================================= TOP BORROWED BOOKS REPORT =========================================
PROMPT

-- QUERY
WITH RankedBooks AS (
    SELECT 
        RANK() OVER (ORDER BY bbv.total_borrows DESC) AS "RANK",    
        bt.title                            AS "TITLE",         
        bt.author                           AS "AUTHOR",    
        bt.genre                            AS "GENRE",     
        bt.publicationYear                  AS "YEAR",    
        bbv.total_borrows                   AS "TIMES BORROWED",  
        bt.price                             AS "PRICE ($)",
        bt.popularity AS "POPULARITY RATING"
    FROM 
        BookBorrow_View bbv   
    JOIN 
        BookTitles bt ON bbv.bookId = bt.bookId  
    JOIN 
        BookCopies bc ON bt.bookId = bc.bookId  
    JOIN 
        BorrowedBooks bb ON bc.copyId = bb.copyId 
    GROUP BY 
        bt.title, bt.author, bt.genre, bt.publicationYear, bt.price, bbv.total_borrows, bt.popularity
)
SELECT * FROM RankedBooks
WHERE RANK <= &n
ORDER BY "RANK"; 
