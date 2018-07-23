#Refresh Working Environment ---------------------------
rm(list=ls())


#Import statements ---------------------------
library(stargazer)
library(IDPmisc)
library(lme4)
library(nloptr)
library(car)
source("~/Documents/tx_milk/data_clean.R")


#function definitions ---------------------------

fu<-function(milk,dir,label,fname='fu.tex'){
  #trying to replicate fu's results from 2011 - only DFW
  fit_fe <- lmer(llevel ~  lestqty + lseasont + lnum + win.prev + ldist + lnostop + lbackt + lfmo + esc + cooler
                 + (1 | system/year) , data=milk, control=lmerControl(optimizer="nloptwrap"))
  fit_fe2 <- lmer(llevel ~ lestqty + lseasont + lnum + win.prev + ldist + lnostop + lbackt + lfmo + esc + cooler
                  + (1 | system/year/vendor) , data=milk, control=lmerControl(optimizer="nloptwrap"))
  fname<-paste(dir,fname,sep="")
  output <- capture.output(stargazer(fit_fe, fit_fe2, title=label, align=TRUE, type = "latex", out=fname,no.space=TRUE))
  return(fit_fe)
}


lee<-function(milk,dir,label,fname='lee.tex'){
  #trying to replicate lee's results from 1999 - only DFW
  milk<-milk[which( (milk$fmozone==1 | milk$fmozone==9) & milk$year <=1992), ]
  milk$lbacksq <- milk$lback*milk$lback
  fit <- lmer(lbid ~ win.prev + begin + end + entry + onebid + type_dum + lfmo + lqstop + lback + lbacksq + esc
              + (1 | system) + (1| year) , data=milk, control=lmerControl(optimizer="nloptwrap"))
  fit_fe <- lmer(lbid ~ win.prev + begin + end + entry + onebid + type_dum + lfmo + lqstop + lback + lbacksq + esc
                 + (1 | system/year) , data=milk, control=lmerControl(optimizer="nloptwrap"))
  
  fname<-paste(dir,fname,sep="")
  output <- capture.output(stargazer(fit , fit_fe, title=label, align=TRUE, type = "latex", out=fname,no.space=TRUE))
  return(fit)
}


table6season<-function(milk,dir,label,fname="table6season.tex"){
  #4 regressions side by side with pooled, SA, DFW, and misc
  #set up data
  milk <-milk[which(milk$year <=1991), ]
  milk_sa <-milk[which(milk$fmozone==9 & milk$year <=1991), ]
  milk_dfw<-milk[which(milk$fmozone==1 & milk$year <=1991), ]
  milk_misc <- milk[which(milk$fmozone!=1 & milk$fmozone!=9 & milk$year <=1991), ]
  #fit models
  fit <- lmer(lbid ~ inc + type_dum + lfmo + lestqty + lnostop + lback + esc + lnum + lseason 
              + (1 | system/year) , data=milk, control=lmerControl(optimizer="nloptwrap"))
  fit_dfw <- lmer(lbid ~ inc + type_dum + lfmo + lestqty + lnostop + lback + esc + lnum + lseason 
                  + (1  | system/year) , data=milk_dfw, control=lmerControl(optimizer="nloptwrap"))
  fit_sa <- lmer(lbid ~ inc + type_dum + lfmo + lestqty + lnostop + lback + esc + lnum + lseason 
                 + (1  | system/year) , data=milk_sa, control=lmerControl(optimizer="nloptwrap"))
  fit_misc <- lmer(lbid ~ inc + type_dum + lfmo + lestqty + lnostop + lback + esc + lnum + lseason 
                   + (1 | system/year) , data=milk_misc, control=lmerControl(optimizer="nloptwrap"))
  #write to latex
  fname<-paste(dir,fname,sep="")
  output <- capture.output(stargazer(fit, fit_dfw, fit_sa, fit_misc, title=label, align=TRUE, type = "latex", out=fname,no.space=TRUE))
  
  return(c(fit,fit_dfw,fit_sa,fit_misc)) 
}


table6season2<-function(milk,dir,label,fname="table6season2.tex"){
  #4 regressions side by side with pooled, SA, DFW, and misc
  #set up data
  milk_sa <-milk[which(milk$fmozone==9 & milk$year <=1991), ]
  milk_dfw<-milk[which(milk$fmozone==1 & milk$year <=1991), ]
  #fit models
 
  fit_dfw <- lmer(lbid ~ inc + type_dum + lfmo + lestqty + lnostop + lback + esc + lnum + lseason 
                  + (1  | system/year) , data=milk_dfw, control=lmerControl(optimizer="nloptwrap"))
  fit_sa <- lmer(lbid ~ inc + type_dum + lfmo + lestqty + lnostop + lback + esc + lnum + lseason 
                 + (1  | system/year) , data=milk_sa, control=lmerControl(optimizer="nloptwrap"))
  fit_dfw2 <- lmer(lbid ~ inc + type_dum + lfmo + lestqty + lnostop + lback + esc + lnum + lseason + lseason*lestqty
                  + (1  | system/year) , data=milk_dfw, control=lmerControl(optimizer="nloptwrap"))
  fit_sa2 <- lmer(lbid ~ inc + type_dum + lfmo + lestqty + lnostop + lback + esc + lnum + lseason + lseason*lestqty
                 + (1  | system/year) , data=milk_sa, control=lmerControl(optimizer="nloptwrap"))
  #write to latex
  fname<-paste(dir,fname,sep="")
  output <- capture.output(stargazer(fit_dfw,fit_dfw2, fit_sa, fit_sa2, title=label, align=TRUE, type = "latex", out=fname,no.space=TRUE))
  
  return(fit_dfw) 
}


table6<-function(milk,dir,label,fname="table6.tex"){
  #4 regressions side by side with pooled, SA, DFW, and misc
  #set up data
  milk_sa <-milk[which(milk$fmozone==9 & milk$year <=1991), ]
  milk_dfw<-milk[which(milk$fmozone==1 & milk$year <=1991), ]
  milk_misc <- milk[which(milk$fmozone!=1 & milk$fmozone!=9 & milk$year <=1991), ]
  #fit models
  fit <- lmer(lbid ~ inc + type_dum + lfmo + lestqty + lnostop + lback + esc + lnum  
              + (1 | system/year) , data=milk, control=lmerControl(optimizer="nloptwrap"))
  fit_dfw <- lmer(lbid ~ inc + type_dum + lfmo + lestqty + lnostop + lback + esc + lnum  
                  + (1  | system/year) , data=milk_dfw, control=lmerControl(optimizer="nloptwrap"))
  fit_sa <- lmer(lbid ~ inc + type_dum + lfmo + lestqty + lnostop + lback + esc + lnum 
                 + (1 | system/year) , data=milk_sa, control=lmerControl(optimizer="nloptwrap"))
  fit_misc <- lmer(lbid ~ inc + type_dum + lfmo + lestqty + lnostop + lback + esc + lnum
                   + (1 | system/year) , data=milk_misc, control=lmerControl(optimizer="nloptwrap"))
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