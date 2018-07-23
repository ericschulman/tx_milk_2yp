#Dependencies ---------------------------
rm(list=ls())
source("~/Documents/tx_milk/models.R")

#import data and set up correct ---------------------------
input_dir <- "~/Documents/tx_milk/input/clean_milk.csv"
milk <- load_milk(input_dir)
milklag<-lag_wins(milk)
milklag<- milklag[which(milklag$year>=1981 & milklag$year <=1991), ]

input_dirm <- "~/Documents/tx_milk/input/clean_milkm.csv"
milkm <- load_milk(input_dirm)
milkmlag<-lag_wins(milkm)
milkmlag<- milkmlag[which(milkmlag$year>=1986 & milkmlag$year <=1991), ]


#Run functions on all data ---------------------------
out_dir<-"~/Documents/tx_milk/output/ext/tables/"
dir.create(out_dir, showWarnings = FALSE)

#fit lee's models
fits_lee<-lee(milklag , out_dir , "Table II (Lee 1999)")

#fit table 6 with season control
fitseason<-table6season(milk , out_dir , "Table 6 Modified with Season")

#fit Fu's models
fits_fu<-fu(milkmlag , out_dir , "Table 3.4 (Fu 2011)")