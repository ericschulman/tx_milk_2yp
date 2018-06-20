#Refresh Working Environment
rm(list=ls())
#Import statements
library(stargazer)
library(IDPmisc)
library(lme4)
library(nloptr)

milk <- data.frame(read.csv("~/Documents/tx_milk/input/clean_milk.csv"))


#Create dummy variables

#setting up type dummies correctly
milk$type_dum <- factor(milk$type)
milk$type_dum <- relevel(milk$type_dum, ref = "ww")

milk$year_dum <- factor(milk$year)
milk$sys_dum <- factor(milk$system)
milk$ven_dum <- factor(milk$vendor)

#Drop inf, na, and nan
milk<-NaRV.omit(milk)

#table 5
lm.object <- lmer(lbid ~ inc + type_dum*inc + lfmo*inc + lqstop*inc + lback*inc + esc*inc +  lnum*inc + type_dum*(1-inc)
                + lfmo*(1-inc) + lqstop*(1-inc) + lback*(1-inc) + esc*(1-inc) +  lnum*(1-inc)  
                + (1 |year) + (1 | system), control=lmerControl(optimizer="nloptwrap"), data=milk)


stargazer(lm.object, title="Table 5 Results RE", align=TRUE, type = "text", out="~/Documents/tx_milk/output/table5_RE.txt")
stargazer(lm.object, title="Table 5 Results RE", align=TRUE, type = "latex", out="~/Documents/tx_milk/output/table5_RE.tex")
summary(lm.object)

#table 6

lm.object2 <- lmer(lbid ~ inc + type_dum + lfmo + lestqty + lnostop + lback + esc + lnum
                   + (1 |year) + (1 | system) , data=milk, control=lmerControl(optimizer="nloptwrap"))

stargazer(lm.object2, title="Table 6 Results RE", align=TRUE, type = "text", out="~/Documents/tx_milk/output/table6_RE.txt")
stargazer(lm.object2, title="Table 6 Results RE", align=TRUE, type = "latex", out="~/Documents/tx_milk/output/table6_RE.tex")
summary(lm.object2)