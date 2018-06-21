/*better view the creamers data*/
create view creamers_1  as SELECT
substr(dim_group_key,0,3) as brand,
substr(dim_group_key,4,2) as oz,
substr(dim_group_key,7,1) as dairy,
substr(dim_group_key,9,1) as flavor,
dim_cta_key as region,
week,
price,
eq_vol as quantity
FROM creamers;

/*focus on one market*/
select region, flavor, dairy, oz, count(distinct brand) as firms, count(distinct week) as weeks
from creamers_1
where brand<>'PL'
group by region, flavor, dairy, oz;

/*focus on one region*/
/*analyzed this view in creamers 1, PL makes it more complicated*/
create view U_D_32_4 as select * from creamers_1 where region = 4 and flavor = 'U' and dairy = 'D' and oz = '32';

create view F_N_16_120 as select * from creamers_1 where region = 120 and flavor = 'F' and dairy = 'N' and oz = '16';

/*three at a time*/
create view F_D_16_4 as select * from creamers_1 where region = 4 and flavor = 'F' and dairy = 'D' and oz = '16';