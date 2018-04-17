

--DROP VIEW NuevaMulta;

CREATE VIEW NuevaMulta AS
SELECT nPlate, odatetime, speed_limit - speed as diferencia from ROADS R INNER JOIN OBSERVATIONS O
    ON R.name=O.road
      WHERE R.speed_limit/2 > O.speed;


--select * from NuevaMulta;

---------------------------------------------

--select * from Tramos;


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
        SELECT KM_POINT,LEAD(KM_POINT, 1, KM_POINT -5) OVER (PARTITION BY ROAD ORDER BY km_point DESC) AS FINAL, ROAD, DIRECTION, SPEEDLIM FROM RADARS WHERE direction='DES');



--- cosas que faltan por controlar
    --KM de final de descendentres : -2
    -- que la velocidad de los tramos sea inferior a la de la carretera general
