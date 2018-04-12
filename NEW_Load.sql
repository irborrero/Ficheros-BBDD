-- ----------------------------------------------------
-- -- Part III: Populate tables by querying old ones --
-- ----------------------------------------------------


INSERT INTO CATALOG(make,model,power) 
   SELECT make, model, MIN(TO_NUMBER(power,'9999')) 
      FROM gotcha
      GROUP BY (make,model);  
-- Problem: there were several 'power' values for some 'make'&'model'
-- Implicit assumption: in case that occurs, minimum value should be taken
-- 110 rows 


INSERT INTO PERSONS (DNI,name,surn_1,surn_2,address,town,mobile,email,birthdate) 
   (SELECT DISTINCT owner_DNI,owner_name,owner_surn1,owner_surn2,owner_address,owner_town,
                    owner_mobile,owner_email, to_date(owner_birth, 'YYYY-MM-DD') 
       FROM gotcha
    UNION
    SELECT DISTINCT driver_DNI,driver_name,driver_surn1,driver_surn2,driver_address,driver_town,
                    driver_mobile,driver_email, to_date(driver_birth, 'YYYY-MM-DD') 
       FROM gotcha
    );  
-- 248 ROWS


INSERT INTO DRIVERS (DNI,lic_date,lic_type)
   SELECT DISTINCT driver_DNI,TO_DATE(license_date,'YYYY-MM-DD'), driver_license FROM gotcha;
-- 207 ROWS


INSERT INTO VEHICLES (nPlate,vin,make,model,color,reg_date,MOT_date,reg_driver,owner)
   SELECT DISTINCT nPlate,VIN,make,model,color,TO_DATE(reg_date,'YYYY-MM-DD'),
                   TO_DATE(MOT_date,'YYYY-MM-DD'),driver_DNI,owner_DNI 
      FROM gotcha;
-- 250 ROWS

   
INSERT INTO ASSIGNMENTS (driver, nPlate)
   SELECT DISTINCT driver_DNI,nPlate FROM gotcha
-- WHERE driver_DNI IS NOT NULL
   MINUS 
   SELECT reg_driver,nPlate FROM VEHICLES;
-- 0 ROWS


INSERT INTO ROADS (name,speed_limit) 
   SELECT DISTINCT road, speed_limit FROM gotcha; 
-- 10 ROWS


INSERT INTO RADARS (road,Km_point,direction,speedlim)
   SELECT road, Km_point, direction, MIN(radar_speedlim) 
      FROM gotcha 
      GROUP BY (road,Km_point,direction);  
-- Problem: there were several 'speed_limit' values for some radars
-- Implicit assumption: in case that occurs, minimum speed_limit will be taken
-- 150 ROWS


INSERT INTO OBSERVATIONS (nPlate,odatetime,road,km_point,direction,speed)
   SELECT DISTINCT nPlate, TO_TIMESTAMP(date1||time1,'YYYY-MM-DDHH24:MI:SS.FF2'), road, Km_point, direction, speed 
      FROM gotcha;
--50.000 ROWS
