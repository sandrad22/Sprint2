USE transactions;

######################################################
# NIVEL 1 ############################################
######################################################

# Exercici 1 #####################
# A partir dels documents adjunts (estructura_dades i dades_introduir), importa les dues taules. 

-- Ejecutamos primero "estructura_dades" y luego "dades_introduir"

# Mostra les característiques principals de l'esquema creat i explica les diferents taules i variables que existeixen. 
# Assegura't d'incloure un diagrama que il·lustri la relació entre les diferents taules i variables.

-- El esquema 'transactions' tiene dos tablas:
-- -- La tabla 'company' es la tabla principal y contiene datos generales de cada una de las compañías (telefono, email, pais, y website). 
-- -- La primary key es 'id' que es el identificador de cada compañía
-- -- La tabla 'transaction' es una tabla de dimensiones y contiene información sobre las transacciones realizadas por cada compañía (tarjeta de credito, id. usuario, 
-- -- latitud, longitud, fecha transaccion, cantidad vendida y rechazada s/n). La primary key es 'id' que es el identificador de cada transacción y 
-- -- la foreign key es 'company_id' que es el identificador de compañía.
-- -- Una compañía puede realizar varias transacciones.

-- -- Diagrama de la relacion entre las tablas y las variables.


# Exercici 2 #####################
# Utilitzant JOIN realitzaràs les següents consultes:

# Llistat dels països que estan fent compres.

SELECT DISTINCT country 
FROM company c
JOIN transaction t
ON c.id = t.company_id
WHERE declined = 0;


# Des de quants països es realitzen les compres.

SELECT COUNT(DISTINCT country) 
FROM company c
JOIN transaction t
ON c.id = t.company_id;


# Identifica la companyia amb la mitjana més gran de vendes.

SELECT c.id, company_name, AVG(amount) AS Media_Ventas  
FROM transaction t
JOIN company c
ON c.id = t.company_id
WHERE declined = 0
GROUP BY company_id
ORDER BY Media_Ventas DESC
LIMIT 1;


# Exercici 3 #####################
# Utilitzant només subconsultes (sense utilitzar JOIN):

# Mostra totes les transaccions realitzades per empreses d'Alemanya.

SELECT id
FROM transaction t
WHERE EXISTS 
	(SELECT country
    FROM company c
    WHERE t.company_id = c.id AND country = 'Germany');


# Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.

SELECT id, company_name      
FROM company c
WHERE c.id IN
	(SELECT t.company_id
    FROM transaction t
    WHERE declined = 0 AND t.amount >          
		(SELECT AVG(amount)
		FROM transaction
        WHERE declined = 0));


# Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.

SELECT id, company_name
FROM company 
WHERE id NOT IN
	(SELECT DISTINCT company_id
	FROM transaction);



######################################################
# NIVEL 2 ############################################
######################################################

# Exercici 1 #####################
# Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes. Mostra la data de cada transacció juntament amb el total de les vendes.

SELECT DATE(timestamp) AS Dia, SUM(amount) AS Total_Ventas 
FROM transaction
WHERE declined = 0
GROUP BY Dia
ORDER BY Total_Ventas DESC
LIMIT 5;


# Exercici 2 #####################
# Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjà.

SELECT c.country, AVG(t.amount) AS Media_Ventas
FROM company c
JOIN transaction t
ON c.id = t.company_id
WHERE declined = 0
GROUP BY c.country
ORDER BY Media_Ventas DESC;


# Exercici 3 #####################
# En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries per a fer competència a la companyia "Non Institute". 
# Per a això, et demanen la llista de totes les transaccions realitzades per empreses que estan situades en el mateix país que aquesta companyia.

# Mostra el llistat aplicant JOIN i subconsultes.

SELECT t.id, c.company_name  
FROM transaction t
JOIN company c
ON t.company_id = c.id 
WHERE c.country =
	(SELECT country
	FROM company
	WHERE company_name = 'Non Institute') AND company_name <> 'Non Institute'
ORDER BY company_name;


# Mostra el llistat aplicant solament subconsultes.

SELECT id               
FROM transaction 
WHERE company_id IN
	(SELECT id
	FROM company
	WHERE country =
		(SELECT country
		FROM company
		WHERE company_name = 'Non Institute') AND company_name <> 'Non Institute');



######################################################
# NIVEL 3 ############################################
######################################################

# Exercici 1 #####################

# Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions amb un valor comprès entre 100 i 200 euros 
# i en alguna d'aquestes dates: 29 d'abril del 2021, 20 de juliol del 2021 i 13 de març del 2022. Ordena els resultats de major a menor quantitat.

SELECT c.company_name Compañia, c.phone Telefono, c.country Pais, DATE(t.timestamp) AS Fecha, t.amount Valor_Transacciones
FROM transaction t
JOIN company c
ON t.company_id = c.id 
WHERE t.amount BETWEEN 100 AND 200 AND DATE(t.timestamp) IN ('2021-04-29', '2021-07-20', '2022-03-13') AND declined = 0
ORDER BY Valor_Transacciones DESC;


# Exercici 2 #####################
# Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, per la qual cosa et 
# demanen la informació sobre la quantitat de transaccions que realitzen les empreses, però el departament de recursos humans és exigent i 
# vol un llistat de les empreses on especifiquis si tenen més de 4 transaccions o menys.

SELECT t.company_id, c.company_name, COUNT(*) AS Transacciones,
CASE
	WHEN COUNT(*) > 4 THEN 'Más de 4 transacciones'
    WHEN COUNT(*) = 4 THEN 'Tienen 4 transacciones'
    ELSE 'Menos de 4 transacciones'
END AS Texto_Transacciones
FROM transaction t
JOIN company c 
ON t.company_id = c.id
GROUP BY t.company_id
ORDER BY c.company_name;



