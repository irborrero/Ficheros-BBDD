
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

select DISTINCT (Select sum(amount) as suma from tickets Where obs1_date between add_months(trunc(sysdate,'mm'),-1) and last_day(add_months(trunc(sysdate,'mm'),-1))
) - (SELECT sum(amount) as suma_anterior from tickets where obs1_date between add_months(SYSDATE, -14) and
last_day(add_months(SYSDATE, -13))) as diferencia FROM tickets;

INSERT into OBSERVATIONS values('9855AIE','19/03/18 03:43:33,010000','M45',10,'ASC',150);
INSERT into OBSERVATIONS values('9855AIE','19/03/17 03:43:33,010000','M45',10,'ASC',150);
INSERT into TICKETS values('9855AIE','19/03/18 03:43:33,010000','S',NULL,NULL,SYSDATE,NULL,NULL,1000,'36071957E','R');
INSERT into TICKETS values('9855AIE','19/03/17 03:43:33,010000','S',NULL,NULL,SYSDATE,NULL,NULL,500,'36071957E','R');

