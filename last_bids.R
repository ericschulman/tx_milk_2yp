#Refresh Working Environment
rm(list=ls())

#Import statements
library(stargazer)
library(IDPmisc)
library(lme4)
library(nloptr)

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
