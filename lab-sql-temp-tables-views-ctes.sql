-- Creating a Customer Summary Report

-- In this exercise, you will create a customer summary report that summarizes key information about customers in the Sakila database,
-- including their rental history and payment details. The report will be generated using a combination of views, CTEs, and temporary tables.

-- Step 1: Create a View
-- First, create a view that summarizes rental information for each customer.
-- The view should include the customer's ID, name, email address, and total number of rentals (rental_count).

drop view if exists rental_info;
 
create view rental_info as
(select cu.customer_id, cu.first_name, cu.last_name, cu.email, count(r.rental_id) as rental_count
from customer as cu
left join rental as r on cu.customer_id = r.customer_id
group by cu.customer_id,  cu.first_name, cu.last_name, cu.email
)
;

select *
from rental_info;

-- Step 2: Create a Temporary Table
-- Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid).
-- The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.
drop temporary table if exists total_paid;

create temporary table total_paid as
(select vi.customer_id, sum(amount) as total_paid
from rental_info as vi
left join payment as p on vi.customer_id = p.customer_id
group by vi.customer_id
)
;

select *
from total_paid;

-- Step 3: Create a CTE and the Customer Summary Report
-- Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2.
-- The CTE should include the customer's name, email address, rental count, and total amount paid.
with cte_report as
(select concat(vi.first_name, '  ',  vi.last_name) as customer_name, vi.email as email_address, vi.rental_count as rental_count, temp.total_paid as total_paid
from rental_info as vi
left join total_paid as temp on vi.customer_id = temp.customer_id
)
select customer_name, email_address, rental_count, total_paid, round((total_paid/rental_count),2) as average_payment_per_rental
from cte_report
order by average_payment_per_rental
desc
;

-- Next, using the CTE, create the query to generate the final customer summary report,
-- which should include: customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.
