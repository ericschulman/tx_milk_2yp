/*(vol -prev_vol = dairy + flavor + brand + size + prev_price + total_price + total_vol 

basic model, no adjustments*/
CREATE VIEW regf1 AS
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


/*basic model above with week dummies*/
CREATE VIEW regf2 AS
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


/*basic model with CTA dummies (prices and volumes reflect this) */
CREATE VIEW regf3 AS
SELECT *
FROM
vol_changes, dairy, flavor, brand, size, prev_price, cta_ag, dim_cta_key
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


/*basic model with CTA dummies and weekly dummies*/
CREATE VIEW regf4_vol AS
SELECT *
FROM
vol_changes, dairy, flavor, brand, size, prev_price, cta_ag, dim_cta_key, week
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