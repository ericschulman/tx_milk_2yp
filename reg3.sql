/*(vol -prev_vol = dairy + flavor + brand + size + prev_price + total_price + total_vol 

basic model, no adjustments*/
CREATE VIEW reg31 AS
SELECT *
FROM
group_edps, dairy, flavor, brand, size, prev_price, price_ratio, prev_vol
WHERE dairy.dim_group_key = group_edps.dim_group_key
AND flavor.dim_group_key = group_edps.dim_group_key
AND brand.dim_group_key = group_edps.dim_group_key
AND size.dim_group_key = group_edps.dim_group_key
AND group_edps.dim_group_key = prev_price.dim_group_key
AND group_edps.week = prev_price.week
AND group_edps.dim_cta_key = prev_price.dim_cta_key
AND group_edps.dim_group_key = price_ratio.dim_group_key
AND group_edps.week = price_ratio.week
AND group_edps.dim_cta_key = price_ratio.dim_cta_key
AND group_edps.dim_group_key = prev_vol.dim_group_key
AND group_edps.week = prev_vol.week
AND group_edps.dim_cta_key = prev_vol.dim_cta_key;


/*basic model above with week dummies*/
CREATE VIEW reg32 AS
SELECT *
FROM
group_edps, dairy, flavor, brand, size, prev_price, price_ratio, prev_vol, week
WHERE dairy.dim_group_key = group_edps.dim_group_key
AND flavor.dim_group_key = group_edps.dim_group_key
AND brand.dim_group_key = group_edps.dim_group_key
AND size.dim_group_key = group_edps.dim_group_key
AND group_edps.dim_group_key = prev_price.dim_group_key
AND group_edps.week = prev_price.week
AND group_edps.dim_cta_key = prev_price.dim_cta_key
AND group_edps.dim_group_key = price_ratio.dim_group_key
AND group_edps.week = price_ratio.week
AND group_edps.dim_cta_key = price_ratio.dim_cta_key
AND group_edps.dim_group_key = prev_vol.dim_group_key
AND group_edps.week = prev_vol.week
AND group_edps.dim_cta_key = prev_vol.dim_cta_key
AND week.week = group_edps.week;


/*basic model with CTA dummies (prices and volumes reflect this) */
CREATE VIEW reg33 AS
SELECT *
FROM
group_edps, dairy, flavor, brand, size, prev_price, price_ratio_cta, prev_vol, dim_cta_key
WHERE dairy.dim_group_key = group_edps.dim_group_key
AND flavor.dim_group_key = group_edps.dim_group_key
AND brand.dim_group_key = group_edps.dim_group_key
AND size.dim_group_key = group_edps.dim_group_key
AND dim_cta_key.dim_cta_key = group_edps.dim_cta_key
AND group_edps.dim_group_key = prev_price.dim_group_key
AND group_edps.week = prev_price.week
AND group_edps.dim_cta_key = prev_price.dim_cta_key
AND group_edps.week = price_ratio_cta.week
AND group_edps.dim_cta_key = price_ratio_cta.dim_cta_key
AND group_edps.dim_group_key = price_ratio_cta.dim_group_key
AND group_edps.dim_group_key = prev_vol.dim_group_key
AND group_edps.week = prev_vol.week
AND group_edps.dim_cta_key = prev_vol.dim_cta_key;


/*looking at volume changes as a regressand*/
CREATE VIEW reg34 AS
SELECT *
FROM
vol_changes, dairy, flavor, brand, size, prev_price, price_ratio
WHERE dairy.dim_group_key = vol_changes.dim_group_key
AND flavor.dim_group_key = vol_changes.dim_group_key
AND brand.dim_group_key = vol_changes.dim_group_key
AND size.dim_group_key = vol_changes.dim_group_key
AND vol_changes.dim_group_key = prev_price.dim_group_key
AND vol_changes.week = prev_price.week
AND vol_changes.dim_cta_key = prev_price.dim_cta_key
AND vol_changes.week = price_ratio.week
AND vol_changes.dim_cta_key = price_ratio.dim_cta_key
AND vol_changes.dim_group_key = price_ratio.dim_group_key;