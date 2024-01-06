--1. Trigger to enforce branch manager existence
--trigger function
CREATE OR REPLACE FUNCTION validate_branch_manager()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.manager_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM cm_staff WHERE staff_id = NEW.manager_id) THEN
        RAISE EXCEPTION 'Cannot assign non-existent staff as branch manager.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--attach trigger
CREATE TRIGGER trigger_validate_branch_manager
BEFORE INSERT OR UPDATE ON cm_branch
FOR EACH ROW EXECUTE FUNCTION validate_branch_manager();
--test

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
    IF NEW.discount = 0 AND EXISTS (
        SELECT 1
        FROM cm_order
        WHERE customer_id = NEW.customer_id 
		AND order_id <> NEW.order_id 
		AND date_order <> NEW.date_order
    ) THEN
        NEW.discount := COALESCE((SELECT MAX(discount) + 5 FROM cm_order WHERE customer_id = NEW.customer_id), 5);
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

--5. trigger cascade Delete for Order Items
--trigger function
CREATE OR REPLACE FUNCTION cascade_delete_order_items()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM cm_order_item WHERE order_id = OLD.order_id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
--attach trigger
CREATE TRIGGER trigger_cascade_delete_order
AFTER DELETE ON cm_order
FOR EACH ROW EXECUTE FUNCTION cascade_delete_order_items();
--test

