#Refresh Working Environment
rm(list=ls())

#Import statements
library(stargazer)
library(IDPmisc)
library(lme4)
library(nloptr)

#import data
milk <- data.frame(read.csv("~/Documents/tx_milk/input/clean_milk4.csv"))

#setting up type dummies correctly
milk$type_dum <- factor(milk$type)
milk$type_dum <- relevel(milk$type_dum, ref = "ww")

#Drop inf, na, and nan
milk<-NaRV.omit(milk)

#Focus on SA area
milk<-milk[which(milk$fmozone==9),]

#table 5
#fit model
fit <- lmer(lbid ~ inc + type_dum*inc + lfmo*inc + lqstop*inc + lback*inc + esc*inc +  lnum*inc + type_dum*(1-inc)
                + lfmo*(1-inc) + lqstop*(1-inc) + lback*(1-inc) + esc*(1-inc) +  lnum*(1-inc)  
                + (1 | system/year) , control=lmerControl(optimizer="nloptwrap"), data=milk)

#write to latex
stargazer(fit, title="Table 5 Results for San Antonio", align=TRUE, type = "latex", 
          out="~/Documents/tx_milk/output/table5_SA.tex", no.space=TRUE)

#table 6
#fit model
fit2 <- lmer(lbid ~ inc + type_dum + lfmo + lestqty + lnostop + lback + esc + lnum
                   + (1 | system/year) , data=milk, control=lmerControl(optimizer="nloptwrap"))

#write to latex
stargazer(fit2, title="Table 6 Results for San Antonio", align=TRUE, type = "latex", 
          out="~/Documents/tx_milk/output/table6_SA.tex",no.space=TRUE)

#table 6 - modified
#Include a dummy for any bids taking place after August 10
milk$aug_10 <- as.integer(milk$biddate - milk$year*10000 >= 810)

#include a dummy for any ISD in Wise County
milk$wise <- as.integer(milk$county=="WISE")

#fit model
fit3 <- lmer(lbid ~ inc + type_dum + lfmo + lestqty + lnostop + lback + esc + lnum
             + aug_10 + wise + (1 | system/year) , data=milk, control=lmerControl(optimizer="nloptwrap"))

#write to latex
stargazer(fit3, title="Modified Table 6 for San Antonio", align=TRUE, type = "latex", 
          out="~/Documents/tx_milk/output/table6_SAm.tex",no.space=TRUE)

#table 10
#create a lagged wins
milk_m <- merge(milk, milk,
                by.x=c("system","vendor","county","type","esc"),
                by.y=c("system","vendor","county","type","esc"),
                suffixes=c("",".prev"))

milk_m <- milk_m[which(milk_m$year==(milk_m$year.prev+1)),]

fit4 <- lmer(lbid ~ win.prev  + type_dum + lfmo + lqstop
             + (1 | system/year) , control=lmerControl(optimizer="nloptwrap"), data=milk_m)

#write to latex
stargazer(fit4, title="Table 10 Results", align=TRUE, type = "latex", 
          out="~/Documents/tx_milk/output/table10.tex", no.space=TRUE)


#print summary to console
summary(fit)
summary(fit2)
summary(fit3)
summary(fit4)
