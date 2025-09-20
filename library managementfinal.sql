use library_management;
SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employee;
SELECT * FROM issued_status;
SELECT * FROM members;
SELECT * FROM return_status;


-- Task 13: Identify Members with Overdue Books
-- Write a query to identify members who have overdue books (assume a 30-day return period).
-- Display the member's_id, member's name, book title, issue date, and days overdue.
 
-- issued_status**members**books**return_status
-- filter books which is return
-- overdue > 30
select A.issued_member_id,
       B.member_name,
       C.book_title,
       A.issued_date,
       current_date - A.issued_date as over_dues 
from issued_status 
as A
inner join members 
as B 
on B.member_id = A.issued_member_id
inner join books  as C 
on C.isbn = A.issued_book_isbn
left join
return_status as D 
on D.issued_id = A.issued_id
where D.return_date is null;

-- Task 14: Update Book Status on Return
-- Write a query to update the status of books in the books table to "Yes" when they are returned
-- (based on entries in the return_status table).
-- store procedure
DELIMITER $$

CREATE PROCEDURE add_return_records (
    IN p_return_id INT,
    IN p_issued_id INT,
    IN p_book_quality VARCHAR(50)
)
BEGIN
    DECLARE v_isbn VARCHAR(50);
    DECLARE v_book_name VARCHAR(80);

    -- Insert into return_status
    INSERT INTO return_status (return_id, issued_id, return_date, book_quality)
    VALUES (p_return_id, p_issued_id, CURDATE(), p_book_quality);

    -- Get book details from issued_status + books
    SELECT i.issued_book_isbn, b.book_title
    INTO v_isbn, v_book_name
    FROM issued_status i
    JOIN books b ON i.issued_book_isbn = b.isbn
    WHERE i.issued_id = p_issued_id;

    -- Update book status to "Yes"
    UPDATE books
    SET status = 'Yes'
    WHERE isbn = v_isbn;

    -- Show a thank-you message (MySQL workaround: use SELECT instead of RAISE NOTICE)
    SELECT CONCAT('Thank you for returning the book: ', v_book_name) AS message;

END$$

DELIMITER ;

-- Task 15: Branch Performance Report
-- Create a query that generates a performance report for each branch,
-- showing the number of books issued,
-- the number of books returned, 
-- and the total revenue generated from book rentals.
create table 
branch_performance_report
as
select  
        b.branch_id,
        b.manager_id,
        count(ist.issued_id) as no_of_book_issued,
        count(rs.issued_id) as no_of_books_returned,
        sum(bk.rental_price) as total_revenue
from issued_status as ist
join 
employee as e
on e.emp_id = ist.issued_emp_id
join 
branch as b
on e.branch_id = b.branch_id
left join 
return_status as rs
on rs.issued_id = ist.issued_id
join 
books as bk
on ist.issued_book_isbn = bk.isbn
group by b.branch_id,b.manager_id;

select * from branch_performance_report;

-- Task 16: CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members
-- containing members who have issued at least one book in the last 18 months.
create table active_members
as
select * from members
where member_id in (select distinct 
         issued_member_id 
from issued_status
where issued_date> current_date - interval 18 month);
 
select * from active_members;

-- Task 17: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues.
-- Display the employee name, number of books processed, and their branch.
SELECT * FROM employee;
SELECT * FROM issued_status;
SELECT * FROM branch;

select e.emp_name,
        b.branch_id,
        b.manager_id,
		count(ist.issued_id) as no_of_books_processed
from issued_status as ist
join 
employee as e
on ist.issued_emp_id = e.emp_id
join 
branch as b
on e.branch_id = b.branch_id
group by e.emp_name,b.branch_id,b.manager_id
order by no_of_books_processed desc
limit 3;

-- Task 18: Identify Members Issuing High-Risk Books
-- Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. 
-- Display the member name, book title, and the number of times they've issued damaged books.
select 
    m.member_name,
    bk.book_title,
    count(ist.issued_id) as times_issued_damaged
from issued_status as ist
join members as m
  on m.member_id = ist.issued_member_id
join books as bk
  on bk.isbn = ist.issued_book_isbn
where bk.status_of = 'damaged'
group by m.member_name, bk.book_title
having count(ist.issued_id) > 2;

