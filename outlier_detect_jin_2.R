library(magrittr)  # to use piping %>%
library(ggplot2)   # for ploting
library(MASS)      # to calculate the pseudo-inverse of a matrix
library(caret)     # to center our data by subtracting its mean
library(reshape2)  # for data manipulation
library(plyr)
library(zoo)

#function to remove duplicate data
remove_dupe <- function(raw_dat){
  is_dupe = duplicated(raw_dat$dateTimeUTC) |
    duplicated(raw_dat$dateTimeUTC, fromLast=TRUE)
  dupes = raw_dat[is_dupe,]
  dupe_key = factor(paste(dupes$dateTimeUTC, dupes$value))
  keepers = data.frame()
  for(k in levels(dupe_key)){
    dupe_group_inds = which(dupe_key == k)
    dupe_group = dupes$flagID[dupe_group_inds]
    keep = dupe_group_inds[dupe_group == 'Bad Data'][1]
    if(is.na(keep)) keep = dupe_group_inds[1]
    keepers = rbind(keepers, dupes[keep,])
  }
  raw_dat = filter(raw_dat, ! is_dupe) %>%
    bind_rows(keepers) %>%
    arrange(dateTimeUTC)
  raw_dat
}

#function to fill missing time stamps with NA
fill_time <- function(raw_dat){
  time_interval = as.numeric(difftime(raw_dat$dateTimeUTC[2],
                                      raw_dat$dateTimeUTC[1]))
  full_dat = seq.POSIXt(raw_dat$dateTimeUTC[1],
                        raw_dat$dateTimeUTC[nrow(raw_dat)], by=paste(time_interval, 'min'))
  filled = full_join(data.frame(dateTimeUTC=full_dat), raw_dat)
  filled
}

#remove rows with NA for any variables
remove_na <- function(raw_dat){
  raw_dat[complete.cases(raw_dat),]
}

#my data (DO and Discharge)
my_DO <- read.csv("outlier_detect_test_DO.csv")
my_disch <- read.csv("outlier_detect_test_disch.csv")
my_temp <- read.csv("outlier_detect_test_temp.csv")
my_DO$dateTimeUTC <- as.POSIXct(my_DO$dateTimeUTC, tz='UTC')
my_disch$dateTimeUTC <- as.POSIXct(my_disch$dateTimeUTC, tz='UTC')
my_temp$dateTimeUTC <- as.POSIXct(my_temp$dateTimeUTC, tz='UTC')
#remove duplicates then fill with NA
DO <- fill_na(remove_dupe(my_DO))
disch <- fill_time(remove_dupe(my_disch))
temp <- fill_time(remove_dupe(my_temp))
corr_dat <- data.frame(Temp = temp$value, 
                       DO = DO$value)
X <- corr_dat[complete.cases(corr_dat),]

X%>%ggplot(aes(x=`disch`,y=`DO`))+
  geom_point(color='blue')
