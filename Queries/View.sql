--1. View of All Branches and Their Managers
CREATE OR REPLACE VIEW BranchManagers AS
SELECT b.branch_id, b.address, b.contact_number, s.first_name || ' ' || s.last_name AS manager_name
FROM cm_branch b
JOIN cm_staff s ON b.manager_id = s.staff_id;
--test
--select * from BranchManagers;
--2. View of Menu Prices
CREATE OR REPLACE VIEW MenuPrices AS
SELECT item_id, item_name, price
FROM cm_menu;
--test
--select * from MenuPrices;
--3. View of Job Roles and Salaries
CREATE OR REPLACE VIEW JobSalaries AS
SELECT job_id, job_title, salary_per_hour, fixed_salary
FROM cm_job;

--4. View of Staff Details
CREATE OR REPLACE VIEW StaffDetails AS
SELECT staff_id, first_name, last_name, date_of_birth, contact_number, hometown, job_id, branch_id, hire_date, work_hour, status
FROM cm_staff;
--test
--select * from StaffDetails;
--5. View of Customer Details
CREATE OR REPLACE VIEW CustomerDetails AS
SELECT customer_id, customer_name, address, contact_number, gender
FROM cm_customer;
--test
--select * from CustomerDetails;
--6. View of Order Summaries
CREATE OR REPLACE VIEW OrderSummaries AS
SELECT o.order_id, o.customer_id, c.customer_name, o.date_order, o.status, SUM(oi.quantity * oi.price) 
AS total_order_value
FROM cm_order o
JOIN cm_order_item oi ON o.order_id = oi.order_id
JOIN cm_customer c ON o.customer_id = c.customer_id
GROUP BY o.order_id, o.customer_id, c.customer_name, o.date_order, o.status;
--test
--select * from OrderSummaries;
--7. View of Total Sales Per Item
CREATE OR REPLACE VIEW TotalSalesPerItem AS
SELECT item_id, SUM(quantity) AS total_quantity_sold
FROM cm_order_item
GROUP BY item_id;
--test
--select * from TotalSalesPerItem;
--8. View of Daily Sales
CREATE OR REPLACE VIEW DailySales AS
SELECT DATE(date_order) as order_date, SUM(quantity * price) AS total_sales
FROM cm_order
JOIN cm_order_item ON cm_order.order_id = cm_order_item.order_id
GROUP BY DATE(date_order);
--test
--select * from DailySales;
--9. View of Staff Per Branch
CREATE OR REPLACE VIEW StaffPerBranch AS
SELECT branch_id, COUNT(staff_id) AS number_of_staff
FROM cm_staff
GROUP BY branch_id;
--test
--select * from StaffPerBranch;
--10. View of Items Never Ordered
CREATE OR REPLACE VIEW NeverOrderedItems AS
SELECT item_id, item_name
FROM cm_menu
WHERE item_id NOT IN (SELECT DISTINCT item_id FROM cm_order_item);
--test 
--select * from NeverOrderedItems;
--11. View of Active Customers
CREATE OR REPLACE VIEW ActiveCustomers AS
SELECT c.customer_id, c.customer_name, COUNT(o.order_id) AS number_of_orders
FROM cm_customer c
JOIN cm_order o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name;
--test
--select * from ActiveCustomers;

--12. View of Staff Full-time and Part-time
CREATE OR REPLACE VIEW StaffWorkStatus AS
SELECT staff_id, first_name, last_name, status
FROM cm_staff
WHERE status = 'full time' OR status = 'part time';
--test
--select * from StaffWorkStatus;
--13. View of Most Recent Orders
CREATE OR REPLACE VIEW RecentOrders AS
SELECT order_id, date_order, status
FROM cm_order
WHERE date_order > CURRENT_DATE - INTERVAL '30 days';
--test
--select * from RecentOrders;
--14. View of Average Distance for Online Orders
CREATE OR REPLACE VIEW AverageDistanceOnline AS
SELECT AVG(distance) AS avg_distance
FROM cm_order
WHERE status = 'Online';
--test
--select * from AverageDistanceOnline;
--15. View of Customer Order History
CREATE OR REPLACE VIEW CustomerOrderHistory AS
SELECT c.customer_id, c.customer_name, o.order_id, o.date_order, o.status
FROM cm_customer c
JOIN cm_order o ON c.customer_id = o.customer_id
ORDER BY c.customer_id, o.date_order DESC;
--test
--select * from CustomerOrderHistory;


