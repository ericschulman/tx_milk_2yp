WITH averages AS  
	(SELECT group_edps.week, dairy.dairy, flavor.flavor, prod_size.s32,  
	prod_size.s48, prod_size.s64, avg(group_edps.price) as avg_price, 
	sum(group_edps.eq_vol) as total_vol FROM  
	group_edps, dairy, flavor, prod_size  
	WHERE dairy.dim_group_key = group_edps.dim_group_key  
	AND flavor.dim_group_key = group_edps.dim_group_key   
	AND prod_size.dim_group_key = group_edps.dim_group_key  
	AND group_edps.price <>  ''
	AND group_edps.eq_vol  <>  ''
	AND dairy.dairy = 1
	AND flavor.flavor = 0 
	AND prod_size.s32 = 1 
	AND prod_size.s64 = 0
	AND prod_size.s48 = 0
	GROUP BY group_edps.week, dairy.dairy, flavor.flavor, 
	prod_size.s32, prod_size.s48, prod_size.s64)  
    
    SELECT averages.avg_price -group_edps.price,  
    group_edps.eq_vol/averages.total_vol,  
    group_edps.week, dairy.dairy, flavor.flavor, prod_size.s32,  
    prod_size.s48, prod_size.s64  

	FROM group_edps, dairy, flavor, brand, prod_size, averages  

	WHERE group_edps.week =	averages.week  
	AND dairy.dairy = 	averages.dairy  
	AND flavor.flavor = averages.flavor  
	AND prod_size.s32 = averages.s32  
	AND prod_size.s48 = averages.s48  
	AND prod_size.s64 = averages.s64  

	AND dairy.dim_group_key = group_edps.dim_group_key  
	AND flavor.dim_group_key = group_edps.dim_group_key   
	AND brand.dim_group_key = group_edps.dim_group_key   
	AND prod_size.dim_group_key = group_edps.dim_group_key  

	AND group_edps.price <> ''
	AND group_edps.eq_vol  <> ''

	AND dairy.dairy = 1
	AND flavor.flavor = 0 
	AND prod_size.s32 = 1 
	AND prod_size.s64 = 0
	AND prod_size.s48 = 0
	AND brand.CM = 0
	AND brand.DD = 1
	AND brand.ID = 0
	AND brand.PL = 0