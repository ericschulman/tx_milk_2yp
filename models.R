#Refresh Working Environment ---------------------------
rm(list=ls())


#Import statements ---------------------------

library(stargazer)
library(IDPmisc)
library(lme4)
library(nloptr)
library(car)


#Refresh Working Environment  ---------------------------

rm(list=ls())


#Functions for loading milk info ---------------------------

load_milk<-function(dir,clean=TRUE){
  milk <- data.frame(read.csv(dir))
  #only include correct processors
  milk <- milk[which(milk$vendor=="BORDEN" | milk$vendor=="CABELL" 
                     | milk$vendor=="FOREMOST" | milk$vendor=="OAK FARMS"
                     | milk$vendor=="PRESTON" | milk$vendor=="SCHEPPS"
                     | milk$vendor=="VANDERVOORT"),]
  #drop variables with bad dates (i.e.)
  milk <- milk[which( (milk$biddate - milk$year*10000) !=0 ),]
  #fix bid dates
  milk$biddate<-as.Date(as.character(milk$biddate),"%Y%m%d")
  #focus on correct bid dates
  milk <- milk[which(milk$year>=1980 & milk$year <=1992),]
  #Drop inf, na, and nan
  if(clean){
    milk<-NaRV.omit(milk)
  }
  if("type" %in% colnames(milk)){
    #setting up type dummies correctly
    milk$type_dum <- factor(milk$type)
    milk$type_dum <- relevel(milk$type_dum, ref = "ww")
  }
  return(milk)
}


lag_wins<-function(milk){
  #create lag
  milk_m <- milk
  milk_m$year <- milk_m$year + 1
  if("type" %in% colnames(milk)){
    milk_m <- merge(milk, milk_m,
                    by.x=c("system","vendor","county","type","esc","fmozone","year"),
                    by.y=c("system","vendor","county","type","esc","fmozone","year"),
                    suffixes=c("",".prev"), all.x =TRUE)
                    milk_m<- milk_m[order(milk_m[,'X'],-milk_m[,'lbid']),]
  } else{
    milk_m <- merge(milk, milk_m,
                    by.x=c("system","vendor","county","esc","fmozone","year","cooler"),
                    by.y=c("system","vendor","county","esc","fmozone","year","cooler"),
                    suffixes=c("",".prev"), all.x =TRUE)
                    milk_m<- milk_m[order(milk_m$X,-milk_m$llevel),]
  }
  #remove 'duplicate' bids
  milk_m <-milk_m[!duplicated(milk_m$X),]
  milk_m$win.prev[is.null(milk_m$win.prev)] <- 0
  milk_m$win.prev[is.na(milk_m$win.prev)] <- 0
  
  return(milk_m)
}


filter_data<-function(milk){
  ids <- data.frame(read.csv("~/Documents/tx_milk/input/ids/complete_isd.csv"))
  milk_f <- merge(milk, ids,
                  by.x=c("system","county"),
                  by.y=c("SYSTEM","COUNTY"))
  return(milk_f)
}


setup_level<-function(milk){
  #removing NAs so I can add
  milk$WW[is.na(milk$WW)] <- 0
  milk$WC[is.na(milk$WC)] <- 0
  milk$LFW[is.na(milk$LFW)] <- 0
  milk$LFC[is.na(milk$LFC)] <- 0

  milk$QWC[is.na(milk$QWC)] <- 0
  print(milk[is.na(milk$QWC)])
  milk$QWW[is.na(milk$QWW)] <- 0
  milk$QLFW[is.na(milk$QLFW)] <- 0
  milk$QLFC[is.na(milk$QLFC)] <- 0
  
  milk$LEVEL<- (milk$WW*milk$QWW + milk$WC*milk$QWC+ milk$LFW*milk$QLFW + milk$LFC*milk$QLFC)/(milk$QWW + milk$QWC + milk$QLFW + milk$QLFC)
  
  milk$LEVEL[(milk$LEVEL>2.0)] <- NA
  milk$LEVEL[(milk$LEVEL==0.0)] <- NA
  return(milk$LEVEL)
}


#Tables from Sibley McClave Hewitt 1995 ---------------------------

table5<-function(milk,dir,label,fname="table5.tex"){
  #fix data
  milk <- milk[which(milk$year <=1991), ]
  #add not-incumbent column
  milk$ninc = (1-milk$inc)
  #fit model
  fit <- lmer(lbid ~ inc + 
                type_dum*inc + lfmo*inc + lqstop*inc + lback*inc + esc*inc +  lnum*inc + 
                type_dum*(1-inc) + lfmo*(1-inc) + lqstop*(1-inc) + lback*(1-inc) + esc*(1-inc) + lnum*(1-inc) +
                (1 | system/year) ,
              control=lmerControl(optimizer="nloptwrap"), data=milk)
  #write to latex
  fname<-paste(dir,fname,sep="")
  output <- capture.output(stargazer(fit, title=label, align=TRUE, type = "latex", out=fname, no.space=TRUE))
  return(fit)
}


table6<-function(milk,dir,label,fname="table6.tex"){
  #fix data
  milk <- milk[which(milk$year <=1991), ]
  #fit model
  fit <- lmer(lbid ~ inc + type_dum + lfmo + lestqty + lnostop + lback + esc + lnum
              + (1 | system/year) , data=milk, control=lmerControl(optimizer="nloptwrap"))
  #write to latex
  fname<-paste(dir,fname,sep="")
  output <- capture.output(stargazer(fit, title=label, align=TRUE, type = "latex", out=fname,no.space=TRUE))
  return(fit) 
}


table10<-function(milk,dir,label,fname="table10.tex"){
  #create a lagged wins, to reproduce table 10 from the original working paper
  milk_m<-lag_wins(milk)
  fit <- lmer(lbid ~ win.prev  + type_dum + lfmo + lqstop
              + (1 | system/year) , control=lmerControl(optimizer="nloptwrap"), data=milk_m)
  
  #write to latex
  fname<-paste(dir,fname,sep="")
  output <- capture.output(stargazer(fit, title=label, align=TRUE, type = "latex", out=fname, no.space=TRUE))
  return(fit)
}


#Fu 2011 ---------------------------

fu<-function(milk,dir,label,fname='fu.tex'){
  #trying to replicate fu's results from 2011 - only DFW
  milk<-milk[which( (milk$fmozone==1 | milk$fmozone==9) & milk$year >=1986  & milk$year <=1992), ]
  fit_fe <- lmer(llevel ~  lestqty + lseason + lnum + win.prev + ldist + lnostop + lback + lfmo + esc + cooler
                 + (1 | system/year) , data=milk, control=lmerControl(optimizer="nloptwrap"))
  fit_fe2 <- lmer(llevel ~ lestqty + lseason + lnum + win.prev + ldist + lnostop + lback + lfmo + esc + cooler
                  + (1 | system/year/vendor) , data=milk, control=lmerControl(optimizer="nloptwrap"))
  fname<-paste(dir,fname,sep="")
  output <- capture.output(stargazer(fit_fe, fit_fe2, title=label, align=TRUE, type = "latex", out=fname,no.space=TRUE))
  return(fit_fe)
}


#Lee 1995 ---------------------------

lee<-function(milk,dir,label,fname='lee.tex'){
  #trying to replicate lee's results from 1999 - only DFW
  milk<-milk[which( (milk$fmozone==1 | milk$fmozone==9) & milk$year <=1992), ]
  milk$lbacksq <- milk$lback*milk$lback
  fit <- lmer(lbid ~ win.prev + begin + end + entry + onebid + type_dum + lfmo + lqstop + lback + lbacksq + esc
                 + (1 | system/year) , data=milk, control=lmerControl(optimizer="nloptwrap"))
  fname<-paste(dir,fname,sep="")
  output <- capture.output(stargazer(fit , title=label, align=TRUE, type = "latex", out=fname,no.space=TRUE))
  return(fit)
}


#Table 6 extensions ---------------------------

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


table6all<-function(milk,dir,label,fname="table6all.tex"){
  #4 regressions side by side with pooled, SA, DFW, and misc
  #set up data
  milk <- milk[which(milk$year <=1991), ]
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


table6sa<-function(milk,dir,label,fname="table6sa.tex"){
  #special model with entry interactions in 1985
  milk$entry <- as.integer(milk$year >= 1985)
  
  #split talbes
  milk_before<-milk[which(milk$fmozone==9 & milk$year >= 1980 & milk$year <=1984), ]
  milk_after<-milk[which(milk$fmozone==9 & milk$year >= 1985 & milk$year <=1991), ]
  
  #fit model
  fit <- lmer(lbid ~ inc*entry + type_dum*entry + lfmo*entry + lestqty*entry + 
                lnostop*entry + lback*entry + esc*entry + lnum*entry +
                inc*(1-entry) + type_dum*(1-entry) + lfmo*(1-entry) + lestqty*(1-entry) +
                lnostop*(1-entry) + lback*(1-entry) + esc*(1-entry) + lnum*(1-entry) 
              + (1 + lfmo | system/year) , data=milk, control=lmerControl(optimizer="nloptwrap"))

  #fit 2 more models
  fit_before <- lmer(lbid ~ inc + type_dum + lfmo + lestqty + lnostop + lback + esc + lnum  
              + (1 | system/year) , data=milk_before, control=lmerControl(optimizer="nloptwrap"))
  fit_after <- lmer(lbid ~ inc + type_dum + lfmo + lestqty + lnostop + lback + esc + lnum  
              + (1 | system/year) , data=milk_after, control=lmerControl(optimizer="nloptwrap"))
  
  #write to latex
  fname<-paste(dir,fname,sep="")
  fname2<-paste(dir,'table6sa2.tex',sep="")
  output <- capture.output(stargazer(fit, title=label, align=TRUE, type = "latex", out=fname,no.space=TRUE))
  output <- capture.output(stargazer(fit_before,fit_after, title=label, align=TRUE, type = "latex", out=fname2,no.space=TRUE))
  return(fit_after)
}


#Table 6 more extensions (not relevant) ---------------------------

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





#Function to set up alternative version of SEASON ---------------------------

#use at own risk
time_variables<-function(milk){
  #set up seasonal information by finding out information on the first and last let dates
  min_year <-  milk[order(milk$YEAR),]$YEAR[1]
  max_year <- milk[order(-milk$YEAR),]$YEAR[1]
  years <- min_year:max_year
  season_info <- data.frame( YEAR=numeric(),
                             STARTDAY=as.Date(character()),
                             ENDDAY = as.Date(character()),
                             DIFF= numeric())
  for (year in years){  
    milk_f<- milk[ which(milk$YEAR==year & (milk$MONTH!= 0 & milk$DAY != 0) ),]
    start_col<- milk_f[order(milk_f$YEAR,milk_f$MONTH,milk_f$DAY),]
    start <- as.Date(as.character(start_col$YEAR*10000 + start_col$MONTH*100 +start_col$DAY),"%Y%m%d")
    start<-start[1]
    end_col<- milk_f[order(-milk_f$YEAR,-milk_f$MONTH,-milk_f$DAY),]
    end <- as.Date(as.character(end_col$YEAR*10000 + end_col$MONTH*100 +end_col$DAY),"%Y%m%d")
    end<- end[1]
    diff <- as.numeric(difftime(end, start), units="days")
    new  <- data.frame( YEAR=year,
                        STARTDAY=start,
                        ENDDAY = end,
                        DIFF= diff)
    season_info <- rbind(season_info, new)
  }
  #add season to columns
  milk<- merge(milk, season_info,
               by.x=c("YEAR"),
               by.y=c("YEAR"),
               suffixes=c("",".season"))
  milk$biddate<- as.Date(as.character(milk$YEAR*10000 + milk$MONTH*100 +milk$DAY),"%Y%m%d")
  #time based definitions for variables
  milk$PASSEDT <- as.numeric(difftime( milk$biddate, milk$STARTDAY ), units="days")
  milk$BEGINT<- as.integer( ( 1.0*milk$PASSEDT)/milk$DIFF <= .5 )
  milk$ENDT<- as.integer( ( 1.0*milk$PASSEDT)/milk$DIFF >= .95 )
  milk$BACKLOGT <- (1.0*milk$COMMITMENTS/milk$CAPACITY) - ( 1.0*milk$PASSEDT)/milk$DIFF
  milk$SEASONT <-  ( 1.0*milk$PASSEDT)/milk$DIFF
  return(milk)
}


#Test code ----------------
input_dir <- "~/Documents/tx_milk/input/clean_milk.csv"
milk <- load_milk(input_dir)
