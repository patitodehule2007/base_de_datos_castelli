

CREATE USER IF NOT EXISTS 'operador_stock'@'localhost' IDENTIFIED BY RANDOM PASSWORD;
GRANT EXECUTE ON PROCEDURE stocks.actualizarStock TO 'operador_stock'@'localhost';

