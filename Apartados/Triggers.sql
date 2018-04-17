
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

--------------------------------- TRIGGER B----------------------------------------
---------- Si el nuevo deudor no es conductor asignado
--- trigger a falta de revisión

CREATE OR REPLACE TYPE ALEGACION
	AS OBJECT(
		obs_veh    VARCHAR2(7),
    obs_date   TIMESTAMP,
    tik_type   VARCHAR2(9),
    reg_date   DATE,
    new_debtor VARCHAR2(9),
    status     VARCHAR2(1),
    exec_date  DATE
		)
   /

	CREATE OR REPLACE TRIGGER ProcesarAlegacion
	 BEFORE INSERT on ALLEGATIONS
			FOR EACH ROW
			DECLARE
				alegacionInsertada ALEGACION;
				c1 NUMBER;
				c2 NUMBER;

			BEGIN
				alegacionInsertada := ALEGACION(NULL, NULL, NULL, NULL, NULL, NULL, NULL);
				alegacionInsertada.new_debtor := :NEW.new_debtor;
				alegacionInsertada.obs_veh := :NEW.obs_veh;
				alegacionInsertada.obs_date := :NEW.obs_date;
				alegacionInsertada.tik_type := :NEW.tik_type;
				alegacionInsertada.reg_date := :NEW.reg_date;

				select count(*) into c1 from assignments where driver = alegacionInsertada.new_debtor and nPlate = alegacionInsertada.obs_veh;
				--select debtor into deudor from tickets where obs1_veh = :NEW.obs_veh and obs1_date =:NEW.obs_date and tik_type= :NEW.tik_type;
				select count(*) into c2 from allegations where obs_veh = alegacionInsertada.obs_veh and obs_date = alegacionInsertada.obs_date and tik_type = alegacionInsertada.tik_type and new_debtor = alegacionInsertada.new_debtor;

				DBMS_OUTPUT.PUT_LINE(c1 || '-' || c2);

				IF c1 = 0 THEN
				-- El nuevo deudor no es conductor del coche
					:NEW.status := 'R';
					:NEW.exec_date := SYSDATE;

				ELSE
				---- Vemos si el nuevo deudor ya ha podido alegar esa multa
					IF c2 = 0 THEN
							--No ha alegado esa multa previamente
							:NEW.status := 'A';
							:NEW.exec_date := SYSDATE;
					ELSE
						--Ha alegado previamente
						:NEW.status := 'U';
						END IF;
					END IF;

		END ;
		/

---------- Insertar un ticket
--INSERT INTO TICKETS VALUES ('8489EAU','04/11/10 18:48:01,020000', 'S', NULL, NULL, SYSDATE, NULL, NULL, '30','97201505D','R');
--INSERT INTO TICKETS VALUES ('9861AUO','13/01/11 05:57:33,510000', 'S', NULL, NULL, SYSDATE, NULL, NULL, '30','76150280V','R');

			------ Alegación en la que el nuevo deudor no es conductor
--INSERT INTO ALLEGATIONS VALUES('8489EAU', '04/11/10 18:48:01,020000', 'S', SYSDATE, '50774649X', 'U', NULL);

		------ Alegación en la que el nuevo deudor es conductor
--INSERT INTO ASSIGNMENTS VALUES ('22117400W', '9861AUO');
--INSERT INTO ALLEGATIONS VALUES('9861AUO', '13/01/11 05:57:33,510000', 'S', SYSDATE, '22117400W', 'U', NULL);
--INSERT INTO ASSIGNMENTS VALUES ('97201505D', '9861AUO');
--INSERT INTO ALLEGATIONS VALUES('9861AUO', '13/01/11 05:57:33,510000', 'S', SYSDATE, '97201505D', 'U', NULL);

    ------ Alegación en la que el nuevo deudor es conductor pero ya ha alegado previamente
--INSERT INTO ALLEGATIONS VALUES('9861AUO', '13/01/11 05:57:33,510000', 'S', SYSDATE, '22117400W', 'U', NULL);

--------------------------------- TRIGGER C----------------------------------------
---------- Nuevo conductor habitual cuando el actual fallece para que el atributo no se quede a nulo

CREATE OR REPLACE TRIGGER aReyMuerto
BEFRORE UPDATE OF REG_DRIVER ON VEHICLES
	DECLARE
		IF re












--------------------------------- TRIGGER D----------------------------------------
-------------- RESTRICCIONES

-- TRIGGER CONTROL DE LA VELOCIDAD DE LOS RADARES

CREATE OR REPLACE TRIGGER NoInsertesRadar
	BEFORE INSERT OR UPDATE ON RADARS
		FOR EACH ROW

			DECLARE
			speedRadar NUMBER;
			speedRoad NUMBER;

			BEGIN
					speedRadar := :NEW.speedlim;
					select speed_limit into speedRoad from ROADS where name= :NEW.road;
				IF speedRadar >= speedRoad THEN
					RAISE_APPLICATION_ERROR(-20001, 'La velocidad del radar debe ser inferior a la general');
				END IF;

			END;
/
-------------------Velocidad adecuada ---------------------
--INSERT INTO RADARS VALUES ('A4','0','ASC','0');

-------------------Velocidad inadeucada ---------------------
--INSERT INTO RADARS VALUES ('A4','0','ASC','200');

-- TRIGGER CONTROL DE QUE LOS CONDUCTORES SEAN MAYORES DE EDAD

CREATE OR REPLACE TRIGGER NoInsertesConductor
	BEFORE INSERT ON DRIVERS
	FOR EACH ROW

		DECLARE
		cumple DATE;
		edad number;

		BEGIN
				select birthdate into cumple from persons where DNI = :NEW.dni;
				edad := TRUNC(MONTHS_BETWEEN(SYSDATE, cumple))/12;

				IF edad < 18 THEN
					RAISE_APPLICATION_ERROR(-20002, 'La edad del conductor debe ser superior a 18 años');
				END IF;
	END;
/

-------------- Mayor de edad ----------------------
--INSERT INTO PERSONS VALUES('1', 'Pablito', 'apellido1', 'apellido2', 'dir', 'ciudad', '123', 'blabla@bla','16/04/00');
--INSERT INTO DRIVERS VALUES ('1', '16/04/00', 'A');

-------------- Menor de edad ----------------------
--INSERT INTO PERSONS VALUES('2', 'Isabella', 'apellido1', 'apellido2', 'dir', 'ciudad', '123', 'blabla@bla','14/04/08');
--INSERT INTO DRIVERS VALUES ('2', '16/04/00', 'A');
