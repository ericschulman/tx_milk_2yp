import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import math
import sqlite3
import numpy as np
import os

def create_query(group, t, filtered):
	"""helper function designed to engineer query for each of the tables"""

	query =  ("WITH category AS (SELECT group_edps.dim_group_key, group_edps.dim_cta_key, "+
	"group_edps.week, group_edps.price, group_edps.eq_vol "+
	"FROM group_edps, prod_size, brand "+
	"WHERE prod_size.dim_group_key = group_edps.dim_group_key "+
	"AND brand.dim_group_key = group_edps.dim_group_key ")

	if filtered:
		query = query +	"AND (brand.CM = 1 OR brand.ID = 1 OR brand.PL = 1) "

	query = (query +
	"AND group_edps.price <>  '' "+
	"AND group_edps.eq_vol  <> '' "+
	"AND (prod_size.s48 = 0 AND prod_size.s64 = 0) ), "+

	"category_averages AS (SELECT category.week,  "+
	"avg(category.price) as avg_price,  "+
	"sum(category.eq_vol) as total_vol "+
	"FROM category "+
	"GROUP BY category.week), "+

	"categoryp AS (SELECT a.dim_group_key, a.week,  "+
	"b.price as prev_price, a.price, a.eq_vol "+
	"FROM category AS a, category AS b "+
	"WHERE a.week = (b.week+%s) "%t +
	"AND a.dim_cta_key = b.dim_cta_key "+
	"AND a.dim_group_key = b.dim_group_key "+
	("AND a.dim_group_key = '%s' "%group)+
	"AND a.price <>  '' "+
	"AND b.price  <> '') "+

	"SELECT categoryp.price - category_averages.avg_price, "+
	"categoryp.price - categoryp.prev_price, "+
	"categoryp.eq_vol/category_averages.total_vol,"+
	"categoryp.dim_group_key, categoryp.week "+
	"FROM category_averages, categoryp "+
	"WHERE categoryp.week = category_averages.week; ")

	return query


def safe_float(x):
	"""convert to float or return nan"""
	try:
		return float(str(x))
	except:
		return 0


def make_folder(folder):
	"""makes a folder in the figures directory with the
	specified name
	returns the name of the folder"""
	if not os.path.exists(folder):
		os.makedirs(folder)
	return folder


def create_3dplot(group, t, filtered):
	con = sqlite3.connect('data/edp_changes.db')
	cur = con.cursor()
	q = create_query(group, t, filtered)
	x =[]
	y = []
	z= []
	cur.execute(q)

	fig = plt.figure()
	ax = fig.add_subplot(111, projection='3d')
	
	for row in cur:
		x.append ( safe_float(row[0]) )
		y.append ( safe_float(row[1]) )
		z.append ( safe_float(row[2]) )

	ax.scatter(x, y, z)
	ax.set_xlabel('P_{i,t} - P_{avg,t}')
	ax.set_ylabel('P_{i,t}-P_{i,t-1}')
	ax.set_zlabel('V_{i,t}/V_{tot,t}')

	make_folder('plots3/t%s_%s/3d/'%(t,filtered))
	plt.savefig('plots3/t%s_%s/3d/%s.png'%(t,filtered,group))
	plt.close()


def create_plot(group, t, filtered):
	con = sqlite3.connect('data/edp_changes.db')
	cur = con.cursor()
	q = create_query(group, t, filtered)
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

	make_folder('plots3/t%s_%s/p_avg/'%(t,filtered))
	plt.savefig('plots3/t%s_%s/p_avg/%s.png'%(t,filtered,group))
	plt.close()

	plt.plot(y,z,'ro')
	make_folder('plots3/t%s_%s/p_t/'%(t,filtered))
	plt.savefig('plots3/t%s_%s/p_t/%s.png'%(t,filtered,group))
	plt.close()

	plt.plot(x,y,'ro')
	make_folder('plots3/t%s_%s/t_avg/'%(t,filtered))
	plt.savefig('plots3/t%s_%s/t_avg/%s.png'%(t,filtered,group))
	plt.close()

def create_all_plots():

	groups1 = ["BA_16_D_F","BA_32_D_F",
	"CM_16_D_F","CM_16_N_F",
	"CM_32_N_F","CM_32_N_U",
	"DD_32_N_F","ID_16_D_F",
	"ID_16_N_F","ID_32_N_F","PL_16_D_U",
	"PL_16_N_F","PL_16_N_U","PL_32_D_F","PL_32_D_U",
	"PL_32_N_F","PL_32_N_U"]

	groups2 = ["CM_16_D_F","CM_16_N_F",
	"CM_32_N_F","CM_32_N_U",
	"ID_16_D_F","ID_16_N_F","ID_32_N_F","PL_16_D_U",
	"PL_16_N_F","PL_16_N_U","PL_32_D_F","PL_32_D_U",
	"PL_32_N_F","PL_32_N_U"]

	for time in {1,2}:
		for filtered in {True,False}:
			groups = groups1
			if filtered:
				groups = groups2
			for group in groups:
				make_folder('plots3/t%s_%s/'%(time,filtered))
				create_plot(group, time, filtered)

if __name__ == "__main__":
	create_all_plots()