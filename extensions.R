#Refresh Working Environment ---------------------------
rm(list=ls())


#Import statements ---------------------------
library(stargazer)
library(IDPmisc)
library(lme4)
library(nloptr)
library(car)


#function definitions ---------------------------
table6<-function(milk,dir,label,fname="table6.tex"){
  #fit model
  fit <- lmer(lbid ~ inc + type_dum + lfmo + lestqty + lnostop + lback + esc + lnum
              + (1 + lfmo | system/year) , data=milk, control=lmerControl(optimizer="nloptwrap"))
  #write to latex
  fname<-paste(dir,fname,sep="")
  output <- capture.output(stargazer(fit, title=label, align=TRUE, type = "latex", out=fname,no.space=TRUE))
  return(fit) 
}


table6fe<-function(milk,dir,label,fname="table6fe.tex"){
  #fit model - fixed effects for mkt as well
  fit <- lmer(lbid ~ inc + type_dum + lfmo + lestqty + lnostop + lback + esc + lnum
              + (1 + lfmo | fmozone/system/year) , data=milk, control=lmerControl(optimizer="nloptwrap"))
  #write to latex
  fname<-paste(dir,fname,sep="")
  output <- capture.output(stargazer(fit, title=label, align=TRUE, type = "latex", out=fname,no.space=TRUE))
  return(fit)
  #
  milk$sa <- as.integer(milk$fmozone==9)
  milk$dfw <- as.integer(milk$fmozone==1)
}


table6c<-function(milk,dir,label,fname="table6c.tex"){
  #fixed effects for just SA and DFW
  milk$sa <- as.integer(milk$fmozone==9)
  milk$dfw <- as.integer(milk$fmozone==1)
  
  #fit model
  fit <- lmer(lbid ~ inc + type_dum + lfmo + lestqty + lnostop + lback + esc + lnum + sa + dfw
              + (1 + lfmo | system/year) , data=milk, control=lmerControl(optimizer="nloptwrap"))
  #write to latex
  fname<-paste(dir,fname,sep="")
  output <- capture.output(stargazer(fit, title=label, align=TRUE, type = "latex", out=fname,no.space=TRUE))
  return(fit) 
}


table6ci<-function(milk,dir,label,fname="table6ci.tex"){
  #fixed effects for just SA and DFW
  
  milk_sa <-milk[which(milk$fmozone==9 & milk$year <=1991), ]
  milk_dfw<-milk[which(milk$fmozone==1 & milk$year <=1991), ]
  milk_misc <- milk[which(milk$fmozone!=1 & milk$fmozone!=9 & milk$year <=1991), ]
  
  #fit model
  fit_sa <- lmer(lbid ~ inc + type_dum + lfmo + lestqty + lnostop + lback + esc + lnum
              + (1 + lfmo | system/year) , data=milk_sa, control=lmerControl(optimizer="nloptwrap"))
  fit_dfw <- lmer(lbid ~ inc + type_dum + lfmo + lestqty + lnostop + lback + esc + lnum
                 + (1 + lfmo | system/year) , data=milk_dfw, control=lmerControl(optimizer="nloptwrap"))
  fit_misc <- lmer(lbid ~ inc + type_dum + lfmo + lestqty + lnostop + lback + esc + lnum
                 + (1 + lfmo | system/year) , data=milk_misc, control=lmerControl(optimizer="nloptwrap"))
  
  #write to latex
  fname<-paste(dir,fname,sep="")
  output <- capture.output(stargazer(fit_misc, fit_dfw, fit_sa, title=label, align=TRUE, type = "latex", out=fname,no.space=TRUE))
  return(fit) 
}


load_milk<-function(dir){
  milk <- data.frame(read.csv(dir))
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
  
  return(milk)
}


filter_data<-function(milk){
  ids <- data.frame(read.csv("~/Documents/tx_milk/input/ids/complete_isd.csv"))
  
  milk_f <- merge(milk, ids,
                  by.x=c("system","county"),
                  by.y=c("SYSTEM","COUNTY"))
  return(milk_f)
}


#import data and set up correct ---------------------------
input_dir <- "~/Documents/tx_milk/input/clean_milk.csv"
milk <- load_milk(input_dir)


#Run functions on all data ---------------------------
out_dir<-"~/Documents/tx_milk/output/tables_mkt/"
dir.create(out_dir, showWarnings = FALSE)

fit1<-table6(milk,out_dir,"Pooled Table 6 Results (All ISDs 1980-1991)")
fit2<-table6fe(milk,out_dir,"FMO Fixed Effects Table 6 Results (All ISDs 1980-1991)")
fit3<-table6c(milk,out_dir,"DFW and San Antonio Dummy Table 6 Results (All ISDs 1980-1991)")
fit4<-table6ci(milk,out_dir,"Table 6 Results by Market (All ISDs 1980-1991)")
