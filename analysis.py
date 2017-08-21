import numpy as np
import statsmodels.api as sm
import statsmodels.formula.api as smf
import sqlite3
import csv
import os

def create_db():
	"""run the sql file to create the db"""
	db = 'data/edp_changes.db'
	f = open('data/edp_changes.sql','r')
	sql = f.read()
	if (os.path.isfile(db) ):
		os.remove(db)
	con = sqlite3.connect(db) #create the db
	cur = con.cursor()
	cur.executescript(sql)
	con.commit()


def load_initial():
	con = sqlite3.connect('data/edp_changes.db') #create the db
	cur = con.cursor()

	f = open('data/group_edps.csv')
	
	reader = csv.reader(f)
	headers = reader.next() #skip the header line
	for line in reader:
		cur.execute("INSERT INTO group_edps VALUES (?,?,?,?,?,?,?,?);", line)
		
	con.commit()
	con.close()
	f.close()


def create_dummy_tables(arg,type_arg):
	"""setup list of CTAS and group dummies in the database"""
	con = sqlite3.connect('data/edp_changes.db') #create the db
	cur = con.cursor()

	#first create a view to see the distinct categories
	query0 = "CREATE VIEW %s_view AS SELECT DISTINCT group_edps.%s"%(arg,arg)
	query0 = query0 + " FROM group_edps  GROUP BY group_edps.%s;"%(arg)

	cur.execute(query0)

	#then use the view to get all the unique listings
	query1 = 'select * from %s_view;'%arg 
	cur.execute(query1)
	results = cur.fetchall()
	query2 = 'CREATE TABLE %s (%s %s,'%(arg,arg,type_arg)

	#create all the various columns
	for row in range(1,len(results)):
		query2 = query2 + '`%s` INTEGER,'% (str(results[row][0]) )

	query2 = query2 + 'PRIMARY KEY(%s));'%arg
	cur.execute(query2)

	#create the dummy variables, finally
	query3 = 'INSERT INTO %s VALUES '%arg 
	line = [0]*(len(results))
	for row in range(len(results)):
		line[0] = results[row][0] if type_arg == 'INTEGER' else str(results[row][0])
		cur.execute(query3+str(tuple(line))+ ';')
		if (row < len(results)-1 ):
			line[row+1] = 1
			line[row] = 0
			

	con.commit()
	con.close()


def create_group_dummies():
	"""setup list of group dummies in the database"""
	query1 = 'select * from dim_group_key_view'
	con = sqlite3.connect('data/edp_changes.db') #create the db
	cur = con.cursor()
	cur.execute(query1)
	results = cur.fetchall()
	
	queryd = 'INSERT INTO dairy VALUES '
	queryf = 'INSERT INTO flavor VALUES '
	queryb = 'INSERT INTO brand  VALUES '
	querys = 'INSERT INTO size VALUES '
	
	for i in results:
		group = str(i[0])
		dairy = (group,1 if group.find('_D') >-1 else 0)
		
		flavor = (group,1 if group.find('_F') >-1 else 0)
		
		brand = (
			group, 1 if group.find('CM_') >-1 else 0,
			1 if group.find('DD_') >-1 else 0,
			1 if group.find('ID_') >-1 else 0,
			1 if group.find('PL_') >-1 else 0)
		
		size = (
			group,
			1 if group.find('_32') >-1 else 0,
			1 if group.find('_64') >-1 else 0,
			1 if group.find('_48') >-1 else 0)

		cur.execute(queryd+str(dairy)+ ';')
		cur.execute(queryf+str(flavor)+ ';')
		cur.execute(queryb+str(brand)+ ';')
		cur.execute(querys+str(size) + ';')

	con.commit()
	con.close()


def setup_db():
	"""use this function to set up the database before regressions"""
	create_db()
	load_initial()
	create_dummy_tables('dim_group_key','TEXT')
	create_dummy_tables('dim_cta_key','TEXT')
	create_dummy_tables('week','INTEGER')
	create_group_dummies()


def isfloat(value):
	try:
		float(value)
		return True
	except ValueError:
		return False

def sql_to_np(q):
	for i in q:
		for j in i:
			j = float(str(j)) if isfloat(str(j)) else float('nan')
	np.array([np.array(i) for i in q])




def regress():
	"""Used for a test regression, will take a database query as an argument, and
	return what is necessary eventually"""
	
	con = sqlite3.connect('data/edp_changes.db') #create the db
	cur = con.cursor()

	#get y from the db
	cur.execute('select eq_vol from group_edps')
	y = cur.fetchall()
	y =  np.array([i[0] for i in y])

	#get regressors from the db
	cur.execute('select * from reg1')
	regressors = cur.fetchall()
	regressors = sql_to_np(regressors)
	regressors = np.delete(regressors, [0,1,2,4,5,6,7,8], axis = 1)
	print (regressors)
	regressors = sm.add_constant(regressors)

	model = sm.GLS(y,regressors,missing = 'drop')
	fitted_model = model.fit()

	#write results
	result_doc = open('results1.txt','w+')
	result_doc.write( fitted_model.summary().as_text() )
	result_doc.close()



if __name__ == "__main__":
	setup_db()
	regress()
	