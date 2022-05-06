rm(list=ls())
source("~/Documents/tx_milk/models.R")

turnovers0<-function(){
  #turnovers but only where both firms bid into the same district in both years
  input_dir <- "~/Documents/tx_milk/input/clean_milkm.csv"
  milk <- load_milk(input_dir,clean=FALSE)
  milklag<-lag_wins(milk)
  milkturn <- milklag[which(milklag$win.prev!=milklag$win & !is.na(milklag$rowid.prev) ),]
  milkturn <- milkturn[order(milkturn$biddate, milkturn$win, milkturn$system,milkturn$vendor),]
  #print((milkturn$biddate))
  #print(duplicated(milkturn$biddate))
  milkturn <-milkturn[ !duplicated(milkturn[,c('win','vendor','system','biddate')], fromLast = TRUE), ]
  milkturn <-milkturn[ (duplicated(milkturn[,c('biddate','system')]) | duplicated(milkturn[,c('biddate','system')], fromLast = TRUE)) ,]
  milkturn <-milkturn[ !duplicated(milkturn[,c('win','system','biddate')], fromLast = TRUE), ]
  
  #merge winners with loosers
  winners<-milkturn[which(milkturn$win==1),][,c('biddate','system', 'county','vendor','level','level.prev')]
  loosers<-milkturn[which(milkturn$win==0),][,c('biddate','system', 'county', 'vendor','level','level.prev')]
  
  both <- merge(loosers, winners,
                by.x=c('biddate','system','county'),
                by.y=c('biddate','system','county'),
                suffixes=c(".win",".loose"), all.x =TRUE)
  
  resp <-merge(both,both,
               by.x=c('vendor.loose','vendor.win'),
               by.y=c('vendor.win','vendor.loose'),
               suffixes=c(".init",".resp"), 
               all.x =TRUE)
  
  result<-resp[,c('vendor.loose','vendor.win','biddate.init','biddate.resp','system.init','level.win.init','level.loose.init',
                  'system.resp','level.win.resp','level.loose.resp')]
  #find first possible retaliation
  result<-result[which(result$biddate.init<result$biddate.resp),]
  result<-result[order(result$biddate.init,result$biddate.resp,result$system.init),]
  result <-result[ !duplicated(result[,c('vendor.loose','vendor.win','biddate.init')]), ]
  colnames(result)<- c('incumbent','winner', 'biddate','response_date','district','winning_bid','incumbent_bid',
                       'response_district','incumbent_response','winner_response')
  
  print(result)
  dir<-"~/Documents/tx_milk/output/"
  write.csv(result , file = paste(dir, "turnovers0.csv", sep=""), row.names=FALSE)
}

turnovers1<-function(){
  input_dir <- "~/Documents/tx_milk/input/clean_milkm.csv"
  milk <- load_milk(input_dir,clean=FALSE)
  milk<-milk[which(milk$win==1),]
  milk_l <- milk
  milk_l$year <- milk_l$year + 1
  milklag<- merge(milk, milk_l,
                  by.x=c("system","county","fmozone","year"),
                  by.y=c("system","county","fmozone","year"),
                  suffixes=c("",".prev"), all.x =TRUE, all.y =TRUE)
  
  milkturn <- milklag[which(milklag$vendor.prev!=milklag$vendor ),]
  milkturn <- milkturn[order(milkturn$biddate, milkturn$system),]
  milkturn <-milkturn[ !duplicated(milkturn[,c('vendor.prev','vendor','system','biddate')], fromLast = TRUE), ]
  #print(milkturn[which( milkturn$year==1985 ),][,c('biddate','system','vendor','vendor.prev')] )
  
  trades<- merge(milkturn, milkturn,
                 by.x=c("vendor","vendor.prev"),
                 by.y=c("vendor.prev","vendor"),
                 suffixes=c(".init",".resp"), all.x =TRUE, all.y =TRUE)
  
  trades<-trades[which(trades$biddate.init < trades$biddate.resp),]
  trades<-trades[order(trades$biddate.init,trades$biddate.resp,trades$system.init),]
  trades <-trades[ !duplicated(trades[,c('vendor.prev','vendor','biddate.init')]), ]
  #trades <-trades[ !duplicated(trades[,c('vendor.prev','vendor','biddate.resp','system.resp')]), ]
  #print(list(trades))
  result<-trades[,c('biddate.init','biddate.resp','system.init','system.resp','vendor','vendor.prev')]
  print(result[which( trades$year.init==1985 ),] )
  dir<-"~/Documents/tx_milk/output/"
  write.csv(result , file = paste(dir, "turnovers1.csv", sep=""), row.names=FALSE)
}


#Test code ----------------

turnovers0()
turnovers1()
