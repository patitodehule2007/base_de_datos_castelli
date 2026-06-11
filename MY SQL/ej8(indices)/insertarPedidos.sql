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
EXPLAIN ANALYZE SELECT * FROM orders o WHERE o.orderNumber = 50000;
-- 3
EXPLAIN ANALYZE SELECT * FROM orders o WHERE o.orderDate BETWEEN NOW() - INTERVAL 1 YEAR AND now();