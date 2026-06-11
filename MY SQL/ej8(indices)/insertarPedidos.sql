USE classicmodels;

DELIMITER //

DROP PROCEDURE IF EXISTS InsertarPedidos //

CREATE PROCEDURE InsertarPedidos(IN N INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE v_orderNum INT;
    DECLARE v_custNum INT;
    DECLARE v_status VARCHAR(15);
    DECLARE v_orderDate DATE;
    DECLARE v_requiredDate DATE;
    DECLARE v_shippedDate DATE;

    DECLARE v_numProds INT;
    DECLARE v_prod1 VARCHAR(15);
    DECLARE v_prod2 VARCHAR(15);
    DECLARE v_prod3 VARCHAR(15);
    DECLARE v_price1 DECIMAL(10,2);
    DECLARE v_price2 DECIMAL(10,2);
    DECLARE v_price3 DECIMAL(10,2);

    DECLARE v_custCount INT DEFAULT 0;
    DECLARE v_prodCount INT DEFAULT 0;

    SELECT COUNT(*) INTO v_custCount FROM customers;
    SELECT COUNT(*) INTO v_prodCount FROM products;

    IF v_custCount = 0 OR v_prodCount = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Se necesitan customers y products';
    END IF;

    DROP TEMPORARY TABLE IF EXISTS tmp_prod;
    CREATE TEMPORARY TABLE tmp_prod (
        productCode VARCHAR(15) NOT NULL PRIMARY KEY,
        MSRP DECIMAL(10,2) NOT NULL
    ) AS
    SELECT productCode, MSRP FROM products;

    SELECT COALESCE(MAX(orderNumber), 100000) + 1 INTO v_orderNum FROM orders;

    START TRANSACTION;

    bucle: LOOP
        IF i >= N THEN LEAVE bucle; END IF;

        SELECT customerNumber INTO v_custNum
        FROM customers
        ORDER BY RAND() LIMIT 1;

        SET v_orderDate = DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND() * 730) DAY);
        SET v_requiredDate = DATE_ADD(v_orderDate, INTERVAL 7 DAY);
        SET v_status = ELT(FLOOR(1 + RAND() * 6),
            'Shipped','In Process','On Hold','Cancelled','Disputed','Resolved');

        IF v_status IN ('Shipped','Resolved') THEN
            SET v_shippedDate = DATE_ADD(v_orderDate, INTERVAL FLOOR(RAND() * 7) DAY);
        ELSE
            SET v_shippedDate = NULL;
        END IF;

        INSERT INTO orders (orderNumber,orderDate,requiredDate,shippedDate,status,comments,customerNumber)
        VALUES (v_orderNum,v_orderDate,v_requiredDate,v_shippedDate,v_status,
                CONCAT('Orden generada #',v_orderNum),v_custNum);

        SET v_numProds = 1 + FLOOR(RAND() * 3);

        SELECT productCode, MSRP INTO v_prod1, v_price1
        FROM tmp_prod ORDER BY RAND() LIMIT 1;

        INSERT INTO orderdetails (orderNumber,productCode,quantityOrdered,priceEach,orderLineNumber)
        VALUES (v_orderNum,v_prod1,1+FLOOR(RAND()*10),v_price1,1);

        IF v_numProds >= 2 THEN
            SELECT productCode, MSRP INTO v_prod2, v_price2
            FROM tmp_prod
            WHERE productCode != v_prod1
            ORDER BY RAND() LIMIT 1;

            INSERT INTO orderdetails (orderNumber,productCode,quantityOrdered,priceEach,orderLineNumber)
            VALUES (v_orderNum,v_prod2,1+FLOOR(RAND()*10),v_price2,2);
        END IF;

        IF v_numProds >= 3 THEN
            SELECT productCode, MSRP INTO v_prod3, v_price3
            FROM tmp_prod
            WHERE productCode NOT IN (v_prod1, v_prod2)
            ORDER BY RAND() LIMIT 1;

            INSERT INTO orderdetails (orderNumber,productCode,quantityOrdered,priceEach,orderLineNumber)
            VALUES (v_orderNum,v_prod3,1+FLOOR(RAND()*10),v_price3,3);
        END IF;

        SET v_orderNum = v_orderNum + 1;
        SET i = i + 1;
    END LOOP;

    COMMIT;

    DROP TEMPORARY TABLE IF EXISTS tmp_prod;
END //

DELIMITER ;



-- 2
-- -> Rows fetched before execution  (cost=0..0 rows=1) (actual time=43e-6..80e-6 rows=1 loops=1)
EXPLAIN ANALYZE SELECT * FROM orders o WHERE o.orderNumber = 50000;
-- 3
--  -> Filter: (o.orderDate between <cache>((now() - interval 1 year)) and <cache>(now()))  (cost=1475 rows=13386) (actual time=0.201..67.8 rows=60114 loops=1)
--    -> Table scan on o  (cost=1475 rows=120486) (actual time=0.0158..62 rows=120494 loops=1)
EXPLAIN ANALYZE SELECT * FROM orders o WHERE o.orderDate BETWEEN NOW() - INTERVAL 1 MONTH AND now();

-- 4 
CREATE INDEX idx_orders_orderDate ON orders(orderDate);
--5 
-- el analizer tomo casi todas ya que le es mas caro
-- usar el indice para un 50 porciento de la tabla aprox
-- -> Filter: (o.orderDate between <cache>((now() - interval 1 year)) and <cache>(now()))  (cost=12185 rows=60243) (actual time=0.195..69 rows=60114 loops=1)
--    -> Table scan on o  (cost=12185 rows=120486) (actual time=0.0115..62.9 rows=120494 loops=1)

-- 6
CREATE INDEX idx_orders_cliente_estado ON orders(customerNumber, status);

-- 7
EXPLAIN ANALYZE SELECT * FROM orders WHERE customerNumber = 65940;
---> Index lookup on orders using customerNumber (customerNumber=65940)  (cost=0.35 rows=1) (actual time=0.00903..0.00903 rows=0 loops=1)

EXPLAIN ANALYZE SELECT * FROM orders WHERE customerNumber = 65940 AND status = 'Shipped';
-- -> Filter: (orders.`status` = 'Shipped')  (cost=0.26 rows=0.1) (actual time=0.0353..0.0353 rows=0 loops=1)
--    -> Index lookup on orders using customerNumber (customerNumber=65940)  (cost=0.26 rows=1) (actual time=0.0348..0.0348 rows=0 loops=1)
