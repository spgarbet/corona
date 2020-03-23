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
    if(is.null(y1)) y1 <- range(cases[cases >0])
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