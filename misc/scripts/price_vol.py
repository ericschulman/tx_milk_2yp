
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


def regressIV(sql_file, name,  iv_list, omit):
	"""Used for a test regression, will take a database query as an argument, and
	return what is necessary eventually

	name is the name of the table, and omit is the columns to remove from the query
	because sqlite doesn't support dropping columns
	sql_file names the file that generates the relevant tables and the folder where results go"""
	
	con = sqlite3.connect('data/edp_changes.db') #create the db
	cur = con.cursor()

	#get y from the db
	cur.execute('select eq_vol from %s'%name)

	#get regressors from the db
	cur.execute('select * from %s'%name)
	regressors = cur.fetchall()
	regressors = np.array([ np.array([safe_float(j) for j in i]).astype(np.float)
			 for i in regressors])

	regressors = np.delete(regressors, omit, axis = 1)
	
	#delete nan lines
	regressors = regressors[~np.isnan(regressors).any(axis=1)]

	#save y and IV
	endog = regressors[:,2]
	print(endog)

	#set up instrument 
	instr = regressors
	instr = np.delete(instr, 2, axis = 1)
	instr = sm.add_constant(instr)
	print(instr)
	
	#set up exog
	exog = np.delete(regressors, iv_list, axis = 1)
	exog = sm.add_constant(exog)
	print(exog)

	#stage1 = OLS(endog, exog).fit()
	stage2 = IV2SLS(endog,exog,instr)
	
	fitted_model = stage2.fit()
	

	#write results
	result_doc = open('results/%sIV/results_%s.txt'%(sql_file,name),'w+')
	result_doc.write( fitted_model.summary().as_text() )
	result_doc.close()