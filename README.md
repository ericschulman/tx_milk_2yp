# Overview

Code and data analyzing the [U.S. justice department investigation](https://www.nytimes.com/1991/08/05/us/us-investigating-school-milk-bidding-in-16-states.html
) involving school milk cartons that took place during the early 1990s. In most states, schools hold a procurement auction where the firm who offers the lowest price wins the right to sell milk to that school. In Florida and Ohio, firms admitted to rigging prices in these auctions by providing each other with side payments to ensure their incentives were aligned. In total, the U.S. justice department investigated collusion over prices for school milk cartons in 16 states.  In Texas, nine milk processors settled for about 15.4 million dollars. Borden Dairy, a milk processors involved with the cartel in Florida, settled for about eight million dollars alone. The lack of official communication between firms and the well documented bids makes the Texas markets a case study in tacit collusion. For academic literature see:
* [Porter and Zona](https://www.jstor.org/stable/2556080?seq=1)
* [Pesendorfer](https://academic.oup.com/restud/article/67/3/381/1547415?login=true)


# Analysis

The code provides evidence of price wars. It uses an empirical strategy involving a switching regression similar to [Baldwin, Marshall and Richards](https://www.journals.uchicago.edu/doi/abs/10.1086/262089) who studied collusion in timber auctions. The switching regression identifies auctions where prices fall drastically for inexplicable reasons. 

* The `replication` folder involves replicating the regression results in a working paper involving this data set in `R`.
* The `structural` folder involves exploratory code using the approach in [Guerre, Perrigne and Vuong](https://www.jstor.org/stable/2999600?seq=1) to find the valuations of the bidders.
* `data_clean` creates a cleaned panel for the data called `clean_milk0.csv`.
* `lags_robust.ipynb` involves estimating the model with lags to look at response patterns and punishment strategies.
* `analytic_solution.ipynb` invovles estimating the switching regression and comparing results with a regression that controls for `incumbency` (i.e. providing milk to the district in the previous school year). 

In terms of $R^2$, likelihood, and AIC, the switching regression does a much better job of explaining the variation in the data. Incumbency consistently accounts for why bids fall from 18 cents to 17 cents. However, most districts have one or two years when firms who are not the incumbent bids about 14 cents. The switching regression more accurately predicts when bids will fall from 17 to 14 cents within a school district with an incumbent. As a result, incumbency does not adequately explain the volatile prices compared to a hidden variable.

 
# Testing framework

I formally test this hypothesis using the [Vuong](https://www.jstor.org/stable/1912557) test. This test lets us choose between two alternative data generating processes under the assumption only one of them is true. It works a lot like a likelihood ratio test, but adjusts for the fact that the models have nonnested likelihood functions. According to our results, both test statistics verify that the switching regression is closer to the true data generating process.


