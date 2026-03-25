CREATE OR REPLACE PROCEDURE GetAllFinesByMember (
    p_memberId IN Members.memberId%TYPE
)
IS
    v_memberExists INT := 0;
    v_fineFound BOOLEAN := FALSE;
BEGIN
    -- Check if member exists
    BEGIN
        SELECT COUNT(*) INTO v_memberExists
        FROM Members
        WHERE memberId = p_memberId;

        IF v_memberExists = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Error: Member does not exist in the system.');
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20002, 'Error: Member not found.');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20099, 'Unexpected error during member validation: ' || SQLERRM);
    END;

    -- Loop through fine records
    FOR fine_rec IN (
        SELECT 
            f.fineId, 
            f.fineAmount, 
            f.fineStatus, 
            f.fineType, 
            NVL(TO_CHAR(p.paymentDate, 'YYYY-MM-DD'), 'Not Paid') AS paymentDate, 
            NVL(p.payAmount, 0.00) AS paidAmount
        FROM Fines f
        JOIN BorrowedBooks bb ON f.borrowId = bb.borrowId
        JOIN Members m ON bb.memberId = m.memberId
        LEFT JOIN Payments p ON f.paymentId = p.paymentId
        WHERE m.memberId = p_memberId
        ORDER BY f.fineDate DESC
    ) LOOP
        IF NOT v_fineFound THEN
            v_fineFound := TRUE;
            DBMS_OUTPUT.PUT_LINE(RPAD('-', 92, '-'));
            DBMS_OUTPUT.PUT_LINE(
                RPAD('Fine ID', 10) || RPAD('Amount(RM)', 15) || RPAD('Status', 12) ||
                RPAD('Type', 15) || RPAD('Payment Date', 20) || RPAD('Paid Amount(RM)', 20)
            );
            DBMS_OUTPUT.PUT_LINE(RPAD('-', 92, '-'));
        END IF;

        DBMS_OUTPUT.PUT_LINE(
            RPAD(fine_rec.fineId, 10) ||
            RPAD(TO_CHAR(fine_rec.fineAmount, '9990.99'), 15) ||
            RPAD(fine_rec.fineStatus, 12) ||
            RPAD(fine_rec.fineType, 15) ||
            RPAD(fine_rec.paymentDate, 20) ||
            RPAD(TO_CHAR(fine_rec.paidAmount, '9999.99'), 20)
        );
    END LOOP;

    IF NOT v_fineFound THEN
        DBMS_OUTPUT.PUT_LINE('No fines records found for the specified member.');
    ELSE
        DBMS_OUTPUT.PUT_LINE(RPAD('-', 92, '-'));
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || SQLERRM);
END;
/

SET SERVEROUTPUT ON;

-- Accept information from user
ACCEPT member_id CHAR PROMPT 'Enter Member ID: '

-- Running the procedure with the inputs
BEGIN
    GetAllFinesByMember(
	p_memberId => '&member_id'
    );
END;
/