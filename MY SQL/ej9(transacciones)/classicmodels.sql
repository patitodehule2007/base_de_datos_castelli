
# 1 - realizarCompra
DELIMITER //

DROP PROCEDURE IF EXISTS realizarCompra //

CREATE PROCEDURE realizarCompra(
    IN p_customerNumber INT,
    IN p_productCode VARCHAR(15),
    IN p_cantidad INT,
    IN p_fecha_esperada DATE
)
BEGIN
    DECLARE v_stock INT;
    DECLARE v_precio DECIMAL(10,2);
    DECLARE v_orderNumber INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT quantityInStock, buyPrice INTO v_stock, v_precio
    FROM products
    WHERE productCode = p_productCode
    FOR UPDATE;

    IF v_stock < p_cantidad THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error, stock insuficiente';
    END IF;

    SELECT COALESCE(MAX(orderNumber), 0) + 1 INTO v_orderNumber FROM orders;

    INSERT INTO orders (orderNumber, orderDate, requiredDate, status, customerNumber)
    VALUES (v_orderNumber, CURDATE(), p_fecha_esperada, 'In Process', p_customerNumber);

    INSERT INTO orderdetails (orderNumber, productCode, quantityOrdered, priceEach, orderLineNumber)
    VALUES (v_orderNumber, p_productCode, p_cantidad, v_precio, 1);

    UPDATE products
    SET quantityInStock = quantityInStock - p_cantidad
    WHERE productCode = p_productCode;

    COMMIT;
END //

DELIMITER ;

# 2 - procesarPago
DELIMITER //

DROP PROCEDURE IF EXISTS procesarPago //

CREATE PROCEDURE procesarPago(
    IN p_customerNumber INT,
    IN p_checkNumber VARCHAR(50),
    IN p_monto DECIMAL(10,2)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    IF simular_pago_tarjeta(p_checkNumber) THEN
        INSERT INTO payments (customerNumber, checkNumber, paymentDate, amount)
        VALUES (p_customerNumber, p_checkNumber, CURDATE(), p_monto);

        IF p_monto > 800000 THEN
            UPDATE customers
            SET creditLimit = 1500000
            WHERE customerNumber = p_customerNumber;
        END IF;

        COMMIT;
    ELSE
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: Pago rechazado';
    END IF;
END //

DELIMITER ;

# 3 - cancelarPedido
DELIMITER //

DROP PROCEDURE IF EXISTS cancelarPedido //

CREATE PROCEDURE cancelarPedido(
    IN p_orderNumber INT
)
BEGIN
    DECLARE v_status VARCHAR(15);
    DECLARE v_finished INT DEFAULT 0;
    DECLARE v_productCode VARCHAR(15);
    DECLARE v_cantidad INT;
    DECLARE cur CURSOR FOR
        SELECT productCode, quantityOrdered
        FROM orderdetails
        WHERE orderNumber = p_orderNumber;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_finished = 1;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT status INTO v_status FROM orders WHERE orderNumber = p_orderNumber;

    IF v_status = 'Shipped' THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: No se puede cancelar un pedido que ya fue enviado';
    END IF;

    OPEN cur;
    devolver: LOOP
        FETCH cur INTO v_productCode, v_cantidad;
        IF v_finished THEN
            LEAVE devolver;
        END IF;
        UPDATE products
        SET quantityInStock = quantityInStock + v_cantidad
        WHERE productCode = v_productCode;
    END LOOP;
    CLOSE cur;

    UPDATE orders SET status = 'Cancelled' WHERE orderNumber = p_orderNumber;

    COMMIT;
END //

DELIMITER ;

# 4 - reasignarVendedor
DELIMITER //

DROP PROCEDURE IF EXISTS reasignarVendedor //

CREATE PROCEDURE reasignarVendedor(
    IN p_viejo_vendedor INT,
    IN p_nuevo_vendedor INT
)
BEGIN
    DECLARE v_existe INT;
    DECLARE v_office_viejo VARCHAR(10);
    DECLARE v_office_nuevo VARCHAR(10);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT COUNT(*) INTO v_existe FROM employees WHERE employeeNumber = p_nuevo_vendedor;

    IF v_existe = 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: Vendedor no apto para esta zona';
    END IF;

    SELECT officeCode INTO v_office_viejo FROM employees WHERE employeeNumber = p_viejo_vendedor;
    SELECT officeCode INTO v_office_nuevo FROM employees WHERE employeeNumber = p_nuevo_vendedor;

    IF v_office_viejo != v_office_nuevo THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: Vendedor no apto para esta zona';
    END IF;

    UPDATE customers
    SET salesRepEmployeeNumber = p_nuevo_vendedor
    WHERE salesRepEmployeeNumber = p_viejo_vendedor;

    COMMIT;
END //

DELIMITER ;
