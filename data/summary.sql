/**bids over time**/
select system, day, month, year, min(score), min(num) 
from milk
WHERE QSCORE is not NULL and day <>0 and SCORE is not null and year >1979 and FMOZONE=1
group by year, month, day, SYSTEM
order by  year, month, day;



/* looking for punishment over time**/
select  system,  month, day, year, score, qscore, num
 from milk where num >1 and score < .155 and win =1
and QSCORE is not NULL and day <>0 and year >1979 and month >=4 and month <=9
order by  year, month, day;

/*price war examples*/
select vendor, system, score, win, qscore, fmo, gas, day, month, year, inc
 from milk where day >=7 and day <= 8 and month =7 and year =1985  
 order by day, SYSTEM, VENDOR;

select * from milk where day >=28 and day <= 29 and month =7 and year =1986  order by SYSTEM, VENDOR;
select * from milk where day >=12 and day <= 13 and month =7 and year =1987 order by SYSTEM, VENDOR;


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

/*price distribution each month*/
select MONTH,  
round(100*avg(SCORE),2) as score, 
round(100*100*avg(SCORE*SCORE),2) as scorevar, 
round(100*sum(score*win)/sum(win*(score<>0)),2) as winbid, 
round(100*100*sum(score*score*win)/sum(win*(score<>0)),2) as varwin, 
round(sum(score<.155)/(max(year)-min(year)),2) as wars,
round(count(*)/(max(year)-min(year)),2) as obs
 from milk
 where QSCORE is not NULL and day <>0 and year >1979 and month >=4 and month <=9
group by month


/*avg characteristics per month*/
select MONTH, 
round(sum(QSCORE*win)/sum(win*(score<>0))/1000.,2) as quant,
 round(sum(QSCORE*QSCORE*win)/sum(win*(score<>0))/1000/1000.,2) as varquant,
round(avg(gas),2) as gas, round(avg(POPUL)/1000.,2) as pop, round(avg(FMO),2) as fmo, 
round(avg(num),2) as num, round(avg(100*ifnull(COOLER,0)),2) as cooler, round(avg(100*ifnull(ESC,0)),2) as esc, 
round(count(*)/(max(year)-min(year)),2) as obs
 from milk
 where QSCORE is not NULL and day <>0 and year >1979 and month >=4 and month <=9
group by month

/*double check quantity*/
select avg(qscore)/1000, avg(qscore*qscore)/1000/1000 from milk
where QSCORE is not NULL 
and day <>0 and year >1979 
and month >=4 and month <=9
and win=1
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


/*variance in number of days*/
select SYSTEM,FMOZONE, avg(score), avg(qscore),
 AVG((DAY + 30*MONTH)*(DAY + 30*MONTH)) - AVG(DAY + 30*MONTH)*AVG(DAY + 30*MONTH), count(*)
 from milk
where SCORE is not NULL and QSCORE is not NULL and day <>0 and year >1979 and month >=4 and month <=9 and num >0 and win=1

group by  SYSTEM, FMOZONE
order by count(*), avg(score)


/*bids by vendor*/
select REALVENDOR, 
round(avg(SCORE)*100,2) as bid,
round(sum(SCORE*WIN)/SUM(WIN*(SCORE<>0))*100,2) as bidwin,
round(sum(QSCORE*WIN)/SUM(WIN*(QSCORE<>0))/1000,2) as quant,
sum(FMOZONE=1), sum(FMOZONE=3), sum(FMOZONE=7), sum(FMOZONE=9), SUM(WIN), count(*)
from (select *,
(CASE WHEN (VENDOR = "BORDEN"
OR VENDOR = "CABELL"
OR VENDOR = "FOREMOST"
OR VENDOR = "OAK FARMS"
OR VENDOR = "PRESTON"
OR VENDOR = "SCHEPPS"
OR VENDOR = "VANDERVOORT"
or VENDOR = "PURE") THEN VENDOR
ELSE 'OTHER' END) as REALVENDOR
 from milk)
where QSCORE is not NULL and day <>0 and year >1979 and month >=4 and month <=9
GROUP BY REALVENDOR;



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

