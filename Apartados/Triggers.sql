
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


create or replace trigger insertarMulta
  AFTER insert on OBSERVATIONS
    FOR EACH STATEMENT
    DECLARE
      amountVelMax NUMBER(3);
      amountVelTramo NUMBER(3);
      amountDist NUMBER(3);
      obsAnterior OBSERVACION;

    BEGIN

        obsAnterior := OBSERVACION(NULL, NULL, NULL, NULL, NULL, NULL);
        obsAnterior := ObservacionAnterior(:NEW.nPlate, :NEW.odatetime);
        --amountVelMax := calculoVelMax(:NEW.nPlate, :NEW.odatetime);
        --amountVelTramo := calculoVelTramo(:NEW.nPlate, obsAnterior.odatetime, :NEW.odatetime);
        --amountDist := calculoSancionDistancia(:NEW.nplate, :NEW.odatetime);


      DBMS_OUTPUT.PUT_LINE(amountVelMax || amountVelTramo || amountDist);
    END;

  /


  create or replace trigger insertarMulta
    FOR insert on OBSERVATIONS
      COMPOUND TRIGGER

        amountVelMax NUMBER(3);
        amountVelTramo NUMBER(3);
        amountDist NUMBER(3);
        obsAnterior OBSERVACION;
        -- Se lanzará después de cada fila actualizada
      BEFORE EACH ROW IS
      BEGIN
          obsAnterior := OBSERVACION(NULL, NULL, NULL, NULL, NULL, NULL);
          obsAnterior := paquete.ObservacionAnterior(:NEW.nPlate, :NEW.odatetime);
          amountVelMax := paquete.calculoVelMax(:NEW.nPlate, :NEW.odatetime);
          amountVelTramo := paquete.calculoVelTramo(:NEW.nPlate, obsAnterior.odatetime, :NEW.odatetime);
          amountDist := paquete.calculoSancionDistancia(:NEW.nplate, :NEW.odatetime);
      END BEFORE EACH ROW;

      AFTER EACH ROW IS
        DBMS_OUTPUT.PUT_LINE(amountVelMax || amountVelTramo || amountDist);

      END AFTER EACH ROW;

      END insertarMulta;
    /




    create or replace trigger insertarMulta FOR
      insert on OBSERVATIONS
        COMPOUND TRIGGER

          amountVelMax NUMBER(3);
          amountVelTramo NUMBER(3);
          amountDist NUMBER(3);
          obsAnterior OBSERVACION;


        AFTER EACH ROW IS
          BEGIN
            obsAnterior := OBSERVACION(NULL, NULL, NULL, NULL, NULL, NULL);
            obsAnterior := paquete.ObservacionAnterior(:OLD.nPlate, :OLD.odatetime);
            amountVelMax := paquete.calculoVelMax(:OLD.nPlate, :OLD.odatetime);
            amountVelTramo := paquete.calculoVelTramo(:OLD.nPlate, obsAnterior.odatetime, :OLD.odatetime);
            amountDist := paquete.calculoSancionDistancia(:OLD.nplate, :OLD.odatetime);
              DBMS_OUTPUT.PUT_LINE(amountVelMax || amountVelTramo || amountDist);
          END AFTER EACH ROW;


    END insertarMulta;

      /


			CREATE OR REPLACE TRIGGER MULTITA
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
   		BEGIN
				obsAnterior := OBSERVACION(NULL, NULL, NULL, NULL, NULL, NULL);
				obsAnterior := paquete.ObservacionAnterior(obsInsertada.nPlate, obsInsertada.odatetime);

				amountVelMax := paquete.calculoVelMax(obsInsertada.nPlate, obsInsertada.odatetime);
				amountVelTramo := paquete.calculoVelTramo(obsInsertada.nPlate, obsAnterior.odatetime, obsInsertada.odatetime);
				amountDist := paquete.calculoSancionDistancia(obsInsertada.nPlate, obsInsertada.odatetime);

				DBMS_OUTPUT.PUT_LINE(amountVelMax || '-' || amountVelTramo||'-'||amountDist);

				select owner into dueno from vehicles where nPlate = obsInsertada.nPlate;

				IF amountVelMax > 0
				THEN
				DBMS_OUTPUT.PUT_LINE('Insertando ticket por Vel Max...');
				INSERT INTO TICKETS VALUES(obsInsertada.nPlate,obsInsertada.odatetime,'S',NULL,NULL,SYSDATE,NULL,NULL,amountVelMax,dueno, 'R');
				END IF;

				IF amountvelTramo > 0
				THEN
				DBMS_OUTPUT.PUT_LINE('Insertando ticket por Vel Tramo...');
				END IF;

				IF amountDist > 0
				THEN
				DBMS_OUTPUT.PUT_LINE('Insertando ticket por distancia...');
				END IF;

   		END AFTER STATEMENT;

END MULTITA;

/
