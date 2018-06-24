#Refresh Working Environment
rm(list=ls())

#Import statements
library(IDPmisc)

#load data into memory
milk <- data.frame(read.csv("~/Documents/tx_milk/input/clean_milk3.csv"))
milk$bid = exp(milk$lbid)

#Drop inf, na, and nan
milk<-NaRV.omit(milk)

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

