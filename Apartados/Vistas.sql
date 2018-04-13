
--DROP VIEW SancionesVelReducida;

CREATE VIEW SancionesVelReducida AS
SELECT nPlate, odatetime, speed_limit - speed as diferencia from ROADS R INNER JOIN OBSERVATIONS O
    ON R.name=O.road
      WHERE R.speed_limit/2 > O.speed;


--select * from SancionesVelReducida;
