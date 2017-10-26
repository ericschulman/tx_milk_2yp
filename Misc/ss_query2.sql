WITH category AS (SELECT group_edps.dim_group_key, group_edps.week, 
	dairy.dairy, flavor.flavor,
	prod_size.s32, prod_size.s48, prod_size.s64, 
	group_edps.price, group_edps.eq_vol
	FROM group_edps, dairy, flavor, prod_size
	WHERE dairy.dim_group_key = group_edps.dim_group_key  
	AND flavor.dim_group_key = group_edps.dim_group_key
	AND prod_size.dim_group_key = group_edps.dim_group_key  
	AND group_edps.price <>  ''
	AND group_edps.eq_vol  <> '' 
	AND dairy.dairy = 1
	AND flavor.flavor = 0
	AND prod_size.s32 = 1 
	AND prod_size.s64 = 0 
	AND prod_size.s48 = 0 ),

	category_averages AS  (SELECT category.dim_group_key, category.week, 
	category.dairy, category.flavor,
	category.s32,category.s48, category.s64, 
	avg(category.price) as avg_price, 
	sum(category.eq_vol) as total_vol
	FROM category
	GROUP BY
	category.week, 
	category.dairy,  category.flavor, 
	category.s32,  category.s48,  category.s64),

	categoryp AS (SELECT a.dim_group_key, a.week,
	a.dairy, a.flavor, a.s32, a.s48, a.s64, 
	b.price as prev_price, a.price, a.eq_vol
	FROM category AS a, category AS b
	WHERE a.week = (b.week+1) 
	AND a.dim_group_key = b.dim_group_key
	AND a.price <>  ''
	AND b.price  <> '' )

    
SELECT categoryp.price - category_averages.avg_price, categoryp.price - categoryp.prev_price, 
	categoryp.eq_vol/category_averages.total_vol,
	categoryp.dim_group_key, categoryp.week,
	categoryp.dairy, categoryp.flavor,
	categoryp.s32, categoryp.s48, categoryp.s64
	FROM category_averages, categoryp, brand
	WHERE brand.dim_group_key = categoryp.dim_group_key
	AND brand.CM = 0
	AND brand.DD = 0
	AND brand.ID = 0 
	AND brand.PL = 1 
	AND categoryp.dim_group_key = category_averages.dim_group_key
	AND categoryp.week = category_averages.week
	AND categoryp.dairy = category_averages.dairy
	AND categoryp.flavor = category_averages.flavor
	AND categoryp.s32 = category_averages.s32
	AND categoryp.s48 = category_averages.s48
	AND categoryp.s64 = category_averages.s64
	AND brand.dim_group_key = categoryp.dim_group_key;