CREATE OR REPLACE PROCEDURE sancionesPorDia(fecha DATE) IS

  cursor cursor1 is
    SELECT nPlate,odatetime
    FROM OBSERVATIONS
    WHERE TRUNC(odatetime) like TO_DATE(fecha, 'DD-MM-YYYY');

  amountVelMax NUMBER;
  amountVelTramo NUMBER;
  amountDist NUMBER;
  dueno VARCHAR(9);
  obsAnterior OBSERVACION;

    BEGIN
        obsAnterior := OBSERVACION(NULL, NULL, NULL, NULL, NULL, NULL);

      FOR obs in cursor1
        LOOP
          obsAnterior := paquete.ObservacionAnterior(obs.nPlate, obs.odatetime);
          select owner into dueno from vehicles where nPlate = obs.nPlate;
          amountVelMax := paquete.calculoVelMax(obs.nPlate, obs.odatetime);
          amountVelTramo := paquete.calculoVelTramo(obs.nPlate,obs.odatetime);
          amountDist := paquete.calculoSancionDistancia(obs.nplate, obs.odatetime);
          
        --INSERCION EN TABLA TICKETS
        IF amountVelMax > 0
        THEN
        INSERT INTO TICKETS VALUES(obs.nPlate,obs.odatetime,'S',NULL,NULL,SYSDATE,NULL,NULL,amountVelMax,dueno, 'R');
        END IF;

        IF amountvelTramo > 0
        THEN
        INSERT INTO TICKETS VALUES(obs.nPlate,obsAnterior.odatetime,'T',obs.nPlate,obs.odatetime,SYSDATE,NULL,NULL,amountVelTramo,dueno, 'R');
        END IF;

        IF amountDist > 0
        THEN
        INSERT INTO TICKETS VALUES(obs.nPlate,obs.odatetime,'D',obsAnterior.nPlate,obsAnterior.odatetime,SYSDATE,NULL,NULL,amountDist,dueno, 'R');
        END IF;

      END LOOP;

    END;
/
