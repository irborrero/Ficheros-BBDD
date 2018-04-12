--------------------------Funcion 1
CREATE OR REPLACE FUNCTION calculoVelMax(matricula IN VARCHAR2, tiempo IN TIMESTAMP) RETURN NUMBER
	IS
       cuantia VARCHAR2(200);
       velocidadLim NUMBER(3,0);
       obs OBSERVATIONS%ROWTYPE;
    BEGIN
    	select road, km_point, direction, speed into obs.road, obs.km_point, obs.direction, obs.speed from OBSERVATIONS where nPlate = matricula and odatetime = tiempo;
		select speedlim into velocidadLim from RADARS where road = obs.road and Km_point = obs.km_point and direction = obs.direction;

		cuantia := round(obs.speed-velocidadLim)*10;

		IF cuantia < 0 THEN
		cuantia := 0;
		END IF;

		RETURN cuantia;
  	END;
	/


--select calculoVelMax('0935IOA','26/03/11 03:43:32,070000') from dual;

--------------------------Funcion 2
CREATE OR REPLACE FUNCTION calculoVelTramo(matricula IN VARCHAR2, tiempo1 IN TIMESTAMP, tiempo2 IN TIMESTAMP) RETURN NUMBER
	IS
       cuantia VARCHAR2(200);
       velocidadLim NUMBER(3,0);
       velocidadMed NUMBER(3,0);
       tiempoTramo NUMBER(10);
       distancia NUMBER(3);
       velocidadGeneral NUMBER(3,0);
       obs1 OBSERVATIONS%ROWTYPE;
       obs2 OBSERVATIONS%ROWTYPE;
    BEGIN
    	select road, km_point, direction, speed into obs1.road, obs1.km_point, obs1.direction, obs1.speed from OBSERVATIONS where nPlate = matricula and odatetime = tiempo1;
    	select road, km_point, direction, speed into obs2.road, obs2.km_point, obs2.direction, obs2.speed from OBSERVATIONS where nPlate = matricula and odatetime = tiempo2;
    	select speedlim into velocidadLim from RADARS where road = obs1.road and Km_point = obs1.km_point and direction = obs1.direction;
    	select speed_limit into velocidadGeneral from ROADS where name = obs1.road;

		select speedlim into velocidadLim from RADARS where road = obs1.road and Km_point = obs1.km_point and direction = obs1.direction;

		distancia := ABS(obs2.Km_point - obs1.km_point);

  		tiempoTramo := (extract(hour from tiempo2)-extract(hour from tiempo1))*3600+ (extract(minute from tiempo2)-extract(minute from tiempo1))*60+ (extract(second from tiempo2)-extract(second from tiempo1))*1000;

		velocidadMed := (distancia/tiempoTramo)*3600;

		IF distancia > 5 THEN
		velocidadLim := (5*velocidadLim + (distancia-5)*velocidadGeneral)*1/distancia;
		cuantia := round(velocidadMed-velocidadLim)*10;
		ELSE
		cuantia := round(velocidadMed-velocidadLim)*10;
		END IF;

		IF cuantia < 0 THEN
		cuantia := 0;
		END IF;

		RETURN cuantia;
  	END;
	/

--select calculoVelTramo('3295IOE','21/11/11 03:11:06,080000', '21/11/11 03:12:06,080000') from dual;
--INSERT INTO OBSERVATIONS VALUES('3295IOE', '21/11/11 03:11:06,080000', 'M45', '23', 'ASC', 100);
--INSERT INTO OBSERVATIONS VALUES('3295IOE', '21/11/11 03:12:06,080000', 'M45', '26', 'ASC', 100);


--------------------------Funcion 3
CREATE OR REPLACE FUNCTION calculoSancionDistancia(matricula IN VARCHAR2, tiempo1 IN TIMESTAMP) RETURN NUMBER
	IS
       cuantia VARCHAR2(200);
       tiempoLapso NUMBER(10);
       tiempoCocheDelante TIMESTAMP;
       obs1 OBSERVATIONS%ROWTYPE;

    BEGIN
    	select road, km_point, direction, speed, odatetime into obs1.road, obs1.km_point, obs1.direction, obs1.speed , obs1.odatetime from OBSERVATIONS where nPlate = matricula and odatetime = tiempo1;

    	select max(odatetime) into tiempoCocheDelante from OBSERVATIONS where road = obs1.road and km_point = obs1.km_point and direction = obs1.direction and odatetime < obs1.odatetime;

		tiempoLapso := (extract(hour from obs1.odatetime)-extract(hour from tiempoCocheDelante))*3600000+ (extract(minute from obs1.odatetime)-extract(minute from tiempoCocheDelante))*60000+ (extract(second from obs1.odatetime)-extract(second from tiempoCocheDelante))*1000;
    tiempoLapso := (round(tiempoLapso/100))*100;

    cuantia := (3.6 - tiempoLapso/1000)*100*10;

    IF
    cuantia < 0 THEN
    cuantia := 0;
    END IF;

		RETURN cuantia;
  	END;
	/

--select calculoSancionDistancia('3295IOE','21/11/11 03:15:06,080000') from dual;
    	select max(odatetime) from OBSERVATIONS where road = 'M45' and km_point = 26 and direction = 'ASC' and odatetime < '21/11/11 03:12:06,080000';

--INSERT INTO OBSERVATIONS VALUES('3295IOE', '21/11/11 03:15:05,023000', 'M45', '23', 'ASC', 100);
--INSERT INTO OBSERVATIONS VALUES('3295IOE', '21/11/11 03:15:06,080000', 'M45', '23', 'ASC', 100);

--------------------------Funcion 4

CREATE OR REPLACE TYPE OBSERVACION
	AS OBJECT(
			nPlate     VARCHAR2(7),
			odatetime  TIMESTAMP,
			road       VARCHAR2(5),
			km_point   NUMBER(3),
			direction  VARCHAR2(3),
			speed      NUMBER(3)
		)
   /

CREATE OR REPLACE FUNCTION ObservacionAnterior(matricula IN VARCHAR2, tiempo IN TIMESTAMP) RETURN OBSERVACION
  IS
       obsAnterior OBSERVACION;
			 tiempoAnterior TIMESTAMP;
			 matriculaAnterior VARCHAR2(7);
			 obs1 OBSERVATIONS%ROWTYPE;

    BEGIN
			obsAnterior := OBSERVACION(NULL, NULL, NULL, NULL, NULL, NULL);
			select road, km_point, direction into obs1.road, obs1.km_point, obs1.direction from OBSERVATIONS where nPlate = matricula and odatetime = tiempo;
			select  max(odatetime) into obsAnterior.odatetime from OBSERVATIONS where road = obs1.road and km_point = obs1.km_point and direction = obs1.direction and odatetime < tiempo;
      select  nPlate, road, km_point, direction, speed into  obsAnterior.nPlate, obsAnterior.road, obsAnterior.km_point, obsAnterior.direction, obsAnterior.speed from OBSERVATIONS where odatetime = obsAnterior.odatetime and road= obs1.road and km_point=obs1.km_point and direction= obs1.direction;

  	RETURN obsAnterior;
    END;
  /

	--select ObservacionAnterior('3295IOE','21/11/11 03:15:06,080000') from dual;
