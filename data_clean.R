#NOTE: X contains the new rowID

#Refresh Working Environment  ---------------------------
rm(list=ls())


#function definitions ---------------------------
load_milk<-function(dir){
  milk <- data.frame(read.csv(dir))
  #only include correct processors
  milk <- milk[which(milk$vendor=="BORDEN" | milk$vendor=="CABELL" 
                     | milk$vendor=="FOREMOST" | milk$vendor=="OAK FARMS"
                     | milk$vendor=="PRESTON" | milk$vendor=="SCHEPPS"
                     | milk$vendor=="VANDERVOORT"),]
  #fix bid dates
  milk$biddate<-as.Date(as.character(milk$biddate),"%Y%m%d")
  #focus on correct bid dates
  milk <- milk[which(milk$year>=1980 & milk$year <=1992),]
  #Drop inf, na, and nan
  milk<-NaRV.omit(milk)
  if("type" %in% colnames(milk)){
    #setting up type dummies correctly
    milk$type_dum <- factor(milk$type)
    milk$type_dum <- relevel(milk$type_dum, ref = "ww")
  }
  return(milk)
}


lag_wins<-function(milk){
  #create lag
  milk_m <- milk
  milk_m$year <- milk_m$year +1
  if("type" %in% colnames(milk)){
    milk_m <- merge(milk, milk_m,
                    by.x=c("system","vendor","county","type","esc","fmozone","year"),
                    by.y=c("system","vendor","county","type","esc","fmozone","year"),
                    suffixes=c("",".prev"), all.x =TRUE)
  } else{
    milk_m <- merge(milk, milk_m,
                    by.x=c("system","vendor","county","esc","fmozone","year"),
                    by.y=c("system","vendor","county","esc","fmozone","year"),
                    suffixes=c("",".prev"), all.x =TRUE)
  }
  milk_m$win.prev[is.null(milk_m$win.prev)] <- 0
  milk_m$win.prev[is.na(milk_m$win.prev)] <- 0
  return(milk_m)
}


filter_data<-function(milk){
  ids <- data.frame(read.csv("~/Documents/tx_milk/input/ids/complete_isd.csv"))
  milk_f <- merge(milk, ids,
                  by.x=c("system","county"),
                  by.y=c("SYSTEM","COUNTY"))
  return(milk_f)
}


time_variables<-function(milk){
  #set up seasonal information by finding out information on the first and last let dates
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
  return(milk)
}


setup_level<-function(milk){
  #removing NAs so I can add
  milk$WW[is.na(milk$WW)] <- 0
  milk$QWW[is.na(milk$QWW)] <- 0
  milk$WC[is.na(milk$WC)] <- 0
  milk$QWC[is.na(milk$QWC)] <- 0
  milk$LFW[is.na(milk$LFW)] <- 0
  milk$QLFW[is.na(milk$QLFW)] <- 0
  milk$LFC[is.na(milk$LFC)] <- 0
  milk$QLFC[is.na(milk$QLFC)] <- 0
  
  milk$LEVEL<- (milk$WW*milk$QWW + milk$WC*milk$QWC+ milk$LFW*milk$QLFW + milk$LFC*milk$QLFC)/(
    1.0*milk$QWW + milk$QWC + milk$LFW + milk$LFC)
  
  milk$LEVEL[(milk$LEVEL==0.0)] <- NA
  return(milk$LEVEL)
}


#Read data and set up necessary tables for regression  ---------------------------
milk <- data.frame(read.csv("~/Documents/tx_milk/input/milk_out.csv"))

#drop variables with bad dates (i.e.)
milk <- milk[which(milk$MONTH!=0  & milk$MONTH!=0),]

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
                      #"begint" = milk$BEGINT,
                      #"endt"=milk$ENDT,
                      #"lbackt"= log(1+milk$BACKLOGT),
                      "lseason" = log(milk$SEASONQ))

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
                     #"begint" = milk$BEGINT,
                     #"endt"=milk$ENDT,
                     #"lbackt"= log(1+milk$BACKLOGT),
                     "lseason" = log(milk$SEASONQ))

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
                      #"begint" = milk$BEGINT,
                      #"endt"=milk$ENDT,
                      #"lbackt"= log(1+milk$BACKLOGT),
                      "lseason" = log(milk$SEASONQ))

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
                     #"begint" = milk$BEGINT,
                     #"endt"=milk$ENDT,
                     #"lbackt"= log(1+milk$BACKLOGT),
                     "lseason" = log(milk$SEASONQ))


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
