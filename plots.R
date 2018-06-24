#Refresh Working Environment
rm(list=ls())

#Import statements
library(IDPmisc)

#load data into memory
milk <- data.frame(read.csv("~/Documents/tx_milk/input/clean_milk3.csv"))
milk$bid = exp(milk$lbid)

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



