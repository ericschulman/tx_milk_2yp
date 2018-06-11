#Refresh Working Environment
rm(list=ls())

#Import statements
library(stargazer)
library(IDPmisc)

#Read data and set up necessary tables for regression
milk <- data.frame(read.csv("~/Documents/summer_ra/tx_milk/data/milk_out.csv"))

new_lfc <- data.frame("rowid" = milk$rowid,
                      "lbid" = log(milk$LFC),
                      "type" = "lfc",
                      "inc" = milk$I,
                      "esc" =  milk$ESC,
                      "lfmo" =  log(milk$FMO),
                      "lqstop" =  log(milk$QSTOP),
                      "lback" = log(1+milk$BACKLOG),
                      "lnum" =  log(milk$N),
                      "lestqty" = log(milk$ESTQTY),
                      "lnostop" = log(milk$DEL*36),
                      "vendor" = milk$VENDOR,
                      "system" = milk$SYSTEM,
                      "year" = milk$YEAR,
                      "biddate" =   paste(milk$MONTH, milk$DAY, milk$YEAR, sep="-"))

new_wc <- data.frame("rowid" = milk$rowid,
                     "lbid" = log(milk$WC),
                     "type" = "wc",
                     "inc" = milk$I,
                     "esc" =  milk$ESC,
                     "lfmo" =  log(milk$FMO),
                     "lqstop" =  log(milk$QSTOP),
                     "lback" = log(1+milk$BACKLOG),
                     "lnum" =  log(milk$N),
                     "lestqty" = log(milk$ESTQTY),
                     "lnostop" = log(milk$DEL*36),
                     "vendor" = milk$VENDOR,
                     "system" = milk$SYSTEM,
                     "year" = milk$YEAR,
                     "biddate" =   paste(milk$MONTH, milk$DAY, milk$YEAR, sep="-"))

new_lfw <- data.frame("rowid" = milk$rowid,
                      "lbid" = log(milk$LFW),
                      "type" = "lfw",
                      "inc" = milk$I,
                      "esc" =  milk$ESC,
                      "lfmo" =  log(milk$FMO),
                      "lqstop" =  log(milk$QSTOP),
                      "lback" = log(1+milk$BACKLOG),
                      "lnum" =  log(milk$N),
                      "lestqty" = log(milk$ESTQTY),
                      "lnostop" = log(milk$DEL*36),
                      "vendor" = milk$VENDOR,
                      "system" = milk$SYSTEM,
                      "year" = milk$YEAR,
                      "biddate" =   paste(milk$MONTH, milk$DAY, milk$YEAR, sep="-"))

new_ww <- data.frame("rowid" = milk$rowid,
                     "lbid" = log(milk$WW),
                     "type" = "ww",
                     "inc" = milk$I,
                     "esc" =  milk$ESC,
                     "lfmo" =  log(milk$FMO),
                     "lqstop" =  log(milk$QSTOP),
                     "lback" = log(1+milk$BACKLOG),
                     "lnum" =  log(milk$N),
                     "lestqty" = log(milk$ESTQTY),
                     "lnostop" = log(milk$DEL*36),
                     "vendor" = milk$VENDOR,
                     "system" = milk$SYSTEM,
                     "year" = milk$YEAR,
                     "biddate" =   paste(milk$MONTH, milk$DAY, milk$YEAR, sep="-"))

#bind each 'type' of bid together
new_milk <- rbind(new_lfc, new_lfw, new_wc, new_ww)


#Create dummy variables

#setting up type dummies correctly
new_milk$type_dum <- factor(new_milk$type)
new_milk$type_dum <- relevel(new_milk$type_dum, ref = "ww")

new_milk$year_dum <- factor(new_milk$year)
new_milk$sys_dum <- factor(new_milk$system)
new_milk$ven_dum <- factor(new_milk$vendor)

#Drop inf, na, and nan
new_milk<-NaRV.omit(new_milk)

#table 5
lm.object <- lm(lbid ~ inc + type_dum*inc + lfmo*inc + lqstop*inc + lback*inc + esc*inc +  lnum*inc + type_dum*(1-inc)
                + lfmo*(1-inc) + lqstop*(1-inc) + lback*(1-inc) + esc*(1-inc) +  lnum*(1-inc)  
                + year_dum + sys_dum, data=new_milk)


stargazer(lm.object, title="Table 5 Results", align=TRUE, type = "text", out="~/Documents/summer_ra/tx_milk/output/table5.txt")
summary(lm.object)

#table 6
lm.object2 <- lm(lbid ~ inc + type_dum + lfmo + lestqty + lnostop + lback + esc + lnum
                + year_dum + sys_dum, data=new_milk)

stargazer(lm.object, title="Table 6 Results", align=TRUE, type = "text", out="~/Documents/summer_ra/tx_milk/output/table6.txt")
summary(lm.object2)

