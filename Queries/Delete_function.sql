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