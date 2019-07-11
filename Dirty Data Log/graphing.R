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

clean <- read.csv("Month_metab.csv")

df <- data.frame(
  date = as.Date(clean$solar_date),
  GPP = clean$GPP,
  GPP_upper = clean$GPP_upper,
  GPP_lower = clean$GPP_lower,
  ER = clean$ER,
  ER_upper = clean$ER_upper,
  ER_lower = clean$ER_lower
)
ggplot(data=df, aes(x=date)) +
  geom_line(aes(y=GPP, group = 1, colour="GPP"))+
  geom_line(aes(y=ER,  group = 1, colour = "ER"))+
  geom_ribbon(aes(ymin=df$GPP_lower, ymax=df$GPP_upper, group=1, fill="GPP 95% Confidence"), fill = "blue", alpha=0.25)+
  geom_ribbon(aes(ymin=df$ER_lower, ymax=df$ER_upper, group=1, fill="ER 95% Confidence"), fill = "red", alpha=0.25)+
  scale_colour_manual(name="Oxygen Variables Observed", values=c("ER"="red","GPP"="blue"))+
  scale_fill_manual(name='Oxygen Variables Observed',values=c("GPP 95% Confidence"="blue", "ER 95% Confidence"="red"))+
  scale_x_date(limits = as.Date(c("2017-03-07","2017-04-07"))) +
  xlab("Date")+
  ylab("Oxygen")+
  theme(
    plot.title = element_text( size=17, face="bold"),
    axis.title.x = element_text(size=14, face="bold"),
    axis.title.y = element_text(size=14, face="bold")
  )


