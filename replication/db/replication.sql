/*Query for calculating which school districts have incumbent vendors*/
CREATE VIEW incumbents AS
WITH
outcomes as (select COUNTY, SYSTEM, VENDOR, YEAR, NUMWIN, WIN is not '' as WIN from tx_milk),
sum_wins as (select COUNTY, SYSTEM, sum(WIN) as SUM_WINS, count(YEAR) as NUMYEAR from outcomes group by COUNTY, SYSTEM),
ind_wins as (select COUNTY, SYSTEM, VENDOR, sum(WIN) as IND_WINS from outcomes group by SYSTEM, COUNTY, VENDOR)

SELECT A.COUNTY AS COUNTY, A.SYSTEM AS SYSTEM, VENDOR, SUM_WINS, 
IND_WINS, ind_wins/((sum_wins*1.0)) AS WIN_PERCENT, 
((ind_wins/(sum_wins*1.0))>=.8) AS I
FROM ind_wins as A, sum_wins as B
WHERE A.SYSTEM = B.SYSTEM
AND NUMYEAR>=5;


/*Simplified table with all the important data and CORRECT let dates*/
create view milk as 
select rowid, SYSTEM, COUNTY, MRKTCODE, VENDOR, 
cast (substr(LETDATE,0,instr(LETDATE,'/')) as integer) AS MONTH,
cast(substr(LETDATE, instr(LETDATE,'/')+1 , instr(substr(LETDATE,instr(LETDATE,'/')+1),'/')-1) as integer) AS DAY,
1900 + YEAR as YEAR,
LFC, LFW, WW, WC, QLFC, QLFW, QWW, QWC, ESTQTY, QUANTITY, FMOZONE, DEL,
CASE ESC
 WHEN 'E' THEN 1
 WHEN 'F' THEN 0
 ELSE ''
 END ESC,
CASE COOLER
 WHEN 'Y' THEN 1
 WHEN 'N' THEN 0
 ELSE ''
 END COOLER,
 MILES,
WIN is not '' as WIN,
NUMSCHL, NUMWIN
from tx_milk;


/*query to calculate the BACKLOG*/
CREATE VIEW backlog AS

WITH passed as (SELECT A.*, SUM(B.ESTQTY*B.WIN) as PASSED
FROM milk as A
LEFT JOIN milk as B ON A.YEAR = B.YEAR
AND ( (A.MONTH > B.MONTH) OR (A.MONTH = B.MONTH AND A.DAY > B.DAY) )
GROUP BY A.rowid),

contracts as (SELECT A.*, SUM(B.ESTQTY*B.WIN) as CONTRACTS
FROM milk as A, milk as B
WHERE A.YEAR = B.YEAR
GROUP BY A.rowid),

commitments as (SELECT A.*, SUM(B.ESTQTY*B.WIN) as COMMITMENTS
FROM milk as A, milk as B
WHERE A.VENDOR = B.VENDOR
AND A.YEAR = B.YEAR
AND ( (A.MONTH > B.MONTH) OR (A.MONTH = B.MONTH AND A.DAY > B.DAY) )
GROUP BY A.rowid),

capacity as (SELECT VENDOR, max(contracts) as CAPACITY
FROM
(SELECT VENDOR, YEAR, SUM(ESTQTY*WIN) as contracts
from milk
GROUP BY VENDOR, YEAR)
GROUP BY VENDOR)

SELECT passed.*, CONTRACTS, COMMITMENTS, CAPACITY, (COMMITMENTS/CAPACITY - PASSED/CONTRACTS) AS BACKLOG
FROM passed
LEFT JOIN contracts on passed.rowid = contracts.rowid
LEFT JOIN commitments on passed.rowid = commitments.rowid
LEFT JOIN capacity on passed.vendor = capacity.vendor;


/*create view with number of competitors*/
create view num as 
select A.rowid, count(*) as NUM from milk as A, milk as B 
WHERE A.SYSTEM = B.SYSTEM
AND A.COUNTY = B.COUNTY
AND A.DAY = B.DAY
AND A.MONTH = B.MONTH
AND A.YEAR = B.YEAR
GROUP BY A.rowid;


/*milk_out with differential included*/
create view milk_out as 
select A.*, B.I as I, C.diff*.01 + D.price as FMO, E.num as N
from backlog as A
LEFT JOIN incumbents as B ON A.SYSTEM = B.SYSTEM
AND A.COUNTY = B.COUNTY
AND A.VENDOR = B.VENDOR
LEFT JOIN fmo_diff AS C on A.FMOZONE = C.FMOZONE
LEFT JOIN fmo_prices AS D on A.YEAR = D.YEAR and A.MONTH = D.MONTH
LEFT JOIN num AS E on A.rowid = E.rowid;


/*Generate the Data involved with Table 5*/
create view milk_out2 as 
select A.*, B.I as I, D.price as FMO, E.num as N
from backlog as A
LEFT JOIN incumbents as B ON A.SYSTEM = B.SYSTEM
AND A.COUNTY = B.COUNTY
AND A.VENDOR = B.VENDOR
LEFT JOIN fmo_prices AS D on A.YEAR = D.YEAR and A.MONTH = D.MONTH
LEFT JOIN num AS E on A.rowid = E.rowid;


/*focus on ISDs with data available in all years*/
CREATE VIEW complete_isd as  SELECT SYSTEM, COUNTY
FROM (select SYSTEM, COUNTY, count(DISTINCT YEAR) as YEARS
from milk
where  YEAR>=1980 AND YEAR <=1990
group by SYSTEM, COUNTY)
WHERE YEARS = 11;


/*Work in Progress*/

/*View with correct dates*/
SELECT 
rowid, SYSTEM, LETDATE, MRKTCODE, VENDOR,
cast (substr(LETDATE,0,instr(LETDATE,'/')) as integer) AS MONTH,
cast(substr(LETDATE, instr(LETDATE,'/')+1 , instr(substr(LETDATE,instr(LETDATE,'/')+1),'/')-1) as integer) AS DAY,
cast (substr(LETDATE, instr(LETDATE,'/')+ instr(substr(LETDATE,instr(LETDATE,'/')+1),'/') + 1 ) as integer)+60 AS YEAR
FROM tx_milk;


/*Querey for listing school districts with incumbent vendors*/
SELECT * FROM incumbents WHERE I>=1 ORDER BY county;


/*Query for identifying 'complete' observations. This allows panel data
methods to be applied if desired*/
SELECT SYSTEM, COUNTY, VENDOR,  ESC
FROM (
select SYSTEM, COUNTY, VENDOR,  ESC, count(DISTINCT YEAR) as YEARS, count(YEAR) as OBS
from milk
where ( YEAR>=1980 AND YEAR <=1990 )
AND (VENDOR = "BORDEN"
OR VENDOR = "CABELL"
OR VENDOR = "FOREMOST"
OR VENDOR = "OAK FARMS"
OR VENDOR = "PRESTON"
OR VENDOR = "SCHEPPS"
OR VENDOR = "VANDERVOORT")
group by ESC, SYSTEM, COUNTY, VENDOR)
WHERE (YEARS >= 5)
GROUP BY COUNTY, SYSTEM, VENDOR,  ESC


/*helpful for debugging milk out
also previous 'differential' adjusted fmo is included*/
select A.*, B.I as I, C.diff*.01 + D.price as FMO, E.num as N
from milk as A
LEFT JOIN incumbents as B ON A.SYSTEM = B.SYSTEM
AND A.COUNTY = B.COUNTY
AND A.VENDOR = B.VENDOR
LEFT JOIN fmo_diff AS C on A.FMOZONE = C.FMOZONE
LEFT JOIN fmo_prices AS D on A.YEAR = D.YEAR and A.MONTH = D.MONTH
LEFT JOIN num AS E on A.rowid = E.rowid;


/*helpful for seeing SA FMO results*/
select A.SYSTEM, A.COUNTY, A.VENDOR,  C.diff*.01 + D.price as FMO
from (select * from milk 
where YEAR >= 1980 and YEAR <=1983 and FMOZONE = 9) as A
LEFT JOIN incumbents as B ON A.SYSTEM = B.SYSTEM
AND A.COUNTY = B.COUNTY
AND A.VENDOR = B.VENDOR
LEFT JOIN fmo_diff AS C on A.FMOZONE = C.FMOZONE
LEFT JOIN fmo_prices AS D on A.YEAR = D.YEAR and A.MONTH = D.MONTH
LEFT JOIN num AS E on A.rowid = E.rowid;