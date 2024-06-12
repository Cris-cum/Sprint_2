use transactions;

SELECT id, count(*)	
FROM transactions.company
GROUP BY id
HAVING COUNT(*)>1;

Select id, count(*)	
from transactions.transaction
group by id
Having count(*)>1;

select*
from transactions.transaction;

-- Nivel 1. Ejercicio 2-1. Listado de los países que están haciendo compras.
SELECT distinct company.country
FROM transactions.company
JOIN transactions.transaction
ON company.id = transaction.company_id
WHERE declined = 0;

-- Nivel 1.Ejercicio 2-2 ¿Desde cuántos países se están haciendo compras?
SELECT count(DISTINCT company.country) AS num_países
FROM transactions.company
JOIN transactions.transaction
ON company.id = transaction.company_id
WHERE declined = 0;

-- Nivel 1.Ejercicio 2-3 Identifica la compañía con la media más grande de ventas
SELECT  company.company_name, ROUND(AVG(transaction.amount),2) AS media
FROM transactions.transaction
LEFT JOIN  transactions.company
ON company.id = transaction.company_id
WHERE declined = 0
GROUP BY company.id
ORDER BY media DESC
LIMIT 1;

-- Nivel 1. Ejercicio 3-1 Muestra todas las transacciones realizadas por empresas de Alemania
SELECT*
FROM transaction
WHERE company_id IN (SELECT company.id
                    FROM company
                    WHERE country = "Germany");	

-- Nivel 1. Ejercicio 3-2 Lista las empresas que han realizado transacciones por un amount superior a la media de todas las transacciones.
SELECT company_name
FROM transactions.company
WHERE id IN (
	SELECT company_id
	FROM transactions.transaction
	WHERE amount> (
		SELECT AVG(amount) AS media
		FROM transactions.transaction));
        
-- Nivel 1. Ejercicio 3-3. Eliminaran del sistema las empreses que no tienen transacciones registradas, entrega la  lista de estas empresas.
SELECT id, company_name
FROM company
WHERE NOT exists (
	SELECT DISTINCT company_id
	FROM transaction
);

-- Nivel 2. Ejercicio 1. Identifica los cinco días que se generó la cantidad más grande de ingresos a la empresa por ventas. Muestra la fecha de cada transacción junto con el total de las ventas.
SELECT  DATE(timestamp) AS fecha, sum(transaction.amount) AS total
FROM transactions.transaction
WHERE declined = 0
GROUP BY fecha
ORDER BY total desc
LIMIT 5;

-- Nivel 2. Ejercicio 2. ¿Cuál es la media de ventas por país? Presenta los resultados ordenados de mayor a menor media.
select  company.country as país, round(avg(transaction.amount),2) as media_ventas
from transactions.transaction
join transactions.company
on company.id = transaction.company_id
where declined = 0 
group by país
order by media_ventas desc;

-- Nivel 2. Ejercicio 3. En tu empresa, se plantea un nuevo proyecto para lanzar algunas campañas publicitarias para hacer competencia a la compañía "Non Institute". Para lo cual, te piden la lista de todas las transacciones realizadas por empresas que están situadas en el mismo país que esta compañía. Muestra el listado aplicando JOIN y subconsultas. Muestra el listado aplicando solo subconsultas.
-- usando JOIN
SELECT company.country, company.company_name, transaction.*
FROM Transaction 
JOIN Company  
ON transaction.company_id = company.id
WHERE company.country in (
	SELECT country
	FROM Company
	WHERE company_name = 'Non Institute');
    
-- usando subconsultas
SELECT transaction.*, (SELECT company_name 
	FROM transactions.company 
    WHERE company_id= transactions.company.id) AS empresa
FROM transactions.transaction
WHERE company_id IN ( select company.id
                      FROM transactions.company 
                      WHERE  company.country = (
							SELECT company.country
							FROM transactions.company
							WHERE company_name = 'Non Institute') );
				
-- Nivel 3. Ejercicio 1. Presenta el nombre, teléfono, país, fecha y amount, de aquellas empresas que realizaron transacciones con un valor comprendido entre 100 y 200 euros y en alguna de estas fechas: 29 de abril del 2021, 20 de julio del 2021 y 13 de marzo del 2022. Ordena los resultados de mayor a menor cantidad.
SELECT company.company_name AS nombre_empresa, company.phone AS teléfono, company.country AS país, transaction.amount AS cantidad, 
    DATE(transaction.timestamp) AS fecha
FROM transactions.transaction 
JOIN transactions.company  ON transaction.company_id = company.id
WHERE transaction.amount BETWEEN 100 AND 200
AND DATE(transaction.timestamp) IN ('2021-04-29', '2021-07-20', '2022-03-13')
ORDER BY cantidad DESC;

-- Nivel 3. Ejercicio 2. Necesitamos optimizar la asignación de los recursos y dependerá de la capacidad operativa que se requiera, por lo cual te piden la información sobre la cantidad de transacciones que realicen las empresas, pero el departamento de recursos humanos es exigente y quiere un listado de las empresas donde especifiques si tienen más de 4 transacciones o menos.
SELECT company_name as empresa,  count(transaction.id) as transacciones, CASE
WHEN COUNT(transaction.id) > 4 THEN "Más de 4"
ELSE "Menos de 4"
END AS "transacciones mayores o menores de 4"
FROM transactions.transaction
JOIN transactions.company on company.id= transaction.company_id
GROUP BY empresa
ORDER BY transacciones desc;
