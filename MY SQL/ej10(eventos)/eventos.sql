
# 1
DROP EVENT IF EXISTS actualizarPedidosRetrasados;

CREATE EVENT actualizarPedidosRetrasados
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_DATE
DO
    UPDATE orders
    SET status = 'Delayed'
    WHERE requiredDate < NOW()
      AND status = 'In Process';

# 2
DROP EVENT IF EXISTS eliminarPagosViejos;

CREATE EVENT eliminarPagosViejos
ON SCHEDULE EVERY 1 MONTH
STARTS CURRENT_DATE
DO
    DELETE FROM payments
    WHERE paymentDate < NOW() - INTERVAL 5 YEAR;

# 3
DROP EVENT IF EXISTS aumentarCreditoClientes;

CREATE EVENT aumentarCreditoClientes
ON SCHEDULE EVERY 1 MONTH
STARTS CURRENT_DATE
ENDS CURRENT_DATE + INTERVAL 1 YEAR
DO
    UPDATE customers
    SET creditLimit = creditLimit * 1.1
    WHERE customerNumber IN (
        SELECT customerNumber FROM (
            SELECT o.customerNumber
            FROM orders o
            WHERE o.orderDate >= NOW() - INTERVAL 1 YEAR
            GROUP BY o.customerNumber
            HAVING COUNT(*) > 10
        ) AS clientes_activos
    );

# 4
DROP EVENT IF EXISTS asignarEmpleadoAClientes;

CREATE EVENT asignarEmpleadoAClientes
ON SCHEDULE EVERY 1 WEEK
STARTS CURRENT_DATE + INTERVAL 1 DAY + INTERVAL 7 HOUR
DO
BEGIN
    DECLARE v_finished INT DEFAULT 0;
    DECLARE v_customerNumber INT;
    DECLARE v_employeeNumber INT;
    DECLARE cur CURSOR FOR
        SELECT customerNumber FROM customers WHERE salesRepEmployeeNumber IS NULL;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_finished = 1;

    OPEN cur;
    asignar: LOOP
        FETCH cur INTO v_customerNumber;
        IF v_finished THEN
            LEAVE asignar;
        END IF;

        SELECT e.employeeNumber INTO v_employeeNumber
        FROM employees e
        LEFT JOIN customers c ON c.salesRepEmployeeNumber = e.employeeNumber
        GROUP BY e.employeeNumber
        ORDER BY COUNT(c.customerNumber) ASC
        LIMIT 1;

        UPDATE customers
        SET salesRepEmployeeNumber = v_employeeNumber
        WHERE customerNumber = v_customerNumber;
    END LOOP;
    CLOSE cur;
END;

# 5
DROP EVENT IF EXISTS generarReporteDiario;

CREATE EVENT generarReporteDiario
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_DATE + INTERVAL 23 HOUR + INTERVAL 59 MINUTE
ENDS CURRENT_DATE + INTERVAL 3 MONTH
DO
    INSERT INTO reportes_diarios (fecha_reporte, total_ventas)
    VALUES (CURDATE(), (
        SELECT COALESCE(SUM(od.quantityOrdered * od.priceEach), 0)
        FROM orders o
        JOIN orderdetails od ON od.orderNumber = o.orderNumber
        WHERE o.orderDate = CURDATE()
    ));

# 6
DROP EVENT IF EXISTS reducirPrecioSinVentas;

CREATE EVENT reducirPrecioSinVentas
ON SCHEDULE EVERY 6 MONTH
STARTS '2025-07-01'
DO
    UPDATE products
    SET buyPrice = buyPrice * 0.95
    WHERE NOT EXISTS (
        SELECT 1
        FROM orderdetails od
        JOIN orders o ON o.orderNumber = od.orderNumber
        WHERE od.productCode = products.productCode
          AND o.orderDate >= NOW() - INTERVAL 6 MONTH
    );
