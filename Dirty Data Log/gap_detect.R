gap.finding <- function(raw_dat, gap_time){
  #finds the index of where all the gaps end
  
  my_dat <- read.csv(raw_dat)   #read csv of one site, one variable
  #new dataframe of dates and values
  df <- data.frame(date = as.POSIXct(my_dat$dateTimeUTC, tz='', 
                                     format = "%Y-%m-%d %H:%M:%S"), value = my_dat$value)   
  #new "gap" column with time intervals
  df$gap <- c(NA, with(df, date[-1] - date[-nrow(df)]))
  #what the gap should be
  gap_threshold <- gap_time 
  #see if gap is larger than threshold
  df$over_thresh <- df$gap > gap_threshold
  #list of TRUE or FALSE for if gap>threshold
  gaps <- df$over_thresh == TRUE
  #list "where_gaps" of indices of end of gap
  where_gaps = which(gaps)
  where_gaps
}

