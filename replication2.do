/*Table 6*/
clear
import delimited C:\Users\ehs588\Downloads\input\clean_milk.csv, numericcols(3 5 6 7 8 9 10 11 12)

generate ww = type=="ww"
generate wc = type=="wc"
generate lfw = type=="lfw"
generate lfc = type=="lfc"

by system year, sort : mixed lbid inc wc lfw lfc lfmo lestqty lnostop lback esc lnum, vce(cluster system)

mixed lbid inc wc lfw lfc lfmo lestqty lnostop lback esc lnum, vce(cluster system)


/*Table 5*/


/*Using the original data file, maybe there's something here?*/
clear

import delimited C:\Users\ehs588\Downloads\input\clean_milk2.csv, numericcols(2 3 4 5 6 7 8 9 10 11 12 13) clear 
rename llfc1 llfw
