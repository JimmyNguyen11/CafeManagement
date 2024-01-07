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