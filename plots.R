#Refresh Working Environment ---------------------------
rm(list=ls())


#Import statements ---------------------------
library(IDPmisc)


#function definitions ---------------------------
plot1<-function(milk,dir,years,types){
  #create dir
  dir.create(dir, showWarnings = FALSE)
  #loop over years and types
  for (year in years) {
    for (type in types){
      #filter data
      milkf <- milk[ which(milk$type==type & milk$year==year & milk$win==1 ), ]
      
      #create file path
      file_path <- paste(dir,'plot_',year, "_", type, ".png", sep="")
      
      #create PNG image
      png(filename=file_path)
      plot(milkf$biddate, milkf$bid, main=paste("Winning Milk bids in",  year, "on", type),
           xlab="date ", ylab="Bids", pch=19) 
      dev.off()
    }
  }
}


plot2<-function(milk,dir,years,types){
  #create dir
  dir.create(dir, showWarnings = FALSE)
  week = 7
  for (year in years) {
    for (type in types){
      #filter data by year and type
      milkf <- milk[ which(milk$year==year & milk$type==type & milk$win==1), ]
      
      start <- as.Date(as.character(year*10000+710),"%Y%m%d")
      end <-tail( (milkf[order(milkf$biddate),]$biddate), 1)
      weeks <- c()
      avg_bids <- c()
      while (start < end){
        milkw <- milkf[ which(milkf$biddate >= start & milkf$biddate < (start+week) ), ]
        weeks<- c(start,weeks)
        avg_bids<- c(mean(milkw$bid),avg_bids)
        start <- start + week
      }
      
      file_path <- paste(dir, "avgs_",year, "_", type, ".png", sep="")
      
      #create PNG image
      png(filename=file_path)
      plot(weeks, avg_bids, main=paste("Weekly Average Winning Milk Bids in",  year, "on", type),
          xlab="Week ", ylab="Bids", pch=19) 
      dev.off()
    }
  }
}


last_bids<-function(milk,dir,years,types){
  #create dir
  dir.create(dir, showWarnings = FALSE)
  #pre-process data
  for (type in types){
    milkf <- milk[ which(milk$type==type & milk$win==1), ]
    milkf<-milkf[order(milkf$biddate),]
    #initialize results
    results<-milkf[1,]
    for (year in years){
      milky<-milkf[which(milkf$year==year),]
      top<-tail(milky,5)
      results<-rbind(results,top)
    }
    #delete first row (hacky way to initialize)
    results <- results[-1,]
    #filter columns
    results<-results[c("biddate","bid", "county","system","vendor")]
    write.csv(results, file = paste(dir, "last_bids.csv", sep=""),  row.names=FALSE)
  }
}  


#Load data into memory ---------------------------
milk <- data.frame(read.csv("~/Documents/tx_milk/input/clean_milk.csv"))

milk$bid = exp(milk$lbid)
milk$biddate<-as.Date(as.character(milk$biddate),"%Y%m%d")


#only include correct processors
milk <- milk[(milk$vendor=="BORDEN" | milk$vendor=="CABELL" 
              | milk$vendor=="FOREMOST" | milk$vendor=="OAK FARMS"
              | milk$vendor=="PRESTON" | milk$vendor=="SCHEPPS"
              | milk$vendor=="VANDERVOORT"),]

#only include correct years
milk <- milk[which(milk$year>=1980 & milk$year <=1990),]

#Drop inf, na, and nan
milk<-NaRV.omit(milk)

years <- 1980:1990
types <- c('ww')


#Make plots 1 ---------------------------
dir1<-'~/Documents/tx_milk/output/plots1/'
dir2<-'~/Documents/tx_milk/output/plots2/'
dir3<-'~/Documents/tx_milk/output/'

plot1(milk,dir1,years,types)
plot2(milk,dir2,years,types)
last_bids(milk,dir3,years,types)

#Make plots for SA ---------------------------
milkSA<-milk[which(milk$fmozone==9),]

dirSA1<-'~/Documents/tx_milk/output/plotsSA1/'
dirSA2<-'~/Documents/tx_milk/output/plotsSA2/'

plot1(milk,dirSA1,years,types)
plot2(milk,dirSA2,years,types)

