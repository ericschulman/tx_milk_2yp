#Refresh Working Environment ---------------------------
rm(list=ls())


#Import statements ---------------------------
library(IDPmisc)


#function definitions ---------------------------
plot_bid<-function(milk,dir,years,types){
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


plot_avg<-function(milk,dir,years,types){
  #create dir
  dir.create(dir, showWarnings = FALSE)
  week = 7
  for (year in years) {
    for (type in types){
      #filter data by year and type
      milkf <-  milk[ which(milk$type==type & milk$year==year & milk$win==1 ), ]
      start <- head( (milkf[order(milkf$biddate),]$biddate), 1)
      end <-tail( (milkf[order(milkf$biddate),]$biddate), 1)
      weeks <- c()
      avg_bids <- c()
      while (start <= end){
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


#Make plots for all data ---------------------------
dir1<-'~/Documents/tx_milk/output/plots/'
dir2<-'~/Documents/tx_milk/output/plots_avg/'
dir3<-'~/Documents/tx_milk/output/'

plot_bid(milk,dir1,years,types)
plot_avg(milk,dir2,years,types)
last_bids(milk,dir3,years,types)


#Make plots for SA ---------------------------
milk_sa<-milk[which(milk$fmozone==9),]

dir_sa1<-'~/Documents/tx_milk/output/plots_sa/'
dir_sa2<-'~/Documents/tx_milk/output/plots_avgsa/'

plot_bid(milk_sa,dir_sa1,years,types)
plot_avg(milk_sa,dir_sa2,years,types)


#Make plots for filtered data ---------------------------
ids <- data.frame(read.csv("~/Documents/tx_milk/input/ids/ids8.csv"))

milk_f <- merge(milk, ids,
                by.x=c("system","vendor","county","esc"),
                by.y=c("SYSTEM","VENDOR","COUNTY","ESC"))

#create directory
dir_f<-"~/Documents/tx_milk/output/plots_f/"
dir_f2<-"~/Documents/tx_milk/output/plots_avgf/"

plot_bid(milk_f,dir_f,years,types)
plot_avg(milk_f,dir_f2,years,types)

