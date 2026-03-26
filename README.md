# Library Management System (Oracle SQL)

An Oracle SQL based Library Management System developed for an Advanced Database Management assignment.

## Overview

This project is a database-driven online library management system designed to support core library operations such as membership registration, borrowing and returning books, reservations, fine processing, payments, staff shift scheduling, attendance tracking, and reporting.

The system was developed with a strong focus on relational database design, integrity constraints, database automation, and decision-support reporting.

## Features

- Entity Relationship Diagram (ERD) design in 3NF
- Data Definition Language (DDL) for all core tables
- Sample data records
- Multi-table SQL queries for decision making
- Stored procedures for operational workflows
- Triggers to enforce business rules
- Reports using cursors and formatted output
- Views for simplified analytics
- Indexes for query optimization
- User-defined functions
- Sequences for ID generation
- Exception handling and output formatting

## Modules

### Core Modules
- Membership Registration
- Membership Validity Tracking
- Borrowing and Returning Process
- Book Reservation
- Due Date and Overdue Tracking
- Fine Processing
- Fine Invoice Handling
- Loan Extension
- Advanced Book Search

### Additional Module
- Staff Shift and Performance Tracking

## Technologies Used

- Oracle SQL
- PL/SQL
- SQL*Plus
- ERD / relational database modeling

## Project Structure

```text
2314630-WONG JIN XUAN/
├── Function/
├── Indexes/
├── Query/
├── Report/
├── Sequence/
├── StoredProcedure/
├── Triggers/
├── View/

CreateInsert.txt
ERD Diagram.drawio.pdf
```

## My Contribution

My section focuses on:

- Popular books ranking query
- Staff performance and efficiency query
- Stored procedure to retrieve member borrow history
- Stored procedure to add new book titles with copies
- Trigger for book detail validation
- Trigger set for automatic book status updates
- Genre borrowing analytics report
- Book availability and borrowing duration report
- Supporting views, indexes, functions, exceptions, and sequences

## Example Database Components

Queries
- Most Borrowed Books (Popular Books Ranking)
- Staff Performance and Efficiency Analysis


Stored Procedures
- Get Borrow History for a Member
- Add New Book Title with Copies


Triggers
- Manage Book Details Validation
- Automatic Book Status Update


Reports
- Most Popular Genres & Authors
- Book Status Analytics: Availability & Borrowing Duration

View
- BookBorrow_View for pre-aggregated book borrowing statistics
- staff_basic_view for staff shift summary and performance analysis

Indexes
- idx_genre_bookid for fast genre-based filtering and ranking
- idx_status_bookcopy for efficient book status and borrowing analysis

Function
- CalculateTotalHoursWorked for computing staff working hours
- CalculateLoanProcessed for tracking staff loan transactions

User-Defined Exceptions
- ISBN uniqueness validation
- Publication year, price, and popularity validation
- Invalid genre and copy count validation
- Duplicate book ID / ISBN handling

Sequence
- book_id_seq for generating unique book IDs
- copy_id_seq for generating unique copy IDs

## How to Use

1. Open Oracle SQL Developer or SQL*Plus.
2. Run the DDL and insert scripts to create the database
3. Execute the SQL scripts for queries, procedures, triggers, reports, views, indexes, functions, and sequences.
4. Test the outputs using the provided prompts and sample calls.

## Notes
This project was developed as part of an academic assignment for Advanced Database Management.

