#Refresh Working Environment ---------------------------
rm(list=ls())

#Import statements ---------------------------
library(IDPmisc)


#function definitions ---------------------------
plot1<-function(milk){
  #initialize different combos for for loop
  years <- seq(1980,1989)
  types <- c('ww','lfw','lfc','wc')
  
  #Drop inf, na, and nan
  milk<-NaRV.omit(milk)
  
  for (year in years) {
    for (type in types){
      #filter data
      milkf <- milk[ which(milk$type==type & milk$year==year & milk$win==1 ), ]
      
      #create file path
      file_path <- paste('~/Documents/tx_milk/output/plots/plot_',year, "_", type, ".png", sep="")
      
      #create PNG image
      png(filename=file_path)
      plot(milkf$biddate, milkf$bid, main=paste("Milk bids in",  year, "on", type),
           xlab="date ", ylab="Bids", pch=19) 
      dev.off()
    }
  }
}


plot2<-function(milk){
  #initialize different combos for for loop
  years <- seq(1980,1989)
  types <- c('ww')
  
  for (year in years) {
    for (type in types){
      #hard coding weeks, because seems easier this way
      weeks <- c(717,724,731,807,814,821,829,905,912,919,928,1005,1012,1017)
      prev_week <- 710
      avg_bids <- 1:length(weeks)
      index <- 0:(length(weeks)-1)
      
      #filter data
      date <- (milk$biddate - milk$year*10000)
      for (i in index){
        milkf <- milk[ which(milk$type==type & milk$year==year & milk$win==1 
                             & date >= prev_week & date < weeks[i]), ]
        avg_bids[i]<- mean(milkf$bid)
        prev_week<-weeks[i]
      }
      
      file_path <- paste('~/Documents/tx_milk/output/plots2/plot_',year, "_", type, ".png", sep="")
      
      #create PNG image
      png(filename=file_path)
      plot(head(weeks,-1), head(avg_bids,-1), main=paste("Weekly Average Milk Bids in",  year, "on", type),
           xlab="Week ", ylab="Bids", pch=19) 
      dev.off()
    }
  }
}


last_bids<-function(){
  #import data
  milk <- data.frame(read.csv("~/Documents/tx_milk/input/milk_out.csv"))
  #pre-process data
  milk<-milk[which(milk$WIN==1 ),]
  milk<-milk[!is.na(milk$WW),]
  milk <- milk[(milk$VENDOR=="BORDEN" | milk$VENDOR=="CABELL" 
                | milk$VENDOR=="FOREMOST" | milk$VENDOR=="OAK FARMS"
                | milk$VENDOR=="PRESTON" | milk$VENDOR=="SCHEPPS"
                | milk$VENDOR=="VANDERVOORT"),]
  milk<-milk[order(-milk$YEAR, -milk$MONTH, -milk$DAY),]
  #initialize results
  results<-milk[1,]
  #list years
  years<-unique(milk$YEAR)
  for (year in years){
    milkf<-milk[which(milk$YEAR==year),]
    top<-milkf[1:5,]
    results<-rbind(results,top)
  }
  #delete first row (hacky way to initialize)
  results <- results[-1,]
  #filter columns
  results<-results[c("YEAR","MONTH","DAY","WW",
                     "COUNTY","SYSTEM","VENDOR")]
  write.csv(results, file = "~/Documents/tx_milk/output/last_bids.csv",  row.names=FALSE)
}


#Code to be run ---------------------------


#Load data into memory ---------------------------
milk <- data.frame(read.csv("~/Documents/tx_milk/input/clean_milk.csv"))

milk$bid = exp(milk$lbid)

#Drop inf, na, and nan
milk<-NaRV.omit(milk)

#Drop inf, na, and nan 
milk<-NaRV.omit(milk)

#only include correct processors
milk <- milk[(milk$vendor=="BORDEN" | milk$vendor=="CABELL" 
              | milk$vendor=="FOREMOST" | milk$vendor=="OAK FARMS"
              | milk$vendor=="PRESTON" | milk$vendor=="SCHEPPS"
              | milk$vendor=="VANDERVOORT"),]

#only include correct years
milk <- milk[which(milk$year>=1980 & milk$year <=1990),]


#Actual Functions ---------------------------
plot1(milk)
plot2(milk)
last_bids()
