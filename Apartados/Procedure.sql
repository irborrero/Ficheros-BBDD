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
          
          DBMS_OUTPUT.PUT_LINE('odatetime: '||to_char(obs.odatetime,'MM-DD-YYYY'));

          obsAnterior := paquete.ObservacionAnterior(obs.nPlate, obs.odatetime);
          DBMS_OUTPUT.PUT_LINE('VELmAX: '||obsAnterior.nPlate);

          select owner into dueno from vehicles where nPlate = obs.nPlate;

          DBMS_OUTPUT.PUT_LINE(obs.nPlate);
          DBMS_OUTPUT.PUT_LINE(obs.odatetime);

          amountVelMax := paquete.calculoVelMax(obs.nPlate, obs.odatetime);
          DBMS_OUTPUT.PUT_LINE('VELmAX: '||amountVelMax);

          amountVelTramo := paquete.calculoVelTramo(obs.nPlate,obs.odatetime);
          DBMS_OUTPUT.PUT_LINE('VEL: '||amountVelTramo);

          DBMS_OUTPUT.PUT_LINE('HOLA PASO POR AQUI ');

          --amountDist := paquete.calculoSancionDistancia(obs.nplate, obs.odatetime);
          --DBMS_OUTPUT.PUT_LINE('DISTANCITA: '||amountDist);
        --INSERCION EN TABLA TICKETS
        IF amountVelMax > 0
        THEN
        DBMS_OUTPUT.PUT_LINE('Insertando ticket por Vel Max...');
        INSERT INTO TICKETS VALUES(obs.nPlate,obs.odatetime,'S',NULL,NULL,SYSDATE,NULL,NULL,amountVelMax,dueno, 'R');
        END IF;

        IF amountvelTramo > 0
        THEN
        DBMS_OUTPUT.PUT_LINE('Insertando ticket por Vel Tramo...');
        INSERT INTO TICKETS VALUES(obs.nPlate,obsAnterior.odatetime,'T',obs.nPlate,obs.odatetime,SYSDATE,NULL,NULL,amountVelTramo,dueno, 'R');
        END IF;

        IF amountDist > 0
        THEN
        DBMS_OUTPUT.PUT_LINE('Insertando ticket por distancia...');
        INSERT INTO TICKETS VALUES(obs.nPlate,obs.odatetime,'D',obsAnterior.nPlate,obsAnterior.odatetime,SYSDATE,NULL,NULL,amountDist,dueno, 'R');
        END IF;

      END LOOP;

    END;
/


CREATE OR REPLACE PROCEDURE PRUEBA(fecha DATE) IS

  cursor c1 is
     SELECT nPlate,speed
     FROM OBSERVATIONS
     WHERE TRUNC(odatetime) like TO_DATE(fecha, 'DD-MM-YYYY');

  BEGIN

  DBMS_OUTPUT.PUT_LINE(TO_DATE(fecha, 'DD-MM-YYYY'));

  FOR obs in c1
   
   LOOP
      INSERT INTO PRUEBA2 VALUES (obs.nplate, obs.speed);
   END LOOP;

  END;
/


-- call sancionespordia('');
--  EXEC SANCIONESPORDIA('23/10/11');
multa por velMax
insert into OBSERVATIONS values ('0861EUI','23/10/11 15:56:27,300000','M45',10,'ASC',160);

Multa por VelTramo
insert into OBSERVATIONS values ('0583EAA','23/10/11 15:54:27,300000','M45',10,'ASC',70);
insert into OBSERVATIONS values ('0583EAA','23/10/11 15:54:29,300000','M45',15,'ASC',70);


Multa por distancia
insert into OBSERVATIONS values ('0583EAA','23/10/11 08:53:27,300000','M45',17,'ASC',160);
insert into OBSERVATIONS values ('0861EUI','23/10/11 08:53:27,580000','M45',17,'ASC',160);





