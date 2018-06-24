#Refresh Working Environment
rm(list=ls())

#Import statements
library(stargazer)
library(IDPmisc)
library(lme4)
library(nloptr)

#import data
milk <- data.frame(read.csv("~/Documents/tx_milk/input/clean_milk3.csv"))

#setting up type dummies correctly
milk$type_dum <- factor(milk$type)
milk$type_dum <- relevel(milk$type_dum, ref = "ww")

#Drop inf, na, and nan
milk<-NaRV.omit(milk)


#table 5
#fit model
fit <- lmer(lbid ~ inc + type_dum*inc + lfmo*inc + lqstop*inc + lback*inc + esc*inc +  lnum*inc + type_dum*(1-inc)
                + lfmo*(1-inc) + lqstop*(1-inc) + lback*(1-inc) + esc*(1-inc) +  lnum*(1-inc)  
                + (1 | system/year) , control=lmerControl(optimizer="nloptwrap"), data=milk)

#write to text
stargazer(fit, title="Table 5 Results RE", align=TRUE, type = "text", 
          out="~/Documents/tx_milk/output/table5_RE.txt")

#write to latex
stargazer(fit, title="Table 5 Results RE", align=TRUE, type = "latex", 
          out="~/Documents/tx_milk/output/table5_RE.tex", no.space=TRUE)

#print summary to console
summary(fit)

#table 6
#fit model
fit2 <- lmer(lbid ~ inc + type_dum + lfmo + lestqty + lnostop + lback + esc + lnum
                   + (1 | system/year) , data=milk, control=lmerControl(optimizer="nloptwrap"))
#write to text
stargazer(fit2, title="Table 6 Results RE", align=TRUE, type = "text", 
          out="~/Documents/tx_milk/output/table6_RE.txt")

#write to latex
stargazer(fit2, title="Table 6 Results RE", align=TRUE, type = "latex", 
          out="~/Documents/tx_milk/output/table6_RE.tex",no.space=TRUE)

#print summary to console
summary(fit2)

#table 6 - modified
#Include a dummy for any bids taking place after August 10
milk$aug_10 <- as.integer(milk$biddate - milk$year*10000 >= 810)

#include a dummy for any ISD in Wise County
milk$wise <- as.integer(milk$county=="WISE")

#fit model
fit3 <- lmer(lbid ~ inc + type_dum + lfmo + lestqty + lnostop + lback + esc + lnum
             + aug_10 + wise + (1 | system/year) , data=milk, control=lmerControl(optimizer="nloptwrap"))
#write to text
stargazer(fit3, title="Modified Table 6 Results RE", align=TRUE, type = "text", 
          out="~/Documents/tx_milk/output/table6_m.txt")

#write to latex
stargazer(fit3, title="Modified Table 6 Results RE", align=TRUE, type = "latex", 
          out="~/Documents/tx_milk/output/table6_m.tex",no.space=TRUE)

#print summary to console
summary(fit3)

