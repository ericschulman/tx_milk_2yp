#Dependencies ---------------------------

rm(list=ls())
source("~/Documents/tx_milk/models.R")

#import data and set up correct ---------------------------

#set up vanilla data
input_dir <- "~/Documents/tx_milk/input/clean_milk.csv"
milk <- load_milk(input_dir)

#set up lee's data
milklag<-lag_wins(milk)
milklag<- milklag[which(milklag$year>=1981), ]

#set up fu's data
input_dirm <- "~/Documents/tx_milk/input/clean_milkm.csv"
milkm <- load_milk(input_dirm)
milkmlag<-lag_wins(milkm)
milkmlag<- milkmlag[which(milkmlag$year>=1986 & milkmlag$year <=1991), ]

#Run functions on all data ---------------------------

out_dir<-"~/Documents/tx_milk/output/writeup/"
dir.create(out_dir, showWarnings = FALSE)

#table 5 and 6 - dfw area (i.e. sibley, hewitt, mcclave)
milk_dfw<-milk[which(milk$fmozone==1 & milk$year <=1991), ]
fit_dfw<-table5(milk_dfw,out_dir,"Reproduced Table 5 Results (Dallas Ft. Worth 1980-1991)")
fit_dfw2<-table6(milk_dfw,out_dir,"Reproduced Table 6 Results (Dallas Ft. Worth 1980-1991)")

#fit Fu's models
fits_fu<-fu(milkmlag , out_dir , "Fu's Table 3.4 (All ISDs 1986-1991)")

#fit lee's models
fits_lee<-lee(milklag , out_dir , "Lee's Table II (DFW and SA 1980-1991)")

#extensions
fitall<-table6all(milk,out_dir,"Table 6 Results by City (1980-1991)")
fitseason<-table6season(milk,out_dir,"Table 6 Results with Percentage of Season Passed (1980-1991)")

#work in progress SA entry interaction
milk_sa <-milk[which(milk$fmozone==9 & milk$year <=1991), ]
fitsa <-table6sa(milk_sa, out_dir, "Table 6 Results with Interactions for Entry (SA 1980-1991)")
