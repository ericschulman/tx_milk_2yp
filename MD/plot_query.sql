/*This query is for making the actual plots*/
WITH category AS (SELECT group_edps.dim_group_key, group_edps.dim_cta_key, 
	group_edps.week, group_edps.price,group_edps.edp, group_edps.eq_vol 
	FROM group_edps, prod_size
	WHERE prod_size.dim_group_key = group_edps.dim_group_key 
	AND group_edps.dim_cta_key = 4
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
	WHERE a.week = (b.week + 2) 
	AND a.dim_cta_key = b.dim_cta_key 
	AND a.dim_group_key = b.dim_group_key 
	AND a.dim_group_key = 'BA_16_D_F'
	AND a.price <>  '' 
	AND b.price  <> ''  
	AND ((a.price-a.edp > .25) OR (a.edp - a.price > .25)) )

	SELECT categoryp.price - category_averages.avg_price, 
	categoryp.price - categoryp.prev_price, 
	categoryp.eq_vol/category_averages.total_vol,
	categoryp.dim_group_key, categoryp.week 
	FROM category_averages, categoryp 
	WHERE categoryp.week = category_averages.week;

/*This query is for ordering the CTAs to choose which to use*/
WITH category AS (SELECT group_edps.dim_group_key, group_edps.dim_cta_key, 
	group_edps.week, group_edps.price,group_edps.edp, group_edps.eq_vol,
	group_edps.eq_vol*group_edps.price as revenue 
	FROM group_edps, prod_size
	WHERE prod_size.dim_group_key = group_edps.dim_group_key 
	AND group_edps.price <>  '' 
	AND group_edps.eq_vol  <> '' 
	AND (prod_size.s48 = 0 AND prod_size.s64 = 0) ),

	cta_view AS (SELECT dim_cta_key, 
	COUNT(DISTINCT dim_group_key) AS groups, 
	sum(eq_vol) AS total_vol, sum(revenue) AS total_rev
	FROM category GROUP BY dim_cta_key )

SELECT * FROM cta_view
ORDER BY total_vol