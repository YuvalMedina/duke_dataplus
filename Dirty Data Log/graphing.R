library(ggplot2)
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
