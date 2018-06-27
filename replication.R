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
  
  fit <- lmer(lbid ~ win.prev  + type_dum + lfmo + lqstop
               + (1 | system/year) , control=lmerControl(optimizer="nloptwrap"), data=milk_m)
  
  #write to latex
  fname<-paste(dir,"table10.tex",sep="")
  output <- capture.output(stargazer(fit, title=label, align=TRUE, type = "latex", out=fname, no.space=TRUE))
  return(fit)
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
dir.create(dir, showWarnings = FALSE)

fit<-table5(milk,dir,"Reproduced Table 5 Regression (All Available Data)")
fit2<-table6(milk,dir,"Reproduced Table 6 Regression (All Available Data)")
fit3<-table6m(milk,dir,"Modified Table 6 Regression (All Available Data)")


#Run functions on SA data ---------------------------

#Focus on SA area
milk_sa<-milk[which(milk$fmozone==9),]

dir_sa<-"~/Documents/tx_milk/output/tables_sa/"
dir.create(dir_sa, showWarnings = FALSE)

fit_sa<-table5(milk_sa,dir_sa,"Reproduced Table 5 Regression (All Available Data for San Antonio)")
fit_sa2<-table6(milk_sa,dir_sa,"Reproduced Table 6 Regression (All Available Data for San Antonio)")
fit_sa3<-table6m(milk_sa,dir_sa,"Modified Table 6 Regression (All Available Data for San Antonio)")
fit_sa4<-table10(milk_sa,dir_sa,"Reproduced Table 10 Regression (All Available Data for San Antonio)")


#Run functions on subset of data ---------------------------

#only include 'correct' processors (i.e. complete data)
ids <- data.frame(read.csv("~/Documents/tx_milk/input/ids/ids8.csv"))

milk_f <- merge(milk, ids,
                     by.x=c("system","vendor","county","esc"),
                     by.y=c("SYSTEM","VENDOR","COUNTY","ESC"))

#create directory
dir_f<-"~/Documents/tx_milk/output/tables_f/"
dir.create(dir_f, showWarnings = FALSE)

fit_f<-table5(milk_f,dir_f,"Reproduced Table 5 Regression (Filtered Data)")
fit_f2<-table6(milk_f,dir_f,"Reproduced Table 6 Regression (Filtered Data)")
fit_f3<-table6m(milk_f,dir_f,"Modified Table 6 Regression (Filtered Data)")


#Run functions on subset of data for SA ---------------------------
#Focus on SA area
milk_saf<-milk[which(milk_f$fmozone==9),]

#create directory
dir_saf<-"~/Documents/tx_milk/output/tables_saf/"
dir.create(dir_saf, showWarnings = FALSE)

fit_Filtered<-table5(milk_saf,dir_saf,"Reproduced Table 5 Regression (Filtered Data for San Antonio)")
fit_saf2<-table6(milk_saf,dir_saf,"Reproduced Table 6 Regression (Filtered Data for San Antonio)")
fit_saf3<-table6m(milk_saf,dir_saf,"Modified Table 6 Regression (Filtered Data for San Antonio)")
fit_saf4<-table10(milk_saf,dir_saf,"Reproduced Table 10 Regression (Filtered Data for San Antonio)")


#Hypothesis tests ---------------------------
linearHypothesis(fit, c("(Intercept)=inc","type_dumlfc=inc:type_dumlfc",
                        "type_dumlfw=inc:type_dumlfw","type_dumwc=inc:type_dumwc",
                        "lfmo = inc:lfmo","lqstop=inc:lqstop",
                        "lback=inc:lback","esc=inc:esc","lnum=inc:lnum" ))
linearHypothesis(fit_sa, c("(Intercept)=inc","type_dumlfc=inc:type_dumlfc",
                         "type_dumlfw=inc:type_dumlfw","type_dumwc=inc:type_dumwc",
                         "lfmo = inc:lfmo","lqstop=inc:lqstop",
                         "lback=inc:lback","esc=inc:esc","lnum=inc:lnum" ))
linearHypothesis(fit_f, c("(Intercept)=inc","type_dumlfc=inc:type_dumlfc",
                        "type_dumlfw=inc:type_dumlfw","type_dumwc=inc:type_dumwc",
                        "lfmo = inc:lfmo","lqstop=inc:lqstop",
                        "lback=inc:lback","esc=inc:esc","lnum=inc:lnum" ))
