
/**bids over time**/
select day, month, year, min(WW), min(num) 
from milk
WHERE WW is not NULL and day <>0 and QWW is not null and year >1979
group by year, month, day, SYSTEM, FMOZONE
order by  year, month, day;


/* looking for punishment over time**/
select  system,  month, day, year, score, num
 from milk where num >1 and score < .155 and win =1
and QSCORE is not NULL and day <>0 and year >1979 and month >=4 and month <=9
order by  year, month, day;



/*avg characteristics per year*/
select year,  round(100*sum(score*win)/sum(win*(score<>0)),2) as winner, round(100*avg(SCORE),2) as score, 
round(sum(QSCORE*win)/sum(win)/1000.,2) as quant,
round(avg(gas),2) as gas, round(avg(POPUL)/1000.,2) as pop, round(avg(FMO),2) as fmo, 
round(avg(num),2) as num, round(avg(100*ifnull(COOLER,0)),2) as cooler, 
count(DISTINCT SYSTEM),
round(avg(100*ifnull(ESC,0)),2) as esc, count(*) as obs
 from milk
 where QSCORE is not NULL and day <>0 and year >1979 and month >=4 and month <=9
group by YEAR

/*average time between auctions*/
select year, count(*) as no_auctions, round(121./count(*),2) as auctions from auctions
where year > 1979 and month >= 5 and month <=8 and day<>0
group by year;

/*avg characteristics per month*/
select MONTH,  round(100*sum(score*win)/sum(win*(score<>0)),2) as winner, round(100*avg(SCORE),2) as score, 
round(sum(QSCORE*win)/sum(win*(score<>0))/1000.,2) as quant,
round(avg(gas),2) as gas, round(avg(POPUL)/1000.,2) as pop, round(avg(FMO),2) as fmo, 
round(avg(num),2) as num, round(avg(100*ifnull(COOLER,0)),2) as cooler, round(avg(100*ifnull(ESC,0)),2) as esc, 
round(count(*)/(max(year)-min(year)),2) as obs
 from milk
 where QSCORE is not NULL and day <>0 and year >1979 and month >=4 and month <=9
group by month


/*time between auctions*/
select month, round(count(*)/(max(year)-min(year)),2) as no_auctions, 
round( (max(year)-min(year))*30./count(*),2) as auctions from auctions
where year > 1979 and month >= 4 and month <=9 and day<>0
group by month;


/** avg characterstics FMOZONE**/
select FMOZONE,  round(100*sum(score*win)/sum(win*(score<>0)),2) as winner, round(100*avg(SCORE),2) as score, 
round(sum(QSCORE*win)/sum(win*(score<>0))/1000.,2) as quant,
round(avg(gas),2) as gas, round(avg(POPUL)/1000.,2) as pop,
round(avg(num),2) as num, round(avg(100*ifnull(COOLER,0)),2) as cooler, round(avg(100*ifnull(ESC,0)),2) as esc, count(*) as obs
 from milk
 where QSCORE is not NULL and day <>0 and year >1979 and month >=4 and month <=9 and FMOZONE <> '1A'
group by FMOZONE


/*incumbency*/
select FMOZONE, SUM(INC) as noinc, count(*) as auctions, sum(bids) as bids
from (select FMOZONE, MAX(INC) as INC, count(*) as bids from milk
where year > 1979 and month >= 4 and month <=9 and day<>0 and QSCORE is not NULL and FMOZONE <> '1A'
group by SYSTEM, FMOZONE)
group by FMOZONE


/*min bid vs num of bidders*/
select num,
round(100*avg(SCORE),2) as bid,
round(100*sum(SCORE*win*(score<>0))/sum(win*(score<>0)),2) as winningbid,
round(sum(QSCORE*win*(score<>0))/sum(win*(score<>0))/1000.,2) as quant,   round(100*avg(ESC),2) as esc,  
 count(*) as obs, sum(win) as auctions,   round(sum(NUMBID*win*(score<>0))*1./sum(win*(score<>0)),2) as bids
from milk 
where year > 1979 and month >= 4 and month <=9 and day<>0
and score <> 0 and QSCORE is not NULL and vendor is not NULL
group by num;


/** scores by num (with a group to see maxes and stuff)**/
select NUM, avg(mins), avg(maxs), avg(avgs)
from
(select year, month, day, SYSTEM, FMOZONE, NUM, min(SCORE) as mins, max(SCORE) as maxs, avg(score) as avgs from milk
 where QSCORE is not NULL and day <>0 and year >1979 and month >=4 and month <=9 and num >0
group by year, month, day, SYSTEM, FMOZONE, NUM)
group by NUM



/**looking for punishments **/
select system, year, month, day, num, potential, score
from (
select system, avg(year) as year, count(*) as counts,
avg(day) as day, 
avg(month) as month, 
avg(num) as num, count(*) as potential, avg(score) as score
from(select system, year, 
avg(day) as day, 
avg(month) as month, 
avg(num) as num, avg(score) as score 
from milk where score < .16 and win =1
and QSCORE is not NULL and day <>0 and year >1979 and month >=4 and month <=9
group by system, year
order by system 
)
group by system)
where potential  <3
order by year, month, day