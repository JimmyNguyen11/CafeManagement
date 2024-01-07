-- Create table
CREATE TABLE IF NOT EXISTS cm_branch (
    branch_id VARCHAR(4) NOT NULL PRIMARY KEY,
    address VARCHAR(60) NOT NULL,
    contact_number VARCHAR(12) NOT NULL,
    manager_id INTEGER NOT NULL
);
CREATE TABLE IF NOT EXISTS cm_menu (
    item_id VARCHAR(4) NOT NULL PRIMARY KEY,
    item_name VARCHAR(30) NOT NULL,
    price NUMERIC(6, 0) NOT NULL
);
CREATE TABLE IF NOT EXISTS cm_job 
(
    job_id VARCHAR(4) NOT NULL PRIMARY KEY,
    job_title VARCHAR(10) NOT NULL,
    salary_per_hour NUMERIC(8,0)  NULL,
    fixed_salary NUMERIC(8,0)  NULL
);

CREATE TABLE IF NOT EXISTS cm_staff 
(
    staff_id SERIAL PRIMARY KEY,
    job_id VARCHAR(4) NOT NULL, 
    first_name VARCHAR(20) NOT NULL,
    last_name VARCHAR(40) NOT NULL,
    date_of_birth DATE NOT NULL,
    contact_number VARCHAR(11) NOT NULL,
    hometown VARCHAR(20) NOT NULL,
    branch_id VARCHAR(4) NOT NULL,
    hire_date DATE NOT NULL,
    work_hour INTEGER DEFAULT 0, 
    status VARCHAR(10),

    CONSTRAINT staff_branch_branch_id 
        FOREIGN KEY (branch_id) REFERENCES cm_branch(branch_id),
    CONSTRAINT staff_job_job_id 
        FOREIGN KEY (job_id) REFERENCES cm_job(job_id),
    CHECK (status = 'part time' or status = 'full time' or status = 'inactive')
);                   

CREATE TABLE IF NOT EXISTS cm_customer
(
    customer_id SERIAL NOT NULL PRIMARY KEY,
    customer_name VARCHAR(40) NOT NULL,
    address VARCHAR(60),
    contact_number VARCHAR(11) NOT NULL,
    gender VARCHAR(8),
    CHECK (gender = 'female' OR gender = 'male')
);


CREATE TABLE IF NOT EXISTS cm_order 
(
    order_id VARCHAR (10) NOT NULL PRIMARY KEY, 
    staff_id INTEGER,
    distance NUMERIC(5,2),
    status VARCHAR(8),
    discount NUMERIC(9,0) DEFAULT 0,
    date_order DATE, 
    customer_id INTEGER ,
	CONSTRAINT order_customer_customer_id 
		FOREIGN KEY (customer_id) REFERENCES cm_customer(customer_id),
 	CONSTRAINT order_staff_staff_id 
		FOREIGN KEY (staff_id) REFERENCES cm_staff(staff_id),
    CHECK (status = 'Online' or status = 'Offline')
    
);

CREATE TABLE IF NOT EXISTS cm_order_item
(
    order_id VARCHAR (10) NOT NULL, 
    item_id VARCHAR (4) NOT NULL,
    quantity INTEGER NOT NULL,
    price NUMERIC(6, 0) NOT NULL,
    PRIMARY KEY (order_id, item_id),
    CONSTRAINT orditm_item_item_id
        FOREIGN KEY (item_id) REFERENCES cm_menu(item_id) ON DELETE CASCADE,
    CONSTRAINT orditm_order_order_id
        FOREIGN KEY (order_id) REFERENCES cm_order(order_id) ON DELETE CASCADE
);
--2. CREATE VIEW
--1. View of All Branches and Their Managers
CREATE OR REPLACE VIEW BranchManagers AS
SELECT b.branch_id, b.address, b.contact_number, s.first_name || ' ' || s.last_name AS manager_name
FROM cm_branch b
JOIN cm_staff s ON b.manager_id = s.staff_id;

--2. View of Menu Prices
CREATE OR REPLACE VIEW MenuPrices AS
SELECT item_id, item_name, price
FROM cm_menu;

--3. View of Job Roles and Salaries
CREATE OR REPLACE VIEW JobSalaries AS
SELECT job_id, job_title, salary_per_hour, fixed_salary
FROM cm_job;

--4. View of Staff Details
CREATE OR REPLACE VIEW StaffDetails AS
SELECT staff_id, first_name, last_name, date_of_birth, contact_number, hometown, job_id, branch_id, hire_date, work_hour, status
FROM cm_staff;

--5. View of Customer Details
CREATE OR REPLACE VIEW CustomerDetails AS
SELECT customer_id, customer_name, address, contact_number, gender
FROM cm_customer;

--6. View of Order Summaries
CREATE OR REPLACE VIEW OrderSummaries AS
SELECT o.order_id, o.customer_id, c.customer_name, o.date_order, o.status, SUM(oi.quantity * oi.price) 
AS total_order_value
FROM cm_order o
JOIN cm_order_item oi ON o.order_id = oi.order_id
JOIN cm_customer c ON o.customer_id = c.customer_id
GROUP BY o.order_id, o.customer_id, c.customer_name, o.date_order, o.status;

--7. View of Total Sales Per Item
CREATE OR REPLACE VIEW TotalSalesPerItem AS
SELECT item_id, SUM(quantity) AS total_quantity_sold
FROM cm_order_item
GROUP BY item_id;

--8. View of Daily Sales
CREATE OR REPLACE VIEW DailySales AS
SELECT DATE(date_order) as order_date, SUM(quantity * price) AS total_sales
FROM cm_order
JOIN cm_order_item ON cm_order.order_id = cm_order_item.order_id
GROUP BY DATE(date_order);

--9. View of Staff Per Branch
CREATE OR REPLACE VIEW StaffPerBranch AS
SELECT branch_id, COUNT(staff_id) AS number_of_staff
FROM cm_staff
GROUP BY branch_id;

--10. View of Items Never Ordered
CREATE OR REPLACE VIEW NeverOrderedItems AS
SELECT item_id, item_name
FROM cm_menu
WHERE item_id NOT IN (SELECT DISTINCT item_id FROM cm_order_item);

--11. View of Active Customers
CREATE OR REPLACE VIEW ActiveCustomers AS
SELECT c.customer_id, c.customer_name, COUNT(o.order_id) AS number_of_orders
FROM cm_customer c
JOIN cm_order o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name;


--12. View of Staff Full-time and Part-time
CREATE OR REPLACE VIEW StaffWorkStatus AS
SELECT staff_id, first_name, last_name, status
FROM cm_staff
WHERE status = 'full time' OR status = 'part time';

--13. View of Most Recent Orders
CREATE OR REPLACE VIEW RecentOrders AS
SELECT order_id, date_order, status
FROM cm_order
WHERE date_order > CURRENT_DATE - INTERVAL '30 days';

--14. View of Average Distance for Online Orders
CREATE OR REPLACE VIEW AverageDistanceOnline AS
SELECT AVG(distance) AS avg_distance
FROM cm_order
WHERE status = 'Online';

--15. View of Customer Order History
CREATE OR REPLACE VIEW CustomerOrderHistory AS
SELECT c.customer_id, c.customer_name, o.order_id, o.date_order, o.status
FROM cm_customer c
JOIN cm_order o ON c.customer_id = o.customer_id
ORDER BY c.customer_id, o.date_order DESC;

--3. FUNCTIONS
-- getShipfee
DROP FUNCTION IF EXISTS GETSHIPFEE;
CREATE OR REPLACE FUNCTION GETSHIPFEE(test_order_id VARCHAR(10)) 
RETURNS INTEGER 
AS $$  
DECLARE
    ship_fee INTEGER;
BEGIN
    SELECT distance * 5000 INTO ship_fee
    FROM cm_order 
    WHERE order_id = test_order_id;
    IF NOT FOUND THEN
        RETURN NULL;  
    END IF;

    RETURN ship_fee;
END;
$$ LANGUAGE PLPGSQL;
--test 
--select GETSHIPFEE('OD10') as ship_fee;
--select GETSHIPFEE('ko') as ship_fee;

--getPayhmentByOd
DROP FUNCTION IF EXISTS GETPAYMENT;
CREATE OR REPLACE FUNCTION GETPAYMENT(A VARCHAR(4))
RETURNS INTEGER AS $$
DECLARE
    total_price INTEGER;
    shipping_fee INTEGER;
    discount_rate REAL;
BEGIN
    -- Calculate the total price of all items in the order
    SELECT SUM(QUANTITY * PRICE) INTO total_price
    FROM CM_ORDER
    INNER JOIN CM_ORDERED_ITEM ON CM_ORDER.ORDER_ID = CM_ORDERED_ITEM.ORDER_ID
    WHERE CM_ORDER.ORDER_ID = A;

    -- Calculate the shipping fee
    SELECT GETSHIPFEE(A) INTO shipping_fee;

    -- Get the discount rate for the order
    SELECT (100 - DISCOUNT) / 100 INTO discount_rate
    FROM CM_ORDER
    WHERE ORDER_ID = A;

    -- Calculate the total payment
    RETURN (total_price + shipping_fee) * discount_rate;
END;
$$ LANGUAGE PLPGSQL;



--new GMEB
SELECT * FROM (SELECT *,
	RANK()
OVER(ORDER BY REV DESC) RN
FROM (
							(SELECT SUM(QUANTITY * PRICE + DISTANCE * 5000)
								FROM CM_BRANCH B
								JOIN CM_STAFF ST ON ST.BRANCH_ID = B.BRANCH_ID
								JOIN CM_ORDER OD ON OD.STAFF_ID = ST.STAFF_ID
								JOIN CM_ORDER_ITEM OI ON OI.ORDER_ID = OD.ORDER_ID
								GROUP BY B.BRANCH_ID) ) AS REV) t
WHERE RN = 1;

/*
* Moi lan chay function thi phai di qua het branch, moi lan di qua branch phai tim max 1 lan nua. 
* Dung order nhu nay thi chi di tim thu nhap cua tung branch roi sap xep. Vi vay cost cua function se giam di  
*/

--getMostEfficientBranch
DROP FUNCTION IF EXISTS getmostefficientbranch;
CREATE OR REPLACE FUNCTION getmostefficientbranch()
RETURNS VARCHAR(4) AS $$
DECLARE
    best_branch_id VARCHAR(4);
BEGIN
    -- Calculate the revenue for each branch and select the top one
    WITH RevenueCalc AS (
        SELECT B.BRANCH_ID,
               SUM(OI.QUANTITY * OI.PRICE + OD.DISTANCE * 5000) AS REV
        FROM CM_BRANCH B
        JOIN CM_STAFF ST ON ST.BRANCH_ID = B.BRANCH_ID
        JOIN CM_ORDER OD ON OD.STAFF_ID = ST.STAFF_ID
        JOIN CM_ORDER_ITEM OI ON OI.ORDER_ID = OD.ORDER_ID
        GROUP BY B.BRANCH_ID
    )
    SELECT BRANCH_ID INTO best_branch_id
    FROM RevenueCalc
    ORDER BY REV DESC
    LIMIT 1;

    RETURN best_branch_id;
END;
$$ LANGUAGE plpgsql;
--test
--select getmostefficientbranch() as ok;

--get daily income function
DROP FUNCTION IF EXISTS get_daily_income;
CREATE OR REPLACE FUNCTION get_daily_income(d DATE)
RETURNS TABLE(id VARCHAR(4), address VARCHAR(60), date DATE, income NUMERIC(11,0))
AS $$
BEGIN
    RETURN QUERY
    SELECT b.branch_id, b.address, o.date_order, SUM(oi.quantity * oi.price) AS income
    FROM cm_branch b
    JOIN cm_staff s ON b.branch_id = s.branch_id
    JOIN cm_order o ON s.staff_id = o.staff_id
    JOIN cm_order_item oi ON o.order_id = oi.order_id
    WHERE o.date_order = d
    GROUP BY b.branch_id, b.address, o.date_order
    ORDER BY o.date_order;
END;
$$ LANGUAGE plpgsql;

--get information of a bill
DROP FUNCTION IF EXISTS get_bill_from_order_id;
CREATE OR REPLACE FUNCTION get_bill_from_order_id(id VARCHAR(10))
RETURNS TABLE(
    staff_id INTEGER,
    customer_id INTEGER, 
    customer_name VARCHAR(40),
    date DATE, 
    distance NUMERIC(5,2), 
    discount NUMERIC(9,0),
    status VARCHAR(8), 
    item_id VARCHAR(4), 
    quantity INTEGER, 
    price NUMERIC(6,0)
)
 AS $$
BEGIN
    RETURN QUERY
    SELECT s.staff_id,
           c.customer_id, 
           c.customer_name, 
           o.date_order, 
           o.distance, 
           o.discount, 
           o.status, 
           oi.item_id, 
           oi.quantity, 
           oi.price
    FROM cm_order AS o
    JOIN cm_order_item AS oi ON o.order_id = oi.order_id
    JOIN cm_staff AS s ON s.staff_id = o.staff_id
    JOIN cm_branch AS b ON b.branch_id = s.branch_id
    JOIN cm_customer AS c ON c.customer_id = o.customer_id
    WHERE o.order_id = id
    ORDER BY o.order_id;
END;
$$ LANGUAGE plpgsql;

--get the loyal customer
DROP FUNCTION IF EXISTS get_loyal_customer;
CREATE OR REPLACE FUNCTION get_loyal_customer(p NUMERIC(10,0))
RETURNS TABLE(id INTEGER, name VARCHAR(40), pay NUMERIC(10,0))
 AS $$
BEGIN
    RETURN QUERY
    SELECT c.customer_id AS id, c.customer_name AS name, SUM(oi.quantity * oi.price) AS pay
    FROM cm_customer c
    JOIN cm_order o ON c.customer_id = o.customer_id
    JOIN cm_order_item oi ON o.order_id = oi.order_id
    JOIN cm_staff s ON s.staff_id = o.staff_id
    JOIN cm_branch b ON b.branch_id = s.branch_id
    GROUP BY c.customer_id, c.customer_name
    HAVING SUM(oi.quantity * oi.price) >= p
    ORDER BY pay DESC;
END;
$$ LANGUAGE plpgsql;

--find most/least favorited product
DROP FUNCTION IF EXISTS get_least_favourite_item;
CREATE OR REPLACE FUNCTION get_least_favourite_item()
RETURNS VARCHAR(4)
 AS $$
DECLARE
    least_favourite_id VARCHAR(4);
BEGIN
    SELECT cm_menu.item_id INTO least_favourite_id
    FROM cm_menu
    LEFT JOIN cm_order_item ON cm_menu.item_id = cm_order_item.item_id
    GROUP BY cm_menu.item_id
    ORDER BY COALESCE(SUM(cm_order_item.quantity), 0) ASC
    LIMIT 1;

    RETURN least_favourite_id;
END;
$$ LANGUAGE plpgsql;

/*
Top n m�n �t quan t�m
select * from get_least_favourite_item(10);
*/

--find n least favorited product
DROP FUNCTION IF EXISTS get_least_favourite_item;
CREATE OR REPLACE FUNCTION get_least_favourite_item(n INT)
RETURNS TABLE (name VARCHAR(30), quantity BIGINT)
 AS $$
BEGIN
    RETURN QUERY
    SELECT cm_menu.item_id AS name, COALESCE(SUM(cm_order_item.quantity), 0) AS quantity
    FROM cm_menu
    LEFT JOIN cm_order_item ON cm_menu.item_id = cm_order_item.item_id
    GROUP BY cm_menu.item_id
    ORDER BY quantity ASC
    LIMIT n;
END;
$$ LANGUAGE plpgsql;

--find n most favorited product
DROP FUNCTION IF EXISTS get_favourite_item;
CREATE OR REPLACE FUNCTION get_favourite_item(n INT)
RETURNS TABLE (name VARCHAR(30), quantity BIGINT)
 AS $$
BEGIN
    RETURN QUERY
    SELECT cm_menu.item_id AS name, COALESCE(SUM(cm_order_item.quantity), 0) AS quantity
    FROM cm_menu
    LEFT JOIN cm_order_item ON cm_menu.item_id = cm_order_item.item_id
    GROUP BY cm_menu.item_id
    ORDER BY quantity DESC
    LIMIT n;
END;
$$ LANGUAGE plpgsql;
--test
--select * from get_favourite_item(10);


--calculate the salary
DROP FUNCTION IF EXISTS get_salary;
CREATE OR REPLACE FUNCTION get_salary(sta_id INT)
RETURNS NUMERIC
AS $$
DECLARE
    salary NUMERIC;
BEGIN
    SELECT CASE
               WHEN s.status = 'full time' THEN j.fixed_salary
               WHEN s.status = 'part time' THEN j.salary_per_hour * s.work_hour
               ELSE 0
           END INTO salary
    FROM cm_staff s
    JOIN cm_job j ON s.job_id = j.job_id
    WHERE s.staff_id = sta_id;

    RETURN salary;
END;
$$ LANGUAGE plpgsql ;
--test
--select get_salary(1023);


--suggestItem
DROP FUNCTION IF EXISTS SUGGEST_ITEM;
CREATE OR REPLACE FUNCTION SUGGEST_ITEM(CUS_ID INT) 
RETURNS VARCHAR(4) 
 AS $$
DECLARE
    most_ordered VARCHAR(4);
BEGIN
    SELECT oi.item_id INTO most_ordered
    FROM cm_order o
    JOIN cm_ordered_item oi ON o.order_id = oi.order_id
    WHERE o.customer_id = CUS_ID
    GROUP BY oi.item_id
    ORDER BY SUM(oi.quantity) DESC
    LIMIT 1;

    RETURN most_ordered;
END;
$$ LANGUAGE PLPGSQL;

-- Insert branch
DROP FUNCTION IF EXISTS insert_branch_info;
CREATE OR REPLACE FUNCTION insert_branch_info(p_branch_id text, p_address text, p_contact_num text, p_manager_id int)
RETURNS void AS $$
BEGIN
    IF NOT EXISTS (SELECT branch_id FROM cm_branch WHERE branch_id = p_branch_id) THEN
        INSERT INTO cm_branch VALUES (p_branch_id, p_address, p_contact_num, p_manager_id);
        RAISE NOTICE 'Insert success';
    ELSE
        RAISE NOTICE 'Duplicate data';
    END IF;
END;
$$ LANGUAGE plpgsql;

--  Insert job
DROP FUNCTION IF EXISTS insert_job_info;
CREATE OR REPLACE FUNCTION insert_job_info(p_job_id text, p_job_title text, p_salary_per_hour numeric, p_fixed_salary numeric)
RETURNS void AS $$
BEGIN
    IF NOT EXISTS (SELECT job_id FROM cm_job WHERE job_id = p_job_id) THEN
        INSERT INTO cm_job VALUES (p_job_id, p_job_title, p_salary_per_hour, p_fixed_salary);
        RAISE NOTICE 'Insert success';
    ELSE
        RAISE NOTICE 'Duplicate data';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Insert menu
DROP FUNCTION IF EXISTS insert_menu_info;
CREATE OR REPLACE FUNCTION insert_menu_info(p_item_id text, p_item_name text, p_price numeric)
RETURNS void AS $$
BEGIN
    IF NOT EXISTS (SELECT item_id FROM cm_menu WHERE item_id = p_item_id) THEN
        INSERT INTO cm_menu VALUES (p_item_id, p_item_name, p_price);
        RAISE NOTICE 'Insert success';
    ELSE
        RAISE NOTICE 'Duplicate data';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Insert customer
DROP FUNCTION IF EXISTS insert_customer_info;
CREATE OR REPLACE FUNCTION insert_customer_info(p_customer_name text, p_address text, p_contact_num text, p_gender text)
RETURNS void AS $$
DECLARE
    p_id int;
BEGIN
    SELECT MAX(customer_id) INTO p_id FROM cm_customer; 
    IF NOT EXISTS (SELECT 1 FROM cm_customer WHERE customer_name = p_customer_name AND address = p_address) THEN
        INSERT INTO cm_customer VALUES (p_id + 1, p_customer_name, p_address, p_contact_num, LOWER(p_gender));
        RAISE NOTICE 'Insert success';
    ELSE
        RAISE NOTICE 'Duplicate data';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Insert staff
DROP FUNCTION IF EXISTS insert_staff_info;
CREATE OR REPLACE FUNCTION insert_staff_info(
    p_job_id text,
    p_first_name text,
    p_last_name text,
    p_date_of_birth date,
    p_contact_number text,
    p_hometown text,
    p_branch_id text,
    p_hire_date date,
    p_work_hour int,
    p_status text
)
RETURNS void AS $$
DECLARE
    p_id int;
BEGIN
    SELECT MAX(staff_id) INTO p_id FROM cm_staff; 

    IF NOT EXISTS (
        SELECT 1 
        FROM cm_staff 
        WHERE first_name = p_first_name 
          AND last_name = p_last_name 
          AND date_of_birth = p_date_of_birth 
          AND contact_number = p_contact_number
    ) THEN
        INSERT INTO cm_staff VALUES (
            p_id + 1,
            UPPER(p_job_id),
            p_first_name,
            p_last_name,
            p_date_of_birth,
            p_contact_number,
            p_hometown,
            UPPER(p_branch_id),
            p_hire_date,
            p_work_hour,
            LOWER(p_status)
        );
        RAISE NOTICE 'Insert success';
    ELSE
        RAISE NOTICE 'Duplicate data';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Insert order
DROP FUNCTION IF EXISTS insert_order_info;
CREATE OR REPLACE FUNCTION insert_order_info(
	p_order_id text,
    p_staff_id text,
    p_distance numeric,
    p_status text,
    p_discount numeric,
    p_date_order date,
    p_customer_id int
)
RETURNS void AS $$
BEGIN

    IF NOT EXISTS (
        SELECT 1 
        FROM cm_order
        WHERE order_id = p_order_id
    ) THEN
        INSERT INTO cm_order VALUES (
            p_order_id,
            p_staff_id,
            p_distance,
            p_status,
            p_discount,
            p_date_order,
            p_customer_id
        );
        RAISE NOTICE 'Insert success';
    ELSE
        RAISE NOTICE 'Duplicate data';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Insert order item
DROP FUNCTION IF EXISTS insert_order_item_info;
CREATE OR REPLACE FUNCTION insert_order_item_info(
    p_order_id text,
    p_item_id text,
    p_quantity int,
    p_price numeric
)
RETURNS void AS $$
BEGIN
    INSERT INTO cm_order_item VALUES (p_order_id, p_item_id, p_quantity, p_price);
    RAISE NOTICE 'Insert success';
END;
$$ LANGUAGE plpgsql;

-- Function to delete an order
CREATE OR REPLACE FUNCTION delete_order(order_id_to_delete VARCHAR(10))
RETURNS VOID AS
$$
BEGIN
    DELETE FROM cm_order
    WHERE order_id = order_id_to_delete;
END;
$$
LANGUAGE plpgsql;

-- Function to delete an order_item
CREATE OR REPLACE FUNCTION delete_order_item(order_id_to_delete VARCHAR(10), item_id_to_delete VARCHAR(4))
RETURNS VOID AS
$$
BEGIN
    DELETE FROM cm_order_item
    WHERE order_id = order_id_to_delete AND item_id = item_id_to_delete;
END;
$$
LANGUAGE plpgsql;

-- Funstion to set a staff to inactive
CREATE OR REPLACE FUNCTION set_staff_to_inactive(staff_id_to_inactive INT)
RETURNS VOID AS $$
BEGIN
    UPDATE cm_staff
    SET status = 'inactive'
    WHERE staff_id = staff_id_to_inactive;
END;
$$ LANGUAGE plpgsql;

--2. Trigger to prevent deleting a job associated with a existence staff
--trigger function
CREATE OR REPLACE FUNCTION prevent_delete_job()
RETURNS TRIGGER AS $$
DECLARE
    job_count INT;
BEGIN
    SELECT COUNT(*) INTO job_count FROM cm_staff WHERE job_id = OLD.job_id;

    IF job_count > 0 THEN
        RAISE EXCEPTION 'Cannot delete job record with job_id %; it is associated with existing staff members.', OLD.job_id;
    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Attach Trigger
CREATE TRIGGER trigger_prevent_delete_job
BEFORE DELETE ON cm_job
FOR EACH ROW EXECUTE FUNCTION prevent_delete_job();
--test

--3. Trigger validate new staff age
--trigger function
CREATE OR REPLACE FUNCTION validate_staff_age()
RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.date_of_birth > CURRENT_DATE - INTERVAL '18 years') THEN
        RAISE EXCEPTION 'Staff must be at least 18 years old.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--attach trigger
CREATE TRIGGER trigger_validate_staff_age
BEFORE INSERT ON cm_staff
FOR EACH ROW EXECUTE FUNCTION validate_staff_age();
--test

--4. trigger automatically set discount for returning customer
--trigger function
CREATE OR REPLACE FUNCTION apply_returning_discount()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.discount >= 0 AND EXISTS (
        SELECT 1
        FROM cm_order
        WHERE customer_id = NEW.customer_id 
		AND order_id <> NEW.order_id 
		AND date_order <> NEW.date_order
    ) THEN
        NEW.discount := COALESCE((SELECT MAX(discount) + 3 + NEW.discount FROM cm_order WHERE customer_id = NEW.customer_id), 3);
    END IF;
	IF NEW.discount >= 15 THEN
		NEW.discount := 15;
	END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Attach trigger
CREATE TRIGGER trigger_returning_customer_discount
BEFORE INSERT OR UPDATE ON cm_order
FOR EACH ROW EXECUTE FUNCTION apply_returning_discount();
--test

-- trigger 5 and 1 will be added later.
