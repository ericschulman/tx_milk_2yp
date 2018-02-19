import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import statsmodels.api as sm
import math
import sqlite3
import numpy as np
import os

CTAS = [6,166,128,5]
TIME = 2
DIFF = .02


def create_fname(cta):
	""" ensures all the file names are the same"""
	return 'plots_%s_t%s_cta%s'%( str(int(100*DIFF)) ,TIME, cta)


def create_query(group,cta):
	"""helper function designed to engineer query for each of the tables"""

	query =  ("WITH category AS (SELECT group_edps.dim_group_key, group_edps.dim_cta_key, "+
	"group_edps.week, group_edps.price, group_edps.edp, group_edps.eq_vol "+
	"FROM group_edps, prod_size "+
	"WHERE prod_size.dim_group_key = group_edps.dim_group_key "+
	("AND group_edps.dim_cta_key = %s "%cta) +

	"AND group_edps.price <>  '' "+
	"AND group_edps.eq_vol  <> '' "+
	"AND (prod_size.s48 = 0 AND prod_size.s64 = 0) ), "+

	"category_averages AS (SELECT category.week,  "+
	"avg(category.price) as avg_price,  "+
	"sum(category.eq_vol) as total_vol "+
	"FROM category "+
	"GROUP BY category.week), "+

	"categoryp AS (SELECT a.dim_group_key, a.week,  "+
	"b.price as prev_price, b.eq_vol as prev_vol, "+
	"a.price, a.eq_vol "+
	"FROM category AS a, category AS b "+
	"WHERE a.week = (b.week+%s) "%TIME +
	"AND a.dim_cta_key = b.dim_cta_key "+
	"AND a.dim_group_key = b.dim_group_key "+
	("AND a.dim_group_key = '%s' "%group)+
	"AND a.price <>  '' "+
	"AND b.price  <> '' " +
	"AND ((a.price-a.edp > %s) OR (a.edp - a.price > %s)) ) "%(DIFF,DIFF)+

	"SELECT categoryp.price - A.avg_price, "+
	"categoryp.price - categoryp.prev_price, "+
	"categoryp.eq_vol, categoryp.prev_vol, A.total_vol, B.total_vol, "+
	"categoryp.dim_group_key, categoryp.week "+
	"FROM category_averages as A, category_averages as B, " +
	"categoryp "+
	"WHERE categoryp.week = A.week " +
	("AND categoryp.week = (B.week + %s); "%TIME))

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


def calc_q(qi,qt,Q,Qt):
	return math.log(qi/Q) - math.log(qt/Qt)


def create_3dplot(group,cta):
	con = sqlite3.connect('data/edp_changes.db')
	cur = con.cursor()
	q = create_query(group,cta)
	x =[]
	y = []
	z= []
	cur.execute(q)

	fig = plt.figure()
	ax = fig.add_subplot(111, projection='3d')
	
	for row in cur:
		x.append ( safe_float(row[0]) )
		y.append ( safe_float(row[1]) )
		q = calc_q(safe_float(row[2]),safe_float(row[3]),safe_float(row[4]),safe_float(row[5])) 
		z.append ( q )

	ax.scatter(x, y, z)
	ax.set_xlabel('P_{i,t} - P_{avg,t}')
	ax.set_ylabel('P_{i,t}-P_{i,t-1}')
	ax.set_zlabel('V_{i,t}/V_{tot,t}')

	plt.savefig('results/%s/3d/%s.png'%(create_fname(cta), group))
	plt.close()


def create_plot(group,cta):
	con = sqlite3.connect('data/edp_changes.db')
	cur = con.cursor()
	q = create_query(group,cta)
	x =[]
	y = []
	z= []
	cur.execute(q)

	fig = plt.figure()
	
	for row in cur:
		x.append( safe_float(row[0]) )
		y.append ( safe_float(row[1]) )
		q = calc_q(safe_float(row[2]),safe_float(row[3]),safe_float(row[4]),safe_float(row[5]))
		z.append ( q )

	plt.plot(x,z,'ro')
	plt.savefig('results/%s/p_avg/%s.png'%(create_fname(cta), group))
	plt.close()

	plt.plot(y,z,'ro')
	plt.savefig('results/%s/p_t/%s.png'%(create_fname(cta), group))
	plt.close()

	plt.plot(x,y,'ro')
	plt.savefig('results/%s/t_avg/%s.png'%(create_fname(cta), group))
	plt.close()


def make_all_folders(cta):
	"""set up the required folder structure"""
	make_folder('results/%s/'%(create_fname(cta)))
	make_folder('results/%s/3d/'%(create_fname(cta)))
	make_folder('results/%s/t_avg/'%(create_fname(cta)))
	make_folder('results/%s/p_t/'%(create_fname(cta)))
	make_folder('results/%s/p_avg/'%(create_fname(cta)))


def create_all_plots(cta):
	"""combines all the functions to make all the plots"""
	con = sqlite3.connect('data/edp_changes.db')
	cur = con.cursor()
	cur.execute(( "select * from group_edps "+
		" where group_edps.dim_cta_key = %s group by dim_group_key"%cta) )

	groups = cur.fetchall()
	for group in groups:
		if  (('64' not in  str(group[0]))
		and ('48' not in  str(group[0]))) :
			create_plot(str(group[0]),cta)
			create_3dplot(str(group[0]),cta)


def make_all_plots_all_ctas():
	for cta in CTAS:
		make_all_folders(cta)
		create_all_plots(cta)



if __name__ == "__main__":
	make_all_plots_all_ctas()