-- 1. DEMO VIEW

-- 1. View of All Branches and Their Managers
SELECT * FROM BranchManagers;

-- 6. View of Order Summaries
SELECT * FROM OrderSummaries;

-- 10. View of Items Never Ordered
SELECT * FROM NeverOrderedItems;

-- 2. DEMO FUNCTION

-- insert_func
SELECT insert_order_info('OD555', 12, 1, 'Online', 5, '1-1-2024', 10);
SELECT insert_order_info('OD123', 12, 1, 'Online', 5, '1-2-2024', 11);
SELECT * FROM cm_order WHERE customer_id = 10; 
SELECT * FROM cm_order WHERE customer_id = 11; 

-- delete_func
SELECT * FROM cm_order_item WHERE order_id = 'OD26'; 
SELECT delete_order_item('OD26', 'AME');

SELECT * FROM cm_order WHERE order_id = 'OD4'; 
SELECT delete_order('OD4');

-- get ship fee
SELECT GETSHIPFEE('OD10') AS ship_fee;
SELECT GETSHIPFEE('ko') AS ship_fee;

-- get most efficient branch
SELECT getmostefficientbranch() AS ok;

-- get salary from one staff
SELECT get_salary(1);

-- 3. DEMO TRIGGER
-- apply returning discount
SELECT * FROM cm_order WHERE customer_id = 5;
SELECT insert_order_info('OD711', 12, 1, 'Online', 2, '1-1-2024', 5);
SELECT insert_order_info('OD712', 12, 1, 'Online', 1, '1-2-2024', 5);
SELECT insert_order_info('OD601', 12, 1, 'Online', 3, '1-10-2024', 5);

SELECT * FROM cm_order WHERE customer_id = 100;
SELECT insert_order_info('OD998', 12, 1, 'Online', 3, '1-10-2024', 100);
SELECT insert_order_info('OD997', 12, 1, 'Online', 0, '1-2-2024', 100);

-- prevent delete job
DELETE FROM cm_job WHERE job_id = 'WAT';
DELETE FROM cm_job WHERE job_id = 'MNG';


-- validate staff age
SELECT insert_staff_info(
    'WAT',
    'Jane',
    'Smith',
    '2016-05-20',
    '98732650',
    'Townsville',
    'NA8',
    '2024-02-01',
    35,
    'part time'
);
SELECT insert_staff_info(
    'WAT',
    'Jane',
    'Smith',
    '2003-05-20',
    '98732650',
    'Townsville',
    'NA8',
    '2024-02-01',
    35,
    'part time'
);

SELECT * FROM pg_catalog.pg_user;
SELECT * FROM pg_catalog.pg_roles;

SELECT * FROM information_schema.table_privileges
where grantee not in ('postgres', 'PUBLIC');

SELECT * FROM information_schema.role_table_grants
where grantee not in ('postgres', 'PUBLIC');

SELECT * FROM information_schema.usage_privileges
where grantee not in ('postgres', 'PUBLIC');