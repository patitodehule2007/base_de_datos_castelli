-- rol 1
CREATE ROLE stocker;

GRANT EXECUTE  ON PROCEDURE update_stock TO stocker;
GRANT EXECUTE  ON PROCEDURE update_prices TO stocker;
GRANT EXECUTE  ON PROCEDURE update_pedidos_price TO stocker;
GRANT SELECT ON stocks.* TO stocker;

-- rol 2
CREATE  ROLE orderer;

GRANT EXECUTE ON PROCEDURE borrarOrden TO orderer
GRANT EXECUTE  ON PROCEDURE borrarLineaProductos TO stocker;
GRANT EXECUTE  ON PROCEDURE actualizarComentarios TO stocker;

GRANT SELECT ON stocks.orderDetails TO orderer;
GRANT SELECT ON stocks.orders TO orderer;

-- rol 3
CREATE  ROLE lector;

GRANT SELECT ON stocks.* TO lector;
GRANT SELECT ON classicmodels.* TO lector;
GRANT EXECUTE  ON PROCEDURE stocks.* TO lector;
GRANT EXECUTE  ON PROCEDURE classicmodels.* TO lector;

-- rol 4


CREATE  ROLE dev;

GRANT CREATE ROUTINE, TRIGGER, INDEX, EVENT ON stocks.* TO dev;
GRANT UPDATE ROUTINE, TRIGGER, INDEX, EVENT ON stocks.* TO dev;
GRANT DELETE ROUTINE, TRIGGER, INDEX, EVENT ON stocks.* TO dev;


GRANT CREATE ROUTINE, TRIGGER, INDEX, EVENT ON classicmodels.* TO dev;
GRANT UPDATE ROUTINE, TRIGGER, INDEX, EVENT ON classicmodels.* TO dev;
GRANT DELETE ROUTINE, TRIGGER, INDEX, EVENT ON classicmodels.* TO dev;

GRANT SELECT ON stocks.* TO dev;
GRANT SELECT ON classicmodels.* TO dev;

-- rol 5

CREATE  ROLE admin;
GRANT ALL PRIVILEGES ON stocks.* TO admin;
GRANT ALL PRIVILEGES ON classicmodels.* TO admin;
