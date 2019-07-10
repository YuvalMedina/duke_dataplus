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

my_out <- outlier.detect("Outliers_DO.csv")
my_dat <- read.csv("Outliers_DO.csv")
my_dat$dateTimeUTC <- as.POSIXct(my_dat$dateTimeUTC)
my_out$dateTimeUTC <- as.POSIXct(my_out$dateTimeUTC)
ggplot()+
  geom_point(data=my_dat, mapping=aes(x=dateTimeUTC, y=value))+
  geom_point(data = my_out, mapping=aes(x=dateTimeUTC, y=value, colour="outliers"))


#assuming every spike up there is a spike down drop
df <- data.frame(date = as.POSIXct(my_dat$dateTimeUTC, tz='', 
                                   format = "%Y-%m-%d %H:%M:%S"), value = my_dat$value)   
df$diff <- c(NA, with(df, value[-1] - value[-nrow(df)]))
df$over_thresh <- df$diff > 1
df$under_thresh <- df$diff < -1
spike_up <- which(df$over_thresh)
spike_down <- which(df$under_thresh)
for(i in length(spike_up)){
  if(spike_up[i] < spike_down[i]){
    df_out <- df[spike_up[i]:(spike_down[i]-1),]
  }
  else
    df_out <- df[spike_down[i]:(spike_up[i]-1),]
}
ggplot()+
  geom_point(data=my_dat, mapping=aes(x=dateTimeUTC, y=value))+
  geom_point(data = df_out, mapping=aes(x=date, y=value, colour="outliers"))


