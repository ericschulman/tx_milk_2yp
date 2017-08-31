import numpy as np
import statsmodels.api as sm
import statsmodels.formula.api as smf
import sqlite3
import csv
import os
from statsmodels.sandbox.regression.gmm import IV2SLS 

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
	con.close()


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
	"""setup list of group dummy variables in the database"""
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


def safe_float(x):
	"""convert to float or return nan"""
	try:
		return float(str(x))
	except:
		return float('NaN')


def set_up_regress(sql_file):
	con = sqlite3.connect('data/edp_changes.db') #create the db
	cur = con.cursor()
	f = open('%s.sql'%sql_file,'r')
	sql = f.read()
	cur.executescript(sql)
	con.commit()
	con.close()


def regress(sql_file, view_name, omit, log=False):
	"""Used for a test regression, will take a database query as an argument, and
	return what is necessary eventually

	name is the name of the table, and omit is the columns to remove from the query
	because sqlite doesn't support dropping columns
	sql_file names the file that generates the relevant tables and the folder where results go"""
	
	con = sqlite3.connect('data/edp_changes.db')
	cur = con.cursor()


	#get regressors from the db
	cur.execute('select * from %s'%view_name)
	regressors = cur.fetchall()
	regressors = np.array([ np.array([safe_float(j) for j in i]).astype(np.float)
			 for i in regressors])

	regressors = np.delete(regressors, omit, axis = 1)
	
	#delete nan lines
	regressors = regressors[~np.isnan(regressors).any(axis=1)]

	y = regressors[:,2]

	if (log == True):
		y = np.log(y)

	#set up instruments
	X = regressors
	X = np.delete(X, 2, axis = 1)
	X = sm.add_constant(X)

	#clean the endogenous explanatory variable of endogeneity
	stage1 = sm.OLS(y,X).fit()

	#write stage 1 results

	file_path_tex = 'results/%s/tex/result_%s.'%(sql_file,view_name)
	file_path_txt = 'results/%s/txt/result_%s.'%(sql_file,view_name)
	if(log==True):
		file_path_tex = 'results/%s/tex/result_%s_log.'%(sql_file,view_name)
		file_path_txt = 'results/%s/txt/result_%s_log.'%(sql_file,view_name)

	result_doc = open(file_path_txt +'txt','w+')
	result_doc.write( stage1.summary().as_text() )
	result_doc.close()

	result_doc = open(file_path_tex +'tex','w+')
	result_doc.write( stage1.summary().as_latex() )
	result_doc.close()


def regressIV(sql_file, view_name, result_name, instr_list, endog_ind, omit,log=False):
	"""Used for a test regression, will take a database query as an argument, and
	return what is necessary eventually

	name is the name of the table, and omit is the columns to remove from the query
	because sqlite doesn't support dropping columns
	sql_file names the file that generates the relevant tables and the folder where results go"""
	
	con = sqlite3.connect('data/edp_changes.db')
	cur = con.cursor()


	#get regressors from the db
	cur.execute('select * from %s'%view_name)
	regressors = cur.fetchall()
	regressors = np.array([ np.array([safe_float(j) for j in i]).astype(np.float)
			 for i in regressors])

	regressors = np.delete(regressors, omit, axis = 1)
	
	#delete nan lines
	regressors = regressors[~np.isnan(regressors).any(axis=1)]

	########stage 1############
	endog = regressors[:,endog_ind]

	#set up instruments
	instr = regressors
	instr = np.delete(instr, [2,endog_ind], axis = 1)
	instr = sm.add_constant(instr)

	#clean the endogenous explanatory variable of endogeneity
	stage1 = sm.OLS(endog,instr).fit()

	#write stage 1 results
	result_doc = open('results/%s/txt/result_%s_s1.txt'%(sql_file,result_name),'w+')
	result_doc.write( stage1.summary().as_text() )
	result_doc.close()

	result_doc = open('results/%s/tex/result_%s_s1.tex'%(sql_file,result_name),'w+')
	result_doc.write( stage1.summary().as_latex() )
	result_doc.close()


	#########stage 2########
	#save vol as the explanatory variable
	y = regressors[:,2]
	if (log == True):
		y = np.log(y)

	#set up exog array for stage 2
	clean = stage1.fittedvalues
	clean = np.reshape(clean,(len(clean),1))

	exog = np.delete(regressors, [instr_list], axis = 1)
	exog = np.append(clean,exog,axis=1)
	exog = sm.add_constant(exog)

	stage2 = sm.OLS(y,exog).fit()

	#write results
	result_doc = open('results/%s/txt/results_%s_s2.txt'%(sql_file,result_name),'w+')
	result_doc.write( stage2.summary().as_text() )
	result_doc.close()

	result_doc = open('results/%s/tex/results_%s_s2.tex'%(sql_file,result_name),'w+')
	result_doc.write( stage2.summary().as_latex() )
	result_doc.close()




def run_reg():
	"""code for running the regressions in reg.sql"""
	regress('reg','reg1',[0,1,2,4,5,7,8])
	regress('reg','reg2',[0,1,2,4,5,7,8,10,12,17])
	regress('reg','reg3',[0,1,2,4,5,7,8,10,12,17,21])
	regress('reg','reg4',[0,1,2,4,5,7,8,10,12,17,21])
	regress('reg','reg5',[0,1,2,4,5,7,8])
	regress('reg','reg6',[0,1,2,4,5,7,8,165])
	regress('reg','reg7',[0,1,2,4,5,7,8,13])
	regress('reg','reg8',[0,1,2,4,5,7,8,10,12,17,21,178])
	regress('reg','reg9',[0])
	regress('reg','reg10',[0])
	regress('reg','reg11',[0])
	regress('reg','reg12',[0])
	regress('reg','reg13',[0,1,2,4,5,7,8,10,12,17,21,22,23,26,27,28,31])
	regress('reg','reg14',[0,1,2,4,5,7,8,10,12,17,21,22,23,26,27,28,31,32])
	regress('reg','reg15',[0,1,2,4,5,7,8,10,12,17,21,178,209,210,211,214,215,216,219,220])
	regress('reg','reg1_fixed',[0,1,2,4,5,7,8,13,14,15])
	regress('reg','reg2_fixed',[0,1,2,4,5,7,8,10,12,17,21,22,23])
	regress('reg','reg15_vol',[0,1,2,4,5,7,8,10,12,17,21,178,209,210,211,214,215])
	regress('reg','reg2_vol',[0,1,2,4,5,7,8,10,12,17])
	regress('reg','reg3_vol',[0,1,2,4,5,7,8,10,12,17,21])
	regress('reg','reg4_vol',[0,1,2,4,5,7,8,10,12,17,21])
	regress('reg','reg8_vol',[0,1,2,4,5,7,8,10,12,17,21,178])
	regress('reg','reg17',[0,1,2,4,5,7,8,10,12,17,21,52,53,54,57,58])
	regress('reg','reg18',[0,1,2,4,5,7,8,10,12,17,21,22,23,26,27])
	regress('reg','reg18_fixed',[0,1,2,4,5,7,8,10,12,17,21,22,23,26])
	regress('reg','reg19',[0,1,2,4,5,7,8,10,12,17,21,22,23,26,29])


def run_reg_good():
	regress('reg','reg15_vol',[0,1,2,4,5,7,8,10,12,17,21,178,209,210,211,214,215])
	regress('reg','reg17',[0,1,2,4,5,7,8,10,12,17,21,52,53,54,57,58])
	regress('reg','reg18_fixed',[0,1,2,4,5,7,8,10,12,17,21,22,23,26])
	regress('reg','reg19',[0,1,2,4,5,7,8,10,12,17,21,22,23,26,29])


def run_regf():
	"""code for running the regressions in regf.sql"""
	regress('regf','regf1',[0,1,2,5,7,8,10,12,17,21,22,23,26])
	regress('regf','regf2',[0,1,2,5,7,8,10,12,17,21,22,23,26,29])
	regress('regf','regf3',[0,1,2,5,7,8,10,12,17,21,22,23,26,29])
	regress('regf','regf4',[0,1,2,5,7,8,10,12,17,21,22,23,26,29,60])


def run_regf_IV():
	regressIV('regf','regf1', 'past', [0,2,12,13], 0, [0,1,2,5,7,8,10,12,17,21,22,23,26])
	regressIV('regf','regf1', 'edp', [0,1,2,12,13], 0, [0,1,2,5,7,8,10,12,17,21,22,23,26])


def run_reg3():
	regress('reg3', 'reg31', [0,1,2,5,7,8,10,12,17,21,22,23,26,27,28,31,32,33])
	regress('reg3', 'reg31', [0,1,2,5,7,8,10,12,17,21,22,23,26,27,28,31,32,33],    log=True)
	#regress('reg3', 'reg32', [0,1,2,5,7,8,10,12,17,21,22,23,26,27,28,31,32,33,36], log=True)
	regress('reg3', 'reg33', [0,1,2,5,7,8,10,12,17,21,22,23,26,27,28,31,32,33,36], log=True)
	#regress('reg3', 'reg34', [0,1,2,5,7,8,10,12,17,21,22,23,26,27,28])
	regressIV('reg3', 'reg31', 'reg31iv1', [0,2,12,13],   0, [0,1,2,5,7,8,10,12,17,21,22,23,26,27,28,31,32,33],    log=True)
	#regressIV('reg3', 'reg31', 'reg31iv2', [0,1,2,12,13], 0, [0,1,2,5,7,8,10,12,17,21,22,23,26,27,28,31,32,33],    log=True)
	#regressIV('reg3', 'reg32', 'reg32iv1', [0,2,12,13],   0, [0,1,2,5,7,8,10,12,17,21,22,23,26,27,28,31,32,33,36], log=True)
	#regressIV('reg3', 'reg33', 'reg33iv1', [0,2,12,13],   0, [0,1,2,5,7,8,10,12,17,21,22,23,26,27,28,31,32,33,36], log=True)

if __name__ == "__main__":
	setup_db()
	set_up_regress('reg3')
	run_reg3()




	