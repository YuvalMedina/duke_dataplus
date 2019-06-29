library(ggplot2)
source("gap_detect.R")

theme_set(theme_minimal())
dat <- read.csv("clean_day.csv")
head(dat)
df <- data.frame(
  date = dat$dateTimeUTC,
  value = dat$value
)

input = "dat"

df <- data.frame(
  date = input$dateTimeUTC,
  value = input$value
)

ss <- subset(df, date < as.Date("2019-02-13"))

plot(df$date, df$value)
lines(lowess(df$date, df$value))

bigDataSet <- read.csv("NC_NHC_DO_mgL.csv")

head(bigDataSet)

ss<-subset(bigDataSet, select="datTimeUTC", start="2019-02-12 00:00:00", end="2019-02-13 00:00:00")


gaps = gap.finding("NC_NHC_DO_mgL.csv", 15)
head(gaps)
my_dirty_dat <- read.csv("NC_NHC_DO_mgL.csv")
my_dirty_df <- data.frame(
  date = my_dirty_dat$dateTimeUTC,
  value = my_dirty_dat$value
)

graph_dat <- my_dirty_df[c(gaps[1]-100:gaps[1]+100)]

for(i in seq(1:length(gaps))){
  graph_dat <- my_dirty_df[gaps[i]-100:gaps[i]+100]
  plot(graph_dat$date, graph_dat$value)
}





storm_DO <- read.csv("storm_DO.csv")
storm_disch <- read.csv("storm_discharge.csv")
head(storm_DO)
head(storm_disch)

df_DO <- data.frame(
  date = storm_DO$dateTimeUTC,
  values = storm_DO$value
)

df_disch <- data.frame(
  date = as.POSIXct(storm_disch$dateTimeUTC, tz='', 
                    format = "%Y-%m-%d %H:%M:%S"),
  values = storm_disch$value
)

plot(df_disch$date, df_disch$value)

library("lubridate")
library("ggplot2")

ggplot() +
  geom_point(df_disch, mapping=aes(x=date, y=values))+
  geom_rect(data = data.frame(xmin = as.POSIXct(c("2017-03-02 00:00:00")),
                              xmax = as.POSIXct(c("2017-03-03 00:00:00")),
                              ymin = 0,
                              ymax = 6),
            aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
            fill = "red", alpha = 0.2) 


gaps_DO <- read.csv("gaps_DO.csv")
storm_disch <- read.csv("storm_discharge.csv")
head(storm_DO)
head(storm_disch)

df_DO <- data.frame(
  date = storm_DO$dateTimeUTC,
  values = storm_DO$value
)
  
