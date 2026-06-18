
# 1 - retirarDeEstanteria
DELIMITER //

DROP PROCEDURE IF EXISTS retirarDeEstanteria //

CREATE PROCEDURE retirarDeEstanteria(
    IN p_codProducto INT,
    IN p_idEstante INT,
    IN p_cantidad INT
)
BEGIN
    DECLARE v_stock_estante INT;
    DECLARE v_stock_producto INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT cantidad INTO v_stock_estante
    FROM estanteria
    WHERE idEstante = p_idEstante AND codProducto = p_codProducto
    FOR UPDATE;

    IF v_stock_estante - p_cantidad < 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: stock insuficiente en la estantería';
    END IF;

    SELECT stock INTO v_stock_producto
    FROM producto
    WHERE codProducto = p_codProducto
    FOR UPDATE;

    IF v_stock_producto - p_cantidad < 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: stock insuficiente del producto';
    END IF;

    UPDATE estanteria
    SET cantidad = cantidad - p_cantidad
    WHERE idEstante = p_idEstante AND codProducto = p_codProducto;

    UPDATE producto
    SET stock = stock - p_cantidad
    WHERE codProducto = p_codProducto;

    COMMIT;
END //

DELIMITER ;

# 2 - aumentarPorCategoria
DELIMITER //

DROP PROCEDURE IF EXISTS aumentarPorCategoria //

CREATE PROCEDURE aumentarPorCategoria(
    IN p_idCategoria INT,
    IN p_porcentaje DECIMAL(5,2)
)
BEGIN
    DECLARE v_existe INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT COUNT(*) INTO v_existe FROM categoria WHERE idCategoria = p_idCategoria;

    IF v_existe = 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: categoría inexistente';
    END IF;

    UPDATE producto
    SET precio = precio * (1 + p_porcentaje / 100)
    WHERE categoria_id = p_idCategoria;

    COMMIT;
END //

DELIMITER ;

# 3 - registrarIngreso
DELIMITER //

DROP PROCEDURE IF EXISTS registrarIngreso //

CREATE PROCEDURE registrarIngreso(
    IN p_idProveedor INT,
    IN p_codProducto INT,
    IN p_provincia VARCHAR(100),
    IN p_cantidad INT
)
BEGIN
    DECLARE v_provincia_proveedor VARCHAR(100);
    DECLARE v_idIngreso INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT provincia INTO v_provincia_proveedor
    FROM proveedor
    WHERE idProveedor = p_idProveedor;

    IF v_provincia_proveedor != p_provincia THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Ingreso rechazado: el proveedor no está habilitado para operar en esta provincia';
    END IF;

    INSERT INTO ingresostock (fecha) VALUES (NOW());
    SET v_idIngreso = LAST_INSERT_ID();

    INSERT INTO ingresostock_producto (IngresoStock_idIngreso, Producto_codProducto, cantidad)
    VALUES (v_idIngreso, p_codProducto, p_cantidad);

    UPDATE producto
    SET stock = stock + p_cantidad
    WHERE codProducto = p_codProducto;

    COMMIT;
END //

DELIMITER ;
