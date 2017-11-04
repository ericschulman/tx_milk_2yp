import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import math
import sqlite3
import numpy as np

def create_query(brand, size, flavor, dairy):
	"""helper function designed to engineer query for each of the tables"""

	query = ('WITH category AS (SELECT group_edps.dim_group_key, group_edps.week, '+
	'group_edps.dim_cta_key, ' +
	'dairy.dairy, flavor.flavor, '+
	'prod_size.s32, prod_size.s48, prod_size.s64, '+
	'group_edps.price, group_edps.eq_vol '+
	'FROM group_edps, dairy, flavor, prod_size '+
	'WHERE dairy.dim_group_key = group_edps.dim_group_key '+ 
	'AND flavor.dim_group_key = group_edps.dim_group_key '+
	'AND prod_size.dim_group_key = group_edps.dim_group_key '+  
	"AND group_edps.price <>  '' "+
	"AND group_edps.eq_vol  <> '' "+
	('AND dairy.dairy = %s '%dairy)+
	('AND flavor.flavor = %s '%flavor)+
	('AND prod_size.s32 = %s '%size[0])+
	('AND prod_size.s64 = %s '%size[1])+
	('AND prod_size.s48 = %s ), '%size[2])+

	'category_averages AS  (SELECT category.week,  '+
	'category.dairy, category.flavor, '+
	'category.s32,category.s48, category.s64,  '+
	'avg(category.price) as avg_price,  '+
	'sum(category.eq_vol) as total_vol '+
	'FROM category '+
	'GROUP BY '+
	'category.week,  '+
	'category.dairy,  category.flavor,  '+
	'category.s32,  category.s48,  category.s64), '+

	'categoryp AS (SELECT a.dim_group_key, a.week, '+
	'a.dairy, a.flavor, a.s32, a.s48, a.s64,  '+
	'b.price as prev_price, a.price, a.eq_vol '+
	'FROM category AS a, category AS b '+
	'WHERE a.week = (b.week+1)  '+
	'AND a.dim_group_key = b.dim_group_key '+
	'AND b.dim_cta_key = a.dim_cta_key ' +
	"AND a.price <>  '' "+
	"AND a.eq_vol <>  '' " + 
	"AND b.price  <> ''  "+
	"AND b.eq_vol <>  '') " + 

    'SELECT categoryp.price - category_averages.avg_price,  '+
    'categoryp.price - categoryp.prev_price,  '+
	'categoryp.eq_vol/category_averages.total_vol, '+
	'categoryp.dim_group_key, categoryp.week, '+
	'categoryp.dairy, categoryp.flavor, '+
	'categoryp.s32, categoryp.s48, categoryp.s64 '+
	'FROM category_averages, categoryp, brand '+
	'WHERE brand.dim_group_key = categoryp.dim_group_key '+
	('AND brand.CM = %s '%brand[0])+
	('AND brand.DD = %s '%brand[1])+
	('AND brand.ID = %s '%brand[2])+
	('AND brand.PL = %s '%brand[3])+
	'AND categoryp.week = category_averages.week '+
	'AND categoryp.dairy = category_averages.dairy '+
	'AND categoryp.flavor = category_averages.flavor '+
	'AND categoryp.s32 = category_averages.s32 '+
	'AND categoryp.s48 = category_averages.s48 '+
	'AND categoryp.s64 = category_averages.s64 '+
	'AND brand.dim_group_key = categoryp.dim_group_key; ')

	return query


def safe_float(x):
	"""convert to float or return nan"""
	try:
		return float(str(x))
	except:
		return 0


def create_3dplot(group ):
	con = sqlite3.connect('data/edp_changes.db')
	cur = con.cursor()
	brand, size, flavor, dairy = group_decoder(group)
	q = create_query(brand, size, flavor, dairy)
	x =[]
	y = []
	z= []
	cur.execute(q)

	fig = plt.figure()
	ax = fig.add_subplot(111, projection='3d')
	
	for row in cur:
		x.append( safe_float(row[0]) )
		y.append ( safe_float(row[1]) )
		z.append ( safe_float(row[2]) )

	ax.scatter(x, y, z)
	ax.set_xlabel('P_{i,t} - P_{avg,t}')
	ax.set_ylabel('P_{i,t}-P_{i,t-1}')
	ax.set_zlabel('V_{i,t}/V_{tot,t}')

	plt.savefig('plots/3d/%s.png'%group)
	plt.close()


def create_plot(group):
	con = sqlite3.connect('data/edp_changes.db')
	cur = con.cursor()
	brand, size, flavor, dairy = group_decoder(group)
	q = create_query(brand, size, flavor, dairy)
	x =[]
	y = []
	z= []
	cur.execute(q)

	fig = plt.figure()
	
	for row in cur:
		x.append( safe_float(row[0]) )
		y.append ( safe_float(row[1]) )
		z.append ( safe_float(row[2]) )

	plt.plot(x,z,'ro')
	plt.savefig('plots/p_avg/%s.png'%group)
	plt.close()

	plt.plot(y,z,'ro')
	plt.savefig('plots/p_t/%s.png'%group)
	plt.close()

	plt.plot(x,y,'ro')
	plt.savefig('plots/t_avg/%s.png'%group)
	plt.close()


def group_decoder(group):
	brand_bool = (0,0,0,0)
	size_bool = (0,0,0)
	flavor_bool = 0
	dairy_bool = 0

	if 'CM_' in group:
		brand_bool = (1,0,0,0)
	if 'DD_' in group:
		brand_bool = (0,1,0,0)
	if 'ID_' in group:
		brand_bool = (0,0,1,0)
	if 'PL_' in group:
		brand_bool = (0,0,0,1)

	if '_32_' in group:
		size_bool = (1,0,0)
	if '_64_' in group:
		size_bool = (0,1,0)
	if '_48_' in group:
		size_bool = (0,0,1)

	if '_D_' in group:
		dairy_bool = 1
	if '_F' in group:
		flavor_bool = 1
	
	return brand_bool,size_bool,flavor_bool,dairy_bool
	

def create_all_plots():

	groups = ["BA_16_D_F","BA_32_D_F","CM_16_D_F","CM_16_N_F",
	"CM_32_N_F","CM_32_N_U","CM_64_N_F","CM_64_N_U","DD_32_N_F",
	"ID_16_D_F","ID_16_N_F","ID_32_N_F","ID_48_N_F","ID_64_D_F","PL_16_D_U",
	"PL_16_N_F","PL_16_N_U","PL_32_D_F","PL_32_D_U","PL_32_N_F","PL_32_N_U","PL_64_D_U"]

	for group in groups:
		create_plot(group)
		create_3dplot(group)

if __name__ == "__main__":
	create_all_plots()
