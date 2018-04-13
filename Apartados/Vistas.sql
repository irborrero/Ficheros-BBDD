
--DROP VIEW NuevaMulta;

CREATE VIEW NuevaMulta AS
SELECT nPlate, odatetime, speed_limit - speed as diferencia from ROADS R INNER JOIN OBSERVATIONS O
    ON R.name=O.road
      WHERE R.speed_limit/2 > O.speed;


--select * from NuevaMulta;





--DROP VIEW Tramos;

CREATE VIEW Tramos AS
SELECT name, km_point inicio, km_point+5 as final from ROADS R INNER JOIN OBSERVATIONS O
    ON R.name=O.road
      WHERE R.speed_limit/2 > O.speed;


--select * from Tramos;


SELECT road, km_point inicio, km_point+5 as fin, direction from RADARS where road='A5';
