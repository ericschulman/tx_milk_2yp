# tx_milk

The code attempts to remplicate table 5, and table 6 from the working paper "Incumbency amd Bidding Behavior in the Dallas Ft. Worth School Milk market" using R.

## clustered_SE.R

This file has an attempt to create clustered standard errors using code from this post.

It is still in progress. Other relevant posts and entries are:

https://stats.stackexchange.com/questions/124662/group-fixed-effects-not-individual-fixed-effects-using-plm-in-r

https://economictheoryblog.com/2016/08/07/robust-standard-errors-in-r-function/

his blog has the following dependencies:

`install.packages("bitops")`
`install.packages("RCurl")`
`install.packages("sandwich")`
`install.packages("gdata")`
`install.packages("IDPmisc")`


## replication.R

This file tries to replicate the main tables from the paper.

This file has the following dependencies
`install.packages("stargazer")`
`install.packages("IDPmisc")`
`install.packages('multiwayvcov')`
`install.packages('lmtest')`

## replication.SQL

Useful SQL queries used for generating BACKLOG and the Incumbencies within the paper

## tx_milk.db

SQLite database containing relevant tables to the project

## data

The data on historic milk prices is courtesy of the Dallas Federal Marketing Order's office. It can be found using the link below

http://www.dallasma.com/order_stats/stats_sum.jsp

### fmo_diff.csv

price differentials for adjusting the Dallas price to different regions

### fmo_prices.csv

table with historical FMO prices in Dallas

### milk_out.csv

table with all the relevant information to table 5

### tx_milk.csv

The file is called 1975 - 1995 statistical summary

## output

This folder contains the relevant output to the project

