#Refresh Working Environment ---------------------------
rm(list=ls())


#Import statements ---------------------------
library(stargazer)
library(IDPmisc)
library(lme4)
library(nloptr)
library(car)


#function definitions ---------------------------
table5<-function(milk,dir,label){
  #add not-incumbent column
  milk$ninc = (1-milk$inc)
  #fit model
  fit <- lmer(lbid ~ inc + 
                type_dum*inc + lfmo*inc + lqstop*inc + lback*inc + esc*inc +  lnum*inc + 
                type_dum*(1-inc) + lfmo*(1-inc) + lqstop*(1-inc) + lback*(1-inc) + esc*(1-inc) + lnum*(1-inc) +
                (1 | system/year) ,
                control=lmerControl(optimizer="nloptwrap"), data=milk)
  
  #write to latex
  fname<-paste(dir,"table5.tex",sep="")
  output <- capture.output(stargazer(fit, title=label, align=TRUE, type = "latex", out=fname, no.space=TRUE))
  return(fit)
}


table6<-function(milk,dir,label){
  #fit model
  fit <- lmer(lbid ~ inc + type_dum + lfmo + lestqty + lnostop + lback + esc + lnum
              + (1 | system/year) , data=milk, control=lmerControl(optimizer="nloptwrap"))
  #write to latex
  fname<-paste(dir,"table6.tex",sep="")
  output <- capture.output(stargazer(fit, title=label, align=TRUE, type = "latex", out=fname,no.space=TRUE))
  return(fit) 
}


table6m<-function(milk,dir,label){
  #Include a dummy for any bids taking place after August 10
  aug_10 =  as.Date(as.character(810+10000*milk$year),"%Y%m%d")
  milk$aug_10 <- as.integer(aug_10 > milk$biddate)
  
  #include a dummy for any ISD in Wise County
  milk$wise <- as.integer(milk$county=="WISE")
  
  #fit model
  fit <- lmer(lbid ~ inc + type_dum + lfmo + lestqty + lnostop + lback + esc + lnum + wise
               + (1 | system/year) + (1 | year), data=milk, control=lmerControl(optimizer="nloptwrap"))
  #write to latex
  fname<-paste(dir,"table6m.tex",sep="")
  output <- capture.output(stargazer(fit, title=label, align=TRUE, type = "latex", out=fname,no.space=TRUE))
  return(fit)
}


table10<-function(milk,dir,label){
  #create a lagged wins
  milk_m <- merge(milk, milk,
                  by.x=c("system","vendor","county","type","esc","fmozone"),
                  by.y=c("system","vendor","county","type","esc","fmozone"),
                  suffixes=c("",".prev"))
  
  milk_m <- milk_m[which(milk_m$year==(milk_m$year.prev+1)),]
  
  fit <- lmer(lbid ~ win.prev  + type_dum + lfmo + lqstop
               + (1 | system/year) , control=lmerControl(optimizer="nloptwrap"), data=milk_m)
  
  #write to latex
  fname<-paste(dir,"table10.tex",sep="")
  output <- capture.output(stargazer(fit, title=label, align=TRUE, type = "latex", out=fname, no.space=TRUE))
  return(fit)
}


filter_data<-function(milk){
  ids <- data.frame(read.csv("~/Documents/tx_milk/input/ids/complete_isd.csv"))
  
  milk_f <- merge(milk, ids,
                  by.x=c("system","county"),
                  by.y=c("SYSTEM","COUNTY"))
  return(milk_f)
}


#import data and set up correct ---------------------------
milk <- data.frame(read.csv("~/Documents/tx_milk/input/clean_milk2.csv"))

#setting up type dummies correctly
milk$type_dum <- factor(milk$type)
milk$type_dum <- relevel(milk$type_dum, ref = "ww")

#only include correct processors
milk <- milk[which(milk$vendor=="BORDEN" | milk$vendor=="CABELL" 
                           | milk$vendor=="FOREMOST" | milk$vendor=="OAK FARMS"
                           | milk$vendor=="PRESTON" | milk$vendor=="SCHEPPS"
                           | milk$vendor=="VANDERVOORT"),]

#fix bid dates
milk$biddate<-as.Date(as.character(milk$biddate),"%Y%m%d")

#focus on correct bid dates
milk <- milk[which(milk$year>=1980 & milk$year <=1991),]

#Drop inf, na, and nan 
milk<-NaRV.omit(milk)


#Run functions on all data ---------------------------
dir<-"~/Documents/tx_milk/output/tables/"
dir.create(dir, showWarnings = FALSE)

fit<-table5(milk,dir,"Reproduced Table 5 Results (All ISDs 1980-1991)")
fit2<-table6m(milk,dir,"Modified Table 6 Results (All ISDs 1980-1991)")

#Run functions on SA data ---------------------------
#set up SA data
milk_sa<-milk[which(milk$fmozone==9 & milk$year >= 1988 & milk$year <=1991), ]

dir_sa<-"~/Documents/tx_milk/output/tables_sa/"
dir.create(dir_sa, showWarnings = FALSE)

fit_sa<-table6(milk_sa,dir_sa,"Reproduced Table 6 Results (San Antonio 1988-1991)")
fit_sa1<-table10(milk_sa,dir_sa,"Reproduced Table 10 Results (San Antonio 1988-1991)")

# 'Broken' Regression ---------------------------
#set up data
milk_m1<-milk[which(milk$year <=1990), ]
milk_m2<-milk[which(milk$fmozone==9 & milk$year >= 1980 & milk$year <=1990), ]

dir_m<-"~/Documents/tx_milk/output/tables_m/"
dir.create(dir_m, showWarnings = FALSE)

fit_sa<-table5(milk_m1,dir_m,"Reproduced Table 5 Results (All ISDs 1980-1990)")
fit_sa1<-table10(milk_m2,dir_m,"Reproduced Table 10 Results (San Antonio 1980-1990)")

#Hypothesis tests ---------------------------
linearHypothesis(fit, c("(Intercept)=inc","type_dumlfc=inc:type_dumlfc",
                        "type_dumlfw=inc:type_dumlfw","type_dumwc=inc:type_dumwc",
                        "lfmo = inc:lfmo","lqstop=inc:lqstop",
                        "lback=inc:lback","esc=inc:esc","lnum=inc:lnum" ))
