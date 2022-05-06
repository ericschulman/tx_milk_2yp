#Dependencies ---------------------------

rm(list=ls())
source("~/Documents/tx_milk/models.R")


table5a<-function(milk,dir,label,fname="table5a.tex"){
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


table5b<-function(milk,dir,label,fname="table5b.tex"){
  #fix data
  milk <- milk[which(milk$year <=1991), ]
  #add not-incumbent column
  milk$ninc = (1-milk$inc)
  #fit model

  fit <- lmer(lbid ~ 1 + type_dum+ lfmo + lqstop + lback + esc +  lnum + 
                 (1 | inc/system/year),
               control=lmerControl(optimizer="nloptwrap"), data=milk)
  #write to latex
  fname<-paste(dir,fname,sep="")
  output <- capture.output(stargazer(fit, title=label, align=TRUE, type = "latex", out=fname, no.space=TRUE))
  return(fit)
}



#import data and set up correct ---------------------------

#set up vanilla data
input_dir <- "~/Documents/tx_milk/input/clean_milk.csv"
milk <- load_milk(input_dir)

out_dir<-"~/Documents/tx_milk/output/writeup/"

milk_dfw<-milk[which(milk$fmozone==1 & milk$year <=1991), ]

fita<-table5a(milk_dfw,out_dir,"Reproduced Table 5 Results (Dallas Ft. Worth 1980-1991)")
fitb<-table5b(milk_dfw,out_dir,"Reproduced Table 5 Results (Dallas Ft. Worth 1980-1991)")

print(coef(fitb)$inc)
print(coef(summary(fita)))

