
# https://en.wikipedia.org/wiki/2019%E2%80%9320_coronavirus_outbreak

source('johnhopkins.R')

us_data$deaths[us_data$deaths == 0] <- NA

model1 <- lm(log(cases) ~ doy, china_data[16:28-15,])
summary(model1)


f <- function(model, x)
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
with(us_data,{
  plot(doy, cases, log="y",
    main="Non-repatriated US COVID-19 Cases",
    xlab="2020 Julian Day",
    ylab="Cases (semilog)",
    yaxt="n",
    ylim=c(1, 1e6),
    xlim=c(20, 100),
    sub="Source: John Hopkins Curated Dataset"
  )
  points(doy[deaths > 0], deaths[deaths > 0], pch=4)
})
    
polygon(
  c(58:100, 100:58),
  c(us_pred[,2], rev(us_pred[,3])),
  border=FALSE,
  col=rgb(0, 0, 0, 0.3))
  

#y1 <- floor(log10(range(us_data$cases)))
y1 <- c(0,6)
pow <- seq(y1[1], y1[2]+1)
ticksat <- as.vector(sapply(pow, function(p) (1:10)*10^p))
axis(2, 10^pow, labels=format(10^pow, scientific=FALSE, big.mark=","))
axis(2, ticksat, labels=NA, tcl=-0.25, lwd=0, lwd.ticks=1)
curve(f(us_model,x), col='red', add=TRUE)

text(64, 75, paste0(round(100*(exp(coef(us_model)[2])-1),1), "% a day"), pos=4)
text(64, 45, paste0("Double ", round(log(2)/coef(us_model)[2], 2), " days"), pos=4)
abline(v=57, col='blue')
text(57, 100000, "Trump", pos=2)
text(57, 65000, "'We’re going very substantially down, not up.'", pos=2, cex=0.70)
legend(25, 10000, c("Cases", "Deaths"), pch=c(1,4))

dev.off()

# plg <- function(t, k, r, p0) k*p0*exp(r*t)/(k+p0*(exp(r*t)-1))
# curve(log(plg(x, 3.3e8, 0.36, 10)), from = 0, to = 90)

library(chron)
us_pred      <- as.data.frame(round(us_pred))
mdy          <- month.day.year(58:100, c(month=1, day=1, year=2020))
us_pred$date <- ISOdatetime(mdy$year, mdy$month, mdy$day, 0, 0, 0)

