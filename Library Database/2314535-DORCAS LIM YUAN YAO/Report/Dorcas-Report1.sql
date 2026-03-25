SET SERVEROUTPUT ON;
SET PAGESIZE 1000;
SET LINESIZE 300;

CREATE OR REPLACE PROCEDURE rpt_reservation_by_statusmonth(
    p_status IN VARCHAR2,
    p_month IN VARCHAR2
)
IS
    CURSOR cur_reservations IS
        SELECT r.reservationId, r.memberId, r.copyId, r.reservationDate
        FROM Reservation r
        WHERE LOWER(TRIM(r.reservationStatus)) = LOWER(TRIM(p_status))
          AND TO_CHAR(r.reservationDate, 'MM') = LPAD(p_month, 2, '0')
        ORDER BY r.reservationDate;

    CURSOR cur_reservation_details(p_memberId VARCHAR2, p_copyId VARCHAR2) IS
        SELECT m.memberName, bt.title, bt.genre
        FROM Members m
        JOIN BookCopies bc ON bc.copyId = p_copyId
        JOIN BookTitles bt ON bt.bookId = bc.bookId
        WHERE m.memberId = p_memberId;

    v_row_num NUMBER := 0;
    v_total_reservations NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE(RPAD('=', 130, '='));
    DBMS_OUTPUT.PUT_LINE('||       Reservation Report - Status: ' || UPPER(p_status) ||
                         ' | Month: ' || TO_CHAR(TO_DATE(p_month, 'MM'), 'Month') ||
                         RPAD(' ', 70 - LENGTH(p_status)) || '||');
    DBMS_OUTPUT.PUT_LINE('||       Generated On: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') || RPAD(' ', 84) || '||');
    DBMS_OUTPUT.PUT_LINE(RPAD('=', 130, '='));
    
    DBMS_OUTPUT.PUT_LINE(
        RPAD('No.', 5) ||
        RPAD('Reservation ID', 18) ||
        RPAD('Member ID', 12) ||
        RPAD('Member Name', 25) ||
        RPAD('Book Title', 35) ||
        RPAD('Genre', 20) ||
        RPAD('Reservation Date', 25)
    );
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 130, '-'));

    FOR res IN cur_reservations LOOP
        v_row_num := v_row_num + 1;
        v_total_reservations := v_total_reservations + 1;

        FOR detail IN cur_reservation_details(res.memberId, res.copyId) LOOP
            DBMS_OUTPUT.PUT_LINE(
                RPAD(v_row_num, 5) ||
                RPAD(res.reservationId, 18) ||
                RPAD(res.memberId, 12) ||
                RPAD(detail.memberName, 25) ||
                RPAD(SUBSTR(detail.title, 1, 34), 35) ||
                RPAD(detail.genre, 20) ||
                RPAD(TO_CHAR(res.reservationDate, 'DD-MON-YYYY'), 25)
            );
        END LOOP;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE(RPAD('-', 130, '-'));

    IF v_total_reservations > 0 THEN
        DBMS_OUTPUT.PUT_LINE('||  Total Reservations Found: ' || v_total_reservations || 
                             RPAD(' ', 94 - LENGTH(TO_CHAR(v_total_reservations))) || '||');
    ELSE
        DBMS_OUTPUT.PUT_LINE('||  No reservations found for the given status and month.' || RPAD(' ', 70) || '||');
    END IF;

    DBMS_OUTPUT.PUT_LINE(RPAD('=', 130, '='));
END;
/

BEGIN
    rpt_reservation_by_statusmonth('Pending', '03');
END;
/
