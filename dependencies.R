#Refresh Working Environment
rm(list=ls())

#install dependencies for the project
update.packages(checkBuilt = TRUE)
install.packages("stargazer")
install.packages("IDPmisc")
install.packages("lme4")
install.packages("nloptr")

#to install car need libcurl through: sudo apt-get install libcurl4-openssl-dev
update.packages()
install.packages("car",dependencies=TRUE)
