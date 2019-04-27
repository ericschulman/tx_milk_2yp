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
create view clean_milk as 
select rowid as ROW, SYSTEM, COUNTY, MRKTCODE, VENDOR, 
cast (substr(LETDATE,0,instr(LETDATE,'/')) as integer) AS MONTH,
cast(substr(LETDATE, instr(LETDATE,'/')+1 , instr(substr(LETDATE,instr(LETDATE,'/')+1),'/')-1) as integer) AS DAY,
1900 + YEAR as YEAR,
LFC, LFW, WW, WC, QLFC, QLFW, QWW, QWC, ESTQTY, QUANTITY, FMOZONE, DEL, POPUL, ADJPOP,
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


/*list all possible auctions*/
create view clean_auctions as
select SYSTEM, YEAR, 
(CASE WHEN MONTH IS NULL THEN 0
	ELSE MONTH END) AS MONTH, 
(CASE WHEN DAY IS NULL THEN 0
	ELSE DAY END) AS DAY, 
(CASE WHEN FMOZONE IS NULL THEN '6' 
	ELSE FMOZONE END) AS FMOZONE,
(CASE WHEN ESC IS NULL THEN 0
	WHEN ESC = '' THEN 0	 
	ELSE ESC
END) AS ESC,
(CASE WHEN COOLER IS NULL THEN 0
	WHEN COOLER = '' THEN 0	
	ELSE COOLER
END) AS COOLER,
MAX(QLFC) AS QLFC, MAX(QLFW) AS QLFW,
MAX(QWW) AS QWW, MAX(QWC) AS QWC, 
MAX(ESTQTY) AS ESTQTY, MAX(DEL) AS DEL,
MAX(MILES) AS MILES, MAX(NUMSCHL) AS NUMSCHL,
MAX(NUMWIN) AS NUMWIN, 
MAX(POPUL) AS POPUL , MAX(ADJPOP) AS ADJPOP,
COUNT(*) as NUM
from clean_milk
GROUP BY SYSTEM, MONTH, DAY, YEAR, FMOZONE
ORDER BY YEAR, MONTH, DAY, FMOZONE,  SYSTEM;


/*Join auctions with crude oil and fmo*/
create view auctions as
select A.*, B.crude as GAS, C.price as FMO
from clean_auctions as A
LEFT JOIN gasoline AS B on A.YEAR = B.YEAR and A.MONTH = B.MONTH
LEFT JOIN fmo_prices AS C on A.YEAR = C.YEAR and A.MONTH = C.MONTH;


/* create a view with the bids*/
create view bids as
select VENDOR, LFC, LFW, WW, WC, SYSTEM,
(CASE WHEN FMOZONE IS NULL THEN '6' 
	ELSE FMOZONE END) AS FMOZONE,
(CASE WHEN MONTH IS NULL THEN 0
	ELSE MONTH END) AS MONTH, 
(CASE WHEN DAY IS NULL THEN 0
	ELSE DAY END) AS DAY,
YEAR,
WIN is not '' as WIN
FROM clean_milk;


/*complete view*/
create view milk as
select VENDOR, WW, WC, LFW, LFC, WIN, a.* from bids as b
left join auctions as a
on a.SYSTEM = b.SYSTEM 
AND A.DAY = b.DAY 
and a.YEAR = b.YEAR 
and a.MONTH = b.MONTH
and a.FMOZONE = b.FMOZONE;