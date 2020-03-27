
source('johnhopkins.R')
source('semilog.R')

#raw        <- hopkins_raw()

italy_data <- hopkins("Italy",                   raw=raw)
italy_data <- italy_data[italy_data$date > as.Date("2020-02-22"),]
italy_data$doy <- as.numeric(italy_data$date) - 18315 + 53


library(rms)

with(italy_data, {
    plot(doy[cases>0], cases[cases>0], log="y",
         xlab="2020 Julian Day",
         ylab="Cases (semilog)",
         yaxt="n"
    )

    y1 <- range(cases[cases >0])
    y1 <- floor(log10(y1))
    pow <- seq(y1[1], y1[2]+1)
    ticksat <- as.vector(sapply(pow, function(p) (1:10)*10^p))
    axis(2, 10^pow, labels=format(10^pow, scientific=FALSE, big.mark=","))
    axis(2, ticksat, labels=NA, tcl=-0.25, lwd=0, lwd.ticks=1)
})



model <- lm(log(cases) ~ ns(doy,5), italy_data)
dr <- as.numeric(range(italy_data$doy))
smooth <- data.frame(doy=seq(dr[1], dr[2], by=0.1))
smooth$cases <- exp(predict(model,smooth))
lines(smooth$doy, smooth$cases, col='red')

# The derivative is the local slope!
dY <- diff(log(smooth$cases))/diff(smooth$doy)
dX <- rowMeans(embed(smooth$doy,2))

plot(dX, dY, type="l", main="Derivative")

# Interesting approach to R0 
# Could tighten this work up by same method
# https://www.ijidonline.com/article/S1201-9712(20)30091-6/fulltext
# https://www.ijidonline.com/action/showPdf?pii=S1201-9712%2820%2930091-6
# Serial Interval = 7.5

# More direct to our current purpose
# https://www.medrxiv.org/content/10.1101/2020.01.27.20018952v1.full.pdf
L <- 2 # Latent Period
D <- 3.1 # Infectious Period

# Incubation time is around 5.1 days by NEJM estimate. I.e. L+D=5.1
# Paper values were far too high.

R0 <- dY^2*L*D+dY*(L+D) + 1
plot(dX, R0, typ="l", xlab="Julian Day of Year", ylab="R0", main="Italy moving R0 SEIR")


## Do it again for Tennessee


tn_data    <- hopkins("US", province = c("TN", "Tennessee"), raw=raw)

with(tn_data, {
    plot(doy[cases>0], cases[cases>0], log="y",
         xlab="2020 Julian Day",
         ylab="Cases (semilog)",
         yaxt="n"
    )

    y1 <- range(cases[cases >0])
    y1 <- floor(log10(y1))
    pow <- seq(y1[1], y1[2]+1)
    ticksat <- as.vector(sapply(pow, function(p) (1:10)*10^p))
    axis(2, 10^pow, labels=format(10^pow, scientific=FALSE, big.mark=","))
    axis(2, ticksat, labels=NA, tcl=-0.25, lwd=0, lwd.ticks=1)
})



model <- lm(log(cases) ~ ns(doy,3), tn_data)
dr <- as.numeric(range(tn_data$doy))
smooth <- data.frame(doy=seq(dr[1], dr[2], by=0.1))
smooth$cases <- exp(predict(model,smooth))
lines(smooth$doy, smooth$cases, col='red')

# The derivative is the local slope!
dY <- diff(log(smooth$cases))/diff(smooth$doy)
dX <- rowMeans(embed(smooth$doy,2))

plot(dX, dY, type="l", main="Derivative")


R0 <- dY^2*L*D+dY*(L+D) + 1
plot(dX, R0, typ="l", xlab="Julian Day of Year", ylab="R0", main="TH moving R0 SEIR")

