--1. View of All Branches and Their Managers
CREATE VIEW BranchManagers AS
SELECT b.branch_id, b.address, b.contact_number, s.first_name || ' ' || s.last_name AS manager_name
FROM cm_branch b
JOIN cm_staff s ON b.manager_id = s.staff_id;

--2. View of Menu Prices
CREATE VIEW MenuPrices AS
SELECT item_id, item_name, price
FROM cm_menu;

--3. View of Job Roles and Salaries
CREATE VIEW JobSalaries AS
SELECT job_id, job_title, salary_per_hour, fixed_salary
FROM cm_job;

--4. View of Staff Details
CREATE VIEW StaffDetails AS
SELECT staff_id, first_name, last_name, date_of_birth, contact_number, hometown, job_id, branch_id, hire_date, work_hour, status
FROM cm_staff;

--5. View of Customer Details
CREATE VIEW CustomerDetails AS
SELECT customer_id, customer_name, address, contact_number, gender
FROM cm_customer;

--6. View of Order Summaries
CREATE VIEW OrderSummaries AS
SELECT o.order_id, o.customer_id, c.customer_name, o.date_order, o.status, SUM(oi.quantity * oi.price) 
AS total_order_value
FROM cm_order o
JOIN cm_order_item oi ON o.order_id = oi.order_id
JOIN cm_customer c ON o.customer_id = c.customer_id
GROUP BY o.order_id, o.customer_id, c.customer_name, o.date_order, o.status;

--7. View of Total Sales Per Item
CREATE VIEW TotalSalesPerItem AS
SELECT item_id, SUM(quantity) AS total_quantity_sold
FROM cm_order_item
GROUP BY item_id;

--8. View of Daily Sales
CREATE VIEW DailySales AS
SELECT DATE(date_order) as order_date, SUM(quantity * price) AS total_sales
FROM cm_order
JOIN cm_order_item ON cm_order.order_id = cm_order_item.order_id
GROUP BY DATE(date_order);

--9. View of Staff Per Branch
CREATE VIEW StaffPerBranch AS
SELECT branch_id, COUNT(staff_id) AS number_of_staff
FROM cm_staff
GROUP BY branch_id;

--10. View of Items Never Ordered
CREATE VIEW NeverOrderedItems AS
SELECT item_id, item_name
FROM cm_menu
WHERE item_id NOT IN (SELECT DISTINCT item_id FROM cm_order_item);

--11. View of Active Customers
CREATE VIEW ActiveCustomers AS
SELECT c.customer_id, c.customer_name, COUNT(o.order_id) AS number_of_orders
FROM cm_customer c
JOIN cm_order o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name;


--12. View of Staff Full-time and Part-time
CREATE VIEW StaffWorkStatus AS
SELECT staff_id, first_name, last_name, status
FROM cm_staff
WHERE status = 'full time' OR status = 'part time';

--13. View of Most Recent Orders
CREATE VIEW RecentOrders AS
SELECT order_id, date_order, status
FROM cm_order
WHERE date_order > CURRENT_DATE - INTERVAL '30 days';

--14. View of Average Distance for Online Orders
CREATE VIEW AverageDistanceOnline AS
SELECT AVG(distance) AS avg_distance
FROM cm_order
WHERE status = 'Online';

--15. View of Customer Order History
CREATE VIEW CustomerOrderHistory AS
SELECT c.customer_id, c.customer_name, o.order_id, o.date_order, o.status
FROM cm_customer c
JOIN cm_order o ON c.customer_id = o.customer_id
ORDER BY c.customer_id, o.date_order DESC;


