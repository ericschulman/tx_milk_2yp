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
  #fit model
  fit <- lmer(lbid ~ inc + type_dum*inc + lfmo*inc + lqstop*inc + lback*inc + esc*inc +  lnum*inc + type_dum*(1-inc)
              + lfmo*(1-inc) + lqstop*(1-inc) + lback*(1-inc) + esc*(1-inc) +  lnum*(1-inc)  
              + (1 | system/year) , control=lmerControl(optimizer="nloptwrap"), data=milk)
  
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
  milk$aug_10 <- as.integer(milk$biddate - milk$year*10000 >= 810)
  
  #include a dummy for any ISD in Wise County
  milk$wise <- as.integer(milk$county=="WISE")
  
  #fit model
  fit <- lmer(lbid ~ inc + type_dum + lfmo + lestqty + lnostop + lback + esc + lnum
               + aug_10 + wise + (1 | system/year) , data=milk, control=lmerControl(optimizer="nloptwrap"))
  #write to latex
  fname<-paste(dir,"table6m.tex",sep="")
  output <- capture.output(stargazer(fit, title=label, align=TRUE, type = "latex", out=fname,no.space=TRUE))
  return(fit)
}


table10<-function(milk,dir,label){
  #create a lagged wins
  milk_m <- merge(milk, milk,
                  by.x=c("system","vendor","county","type","esc"),
                  by.y=c("system","vendor","county","type","esc"),
                  suffixes=c("",".prev"))
  
  milk_m <- milk_m[which(milk_m$year==(milk_m$year.prev+1)),]
  
  fit4 <- lmer(lbid ~ win.prev  + type_dum + lfmo + lqstop
               + (1 | system/year) , control=lmerControl(optimizer="nloptwrap"), data=milk_m)
  
  #write to latex
  fname<-paste(dir,"table10.tex",sep="")
  output <- capture.output(stargazer(fit4, title=label, align=TRUE, type = "latex", out=fname, no.space=TRUE))
}


#import data and set up correct ---------------------------
milk <- data.frame(read.csv("~/Documents/tx_milk/input/clean_milk.csv"))

#setting up type dummies correctly
milk$type_dum <- factor(milk$type)
milk$type_dum <- relevel(milk$type_dum, ref = "ww")

#Drop inf, na, and nan 
milk<-NaRV.omit(milk)

#only include correct processors
milk <- milk[(milk$vendor=="BORDEN" | milk$vendor=="CABELL" 
                           | milk$vendor=="FOREMOST" | milk$vendor=="OAK FARMS"
                           | milk$vendor=="PRESTON" | milk$vendor=="SCHEPPS"
                           | milk$vendor=="VANDERVOORT"),]

#only include correct years
milk <- milk[which(milk$year>=1980 & milk$year <=1990),]


#Run functions on all data ---------------------------
dir<-"~/Documents/tx_milk/output/tables/"

fit<-table5(milk,dir,"Table 5 Results All Data")
fit2<-table6(milk,dir,"Table 6 Results All Data")
fit3<-table6m(milk,dir,"Table 6 Modified Results All Data")


#Run functions on SA data ---------------------------

#Focus on SA area
milkSA<-milk[which(milk$fmozone==9),]

dirSA<-"~/Documents/tx_milk/output/tablesSA/"

fitSA<-table5(milkSA,dirSA,"Table 5 Results San Antonio")
fitSA2<-table6(milkSA,dirSA,"Table 6 Results San Antonio")
fitSA3<-table6m(milkSA,dirSA,"Table 6 Modified Results San Antonio")
fitSA4<-table10(milkSA,dirSA,"Table 10 Results")


#Run functions on subset of data ---------------------------

#only include 'correct' processors (i.e. complete data)
ids <- data.frame(read.csv("~/Documents/tx_milk/input/ids/ids8.csv"))

milkC <- merge(milk, ids,
                     by.x=c("system","vendor","county","esc"),
                     by.y=c("SYSTEM","VENDOR","COUNTY","ESC"))

dirC<-"~/Documents/tx_milk/output/tablesC/"

fitC<-table5(milkC,dirC,"Table 5 Results 'Filtered' Observations")
fitC2<-table6(milkC,dirC,"Table 6 Results 'Filtered' Observations")
fitC3<-table6m(milkC,dirC,"Table 6 Modified 'Filtered' Observations")


#Run functions on subset of data for SA ---------------------------
#Focus on SA area
milkSAC<-milk[which(milkC$fmozone==9),]
dirSAC<-"~/Documents/tx_milk/output/tablesSAC/"
fitSAC<-table5(milkSAC,dirSAC,"Table 5 Results San Antonio with 'Filtered' Observations")
fitSAC2<-table6(milkSAC,dirSAC,"Table 6 Results San Antonio with 'Filtered' Observations")
fitSAC3<-table6m(milkSAC,dirSAC,"Table 6 Modified Results San Antonio with 'Filtered' Observations")
fitSAC4<-table10(milkSAC,dirSAC,"Table 10 Results with 'Filtered' Observations")


#Hypothesis tests ---------------------------
linearHypothesis(fit, c("(Intercept)=inc","type_dumlfc=inc:type_dumlfc",
                        "type_dumlfw=inc:type_dumlfw","type_dumwc=inc:type_dumwc",
                        "lfmo = inc:lfmo","lqstop=inc:lqstop",
                        "lback=inc:lback","esc=inc:esc","lnum=inc:lnum" ))
linearHypothesis(fitSA, c("(Intercept)=inc","type_dumlfc=inc:type_dumlfc",
                         "type_dumlfw=inc:type_dumlfw","type_dumwc=inc:type_dumwc",
                         "lfmo = inc:lfmo","lqstop=inc:lqstop",
                         "lback=inc:lback","esc=inc:esc","lnum=inc:lnum" ))
linearHypothesis(fitC, c("(Intercept)=inc","type_dumlfc=inc:type_dumlfc",
                        "type_dumlfw=inc:type_dumlfw","type_dumwc=inc:type_dumwc",
                        "lfmo = inc:lfmo","lqstop=inc:lqstop",
                        "lback=inc:lback","esc=inc:esc","lnum=inc:lnum" ))
