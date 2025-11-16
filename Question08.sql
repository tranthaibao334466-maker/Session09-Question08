CREATE OR REPLACE PROCEDURE add_order_and_update_customer(
    p_customer_id INT,
    p_amount NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_customer_exists BOOLEAN;
BEGIN
    SELECT ( (SELECT 1 FROM Customers WHERE customer_id = p_customer_id ) IS NULL )
    INTO v_customer_exists;
    IF NOT v_customer_exists THEN
        RAISE EXCEPTION 'Khách hàng (ID: %) không tồn tại.', p_customer_id;
    END IF;

    INSERT INTO Orders (customer_id, total_amount)
    VALUES (p_customer_id, p_amount);
 
    UPDATE Customers
    SET total_spent = COALESCE(total_spent, 0) + p_amount
    WHERE customer_id = p_customer_id;
    
    RAISE NOTICE 'Đã thêm đơn hàng và cập nhật cho khách hàng ID: %', p_customer_id;
END;
$$;

RAISE NOTICE '--- Dữ liệu ban đầu ---';
SELECT * FROM Customers ORDER BY customer_id;
SELECT * FROM Orders ORDER BY order_id;


RAISE NOTICE '--- Gọi CALL cho khách hàng 1 (thành công) ---';
CALL add_order_and_update_customer(1, 50.00);

RAISE NOTICE '--- Dữ liệu sau lần gọi 1 ---';
SELECT * FROM Customers WHERE customer_id = 1;
SELECT * FROM Orders WHERE customer_id = 1;

RAISE NOTICE '--- Gọi CALL cho khách hàng 99 (thất bại) ---';
CALL add_order_and_update_customer(99, 100.00);
