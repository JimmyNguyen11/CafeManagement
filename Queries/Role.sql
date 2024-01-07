-- Revoke privileges
REVOKE CREATE ON SCHEMA public FROM public;
REVOKE ALL PRIVILEGES ON DATABASE cafe_management FROM public;

-- 1. Role customer.
CREATE ROLE customer;
GRANT CONNECT ON DATABASE cafe_management TO customer;
GRANT USAGE ON SCHEMA public TO customer;

GRANT SELECT ON TABLE cm_menu TO customer;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE cm_order TO customer;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE cm_order_item TO customer;
ALTER ROLE customer WITH LOGIN;


-- 2. Role normal staff.
CREATE ROLE normal_staff;
GRANT CONNECT ON DATABASE cafe_management TO normal_staff;
GRANT USAGE ON SCHEMA public TO normal_staff;

GRANT SELECT, INSERT, UPDATE ON TABLE cm_customer TO normal_staff;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE cm_order TO normal_staff;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE cm_order_item TO normal_staff;
ALTER ROLE normal_staff WITH LOGIN;

-- 3. Role branch manager.
CREATE ROLE manager_branch;
GRANT CONNECT ON DATABASE cafe_management TO manager_branch;
GRANT USAGE ON SCHEMA public TO manager_branch;

GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO manager_branch;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO manager_branch;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE cm_customer TO manager_branch;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE cm_order TO manager_branch;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE cm_order_item TO manager_branch;
GRANT SELECT, INSERT, UPDATE ON TABLE cm_staff TO manager_branch;
ALTER ROLE manager_branch WITH LOGIN;

-- 4. Role admin_system.
CREATE ROLE admin_system;
GRANT CONNECT ON DATABASE cafe_management TO admin_system;
GRANT ALL ON SCHEMA public TO admin_system;

GRANT ALL ON ALL TABLES IN SCHEMA public TO admin_system;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO admin_system;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO admin_system;
ALTER ROLE admin_system WITH LOGIN;

-- Create Users
CREATE USER customer1 WITH PASSWORD 'password1';
CREATE USER customer2 WITH PASSWORD 'password2';
CREATE USER normal_staff1 WITH PASSWORD 'password3';
CREATE USER normal_staff2 WITH PASSWORD 'password4';
CREATE USER manager_branch1 WITH PASSWORD 'password5';
CREATE USER manager_branch2 WITH PASSWORD 'password6';
CREATE USER admin1 WITH PASSWORD 'admin1';

-- Grant Roles to Users
GRANT customer TO customer1;
GRANT customer TO customer2;
GRANT normal_staff TO normal_staff1;
GRANT normal_staff TO normal_staff2;
GRANT manager_branch TO manager_branch1;
GRANT manager_branch TO manager_branch2;
GRANT admin_system TO admin1;