#World Life Expectancy Project (Data Cleaning)


SELECT * 
FROM world_life_expectancy
;

#Removing Duplicates

SELECT Country, Year, CONCAT(Country,Year), COUNT(CONCAT(Country,Year))
FROM world_life_expectancy
GROUP BY Country, Year, CONCAT(Country,Year)
HAVING COUNT(CONCAT(Country,Year)) > 1
;
SELECT *
	FROM(
		SELECT Row_ID, 
		CONCAT(Country,Year),
		ROW_NUMBER() OVER(PARTITION BY CONCAT(Country,Year) ORDER BY CONCAT(Country,Year)) AS Row_Num
		FROM world_life_expectancy
	) AS Row_Table
WHERE Row_Num > 1
;

DELETE FROM  world_life_expectancy
WHERE 
	Row_ID IN (
    SELECT Row_ID
	FROM(
		SELECT Row_ID, 
		CONCAT(Country,Year),
		ROW_NUMBER() OVER(PARTITION BY CONCAT(Country,Year) ORDER BY CONCAT(Country,Year)) AS Row_Num
		FROM world_life_expectancy
	) AS Row_Table
WHERE Row_Num > 1
    )
;
#Now duplicates are removed
 
 SELECT * 
FROM world_life_expectancy
WHERE Status = ''
;

SELECT DISTINCT(Status)
FROM world_life_expectancy
WHERE Status <> ''
;

SELECT DISTINCT(Country)
FROM world_life_expectancy
WHERE Status = 'Developing'
;

UPDATE world_life_expectancy 
SET Status = 'Developing'
WHERE Country IN ( SELECT DISTINCT(Country)
					FROM world_life_expectancy
					WHERE Status = 'Developing');

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
ON t1.Country = t2.Country
SET t1.Status = 'Developing'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developing'
;

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
ON t1.Country = t2.Country
SET t1.Status = 'Developed'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developed'
;

#Now to check if all dupicates are successfully removed
 SELECT * 
FROM world_life_expectancy
WHERE Status = ''
; #They are, yay!

#What about for NULL: 
 SELECT * 
FROM world_life_expectancy
WHERE Status IS NULL
; #Same :)

#Now to work on Life expectancy
 SELECT * 
FROM world_life_expectancy
WHERE `Life expectancy` = ''
;

 SELECT Country, Year, `Life expectancy`
FROM world_life_expectancy
WHERE `Life expectancy` = ''
;

 SELECT t1.Country, t1.Year, t1.`Life expectancy`,
 t2.Country, t2.Year, t2.`Life expectancy`,
 t3.Country, t3.Year, t3.`Life expectancy`,
 ROUND((t2.`Life expectancy`+t3.`Life expectancy`)/2,1)
FROM world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
    AND t1.YEAR = t2.Year-1
JOIN world_life_expectancy t3
	ON t1.Country = t3.Country
    AND t1.YEAR = t3.Year+1
    WHERE t1.`Life expectancy` = ''
;

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
    AND t1.YEAR = t2.Year-1
JOIN world_life_expectancy t3
	ON t1.Country = t3.Country
    AND t1.YEAR = t3.Year+1
SET t1.`Life expectancy` = ROUND((t2.`Life expectancy`+t3.`Life expectancy`)/2,1)
WHERE t1.`Life expectancy`=''
;

 SELECT * 
FROM world_life_expectancy
#WHERE `Life expectancy` = ''
; #We are good to go

#-----------------------------------------------------------------------------

#Part 2: World Life Expectancy Project (Exploratory Data Analysis)

SELECT * 
FROM world_life_expectancy
;

SELECT Country, MIN(`Life expectancy`), 
MAX(`Life expectancy`),
ROUND(MAX(`Life expectancy`) - MIN(`Life expectancy`),1) AS Life_Increase_15_Years
FROM world_life_expectancy
GROUP BY Country
HAVING MIN(`Life expectancy`) <> 0
AND MAX(`Life expectancy`) <> 0
Order by Life_Increase_15_Years ASC
;


SELECT Year, ROUND(AVG(`Life expectancy`),2)
FROM world_life_expectancy
WHERE `Life expectancy` <> 0
AND `Life expectancy` <> 0
GROUP BY Year 
ORDER BY Year 
;

SELECT * 
FROM world_life_expectancy
;

SELECT Country, ROUND(AVG(`Life expectancy`),1) AS Life_Exp , ROUND(AVG(GDP),1) AS GDP
FROM world_life_expectancy
GROUP BY Country
HAVING Life_Exp >0 AND GDP > 0
ORDER BY GDP DESC
;

SELECT  
SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END) High_GDP_Count,
ROUND(AVG(CASE WHEN GDP >= 1500 THEN `Life expectancy`ELSE NULL END),1) High_GDP_Life_Expectancy,
SUM(CASE WHEN GDP <= 1500 THEN 1 ELSE 0 END) Low_GDP_Count,
ROUND(AVG(CASE WHEN GDP <= 1500 THEN `Life expectancy`ELSE NULL END),1) Low_GDP_Life_Expectancy
FROM world_life_expectancy
;

# Life Expectancy against Status

SELECT *
FROM world_life_expectancy
;

SELECT Status, ROUND(AVG(`Life expectancy`),1)
FROM world_life_expectancy
GROUP BY Status
;


SELECT Status, COUNT(DISTINCT Country) #ROUND(AVG(`Life expectancy`),1)
FROM world_life_expectancy
GROUP BY Status #But status is skwed so affects avaerage
;

SELECT Status, COUNT(DISTINCT Country), ROUND(AVG(`Life expectancy`),1)
FROM world_life_expectancy
GROUP BY Status #But status is skwed so affects avaerage
;



SELECT *
FROM world_life_expectancy
;
# Life Expectancy against BMI
SELECT Country, ROUND(AVG(`Life expectancy`),1) AS Life_Exp , ROUND(AVG(BMI),1)  BMI
FROM world_life_expectancy
GROUP BY Country
HAVING Life_Exp >0 
AND BMI > 0
ORDER BY BMI ASC
;

# Life Expectancy against Adult Mortality

SELECT *
FROM world_life_expectancy
;


SELECT Country, 
		Year, 
        `Life expectancy`, 
        `Adult Mortality`,
        SUM(`Adult Mortality`) OVER(PARTITION BY Country ORDER BY Year) Rolling_total
FROM world_life_expectancy
WHERE Country LIKE '%United%'
;



