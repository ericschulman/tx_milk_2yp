# creamers

Code and documentation to predict creamer sales based on panel data. Creamer sales are essentially a repeated Bertrand game. It is well known that this game admits multiple equilibrium in the stage game from the folk theorem. First I plan to cluster among prices to 'indentify' the stage game strategies. Then once, the stage game strategies have been identified, I plan to estimate the quantity, which is a peice wise function. 

The goal of the project is to focus on strategic interactions between firms. Prices among all firms are co-determined in a repeated game. Firms see a fixed market (possibly piece wise) demand curve with noise. They have to choose strategies against eachother. Essentially, I want to argue that taking the stage game strategies into account will improve efficiency when predicting quanity.

* In order to estimate the demand curve at each of the equilbrium, I plan to cluster among prices to 'indentify' stage game strategies using either a mixture model or k-means clustering. 

* Then once, the stage game strategies have been identified, I plan to estimate the structural parameter beta and demand shock mu. Hopefully, I can find a supply shock to better justify my estimation. But, this is less crucial. The predictor for quantity will still be a consistent estimate, if we take the stage-game strategies into account. Identifying beta in this situation is a well understood problem.

* Alternatively, I could assume that supply is not co-determined with demand. In other words, suppliers don't change their prices in reaction changes in market demand. This also means, that the error term is purely a demand shifter. This doesn't seem credible.

Equilibrium selection

Questions
* Can I implement any infinite strategy using finite one?
* Do finite strategy dominates infinite ones? (when there are costs?)
* does the cost matter?
* What happens if i choose the wrong # of clusters?
* Should I include Q in the clusters -- how do i incoporate the error into the model? Both supply error and demand error? 


## MD

This folder contains the legacy code from when I was working with Massive Dynamics on the project.

## Data

This folder contains the proprietary data from when I was working with Massive Dynamics. It comes originally from Neilson. Unfortunately, I am not planning to share it here.

## Reading
CMU Notes on EM and Mixture Models:
http://www.stat.cmu.edu/~cshalizi/uADA/12/lectures/ch20.pdf

Blog Post About Clusters:
https://www.r-bloggers.com/em-and-regression-mixture-modeling/




