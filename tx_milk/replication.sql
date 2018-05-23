WITH outcomes as (select COUNTY, SYSTEM, VENDOR, YEAR, NUMWIN, WIN is not '' as WIN from raw),

sum_wins as (select COUNTY, SYSTEM, sum(WIN) as SUM_WINS, count(YEAR) as NUMYEAR from outcomes group by SYSTEM),

ind_wins as (select COUNTY, SYSTEM, VENDOR, sum(WIN) as IND_WINS from outcomes group by SYSTEM, VENDOR),

incumbents as (SELECT A.COUNTY, A.SYSTEM, VENDOR, SUM_WINS, IND_WINS, ind_wins/((sum_wins*1.0)) AS WIN_PERCENT, 
((ind_wins/(sum_wins*1.0))>=.8) AS I
FROM ind_wins as A, sum_wins as B
WHERE A.SYSTEM = B.SYSTEM
AND NUMYEAR>=5)

select * from incumbents where I>=1 order by county;