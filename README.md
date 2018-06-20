# tx_milk

The code attempts to replicate table 5, and table 6 from the working paper "Incumbency and Bidding Behavior in the Dallas Ft. Worth School Milk market" using R and SQLite.

## Work in progress

### Hierarchical model in R
http://www.r-tutor.com/gpu-computing/rbayes/rhierlmc
https://www.jaredknowles.com/journal/2013/11/25/getting-started-with-mixed-effect-models-in-r

### Clustered Standard Errors
Blogs for reproducing the clustered standard errors in R
Relevant posts and forums:

Stack exchange post
https://stats.stackexchange.com/questions/124662/group-fixed-effects-not-individual-fixed-effects-using-plm-in-r

Blog post
https://economictheoryblog.com/2016/08/07/robust-standard-errors-in-r-function/

STATA documentation on cluster robust SEs
https://www.stata.com/support/faqs/statistics/standard-errors-and-vce-cluster-option/

## replication.R

This file tries to replicate the main tables from the paper.


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

