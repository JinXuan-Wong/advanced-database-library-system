CREATE OR REPLACE PROCEDURE add_book_title_with_copies (
    p_title       IN BookTitles.title%TYPE,
    p_author      IN BookTitles.author%TYPE,
    p_genre       IN BookTitles.genre%TYPE,
    p_pub_year    IN BookTitles.publicationYear%TYPE,
    p_isbn        IN BookTitles.isbn%TYPE,
    p_price       IN BookTitles.price%TYPE,
    p_popularity  IN BookTitles.popularity%TYPE,
    p_num_copies  IN NUMBER
)
IS
    -- Exception for invalid number of copies
    ex_invalid_copy_count EXCEPTION;

    -- Exception if duplicate bookId or isbn exists
    ex_dup_val EXCEPTION;
    PRAGMA EXCEPTION_INIT(ex_dup_val, -1);

    -- Local Variables
    v_bookId VARCHAR2(4);
    v_copy_id VARCHAR2(4);
    v_copy_num NUMBER := 1;

BEGIN
     -- Validate number of copies
    IF p_num_copies <= 0 THEN
        RAISE ex_invalid_copy_count;
    END IF;

    -- Generate Book ID using book_id_seq sequence
    v_bookId := 'B' || LPAD(TO_CHAR(book_id_seq.NEXTVAL), 3, '0');

    -- Insert into BookTitles Table
    BEGIN
        INSERT INTO BookTitles (bookId, title, author, genre, publicationYear, isbn, price, popularity)
        VALUES (v_bookId, p_title, p_author, p_genre, p_pub_year, p_isbn, p_price, p_popularity);
    EXCEPTION
        WHEN ex_dup_val THEN
            DBMS_OUTPUT.PUT_LINE('Error: Book ID or ISBN already exists. Please use unique values.');
            RETURN;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || SQLERRM);
            RETURN;
    END;

    -- Insert BookCopies
    WHILE v_copy_num <= p_num_copies LOOP
        -- Construct copyId based on the sequence
        v_copy_id := 'C' || LPAD(TO_CHAR(copy_id_seq.NEXTVAL), 3, '0');  -- Use sequence to get the next copyId
        BEGIN
            INSERT INTO BookCopies (copyId, bookId, bookStatus)
            VALUES (v_copy_id, v_bookId, 'available');
            v_copy_num := v_copy_num + 1;
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Error adding BookCopy: ' || SQLERRM);
                RETURN;
        END;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Successfully added book "' || p_title || '" with ' || p_num_copies || ' copies.');

-- Handle invalid copy count exception
EXCEPTION
    WHEN ex_invalid_copy_count THEN
        DBMS_OUTPUT.PUT_LINE('Error: Number of copies must be greater than 0.');
END;
/

SET SERVEROUTPUT ON;

-- Prompt user for input (this can be simplified if needed)
ACCEPT p_title CHAR PROMPT 'Enter Book Title: '
ACCEPT p_author CHAR PROMPT 'Enter Book Author: '
ACCEPT p_genre CHAR PROMPT 'Enter Book Genre: '
ACCEPT p_pub_year CHAR PROMPT 'Enter Publication Year: '
ACCEPT p_isbn CHAR PROMPT 'Enter ISBN: '
ACCEPT p_price CHAR PROMPT 'Enter Price: '
ACCEPT p_popularity CHAR PROMPT 'Enter Popularity: '
ACCEPT p_num_copies CHAR PROMPT 'Enter Number of Copies: '

-- Call the procedure
BEGIN
    add_book_title_with_copies(
        p_title => '&p_title',
        p_author => '&p_author',
        p_genre => '&p_genre',
        p_pub_year => TO_NUMBER('&p_pub_year'),
        p_isbn => '&p_isbn',
        p_price => TO_NUMBER('&p_price'),
        p_popularity => TO_NUMBER('&p_popularity'),
        p_num_copies => TO_NUMBER('&p_num_copies')
    );
END;
/

/*
Sample demo
----------------------
Enter Book Title: Island Adventures
Enter Book Author: John Doe
Enter Book Genre: Adventure
Enter Publication Year: 2023
Enter ISBN: 1234567890
Enter Price: 19.99
Enter Popularity: 4.5
Enter Number of Copies: 5

NOTE: Remember to COMMIT; if really want to make changes (add)
*/