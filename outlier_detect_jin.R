library(plyr)
library(ggplot2)

outlier.detect <- function(raw_dat){
  
  my_dat <- read.csv(raw_dat)   #read csv of one site, one variable
  #new dataframe of dates and values
  df <- data.frame(date = as.POSIXct(my_dat$dateTimeUTC, tz='', 
                                     format = "%Y-%m-%d %H:%M:%S"), value = my_dat$value)   
  #new "diff" column with consecutive value differences
  df$diff <- c(NA, with(df, abs(value[-1] - value[-nrow(df)])))
  #what the biggest difference should be
  diff_threshold <- 1
  #see if diff is larger than threshold
  df$over_thresh <- df$diff > diff_threshold
  #indices of there difference is over threshold
  where_out = which(df$over_thresh)
  outliers <- ldply(where_out, function(x) my_dat[x,])
  outliers
}

my_out <- outlier.detect("NC_Eno_DO_mgL.csv")
my_dat <- read.csv("NC_Eno_DO_mgL.csv")

ggplot()+
  geom_point(my_dat, mapping=aes(x=dateTimeUTC, y=value, colour="blue"))+
  geom_point(my_out, mapping=aes(x=dateTimeUTC, y=value, colour="red"))


    
