
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
    FOR EACH ROW
    DECLARE
      amountVelMax NUMBER(3);
      amountVelTramo NUMBER(3);
      amountDist NUMBER(3);
      obsAnterior OBSERVACION;

    BEGIN

        obsAnterior := OBSERVACION(NULL, NULL, NULL, NULL, NULL, NULL);
        obsAnterior := ObservacionAnterior(:NEW.nPlate, :NEW.odatetime);
        amountVelMax := calculoVelMax(:NEW.nPlate, :NEW.odatetime);
        amountVelTramo := calculoVelTramo(:NEW.nPlate, obsAnterior.odatetime, :NEW.odatetime);
        amountDist := calculoSancionDistancia(:NEW.nplate, :NEW.odatetime);


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
