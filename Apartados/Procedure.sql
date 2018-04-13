CREATE OR REPLACE PROCEDURE sancionesPorDia(fecha DATE) AS
  amountVelMax NUMBER(3);
  amountVelTramo NUMBER(3);
  amountDist NUMBER(3);
  dueno VARCHAR(9);
     BEGIN
          FOR cursor1 IN (SELECT * FROM OBSERVATIONS WHERE odatetime = fecha)
          LOOP
            select owner into dueno from vehicles where nPlate = cursor1.nPlate;
            amountVelMax := calculoVelMax(cursor1.nPlate, fecha);
            --amountVelTramo := calculoVelTramo(cursor1.nPlate, cursor1., tiempo2 IN TIMESTAMP)
            amountDist := calculoSancionDistancia(cursor1.nplate, fecha);

            IF amountVelMax > 0
            THEN
              --INSERT into TICKETS values (cursor1.nPlate,fecha,'S',NULL,NULL,SYSDATE,NULL,NULL,amountVelMax,dueno,'R');

              MERGE INTO TICKETS T
              USING(SELECT obs1_veh, obs1_date, tik_type from TICKETS WHERE obs1_date = cursor1.odatetime) S
              ON(obs1_veh = T.obs1_veh AND obs1_date = cursor1.odatetime and tik_type = T.tik_type)
              WHEN MATCHED THEN UPDATE SET amount = amountVelMax
              WHEN NOT MATCHED THEN
              INSERT VALUES (cursor1.nPlate,cursor1.odatetime,'S',NULL,NULL,SYSDATE,NULL,NULL,amountVelMax,dueno,'R');

              COMMIT;
            END IF;

            IF amountDist > 0
            THEN
              INSERT into TICKETS values (cursor1.nPlate,cursor1.odatetime,'D',NULL,NULL,SYSDATE,NULL,NULL,amountDist,dueno,'R');
              COMMIT;
            END IF;

          END LOOP;
     END;
        /
