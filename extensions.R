#Refresh Working Environment ---------------------------
rm(list=ls())


#Import statements ---------------------------
library(stargazer)
library(IDPmisc)
library(lme4)
library(nloptr)
library(car)
source("data_clean.R")


#function definitions ---------------------------

lee<-function(milk,dir,label,fname='lee.tex'){
  #trying to replicate lee's results from 1999
  fit <- lm(lbid ~ inc + begin + end + entry + onebid + type_dum + lfmo + lestqty + lnostop + lback + esc, data=milk)
  
  fit_fe <- lmer(lbid ~ inc + begin + end + entry + onebid + type_dum + lfmo + lestqty + lnostop + lback + esc
              + (1 | system/year) , data=milk, control=lmerControl(optimizer="nloptwrap"))
  
  #limit to dfw data
  milk_dfw<-milk[which(milk$fmozone==1 & milk$year <=1991), ]
  fit_dfw <- lmer(lbid ~ inc + begin + end + entry + onebid + type_dum + lfmo + lestqty + lnostop + lback + esc
                 + (1 | system/year) , data=milk_dfw, control=lmerControl(optimizer="nloptwrap"))
  
  fname<-paste(dir,fname,sep="")
  output <- capture.output(stargazer(fit,fit_fe,fit_dfw, title=label, align=TRUE, type = "latex", out=fname,no.space=TRUE))
  return(c(fit,fit_fe,fit_dfw))
}


table6<-function(milk,dir,label,fname="table6.tex"){
  #4 regressions side by side with pooled, SA, DFW, and misc
  
  #set up data
  milk_sa <-milk[which(milk$fmozone==9 & milk$year <=1991), ]
  milk_dfw<-milk[which(milk$fmozone==1 & milk$year <=1991), ]
  milk_misc <- milk[which(milk$fmozone!=1 & milk$fmozone!=9 & milk$year <=1991), ]
  
  #fit models
  fit <- lmer(lbid ~ inc + type_dum + lfmo + lestqty + lnostop + lback + esc + lnum
              + (1 + lfmo | system/year) , data=milk, control=lmerControl(optimizer="nloptwrap"))
  fit_dfw <- lmer(lbid ~ inc + type_dum + lfmo + lestqty + lnostop + lback + esc + lnum
                  + (1 + lfmo | system/year) , data=milk_dfw, control=lmerControl(optimizer="nloptwrap"))
  fit_sa <- lmer(lbid ~ inc + type_dum + lfmo + lestqty + lnostop + lback + esc + lnum
                 + (1 + lfmo | system/year) , data=milk_sa, control=lmerControl(optimizer="nloptwrap"))
  fit_misc <- lmer(lbid ~ inc + type_dum + lfmo + lestqty + lnostop + lback + esc + lnum
                   + (1 + lfmo | system/year) , data=milk_misc, control=lmerControl(optimizer="nloptwrap"))
  
  #write to latex
  fname<-paste(dir,fname,sep="")
  output <- capture.output(stargazer(fit, fit_dfw, fit_sa, fit_misc, title=label, align=TRUE, type = "latex", out=fname,no.space=TRUE))
  
  return(c(fit,fit_dfw,fit_sa,fit_misc)) 
}


table6w<-function(milk,dir,label,fname="table6w.tex"){
  #filter for dfw
  milk<-milk[which(milk$fmozone==1 & milk$year <=1991), ]
  
  #Include a dummy for any bids taking place in wise county
  aug_10 =  as.Date(as.character(810+10000*milk$year),"%Y%m%d")
  milk$aug_10 <- as.integer(aug_10 > milk$biddate)
  
  #include a dummy for any ISD in Wise County
  milk$wise <- as.integer(milk$county=="WISE")
  
  #fit model
  fit <- lmer(lbid ~ inc + type_dum + lfmo + lestqty + lnostop + lback + esc + lnum + wise + aug_10
              + (1 + lfmo | system/year) , data=milk, control=lmerControl(optimizer="nloptwrap"))
  #write to latex
  fname<-paste(dir,fname,sep="")
  output <- capture.output(stargazer(fit, title=label, align=TRUE, type = "latex", out=fname,no.space=TRUE))
  return(fit)
}


table6fe<-function(milk,dir,label,fname="table6fe.tex"){
  #create dummy variables
  milk$sa <- as.integer(milk$fmozone==9)
  milk$dfw <- as.integer(milk$fmozone==1)
  #fit model - fixed effects for mkt as well (hence fe)
  fit <- lmer(lbid ~ inc + type_dum + lfmo + lestqty + lnostop + lback + esc + lnum
              + (1 + lfmo | fmozone/system/year) , data=milk, control=lmerControl(optimizer="nloptwrap"))
  #write to latex
  fname<-paste(dir,fname,sep="")
  output <- capture.output(stargazer(fit, title=label, align=TRUE, type = "latex", out=fname,no.space=TRUE))
  return(fit)
}


table6c<-function(milk,dir,label,fname="table6c.tex"){
  #categorical variables for just SA and DFW (Hence c)
  milk$sa <- as.integer(milk$fmozone==9)
  milk$dfw <- as.integer(milk$fmozone==1)
  milk$aust <- as.integer(milk$fmozone==7)
  
  #fit model
  fit <- lmer(lbid ~ inc + type_dum + lfmo + lestqty + lnostop + lback + esc + lnum + sa + dfw
              + (1 + lfmo | system/year) , data=milk, control=lmerControl(optimizer="nloptwrap"))
  #write to latex
  fname<-paste(dir,fname,sep="")
  output <- capture.output(stargazer(fit, title=label, align=TRUE, type = "latex", out=fname,no.space=TRUE))
  return(fit) 
}


#import data and set up correct ---------------------------
input_dir <- "~/Documents/tx_milk/input/clean_milk.csv"
milk <- load_milk(input_dir)

#Run functions on all data ---------------------------
out_dir<-"~/Documents/tx_milk/output/ext/tables/"
dir.create(out_dir, showWarnings = FALSE)

fits<-table6(milk,out_dir,"Table 6 Results (By Market)")
fit2<-table6fe(milk,out_dir,"Table 6 Results (Market Fixed Effects)")
fit3<-table6c(milk,out_dir,"Table 6 Results (Categorical Variables)")
fit4<-table6w(milk,out_dir,"Quick Check for August")
fits_lee<-lee(milk , out_dir , "Lee Table II")
