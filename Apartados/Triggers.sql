
------------------------------- TRIGGER A ----------------------------------
----------- INSERCIÓN DE MULTA
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


	CREATE OR REPLACE TRIGGER InsertarMulta
				FOR INSERT ON OBSERVATIONS
				COMPOUND TRIGGER
				obsInsertada OBSERVACION;
			AFTER EACH ROW IS
   		BEGIN
				obsInsertada := OBSERVACION(NULL, NULL, NULL, NULL, NULL, NULL);
				obsInsertada.nPlate := :NEW.nPlate;
				obsInsertada.odatetime := :NEW.odatetime;
   		END AFTER EACH ROW;

   		AFTER STATEMENT IS
				amountVelMax NUMBER;
				amountVelTramo NUMBER;
				amountDist NUMBER;
				dueno VARCHAR(9);
				obsAnterior OBSERVACION;
				obsCocheAnterior OBSERVACION;
   		BEGIN
				obsAnterior := OBSERVACION(NULL, NULL, NULL, NULL, NULL, NULL);
				obsCocheAnterior := OBSERVACION(NULL, NULL, NULL, NULL, NULL, NULL);
				obsAnterior := paquete.ObservacionAnterior(obsInsertada.nPlate, obsInsertada.odatetime);
				obsCocheAnterior := paquete.ObservacionCocheAnterior(obsInsertada.nPlate, obsInsertada.odatetime);

				amountVelMax := paquete.calculoVelMax(obsInsertada.nPlate, obsInsertada.odatetime);
				amountVelTramo := paquete.calculoVelTramo(obsInsertada.nPlate, obsAnterior.odatetime, obsInsertada.odatetime);
				amountDist := paquete.calculoSancionDistancia(obsInsertada.nPlate, obsInsertada.odatetime);

				DBMS_OUTPUT.PUT_LINE(amountVelMax || '-' || amountVelTramo||'-'||amountDist);

				select owner into dueno from vehicles where nPlate = obsInsertada.nPlate;

					--r: registrada
					--i: emitida
					--e: recibida
					--f: abonada
					--n: no abonada

				IF amountVelMax > 0
				THEN
				DBMS_OUTPUT.PUT_LINE('Insertando ticket por Vel Max...');
				INSERT INTO TICKETS VALUES(obsInsertada.nPlate,obsInsertada.odatetime,'S',NULL,NULL,SYSDATE,NULL,NULL,amountVelMax,dueno, 'R');
				END IF;

				IF amountvelTramo > 0
				THEN
				DBMS_OUTPUT.PUT_LINE('Insertando ticket por Vel Tramo...');
				INSERT INTO TICKETS VALUES(obsInsertada.nPlate,obsAnterior.odatetime,'T',obsInsertada.nPlate,obsInsertada.odatetime,SYSDATE,NULL,NULL,amountVelTramo,dueno, 'R');
				END IF;

				IF amountDist > 0
				THEN
				DBMS_OUTPUT.PUT_LINE('Insertando ticket por distancia...');
				INSERT INTO TICKETS VALUES(obsInsertada.nPlate,obsInsertada.odatetime,'D',obsCocheAnterior.nPlate,obsCocheAnterior.odatetime,SYSDATE,NULL,NULL,amountDist,dueno, 'R');
				END IF;

   		END AFTER STATEMENT;

END InsertarMulta;

/
--------------------------------- TRIGGER C----------------------------------------
CREATE OR REPLACE TRIGGER aReyMuerto
BEfore UPDATE OF reg_driver on VEHICLES
	DECLARE
		IF re












--------------------------------- TRIGGER D----------------------------------------
-------------- RESTRICCIONES
--Restricciones: recoger que la velocidad de todo radar sea menor o igual que la general de la vía


CREATE OR REPLACE TRIGGER NoInsertesRadar
	FOR INSERT ON radars
		COMPOUND trigger
			speedRadar NUMBER;
			speedRoad NUMBER;

		AFTER EACH ROW IS
			BEGIN
				speedRadar := :NEW.speedlim;
				select speed_limit into speedRoad from ROADS where name= :NEW.road;
			END AFTER EACH ROW;

		AFTER STATEMENT IS
	 			velocidad_inadecuada EXCEPTION;
			BEGIN
				DBMS_OUTPUT.PUT_LINE(speedRadar || '-' || speedRoad);
				IF speedRadar >= speedRoad THEN
   				RAISE velocidad_inadecuada;
				END IF;
			EXCEPTION
   			WHEN velocidad_inadecuada THEN
					RAISE_APPLICATION_ERROR(-20001, 'La velocidad del radar debe ser inferior a la general');

END AFTER STATEMENT;
		END NoInsertesRadar;
/


-- y que los conductores tengan al menos 18 años.

CREATE OR REPLACE TRIGGER NoInsertesConductor
	BEFORE INSERT ON DRIVERS
	FOR EACH ROW
		DECLARE
		cumple DATE;
		edad number;
		edad_inadecuada EXCEPTION;
		BEGIN
				select birthdate into cumple from persons where DNI = :NEW.dni;

				edad := TRUNC(MONTHS_BETWEEN(SYSDATE, cumple))/12;

				IF edad < 18 THEN
					RAISE edad_inadecuada;
				END IF;

				EXCEPTION
	   			WHEN edad_inadecuada THEN
						RAISE_APPLICATION_ERROR(-20001, 'La edad del conductor debe ser superior a 18 años');
	END;
/
--INSERT INTO RADARS VALUES ('A6','1','ASC','0');

insert into PERSONS VALUES()
