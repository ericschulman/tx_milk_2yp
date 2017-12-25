import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import math
import sqlite3
import numpy as np
import os

CTA = 4
TIME = 2
DIFF = .02
FNAME = 'plots_%s_t%s_cta%s'%( str(int(100*DIFF)) ,TIME, CTA)

def create_query(group):
	"""helper function designed to engineer query for each of the tables"""

	query =  ("WITH category AS (SELECT group_edps.dim_group_key, group_edps.dim_cta_key, "+
	"group_edps.week, group_edps.price, group_edps.edp, group_edps.eq_vol "+
	"FROM group_edps, prod_size "+
	"WHERE prod_size.dim_group_key = group_edps.dim_group_key "+
	("AND group_edps.dim_cta_key = %s "%CTA) +

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
	"WHERE a.week = (b.week+%s) "%TIME +
	"AND a.dim_cta_key = b.dim_cta_key "+
	"AND a.dim_group_key = b.dim_group_key "+
	("AND a.dim_group_key = '%s' "%group)+
	"AND a.price <>  '' "+
	"AND b.price  <> '' " +
	"AND ((a.price-a.edp > %s) OR (a.edp - a.price > %s)) ) "%(DIFF,DIFF)+

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


def create_3dplot(group):
	con = sqlite3.connect('data/edp_changes.db')
	cur = con.cursor()
	q = create_query(group)
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

	plt.savefig('results/%s/3d/%s.png'%(FNAME, group))
	plt.close()


def create_plot(group):
	con = sqlite3.connect('data/edp_changes.db')
	cur = con.cursor()
	q = create_query(group)
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
	plt.savefig('results/%s/p_avg/%s.png'%(FNAME, group))
	plt.close()

	plt.plot(y,z,'ro')
	plt.savefig('results/%s/p_t/%s.png'%(FNAME, group))
	plt.close()

	plt.plot(x,y,'ro')
	plt.savefig('results/%s/t_avg/%s.png'%(FNAME, group))
	plt.close()


def make_all_folders():
	make_folder('results/%s/'%(FNAME))
	make_folder('results/%s/3d/'%(FNAME))
	make_folder('results/%s/t_avg/'%(FNAME))
	make_folder('results/%s/p_t/'%(FNAME))
	make_folder('results/%s/p_avg/'%(FNAME))

def create_all_plots():

	con = sqlite3.connect('data/edp_changes.db')
	cur = con.cursor()
	cur.execute(( "select * from group_edps "+
		" where group_edps.dim_cta_key = %s group by dim_group_key"%CTA) )

	groups = cur.fetchall()
	for group in groups:
		if  (('64' not in  str(group[0]))
		and ('48' not in  str(group[0]))) :
			create_plot(str(group[0]))
			create_3dplot(str(group[0]))

if __name__ == "__main__":
	make_all_folders()
	create_all_plots()
