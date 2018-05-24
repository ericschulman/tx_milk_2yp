/*Query for calculating which school districts have incumbent vendors*/
CREATE VIEW incumbents AS
WITH
outcomes as (select COUNTY, SYSTEM, VENDOR, YEAR, NUMWIN, WIN is not '' as WIN from tx_milk),
sum_wins as (select COUNTY, SYSTEM, sum(WIN) as SUM_WINS, count(YEAR) as NUMYEAR from outcomes group by SYSTEM),
ind_wins as (select COUNTY, SYSTEM, VENDOR, sum(WIN) as IND_WINS from outcomes group by SYSTEM, VENDOR)

SELECT A.COUNTY, A.SYSTEM, VENDOR, SUM_WINS, 
IND_WINS, ind_wins/((sum_wins*1.0)) AS WIN_PERCENT, 
((ind_wins/(sum_wins*1.0))>=.8) AS I
FROM ind_wins as A, sum_wins as B
WHERE A.SYSTEM = B.SYSTEM
AND NUMYEAR>=5;

/*Querey for listing school districts with incumbent vendors*/
SELECT * FROM incumbents WHERE I>=1 ORDER BY county;

/*Baby query to format date correctly*/
SELECT 
cast (substr(LETDATE,0,instr(LETDATE,'/')) as integer) AS MONTH,
cast(substr(LETDATE, instr(LETDATE,'/')+1 , instr(substr(LETDATE,instr(LETDATE,'/')+1),'/')-1) as integer) AS DAY,
cast (substr(LETDATE, instr(LETDATE,'/')+ instr(substr(LETDATE,instr(LETDATE,'/')+1),'/') + 1 ) as integer)+60 AS YEAR
FROM tx_milk;

/*Trying to generate previous wins that year, needs work...*/
WITH
dated_bids as (select VENDOR, WIN is not '' as WIN,
cast (substr(LETDATE,0,instr(LETDATE,'/')) as integer) AS MONTH,
cast(substr(LETDATE, instr(LETDATE,'/')+1 , instr(substr(LETDATE,instr(LETDATE,'/')+1),'/')-1) as integer) AS DAY,
1900 + YEAR as YEAR,
QLFC, QLFW, QWW, QWC, ESTQTY, 
LFC from tx_milk)

select A.YEAR, A.VENDOR, A.LFC,
SUM(B.QLFC),
MAX(A.ESTQTY)
from dated_bids as A, dated_bids as B
WHERE A.WIN >= 1 and
B.WIN >= 1 and
(A.YEAR = B.YEAR)
AND ( (A.MONTH > B.MONTH) OR (A.MONTH = B.MONTH AND A.DAY >= B.DAY) )
GROUP BY A.YEAR, A.VENDOR, A.LFC

/*Generate the Data involved with Table 5*/
select A.SYSTEM as SYSTEM, A.VENDOR as VENDOR,
cast (substr(LETDATE,0,instr(LETDATE,'/')) as integer) AS MONTH,
cast(substr(LETDATE, instr(LETDATE,'/')+1 , instr(substr(LETDATE,instr(LETDATE,'/')+1),'/')-1) as integer) AS DAY,
1900 + YEAR as YEAR,
LFC as BID, I, 1 as LFC, 0 as LFW, 0 as WC,
instr(ESC,'E') > 0 as ESC,
1-I as NI
from tx_milk as A, incumbents as B 
where A.SYSTEM = B.SYSTEM and A.VENDOR = B.VENDOR;

