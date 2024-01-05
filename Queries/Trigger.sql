--1. Trigger audit Trail on Customer Update
--trigger function
CREATE OR REPLACE FUNCTION audit_customer_update()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO customer_audit (customer_id, changed_on, previous_data)
    VALUES (OLD.customer_id, now(), ROW(OLD.*));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
--attach trigger
CREATE TRIGGER trigger_customer_update
AFTER UPDATE ON cm_customer
FOR EACH ROW EXECUTE FUNCTION audit_customer_update();
--test

--2. Trigger update Inventory After Order
--trigger function
CREATE OR REPLACE FUNCTION update_inventory_after_order()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE cm_menu SET quantity = quantity - NEW.quantity
    WHERE item_id = NEW.item_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
--attach trigger
CREATE TRIGGER trigger_update_inventory
AFTER INSERT ON cm_order_item
FOR EACH ROW EXECUTE FUNCTION update_inventory_after_order();

--test

--3. trigger validate new staff age
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

--4. trigger automatically set discount for large orders
--trigger function
CREATE OR REPLACE FUNCTION apply_large_order_discount()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.total_amount > 1000 THEN -- Assuming total_amount is a column in cm_order
        NEW.discount := 10; -- 10% discount
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--attach trigger
CREATE TRIGGER trigger_large_order_discount
BEFORE INSERT OR UPDATE ON cm_order
FOR EACH ROW EXECUTE FUNCTION apply_large_order_discount();

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

