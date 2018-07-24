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
winners<-milkturn[which(milkturn$win==1),][,c('biddate','system', 'county','vendor','ww','ww.prev')]
loosers<-milkturn[which(milkturn$win==0),][,c('biddate','system', 'county', 'vendor','ww','ww.prev')]
bleh <- merge(loosers, winners,
                by.x=c('biddate','system','county'),
                by.y=c('biddate','system','county'),
                suffixes=c(".win",".loose"), all.x =TRUE)

print(bleh)
#find first possible retaliation.


dir<-"~/Documents/tx_milk/output/"
result<-milkturn[,c('biddate','system', 'county', 'win','vendor','ww','ww.prev')]
write.csv(result ,
          file = paste(dir, "turnovers.csv", sep=""),  row.names=FALSE)
