use library_management;
SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employee;
SELECT * FROM issued_status;
SELECT * FROM members;
SELECT * FROM return_status;

-- Project task
-- 1. CRUD Operations


-- Task 1. Create a New Book Record
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
insert  books values('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
select count(*) from books;

-- Task 2: Update an Existing Member's Address
Update members
set member_address = "125 Oak St"
where member_id = "C103";

-- Task 3: Delete a Record from the Issued Status Table
-- Objective: Delete the record with issued_id = 'IS104' from the issued_status table.
Delete from issued_status
where issued_id = "IS104";

Select * from issued_status
where issued_id = "IS104";

-- Task 4: Retrieve All Books Issued by a Specific Employee
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
Select * from issued_status
where issued_emp_id = 'E101';


-- Task 5: List Members Who Have Issued More Than One Book
-- Objective: Use GROUP BY to find members who have issued more than one book.
select issued_emp_id,
count(issued_id) as total_book_issued
from issued_status
group by issued_emp_id
having count(issued_id)>1;

-- 2. CTAS (Create Table As Select)
-- Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt
create table book_count
as
select b.isbn,
       b.book_title,
       count(ist.issued_id) as no_issued
from books as b
join
issued_status as ist
on ist.issued_book_isbn = b.isbn
group by b.isbn,b.book_title;
select * from book_count;

-- ### 4. Data Analysis & Findings

-- Task 7. **Retrieve All Books in a Specific Category:
select * from books
where category = "classic";

-- Task 8: Find Total Rental Income by each Category:
select b.category,
       sum(b.rental_price) as total_rental_prize
from books as b
join
issued_status as ist
on ist.issued_book_isbn = b.isbn
group by b.category;

-- Task 9. **List Members Who Registered in the Last 180 Days**:
select * from members
where reg_date >= current_date - interval 180 day;

-- Task 10: List Employees with Their Branch Manager's Name and their branch details**:
select emp.emp_id,
	   emp.emp_name,
       bch.branch_id,
       emp.position_on,
       emp.salary,
       emp2.emp_name as manager_name
from employee as emp
join 
branch as bch
on emp.branch_id = bch.branch_id
join
employee as emp2
on bch.manager_id = emp2.emp_id;

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold
create table high_priced_books
as
select * from books
where rental_price >=4;
select * from high_priced_books;

-- Task 12: Retrieve the List of Books Not Yet Returned
select 
    distinct A.issued_book_name,
    count(A.issued_book_name)
    from issued_status 
as A
left join
return_status as B
on A.issued_id = B.issued_id
where B.return_id is null
group by A.issued_book_name;