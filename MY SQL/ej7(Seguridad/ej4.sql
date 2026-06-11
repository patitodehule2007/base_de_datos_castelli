

CREATE USER IF NOT EXISTS 'rrhh_user'@'localhost' IDENTIFIED BY RANDOM PASSWORD;

GRANT SELECT (lastanme,firstName,officeCode,jobTitle) ON TABLE classicmodels.employees TO 'rrhh_user'@'localhost';

GRANT EXECUTE ON PROCEDURE classicmodels.contar_empleados TO 'rrhh_user'@'localhost';


