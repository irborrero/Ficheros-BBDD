---------------------------- OBLIGATORIO
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

				select owner into dueno from vehicles where nPlate = obsInsertada.nPlate;

					--r: registrada
					--i: emitida
					--e: recibida
					--f: abonada
					--n: no abonada

				IF amountVelMax > 0
				THEN
				INSERT INTO TICKETS VALUES(obsInsertada.nPlate,obsInsertada.odatetime,'S',NULL,NULL,SYSDATE,NULL,NULL,amountVelMax,dueno, 'R');
				END IF;

				IF amountvelTramo > 0
				THEN
				INSERT INTO TICKETS VALUES(obsInsertada.nPlate,obsAnterior.odatetime,'T',obsInsertada.nPlate,obsInsertada.odatetime,SYSDATE,NULL,NULL,amountVelTramo,dueno, 'R');
				END IF;

				IF amountDist > 0
				THEN
				INSERT INTO TICKETS VALUES(obsInsertada.nPlate,obsInsertada.odatetime,'D',obsCocheAnterior.nPlate,obsCocheAnterior.odatetime,SYSDATE,NULL,NULL,amountDist,dueno, 'R');
				END IF;

   		END AFTER STATEMENT;

END InsertarMulta;

/

-------------------------------- OPCIONAL--------------------------------- 
