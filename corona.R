china_nhc_cases <- data.frame(
  doy   = 16:64, # 2020
  cases = c(45, 62, 121, 198, 291, 440, 571, 830, 1287, 1975, 2744, 4515, 5974,
            7711, 9692, 11791, 14380, 17205, 20438, 24324, 28018,
            31161, 34546, 37198,40171,42638,44276,59493,63851,
            66286, 68500, 70548, 72436, 74185,74576,75465,76288,76936,
            77345, 77658, 78064, 78514, 78824, 79251, 80026, 80151,
            80270, 80411, 80555),
  deaths= c(NA, NA, NA, NA, NA, NA, NA, 25, 41, 56, 80,106,132,
            170, 213, 259, 304, 362, 426, 492, 565, 637,723,804,908,
            1016,1110,1355,1381,1520,1666,1718,1770,2006,2118,2234,2345,
            2441,2592,2663, 2715, 2744, 2788, 2835, 2912, 2944,
            2981,3012,3042)
)

model1 <- lm(log(cases) ~ doy, china_nhc_cases[16:28-15,])
summary(model1)



png("China.png")

with(china_nhc_cases,
  plot(doy, cases, log="y",
    main="China NHC data",
    xlab="2020 Julian Day",
    ylab="Cases (semilog)",
    yaxt="n"
  )
)


y1 <- floor(log10(range(china_nhc_cases$cases)))
pow <- seq(y1[1], y1[2]+1)
ticksat <- as.vector(sapply(pow, function(p) (1:10)*10^p))
axis(2, 10^pow, labels=format(10^pow, scientific=FALSE, big.mark=","))
axis(2, ticksat, labels=NA, tcl=-0.25, lwd=0, lwd.ticks=1)


f <- function(model, x)
{
  cf <- coef(model)
  exp(cf[1] + x*cf[2])
}
curve(f(model1,x), col='red', add=TRUE)

summary(lm(log(cases) ~ poly(doy,4), china_nhc_cases))

abline(v=23, col='blue') # Quarantine
text(22.7, 200, pos=4, "Quarantine", col='blue')
abline(v=23+5, col='darkgreen') # Incubation period estimate
text(27.7, 50, pos=4, 'Q+Incubation', col='darkgreen') #https://www.thelancet.com/journals/lancet/article/PIIS0140-6736(20)30260-9/fulltext#tbl1
abline(v=42, col='brown')
text(41.7, 50, pos=4, 'WHO Arrival', col='brown')

with(china_nhc_cases, points(doy, deaths, pch=4))

# 5-day lag
with(china_nhc_cases,prop.test(deaths[8:21], cases[3:16]))

# 4-day lag
with(china_nhc_cases,prop.test(deaths[8:21], cases[4:17]))


# Assume New Growth Rate
model2 <- lm(log(cases) ~ doy, china_nhc_cases[(52-15):length(china_nhc_cases$doy),])
summary(model2)
curve(f(model2,x), col='darkgreen', add=TRUE)

legend(50, 400, c("Cases", "Deaths"), pch=c(1,4))
text(20, 1000, substitute(alpha == x, list(x=round(coef(model1)[2],3))))
text(20, 75000, substitute(alpha == x, list(x=round(coef(model2)[2],3))))
text(20, 10000, expression(e^(alpha*t)))

dev.off()

# Logistic Growth Model
# Logistic model fails to explain bend
#
#data   <- china_nhc_cases
#data$t <- data$doy - 16
#
#
#
# lmodel <- nls(log(cases) ~ log(k/(1+((k-45)/45)*exp(-r*t))),
#               data,
#               start=c(k=10000, r=0.4))
# summary(lmodel)
# k <- coef(lmodel)[1]
# r <- coef(lmodel)[2]
# curve(k/(1+((k-45)/45)*exp(-r*(x-16))), add=TRUE, col='orange')
# 
# 

# This leaves out the 45 from princess and 3 that were repatriated
# into isolation. I.e., tracking cases identified in the wild.
us_data <- data.frame(
  doy    = c(20:65),
  cases  = c(1, 1, 1, 1, 2, 4, 4, 4, 4, 5, 6, 7, 10, 10, 10,
             11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11,
             11, 11, 11, 13, 13, 13, 13, 13, 13, 
             14, 14, 18, 23, 41, 57, 85, 112, 175, 237),
  deaths = c(rep(0, 41), 3, 6, 9, 10, 14)
)

df <- us_data[38:length(us_data$doy),]

us_model <- lm(log(cases) ~ doy, df)

summary(us_model)

us_pred <- exp(predict(us_model, data.frame(doy=58:100), interval=c("prediction")))
us_pred

png("us.png")
with(us_data,
  plot(doy, cases, log="y",
    main="US COVID-19 Cases",
    sub="Non-repatriated",
    xlab="2020 Julian Day",
    ylab="Cases (semilog)",
    yaxt="n",
    ylim=c(1, 1e6),
    xlim=c(20, 100)
  )
)
    
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
dev.off()


# plg <- function(t, k, r, p0) k*p0*exp(r*t)/(k+p0*(exp(r*t)-1))
# curve(log(plg(x, 3.3e8, 0.36, 10)), from = 0, to = 90)

library(chron)
us_pred      <- as.data.frame(round(us_pred))
mdy          <- month.day.year(58:100, c(month=1, day=1, year=2020))
us_pred$date <- ISOdatetime(mdy$year, mdy$month, mdy$day, 0, 0, 0)

