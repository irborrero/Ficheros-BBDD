--------------------------Consulta 1
SELECT nPlate, repeticiones FROM (SELECT count(nPlate) repeticiones, nPlate FROM observations GROUP BY nPlate ORDER BY repeticiones DESC) WHERE rownum <=10;
--- Esta vista está mal, la correcta está en la memoria

--------------------------Consulta 2: falta supuestamente la velocidad promedia

 --Tramos: tabla que registra cada tramo de carretera en el que la velocidad es inferior a la velocidad general de la vía (contiene la identificación de la vía, puntos de inicio y fin, y límite de velocidad en el tramo).

select ROAD, (MAX(speed_limit)*(2*max(finalmax)-sum(distTramo)) + sum(velTramo) )/(2*MAX(finalmax)) as VELOCIDADMEDIA from
((Select sum(abs(final - km_point)) as distTramo, (sum(abs(final - km_point)) * speedlim) as velTramo, max(final) as finalmax, MAX(road) AS ROAD from Tramos group by ROAD,speedlim)
	TRAMOS JOIN ROADS R on R.name = TRAMOS.road) GROUP BY ROAD ORDER BY velocidadmedia DESC, road;

-------------------------Consulta 3: dueños que no son conductores habituales

--INSERT INTO ASSIGNMENTS values ('78455829T', '5862IOU');
--INSERT INTO ASSIGNMENTS values ('33254360V', '5862IOU');
SELECT DISTINCT DRIVER FROM (
  SELECT * FROM assignments UNION SELECT reg_driver, nplate FROM vehicles
   MINUS Select owner, nplate FROM vehicles);

   ---------- CON LA TABLA TAL CUAL NOS LA DA LA PROFE
   --107 ROWS SELECTED (son dueños que no son conductores habituales con un total de 197 dueños distintos)
   ---------- PRUEBAS QUE HEMOS HECHO NOSOTROS
    -- COCHE: '5862IOU' -- DUEÑO: 78455829T -- CONDUCTOR HABITUAL: 36071957E
    --INSERT INTO ASSIGNMENTS values ('78455829T', '5862IOU');
    --(insertamos el dueño como conductor no habitual)
 select count(*)coches,driver from (select driver, nplate from assignments UNION select reg_driver, nplate from vehicles MINUS select owner, nplate from vehicles)group by driver having count(*)>=3;


-------------------------Consulta 4
Select sum(amount) as suma from prueba Where obs1_date between add_months(trunc(sysdate,'mm'),-1) and last_day(add_months(trunc(sysdate,'mm'),-1));


-------------------------Consulta 5
select DISTINCT (Select sum(amount) as suma from prueba Where obs1_date between add_months(trunc(sysdate,'mm'),-1) and last_day(add_months(trunc(sysdate,'mm'),-1))
) - (SELECT sum(amount) as suma_anterior from prueba where obs1_date between add_months(SYSDATE, -14) and
last_day(add_months(SYSDATE, -13))) as diferencia FROM prueba;
