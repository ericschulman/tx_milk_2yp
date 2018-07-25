rm(list=ls())
source("~/Documents/tx_milk/models.R")


#Test code ----------------
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

result<-resp[,c('vendor.loose','vendor.win','biddate.init','biddate.resp','system.init','level.win.init','level.loose.init','system.resp','level.win.resp','level.loose.resp')]
#find first possible retaliation
result<-result[which(result$biddate.init<result$biddate.resp),]
result<-result[order(result$biddate.init,result$biddate.resp,result$system.init),]
result <-result[ !duplicated(result[,c('vendor.loose','vendor.win','biddate.init')]), ]

print(result)
dir<-"~/Documents/tx_milk/output/"
write.csv(resp ,
          file = paste(dir, "turnovers.csv", sep=""),  row.names=FALSE)
