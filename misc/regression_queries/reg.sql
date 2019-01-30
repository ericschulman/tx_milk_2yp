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


/*brand with previous vol*/
CREATE VIEW reg1_fixed AS
SELECT * FROM
group_edps, brand, prev_vol
WHERE brand.dim_group_key = group_edps.dim_group_key
AND group_edps.dim_group_key = prev_vol.dim_group_key
AND group_edps.week = prev_vol.week
AND group_edps.dim_cta_key = prev_vol.dim_cta_key;


CREATE VIEW reg2_fixed AS
SELECT * FROM
group_edps, dairy, flavor, brand, size, prev_vol
WHERE dairy.dim_group_key = group_edps.dim_group_key
AND flavor.dim_group_key = group_edps.dim_group_key
AND brand.dim_group_key = group_edps.dim_group_key
AND size.dim_group_key = group_edps.dim_group_key
AND group_edps.dim_group_key = prev_vol.dim_group_key
AND group_edps.week = prev_vol.week
AND group_edps.dim_cta_key = prev_vol.dim_cta_key;


/*view for first regression just group characteristics and price*/
CREATE VIEW reg2_vol AS
SELECT * FROM
vol_changes, dairy, flavor, brand, size
WHERE dairy.dim_group_key = vol_changes.dim_group_key
AND flavor.dim_group_key = vol_changes.dim_group_key
AND brand.dim_group_key = vol_changes.dim_group_key
AND size.dim_group_key = vol_changes.dim_group_key;


/*view for first regression group characteristics and week*/
CREATE VIEW reg3_vol AS
SELECT * FROM
vol_changes, dairy, flavor, brand, size, week
WHERE dairy.dim_group_key = vol_changes.dim_group_key
AND flavor.dim_group_key = vol_changes.dim_group_key
AND brand.dim_group_key = vol_changes.dim_group_key
AND size.dim_group_key = vol_changes.dim_group_key
AND week.week = vol_changes.week;


/*view for first regression with group and CTA*/
CREATE VIEW reg4_vol AS
SELECT * FROM
vol_changes, dairy, flavor, brand, size, dim_cta_key
WHERE dairy.dim_group_key = vol_changes.dim_group_key
AND flavor.dim_group_key = vol_changes.dim_group_key
AND brand.dim_group_key = vol_changes.dim_group_key
AND size.dim_group_key = vol_changes.dim_group_key
AND dim_cta_key.dim_cta_key = vol_changes.dim_cta_key;


/*view for first regression with group characteristics CTA and week*/
CREATE VIEW reg8_vol AS
SELECT * FROM
vol_changes, dairy, flavor, brand, size, week, dim_cta_key
WHERE dairy.dim_group_key = vol_changes.dim_group_key
AND flavor.dim_group_key = vol_changes.dim_group_key
AND brand.dim_group_key = vol_changes.dim_group_key
AND size.dim_group_key = vol_changes.dim_group_key
AND week.week = vol_changes.week
AND dim_cta_key.dim_cta_key = vol_changes.dim_cta_key;


/*regression with prev price, prev vol, sum vol, sum price*/
CREATE VIEW reg15_vol AS
SELECT *
FROM
vol_changes, dairy, flavor, brand, size, week, dim_cta_key, prev_price, cta_ag
WHERE dairy.dim_group_key = vol_changes.dim_group_key
AND flavor.dim_group_key = vol_changes.dim_group_key
AND brand.dim_group_key = vol_changes.dim_group_key
AND size.dim_group_key = vol_changes.dim_group_key
AND week.week = vol_changes.week
AND dim_cta_key.dim_cta_key = vol_changes.dim_cta_key
AND vol_changes.dim_group_key = prev_price.dim_group_key
AND vol_changes.week = prev_price.week
AND vol_changes.dim_cta_key = prev_price.dim_cta_key
AND vol_changes.week = cta_ag.week
AND vol_changes.dim_cta_key = cta_ag.dim_cta_key;


/*regression with prev price, prev vol, sum vol, sum price*/
CREATE VIEW reg17 AS
SELECT *
FROM
vol_changes, dairy, flavor, brand, size, dim_cta_key, prev_price, cta_ag
WHERE dairy.dim_group_key = vol_changes.dim_group_key
AND flavor.dim_group_key = vol_changes.dim_group_key
AND brand.dim_group_key = vol_changes.dim_group_key
AND size.dim_group_key = vol_changes.dim_group_key
AND dim_cta_key.dim_cta_key = vol_changes.dim_cta_key
AND vol_changes.dim_group_key = prev_price.dim_group_key
AND vol_changes.week = prev_price.week
AND vol_changes.dim_cta_key = prev_price.dim_cta_key
AND vol_changes.week = cta_ag.week
AND vol_changes.dim_cta_key = cta_ag.dim_cta_key;


/*regression with prev price, prev vol, sum vol, sum price*/
CREATE VIEW reg18 AS
SELECT *
FROM
vol_changes, dairy, flavor, brand, size, prev_price, cta_ag
WHERE dairy.dim_group_key = vol_changes.dim_group_key
AND flavor.dim_group_key = vol_changes.dim_group_key
AND brand.dim_group_key = vol_changes.dim_group_key
AND size.dim_group_key = vol_changes.dim_group_key
AND vol_changes.dim_group_key = prev_price.dim_group_key
AND vol_changes.week = prev_price.week
AND vol_changes.dim_cta_key = prev_price.dim_cta_key
AND vol_changes.week = cta_ag.week
AND vol_changes.dim_cta_key = cta_ag.dim_cta_key;


/*regression with prev price, prev vol, sum vol, sum price*/
CREATE VIEW reg18_fixed AS
SELECT *
FROM
vol_changes, dairy, flavor, brand, size, prev_price, week_ag
WHERE dairy.dim_group_key = vol_changes.dim_group_key
AND flavor.dim_group_key = vol_changes.dim_group_key
AND brand.dim_group_key = vol_changes.dim_group_key
AND size.dim_group_key = vol_changes.dim_group_key
AND vol_changes.dim_group_key = prev_price.dim_group_key
AND vol_changes.week = prev_price.week
AND vol_changes.dim_cta_key = prev_price.dim_cta_key
AND vol_changes.week = week_ag.week;


/*dropping CTA dummies and including weeks to see what happens*/
CREATE VIEW reg19 AS
SELECT *
FROM
vol_changes, dairy, flavor, brand, size, prev_price, week_ag, week
WHERE dairy.dim_group_key = vol_changes.dim_group_key
AND flavor.dim_group_key = vol_changes.dim_group_key
AND brand.dim_group_key = vol_changes.dim_group_key
AND size.dim_group_key = vol_changes.dim_group_key
AND vol_changes.dim_group_key = prev_price.dim_group_key
AND vol_changes.week = prev_price.week
AND vol_changes.dim_cta_key = prev_price.dim_cta_key
AND vol_changes.week = week_ag.week
AND week.week = vol_changes.week;