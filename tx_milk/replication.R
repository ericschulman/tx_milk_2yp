
library(haven)
TXMILKDB_new <- read_dta("Documents/summer_ra/tx_milk/data/TXMILKDB_new.DTA")
View(TXMILKDB_new)
fit <- lm(ly ~ xI + ILFC + ILFW, data=mydata)
# Other useful functions
coefficients(fit) # model coefficients
#confint(fit, level=0.95) # CIs for model parameters
#fitted(fit) # predicted values
#residuals(fit) # residuals
#anova(fit) # anova table
#vcov(fit) # covariance matrix for model parameters
#influence(fit) # regression diagnostics 