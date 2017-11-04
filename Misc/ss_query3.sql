WITH category AS (SELECT group_edps.dim_group_key, group_edps.dim_cta_key, 
	group_edps.week, group_edps.price, group_edps.eq_vol
	FROM group_edps, prod_size, brand
	WHERE prod_size.dim_group_key = group_edps.dim_group_key
	AND brand.dim_group_key = group_edps.dim_group_key
	AND (brand.CM = 1 OR brand.ID = 1 OR brand.PL = 1)
	AND group_edps.price <>  ''
	AND group_edps.eq_vol  <> ''
	AND (prod_size.s48 = 0 AND prod_size.s64 = 0) ),

	category_averages AS (SELECT category.week, 
	avg(category.price) as avg_price, 
	sum(category.eq_vol) as total_vol
	FROM category
	GROUP BY category.week),

	categoryp AS (SELECT a.dim_group_key, a.week, 
	b.price as prev_price, a.price, a.eq_vol
	FROM category AS a, category AS b
	WHERE a.week = (b.week+1)
	AND a.dim_cta_key = b.dim_cta_key
	AND a.dim_group_key = b.dim_group_key
	AND a.dim_group_key = 'ID_32_N_F'
	AND a.price <>  ''
	AND b.price  <> '')

SELECT categoryp.price - category_averages.avg_price, categoryp.price - categoryp.prev_price, 
	categoryp.eq_vol/category_averages.total_vol,
	categoryp.dim_group_key, categoryp.week
	FROM category_averages, categoryp
	WHERE categoryp.week = category_averages.week;