library(plyr)
library(ggplot2)
library(ks)

outlier.detect <- function(raw_dat){
  
  my_dat <- read.csv(raw_dat)   #read csv of one site, one variable
  #new dataframe of dates and values
  df <- data.frame(date = as.POSIXct(my_dat$dateTimeUTC, tz='', 
                                     format = "%Y-%m-%d %H:%M:%S"), value = my_dat$value)   
  #new "diff" column with consecutive value differences
  df$diff <- c(NA, with(df, abs(value[-1] - value[-nrow(df)])))
  #what the biggest difference should be
  diff_threshold <- 0.7
  #see if diff is larger than threshold
  df$over_thresh <- df$diff > diff_threshold
  #indices of there difference is over threshold
  where_out = which(df$over_thresh)
  outliers <- ldply(where_out, function(x) my_dat[x,])
  outliers
}

my_out <- outlier.detect("outlier_detect_test_dat.csv")
my_dat <- read.csv("outlier_detect_test_dat.csv")
my_dat$dateTimeUTC <- as.POSIXct(my_dat$dateTimeUTC, format="%Y-%m-%d %H:%M:%S")
my_out$dateTimeUTC <- as.POSIXct(my_out$dateTimeUTC, format="%Y-%m-%d %H:%M:%S")
ggplot()+
  geom_point(data=my_dat, mapping=aes(x=dateTimeUTC, y=value))+
  geom_point(data = my_out, mapping=aes(x=dateTimeUTC, y=value, colour="outliers"))


#assuming every spike up there is a spike down drop
df <- data.frame(date = as.POSIXct(my_dat$dateTimeUTC, tz='', 
                                   format = "%Y-%m-%d %H:%M:%S"), value = my_dat$value)   
df$diff <- c(NA, with(df, value[-1] - value[-nrow(df)]))
df$over_thresh <- df$diff > 0.4
df$under_thresh <- df$diff < -0.4
spike_up <- which(df$over_thresh)
spike_down <- which(df$under_thresh)
spike_down <- spike_down[- 1]
spike_up <- spike_up[- (length(spike_up))]
for(i in length(spike_up)){
  if(spike_up[i] < spike_down[i]){
    df_out <- df[spike_up[i]:(spike_down[i]),]
  }
  else
    df_out <- df[spike_down[i]:(spike_up[i]),]
}
ggplot()+
  geom_point(data=my_dat, mapping=aes(x=dateTimeUTC, y=value))+
  geom_point(data = df_out, mapping=aes(x=date, y=value, colour="outliers"))



cor_coef <- function(raw_dat){
  
}

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

#function to fill missing data with NA
fill_na <- function(raw_dat){
  time_interval = as.numeric(difftime(raw_dat$dateTimeUTC[2],
                                      raw_dat$dateTimeUTC[1]))
  full_dat = seq.POSIXt(raw_dat$dateTimeUTC[1],
                       raw_dat$dateTimeUTC[nrow(raw_dat)], by=paste(time_interval, 'min'))
  filled = full_join(data.frame(dateTimeUTC=full_dat), raw_dat)
  filled
}

#my data (DO and Discharge)
my_DO <- read.csv("outlier_detect_test_DO.csv")
my_disch <- read.csv("outlier_detect_test_disch.csv")
my_DO$dateTimeUTC <- as.POSIXct(my_DO$dateTimeUTC, tz='UTC')
my_disch$dateTimeUTC <- as.POSIXct(my_disch$dateTimeUTC, tz='UTC')
#remove duplicates then fill with NA
DO <- fill_na(remove_dupe(my_DO))
disch <- fill_na(remove_dupe(my_disch))

corr_dat <- data.frame(disch = disch$value, 
                       DO = DO$value)
corr_mat <- data.matrix(corr_dat)
fhat <- kde(x=corr_mat)
plot(fhat)                  

