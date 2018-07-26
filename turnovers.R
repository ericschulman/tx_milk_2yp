rm(list=ls())
source("~/Documents/tx_milk/models.R")


#Test code ----------------
input_dir <- "~/Documents/tx_milk/input/clean_milkm.csv"
milk <- load_milk(input_dir,clean=FALSE)
milklag<-lag_wins(milk)

milkturn <- milklag[which(milklag$win.prev!=milklag$win ),]
milkturn <- milkturn[order(milkturn$biddate, milkturn$win, milkturn$system,milkturn$vendor),]
#print(milkturn[which(milkturn$year == 1985),] [,c('biddate','system','vendor','win')]  )

loosers<-milkturn[which(milkturn$win.prev==1),][,c('biddate','system', 'county','vendor','level','level.prev','year')]
winners<-milkturn[which(milkturn$win.prev==0),][,c('biddate','system', 'county', 'vendor','level','level.prev','year')]

bothl <- merge(loosers, winners,
              by.x=c('biddate','system','county','year'),
              by.y=c('biddate','system','county','year'),
              suffixes=c(".loose",".win"), all.x =TRUE)

bothw <- merge(winners, loosers,
              by.x=c('biddate','system','county','year'),
              by.y=c('biddate','system','county','year'),
              suffixes=c(".win",".loose"), all.x =TRUE)

resp <-merge(bothl,bothw,
             suffixes=c(".init",".resp"), 
             all.x =TRUE)

resp2<-resp[ which(resp$vendor.loose.init == resp$vendor.win.resp) & 
              (resp$vendor.win.init == resp$vendor.loose.resp), ]

#print(resp[which(result$year.init==1985),])

#result<-resp[,c('vendor.loose','vendor.win','biddate.init','biddate.resp','system.init','level.win.init','level.loose.init',
#                'system.resp','level.win.resp','level.loose.resp')]
#find first possible retaliation
#result<-result[which(result$biddate.init<result$biddate.resp),]
#result<-result[order(result$biddate.init,result$biddate.resp,result$system.init),]


