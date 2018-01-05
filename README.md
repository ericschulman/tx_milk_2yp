# MD
Code and documentation to predict consumer response to EDP changes

TODO:
--------------------------------------------------------------
Dec 29

Modify plots to include CTAs and include PL - Done

Rank CTAs by volume (and # of groups) 
-chose top 2 and median - done
Rank CTAs by Revenue (and # of groups)
-chose top 2 and median - done

-Run linear regressions for each group
-construct plot
-order CTAs by size
-plot alpha, plus confidence interval around alpha


for each cta
#, size, lower bound, mean, upper boud
(write to file)
--------------------------------------------------------------
Jan 5

The underlying model should read: (Q_i/Q_T)@t = (Q_i/Q_T)@t-2  + coeff_1*(…….) + coeff_2*(……..)
- fix query
- fix regression
- fix plot