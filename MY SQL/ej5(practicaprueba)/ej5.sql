DROP VIEW IF EXISTS resumen_ventas;

CREATE VIEW resumen_ventas AS(
	SELECT m.marca,COUNT(a.patente) AS cantidad_ventas,SUM(c.precio) AS ganacia,cantidad_autos_vendidos(m.id,c.fecha) AS masVendido FROM modelo m 
	JOIN auto a ON a.modelo_id = m.id
	JOIN compra c ON c.auto_patente = a.patente
	GROUP BY YEAR(c.fecha), MONTH(c.fecha) ,a.modelo_id
)

