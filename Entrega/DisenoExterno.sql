
------------------ PERFIL RELACIONES PÚBLICAS ------------

---- Vista conductores con atributos de persona
CREATE VIEW Conductores AS
SELECT name, surn_1, surn_2, address, town, mobile, email, birthdate FROM
DRIVERS D INNER JOIN PERSONS P ON D.DNI= P.DNI;

---- Dueños con atributo de persona
CREATE VIEW Duenos AS
SELECT DISTINCT name, surn_1, surn_2, address, town, mobile, email, birthdate FROM
VEHICLES V INNER JOIN PERSONS P ON V.OWNER= P.DNI;

---- Asignaciones
---not working
CREATE VIEW Asignaciones AS
SELECT driver as conductor,
CASE
 WHEN (driver like (SELECT reg_driver from vehicles where nplate = NPLATE)) THEN 'SI'
 ELSE 'NO'
END AS cond_habitual, nplate as matricula FROM ASSIGNMENTS A INNER JOIN VEHICLES V ON V.nPlate = A.nPlate;

---- Bonachon

CREATE VIEW Bonachon AS
SELECT dni FROM PERSONS MINUS SELECT new_debtor FROM ALLEGATIONS;


--------------- PERFIL ADMINISTRATIVO

--- Vista de sanciones impagadas
CREATE VIEW SancionesImpagadas AS
 SELECT amount , tik_type FROM tickets where state like 'N';

-- Vista de el vehiculo con contacto
CREATE VIEW Notificacion AS
  SELECT nPlate as matricula, email, mobile as telefono, address as direction FROM
   VEHICLES V INNER JOIN PERSONS P ON V.owner =  P.dni;

-- Vista ultima infraccion
CREATE VIEW UltimaInfraccion AS
  SELECT max(obs1_veh) as matricula, max(obs1_date) as ult_infracion
  FROM TICKETS GROUP BY obs1_veh;
