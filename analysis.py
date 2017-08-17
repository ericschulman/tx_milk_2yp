
import numpy as np
import statsmodels.api as sm
import statsmodels.formula.api as smf
import sqlite3


def regress():
	"""Used for a test regression"""
	data = np.genfromtxt('data/group_edps.csv', delimiter=',', names=True)
	vol = data['eq_vol']
	price = data['price']
	regressors = np.array([price])
	regressors = np.matrix.transpose(regressors)
	regressors = sm.add_constant(regressors)
	model = sm.OLS(vol,regressors,missing = 'drop')
	results = model.fit()
	print(results.summary())

def list_cta_groups():
	conn = sqlite3.connect('data/edp_changes.db')
	c = conn.cursor()
	query1 = ('SELECT DISTINCT group_edps.dim_cta_key, group_edps.dim_group_key ' +
			'FROM group_edps ' +
			'GROUP BY group_edps.dim_cta_key, group_edps.dim_group_key')
	result = []
	for row in c.execute(query1):
		result.append(row)
	#print result
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
	price_doc = open('weekly_price.csv','w+')
	vol_doc = open('weekly_vol.csv','w+')
	price_doc.write('week,')
	vol_doc.write('week,')
	

	#set up cols
	cols = list_cta_groups()
	for col in cols:
		price_doc.write('"'+ str( (str(col[0]),str(col[1]),'price') ) + '",')
		vol_doc.write('"'+ str( (str(col[0]),str(col[1]),'vol') )   + '",')


	#iterate through each week to find all the other prices
	for i in range(1,4):
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



def gen_cta():
	return;

def gen_group():
	return;




if __name__ == "__main__":
	gen_weekly_price_vol()