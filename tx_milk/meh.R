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
                       
new_ww <- data.frame("rowid" = milk$rowid,
                      "vendor" = milk$VENDOR,
                      "system" = milk$SYSTEM,
                      "year" = milk$YEAR,
                      "biddate" =   paste(milk$MONTH, milk$DAY, milk$YEAR, sep="-"),
                      "bid" = log(milk$LFC),
                      "inc" = milk$I, 
                      "type" = "",
                      "logfmo" =  log(milk$FMO),
                      "logqstop" =  log(milk$QSTOP),
                      "back" = log(1+milk$BACKLOG),
                      "esc" =  milk$ESC,
                      "num" =  milk$N)

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

new_milk <- rbind(new_lfc, new_lfw, new_wc, new_ww)

new_milk$year_dum <- factor(new_milk$year)
new_milk$sys_dum <- factor(new_milk$system)
new_milk$type_dum <- factor(new_milk$type)

lm.object <- lm(bid ~ inc + type_dum*inc + logfmo*inc + logqstop*inc + back*inc + esc*inc + num*inc
   + type_dum*(1-inc) + logfmo*(1-inc) + logqstop*(1-inc) + back*(1-inc) + esc*(1-inc) + num*(1-inc), data=new_milk, na.action=na.exclude) 

summary(lm.object)


