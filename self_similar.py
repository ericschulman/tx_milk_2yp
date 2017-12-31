from plots import *


def create_matrix(group,cta):
	"""helper function tocreate matrix for regression, 
	a1 is coef on P_{i,t}-P_{i,t-1}, a2 is coef on P_{i,t} - P_{avg,t}"""
	con = sqlite3.connect('data/edp_changes.db')
	cur = con.cursor()
	q = create_query(group,cta)
	cur.execute(q)

	con = sqlite3.connect('data/edp_changes.db')
	cur = con.cursor()
	q = create_query(group,cta)
	X =[]
	y= []

	cur.execute(q)

	for row in cur:
		x_row =	np.array( [safe_float(row[0]), safe_float(row[1])] )	
		X.append (x_row) 
		y.append ( x_row[1] )

	y = np.array(y)
	X = np.array(X)
	return y,X


def make_reg_folders(cta):
	"""set up the required folder structure
	to save the results"""
	make_all_folders(cta)
	make_folder('results/%s/reg/'%(create_fname(cta)))


def run_reg(group,cta):
	"""run regressions and simply save the results to a folder"""
	y,X = create_matrix(group,cta)
	if len(X) == 0:
		print 'no data %s %s'%(group,cta)
	
	else:
		X = sm.add_constant(X)
		model_result = sm.OLS(y,X).fit()
		fname = 'results/%s/reg/%s.txt'%(create_fname(cta), group)
		result_doc = open(fname,'w+')
		result_doc.write( model_result.summary().as_text() )
		result_doc.close()


def run_all_regs(cta):
	"""combines all the functions to make all the plots"""
	con = sqlite3.connect('data/edp_changes.db')
	cur = con.cursor()
	cur.execute( ( "select * from group_edps "+
		" where group_edps.dim_cta_key = %s group by dim_group_key"%cta) )

	groups = cur.fetchall()
	for group in groups:
		if  (('64' not in  str(group[0]))
		and ('48' not in  str(group[0]))) :
			run_reg(str(group[0]),cta)


def plot_coefficients(cta):
	""" helper function 
	to constructs scatter plots of the coefficients"""
	fig = plt.figure()
	
	con = sqlite3.connect('data/edp_changes.db')
	cur = con.cursor()
	cur.execute(( "select * from group_edps "+
		" where group_edps.dim_cta_key = %s group by dim_group_key"%cta) )

	groups = cur.fetchall()
	
	vols =[]
	lb = [[],[],[]]
	ub = [[],[],[]]
	mean = [[],[],[]]


	for group in groups:
		group = str(group[0])
		if  (('64' not in  group)
		and  ('48' not in  group)) :

			y,X = create_matrix(group, cta)
			if len(X) == 0:
				print 'no data %s %s'%(group,cta)
			else:
				X = sm.add_constant(X)
				model_result = sm.OLS(y,X).fit()
				conf_int = model_result.conf_int()

				query = ("select avg(group_edps.eq_vol) from group_edps "+
				" where group_edps.dim_cta_key = %s and group_edps.dim_group_key = '%s' "%(cta,group) +
				" group by dim_group_key")
				cur.execute(query )

				vol = cur.fetchall()
				vol = float(vol[0][0])
				vols.append(vol)
				
				for coef in range(3):
					lb[coef].append(conf_int[coef][0])
					ub[coef].append(conf_int[coef][1])
					mean[coef].append( (lb[coef][-1] + ub[coef][-1])/2.0 )

		for coef in range(3):
			plt.plot(vols, mean[coef], 'ro', vols, lb[coef], 'b^', vols, ub[coef], 'g^')
			plt.savefig('results/%s/coef_%s.png'%(create_fname(cta), coef))
			plt.close()


def run_all_regs_all_ctas():
	"""wrapper function for running all regressions"""
	for cta in CTAS:
		make_reg_folders(cta)
		run_all_regs(cta)


def plot_coef_all_ctas():
	"""wrapper function for making all the plots"""
	for cta in CTAS:
		make_reg_folders(cta)
		plot_coefficients(cta)


if __name__ == "__main__":
	#run_all_regs_all_ctas()
	plot_coef_all_ctas()