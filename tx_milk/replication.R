rm(list=ls())

milk <- data.frame(read.csv("~/Documents/summer_ra/tx_milk/data/milk_out.csv"))

new_lfc <- data.frame("rowid" = milk$rowid,
                      "vendor" = milk$VENDOR,
                      "system" = milk$SYSTEM,
                      "year" = milk$YEAR,
                      "biddate" =   paste(milk$MONTH, milk$DAY, milk$YEAR, sep="-"),
                      "bid" = log(milk$LFC),
                      "inc" = milk$I, 
                      "type" = "lfc",
                      "logfmo" =  log(milk$FMO),
                      "logqstop" =  log(milk$QSTOP),
                      "back" = log(1+milk$BACKLOG),
                      "esc" =  milk$ESC,
                      "num" =  milk$N)
                       
new_wc <- data.frame("rowid" = milk$rowid,
                      "vendor" = milk$VENDOR,
                      "system" = milk$SYSTEM,
                      "year" = milk$YEAR,
                      "biddate" =   paste(milk$MONTH, milk$DAY, milk$YEAR, sep="-"),
                      "bid" = log(milk$WC),
                      "inc" = milk$I, 
                      "type" = "wc",
                      "logfmo" =  log(milk$FMO),
                      "logqstop" =  log(milk$QSTOP),
                      "back" = log(1+milk$BACKLOG),
                      "esc" =  milk$ESC,
                      "num" =  milk$N)

new_lfw <- data.frame("rowid" = milk$rowid,
                      "vendor" = milk$VENDOR,
                      "system" = milk$SYSTEM,
                      "year" = milk$YEAR,
                      "biddate" =   paste(milk$MONTH, milk$DAY, milk$YEAR, sep="-"),
                      "bid" = log(milk$LFW),
                      "inc" = milk$I, 
                      "type" = "lfw",
                      "logfmo" =  log(milk$FMO),
                      "logqstop" =  log(milk$QSTOP),
                      "back" = log(1+milk$BACKLOG),
                      "esc" =  milk$ESC,
                      "num" =  milk$N)

new_ww <- data.frame("rowid" = milk$rowid,
                      "vendor" = milk$VENDOR,
                      "system" = milk$SYSTEM,
                      "year" = milk$YEAR,
                      "biddate" =   paste(milk$MONTH, milk$DAY, milk$YEAR, sep="-"),
                      "bid" = log(milk$WW),
                      "inc" = milk$I, 
                      "type" = "ww",
                      "logfmo" =  log(milk$FMO),
                      "logqstop" =  log(milk$QSTOP),
                      "back" = log(1+milk$BACKLOG),
                      "esc" =  milk$ESC,
                      "num" =  milk$N)

new_milk <- rbind(new_lfc, new_lfw, new_wc, new_ww)
new_milk$type_dum <- factor(new_milk$type)
new_milk$type_dum <- relevel(new_milk$type_dum, ref = "ww")

new_milk$year_dum <- factor(new_milk$year)
new_milk$sys_dum <- factor(new_milk$system)
new_milk$sys_dum <- factor(new_milk$vendor)

library(IDPmisc)
new_milk<-NaRV.omit(new_milk)

lm.object <- lm(bid ~ inc + type_dum*inc + logfmo*inc + logqstop*inc + back*inc + esc*inc +  num*inc + type_dum*(1-inc)
                + logfmo*(1-inc) + logqstop*(1-inc) + back*(1-inc) + esc*(1-inc) +  num*(1-inc)  
                + year_dum , data=new_milk)


summary(lm.object)

