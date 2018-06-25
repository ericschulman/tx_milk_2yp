# creamers

Code and documentation to predict creamer sales based on panel data. Creamer sales are essentially a repeated Bertrand game. It is well known that this game admits multiple equilibrium in the stage game from the folk theorem. First I plan to cluster among prices to 'indentify' the stage game strategies. Then once, the stage game strategies have been identified, I plan to estimate the quantity, which is a peice wise function. 

The goal of the project is to focus on strategic interactions between firms. Prices among all firms are co-determined in a repeated game. Firms see a fixed market (possibly piece wise) demand curve with noise. They have to choose strategies against eachother. Essentially, I want to argue that taking the stage game strategies into account will improve efficiency when predicting quanity.

I am hoping to show that over a finite interval, the set of stage game strategies is bounded by the number of stage games (i.e. to chose the number of clusters). Hopefully, this happens when changing prices is costly. This is consistent with the consistent with the actual data which has a limited number of price changes.

>In order to estimate the demand curve at each of the equilbrium, I plan to cluster among prices to 'indentify' stage game strategies using either a mixture model or k-means clustering. 

>Then once, the stage game strategies have been identified, I plan to estimate the structural parameter beta and demand shock mu. Hopefully, I can find a supply shock to better justify my estimation. But, this is less crucial. The predictor for quantity will still be a consistent estimate, if we take the stage-game strategies into account. Identifying beta in this situation is a well understood problem.

>Alternatively, I could assume that supply is not co-determined with demand. In other words, suppliers don't change their prices in reaction changes in market demand. This also means, that the error term is purely a demand shifter. This doesn't seem credible.


Questions
1. How do I know that the stage game strategy set (prices) is finite (i.e. need the set not to explode with infinite observations). Maybe I just need it bounded by number of demand observations? 
2. How do I prove that the stage game strategy set is identifies by the the strategy clusters
3. What assumptions are essential for Demand?
4. Should I include Q in the clusters.

## MD

This folder contains the legacy code from when I was working with Massive Dynamics on the project.

## Data

This folder contains the proprietary data from when I was working with Massive Dynamics. It comes originally from Neilson. Unfortunately, I am not planning to share it here.

## Reading
CMU Notes on EM and Mixture Models:
http://www.stat.cmu.edu/~cshalizi/uADA/12/lectures/ch20.pdf

Blog Post About Clusters:
https://www.r-bloggers.com/em-and-regression-mixture-modeling/