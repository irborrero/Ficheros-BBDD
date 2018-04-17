
---------------------------------- FUNCIONES -------------------------------
--- typo creado para devolver observaciones en las funciones, usado más adelante

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

----------------- creacion del paquete
	 CREATE OR REPLACE PACKAGE paquete AS
	 	FUNCTION calculoVelMax(matricula IN VARCHAR2, tiempo IN TIMESTAMP) RETURN NUMBER;
	 	FUNCTION calculoVelTramo(matricula IN VARCHAR2, tiempo1 IN TIMESTAMP) RETURN NUMBER;
	 	FUNCTION calculoSancionDistancia(matricula IN VARCHAR2, tiempo1 IN TIMESTAMP) RETURN NUMBER;
	 	FUNCTION ObservacionAnterior(matricula IN VARCHAR2, tiempo IN TIMESTAMP) RETURN OBSERVACION;
	 	FUNCTION ObservacionCocheAnterior(matricula IN VARCHAR2, tiempo IN TIMESTAMP) RETURN OBSERVACION;
	 END paquete;
	 	/

		-------------------- paquete para la definición del cuerpo de las funciones
		CREATE OR REPLACE PACKAGE BODY paquete AS

		 	------------- FUNCION 1 ---------------------------------
		 				FUNCTION calculoVelMax(matricula IN VARCHAR2, tiempo IN TIMESTAMP) RETURN NUMBER
			 					IS
								cuantia NUMBER;
								velocidadLim NUMBER;
								obs OBSERVATIONS%ROWTYPE;
				 			BEGIN
								------ utilizamos obs para guardar los argumentos que relacionan la observacion con el radar
					 			select road, km_point, direction, speed into obs.road, obs.km_point, obs.direction, obs.speed from OBSERVATIONS where nPlate = matricula and odatetime = tiempo;
								------ buscamos el radar y su velocidad limite
								select speedlim into velocidadLim from RADARS where road = obs.road and Km_point = obs.km_point and direction = obs.direction;

								------ calculamos la cuantia redondeando los kilometros hacia arriba
				 				cuantia := round(obs.speed-velocidadLim)*10;

								------ si el conductor iba por debajo de la velocidad limite la cuantía es nula
				 					IF cuantia < 0 THEN
				 					cuantia := 0;
				 					END IF;

				 			RETURN cuantia;
				 	END;
					------------- FUNCION 2 --------------------------------
					FUNCTION calculoVelTramo(matricula IN VARCHAR2, tiempo1 IN TIMESTAMP) RETURN NUMBER
								IS
					      cuantia NUMBER;
					      velocidadLim NUMBER;
					      velocidadMed NUMBER;
					      tiempoTramo NUMBER;
					      distancia NUMBER;
					      tiempo2 TIMESTAMP;
					      velocidadGeneral NUMBER;
					      obs1 OBSERVATIONS%ROWTYPE;
					      obs2 OBSERVATIONS%ROWTYPE;
					    BEGIN

					    	select road, km_point, direction, speed into obs1.road, obs1.km_point, obs1.direction, obs1.speed from OBSERVATIONS where nPlate = matricula and odatetime = tiempo1;
								------ seleccionamos la observacion inmediatamente anterior a ese vehiculo
								select MAX(odatetime) into tiempo2 from OBSERVATIONS where nPlate = matricula and odatetime < tiempo1 and road = obs1.road and DIRECTION = obs1.direction;
								----- obtenemos el resto de datos necesarios para la observacion anterior
								select km_point, odatetime,road,direction into obs2.km_point, obs2.odatetime, obs2.road, obs2.direction from OBSERVATIONS where nPlate = matricula and odatetime = tiempo2;
								----- escogemos la velocidad del radar asociado a la observacion inmediatamente antior
					    	select speedlim into velocidadLim from RADARS where road = obs2.road and Km_point = obs2.km_point and direction = obs2.direction;
								---- escogemos la velocidad de la carreterea asociada de la carretera
								select speed_limit into velocidadGeneral from ROADS where name = obs1.road;
								----- escogemos la velocidad del radar asociado a la observacion actual
								select speedlim into velocidadLim from RADARS where road = obs1.road and Km_point = obs1.km_point and direction = obs1.direction;
							--- calculamos la distancia entre los radares
							distancia := ABS(obs2.Km_point - obs1.km_point);
							--- calculamos el tiempo que ha transcurrido entre las observaciones
						  tiempoTramo := ABS((extract(hour from obs2.odatetime)-extract(hour from tiempo1))*3600+ (extract(minute from obs2.odatetime)-extract(minute from tiempo1))*60+ (extract(second from obs2.odatetime)-extract(second from tiempo1))*1000);
							--- calculamos la velocidad a la que ha ido el coche de media con los parametros calculados previamente
							velocidadMed := (distancia/(tiempoTramo/(3600*1000)));

							---- si la distancia es mayor que 5 entre las observaciones entonces hemos de tener en cuenta la restricción del radar y la velocidad general de la carretera
							IF distancia > 5 THEN
								velocidadLim := (5*velocidadLim + (distancia-5)*velocidadGeneral)*1/distancia;
								cuantia := round(velocidadMed-velocidadLim)*10;
							ELSE
								--- si no solo contamos con la velocidad propia del radar
								cuantia := round(velocidadMed-velocidadLim)*10;
							END IF;

							-- si el coche va más despacio que la velocidad permitida la cuantía es nula
							IF cuantia < 0 THEN
								cuantia := 0;
							END IF;

							RETURN cuantia;
					END;

						-- SELECT paquete.CALCULOVELTRAMO('0583EAA','23/10/11 15:54:29,300000') from dual;

					------------- FUNCION 3 --------------------------------
					FUNCTION calculoSancionDistancia(matricula IN VARCHAR2, tiempo1 IN TIMESTAMP) RETURN NUMBER
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

					    					IF cuantia < 0 THEN
					    						cuantia := 0;
					    						END IF;

							RETURN cuantia;
						END;

						------------- FUNCION 4 --------------------------------
						FUNCTION ObservacionAnterior(matricula IN VARCHAR2, tiempo IN TIMESTAMP) RETURN OBSERVACION
						  IS
						       obsAnterior OBSERVACION;
									 obs1 OBSERVATIONS%ROWTYPE;

						    BEGIN
									obsAnterior := OBSERVACION(NULL, NULL, NULL, NULL, NULL, NULL);
									select road, km_point, direction into obs1.road, obs1.km_point, obs1.direction from OBSERVATIONS where nPlate = matricula and odatetime = tiempo;
									select  max(odatetime) into obsAnterior.odatetime from OBSERVATIONS where road = obs1.road and km_point = obs1.km_point and direction = obs1.direction and odatetime < tiempo;
						      select  nPlate, road, km_point, direction, speed into  obsAnterior.nPlate, obsAnterior.road, obsAnterior.km_point, obsAnterior.direction, obsAnterior.speed from OBSERVATIONS where odatetime = obsAnterior.odatetime and road= obs1.road and km_point=obs1.km_point and direction= obs1.direction;

						  	RETURN obsAnterior;
						END;

						------------- FUNCION 5 --------------------------------
						FUNCTION ObservacionCocheAnterior(matricula IN VARCHAR2, tiempo IN TIMESTAMP) RETURN OBSERVACION
							IS
									 obsAnterior OBSERVACION;
									 obs1 OBSERVATIONS%ROWTYPE;

								BEGIN
									obsAnterior := OBSERVACION(NULL, NULL, NULL, NULL, NULL, NULL);
									select  max(odatetime) into obsAnterior.odatetime from OBSERVATIONS where odatetime < tiempo and nPlate=matricula;
									select  nPlate, road, km_point, direction, speed into obsAnterior.nPlate, obsAnterior.road, obsAnterior.km_point, obsAnterior.direction, obsAnterior.speed from OBSERVATIONS where odatetime = obsAnterior.odatetime and nPlate=matricula;

								RETURN obsAnterior;
							END;

		END paquete;
		/
