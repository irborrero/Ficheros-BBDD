
------------------------ CONSULTAS --------------------------

--------------- 1
SELECT nPlate matricula, repeticiones FROM (
  SELECT nPlate, count(nPlate) repeticiones FROM
  observations WHERE TO_CHAR(odatetime, ‘DD-MM-YYYY’) LIKE TO_CHAR(SYSDATE, ‘DD-MM-YYYY’) GROUP BY nPlate ORDER BY repeticiones DESC )
  WHERE rownum <=10;


---------------- 2

SELECT ROAD, (MAX(speed_limit)*(2*max(finalmax)-sum(distTramo)) + sum(velTramo) )/(2*MAX(finalmax)) as VELOCIDADMEDIA FROM
  ((SELECT sum(abs(final - km_point)) as distTramo, (sum(abs(final - km_point)) * speedlim) as velTramo, max(final) as finalmax, MAX(road) AS ROAD from Tramos group by ROAD,speedlim)
  	TRAMOS JOIN ROADS R on R.name = TRAMOS.road) GROUP BY ROAD ORDER BY velocidadmedia DESC, road;

----------------- 3
SELECT DISTINCT OWNER FROM (
  SELECT OWNER, NPLATE FROM VEHICLES MINUS
  SELECT REG_DRIVER, NPLATE FROM VEHICLES
  MINUS SELECT DRIVER, NPLATE FROM ASSIGNMENTS);

--------------- 4
SELECT count(*) coches, dueno FROM ((SELECT DISTINCT owner as dueno FROM ((SELECT owner, nPlate FROM vehicles )
MINUS (SELECT reg_driver, nPlate  FROM vehicles) MINUS (SELECT * from ASSIGNMENTS))) A
INNER JOIN (SELECT owner, nPlate FROM vehicles) B ON A.dueno = B.owner ) GROUP BY dueno HAVING count(*)>=3;

 --------- 5
