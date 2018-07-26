# tx_milk

The code attempts to replicate and extend the working paper "Incumbency and Bidding Behavior in the Dallas Ft. Worth School Milk Market" using R and SQLite.

## Folder Structure

Below is an explanaton of the project's file structure

* `dependencies.R` This file installs the necessary R dependencies and libraries for R

* `models.R` code for loading in the data and running linear models is defined in this file and called in other scripts

* `ext.R` This file tries to replicate the main tables from Fu 2011 and Lee 1999 from the paper with some extensions.

* `rep.R` This file tries to replicate the main tables from the paper with some extensions.

* `data_clean.R` This is more post processing after the data is taken from the database

* `plots.R` This file containing relevant R code to make plots

* `db`
contains the database and a `.sql` file used for constructing the required views in for the data

	* `replication.SQL` Useful SQL queries used for generating BACKLOG and the Incumbencies within the paper

	* `tx_milk.db` SQLite database containing relevant tables to the project

* `data` The data on historic milk prices is courtesy of the Dallas Federal Marketing Order's office. It can be found using the link below

	* `fmo_diff.csv` price differentials for adjusting the Dallas price to different regions

	* `fmo_prices.csv` table with historical FMO prices in Dallas, I formatted these using the original file. The file is found under 1975 - 1995 statistical summary from http://www.dallasma.com/order_stats/stats_sum.jsp

	*  `milk_out.csv` is a table with all the relevant information to table 5

	* `tx_milk.csv` is the original data on milk bids

* `output`This folder contains the relevant output to the project

* `input` destination for cleaned data files for use in R and STATA

* `stata` This folder contains the relevant stata commands to the project, development is mainly in R. The data undergoes further filtering in the `replication.R`

## Further Reading (For generalized linear models)

* https://stats.stackexchange.com/questions/122009/extracting-slopes-for-cases-from-a-mixed-effects-model-lme4
* http://bbolker.github.io/mixedmodels-misc/glmmFAQ.html#model-definition