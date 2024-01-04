-- getShipfee
CREATE FUNCTION GETSHIPFEE(in ORDER_ID VARCHAR(4)) 
RETURNS INTEGER 
AS $$  
BEGIN
SELECT distance*5000 FROM cm_order 
WHERE order_id = cm_order.order_id ;
END;
$$ LANGUAGE PLPGSQL;

--getPayhmentByOd
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

--get daily income function
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
/* Top n m�n ???c y�u th�ch nh?t
select * from get_favourite_item(10);
*/

--calculate the salary
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
/* L??ng c?a nh�n vi�n c� ID l� 1023
select get_salary(1023);
*/

--suggestItem
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

