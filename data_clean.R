#NOTE: X contains the new rowID

#Dependencies ---------------------------
rm(list=ls())
source("~/Documents/tx_milk/models.R")

#Read data and set up necessary tables for regression  ---------------------------
milk <- data.frame(read.csv("~/Documents/tx_milk/input/milk_out.csv"))

#add strategic variables
milk$NOSTOP<-  (milk$DEL*milk$NUMSCHL*36.0)
milk$QSTOP<-  milk$ESTQTY/(milk$NOSTOP*milk$NUMWIN)
milk$SEASONQ <-  milk$PASSED/(1.0*milk$CONTRACTS)
milk$ONEBID <- as.integer(milk$N==1)
milk$BEGIN <- as.integer( ( 1.0*milk$PASSED)/milk$CONTRACTS <= .5 )
milk$END <- as.integer( ( 1.0*milk$PASSED)/milk$CONTRACTS >= .95 )
milk$ENTRY <- as.integer( milk$YEAR==1985 & milk$VENDOR == 'PRESTON' )


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
                      "lnostop" = log(milk$NOSTOP),
                      "vendor" = milk$VENDOR,
                      "system" = milk$SYSTEM,
                      "year" = milk$YEAR,
                      "biddate" =    milk$YEAR*10000 + milk$MONTH*100 +milk$DAY,
                      "win" = milk$WIN,
                      "county" = milk$COUNTY,
                      "fmozone"= milk$FMOZONE,
                      "onebid"= milk$ONEBID,
                      "begin"= milk$BEGIN,
                      "end"= milk$END,
                      "entry"= milk$ENTRY,
                      "lseason" = log(milk$SEASONQ),
                      "season" = milk$SEASONQ,
                      "back" = milk$BACKLOG)

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
                     "lnostop" = log(milk$NOSTOP),
                     "vendor" = milk$VENDOR,
                     "system" = milk$SYSTEM,
                     "year" = milk$YEAR,
                     "biddate" =    milk$YEAR*10000 + milk$MONTH*100 +milk$DAY,
                     "win" = milk$WIN,
                     "county" = milk$COUNTY,
                     "fmozone"= milk$FMOZONE,
                     "onebid"= milk$ONEBID,
                     "begin"= milk$BEGIN,
                     "end"= milk$END,
                     "entry"= milk$ENTRY,
                     "lseason" = log(milk$SEASONQ),
                     "season" = milk$SEASONQ,
                     "back" = milk$BACKLOG)

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
                      "lnostop" = log(milk$NOSTOP),
                      "vendor" = milk$VENDOR,
                      "system" = milk$SYSTEM,
                      "year" = milk$YEAR,
                      "biddate" =    milk$YEAR*10000 + milk$MONTH*100 +milk$DAY,
                      "win" = milk$WIN,
                      "county" = milk$COUNTY,
                      "fmozone"= milk$FMOZONE,
                      "onebid"= milk$ONEBID,
                      "begin"= milk$BEGIN,
                      "end"= milk$END,
                      "entry"= milk$ENTRY,
                      "lseason" = log(milk$SEASONQ),
                      "season" = milk$SEASONQ,
                      "back" = milk$BACKLOG)
            

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
                     "lnostop" = log(milk$NOSTOP),
                     "vendor" = milk$VENDOR,
                     "system" = milk$SYSTEM,
                     "year" = milk$YEAR,
                     "biddate" =    milk$YEAR*10000 + milk$MONTH*100 +milk$DAY,
                     "win" = milk$WIN,
                     "county" = milk$COUNTY,
                     "fmozone"= milk$FMOZONE,
                     "onebid"= milk$ONEBID,
                     "begin"= milk$BEGIN,
                     "end"= milk$END,
                     "entry"= milk$ENTRY,
                     "lseason" = log(milk$SEASONQ),
                     "season" = milk$SEASONQ,
                     "back" = milk$BACKLOG)


#bind each 'type' of bid together  ---------------------------
clean_milk <- rbind(new_lfc, new_lfw, new_wc, new_ww)


#cleanmilk set up  ---------------------------
#write to CSV file
write.csv(clean_milk, file = "~/Documents/tx_milk/input/clean_milk.csv")


#clean milk2 set up ---------------------------
#Bonus, setting up logs and stuff variables for stata
milk$LEVEL <- setup_level(milk)

clean_milkm <- data.frame("rowid" = milk$rowid,
                          "system" = milk$SYSTEM,
                          "vendor" = milk$VENDOR,
                          "county" = milk$COUNTY,
                          "fmozone"= milk$FMOZONE,
                          "county" = milk$COUNTY,
                          "year" = milk$YEAR,
                          "biddate" =   milk$YEAR*10000 + milk$MONTH*100 +milk$DAY,
                          "llevel" = log( milk$LEVEL),
                          "lestqty" = log(milk$ESTQTY),
                          "lseason" = log(milk$SEASONQ),
                          "season" = milk$SEASONQ,
                          "lnum" =  log(milk$N),
                          "inc" = milk$I,
                          "ldist" = log(milk$MILES),
                          "lnostop" = log(milk$NOSTOP),
                          "lback" = log(1+milk$BACKLOG),
                          "lfmo" =  log(milk$FMO),
                          "esc" =  milk$ESC,
                          "cooler" = milk$COOLER,
                          "lqstop" =  log(milk$QSTOP),
                          "win"=milk$WIN)

#write to file
write.csv(clean_milkm, file = "~/Documents/tx_milk/input/clean_milkm.csv")
