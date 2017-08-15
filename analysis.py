
import numpy as np
import statsmodels.api as sm
import statsmodels.formula.api as smf


if __name__ == "__main__":
	# Create linear regression object
	data = np.genfromtxt('data/group_edps.csv', delimiter=',', names=True)
	vol = data['eq_vol']
	#print(type(vol[0]))
	price = data['price']
	#print(price[0])
	regressors = np.array([price])
	regressors = np.matrix.transpose(regressors)
	regressors = sm.add_constant(regressors)
	model = sm.OLS(vol,regressors,missing = 'drop')
	results = model.fit()
	print(results.summary())