/*Simplified table with all the important data and CORRECT let dates*/
create view clean_milk as 
select rowid as ROW, SYSTEM, COUNTY, MRKTCODE, VENDOR, 
cast (substr(LETDATE,0,instr(LETDATE,'/')) as integer) AS MONTH,
cast(substr(LETDATE, instr(LETDATE,'/')+1 , instr(substr(LETDATE,instr(LETDATE,'/')+1),'/')-1) as integer) AS DAY,
1900 + YEAR as YEAR,
LFC, LFW, WW, WC, QLFC, QLFW, QWW, QWC, ESTQTY, QUANTITY, FMOZONE, DEL, POPUL, ADJPOP, MEALS,
(CASE
 WHEN ESC='E' THEN 1
 WHEN ESC='F' THEN 0
 ELSE NULL
 END) as ESC,
(CASE
 WHEN COOLER ='Y' THEN 1
 WHEN COOLER='N' THEN 0
 ELSE NULL
 END) AS COOLER,
 MILES,
 (CASE
 WHEN KEYS ='Y' THEN 1
 WHEN KEYS='N' THEN 0
 ELSE NULL
 END) AS KEYS,
(CASE
WHEN WIN is not NULL THEN 1
WHEN WIN is '' THEN 1
ELSE 0
END) as WIN,
NUMSCHL, NUMWIN
from tx_milk;


/* list incumbencies */
create view incumbents as 
WITH wins as (select SYSTEM, 
(CASE WHEN FMOZONE IS NULL THEN 9 
	ELSE FMOZONE END) AS FMOZONE,
VENDOR, SUM(WIN is not NULL) as WINS
from tx_milk
GROUP BY SYSTEM, FMOZONE, VENDOR),

max_wins as (select SYSTEM, FMOZONE, MAX(WINS) as MAX_WINS, SUM(WINS) as TOT_WINS from wins group by  SYSTEM, FMOZONE),

potential_incs as (select *, (1.*MAX_WINS)/(1.*TOT_WINS) from max_wins
where (1.*MAX_WINS)/(1.*TOT_WINS) > .5 and TOT_WINS > 5)

select a.*, b.VENDOR from max_wins as a
left join potential_incs as c on 
a.SYSTEM = c.SYSTEM AND a.FMOZONE = c.FMOZONE AND a.MAX_WINS = c.MAX_WINS
left join wins as b on 
c.MAX_WINS = b.WINS AND c.SYSTEM = b.SYSTEM AND c.FMOZONE = b.FMOZONE;


/*list all possible auctions*/
create view clean_auctions as
select SYSTEM, YEAR, COUNTY,
(CASE WHEN MONTH IS NULL THEN 0
	ELSE MONTH END) AS MONTH, 
(CASE WHEN DAY IS NULL THEN 0
	ELSE DAY END) AS DAY, 
(CASE WHEN FMOZONE IS NULL THEN 9
	ELSE FMOZONE END) AS FMOZONE, 
MAX(COOLER) as COOLER,  MAX(KEYS) as KEYS, 
MAX(QLFC) AS QLFC, MAX(QLFW) AS QLFW,
MAX(QWW) AS QWW, MAX(QWC) AS QWC, MAX(QUANTITY) AS QUANTITY,
MAX(ESTQTY) AS ESTQTY, MAX(DEL) AS DEL,
MAX(MILES) AS MILES, MAX(NUMSCHL) AS NUMSCHL,
MAX(NUMWIN) AS NUMWIN, 
MAX(POPUL) AS POPUL , MAX(ADJPOP) AS ADJPOP, MAX(MEALS) AS MEALS,
COUNT(*) as NUMBID,
COUNT(DISTINCT VENDOR) as NUM
from clean_milk
GROUP BY SYSTEM, COUNTY, MONTH, DAY, YEAR, FMOZONE
ORDER BY YEAR, MONTH, DAY, FMOZONE,  SYSTEM;



/*Join auctions with crude oil and fmo*/
create view auctions as
select A.*, B.crude as GAS, C.price as FMO
from clean_auctions as A
LEFT JOIN gasoline AS B on A.YEAR = B.YEAR and A.MONTH = B.MONTH
LEFT JOIN fmo_prices AS C on A.YEAR = C.YEAR and A.MONTH = C.MONTH;


/* create a view with the bids*/
create view bids as
select VENDOR, ESC, LFC, LFW, WW, WC, SYSTEM,
(CASE WHEN FMOZONE IS NULL THEN 9 
	ELSE FMOZONE END) AS FMOZONE,
(CASE WHEN MONTH IS NULL THEN 0
	ELSE MONTH END) AS MONTH, 
(CASE WHEN DAY IS NULL THEN 0
	ELSE DAY END) AS DAY,
YEAR, WIN
FROM clean_milk;


/*complete view*/
create view milk as
select b.VENDOR as VENDOR, WW, WC, LFW, LFC, WIN, ESC, a.*, 
((ifnull(QWW*WW,0)+ ifnull(QLFW*LFW,0)+ ifnull(QWC*WC,0) + ifnull(QLFC*LFC,0))/
(ifnull(QWW,0)*(WW is not null)+ ifnull(QLFW,0)*(LFW is not null)+ ifnull(QWC,0)*(WC is not null)+ ifnull(QLFC,0)*(LFC is not null) )) as SCORE,
(ifnull(QWW,0)*(WW is not null)+ ifnull(QLFW,0)*(LFW is not null)+ ifnull(QWC,0)*(WC is not null)+ ifnull(QLFC,0)*(LFC is not null) ) as QSCORE,
(CASE WHEN b.VENDOR = c.VENDOR  THEN 1
ELSE 0 END) as INC
from bids as b
left join auctions as a
on a.SYSTEM = b.SYSTEM 
AND A.DAY = b.DAY 
and a.YEAR = b.YEAR 
and a.MONTH = b.MONTH
and a.FMOZONE = b.FMOZONE
left join incumbents as c on 
c.SYSTEM = a.SYSTEM
and c.FMOZONE = a.FMOZONE
ORDER by a.YEAR, a.MONTH, a.DAY;