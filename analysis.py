
import numpy as np
import statsmodels.api as sm
import statsmodels.formula.api as smf
import sqlite3


def list_cta_groups():
	conn = sqlite3.connect('data/edp_changes.db')
	c = conn.cursor()
	query1 = ('SELECT DISTINCT group_edps.dim_cta_key, group_edps.dim_group_key ' +
			'FROM group_edps ' +
			'GROUP BY group_edps.dim_cta_key, group_edps.dim_group_key')
	result = []
	for row in c.execute(query1):
		result.append(row)
	return result


def gen_weekly_price_vol():
	"""generate a list of prices/volumes for each of the cta groups
	each week"""
	
	#set up db stuff
	conn = sqlite3.connect('data/edp_changes.db')
	c = conn.cursor()
	query1 = ("select group_edps.price, group_edps.eq_vol, group_edps.week "
	+ "from group_edps "
	+ "where group_edps.dim_cta_key =? "
	+ "and group_edps.dim_group_key =? "
	+ "and (group_edps.week =? or group_edps.week=?)")
	
	#open 2 files (write simultaneously so that only 2 queries are necessary)
	price_doc = open('data/weekly_price.csv','w+')
	vol_doc = open('data/weekly_vol.csv','w+')
	price_doc.write('week,')
	vol_doc.write('week,')
	

	#set up cols
	cols = list_cta_groups()
	for col in cols:
		price_doc.write('"'+ str( (str(col[0]),str(col[1]),'price') ) + '",')
		vol_doc.write('"'+ str( (str(col[0]),str(col[1]),'vol') )   + '",')


	#iterate through each week to find all the other prices
	for i in range(1,158):
		print(i)
		price_doc.write("\n" + str(i)+",")
		vol_doc.write("\n" + str(i)+",")
		for col in cols:
			for row in c.execute( query1,(col[0],col[1],str(i),str(i-1),) ):
				if(row[2]==str(i)):
					price_doc.write( str(row[0]) +"," )
				if(row[2]==str(i-1)):
					vol_doc.write( str(row[1]) +"," )

	price_doc.close()
	vol_doc.close()


def cta_group_dummies():
	#setup list of CTAS and groups
	ctas = []
	groups = []
	conn = sqlite3.connect('data/edp_changes.db')
	c = conn.cursor()
	query1 = ('SELECT DISTINCT group_edps.dim_cta_key ' +
			'FROM group_edps ' +
			'GROUP BY group_edps.dim_cta_key')
	query2 = ('SELECT DISTINCT group_edps.dim_group_key ' +
			'FROM group_edps ' +
			'GROUP BY group_edps.dim_group_key')
	query3 = ('select group_edps.dim_cta_key, group_edps.week, '+
		'group_edps.dim_group_key, group_edps.price, group_edps.eq_vol '+
		'from group_edps')

	doc = open('data/edp_changes.csv','w+')
	doc.write ('week,price,vol,')

	for row in c.execute(query1):
		ctas.append(row[0])
		doc.write( str(row[0]) +',')
	
	for row in c.execute(query2):
		groups.append(row[0])
		doc.write( str(row[0]) +',')

	for row in c.execute(query3):
		doc.write('\n')
		doc.write('%s,%s,%s,'%(str(row[1]),str(row[3]),str(row[4])))

		for cta in ctas:
			dum = '1' if row[0] == cta else '0'
			doc.write(dum +',')

		for group in groups:
			#if group == 'PL_64_D_U': print 'made it'
			dum = '1' if str(row[2]) == str(group) else '0'
			#print ('group: %s, group(check): %s, dum:%s'% (str(group),str(row[2]),dum)) 
			doc.write(dum +',')

	doc.close()

def regress():
	"""Used for a test regression"""
	data = np.genfromtxt('data/edp_changes.csv', delimiter=',', names=True)
	vol = data['vol']

	#delete dummy variables to avoid collinearity
	np.delete(data,34)
	np.delete(data,3)

	#vol and week number are not useful right now
	np.delete(data,2)
	np.delete(data,0)

	regressors = np.matrix.transpose(data)
	regressors = sm.add_constant(regressors)
	regressors.astype(np.float)

	model = sm.OLS(vol,regressors,missing = 'drop')
	
	fitted_model = model.fit()

	result_doc = open('results.txt','w+')
	result_doc.write( fitted_model.summary() )
	resutl_doc.close()


	

	

if __name__ == "__main__":
	#cta_group_dummies()
	regress()