CREATE TABLE cm_branch (
    branch_id VARCHAR(4) NOT NULL PRIMARY KEY,
    address VARCHAR(60) NOT NULL,
    contact_number VARCHAR(12) NOT NULL,
    manager_id INTEGER NOT NULL
);
CREATE TABLE cm_menu (
    item_id VARCHAR(4) NOT NULL PRIMARY KEY,
    item_name VARCHAR(30) NOT NULL,
    price NUMERIC(6, 0) NOT NULL
);
CREATE TABLE cm_job 
(
    job_id VARCHAR(4) NOT NULL PRIMARY KEY,
    job_title VARCHAR(10) NOT NULL,
    salary_per_hour NUMERIC(8,0)  NULL,
    fixed_salary NUMERIC(8,0)  NULL
);

CREATE TABLE cm_staff 
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
    CHECK (status = 'part time' or status = 'full time')
);

CREATE TABLE cm_customer
(
    customer_id SERIAL NOT NULL PRIMARY KEY,
    customer_name VARCHAR(40) NOT NULL,
    address VARCHAR(60),
    contact_number VARCHAR(11) NOT NULL,
    gender VARCHAR(8),
    CHECK (gender = 'female' OR gender = 'male')
);


CREATE TABLE cm_order 
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

CREATE TABLE cm_order_item
(
    order_id VARCHAR (10) NOT NULL, 
    item_id VARCHAR (4) NOT NULL,
    quantity INTEGER NOT NULL,
    price NUMERIC(6, 0) NOT NULL,
    PRIMARY KEY (order_id, item_id),
    CONSTRAINT orditm_item_item_id
        FOREIGN KEY (item_id) REFERENCES cm_menu(item_id),
    CONSTRAINT orditm_order_order_id
        FOREIGN KEY (order_id) REFERENCES cm_order(order_id)
);


