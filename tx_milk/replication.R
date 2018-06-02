milk <- data.frame(read.csv("~/Documents/summer_ra/tx_milk/data/milk_out.csv"))

new_lfc <- data.frame("bid" = log(milk$LFC),
                      "inc" = milk$I,   
                      "lfci" =   milk$I* rep(1,nrow(milk)),
                      "lfwi" =   milk$I* rep(0,nrow(milk)),
                      "wci" =  milk$I * rep(0,nrow(milk)), 
                      "logfmoi" = milk$I * log(milk$FMO),
                      "logqstopi" = milk$I * log(milk$QSTOP),
                      "backi" = milk$I * milk$BACKLOG,
                      "esci" = milk$I * milk$ESC,
                      "numi" = milk$I * milk$N, 
                      "lfcni" =   (1-milk$I) * rep(1,nrow(milk)),
                      "lfwni" =   (1-milk$I) * rep(0,nrow(milk)),
                      "wcni" =  (1-milk$I)  * rep(0,nrow(milk)), 
                      "logfmoni" = (1-milk$I)  * log(milk$FMO),
                      "logqstopni" = (1-milk$I) * log(milk$QSTOP),
                      "backni" = (1-milk$I)  * milk$BACKLOG,
                      "numni" = (1-milk$I) * milk$N,
                      "escni" = (1-milk$I) * milk$ESC)
                       
new_ww <- data.frame("bid" = log(milk$WW),
                     "inc" = milk$I,   
                     "lfci" =   milk$I* rep(0,nrow(milk)),
                     "lfwi" =   milk$I* rep(0,nrow(milk)),
                     "wci" =  milk$I * rep(0,nrow(milk)), 
                     "logfmoi" = milk$I * log(milk$FMO),
                     "logqstopi" = milk$I * log(milk$QSTOP),
                     "backi" = milk$I * milk$BACKLOG,
                     "esci" = milk$I * milk$ESC,
                     "numi" = milk$I * milk$N, 
                     "lfcni" =   (1-milk$I) * rep(0,nrow(milk)),
                     "lfwni" =   (1-milk$I) * rep(0,nrow(milk)),
                     "wcni" =  (1-milk$I)  * rep(0,nrow(milk)), 
                     "logfmoni" = (1-milk$I)  * log(milk$FMO),
                     "logqstopni" = (1-milk$I) * log(milk$QSTOP),
                     "backni" = (1-milk$I)  * milk$BACKLOG,
                     "numni" = (1-milk$I) * milk$N,
                     "escni" = (1-milk$I) * milk$ESC)

new_lfw <- data.frame("bid" = log(milk$LFW),
                      "inc" = milk$I,   
                      "lfci" =   milk$I* rep(0,nrow(milk)),
                      "lfwi" =   milk$I* rep(1,nrow(milk)),
                      "wci" =  milk$I * rep(0,nrow(milk)), 
                      "logfmoi" = milk$I * log(milk$FMO),
                      "logqstopi" = milk$I * log(milk$QSTOP),
                      "backi" = milk$I * milk$BACKLOG,
                      "esci" = milk$I * milk$ESC,
                      "numi" = milk$I * milk$N, 
                      "lfcni" =   (1-milk$I) * rep(0,nrow(milk)),
                      "lfwni" =   (1-milk$I) * rep(1,nrow(milk)),
                      "wcni" =  (1-milk$I)  * rep(0,nrow(milk)), 
                      "logfmoni" = (1-milk$I)  * log(milk$FMO),
                      "logqstopni" =(1-milk$I) * log(milk$QSTOP),
                      "backni" = (1-milk$I)  * milk$BACKLOG,
                      "numni" = (1-milk$I) * milk$N,
                      "escni" = (1-milk$I) * milk$ESC)

new_wc <- data.frame("bid" = log(milk$LFC),
                     "inc" = milk$I,   
                     "lfci" =   milk$I* rep(0,nrow(milk)),
                     "lfwi" =   milk$I* rep(0,nrow(milk)),
                     "wci" =  milk$I * rep(1,nrow(milk)), 
                     "logfmoi" = milk$I * log(milk$FMO),
                     "logqstopi" = milk$I * log(milk$QSTOP),
                     "backi" = milk$I * milk$BACKLOG,
                     "esci" = milk$I * milk$ESC,
                     "numi" = milk$I * milk$N, 
                     "lfcni" =   (1-milk$I) * rep(0,nrow(milk)),
                     "lfwni" =   (1-milk$I) * rep(0,nrow(milk)),
                     "wcni" =  (1-milk$I)  * rep(1,nrow(milk)), 
                     "logfmoni" = (1-milk$I)  * log(milk$FMO),
                     "logqstopni" = (1-milk$I) * log(milk$QSTOP),
                     "backni" = (1-milk$I)  * milk$BACKLOG,
                     "numni" = (1-milk$I) * milk$N,
                     "escni" = (1-milk$I) * milk$ESC)

new_milk <- rbind(new_lfc, new_lfw, new_wc, new_ww)

table5 = lm(bid ~ inc + lfci + lfwi + wci + logfmoi + logqstopi + backi + esci + numi
   + lfcni + lfwni + wcni + logfmoni + logqstopni + backni + escni + numni, new_milk)

summary(table5)

