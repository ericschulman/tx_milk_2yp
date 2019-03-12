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
select rowid as ROW, SYSTEM, COUNTY, MRKTCODE, VENDOR, 
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


/*create view with number of competitors*/
create view num as 
select A.ROW, count(*) as NUM from milk as A, milk as B 
WHERE A.SYSTEM = B.SYSTEM
AND A.COUNTY = B.COUNTY
AND A.DAY = B.DAY
AND A.MONTH = B.MONTH
AND A.YEAR = B.YEAR
GROUP BY A.ROW;


/*helpful for debugging milk out
also previous 'differential' adjusted fmo is included*/
create view milk_join as
select A.*, B.I as I, C.crude as GAS, D.price as FMO, E.num as N, F.BACKLOG
from milk as A
LEFT JOIN incumbents as B ON A.SYSTEM = B.SYSTEM
AND A.COUNTY = B.COUNTY
AND A.VENDOR = B.VENDOR
LEFT JOIN gasoline AS C on A.YEAR = C.YEAR and A.MONTH = C.MONTH
LEFT JOIN fmo_prices AS D on A.YEAR = D.YEAR and A.MONTH = D.MONTH
LEFT JOIN num AS E on A.ROW = E.ROW
LEFT JOIN backlog as F on A.ROW = F.ROW;