EXPLAIN ANALYZE
SELECT * FROM cm_order WHERE order_id = 'OD6';

CREATE INDEX idx_order ON cm_order(order_id);

EXPLAIN ANALYZE
SELECT * FROM cm_customer WHERE customer_id = '99';

CREATE INDEX idx_customer ON cm_customer(customer_id);

EXPLAIN ANALYZE
SELECT * FROM cm_menu WHERE item_id = 'STR';

CREATE INDEX idx_item ON cm_menu(item_id);