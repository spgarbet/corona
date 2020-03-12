
# https://en.wikipedia.org/wiki/2019%E2%80%9320_coronavirus_outbreak

source('johnhopkins.R')

us_data    <- hopkins("US", "Princess")
china_data <- hopkins("Mainland China")
italy_data <- hopkins("Italy")
sk_data    <- hopkins("Republic of Korea")

semilog    <- function(data, ...)
{
  with(data, {
    plot(doy[cases>0], cases[cases>0], log="y",
      xlab="2020 Julian Day",
      ylab="Cases (semilog)",
      yaxt="n",
      ...,
    )
    points(doy[deaths > 0], deaths[deaths > 0], pch=4)
    
    y1 <- list(...)[['ylim']]
    if(is.null(y1)) y1 <- range(us_data$cases[cases >0])
    y1 <- floor(log10(y1))
    pow <- seq(y1[1], y1[2]+1)
    ticksat <- as.vector(sapply(pow, function(p) (1:10)*10^p))
    axis(2, 10^pow, labels=format(10^pow, scientific=FALSE, big.mark=","))
    axis(2, ticksat, labels=NA, tcl=-0.25, lwd=0, lwd.ticks=1)
  })
}

# Plot straight lines from exponential model
expgrowth <- function(model, x)
{
  cf <- coef(model)
  exp(cf[1] + x*cf[2])
}

df <- us_data[38:length(us_data$doy),]

us_model <- lm(log(cases) ~ doy, df)

summary(us_model)

us_pred <- exp(predict(us_model, data.frame(doy=58:100), interval=c("prediction")))
us_pred

png("us.png")

semilog(
  us_data, 
  main="Non-repatriated US COVID-19 Cases",
  ylim=c(1, 1e6),
  xlim=c(20, 100),
  sub="Source: John Hopkins Curated Dataset"
)

polygon(
  c(58:100, 100:58),
  c(us_pred[,2], rev(us_pred[,3])),
  border=FALSE,
  col=rgb(0, 0, 0, 0.3))
  

# Annotations to US Plot
curve(expgrowth(us_model,x), col='red', add=TRUE)

text(64, 75, paste0(round(100*(exp(coef(us_model)[2])-1),1), "% a day"), pos=4)
text(64, 45, paste0("Double ", round(log(2)/coef(us_model)[2], 2), " days"), pos=4)
abline(v=57, col='blue')
text(57, 100000, "Trump", pos=2)
text(57, 65000, "'We’re going very substantially down, not up.'", pos=2, cex=0.70)
legend(25, 10000, c("Cases", "Deaths"), pch=c(1,4))

abline(v=72, col='blue')
text(72, 10000, "Europe",pos=2)
text(72,  6500, "Travel Ban", pos=2)

dev.off()


# Number table of predictions
us_pred      <- as.data.frame(round(us_pred))
mdy          <- month.day.year(58:100 - 1, c(month=1, day=1, year=2020))
us_pred$date <- ISOdatetime(mdy$year, mdy$month, mdy$day, 0, 0, 0)


### Italy
png("italy.png")

semilog(
  italy_data,
  ylim=c(1, 1e6),
  xlim=c(20, 100),
  main="Italy COVID-19 Cases",
  sub="Source: John Hopkins Curated Dataset"
)
abline(v=53, col='blue') # First Quarantine
text(53, 75000, "Quarantine", pos=2)
abline(v=67, col='blue') # Second Quarantine
text(67, 50000, "Expanded", pos=2)

legend(25, 10000, c("Cases", "Deaths"), pch=c(1,4))
dev.off()

### South Korea
png("sk.png")

semilog(
  sk_data,
  ylim=c(1, 1e6),
  xlim=c(20, 100),
  main="South Korea COVID-19 Cases",
  sub="Source: John Hopkins Curated Dataset"
)
abline(v=49, col='blue')
text(49, 100000, "Shincheonji", pos=2)
abline(v=60, col='blue') 
text(60, 50000, "Mass\nClosures", pos=2)
#abline(v=67, col='blue') # Second Quarantine
#text(67, 50000, "Expanded", pos=2)

legend(25, 10000, c("Cases", "Deaths"), pch=c(1,4))
dev.off()

iran_data <- hopkins('Iran')
png('iran.png')
semilog(
  iran_data,
  ylim=c(1, 1e6),
  xlim=c(20, 100),
  main="Iran COVID-19 Cases",
  sub="Source: John Hopkins Curated Dataset"
)

legend(25, 10000, c("Cases", "Deaths"), pch=c(1,4))
dev.off()


spain_data <- hopkins('Spain')
png('spain.png')
semilog(
  spain_data,
  ylim=c(1, 1e6),
  xlim=c(20, 100),
  main="Spain COVID-19 Cases",
  sub="Source: John Hopkins Curated Dataset"
)

legend(25, 10000, c("Cases", "Deaths"), pch=c(1,4))
dev.off()


france_data <- hopkins('France')
png('france.png')
semilog(
  france_data,
  ylim=c(1, 1e6),
  xlim=c(20, 100),
  main="France COVID-19 Cases",
  sub="Source: John Hopkins Curated Dataset"
)

legend(25, 10000, c("Cases", "Deaths"), pch=c(1,4))
dev.off()


germany_data <- hopkins('Germany')
png('germany.png')
semilog(
  germany_data,
  ylim=c(1, 1e6),
  xlim=c(20, 100),
  main="Germany COVID-19 Cases",
  sub="Source: John Hopkins Curated Dataset"
)

legend(25, 10000, c("Cases", "Deaths"), pch=c(1,4))
dev.off()