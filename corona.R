china_nhc_cases <- data.frame(
  doy   = 16:62, # 2020
  cases = c(45, 62, 121, 198, 291, 440, 571, 830, 1287, 1975, 2744, 4515, 5974,
            7711, 9692, 11791, 14380, 17205, 20438, 24324, 28018,
            31161, 34546, 37198,40171,42638,44276,59493,63851,
            66286, 68500, 70548, 72436, 74185,74576,75465,76288,76936,
            77345, 77658, 78064, 78514, 78824, 79251, 80026, 80151,
            80270),
  deaths= c(NA, NA, NA, NA, NA, NA, NA, 25, 41, 56, 80,106,132,
            170, 213, 259, 304, 362, 426, 492, 565, 637,723,804,908,
            1016,1110,1355,1381,1520,1666,1718,1770,2006,2118,2234,2345,
            2441,2592,2663, 2715, 2744, 2788, 2835, 2912, 2944,
            2981)
)

model1 <- lm(log(cases) ~ doy, china_nhc_cases[16:28-15,])
summary(model1)



#library(lattice)
#library(latticeExtra)
#xyplot(y~x, data=d, scales=list(y=list(log=10)),
#       yscale.components=yscale.components.log10ticks) 

#xyplot(cases~doy, data=china_nhc_cases, 
#       scale=list(y=list(log=10)),
#       yscale.components=yscale.components.log10ticks
#       )

with(china_nhc_cases,
  plot(doy, cases, log="y",
  main="China NHC data",
  xlab="2020 Julian Day",
  ylab="Cases (semilog)",
  yaxt="n"))

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
model2 <- lm(log(cases) ~ doy, china_nhc_cases[(48-15):length(china_nhc_cases$doy),])
summary(model2)
curve(f(model2,x), col='darkgreen', add=TRUE)

legend(50, 400, c("Cases", "Deaths"), pch=c(1,4))


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
  doy    = c(21:63),
  cases  = c(1, 1, 1, 1, 2, 4, 4, 4, 4, 5, 6, 7, 10, 10, 10,
             11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11,
             11, 11, 11, 13, 13, 13, 13, 13, 13, 
             14, 14, 18, 23, 41, 57, 74),
  deaths = c(rep(0, 41), 3, 6)
)

df <- us_data[38:43,]

us_model <- lm(log(cases) ~ doy, df)

summary(us_model)

exp(predict(us_model, data.frame(doy=c(63:120)), interval=c("prediction")))