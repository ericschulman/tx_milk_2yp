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
clean_milk <- rbind(new_lfc, new_lfw, new_wc, new_ww)

#write to CSV file
write.csv(clean_milk, file = "~/Documents/tx_milk/input/clean_milk.csv")

#Bonus, setting up logs and stuff variables for stata
clean_milk2 <- data.frame("rowid" = milk$rowid,
                        "llfc" = log(milk$LFC),
                        "llfc" = log(milk$LFW),
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
                        "biddate" =   paste(milk$MONTH, milk$DAY, milk$YEAR, sep="-"))

#write to file
write.csv(clean_milk2, file = "~/Documents/tx_milk/input/clean_milk2.csv", row.names=FALSE)