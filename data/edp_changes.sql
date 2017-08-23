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


/*week_ag volumes and average prices by CTA*/
CREATE VIEW cta_ag AS
SELECT
week,
dim_cta_key,
sum(eq_vol) as total_vol,
avg(price) as avg_price
FROM group_edps
GROUP BY week, dim_cta_key;


/*view for first regression just brand and price*/
CREATE VIEW reg1 AS
SELECT * FROM
group_edps, brand
WHERE brand.dim_group_key = group_edps.dim_group_key;


/*view for first regression just group characteristics and price*/
CREATE VIEW reg2 AS
SELECT * FROM
group_edps, dairy, flavor, brand, size
WHERE dairy.dim_group_key = group_edps.dim_group_key
AND flavor.dim_group_key = group_edps.dim_group_key
AND brand.dim_group_key = group_edps.dim_group_key
AND size.dim_group_key = group_edps.dim_group_key;


/*view for first regression group characteristics and week*/
CREATE VIEW reg3 AS
SELECT * FROM
group_edps, dairy, flavor, brand, size, week
WHERE dairy.dim_group_key = group_edps.dim_group_key
AND flavor.dim_group_key = group_edps.dim_group_key
AND brand.dim_group_key = group_edps.dim_group_key
AND size.dim_group_key = group_edps.dim_group_key
AND week.week = group_edps.week;


/*view for first regression with group and CTA*/
CREATE VIEW reg4 AS
SELECT * FROM
group_edps, dairy, flavor, brand, size, dim_cta_key
WHERE dairy.dim_group_key = group_edps.dim_group_key
AND flavor.dim_group_key = group_edps.dim_group_key
AND brand.dim_group_key = group_edps.dim_group_key
AND size.dim_group_key = group_edps.dim_group_key
AND dim_cta_key.dim_cta_key = group_edps.dim_cta_key;


/*view for first regression with just CTA*/
CREATE VIEW reg5 AS
SELECT * FROM
group_edps, dim_cta_key
WHERE dim_cta_key.dim_cta_key = group_edps.dim_cta_key;


/*view for first regression with  CTA and week*/
CREATE VIEW reg6 AS
SELECT * FROM
group_edps, week, dim_cta_key
WHERE week.week = group_edps.week
AND dim_cta_key.dim_cta_key = group_edps.dim_cta_key;


/*view for first regression with just CTA and brand*/
CREATE VIEW reg7 AS
SELECT * FROM
group_edps, brand, dim_cta_key
WHERE brand.dim_group_key = group_edps.dim_group_key
AND dim_cta_key.dim_cta_key = group_edps.dim_cta_key;


/*view for first regression with group characteristics CTA and week*/
CREATE VIEW reg8 AS
SELECT * FROM
group_edps, dairy, flavor, brand, size, week, dim_cta_key
WHERE dairy.dim_group_key = group_edps.dim_group_key
AND flavor.dim_group_key = group_edps.dim_group_key
AND brand.dim_group_key = group_edps.dim_group_key
AND size.dim_group_key = group_edps.dim_group_key
AND week.week = group_edps.week
AND dim_cta_key.dim_cta_key = group_edps.dim_cta_key;


/*regression with prev 1 volume*/
CREATE VIEW reg9 AS
SELECT  group_edps.eq_vol, group_edps.price, prev_vol.prev_vol1 
FROM group_edps, prev_vol
WHERE group_edps.dim_group_key = prev_vol.dim_group_key
AND group_edps.week = prev_vol.week
AND group_edps.dim_cta_key = prev_vol.dim_cta_key;


/*regression with prev 2 vol*/
CREATE VIEW reg10 AS
SELECT group_edps.eq_vol, group_edps.price, prev_vol.prev_vol1, prev_vol.prev_vol2
FROM group_edps, prev_vol
WHERE group_edps.dim_group_key = prev_vol.dim_group_key
AND group_edps.week = prev_vol.week
AND group_edps.dim_cta_key = prev_vol.dim_cta_key;


/*regression with prev 1 price*/
CREATE VIEW reg11 AS
SELECT  group_edps.eq_vol, group_edps.price, prev_price.prev_price1 
FROM group_edps, prev_price
WHERE group_edps.dim_group_key = prev_price.dim_group_key
AND group_edps.week = prev_price.week
AND group_edps.dim_cta_key = prev_price.dim_cta_key;


/*regression with prev 2 price*/
CREATE VIEW reg12 AS
SELECT  group_edps.eq_vol, group_edps.price, prev_price.prev_price1,  prev_price.prev_price2
FROM group_edps, prev_price
WHERE group_edps.dim_group_key = prev_price.dim_group_key
AND group_edps.week = prev_price.week
AND group_edps.dim_cta_key = prev_price.dim_cta_key;


/*regression with prev price, prev vol, sum vol, sum price*/
CREATE VIEW reg13 AS
SELECT * FROM
group_edps, dairy, flavor, brand, size, prev_price, prev_vol, week_ag
WHERE dairy.dim_group_key = group_edps.dim_group_key
AND flavor.dim_group_key = group_edps.dim_group_key
AND brand.dim_group_key = group_edps.dim_group_key
AND size.dim_group_key = group_edps.dim_group_key
AND group_edps.dim_group_key = prev_price.dim_group_key
AND group_edps.week = prev_price.week
AND group_edps.dim_cta_key = prev_price.dim_cta_key
AND group_edps.dim_group_key = prev_vol.dim_group_key
AND group_edps.week = prev_vol.week
AND group_edps.dim_cta_key = prev_vol.dim_cta_key
AND group_edps.week = week_ag.week;


/*regression with prev price, prev vol, sum vol, sum price*/
CREATE VIEW reg14 AS
SELECT * FROM
group_edps, dairy, flavor, brand, size, prev_price, prev_vol, cta_ag
WHERE dairy.dim_group_key = group_edps.dim_group_key
AND flavor.dim_group_key = group_edps.dim_group_key
AND brand.dim_group_key = group_edps.dim_group_key
AND size.dim_group_key = group_edps.dim_group_key
AND group_edps.dim_group_key = prev_price.dim_group_key
AND group_edps.week = prev_price.week
AND group_edps.dim_cta_key = prev_price.dim_cta_key
AND group_edps.dim_group_key = prev_vol.dim_group_key
AND group_edps.week = prev_vol.week
AND group_edps.dim_cta_key = prev_vol.dim_cta_key
AND group_edps.week = cta_ag.week
AND group_edps.dim_cta_key = cta_ag.dim_cta_key;


/*regression with prev price, prev vol, sum vol, sum price*/
CREATE VIEW reg15 AS
SELECT * FROM
group_edps, dairy, flavor, brand, size, week, dim_cta_key, prev_price, prev_vol, cta_ag
WHERE dairy.dim_group_key = group_edps.dim_group_key
AND flavor.dim_group_key = group_edps.dim_group_key
AND brand.dim_group_key = group_edps.dim_group_key
AND size.dim_group_key = group_edps.dim_group_key
AND week.week = group_edps.week
AND dim_cta_key.dim_cta_key = group_edps.dim_cta_key
AND group_edps.dim_group_key = prev_price.dim_group_key
AND group_edps.week = prev_price.week
AND group_edps.dim_cta_key = prev_price.dim_cta_key
AND group_edps.dim_group_key = prev_vol.dim_group_key
AND group_edps.week = prev_vol.week
AND group_edps.dim_cta_key = prev_vol.dim_cta_key
AND group_edps.week = cta_ag.week
AND group_edps.dim_cta_key = cta_ag.dim_cta_key;