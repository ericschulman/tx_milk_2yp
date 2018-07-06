/* Please see when Preston first bids into DFW, where it has never been before. 
Document where it bid, the prices it bid, and what it won and lost.*/
SELECT SYSTEM, COUNTY, VENDOR, WW, WIN, YEAR, ESTQTY
FROM milk
WHERE VENDOR == "PRESTON" 
and FMOZONE == 1
and DAY <> 0
GROUP BY ESC, SYSTEM, COUNTY, VENDOR, YEAR
ORDER BY YEAR, WIN, WW;


/* Then document it in succeeding years. Am I correct that it bid higher 
and lost most of what it won when it first entered?*/
SELECT YEAR, sum(WIN) as WINS,
count(WW), ROUND(sum(WW*WIN)/sum(WIN),5) as AVG_WW, ROUND(sum(ESTQTY*WIN),2) as QTY_SOLD
FROM milk
WHERE VENDOR == "PRESTON" 
and FMOZONE == 1
and WW <> ''
and DAY <> 0
GROUP BY YEAR
ORDER BY YEAR;


/* Then go through the lists of who bid into San Antonio form DFW and had not bid there previously. 
This would be the cross-market threat. Once Preston backed off in DFW, did this DFW seller 
stop submitting bids into San Antonio? */ 

/*look at Preston's Incumbencies and look who it took*/
WITH preston as (select * from incumbents 
WHERE I = 1 and VENDOR = "PRESTON"),

winners as (SELECT * from milk 
WHERE VENDOR <> "PRESTON" AND WIN = 1
ORDER BY FMOZONE, SYSTEM, COUNTY, YEAR, WW)

SELECT A.SYSTEM, B.SYSTEM, A.COUNTY, A.VENDOR, A.YEAR, A.WW, A.ESTQTY
FROM winners as A, preston as B
WHERE A.COUNTY = B.COUNTY
AND A.SYSTEM = B.SYSTEM
AND A.WW <> ''
AND FMOZONE = 9
ORDER BY A.YEAR


/*districts that were taken by preston in the dallas market in 1985*/
SELECT SYSTEM, YEAR, VENDOR, WW, ESTQTY FROM milk
WHERE (SYSTEM = 'ARLINGTON'
OR SYSTEM = 'MOUNT VERNON'
OR SYSTEM = 'ALEDO')
AND WIN = 1
AND WW <>''
ORDER BY SYSTEM, YEAR


/*General market share SA and DA*/
SELECT FMOZONE, YEAR, 
SUM(WIN) as SYSTEMS, ROUND(AVG(WW),5) as AVG_PRICE, ROUND(SUM(ESTQTY),2) as MKT_SIZE
FROM milk
WHERE (FMOZONE = 1 or FMOZONE = 9)
AND YEAR >=1980 and YEAR<=1991
and WIN =1
and WW<>''
GROUP BY FMOZONE, YEAR
ORDER BY FMOZONE, YEAR