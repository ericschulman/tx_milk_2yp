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
CREATE VIEW milk as select rowid, SYSTEM, COUNTY, MRKTCODE, VENDOR, 
cast (substr(LETDATE,0,instr(LETDATE,'/')) as integer) AS MONTH,
cast(substr(LETDATE, instr(LETDATE,'/')+1 , instr(substr(LETDATE,instr(LETDATE,'/')+1),'/')-1) as integer) AS DAY,
1900 + YEAR as YEAR,
LFC, LFW, WW, WC, QLFC, QLFW, QWW, QWC, ESTQTY, QUANTITY, FMOZONE, DEL,
ESTQTY/(DEL*36) AS QSTOP,
instr(ESC,'E') > 0 as ESC,
WIN is not '' as WIN
from tx_milk;


/*query to calculate the BACKLOG*/
CREATE VIEW backlog AS

WITH passed as (SELECT A.*, SUM(B.ESTQTY*B.WIN) as PASSED
FROM milk as A, milk as B
WHERE A.YEAR = B.YEAR
AND ( (A.MONTH <= B.MONTH) OR (A.MONTH = B.MONTH AND A.DAY <= B.DAY) )
GROUP BY A.rowid),

contracts as (SELECT A.*, SUM(B.ESTQTY*B.WIN) as CONTRACTS
FROM milk as A, milk as B
WHERE A.YEAR = B.YEAR
GROUP BY A.rowid),

commitments as (SELECT A.*, SUM(B.ESTQTY*B.WIN) as COMMITMENTS
FROM milk as A, milk as B
WHERE A.VENDOR = B.VENDOR
AND A.YEAR = B.YEAR
AND ( (A.MONTH >= B.MONTH) OR (A.MONTH = B.MONTH AND A.DAY >= B.DAY) )
GROUP BY A.rowid),

capacity as (SELECT VENDOR, max(contracts) as CAPACITY
FROM
(SELECT VENDOR, YEAR, SUM(ESTQTY*WIN) as contracts
from milk
GROUP BY VENDOR, YEAR)
GROUP BY VENDOR)

SELECT passed.*, CONTRACTS, COMMITMENTS, CAPACITY, (COMMITMENTS/CAPACITY - PASSED/CONTRACTS) AS BACKLOG
FROM passed, contracts, commitments, capacity
WHERE passed.rowid = contracts.rowid
AND passed.rowid = commitments.rowid
AND passed.vendor = capacity.vendor;

/*create view with number of competitors*/
create view num as 
select A.rowid, count(*) as NUM from milk as A, milk as B 
WHERE A.SYSTEM = B.SYSTEM
AND A.COUNTY = B.COUNTY
AND A.DAY = B.DAY
AND A.MONTH = B.MONTH
AND A.YEAR = B.YEAR
GROUP BY A.rowid;


/*Work in Progress*/

/*View with correct dates*/
CREATE VIEW letdates as SELECT 
rowid, SYSTEM, LETDATE, MRKTCODE, VENDOR,
cast (substr(LETDATE,0,instr(LETDATE,'/')) as integer) AS MONTH,
cast(substr(LETDATE, instr(LETDATE,'/')+1 , instr(substr(LETDATE,instr(LETDATE,'/')+1),'/')-1) as integer) AS DAY,
cast (substr(LETDATE, instr(LETDATE,'/')+ instr(substr(LETDATE,instr(LETDATE,'/')+1),'/') + 1 ) as integer)+60 AS YEAR
FROM tx_milk;

/*Querey for listing school districts with incumbent vendors*/
SELECT * FROM incumbents WHERE I>=1 ORDER BY county;

/*Generate the Data involved with Table 5*/
select A.*, B.I as I, C.diff*.01 + D.price as FMO, E.num as N
from milk as A
LEFT JOIN incumbents as B ON A.SYSTEM = B.SYSTEM
AND A.COUNTY = B.COUNTY
AND A.VENDOR = B.VENDOR
LEFT JOIN fmo_diff AS C on A.FMOZONE = C.FMOZONE
LEFT JOIN fmo_prices AS D on A.YEAR = D.YEAR and 0 = D.month
LEFT JOIN num AS E on A.rowid = E.rowid;