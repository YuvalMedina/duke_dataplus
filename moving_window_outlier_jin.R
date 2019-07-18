library(zoo)

z <- zoo(11:15, as.Date(31:35))
rollapply(z, 2, mean)

## non-overlapping means
z2 <- zoo(rnorm(6))
rollapply(z2, 3, mean, by = 3)      # means of nonoverlapping groups of 3
aggregate(z2, c(3,3,3,6,6,6), mean) # same

## optimized vs. customized versions
rollapply(z2, 3, mean)   # uses rollmean which is optimized for mean
rollmean(z2, 3)          # same
rollapply(z2, 3, (mean)) # does not use rollmean

DF <- data.frame(a = 1:10, b = 21:30, c = letters[1:10])
replace(DF, 1:2, rollapply(DF[1:2], 3, sum, fill = NA))



library(dplyr)
library(ggplot2)
library(ks)
library(sp)
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



#function to properly format df input for cor_coeff functions
prep_corr_dat <- function(var1_df, var2_df){
  var1_df$dateTimeUTC <- as.POSIXct(var1_df$dateTimeUTC, tz='UTC')
  var2_df$dateTimeUTC <- as.POSIXct(var2_df$dateTimeUTC, tz='UTC')
  #remove duplicates then fill with NA
  var1 <- fill_time(remove_dupe(var1_df))
  var2 <- fill_time(remove_dupe(var2_df))
  corr_dat <- merge(var1,var2,by="dateTimeUTC")
  corr_dat <- data.frame(date=corr_dat$dateTimeUTC,
                         var1 = corr_dat$value.x,
                         var2 = corr_dat$value.y)
  #remove rows with NA
  corr_dat <- corr_dat[complete.cases(corr_dat),]
  return(corr_dat)
}

cor_coef_singleCluster <- function(corr_dat, var1, var2){
  #corr_dat <- dataframe with date, var1, var2 columns
  #returns list of timestamps for outliers
  #remove rows with NA
  corr_dat <- corr_dat[complete.cases(corr_dat),]
  #new df with no dates
  corr_dat_noDate <- data.frame(var1 = corr_dat$var1, 
                                var2 = corr_dat$var2)
  corr_mat <- data.matrix(corr_dat_noDate)
  #get KDE
  fhat <- kde(x=corr_mat)
  #points making 95% contour line
  contour.5 <- with(fhat,contourLines(x=eval.points[[1]],y=eval.points[[2]],
                                      z=estimate,levels=cont["5%"])[[1]])
  contour.5 <- contour.5[-1]
  #finding points outside of 95 line (have value 0)
  in_95 <- point.in.polygon(point.x=corr_dat$var1, point.y=corr_dat$var2, 
                            pol.x=contour.5[[1]], pol.y=contour.5[[2]], 
                            mode.checked = TRUE)
  corr_dat$outlier_check <- in_95 == 0
  #go back to dataframe to obtain df of only outliers
  out_index <- which(corr_dat$outlier_check)
  outliers <- ldply(out_index, function(x) corr_dat[x,])
  return(outliers$date)
}

cor_coef_multCluster <- function(corr_dat){
  #corr_dat <- dataframe with var1, var2 columns aligned by date
  #returns list timestamps for outliers
  corr_dat <- corr_dat[complete.cases(corr_dat),]
  #new df with no dates
  corr_dat_noDate <- data.frame(var1 = corr_dat$var1, 
                                var2 = corr_dat$var2)
  corr_mat <- data.matrix(corr_dat_noDate)
  #get KDE
  fhat <- kde(x=corr_mat)
  plot(fhat, cont = seq(5, 95, by = 10))
  contour.5 <- contourLines(x=fhat$eval.points[[1]],y=fhat$eval.points[[2]],
                            z=fhat$estimate,levels=fhat$cont["5%"])
  points(fhat$x)
  contour_poly <- list(list())
  in_95 <- list(list())
  for(i in seq(1, length(contour.5))){
    contour_poly[[i]]<- contour.5[[i]]
    points(contour.5[[i]])
    in_95[[i]] <- point.in.polygon(point.x=corr_dat$var1, point.y=corr_dat$var2, 
                                   pol.x=contour.5[[i]]$x, pol.y=contour.5[[i]]$y, 
                                   mode.checked = TRUE)
  }
  #finding points outside of 95 line (have value 0)
  corr_dat$outlier_check <- TRUE
  for(i in seq(1, length(in_95))){
    corr_dat$outlier_check <- (in_95[[i]] == 0 & corr_dat$outlier_check)
  }
  #go back to dataframe to obtain df of only outliers
  out_index <- which(corr_dat$outlier_check)
  outliers <- ldply(out_index, function(x) corr_dat[x,])
  #outlier_count <- data.frame(dateTimeUTC=outliers$date,
  #                            count=1)
  return(outliers)
  #times<-outliers$date[corr_dat$outlier_check]
  #return(times)
}

rollapply(corr_dat, 47030, by.column=FALSE, FUN=function(x){
  new <- data.frame(date=as.POSIXct(x[,1], tz='UTC'),
                    var1=as.numeric(x[,2]),
                    var2=as.numeric(x[,3]))
  outliers = cor_coef_multCluster(new)
  return(outliers)
})

cor_coef_multCluster_sliding <- function(short_list){
  #corr_dat <- dataframe with var1, var2 columns aligned by date
  #returns list timestamps for outliers
  corr_dat <- short_list
  print(str(corr_dat))
  corr_dat_noDate <- data.frame(var1 = corr_dat$var1, 
                                var2 = corr_dat$var2)
  corr_mat <- data.matrix(corr_dat_noDate)
  #get KDE
  fhat <- kde(x=corr_mat)
  contour.5 <- contourLines(x=fhat$eval.points[[1]],y=fhat$eval.points[[2]],
                            z=fhat$estimate,levels=fhat$cont["1%"])
  contour_poly <- list(list())
  in_95 <- list(list())
  for(i in seq(1, length(contour.5))){
    contour_poly[[i]]<- contour.5[[i]]
    in_95[[i]] <- point.in.polygon(point.x=corr_dat$var1, point.y=corr_dat$var2, 
                                   pol.x=contour.5[[i]]$x, pol.y=contour.5[[i]]$y, 
                                   mode.checked = TRUE)
  }
  #finding points outside of 95 line (have value 0)
  corr_dat$outlier_check <- TRUE
  for(i in seq(1, length(in_95))){
    corr_dat$outlier_check <- (in_95[[i]] == 0 & corr_dat$outlier_check)
  }
  #go back to dataframe to obtain df of only outliers
  out_index <- which(corr_dat$outlier_check)
  outliers <- ldply(out_index, function(x) corr_dat[x,])
  #outlier_count <- data.frame(dateTimeUTC=outliers$date,
  #                            count=1)
  return(outliers$date)
  #times<-outliers$date[corr_dat$outlier_check]
  #return(as.POSIXct(times, tx='UTC'))
  
}

#make some data to break up and apply functions
nc_DO <- read.csv("outlier_detect_test_DO.csv")
nc_temp <- read.csv("outlier_detect_test_temp.csv")
nc_DO$dateTimeUTC <- as.POSIXct(nc_DO$dateTimeUTC, tz='UTC')
nc_temp$dateTimeUTC <- as.POSIXct(nc_temp$dateTimeUTC, tz='UTC')
corr_dat <- prep_corr_dat(nc_DO, nc_temp)

#split the dataframe into a list of smaller frames
n_full_windows = 20
points_per_window = length(corr_dat_noDate[,1]) / n_full_windows
split_factor = rep(1:n_full_windows, each=points_per_window)
ex_list = split(corr_dat, split_factor)

#apply your function to each list element (you'll have to manually deal
#with fractional windows)
final <- NULL
final <- lapply(ex_list, FUN = cor_coef_multCluster_sliding)
final_one <- do.call("c", final)
outlier_date <- final_one[complete.cases(final_one)]
freq <- as.data.frame(table(outlier_date))
freq <- data.frame(date=as.POSIXct(freq$outlier_date, format='%Y-%m-%d %H:%M:%S'),
                   out_freq = freq$Freq)
outlier_df <- merge(corr_dat, freq, by="date")

ggplot()+
  geom_point(data=corr_dat, mapping=aes(x=var1, y=var2))+
  geom_point(data = outlier_df, mapping=aes(x=var1, y=var2, colour="outliers"))
ggplot()+
  geom_point(data=nc_DO, mapping=aes(x=dateTimeUTC, y=value))+
  geom_point(data = outlier_df, mapping=aes(x=date, y=var1, colour="outliers"))



corr_dat <- ex_list[['20']]
#remove rows with NA
corr_dat <- corr_dat[complete.cases(corr_dat),]
#new df with no dates
corr_dat_noDate <- data.frame(var1 = corr_dat$var1, 
                              var2 = corr_dat$var2)
corr_mat <- data.matrix(corr_dat_noDate)
#get KDE
fhat <- kde(x=corr_mat)
plot(fhat, cont = seq(5, 95, by = 10))
contour.5 <- contourLines(x=fhat$eval.points[[1]],y=fhat$eval.points[[2]],
                          z=fhat$estimate,levels=fhat$cont["5%"])
contour_poly <- list(list())
in_95 <- list(list())
for(i in seq(1, length(contour.5))){
  contour_poly[[i]]<- contour.5[[i]]
  points(contour.5[[i]])
  in_95[[i]] <- point.in.polygon(point.x=corr_dat$var1, point.y=corr_dat$var2, 
                                 pol.x=contour.5[[i]]$x, pol.y=contour.5[[i]]$y, 
                                 mode.checked = TRUE)
}
#finding points outside of 95 line (have value 0)
corr_dat$outlier_check <- TRUE
for(i in seq(1, length(in_95))){
  corr_dat$outlier_check <- (in_95[[i]] == 0 & corr_dat$outlier_check)
}
#go back to dataframe to obtain df of only outliers
out_index <- which(corr_dat$outlier_check)
outliers <- ldply(out_index, function(x) corr_dat[x,])
outlier_count <- data.frame(dateTimeUTC=outliers$date,
                            count=1)
plot(c(0, 20), c(0,30), type = "n")
points(x=outliers$var1, y=outliers$var2, col="blue")

corr_dat <- ex_list[['2']]
outliers <- cor_coef_multCluster(corr_dat)


points(x=outliers$var1, y=outliers$var2, col="blue")


ggplot()+
  geom_point(data=corr_dat, mapping=aes(x=var1, y=var2))+
  geom_point(data = outliers, mapping=aes(x=var1, y=var2, colour="outliers"))
ggplot()+
  geom_point(data=nc_temp, mapping=aes(x=dateTimeUTC, y=value))+
  geom_point(data = outliers, mapping=aes(x=date, y=var2, colour="outliers"))
