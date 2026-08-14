#World Life Expentency Project - Data Cleaning

select *
from world_life_expectancy;

select Country, Year, concat(Country, Year), Row_ID, (concat(Country, Year)) 
from world_life_expectancy
Group by Country, Year, concat(Country, Year) 
having count(concat(Country, Year)) > 1
;

# Identifying dupliacte rows to be deleted
Select *
FROM(
select Row_ID, concat(Country, Year),
ROW_NUMBER() OVER(PARTITION BY concat(Country, Year) ORDER BY concat(Country, Year)) as Row_Num
from world_life_expectancy) as Row_Table
where Row_Num > 1
;

#Deleting duplicate rows from Table
Delete From world_life_expectancy
where 
Row_ID IN ( 
select Row_ID
from ( select Row_ID,
concat(Country, Year),
ROW_NUMBER() OVER(PARTITION BY concat(Country, Year) ORDER BY concat(Country, Year)) as Row_Num
from world_life_expectancy 
) as Row_Table
where Row_Num > 1 )
;
#------------------------

#Checking for null Statuses
select *
from world_life_expectancy
where Status='';

select distinct(Status)
from world_life_expectancy
where Status!='';

select distinct(country)
from world_life_expectancy
where Status='Developing'
;

Update world_life_expectancy
set status = 'Developing'
where Country IN ( select distinct(country)
						from world_life_expectancy
						where Status='Developing'
);

Update world_life_expectancy t1
join world_life_expectancy t2
	on t1.Country=t2.Country
    set t1.Status='Developing'
    where t1.Status = ''
    and t2.Status != ''
    and t2.Status= 'Developing' 
;

Update world_life_expectancy t1
join world_life_expectancy t2
	on t1.Country=t2.Country
    set t1.Status='Developed'
    where t1.Status = ''
    and t2.Status != ''
    and t2.Status= 'Developed' 
;

# Check for no more null values
select *
from world_life_expectancy
where Status is NULL;

select *
from world_life_expectancy
where `Life expectancy`='';

Select t1.Country, t1.Year, t1.`Life expectancy`,
t2.Country, t2.Year, t2.`Life expectancy`,
t3.Country, t3.Year, t3.`Life expectancy`,
Round((t2.`Life expectancy` + t3.`Life expectancy`)/2,1)
from world_life_expectancy t1
join world_life_expectancy t2
on t1.Country = t2.Country
and t1.Year=t2.Year-1
join world_life_expectancy t3
on t1.Country = t3.Country
and t1.Year=t3.Year+1
where t1.`Life expectancy`= ''
;

# Populating blank Life Expectancy Values
Update world_life_expectancy t1
join world_life_expectancy t2
on t1.Country = t2.Country
and t1.Year=t2.Year-1
join world_life_expectancy t3
on t1.Country = t3.Country
and t1.Year=t3.Year+1
set t1.`Life expectancy`= Round((t2.`Life expectancy` + t3.`Life expectancy`)/2,1)
where t1.`Life expectancy`= '';

#Checking data is populated
select Country, Year, `Life Expectancy`
from world_life_expectancy;

#-------------------------------------- 
#--------------------------------------- Exploratory Data Analysis
#---------------------------------------

select * 
from world_life_expectancy
;

select Country, min(`Life expectancy`), max(`Life expectancy`)
from world_life_expectancy
GROUP BY Country
Having min(`Life expectancy`) != 0 and max(`Life expectancy`) != 0
order by Country DESC
;

select Country, min(`Life expectancy`), max(`Life expectancy`), 
round(max(`Life expectancy`)-min(`Life expectancy`),1) as Life_Increase_15_years
from world_life_expectancy
GROUP BY Country
Having min(`Life expectancy`) != 0 and max(`Life expectancy`) != 0
order by Life_Increase_15_years DESC
;

# Average Life Expectancy Across all countries
select Year, round(AVG(`Life expectancy`),1)
from world_life_expectancy
GROUP BY Year
Having min(`Life expectancy`) != 0 and max(`Life expectancy`) != 0
order by Year
;

# Correlation between LE and all othe columns
Select Country, 
ROUND(AVG(`Life expectancy`),1) AS Life_Exp, 
round(avg(GDP),1) as GDP
from world_life_expectancy
GROUP BY Country
Having Life_Exp > 0 and GDP  >0
order by GDP asc
;
# use Tablue Visualization for corralation

# Using Case Statements to categorize on LE and GDP
SELECT
sum(case 
	when GDP >= 1500 then 1 else 0
end) High_GDP_Count
from world_life_expectancy
order by GDP;
# answer is 1326 rows where countries gdp>1500

# Contrsasting High vs Low LE with GDP
SELECT
sum(case when GDP >= 1500 then 1 else 0 end) High_GDP_Count,
    round(avg(case when GDP >= 1500 then `Life expectancy` else null end),1)
    High_GDP_LE,
sum(case when GDP <= 1500 then 1 else 0 end) Low_GDP_Count,
    round(avg(case when GDP <= 1500 then `Life expectancy` else null end),1)
    Low_GDP_LE    
from world_life_expectancy
order by GDP;
#Result: It can be seen that countries with high GDP have higher 
# Life Expectancy rates. So to some degree we can say that GDP & LE
# are positvely correlated. 

# Lets check LE by Status, we expect Developed to have higher LE
Select Status, round(avg(`Life expectancy`),1)
from world_life_expectancy
GROUP BY Status
;

#Since average is location dependent, then we can't rely on it. Lets check the number of countires. 
Select Status, count(distinct country), round(avg(`Life expectancy`),1)
from world_life_expectancy
GROUP BY Status
;

#bmi
Select Country, 
ROUND(AVG(`Life expectancy`),1) AS Life_Exp, 
round(avg(BMI),1) as BMI
from world_life_expectancy
GROUP BY Country
Having Life_Exp > 0 and BMI  >0
order by BMI DESC
;

#Rolling totals
SELECT Country, 
Year,
`Life expectancy`,
`Adult Mortality`,
sum( `Adult Mortality`) 
over(PARTITION BY Country order by Year) as Rolling_Total
from world_life_expectancy
where Country like '%United%'
;
# This data does not have total population with which we can compare 
# Adult Morality and Life Expectancy to