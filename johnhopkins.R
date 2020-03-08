library(chron)

hopkins <- read.csv("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Confirmed.csv")

us_raw <- hopkins[hopkins$Country.Region == 'US',]
diamond_princess <- grepl("Diamond Princess", as.character(us_raw$Province.State))
us_raw <- us_raw[!diamond_princess, 5:ncol(us_raw)]

dates <- strsplit(substr(colnames(us_raw), 2, nchar(colnames(us_raw))), "[.]")
doy   <- julian(
  sapply(dates, function(x) as.numeric(x[1])),
  sapply(dates, function(x) as.numeric(x[2])),
  sapply(dates, function(x) as.numeric(x[3]))+2000,
  c(month=1, day=1, year=2020))+1
dates <- sapply(dates, function(x) paste0(x[1], "/", x[2], "/20", x[3]))

us_data <- data.frame(
  date   = dates,
  doy    = doy,
  cases  = colSums(us_raw)
)

rownames(us_data) <- NULL
rm(diamond_princess)
rm(us_raw)

china_raw <- hopkins[hopkins$Country.Region == 'Mainland China' ,5:ncol(hopkins)]

china_data <- rbind(
  data.frame(
    date   = paste0("1/",16:21,"/20"), 
    doy    = 16:21,
    cases  = c(45, 62, 121, 198, 291, 440)
  ),
  data.frame(
    date   = dates,
    doy    = doy,
    cases  = colSums(china_raw)
  )
)
rownames(china_data) <- NULL

rm(china_raw)
rm(doy)
rm(dates)
rm(hopkins)


