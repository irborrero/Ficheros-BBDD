--------------------------Consulta 1
SELECT nPlate, repeticiones FROM (SELECT count(nPlate) repeticiones, nPlate FROM observations GROUP BY nPlate ORDER BY repeticiones DESC) WHERE rownum <=10;


--------------------------Consulta 2: falta supuestamente la velocidad promedia
SELECT name,speed_limit FROM ROADS ORDER BY speed_limit DESC, name;


-------------------------Consulta 3: dueños que no son conductores habituales

--INSERT INTO ASSIGNMENTS values ('78455829T', '5862IOU');
--INSERT INTO ASSIGNMENTS values ('33254360V', '5862IOU');
 select count(*)coches,driver from (select driver, nplate from assignments UNION select reg_driver, nplate from vehicles MINUS select owner, nplate from vehicles)group by driver having count(*)>=3;


-------------------------Consulta 4
Select sum(amount) as suma from prueba Where obs1_date between add_months(trunc(sysdate,'mm'),-1) and last_day(add_months(trunc(sysdate,'mm'),-1));


-------------------------Consulta 5
select DISTINCT (Select sum(amount) as suma from prueba Where obs1_date between add_months(trunc(sysdate,'mm'),-1) and last_day(add_months(trunc(sysdate,'mm'),-1))
) - (SELECT sum(amount) as suma_anterior from prueba where obs1_date between add_months(SYSDATE, -14) and
last_day(add_months(SYSDATE, -13))) as diferencia FROM prueba;
