#US Household Income Data Cleaning

SELECT *
FROM us_project.us_household_income;

SELECT *
FROM us_project.us_household_income_statistics;

#-----

SELECT id, count(id)
FROM us_project.us_household_income
GROUP BY ID
Having count(id) >1;

DELETE FROM us_household_income
WHERE row_id IN (
		SELECT row_id
		FROM(
				SELECT row_id, 
				id, 
				ROW_NUMBER() OVER(PARTITION BY ID ORDER BY ID) row_num
				FROM us_household_income ) AS duplicates
		WHERE row_num > 1)
    ;
 
 #CHECKING FOR DUPLICATES IN STATS TABLE
    SELECT id, count(id)
FROM us_project.us_household_income_statistics
GROUP BY ID
Having count(id) >1; # NO DUPLICATES, WE ARE GOOD TO GO!


#FIXING OTHER ISSUES 

SELECT DISTINCT State_Name #COUNT(State_Name)
FROM us_project.us_household_income
GROUP BY State_Name
ORDER BY 1;

UPDATE us_project.us_household_income
SET State_Name = 'Georgia'
WHERE State_Name = 'georia';

UPDATE us_project.us_household_income
SET State_Name = 'Alabama'
WHERE State_Name = 'alabama';

#STATE ABRV
SELECT  *
FROM us_project.us_household_income
WHERE COUNTY='Autauga County'
ORDER BY 1
;

UPDATE us_project.us_household_income
SET PLACE = 'Autaugaville'
WHERE COUNTY='Autauga County'
and City = 'Vinemont';

#CORRECTING FOR TYPE COLUMN
SELECT  Type, COUNT(tYPE)
FROM us_project.us_household_income
group BY 1;

UPDATE us_project.us_household_income
SET Type = 'Borough'
WHERE Type = 'Boroughs';


#CHECKING CORRECTING FOR ALAND & AWATER COLUMN
SELECT  ALAND, AWATER
FROM us_project.us_household_income
WHERE AWATER = 0 OR AWATER = '' OR AWATER IS NULL
; #THINGS SEEM FINE

#------------------------------------------------------------------
#------------------------------------------------------------------


#PART 2 : US Household Income Exploratory Data Analysis

SELECT *
FROM us_project.us_household_income;

SELECT *
FROM us_project.us_household_income_statistics;

#LARGEST 10 BY LAND
SELECT State_Name, SUM(ALand), sum(AWater)
FROM us_project.us_household_income
GROUP BY State_Name
ORDER BY 2 DESC
LIMIT 10; 

#LARGEST 10 BY WATER AREA
SELECT State_Name, SUM(ALand), sum(AWater)
FROM us_project.us_household_income
GROUP BY State_Name
ORDER BY 3 DESC
LIMIT 10; 


SELECT *
FROM us_project.us_household_income u
JOIN us_project.us_household_income_statistics us
ON u.id=us.id;

SELECT *
FROM us_project.us_household_income u
INNER JOIN us_project.us_household_income_statistics us
ON u.id=us.id
WHERE Mean <> 0 #Some governments do not report to higher up governments
; #CLEANED DATA 

SELECT u.State_Name, ROUND(AVG(Mean),1), ROUND(AVG(Median),1)# County, Type, `Primary`, 
FROM us_project.us_household_income u
INNER JOIN us_project.us_household_income_statistics us
ON u.id=us.id
WHERE Mean <>0
GROUP BY u.State_Name
ORDER BY 3 DESC
LIMIT 10
;

SELECT Type,COUNT(Type), ROUND(AVG(Mean),1), ROUND(AVG(Median),1)  
FROM us_project.us_household_income u
INNER JOIN us_project.us_household_income_statistics us
ON u.id=us.id
WHERE Mean <>0
GROUP BY 1
HAVING COUNT(Type) > 100
ORDER BY 4 DESC
LIMIT 20
; 

SELECT *
FROM us_project.us_household_income
WHERE Type = 'Community'
;

SELECT u.State_Name, city, ROUND(AVG(Mean),1),ROUND(AVG(Median),1)
FROM us_project.us_household_income u
JOIN us_project.us_household_income_statistics us
ON u.id=us.id
GROUP BY u.State_Name, city 
ORDER BY ROUND(AVG(Mean),1) DESC;
