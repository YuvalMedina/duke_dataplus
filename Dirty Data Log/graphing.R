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



