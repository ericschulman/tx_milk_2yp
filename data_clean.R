#NOTE: X contains the new rowID

#Refresh Working Environment  ---------------------------
rm(list=ls())


filter_data<-function(milk){
  ids <- data.frame(read.csv("~/Documents/tx_milk/input/ids/complete_isd.csv"))
  
  milk_f <- merge(milk, ids,
                  by.x=c("system","county"),
                  by.y=c("SYSTEM","COUNTY"))
  return(milk_f)
}


#function definitions ---------------------------
load_milk<-function(dir){
  milk <- data.frame(read.csv(dir))
  #setting up type dummies correctly
  milk$type_dum <- factor(milk$type)
  milk$type_dum <- relevel(milk$type_dum, ref = "ww")
  #only include correct processors
  milk <- milk[which(milk$vendor=="BORDEN" | milk$vendor=="CABELL" 
                     | milk$vendor=="FOREMOST" | milk$vendor=="OAK FARMS"
                     | milk$vendor=="PRESTON" | milk$vendor=="SCHEPPS"
                     | milk$vendor=="VANDERVOORT"),]
  #fix bid dates
  milk$biddate<-as.Date(as.character(milk$biddate),"%Y%m%d")
  #focus on correct bid dates
  milk <- milk[which(milk$year>=1980 & milk$year <=1991),]
  #Drop inf, na, and nan 
  milk<-NaRV.omit(milk)
  
  return(milk)
}


#Read data and set up necessary tables for regression  ---------------------------
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

#bind each 'type' of bid together  ---------------------------
clean_milk <- rbind(new_lfc, new_lfw, new_wc, new_ww)


#cleanmilk set up  ---------------------------
#write to CSV file
write.csv(clean_milk, file = "~/Documents/tx_milk/input/clean_milk.csv")


#clean milk2 set up ---------------------------
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
write.csv(clean_milk2, file = "~/Documents/tx_milk/input/clean_milkm.csv", row.names=FALSE)
