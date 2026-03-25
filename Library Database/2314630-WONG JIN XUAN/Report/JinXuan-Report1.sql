SET SERVEROUTPUT ON;
SET PAGESIZE 1000;
SET LINESIZE 300;

CREATE OR REPLACE PROCEDURE rpt_genre_author_report(p_genre IN VARCHAR2)
IS
    -- Custom exception for invalid genre
    ex_invalid_genre EXCEPTION;

    -- Validation variable
    v_genre_exists NUMBER;

    -- Cursors
    CURSOR cur_authors IS
        SELECT bt.author, COUNT(bb.borrowId) AS borrow_count
        FROM BookTitles bt
        JOIN BookCopies bc ON bt.bookId = bc.bookId
        JOIN BorrowedBooks bb ON bb.copyId = bc.copyId
        WHERE LOWER(bt.genre) = LOWER(p_genre)
        GROUP BY bt.author
        ORDER BY borrow_count DESC;

    CURSOR cur_books(p_author VARCHAR2) IS
        SELECT bt.title, bt.publicationYear, bt.popularity, bt.price, COUNT(bb.borrowId) AS borrow_count
        FROM BookTitles bt
        JOIN BookCopies bc ON bt.bookId = bc.bookId
        JOIN BorrowedBooks bb ON bb.copyId = bc.copyId
        WHERE LOWER(bt.genre) = LOWER(p_genre)
          AND bt.author = p_author
        GROUP BY bt.title, bt.publicationYear, bt.popularity, bt.price
        ORDER BY borrow_count DESC;

    v_top_title BookTitles.title%TYPE;
    v_top_borrows NUMBER;
    v_avg_popularity NUMBER;
    v_total_books NUMBER;
    v_top_author BookTitles.author%TYPE;
    v_top_author_books NUMBER;
    v_total_value NUMBER(10,2);
BEGIN

    SELECT COUNT(*) INTO v_genre_exists
    FROM BookTitles
    WHERE LOWER(genre) = LOWER(p_genre);

    IF v_genre_exists = 0 THEN
        RAISE ex_invalid_genre;
    END IF;

    DBMS_OUTPUT.PUT_LINE(RPAD('=', 100, '='));
    DBMS_OUTPUT.PUT_LINE(RPAD('||', 100));
    DBMS_OUTPUT.PUT_LINE(RPAD('||', 5) || RPAD('Genre Report: ' || UPPER(p_genre), 92) || '||');
    DBMS_OUTPUT.PUT_LINE(RPAD('||', 5) ||
                    RPAD('Generated On: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'), 92) || '||');
    DBMS_OUTPUT.PUT_LINE(RPAD('||', 100));
    DBMS_OUTPUT.PUT_LINE(RPAD('=', 100, '='));

    FOR author_rec IN cur_authors LOOP
        DBMS_OUTPUT.PUT_LINE('Author:  ' || author_rec.author);
        DBMS_OUTPUT.PUT_LINE('Total Borrow Count: ' || author_rec.borrow_count);
        DBMS_OUTPUT.PUT_LINE(RPAD('-', 100, '-'));

        DBMS_OUTPUT.PUT_LINE(RPAD('No.', 5) ||
                             RPAD('Title', 45) ||
                             RPAD('Year', 8) ||
                             RPAD('Popularity', 12) ||
                             RPAD('Price (RM)', 12) ||
                             'Borrows');
        DBMS_OUTPUT.PUT_LINE(RPAD('-', 100, '-'));

        DECLARE
            book_num NUMBER := 0;
        BEGIN
            FOR book_rec IN cur_books(author_rec.author) LOOP
                book_num := book_num + 1;
                DBMS_OUTPUT.PUT_LINE(RPAD(book_num, 5) ||
                                     RPAD(book_rec.title, 45) ||
                                     RPAD(book_rec.publicationYear, 8) ||
                                     RPAD(TO_CHAR(book_rec.popularity, '9.9'), 12) ||
                                     RPAD(TO_CHAR(book_rec.price, '9990.00'), 12) ||
                                     book_rec.borrow_count);
            END LOOP;
        END;

        DBMS_OUTPUT.PUT_LINE(CHR(10));
    END LOOP;

    -- Most Borrowed Book
    SELECT title, times_borrowed INTO v_top_title, v_top_borrows
    FROM (
        SELECT bt.title, COUNT(bb.borrowId) AS times_borrowed
        FROM BookTitles bt
        JOIN BookCopies bc ON bt.bookId = bc.bookId
        JOIN BorrowedBooks bb ON bb.copyId = bc.copyId
        WHERE LOWER(bt.genre) = LOWER(p_genre)
        GROUP BY bt.title
        ORDER BY times_borrowed DESC
    )
    WHERE ROWNUM = 1;

    -- Average Popularity
    SELECT ROUND(AVG(popularity), 2)
    INTO v_avg_popularity
    FROM BookTitles
    WHERE LOWER(genre) = LOWER(p_genre);

    -- Total Books in Genre
    SELECT COUNT(*) INTO v_total_books
    FROM BookTitles
    WHERE LOWER(genre) = LOWER(p_genre);

    -- Top Author by Book Count
    SELECT author, book_count INTO v_top_author, v_top_author_books
    FROM (
        SELECT author, COUNT(*) AS book_count
        FROM BookTitles
        WHERE LOWER(genre) = LOWER(p_genre)
        GROUP BY author
        ORDER BY book_count DESC
    )
    WHERE ROWNUM = 1;

    -- Total Book Value
    SELECT SUM(price) INTO v_total_value
    FROM BookTitles
    WHERE LOWER(genre) = LOWER(p_genre);

    -- Final Summary
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 100, '-'));
    DBMS_OUTPUT.PUT_LINE(RPAD('||', 100)); 

    DBMS_OUTPUT.PUT_LINE(RPAD('||', 10) || RPAD('**************** Additional Stats ****************', 88) || '||');
    DBMS_OUTPUT.PUT_LINE(RPAD('||', 10) || RPAD('Most Borrowed Book : ' || v_top_title || ' (' || v_top_borrows || ' times)', 88) || '||');
    DBMS_OUTPUT.PUT_LINE(RPAD('||', 10) || RPAD('Average Popularity : ' || TO_CHAR(v_avg_popularity, '9.99'), 88) || '||');
    DBMS_OUTPUT.PUT_LINE(RPAD('||', 10) || RPAD('Total Books in Genre : ' || v_total_books, 88) || '||');
    DBMS_OUTPUT.PUT_LINE(RPAD('||', 10) || RPAD('Top Author by Book Count : ' || v_top_author || ' (' || v_top_author_books || ' books)', 88) || '||');
    DBMS_OUTPUT.PUT_LINE(RPAD('||', 10) || RPAD('Total Book Value in Genre : RM ' || TO_CHAR(v_total_value, '9999990.00'), 88) || '||');

    DBMS_OUTPUT.PUT_LINE(RPAD('||', 100));  
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 100, '-'));

    EXCEPTION
    WHEN ex_invalid_genre THEN
        DBMS_OUTPUT.PUT_LINE('Error: Genre "' || UPPER(p_genre) || '" does not exist in the database.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An unexpected error occurred: ' || SQLERRM);
END;
/

CREATE OR REPLACE PROCEDURE rpt_genre_ranking
IS
    CURSOR cur_genres IS
        SELECT LOWER(bt.genre) AS genre,
               COUNT(bb.borrowId) AS total_borrows
        FROM BookTitles bt
        JOIN BookCopies bc ON bt.bookId = bc.bookId
        JOIN BorrowedBooks bb ON bb.copyId = bc.copyId
        WHERE bt.genre IS NOT NULL
        GROUP BY LOWER(bt.genre)
        ORDER BY total_borrows DESC;
    
    genre_num NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE(RPAD('=', 100, '='));
    DBMS_OUTPUT.PUT_LINE(RPAD('||', 100));
    DBMS_OUTPUT.PUT_LINE(RPAD('||', 5) || RPAD('Genre Ranking Summary', 92) || '||');
    DBMS_OUTPUT.PUT_LINE(RPAD('||', 5) || RPAD('Generated On: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'), 92) || '||');
    DBMS_OUTPUT.PUT_LINE(RPAD('||', 100));
    DBMS_OUTPUT.PUT_LINE(RPAD('=', 100, '='));

    DBMS_OUTPUT.PUT_LINE(RPAD('No.', 5) || RPAD('Genre', 40) || 'Total Borrows');
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 100, '-'));

    FOR genre_rec IN cur_genres LOOP
        genre_num := genre_num + 1;
        DBMS_OUTPUT.PUT_LINE(RPAD(genre_num, 5) ||
                             RPAD(INITCAP(genre_rec.genre), 40) ||
                             genre_rec.total_borrows);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE(RPAD('-', 100, '-'));
END;
/

SET SERVEROUTPUT ON;

EXEC rpt_genre_ranking;

-- Prompt the user for input
ACCEPT v_genre CHAR PROMPT 'Enter a genre to view author-level details: ';

-- Execute the procedure
EXEC rpt_genre_author_report('&v_genre');
