
/*If there is a decreasing trend in winning bids, one might expect ISDs to use this fact. If you look at the order in which school districts
have their annual bid meetings, is there any change? Do we see ISDs holding their bid meetings later on and getting lower bids? */


/*This shows the number of times each district holds in let date in August*/
SELECT COUNTY, SYSTEM, COUNT(MONTH) as MONTHS,  SUM( CASE WHEN (MONTH>7) THEN 1 ELSE 0 END ) as LATE_BIDS
FROM milk
WHERE WIN  = 1
AND YEAR >= 1980
AND YEAR <= 1991
GROUP BY SYSTEM, COUNTY
ORDER BY COUNTY, SYSTEM


/*This shows the number of let dates in August by year as a percentage*/
WITH SEASON AS (SELECT YEAR, COUNT(MONTH) as MONTHS,  SUM( CASE WHEN (MONTH>7) THEN 1 ELSE 0 END ) as LATE_BIDS
FROM milk
WHERE WIN  = 1
AND YEAR >= 1980
AND YEAR <= 1991
GROUP BY YEAR)

SELECT YEAR, ROUND((1.0*LATE_BIDS)/MONTHS,2) AS PERCENT_AUG
FROM SEASON


/*Shows which month the low bids occur in by percentage (low is <.15) */
WITH SEASON AS (SELECT year, count(DISTINCT WW) as BIDS,
SUM(CASE WHEN (WW<.15) THEN 1 ELSE 0 END) as LOW_BIDS,
SUM(CASE WHEN (WW<.15 and MONTH = 5) THEN 1 ELSE 0 END) as LOW_MAY,
SUM(CASE WHEN (WW<.15 and MONTH = 6) THEN 1 ELSE 0 END) as LOW_JUNE,
SUM(CASE WHEN (WW<.15 and MONTH = 7) THEN 1 ELSE 0 END) as LOW_JULY,
SUM(CASE WHEN (WW<.15 and MONTH = 8) THEN 1 ELSE 0 END) as LOW_AUG
FROM milk
WHERE WIN  = 1
AND YEAR >= 1980 AND YEAR <= 1991
AND MONTH <> 0 AND DAY <> 0
GROUP BY YEAR
ORDER BY YEAR)

SELECT YEAR, ROUND(LOW_MAY/(LOW_BIDS*1.0),2) AS PERCENT_MAY,
ROUND(LOW_JUNE/(LOW_BIDS*1.0),2) AS PERCENT_JUNE,
ROUND(LOW_JULY/(LOW_BIDS*1.0),2) AS PERCENT_JULY,
ROUND(LOW_AUG/(LOW_BIDS*1.0),2) AS PERCENT_AUG
FROM SEASON

