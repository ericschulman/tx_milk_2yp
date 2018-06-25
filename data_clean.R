#NOTE: X contains the new rowID

#Refresh Working Environment
rm(list=ls())

#Read data and set up necessary tables for regression
milk <- data.frame(read.csv("~/Documents/tx_milk/input/milk_out.csv"))

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
                      "biddate" =    milk$YEAR*10000 + milk$MONTH*100 +milk$DAY,
                      "win" = milk$WIN,
                      "county" = milk$COUNTY,
                      "fmozone"= milk$FMOZONE)

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
                     "biddate" =    milk$YEAR*10000 + milk$MONTH*100 +milk$DAY,
                     "win" = milk$WIN,
                     "county" = milk$COUNTY,
                     "fmozone"= milk$FMOZONE)

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
                      "biddate" =    milk$YEAR*10000 + milk$MONTH*100 +milk$DAY,
                      "win" = milk$WIN,
                      "county" = milk$COUNTY,
                      "fmozone"= milk$FMOZONE)

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
                     "biddate" =    milk$YEAR*10000 + milk$MONTH*100 +milk$DAY,
                     "win" = milk$WIN,
                     "county" = milk$COUNTY,
                     "fmozone"= milk$FMOZONE)

#bind each 'type' of bid together
clean_milk <- rbind(new_lfc, new_lfw, new_wc, new_ww)

#write to CSV file
write.csv(clean_milk, file = "~/Documents/tx_milk/input/clean_milk.csv")

#Bonus, setting up logs and stuff variables for stata
clean_milk2 <- data.frame("rowid" = milk$rowid,
                        "llfc" = log(milk$LFC),
                        "llfw" = log(milk$LFW),
                        "lwc" = log(milk$WC),
                        "lww" = log(milk$WW),
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
                        "biddate" =   milk$YEAR*10000 + milk$MONTH*100 +milk$DAY)
                        
#write to file
write.csv(clean_milk2, file = "~/Documents/tx_milk/input/clean_milk2.csv", row.names=FALSE)

#only include 'correct' processors
clean_milk3 <- clean_milk[(clean_milk$vendor=="BORDEN" | clean_milk$vendor=="CABELL" 
                          | clean_milk$vendor=="FOREMOST" | clean_milk$vendor=="OAK FARMS"
                          | clean_milk$vendor=="PRESTON" | clean_milk$vendor=="SCHEPPS"
                          | clean_milk$vendor=="VANDERVOORT"),]
write.csv(clean_milk3, file = "~/Documents/tx_milk/input/clean_milk3.csv")
