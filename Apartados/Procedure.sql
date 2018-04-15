CREATE OR REPLACE PROCEDURE sancionesPorDia(fecha DATE) AS
  amountVelMax NUMBER(3);
  amountVelTramo NUMBER(3);
  amountDist NUMBER(3);
  dueno VARCHAR(9);
  obsAnterior OBSERVACION;

    BEGIN

    FOR cursor1 IN (SELECT * FROM OBSERVATIONS WHERE CAST(odatetime AS DATE) = fecha)
      LOOP
          obsAnterior := paquete.ObservacionAnterior(cursor1.nPlate, cursor1.odatetime);
          select owner into dueno from vehicles where nPlate = cursor1.nPlate;

          amountVelMax := calculoVelMax(cursor1.nPlate, cursor1.odatetime);
          amountVelTramo := calculoVelTramo(cursor1.nPlate, obsAnterior.odatetime, cursor1.odatetime);
          amountDist := calculoSancionDistancia(cursor1.nplate, cursor1.odatetime);
          DBMS_OUTPUT.PUT_LINE('Insertando ticket por Vel Max...');
          DBMS_OUTPUT.PUT_LINE('Insertando ticket por Vel Max...');
          DBMS_OUTPUT.PUT_LINE('Insertando ticket por Vel Max...');


        IF amountVelMax > 0
        THEN
        DBMS_OUTPUT.PUT_LINE('Insertando ticket por Vel Max...');
        INSERT INTO TICKETS VALUES(cursor1.nPlate,cursor1.odatetime,'S',NULL,NULL,SYSDATE,NULL,NULL,amountVelMax,dueno, 'R');
        END IF;

        IF amountvelTramo > 0
        THEN
        DBMS_OUTPUT.PUT_LINE('Insertando ticket por Vel Tramo...');
        INSERT INTO TICKETS VALUES(cursor1.nPlate,obsAnterior.odatetime,'T',cursor1.nPlate,cursor1.odatetime,SYSDATE,NULL,NULL,amountVelTramo,dueno, 'R');
        END IF;

        IF amountDist > 0
        THEN
        DBMS_OUTPUT.PUT_LINE('Insertando ticket por distancia...');
        INSERT INTO TICKETS VALUES(cursor1.nPlate,cursor1.odatetime,'D',obsAnterior.nPlate,obsAnterior.odatetime,SYSDATE,NULL,NULL,amountDist,dueno, 'R');
        END IF;
        commit;

      END LOOP;
    END;
/

-- call sancionespordia('');
multa por velMax
insert into OBSERVATIONS values ('0861EUI','23/10/11 15:56:27,300000','M45',10,'ASC',160);

Multa por VelTramo
insert into OBSERVATIONS values ('0583EAA','23/10/11 15:54:27,300000','M45',10,'ASC',70);
insert into OBSERVATIONS values ('0583EAA','23/10/11 15:54:29,300000','M45',15,'ASC',70);


Multa por distancia
insert into OBSERVATIONS values ('0583EAA','23/10/11 08:53:27,300000','M45',17,'ASC',160);
insert into OBSERVATIONS values ('0861EUI','23/10/11 08:53:27,580000','M45',17,'ASC',160);





