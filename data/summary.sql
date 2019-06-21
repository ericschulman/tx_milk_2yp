select day, month, year, min(WW), min(num) 
from milk
WHERE WW is not NULL and day <>0 and QWW is not null and year >1979
group by year, month, day, SYSTEM, FMOZONE
order by  year, month, day;

/*average time between auctions*/
select year, count(*) as no_auctions, round(121./count(*),2) as auctions from auctions
where year > 1979 and month >= 5 and month <=8 and day<>0 and QSCORE is not NULL
group by year;


/*time between auctions*/
select month, count(*) as no_auctions, round( (max(year)-min(year))*30./count(*),2) as auctions from auctions
where year > 1979 and month >= 4 and month <=9 and day<>0 and QSCORE is not NULL
group by month;


/*avg characteristics*/
select MONTH, round(avg(gas),2), round(avg(POPUL)/1000.,2), round(avg(FMO),2), round(avg(SCORE),3), round(avg(QSCORE)/1000.,2), 
round(avg(num),2), round(avg(ifnull(COOLER,0)),2), round(avg(ifnull(ESC,0)),2), count(*)
 from milk
 where QSCORE is not NULL and day <>0 and year >1979 and month >=4 and month <=9
group by month

/*incumbency*/
select FMOZONE, SUM(INC), count(*)
from (select FMOZONE, MAX(INC) as INC from milk
where year > 1979 and month >= 5 and month <=8 and day<>0 and QSCORE is not NULL
group by SYSTEM, FMOZONE)
group by FMOZONE