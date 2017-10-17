import numpy as np
import matplotlib.pyplot as plt
import math
import sqlite3
import numpy as np


# WITH averages AS 
# (SELECT group_edps.week, dairy.dairy, flavor.flavor, prod_size.s32, prod_size.s48, prod_size.s64, avg(group_edps.price) as avg_price, sum(group_edps.eq_vol) as total_vol FROM
# 	group_edps, dairy, flavor, brand, prod_size
# 	WHERE dairy.dim_group_key = group_edps.dim_group_key
# 	AND flavor.dim_group_key = group_edps.dim_group_key 
# 	AND brand.dim_group_key = group_edps.dim_group_key 
# 	AND prod_size.dim_group_key = group_edps.dim_group_key
# 	GROUP BY group_edps.week, dairy.dairy, flavor.flavor, prod_size.s32, prod_size.s48, prod_size.s64)

# SELECT group_edps.week, dairy.dairy, flavor.flavor, prod_size.s32, prod_size.s48, prod_size.s64, averages.avg_price, averages.total_vol, group_edps.eq_vol, group_edps.price 
# 	FROM
# 	group_edps, dairy, flavor, brand, prod_size, averages
# 	WHERE 
# 	group_edps.week =	averages.week
# 	AND dairy.dairy = 	averages.dairy
# 	AND flavor.flavor = averages.flavor 
# 	AND prod_size.s32 = averages.s32
# 	AND prod_size.s48 = averages.s48
# 	AND prod_size.s64 = averages.s64
# 	AND group_edps.dim_cta_key
# 	AND dairy.dim_group_key = group_edps.dim_group_key
# 	AND flavor.dim_group_key = group_edps.dim_group_key 
# 	AND brand.dim_group_key = group_edps.dim_group_key 
# 	AND prod_size.dim_group_key = group_edps.dim_group_key;

def create_query(brand, size, flavor, dairy):
	"""helper function designed to engineer query for each of the tables"""
	brand_bool = (0,0,0,0)
	if brand == 'CM':
		brand_bool = (1,0,0,0)
	if brand == 'DD':
		brand_bool = (0,1,0,0)
	if brand == 'ID':
		brand_bool = (0,0,1,0)
	if brand == 'PL':
		brand_bool = (0,0,0,1)

	size_bool = (0,0,0)
	if size == '32':
		size_bool = (1,0,0)
	if size == '64':
		size_bool = (0,1,0)
	if size == '48':
		size_bool = (0,0,1)

	query = ('WITH averages AS ' +
	'(SELECT group_edps.week, dairy.dairy, flavor.flavor, prod_size.s32, ' +
	'prod_size.s48, prod_size.s64, avg(group_edps.price) as avg_price, '
	'sum(group_edps.eq_vol) as total_vol FROM ' +
	'group_edps, dairy, flavor, brand, prod_size ' +
	'WHERE dairy.dim_group_key = group_edps.dim_group_key ' +
	'AND flavor.dim_group_key = group_edps.dim_group_key  ' +
	'AND brand.dim_group_key = group_edps.dim_group_key  ' +
	'AND prod_size.dim_group_key = group_edps.dim_group_key ' +
	'GROUP BY group_edps.week, dairy.dairy, flavor.flavor, '+
	'prod_size.s32, prod_size.s48, prod_size.s64) ' +
    
    'SELECT averages.avg_price, averages.total_vol, ' +
    'group_edps.eq_vol, group_edps.price,' + 
    'group_edps.week, dairy.dairy, flavor.flavor, prod_size.s32, ' +
    'prod_size.s48, prod_size.s64 ' +
	'FROM group_edps, dairy, flavor, brand, prod_size, averages ' +
	'WHERE group_edps.week =	averages.week ' +
	'AND dairy.dairy = 	averages.dairy ' +
	'AND flavor.flavor = averages.flavor ' +
	'AND prod_size.s32 = averages.s32 ' +
	'AND prod_size.s48 = averages.s48 ' +
	'AND prod_size.s64 = averages.s64 ' +
	'AND group_edps.dim_cta_key ' +
	'AND dairy.dim_group_key = group_edps.dim_group_key ' +
	'AND flavor.dim_group_key = group_edps.dim_group_key  ' +
	'AND brand.dim_group_key = group_edps.dim_group_key  ' +
	'AND prod_size.dim_group_key = group_edps.dim_group_key ' +
	('AND dairy.dairy = %s '%dairy )+
	('AND flavor.flavor = %s '%flavor )+
	('AND brand.CM = %s '%brand_bool[0] )+
	('AND brand.DD = %s '%brand_bool[1] )+
	('AND brand.ID = %s '%brand_bool[2] )+
	('AND brand.PL = %s '%brand_bool[3] )+
	('AND prod_size.s32 = %s '%size_bool[0] )+
	('AND prod_size.s64 = %s '%size_bool[1] )+
	('AND prod_size.s48 = %s ;'%size_bool[2] ) )

	#print(query)
	return query

def safe_float(x):
	"""convert to float or return nan"""
	try:
		return float(str(x))
	except:
		return 0

def safe_divide(x,y):
	try:
		return x/y
	except:
		return 0

def create_plot(brand, size, flavor, dairy):
	con = sqlite3.connect('data/edp_changes.db')
	cur = con.cursor()

	q = create_query(brand, size, flavor, dairy)
	x =[]
	y = []
	cur.execute(q)
	for row in cur:
		y.append( safe_divide(safe_float(row[2]),row[1]) )
		x.append ( safe_float(row[3]) -row[0] )
		plt.plot(x, y, 'ro')

	plt.savefig('plots/%s_%s_%s_%s.png'%(brand, size, flavor, dairy))
	plt.close()

def create_all_plots():
	for brand in ('DD','CM','ID','PL','BA'):
		for size in ('32','64','16','48'):
			for flavor in (0,1):
				for dairy in (0,1):
					 create_plot(brand, size, flavor, dairy)



if __name__ == "__main__":
	create_all_plots()
