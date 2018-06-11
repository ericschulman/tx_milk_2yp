install.packages("bitops")
install.packages("RCurl")
install.packages("sandwich")
install.packages("gdata")
install.packages("IDPmisc")
library(bitops)
library(RCurl)
library(sandwich)
library(gdata)


url_robust <- "https://raw.githubusercontent.com/IsidoreBeautrelet/economictheoryblog/master/robust_summary.R"
eval(parse(text = getURL(url_robust, ssl.verifypeer = FALSE)),
     envir=.GlobalEnv)

new_milk <- rbind(new_lfc, new_lfw, new_wc, new_ww)

lm.object <- lm(bid ~ inc + lfci + lfwi + wci + logfmoi + logqstopi + backi + esci + numi
                + lfcni + lfwni + wcni + logfmoni + logqstopni + backni + escni + numni, new_milk) 

summary(lm.object )

summary(lm.object, cluster=c("vendor","year") )