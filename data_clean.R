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
   if("type" %in% colnames(milk))
  {
    milk$type_dum <- factor(milk$type)
    milk$type_dum <- relevel(milk$type_dum, ref = "ww")
  }
  
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


lee_ext<-function(milk){
  #set up seasonal information
  min_year <-  milk[order(milk$YEAR),]$YEAR[1]
  max_year <- milk[order(-milk$YEAR),]$YEAR[1]
  years <- min_year:max_year
  season_info <- data.frame( YEAR=numeric(),
                             STARTDAY=as.Date(character()),
                             ENDDAY = as.Date(character()),
                             DIFF= numeric())
  
  for (year in years){  
    milk_f<- milk[ which(milk$YEAR==year & (milk$MONTH!= 0 & milk$DAY != 0) ),]
    
    start_col<- milk_f[order(milk_f$YEAR,milk_f$MONTH,milk_f$DAY),]
    start <- as.Date(as.character(start_col$YEAR*10000 + start_col$MONTH*100 +start_col$DAY),"%Y%m%d")
    start<-start[1]
    
    end_col<- milk_f[order(-milk_f$YEAR,-milk_f$MONTH,-milk_f$DAY),]
    end <- as.Date(as.character(end_col$YEAR*10000 + end_col$MONTH*100 +end_col$DAY),"%Y%m%d")
    end<- end[1]
    
    diff <- as.numeric(difftime(end, start), units="days")
    new  <- data.frame( YEAR=year,
                        STARTDAY=start,
                        ENDDAY = end,
                        DIFF= diff)
    season_info <- rbind(season_info, new)
  }
  
  #add season to columns
  milk<- merge(milk, season_info,
               by.x=c("YEAR"),
               by.y=c("YEAR"),
               suffixes=c("",".season"))
  
  
  milk$biddate<- as.Date(as.character(milk$YEAR*10000 + milk$MONTH*100 +milk$DAY),"%Y%m%d")
  
  #time based definitions for variables
  milk$PASSEDT <- as.numeric(difftime(milk$ENDDAY, milk$biddate), units="days")
  milk$BEGINT<- as.integer( ( 1.0*milk$PASSEDT)/milk$DIFF <= .5 )
  milk$ENDT<- as.integer( ( 1.0*milk$PASSEDT)/milk$DIFF >= .95 )
  milk$BACKLOGT <- (1.0*milk$COMMITMENTS/milk$CAPACITY) - ( 1.0*milk$PASSEDT)/milk$DIFF
  milk$SEASONT <-  ( 1.0*milk$PASSEDT)/milk$DIFF
  
  #quanity based definitions for variables
  milk$ONEBID <- as.integer(milk$N==1)
  milk$BEGIN <- as.integer( ( 1.0*milk$PASSED)/milk$CONTRACTS <= .5 )
  milk$END <- as.integer( ( 1.0*milk$PASSED)/milk$CONTRACTS >= .95 )
  milk$ENTRY <- as.integer( milk$YEAR>=1985 & milk$VENDOR == 'PRESTON' )
  
  return(milk)
}


#Read data and set up necessary tables for regression  ---------------------------

milk <- data.frame(read.csv("~/Documents/tx_milk/input/milk_out.csv"))

#add variables
milk$NOSTOP<-  (milk$DEL*milk$NUMSCHL)/(1.0*milk$NUMWIN)
milk$QSTOP<-  milk$ESTQTY/milk$NOSTOP
milk$SEASONQ <-  milk$PASSED/(1.0*milk$CONTRACTS)

milk <- lee_ext(milk)

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
                      "begint" = milk$BEGINT,
                      "endt"=milk$ENDT,
                      "lbackt"= log(1+milk$BACKLOGT))

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
                     "begint" = milk$BEGINT,
                     "endt"=milk$ENDT,
                     "lbackt"= log(1+milk$BACKLOGT))

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
                      "begint" = milk$BEGINT,
                      "endt"=milk$ENDT,
                      "lbackt"= log(1+milk$BACKLOGT))

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
                     "begint" = milk$BEGINT,
                     "endt"=milk$ENDT,
                     "lbackt"= log(1+milk$BACKLOGT))


#bind each 'type' of bid together  ---------------------------
clean_milk <- rbind(new_lfc, new_lfw, new_wc, new_ww)


#cleanmilk set up  ---------------------------
#write to CSV file
write.csv(clean_milk, file = "~/Documents/tx_milk/input/clean_milk.csv")


#clean milk2 set up ---------------------------
#Bonus, setting up logs and stuff variables for stata
clean_milkm <- data.frame("rowid" = milk$rowid,
                        "llevel" = log( (milk$WW*milk$QWW + milk$WC*milk$QWC + milk$LFC*milk$QLFC + milk$LFW*milk$LFW)
                                        /(1.0*(milk$QWW + milk$QWC + milk$QLFC + milk$LFW) ) ),
                        "lsize" = log((milk$QWW + milk$QWC + milk$QLFC + milk$LFW)),
                        "lestqty" = log(milk$ESTQTY),
                        "lseason" = log(milk$SEASONQ),
                        "lseasont" = log(milk$SEASONT),
                        "lnum" =  log(milk$N),
                        "inc" = milk$I,
                        "ldist" = log(milk$MILES),
                        "lnostop" = log(milk$NOSTOP),
                        "lback" = log(1+milk$BACKLOG),
                        "lbackt" = log(1+milk$BACKLOGT),
                        "lfmo" =  log(milk$FMO),
                        "esc" =  milk$ESC,
                        "cooler" = milk$COOLER,
                        "lqstop" =  log(milk$QSTOP),
                        "vendor" = milk$VENDOR,
                        "system" = milk$SYSTEM,
                        "year" = milk$YEAR,
                        "biddate" =   milk$YEAR*10000 + milk$MONTH*100 +milk$DAY,
                        "system" = milk$YEAR,
                        "year" = milk$YEAR)
#write to file
write.csv(clean_milkm, file = "~/Documents/tx_milk/input/clean_milkm.csv")
