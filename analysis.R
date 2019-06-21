rm(list=ls())

#install.packages("nonnest2")
#install.packages('flexmix')
#install.packages('mixtools')
#install.packages('xtable')

library(nonnest2)
library(flexmix)
library(mixtools)
library(xtable)

dir <-"~/Documents/creamers"
dir<- paste(dir,'/data/clean_milk1.csv', sep = "")
milk <- data.frame(read.csv(dir))

covariates<-"LWW ~ COOLER + ESC + LFMO + LGAS + LPOPUL + LQWW + X3 + X6 + X7 + X9"
hist <- " + LWW_min1 + LWW_min2 + LWW_min3 + + LWW_min4 + LWW_max1 + LWW_max2 + LWW_max3 + LWW_max4"
covariates_hist<- paste(covariates,hist)

#print(covariates_hist)
#ols<-lm(covariates,milk)
#summary(ols)
#ols_hist<-glm(covariates_hist,milk,family=gaussian())
#summary(ols_hist)


ex1 <- flexmix(LWW ~ 1 + COOLER + ESC + LFMO + LGAS + LPOPUL + LQWW + X3 + X6 + X7 + X9,
               data = milk, k = 2 , control = list(verb = 0, iter = 100))

#xtable(ex1, type = "latex", file = "output2.tex")


ex1re <-refit(ex1)
summary(ex1re)
#xtable(summary(ex1re), type = "latex" , file = "output3.tex")


milk$clusters <-clusters(ex1)-1
predict <- lm(clusters ~ LWW_min1 + LWW_min2 + LWW_min3 + + LWW_min4 + LWW_max1 + LWW_max2 + LWW_max3 + LWW_max4, milk)
xtable(predict, type = "latex", file = "output1.tex")

