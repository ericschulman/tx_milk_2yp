
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
	print result
	return result


def gen_weekly_price():
	conn = sqlite3.connect('data/edp_changes.db')
	c = conn.cursor()
	query = ("select group_edps.price from group_edps "
	+ "where group_edps.dim_cta_key =? "
	+ "and group_edps.dim_group_key =? "
	+ "and group_edps.dim_date_key =?")
	f = open('weekly_price.csv','w+')

	cols = list_cta_groups()

	for col in cols:
		f.write('"'+ string(col) + '",')
		f.write('\n')
		for i in range(1,157):
			for row in c.execute(query1,()):





	
def gen_weekly_vol():
	return;

def gen_cta():
	return;

def gen_group():
	return;




if __name__ == "__main__":
	gen_weekly_price()