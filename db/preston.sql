/* Please see when Preston first bids into DFW, where it has never been before. 
Document where it bid, the prices it bid, and what it won and lost.*/

/*prestons bids in the DFW area*/
SELECT SYSTEM, COUNTY, VENDOR, WW, WIN, YEAR, ESTQTY
FROM milk
WHERE VENDOR == "PRESTON" 
and FMOZONE == 1
and DAY <> 0
and WW <>''
GROUP BY ESC, SYSTEM, COUNTY, VENDOR, YEAR
ORDER BY YEAR, WIN, WW;


/* Then document it in succeeding years. Am I correct that it bid higher 
and lost most of what it won when it first entered?*/

/*isolate preston's market share in each year*/
SELECT YEAR, sum(WIN) as WINS,
count(WW), ROUND(sum(WW*WIN)/sum(WIN),5) as AVG_WW, ROUND(sum(ESTQTY*WIN),2) as QTY_SOLD
FROM milk
WHERE VENDOR == "PRESTON" 
and FMOZONE == 1
and WW <> ''
and DAY <> 0
GROUP BY YEAR
ORDER BY YEAR;

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


/* Then go through the lists of who bid into San Antonio form DFW and had not bid there previously. 
This would be the cross-market threat. Once Preston backed off in DFW, did this DFW seller 
stop submitting bids into San Antonio? */ 

/*districts that were taken by preston in the dallas market in 1985*/
SELECT SYSTEM, YEAR, VENDOR, WW, ESTQTY FROM milk
WHERE (SYSTEM = 'ARLINGTON'
OR SYSTEM = 'MOUNT VERNON'
OR SYSTEM = 'ALEDO')
AND WIN = 1
AND WW <>''
ORDER BY SYSTEM, YEAR

/*look at Preston's Incumbencies and look who it took*/
WITH incumbents2 as (WITH
outcomes as (select COUNTY, SYSTEM, VENDOR, YEAR, NUMWIN, WIN is not '' as WIN from tx_milk),
sum_wins as (select COUNTY, SYSTEM, sum(WIN) as SUM_WINS, count(YEAR) as NUMYEAR from outcomes group by COUNTY, SYSTEM),
ind_wins as (select COUNTY, SYSTEM, VENDOR, sum(WIN) as IND_WINS from outcomes group by SYSTEM, COUNTY, VENDOR)

SELECT A.COUNTY AS COUNTY, A.SYSTEM AS SYSTEM, VENDOR, SUM_WINS, 
IND_WINS, ind_wins/((sum_wins*1.0)) AS WIN_PERCENT, 
((ind_wins/(sum_wins*1.0))>=.3) AS I
FROM ind_wins as A, sum_wins as B
WHERE A.SYSTEM = B.SYSTEM
AND NUMYEAR>=5),

preston as (select * from incumbents2 
WHERE I = 1 and VENDOR = "VANDERVOORT"),

winners as (SELECT * from milk 
WHERE VENDOR <> "VANDERVOORT" AND WIN = 1
ORDER BY FMOZONE, SYSTEM, COUNTY, YEAR, WW)

SELECT A.SYSTEM, A.COUNTY, A.VENDOR, A.YEAR, A.WW, A.ESTQTY, B.IND_WINS, B.WIN_PERCENT
FROM winners as A, preston as B
WHERE A.COUNTY = B.COUNTY
AND A.SYSTEM = B.SYSTEM
AND A.WW <> ''
AND FMOZONE = 9
ORDER BY A.YEAR

/*Use this to find the strategic bids that disrupt the incumbent, improved version of the query above*/
WITH incumbents2 as (WITH
outcomes as (select COUNTY, SYSTEM, VENDOR, YEAR, NUMWIN, WIN is not '' as WIN from tx_milk),
sum_wins as (select COUNTY, SYSTEM, sum(WIN) as SUM_WINS, count(YEAR) as NUMYEAR from outcomes group by COUNTY, SYSTEM),
ind_wins as (select COUNTY, SYSTEM, VENDOR, sum(WIN) as IND_WINS from outcomes group by SYSTEM, COUNTY, VENDOR)

SELECT A.COUNTY AS COUNTY, A.SYSTEM AS SYSTEM, VENDOR, SUM_WINS, 
IND_WINS, ind_wins/((sum_wins*1.0)) AS WIN_PERCENT, 
((ind_wins/(sum_wins*1.0))>.5) AS I
FROM ind_wins as A, sum_wins as B
WHERE A.SYSTEM = B.SYSTEM
AND NUMYEAR>=5)

SELECT A.SYSTEM AS ISD, A.YEAR AS YEAR, B.VENDOR AS INCUMBENT, 
B.WIN_PERCENT AS INC_PERCENT,
A.VENDOR AS TURNOVER, A.WW AS TURNOVER_WW, A.ESTQTY AS TURNOVER_QTY
FROM milk as A, incumbents2 as B
WHERE A.COUNTY = B.COUNTY
AND A.SYSTEM = B.SYSTEM
AND A.VENDOR <> B.VENDOR
AND A.WW <> ''
AND (A.VENDOR = "BORDEN"
OR A.VENDOR = "CABELL"
OR A.VENDOR = "FOREMOST"
OR A.VENDOR = "OAK FARMS"
OR A.VENDOR = "PRESTON"
OR A.VENDOR = "SCHEPPS"
OR A.VENDOR = "VANDERVOORT")
AND A.WIN =1
AND B.I = 1
AND A.FMOZONE =9
ORDER BY A.SYSTEM, A.YEAR




