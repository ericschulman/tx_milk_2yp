/*Creates table with dairy dummy*/
CREATE TABLE dairy (
dim_group_key TEXT,
dairy INTEGER,
PRIMARY KEY(dim_group_key));


/*Creates table with flavor dummy*/
CREATE TABLE flavor (
dim_group_key TEXT,
flavor INTEGER,
PRIMARY KEY(dim_group_key));


/*Creates table with brand dummies
leaves out BA (i.e. 0000)*/
CREATE TABLE brand(
dim_group_key TEXT,
CM INTEGER,
DD INTEGER,
ID INTEGER,
PL INTEGER,
PRIMARY KEY(dim_group_key));


/*creates table with size dummy (000 is 16 oz)*/
CREATE TABLE size (
dim_group_key TEXT,
`32` INTEGER,
`64` INTEGER,
`48` INTEGER,
PRIMARY KEY(dim_group_key));


/* Create the main table in SQL*/
CREATE TABLE group_edps (
dim_cta_key TEXT,
dim_group_key TEXT,
week INTEGER,
price REAL,
edp REAL,
money_vol REAL,
eq_vol REAL,
dim_date_key TEXT,
PRIMARY KEY(dim_cta_key, dim_group_key, week)
FOREIGN KEY (dim_group_key) REFERENCES dairy(dim_group_key)
FOREIGN KEY (dim_group_key) REFERENCES flavor(dim_group_key)
FOREIGN KEY (dim_group_key) REFERENCES brand(dim_group_key)
FOREIGN KEY (dim_group_key) REFERENCES size(dim_group_key)
FOREIGN KEY (dim_cta_key) REFERENCES groups(dim_cta_key)
);


/*create view with previous prices (Back 2)*/
CREATE VIEW prev_price AS
SELECT a.dim_cta_key,
a.dim_group_key,
a.week,
b.price as prev_price1,
c.price as prev_price2
FROM group_edps AS a, group_edps AS b, group_edps AS c
WHERE a.week = (b.week+1) 
AND a.dim_group_key = b.dim_group_key
AND a.dim_cta_key = b.dim_cta_key
AND a.week = (c.week+2) 
AND a.dim_group_key = c.dim_group_key
AND a.dim_cta_key = c.dim_cta_key;


/*create view with previous vol (Back 2)*/
CREATE VIEW prev_vol AS
SELECT a.dim_cta_key,
a.dim_group_key,
a.week, 
b.eq_vol as prev_vol1,
c.eq_vol as prev_vol2
FROM group_edps AS a, group_edps AS b, group_edps AS c
WHERE a.week = (b.week+1) 
AND a.dim_group_key = b.dim_group_key
AND a.dim_cta_key = b.dim_cta_key
AND a.week = (c.week+2) 
AND a.dim_group_key = c.dim_group_key
AND a.dim_cta_key = c.dim_cta_key;


/*create view with sum of week_ag volumes*/
CREATE VIEW week_ag AS
SELECT
week,
sum(eq_vol) as total_vol,
avg(price) as avg_price
FROM group_edps
GROUP BY week;


/*create price ratio to use instead of weekly ag*/
CREATE VIEW price_ratio AS
SELECT
group_edps.dim_cta_key,
group_edps.dim_group_key,
group_edps.week,
group_edps.eq_vol/week_ag.total_vol,
group_edps.price/week_ag.avg_price
FROM group_edps, week_ag
WHERE
group_edps.week = week_ag.week;


/*week_ag volumes and average prices by CTA*/
CREATE VIEW cta_ag AS
SELECT
week,
dim_cta_key,
sum(eq_vol) as total_vol,
avg(price) as avg_price
FROM group_edps
GROUP BY week, dim_cta_key;


/*create price ratio to use instead of weekly ag*/
CREATE VIEW price_ratio_cta AS
SELECT
group_edps.dim_cta_key,
group_edps.dim_group_key,
group_edps.week, 
group_edps.eq_vol/cta_ag.total_vol,
group_edps.price/cta_ag.avg_price
FROM group_edps, cta_ag
WHERE
group_edps.week = cta_ag.week 
AND group_edps.dim_cta_key = cta_ag.dim_cta_key;


/*view designed to show volume change to use as regressors*/
CREATE VIEW vol_changes AS
SELECT group_edps.dim_cta_key,
group_edps.dim_group_key,
group_edps.week,
group_edps.price,
group_edps.edp,
group_edps.money_vol,
(group_edps.eq_vol-prev_vol.prev_vol1) AS eq_vol,
group_edps.dim_date_key
FROM
group_edps, prev_vol
WHERE group_edps.dim_group_key = prev_vol.dim_group_key
AND group_edps.week = prev_vol.week
AND group_edps.dim_cta_key = prev_vol.dim_cta_key


