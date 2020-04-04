
# https://en.wikipedia.org/wiki/2019%E2%80%9320_coronavirus_outbreak
# https://medium.com/analytics-vidhya/covid19-transmission-forecast-in-italy-a-python-tutorial-for-sri-model-8c103c0a95b9
# http://uop.whoi.edu/UOPinstruments/frodo/aer/leap-julian-day-table.html

source('johnhopkins.R')
source('semilog.R')

raw        <- hopkins_raw()

us_data    <- hopkins("US", province.excludes="Princess", raw=raw)
china_data <- hopkins("Mainland China",          raw=raw)
italy_data <- hopkins("Italy",                   raw=raw)

# Come on JH, keep naming consistent at least!
sk_data    <- hopkins(c("Korea, South", "South Korea", "Republic of Korea"), raw=raw)


#df <- us_data[38:length(us_data$doy),]
#df <- us_data[38:69,]

# First Exponential Phase
df <- us_data[us_data$date >= as.Date("02-27-2020", "%m-%d-%Y") &
              us_data$date <= as.Date("03-27-2020","%m-%d-%Y"),]
us_model <- lm(log(cases) ~ date, df)

p_rng <- seq(as.Date("02-27-2020", "%m-%d-%Y"), as.Date("03-27-2020", "%m-%d-%Y"), "days")
us_pred <- exp(predict(us_model, data.frame(date=p_rng), interval=c("prediction")))

# Second Exponential Phase
df <- us_data[us_data$date >=as.Date("03-28-2020", "%m-%d-%Y"),]
us_model2 <- lm(log(cases) ~ date, df)
p_rng2 <- seq(as.Date("04-01-2020", "%m-%d-%Y"), as.Date("04-30-2020", "%m-%d-%Y"), "days")
us_pred2 <- exp(predict(us_model2, data.frame(date=p_rng2), interval=c("prediction")))

png("us.png")

semilog(
  us_data, 
  main="Non-repatriated US COVID-19 Cases",
  xlim=c(as.Date("2020-01-22"),as.Date("2020-04-10")),
  ylim=c(1, 1e6),
  sub="Source: John Hopkins Curated Dataset"
)

polygon(
  c(p_rng, rev(p_rng)),
  c(us_pred[,2], rev(us_pred[,3])),
  border=FALSE,
  col=rgb(0, 0, 0, 0.2))
  

# Annotations to US Plot
curve(expgrowth(us_model,x), col='red', add=TRUE)

text(as.Date("2020-03-04"), 75, paste0(round(100*(exp(coef(us_model)[2])-1),1), "% a day"), pos=4)
text(as.Date("2020-03-04"), 45, paste0("Double ", round(log(2)/coef(us_model)[2], 2), " days"), pos=4)
abline(v=as.Date("2020-02-26"), col='blue')
text(as.Date("2020-02-26"), 100000, "Trump", pos=2)
text(as.Date("2020-02-26"), 65000, "'We’re going very substantially down, not up.'", pos=2, cex=0.70)
legend(as.Date("2020-01-25"), 10000, c("Cases", "Deaths"), pch=c(1,4))

abline(v=as.Date("2020-03-12"), col='blue')
text(as.Date("2020-03-12"), 10000, "Europe",pos=2)
text(as.Date("2020-03-12"),  6500, "Travel Ban", pos=2)


text(as.Date("2020-03-29"), 150000, "Rate Change", pos=2)

dev.off()


# Number table of predictions
us_pred2      <- as.data.frame(round(us_pred2))
us_pred2$date <- p_rng2


### Italy
png("italy.png")

semilog(
  italy_data,
  ylim=c(1, 1e6),
  xlim=c(as.Date("2020-01-22"),as.Date("2020-04-10")),
  main="Italy COVID-19 Cases",
  sub="Source: John Hopkins Curated Dataset"
)
abline(v=as.Date("2020-02-22"), col='blue') # First Quarantine
text(as.Date("2020-02-22"), 75000, "Quarantine", pos=2)
abline(v=as.Date("2020-03-07"), col='blue') # Second Quarantine
text(as.Date("2020-03-07"), 50000, "Expanded", pos=2)

legend(as.Date("2020-01-25"), 10000, c("Cases", "Deaths"), pch=c(1,4))
dev.off()

### South Korea
png("sk.png")

semilog(
  sk_data,
  ylim=c(1, 1e6),
  xlim=c(as.Date("2020-01-22"),as.Date("2020-04-10")),
  main="South Korea COVID-19 Cases",
  sub="Source: John Hopkins Curated Dataset"
)
abline(v=as.Date("2020-02-18"), col='blue')
text(as.Date("2020-02-18"), 100000, "Shincheonji", pos=2)
abline(v=as.Date("2020-02-29"), col='blue') 
text(as.Date("2020-02-29"), 50000, "Mass\nClosures", pos=2)
#abline(v=67, col='blue') # Second Quarantine
#text(67, 50000, "Expanded", pos=2)

legend(as.Date("2020-01-25"), 10000, c("Cases", "Deaths"), pch=c(1,4))
dev.off()

iran_data <- hopkins('Iran', raw=raw)
png('iran.png')
semilog(
  iran_data,
  ylim=c(1, 1e6),
  xlim=c(as.Date("2020-01-22"),as.Date("2020-04-10")),
  main="Iran COVID-19 Cases",
  sub="Source: John Hopkins Curated Dataset"
)

legend(25, 10000, c("Cases", "Deaths"), pch=c(1,4))
dev.off()


spain_data <- hopkins('Spain', raw=raw)
png('spain.png')
semilog(
  spain_data,
  ylim=c(1, 1e6),
  xlim=c(as.Date("2020-01-22"),as.Date("2020-04-10")),
  main="Spain COVID-19 Cases",
  sub="Source: John Hopkins Curated Dataset"
)

legend(25, 10000, c("Cases", "Deaths"), pch=c(1,4))
dev.off()


france_data <- hopkins('France', raw=raw)
png('france.png')
semilog(
  france_data,
  ylim=c(1, 1e6),
  xlim=c(as.Date("2020-01-22"),as.Date("2020-04-10")),
  main="France COVID-19 Cases",
  sub="Source: John Hopkins Curated Dataset"
)

legend(25, 10000, c("Cases", "Deaths"), pch=c(1,4))
dev.off()


germany_data <- hopkins('Germany', raw=raw)
png('germany.png')
semilog(
  germany_data,
  ylim=c(1, 1e6),
  xlim=c(as.Date("2020-01-22"),as.Date("2020-04-10")),
  main="Germany COVID-19 Cases",
  sub="Source: John Hopkins Curated Dataset"
)

legend(25, 10000, c("Cases", "Deaths"), pch=c(1,4))
dev.off()

norway_data <- hopkins('Norway', raw=raw)
png('norway.png')
semilog(
  norway_data,
  ylim=c(1, 1e6),
  xlim=c(as.Date("2020-01-22"),as.Date("2020-04-10")),
  main="Norway COVID-19 Cases",
  sub="Source: John Hopkins Curated Dataset"
)

legend(25, 10000, c("Cases", "Deaths"), pch=c(1,4))
dev.off()
