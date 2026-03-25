CREATE OR REPLACE VIEW BookBorrow_view AS
SELECT 
    bt.bookId,                  
    bt.title,                              
    bt.author,                            
    bt.genre,                              
    bt.publicationYear,                    
    COUNT(bb.borrowId) AS total_borrows,   
    bt.price                              
FROM 
    BookTitles bt
JOIN 
    BookCopies bc ON bt.bookId = bc.bookId   -- Join with BookCopies to get the copies of books
JOIN 
    BorrowedBooks bb ON bc.copyId = bb.copyId -- Join with BorrowedBooks to count borrows
GROUP BY 
    bt.bookId, bt.title, bt.author, bt.genre, bt.publicationYear, bt.price;


-- SELECT * FROM BookBorrow_View；
