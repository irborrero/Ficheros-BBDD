
---------- VISTA OBLIGATORIA ---------------------------------------------------------
-- C) TRAMOS
    CREATE VIEW TRAMOS AS
      SELECT ROAD, KM_POINT,
        CASE
        WHEN (KM_POINT + 5 >= FINAL AND DIRECTION='ASC') THEN FINAL
        WHEN (KM_POINT + 5 < FINAL AND DIRECTION='ASC') THEN KM_POINT +5
        WHEN (KM_POINT - 5 >= FINAL AND DIRECTION='DES') THEN KM_POINT -5
        WHEN (KM_POINT - 5 < FINAL AND DIRECTION='DES') THEN FINAL
        END AS FINAL, SPEEDLIM FROM
        (SELECT km_point, LEAD(KM_POINT, 1, KM_POINT +5) OVER (PARTITION BY ROAD ORDER BY KM_POINT) AS FINAl, ROAD, DIRECTION, SPEEDLIM FROM RADARS WHERE direction='ASC'
        UNION ALL
        SELECT KM_POINT,
        CASE
        WHEN (LEAD(KM_POINT, 1, KM_POINT -5) OVER (PARTITION BY ROAD ORDER BY km_point DESC)<0) THEN 0
        ELSE LEAD(KM_POINT, 1, KM_POINT -5) OVER (PARTITION BY ROAD ORDER BY km_point DESC)
        END AS FINAL, ROAD, DIRECTION, SPEEDLIM FROM RADARS WHERE direction='DES')
        VISTA INNER JOIN ROADS R ON R.NAME= VISTA.ROAD WHERE VISTA.SPEEDLIM < R.speed_limit;


------------------ VISTAS OPCIONALES

-- A) NUEVA MULTA
CREATE VIEW NuevaMulta AS
  SELECT nPlate, to_char(odatetime, 'DD-MM-YY') AS FECHA, speed_limit - speed as diferencia from ROADS R INNER JOIN OBSERVATIONS O
    ON R.name=O.road
    WHERE R.speed_limit/2 > O.speed;

-- B) PROTESTON
CREATE VIEW Proteston AS
SELECT MAX(PROTESTON)KEEP(DENSE_RANK FIRST ORDER BY CUENTA DESC) AS PROTESTON, ltrim(TO_CHAR(FECHA, 'mm-yyyy'),0) AS FECHA FROM (
    SELECT new_debtor as proteston, count (*) cuenta, trunc(exec_date) AS FECHA from allegations where status like 'R'
        GROUP BY trunc(exec_date), new_debtor ORDER BY count(*) DESC) GROUP BY FECHA;
