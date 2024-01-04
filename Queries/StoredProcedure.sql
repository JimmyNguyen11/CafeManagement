
  CREATE PROCEDURE insert_branch
 (branch_id VARCHAR(4), address VARCHAR(60), contact_number VARCHAR(12), manager_id INTEGER)
 LANGUAGE SQL
 AS $$
 INSERT INTO cm_branch VALUES (branch_id, address, contact_number, manager_id);
 $$;

  CREATE PROCEDURE insert_job
 (job_id VARCHAR(4), job_title VARCHAR(10), salary_per_hour NUMERIC(8,0), fixed_salary NUMERIC(8,0))
 LANGUAGE SQL
 AS $$
 INSERT INTO cm_job VALUES (job_id, job_title, salary_per_hour, fixed_salary);
 $$;

  CREATE PROCEDURE insert_menu
 (item_id VARCHAR(4), item_name VARCHAR(30), price NUMERIC(6, 0))
 LANGUAGE SQL
 AS $$
 INSERT INTO cm_menu VALUES (item_id, item_name, price);
 $$;

  CREATE PROCEDURE insert_staff
 (staff_id INTEGER, job_id VARCHAR(4), first_name VARCHAR(20), last_name VARCHAR(40), date_of_birth DATE, contact_number VARCHAR(11),
  hometown VARCHAR(20), branch_id VARCHAR(4), hire_date DATE, work_hour INTEGER, status VARCHAR(10))
 LANGUAGE SQL
 AS $$
 INSERT INTO cm_staff VALUES (staff_id, job_id, first_name, last_name, date_of_birth, contact_number, 
							  hometown, branch_id, hire_date, work_hour, status);
 $$;

  CREATE PROCEDURE insert_customer
 (customer_id INTEGER, customer_name VARCHAR(40), address VARCHAR(60), contact_number VARCHAR(11), gender VARCHAR(8))
 LANGUAGE SQL
 AS $$
 INSERT INTO cm_customer VALUES (customer_id, customer_name, address, contact_number, gender);
 $$;

  CREATE PROCEDURE insert_order
 (order_id VARCHAR (10), staff_id INTEGER, distance NUMERIC(5,2), status VARCHAR(8), discount NUMERIC(9,0), date_order DATE, customer_id INTEGER )
 LANGUAGE SQL
 AS $$
 INSERT INTO cm_order VALUES (order_id, staff_id, distance, status, discount, date_order, customer_id);
 $$;
 
  CREATE PROCEDURE insert_order_item
 (order_id VARCHAR (10), item_id VARCHAR (4), quantity INTEGER, price NUMERIC(6, 0))
 LANGUAGE SQL
 AS $$
 INSERT INTO cm_order_item VALUES (order_id , item_id, quantity, price);
 $$;